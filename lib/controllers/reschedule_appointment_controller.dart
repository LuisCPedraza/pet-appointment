import 'package:flutter/foundation.dart';
import 'package:pet_appointment/controllers/calendar_controller.dart';
import 'package:pet_appointment/models/appointment_model.dart';
import 'package:pet_appointment/models/availability_slot.dart';
import 'package:pet_appointment/services/appointment_service.dart';

/// Controlador para gestionar el flujo de reprogramación de citas.
/// Utiliza la misma experiencia que el calendario de creación,
/// pero mantiene un controlador independiente para reprogramación.
class RescheduleAppointmentController extends CalendarController {
  final _appointmentService = AppointmentService();

  /// Cita original que será reprogramada
  late AppointmentModel originalAppointment;

  /// Mensaje de error de reprogramación o carga
  String? errorMessage;

  /// Inicializa el controlador con la cita que será reprogramada.
  Future<void> initialize(AppointmentModel appointment) async {
    try {
      isLoading = true;
      errorMessage = null;
      notifyListeners();

      originalAppointment = appointment;
      selectedServiceId = appointment.serviceId.isNotEmpty
          ? appointment.serviceId
          : null;
      selectedProfessionalId = appointment.professionalId.isNotEmpty
          ? appointment.professionalId
          : null;
      selectedPetId = appointment.petId;
      focusedDay = appointment.scheduledAt ?? DateTime.now();
      selectedDay = appointment.scheduledAt != null
          ? DateTime(
              appointment.scheduledAt!.year,
              appointment.scheduledAt!.month,
              appointment.scheduledAt!.day,
            )
          : null;

      await super.loadInitialData();
      selectedPetId = appointment.petId;
      await loadMonth(focusedDay);
      _restoreOriginalSlot();
    } catch (e) {
      errorMessage = 'Error al cargar datos de reprogramación: $e';
      debugPrint(errorMessage);
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  void _restoreOriginalSlot() {
    if (originalAppointment.availabilityId == null || selectedDay == null) {
      return;
    }

    final daySlots = slotsForDay(selectedDay);
    final matchingSlot = daySlots
        .where((slot) => slot.id == originalAppointment.availabilityId)
        .toList();
    if (matchingSlot.isNotEmpty) {
      selectedSlot = matchingSlot.first;
      notifyListeners();
    }
  }

  @override
  Future<void> loadMonth(DateTime month) async {
    final from = DateTime(month.year, month.month, 1);
    final to = DateTime(month.year, month.month + 1, 0, 23, 59, 59);

    try {
      final slots = await _appointmentService.fetchAllSlots(
        from: from,
        to: to,
        serviceId: selectedServiceId,
        professionalId: originalAppointment.professionalId,
      );

      final grouped = <DateTime, List<AvailabilitySlot>>{};
      for (final slot in slots) {
        final key = DateTime(slot.start.year, slot.start.month, slot.start.day);
        grouped.putIfAbsent(key, () => []).add(slot);
      }
      slotsByDay = grouped;

      final booked = await _appointmentService.fetchAllBookedSlotIds(
        from: from,
        to: to,
      );
      if (originalAppointment.availabilityId != null) {
        booked.remove(originalAppointment.availabilityId);
      }
      bookedIds = booked;
    } catch (e) {
      debugPrint('Error cargando calendario de reprogramación: $e');
      slotsByDay = {};
      bookedIds = {};
    } finally {
      notifyListeners();
    }
  }

  @override
  Future<void> refreshBookedIds() async {
    final month = focusedDay;
    final from = DateTime(month.year, month.month, 1);
    final to = DateTime(month.year, month.month + 1, 0, 23, 59, 59);
    try {
      final booked = await _appointmentService.fetchAllBookedSlotIds(
        from: from,
        to: to,
      );
      if (originalAppointment.availabilityId != null) {
        booked.remove(originalAppointment.availabilityId);
      }
      bookedIds = booked;
      if (selectedSlot != null && booked.contains(selectedSlot!.id)) {
        selectedSlot = null;
      }
      notifyListeners();
    } catch (e) {
      debugPrint('Error actualizando bookings de reprogramación: $e');
    }
  }

  @override
  Future<void> refreshSlots() async {
    final month = focusedDay;
    final from = DateTime(month.year, month.month, 1);
    final to = DateTime(month.year, month.month + 1, 0, 23, 59, 59);
    try {
      final slots = await _appointmentService.fetchAllSlots(
        from: from,
        to: to,
        serviceId: selectedServiceId,
        professionalId: originalAppointment.professionalId,
      );
      final grouped = <DateTime, List<AvailabilitySlot>>{};
      for (final slot in slots) {
        final key = DateTime(slot.start.year, slot.start.month, slot.start.day);
        grouped.putIfAbsent(key, () => []).add(slot);
      }
      slotsByDay = grouped;
      notifyListeners();
    } catch (e) {
      debugPrint('Error actualizando slots de reprogramación: $e');
    }
  }

  @override
  Future<void> changeService(String? serviceId) async {
    selectedServiceId = serviceId;
    selectedSlot = null;
    selectedDay = null;
    if (serviceId == null) {
      slotsByDay = {};
      notifyListeners();
      return;
    }
    notifyListeners();
    await loadMonth(focusedDay);
  }

  @override
  Future<void> changeProfessional(String? professionalId) async {
    selectedProfessionalId = professionalId;
    selectedSlot = null;
    selectedDay = null;
    if (professionalId == null) {
      slotsByDay = {};
      bookedIds = {};
      notifyListeners();
      return;
    }

    notifyListeners();
    await loadMonth(focusedDay);
  }

  /// Reprograma la cita actualizando el slot, mascota, servicio y notas existentes.
  Future<bool> rescheduleAppointment(String notes) async {
    if (!['En espera', 'Confirmada'].contains(originalAppointment.status)) {
      errorMessage =
          'Solo se pueden reprogramar citas en espera o confirmadas.';
      notifyListeners();
      return false;
    }

    if (selectedSlot == null) {
      errorMessage = 'Debes seleccionar un nuevo horario.';
      notifyListeners();
      return false;
    }

    if (selectedPetId == null) {
      errorMessage = 'Debes seleccionar una mascota.';
      notifyListeners();
      return false;
    }

    try {
      isSubmitting = true;
      errorMessage = null;
      notifyListeners();

      await _appointmentService.updateAppointment(
        appointmentId: originalAppointment.id,
        newAvailabilityId: selectedSlot!.id,
        petId: selectedPetId!,
        serviceId: selectedServiceId ?? selectedSlot!.serviceId,
        notes: notes.trim().isEmpty ? null : notes.trim(),
      );

      return true;
    } catch (e) {
      errorMessage = 'Error al reprogramar la cita: $e';
      debugPrint(errorMessage);
      return false;
    } finally {
      isSubmitting = false;
      notifyListeners();
    }
  }
}
