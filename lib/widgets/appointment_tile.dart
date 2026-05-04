import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:pet_appointment/models/appointment_model.dart';

/// Widget que representa una cita en forma de tarjeta.
/// Muestra: cliente, mascota, servicio, hora, estado.
/// Al pulsar, navega al detalle de la cita.
class AppointmentTile extends StatelessWidget {
  final AppointmentModel appointment;
  final VoidCallback? onTap;

  const AppointmentTile({
    super.key,
    required this.appointment,
    this.onTap,
  });

  /// Retorna el color de fondo según el estado de la cita.
  Color _statusColor(BuildContext context) {
    return switch (appointment.status) {
      'En espera' => Colors.blue.shade50,
      'Confirmada' => Colors.green.shade50,
      'En progreso' => Colors.amber.shade50,
      'Atendida' => Colors.grey.shade100,
      'Cancelada' => Colors.red.shade50,
      _ => Colors.grey.shade50,
    };
  }

  /// Retorna el color de borde según el estado.
  Color _statusBorderColor(BuildContext context) {
    return switch (appointment.status) {
      'En espera' => Colors.blue,
      'Confirmada' => Colors.green,
      'En progreso' => Colors.amber,
      'Atendida' => Colors.grey,
      'Cancelada' => Colors.red,
      _ => Colors.grey.shade300,
    };
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

  @override
  Widget build(BuildContext context) {
    final timeFormatter = DateFormat('HH:mm', 'es_ES');
    final time = appointment.scheduledAt != null
        ? timeFormatter.format(appointment.scheduledAt!)
        : '--:--';

    return Card(
      color: _statusColor(context),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: _statusBorderColor(context),
          width: 2,
        ),
      ),
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Fila superior: hora, estado, icono
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Hora
                  Text(
                    time,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  // Estado con icono
                  Chip(
                    label: Text(
                      appointment.status,
                      style: const TextStyle(fontSize: 12),
                    ),
                    avatar: Icon(
                      _statusIcon(),
                      size: 16,
                    ),
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                ],
              ),
              const SizedBox(height: 12),
              // Cliente
              Row(
                children: [
                  const Icon(Icons.person, size: 18),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      appointment.clientName.isNotEmpty
                          ? appointment.clientName
                          : 'Cliente desconocido',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              // Mascota
              Row(
                children: [
                  const Icon(Icons.pets, size: 18),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      '${appointment.petName} (${appointment.petSpecies})',
                      style: Theme.of(context).textTheme.bodyMedium,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              // Servicio
              Row(
                children: [
                  const Icon(Icons.medical_services, size: 18),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      appointment.serviceName.isNotEmpty
                          ? appointment.serviceName
                          : 'Servicio no especificado',
                      style: Theme.of(context).textTheme.bodyMedium,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
