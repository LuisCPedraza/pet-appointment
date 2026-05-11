import 'package:flutter/material.dart';
import 'package:pet_appointment/models/appointment_status.dart';

/// Widget que permite seleccionar el siguiente estado de una cita.
/// Solo muestra las transiciones válidas desde el estado actual.
class StatusSelector extends StatefulWidget {
  const StatusSelector({
    super.key,
    required this.currentStatus,
    required this.onStatusChanged,
    this.enabled = true,
  });

  /// Estado actual de la cita
  final String currentStatus;

  /// Callback cuando se selecciona un nuevo estado
  final void Function(String newStatus) onStatusChanged;

  /// Si es false, el selector se deshabilita
  final bool enabled;

  @override
  State<StatusSelector> createState() => _StatusSelectorState();
}

class _StatusSelectorState extends State<StatusSelector> {
  @override
  Widget build(BuildContext context) {
    final currentStatusEnum = AppointmentStatus.fromString(
      widget.currentStatus,
    );
    if (currentStatusEnum == null) {
      return const SizedBox.shrink();
    }

    final validNextStates = currentStatusEnum.getValidNextStates();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Estado actual
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: _getStatusColor(currentStatusEnum).withAlpha(26),
            border: Border.all(
              color: _getStatusColor(currentStatusEnum),
              width: 2,
            ),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              Icon(
                _getStatusIcon(currentStatusEnum),
                color: _getStatusColor(currentStatusEnum),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Estado actual',
                    style: TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                  Text(
                    widget.currentStatus,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: _getStatusColor(currentStatusEnum),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // Selector de siguiente estado
        if (validNextStates.isNotEmpty)
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Cambiar a:',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              SizedBox(
                width: double.infinity,
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: validNextStates.map((status) {
                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: ElevatedButton.icon(
                          onPressed: widget.enabled
                              ? () {
                                  widget.onStatusChanged(status.label);
                                }
                              : null,
                          icon: Icon(_getStatusIcon(status)),
                          label: Text(status.label),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: _getStatusColor(status),
                            foregroundColor: Colors.white,
                            disabledBackgroundColor: Colors.grey[300],
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ),
            ],
          )
        else
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Row(
              children: [
                Icon(Icons.lock, color: Colors.grey, size: 18),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'No hay transiciones disponibles para este estado',
                    style: TextStyle(fontSize: 14, color: Colors.grey),
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }

  /// Retorna el color asociado a un estado
  Color _getStatusColor(AppointmentStatus status) {
    switch (status) {
      case AppointmentStatus.enEspera:
        return Colors.orange;
      case AppointmentStatus.confirmada:
        return Colors.blue;
      case AppointmentStatus.enProgreso:
        return Colors.purple;
      case AppointmentStatus.atendida:
        return Colors.green;
      case AppointmentStatus.cancelada:
        return Colors.red;
    }
  }

  /// Retorna el icono asociado a un estado
  IconData _getStatusIcon(AppointmentStatus status) {
    switch (status) {
      case AppointmentStatus.enEspera:
        return Icons.schedule;
      case AppointmentStatus.confirmada:
        return Icons.check_circle_outline;
      case AppointmentStatus.enProgreso:
        return Icons.hourglass_bottom;
      case AppointmentStatus.atendida:
        return Icons.task_alt;
      case AppointmentStatus.cancelada:
        return Icons.cancel;
    }
  }
}
