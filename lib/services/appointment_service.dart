import 'dart:async';

import '../models/appointment.dart';

/// Servicio simple inicial para obtener citas.
/// Más adelante integrar con Supabase y Realtime.
class AppointmentService {
  // Mock: devuelve citas del día ordenadas
  Future<List<Appointment>> fetchDailyAppointments(DateTime day) async {
    await Future.delayed(Duration(milliseconds: 200));
    final now = DateTime.now();
    return [
      Appointment(
        id: 'a1',
        startsAt: DateTime(now.year, now.month, now.day, 9, 0),
        clientName: 'María Pérez',
        petName: 'Fido',
        serviceName: 'Corte de pelo',
        status: 'scheduled',
      ),
      Appointment(
        id: 'a2',
        startsAt: DateTime(now.year, now.month, now.day, 11, 30),
        clientName: 'Juan Gómez',
        petName: 'Luna',
        serviceName: 'Vacunación',
        status: 'scheduled',
      ),
      Appointment(
        id: 'a3',
        startsAt: DateTime(now.year, now.month, now.day, 15, 0),
        clientName: 'Ana Ruiz',
        petName: 'Nube',
        serviceName: 'Consulta',
        status: 'cancelled',
      ),
    ];
  }

  Future<Map<String, int>> fetchWeeklySummary(DateTime weekStart) async {
    await Future.delayed(Duration(milliseconds: 150));
    return {
      'Mon': 3,
      'Tue': 2,
      'Wed': 4,
      'Thu': 1,
      'Fri': 2,
      'Sat': 0,
      'Sun': 0,
    };
  }

  // Realtime placeholder stream that emits an updated list periodically (mock)
  Stream<List<Appointment>> watchDailyRealtime(DateTime day) async* {
    while (true) {
      final list = await fetchDailyAppointments(day);
      yield list;
      await Future.delayed(Duration(seconds: 10));
    }
  }
}
