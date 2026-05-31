import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:pet_appointment/controllers/professional_agenda_controller.dart';
import 'package:pet_appointment/models/appointment_model.dart';
import 'package:pet_appointment/widgets/appointment_tile.dart';

class ProfessionalHomeDailyView extends StatelessWidget {
  const ProfessionalHomeDailyView({
    super.key,
    required this.controller,
    required this.statusFilter,
    required this.onAppointmentTap,
    required this.onConfirmAppointment,
  });

  final ProfessionalAgendaController controller;
  final String statusFilter;
  final ValueChanged<AppointmentModel> onAppointmentTap;
  final Future<void> Function(AppointmentModel appointment)
  onConfirmAppointment;

  List<AppointmentModel> _filterAppointments(
    List<AppointmentModel> appointments,
  ) {
    return appointments.where((appointment) {
      return switch (statusFilter) {
        'Pendientes' => appointment.status == 'En espera',
        'Confirmadas' => appointment.status == 'Confirmada',
        _ => true,
      };
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final today = DateTime.now();
    final appointmentsToday = _filterAppointments(
      controller.appointmentsForDay(today),
    );

    final dateFormatter = DateFormat('EEEE, d \'de\' MMMM', 'es_ES');
    final formattedDate = dateFormatter.format(today);

    if (appointmentsToday.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.check_circle, size: 64, color: Colors.green.shade400),
            const SizedBox(height: 16),
            Text(
              statusFilter == 'Todas'
                  ? 'No hay citas hoy'
                  : 'No hay citas $statusFilter hoy',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(color: Colors.grey.shade600),
            ),
          ],
        ),
      );
    }

    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Text(
              statusFilter == 'Todas'
                  ? formattedDate
                  : '$formattedDate · $statusFilter',
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
          ),
        ),
        SliverList(
          delegate: SliverChildBuilderDelegate((context, index) {
            final appointment = appointmentsToday[index];
            return AppointmentTile(
              appointment: appointment,
              onTap: () => onAppointmentTap(appointment),
              onConfirm: () => onConfirmAppointment(appointment),
            );
          }, childCount: appointmentsToday.length),
        ),
      ],
    );
  }
}
