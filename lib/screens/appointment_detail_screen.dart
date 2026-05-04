import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:pet_appointment/models/appointment_model.dart';

/// Pantalla que muestra los detalles completos de una cita.
/// Incluye información del cliente, la mascota, el servicio y el estado.
class AppointmentDetailScreen extends StatelessWidget {
  final AppointmentModel appointment;

  const AppointmentDetailScreen({super.key, required this.appointment});

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
    final dateFormatter = DateFormat('dd/MM/yyyy HH:mm', 'es_ES');
    final appointmentDate = appointment.scheduledAt != null
        ? dateFormatter.format(appointment.scheduledAt!)
        : 'Fecha no disponible';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Detalle de la Cita'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Header con estado
            Container(
              width: double.infinity,
              color: _statusColor().withAlpha((0.1 * 255).toInt()),
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: _statusColor().withAlpha((0.2 * 255).toInt()),
                    ),
                    child: Icon(_statusIcon(), size: 40, color: _statusColor()),
                  ),
                  const SizedBox(height: 16),
                  Chip(
                    label: Text(
                      appointment.status,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    backgroundColor: _statusColor(),
                  ),
                ],
              ),
            ),
            // Contenido principal
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Sección de fecha y hora
                  _SectionTitle('Cita'),
                  _DetailRow(
                    icon: Icons.calendar_today,
                    label: 'Fecha y hora',
                    value: appointmentDate,
                  ),
                  const SizedBox(height: 20),
                  // Sección de cliente
                  _SectionTitle('Cliente'),
                  _DetailRow(
                    icon: Icons.person,
                    label: 'Nombre',
                    value: appointment.clientName.isNotEmpty
                        ? appointment.clientName
                        : 'No disponible',
                  ),
                  _DetailRow(
                    icon: Icons.email,
                    label: 'Email',
                    value: appointment.clientEmail.isNotEmpty
                        ? appointment.clientEmail
                        : 'No disponible',
                  ),
                  const SizedBox(height: 20),
                  // Sección de mascota
                  _SectionTitle('Mascota'),
                  _DetailRow(
                    icon: Icons.pets,
                    label: 'Nombre',
                    value: appointment.petName.isNotEmpty
                        ? appointment.petName
                        : 'No disponible',
                  ),
                  _DetailRow(
                    icon: Icons.category,
                    label: 'Especie',
                    value: appointment.petSpecies.isNotEmpty
                        ? appointment.petSpecies
                        : 'No disponible',
                  ),
                  const SizedBox(height: 20),
                  // Sección de servicio
                  _SectionTitle('Servicio'),
                  _DetailRow(
                    icon: Icons.medical_services,
                    label: 'Tipo',
                    value: appointment.serviceName.isNotEmpty
                        ? appointment.serviceName
                        : 'No disponible',
                  ),
                  // Notas (si existen)
                  if (appointment.notes != null &&
                      appointment.notes!.isNotEmpty) ...[
                    const SizedBox(height: 20),
                    _SectionTitle('Notas'),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        appointment.notes!,
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Retorna el icono según el estado.
  IconData _statusIcon() {
    return switch (appointment.status) {
      'En espera' => Icons.schedule,
      'Confirmada' => Icons.check_circle,
      'En progreso' => Icons.hourglass_bottom,
      'Atendida' => Icons.done_all,
      'Cancelada' => Icons.cancel,
      _ => Icons.info,
    };
  }
}

/// Widget para mostrar un título de sección.
class _SectionTitle extends StatelessWidget {
  final String text;

  const _SectionTitle(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: Theme.of(
        context,
      ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
    );
  }
}

/// Widget para mostrar una fila de detalles (icono, etiqueta, valor).
class _DetailRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _DetailRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Colors.grey.shade600),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: Theme.of(
                  context,
                ).textTheme.labelSmall?.copyWith(color: Colors.grey.shade600),
              ),
              Text(
                value,
                style: Theme.of(
                  context,
                ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w500),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
