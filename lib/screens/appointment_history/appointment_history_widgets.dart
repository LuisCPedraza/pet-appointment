import 'package:flutter/material.dart';
import 'package:pet_appointment/config/theme.dart';
import 'package:pet_appointment/models/appointment_model.dart';
import 'package:pet_appointment/widgets/app_shell.dart';

/// =============================================
/// lib/screens/appointment_history/appointment_history_widgets.dart
/// Descripción: Widgets de presentación usados por la pantalla de historial de citas.
/// Responsabilidad: Encapsular estados vacíos y tarjetas de cita sin mezclar la lógica de filtrado y suscripción.
/// =============================================

class AppointmentHistoryEmptyState extends StatelessWidget {
  const AppointmentHistoryEmptyState({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.calendar_month_outlined,
            size: 64,
            color: AppColors.primary.withValues(alpha: 0.7),
          ),
          const SizedBox(height: 20),
          const Text(
            'Aún no tienes citas registradas.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 12),
          const Text(
            'Agenda tu primera cita para empezar a cuidar a tu mascota.',
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          FilledButton(
            onPressed: () {
              AppShell.selectTab(2);
            },
            child: const Text('Agendar mi primera cita'),
          ),
        ],
      ),
    );
  }
}

class AppointmentHistoryLoadingState extends StatelessWidget {
  const AppointmentHistoryLoadingState({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 56, horizontal: 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(
              width: 44,
              height: 44,
              child: CircularProgressIndicator(strokeWidth: 3),
            ),
            const SizedBox(height: 18),
            Text(
              'Cargando tu historial',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 8),
            Text(
              'Estamos trayendo tus citas y su estado más reciente.',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColors.onSurfaceVariant),
            ),
          ],
        ),
      ),
    );
  }
}

class AppointmentHistoryErrorState extends StatelessWidget {
  const AppointmentHistoryErrorState({
    super.key,
    required this.message,
    required this.onRetry,
  });

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 56, horizontal: 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 88,
              height: 88,
              decoration: BoxDecoration(
                color: Colors.red.withValues(alpha: 0.08),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.cloud_off_outlined,
                size: 42,
                color: Colors.red,
              ),
            ),
            const SizedBox(height: 18),
            Text(
              'No pudimos cargar tus citas',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColors.onSurfaceVariant),
            ),
            const SizedBox(height: 18),
            FilledButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: const Text('Reintentar'),
            ),
          ],
        ),
      ),
    );
  }
}

class AppointmentHistoryFilterEmptyState extends StatelessWidget {
  const AppointmentHistoryFilterEmptyState({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.search_off_outlined,
            size: 64,
            color: AppColors.primary.withValues(alpha: 0.7),
          ),
          const SizedBox(height: 20),
          const Text(
            'No hay citas que cumplan con ese criterio.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 12),
          Text(
            'Prueba con otro filtro o revisa tus citas próximas y pasadas.',
            textAlign: TextAlign.center,
            style: TextStyle(color: AppColors.onSurfaceVariant),
          ),
        ],
      ),
    );
  }
}

class AppointmentHistoryCard extends StatelessWidget {
  const AppointmentHistoryCard({
    super.key,
    required this.appointment,
    required this.statusColor,
    required this.statusIcon,
    required this.formatAppointmentDate,
    required this.isActiveAppointment,
    required this.onOpenAppointmentDetail,
    required this.onShowAppointmentActions,
  });

  final AppointmentModel appointment;
  final Color Function(String status) statusColor;
  final IconData Function(String status) statusIcon;
  final String Function(AppointmentModel appointment) formatAppointmentDate;
  final bool Function(AppointmentModel appointment) isActiveAppointment;
  final void Function(AppointmentModel appointment) onOpenAppointmentDetail;
  final Future<void> Function(AppointmentModel appointment)
  onShowAppointmentActions;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 10),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () {
          if (isActiveAppointment(appointment)) {
            onShowAppointmentActions(appointment);
          } else {
            onOpenAppointmentDetail(appointment);
          }
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Text(
                      appointment.serviceName.isNotEmpty
                          ? appointment.serviceName
                          : 'Servicio no especificado',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Chip(
                    backgroundColor: statusColor(
                      appointment.status,
                    ).withAlpha(40),
                    label: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          statusIcon(appointment.status),
                          size: 16,
                          color: statusColor(appointment.status),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          appointment.status,
                          style: TextStyle(
                            color: statusColor(appointment.status),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                'Mascota: ${appointment.petName.isNotEmpty ? appointment.petName : 'No disponible'}',
                style: const TextStyle(fontSize: 14),
              ),
              const SizedBox(height: 6),
              Text(
                'Profesional: ${appointment.professionalName.isNotEmpty ? appointment.professionalName : 'No disponible'}',
                style: const TextStyle(fontSize: 14),
              ),
              const SizedBox(height: 6),
              Text(
                formatAppointmentDate(appointment),
                style: TextStyle(
                  fontSize: 14,
                  color: AppColors.onSurfaceVariant,
                ),
              ),
              if (isActiveAppointment(appointment))
                Padding(
                  padding: const EdgeInsets.only(top: 12),
                  child: Row(
                    children: const [
                      Icon(Icons.arrow_forward, size: 16),
                      SizedBox(width: 6),
                      Text(
                        'Toca para cancelar o reprogramar',
                        style: TextStyle(fontSize: 12),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
