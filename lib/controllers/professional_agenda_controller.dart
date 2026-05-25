import 'package:flutter/foundation.dart';
import 'package:pet_appointment/models/appointment_model.dart';
import 'package:pet_appointment/services/appointment_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ProfessionalAgendaController extends ChangeNotifier {
  final _service = AppointmentService();

  List<AppointmentModel> appointments = [];
  bool isLoading = false;

  RealtimeChannel? _appointmentsChannel;

  /// Retorna todas las citas para el día indicado ordenadas por hora.
  List<AppointmentModel> appointmentsForDay(DateTime day) {
    final dayStart = DateTime(day.year, day.month, day.day);
    final dayEnd = DateTime(day.year, day.month, day.day, 23, 59, 59);

    return appointments.where((apt) {
      final availSlot = apt.scheduledAt;
      return availSlot != null &&
          availSlot.isAfter(dayStart) &&
          availSlot.isBefore(dayEnd);
    }).toList()..sort(
      (a, b) => (a.scheduledAt ?? DateTime.now()).compareTo(
        b.scheduledAt ?? DateTime.now(),
      ),
    );
  }

  /// Retorna todas las citas para la semana indicada, agrupadas por día.
  Map<int, List<AppointmentModel>> appointmentsForWeek(DateTime weekStart) {
    final result = <int, List<AppointmentModel>>{};

    for (int i = 0; i < 7; i++) {
      final day = weekStart.add(Duration(days: i));
      result[i] = appointmentsForDay(day);
    }

    return result;
  }

  /// Carga todas las citas del profesional autenticado.
  Future<void> loadAppointments() async {
    isLoading = true;
    notifyListeners();
    try {
      appointments = await _service.fetchProfessionalAppointments();
      notifyListeners();
    } catch (e) {
      debugPrint('Error loading appointments: $e');
      rethrow;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  /// Suscribe a cambios en tiempo real en las citas del profesional.
  void subscribeRealtime() {
    unsubscribe();
    _appointmentsChannel = _service.subscribeToProfessionalAppointments(
      onChanged: _onAppointmentsChanged,
    );
  }

  /// Confirma una cita (cambia su estado a 'Confirmada').
  Future<void> confirmAppointment(String appointmentId) async {
    try {
      await _service.updateAppointmentStatus(
        appointmentId: appointmentId,
        newStatus: 'Confirmada',
      );
      // Refrescar lista local
      appointments = await _service.fetchProfessionalAppointments();
      notifyListeners();
    } catch (e) {
      debugPrint('Error confirming appointment: $e');
      rethrow;
    }
  }

  /// Callback para cuando hay cambios en appointments (insert, update, delete).
  Future<void> _onAppointmentsChanged() async {
    try {
      appointments = await _service.fetchProfessionalAppointments();
      notifyListeners();
    } catch (e) {
      debugPrint('Error refreshing appointments: $e');
    }
  }

  void unsubscribe() {
    _appointmentsChannel?.unsubscribe();
  }

  @override
  void dispose() {
    unsubscribe();
    super.dispose();
  }
}
