import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:pet_appointment/models/appointment_model.dart';
import 'package:pet_appointment/widgets/app_shell.dart';

/// Pantalla de confirmación inmediata tras reservar una cita.
/// Muestra un resumen completo de los detalles de la cita agendada
/// y ofrece opciones para navegar al historial o al inicio.
class AppointmentConfirmScreen extends StatelessWidget {
  final AppointmentModel appointment;

  const AppointmentConfirmScreen({
    super.key,
    required this.appointment,
  });

  /// Retorna el ícono según el estado de la cita.
  IconData _statusIcon() {
    return switch (appointment.status) {
      'En espera' => Icons.schedule,
      'Confirmada' => Icons.check_circle,
      'En progreso' => Icons.hourglass_top,
      'Atendida' => Icons.done_all,
      'Cancelada' => Icons.cancel,
      _ => Icons.info,
    };
  }

  /// Retorna el color del badge del estado.
  Color _statusColor() {
    return switch (appointment.status) {
      'En espera' => Colors.blue,
      'Confirmada' => Colors.green,
      'En progreso' => Colors.amber,
      'Atendida' => Colors.grey,
      'Cancelada' => Colors.red,
      _ => Colors.grey,
    };
  }

  @override
  Widget build(BuildContext context) {
    final dateFormatter = DateFormat('EEEE d MMMM yyyy', 'es_ES');
    final timeFormatter = DateFormat('HH:mm', 'es_ES');

    final appointmentDate = appointment.scheduledAt != null
        ? dateFormatter.format(appointment.scheduledAt!).capitalize()
        : 'Fecha no disponible';
    final appointmentTime = appointment.scheduledAt != null
        ? timeFormatter.format(appointment.scheduledAt!)
        : 'Hora no disponible';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Confirmación de Reserva'),
        centerTitle: true,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Header con ícono de éxito
            Container(
              width: double.infinity,
              color: Colors.green.shade50,
              padding: const EdgeInsets.symmetric(vertical: 30),
              child: Column(
                children: [
                  Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.green.withAlpha((0.2 * 255).toInt()),
                    ),
                    child: Icon(
                      Icons.check_circle,
                      size: 60,
                      color: Colors.green,
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    '¡Tu cita ha sido\nagendada exitosamente!',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                ],
              ),
            ),
            // Contenido del resumen
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Sección de Servicio
                  _SectionTitle('Servicio'),
                  _DetailCard(
                    icon: Icons.medical_services,
                    label: 'Servicio',
                    value: appointment.serviceName.isNotEmpty
                        ? appointment.serviceName
                        : 'No disponible',
                  ),
                  const SizedBox(height: 16),

                  // Sección de Mascota
                  _SectionTitle('Mascota'),
                  _DetailCard(
                    icon: Icons.pets,
                    label: 'Nombre',
                    value: appointment.petName.isNotEmpty
                        ? appointment.petName
                        : 'No disponible',
                  ),
                  _DetailCard(
                    icon: Icons.category,
                    label: 'Especie',
                    value: appointment.petSpecies.isNotEmpty
                        ? appointment.petSpecies
                        : 'No disponible',
                  ),
                  const SizedBox(height: 16),

                  // Sección de Profesional
                  _SectionTitle('Profesional'),
                  _DetailCard(
                    icon: Icons.person,
                    label: 'Profesional',
                    value: appointment.professionalName.isNotEmpty
                        ? appointment.professionalName
                        : 'No disponible',
                  ),
                  const SizedBox(height: 16),

                  // Sección de Fecha y Hora
                  _SectionTitle('Fecha y Hora'),
                  _DetailCard(
                    icon: Icons.calendar_today,
                    label: 'Fecha',
                    value: appointmentDate,
                  ),
                  _DetailCard(
                    icon: Icons.schedule,
                    label: 'Hora',
                    value: appointmentTime,
                  ),
                  const SizedBox(height: 16),

                  // Sección de Estado
                  _SectionTitle('Estado'),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: _statusColor().withAlpha((0.1 * 255).toInt()),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: _statusColor().withAlpha((0.3 * 255).toInt()),
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(_statusIcon(), color: _statusColor()),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            appointment.status,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: _statusColor(),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Botones de acción
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        AppShell.selectTab(3);
                        Navigator.of(context).pushNamedAndRemoveUntil(
                          '/home',
                          (route) => false,
                        );
                      },
                      icon: const Icon(Icons.list),
                      label: const Text('Ver mis citas'),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        backgroundColor: Colors.blue,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: () {
                        Navigator.of(context).pushNamedAndRemoveUntil(
                          '/home',
                          (route) => false,
                        );
                      },
                      icon: const Icon(Icons.home),
                      label: const Text('Ir al inicio'),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        side: const BorderSide(color: Colors.blue),
                        foregroundColor: Colors.blue,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Widget para mostrar el título de una sección.
class _SectionTitle extends StatelessWidget {
  final String title;

  const _SectionTitle(this.title);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: Colors.grey,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}

/// Widget para mostrar un detalle con ícono, etiqueta y valor.
class _DetailCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _DetailCard({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          Icon(icon, color: Colors.blue, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.grey,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Extensión para capitalizar la primera letra de una cadena.
extension StringCapitalization on String {
  String capitalize() {
    if (isEmpty) return this;
    return this[0].toUpperCase() + substring(1);
  }
}
