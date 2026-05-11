import 'package:flutter/material.dart';
import 'package:pet_appointment/models/appointment_history_model.dart';
import 'package:intl/intl.dart';

/// Widget que muestra el historial de cambios de estado de una cita.
class AppointmentHistoryView extends StatelessWidget {
  const AppointmentHistoryView({
    super.key,
    required this.history,
    this.isLoading = false,
  });

  /// Lista de cambios de estado (ordenados más reciente primero)
  final List<AppointmentHistoryModel> history;

  /// Si está cargando el historial
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (history.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.history, size: 48, color: Colors.grey[400]),
              const SizedBox(height: 16),
              Text(
                'Sin historial de cambios',
                style: TextStyle(fontSize: 16, color: Colors.grey[600]),
              ),
            ],
          ),
        ),
      );
    }

    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: history.length,
      separatorBuilder: (context, index) =>
          Divider(height: 1, color: Colors.grey[200]),
      itemBuilder: (context, index) {
        final record = history[index];
        return _HistoryItem(record: record);
      },
    );
  }
}

/// Elemento individual del historial
class _HistoryItem extends StatelessWidget {
  const _HistoryItem({required this.record});

  final AppointmentHistoryModel record;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Icono de transición
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: _getTransitionColor(record.newStatus).withAlpha(26),
              shape: BoxShape.circle,
            ),
            child: Icon(
              _getTransitionIcon(record.newStatus),
              color: _getTransitionColor(record.newStatus),
              size: 20,
            ),
          ),
          const SizedBox(width: 12),

          // Contenido del cambio
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Transición de estado
                RichText(
                  text: TextSpan(
                    children: [
                      if (record.previousStatus != null)
                        TextSpan(
                          text: record.previousStatus,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      if (record.previousStatus != null)
                        const TextSpan(
                          text: ' → ',
                          style: TextStyle(fontSize: 14, color: Colors.grey),
                        ),
                      TextSpan(
                        text: record.newStatus,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: _getTransitionColor(record.newStatus),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 4),

                // Información del cambio
                Row(
                  children: [
                    Icon(
                      Icons.person_outline,
                      size: 12,
                      color: Colors.grey[500],
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        record.changedByName ?? 'Usuario desconocido',
                        style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Icon(Icons.schedule, size: 12, color: Colors.grey[500]),
                    const SizedBox(width: 4),
                    Text(
                      _formatDateTime(record.changedAt),
                      style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                    ),
                  ],
                ),
                if (record.changeReason != null &&
                    record.changeReason!.trim().isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    'Motivo: ${record.changeReason!}',
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Retorna el color basado en el nuevo estado
  Color _getTransitionColor(String status) {
    switch (status) {
      case 'En espera':
        return Colors.orange;
      case 'Confirmada':
        return Colors.blue;
      case 'En progreso':
        return Colors.purple;
      case 'Atendida':
        return Colors.green;
      case 'Cancelada':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  /// Retorna el icono de la transición
  IconData _getTransitionIcon(String status) {
    switch (status) {
      case 'En espera':
        return Icons.schedule;
      case 'Confirmada':
        return Icons.check_circle_outline;
      case 'En progreso':
        return Icons.hourglass_bottom;
      case 'Atendida':
        return Icons.task_alt;
      case 'Cancelada':
        return Icons.cancel;
      default:
        return Icons.info_outline;
    }
  }

  /// Formatea la fecha/hora de manera legible
  String _formatDateTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inMinutes < 1) {
      return 'Justo ahora';
    } else if (difference.inMinutes < 60) {
      return 'hace ${difference.inMinutes}m';
    } else if (difference.inHours < 24) {
      return 'hace ${difference.inHours}h';
    } else if (difference.inDays < 7) {
      return 'hace ${difference.inDays}d';
    } else {
      return DateFormat('d/M/y H:mm').format(dateTime);
    }
  }
}
