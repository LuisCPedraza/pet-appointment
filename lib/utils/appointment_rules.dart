/// Reglas puras relacionadas con citas.
bool canClientCancelAppointment(String status) {
  return status == 'En espera' || status == 'Confirmada';
}
