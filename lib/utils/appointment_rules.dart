import 'package:pet_appointment/models/appointment_status.dart';

/// Reglas puras relacionadas con citas.
bool canClientCancelAppointment(String status) {
  return status == 'En espera' || status == 'Confirmada';
}

bool canProfessionalUpdateAppointmentStatus(
  String currentStatus,
  String nextStatus,
) {
  final current = AppointmentStatus.fromString(currentStatus);
  final next = AppointmentStatus.fromString(nextStatus);
  if (current == null || next == null) return false;
  return current.canTransitionTo(next);
}

bool canAdminUpdateAppointmentStatus(String currentStatus, String nextStatus) {
  return canProfessionalUpdateAppointmentStatus(currentStatus, nextStatus);
}
