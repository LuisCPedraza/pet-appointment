import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:pet_appointment/controllers/professional_agenda_controller.dart';
import 'package:pet_appointment/models/appointment_model.dart';

class ProfessionalHomeWeeklyView extends StatefulWidget {
  const ProfessionalHomeWeeklyView({
    super.key,
    required this.controller,
    required this.weekStart,
    required this.onAppointmentTap,
    required this.onConfirmAppointment,
  });

  final ProfessionalAgendaController controller;
  final DateTime weekStart;
  final ValueChanged<AppointmentModel> onAppointmentTap;
  final Future<void> Function(AppointmentModel appointment)
  onConfirmAppointment;

  @override
  State<ProfessionalHomeWeeklyView> createState() =>
      _ProfessionalHomeWeeklyViewState();
}

class _ProfessionalHomeWeeklyViewState
    extends State<ProfessionalHomeWeeklyView> {
  late DateTime _weekStart;

  @override
  void initState() {
    super.initState();
    _weekStart = widget.weekStart;
  }

  void _nextWeek() {
    setState(() {
      _weekStart = _weekStart.add(const Duration(days: 7));
    });
  }

  void _previousWeek() {
    setState(() {
      _weekStart = _weekStart.subtract(const Duration(days: 7));
    });
  }

  void _goToCurrentWeek() {
    final now = DateTime.now();
    setState(() {
      _weekStart = now.subtract(Duration(days: now.weekday - 1));
    });
  }

  @override
  Widget build(BuildContext context) {
    final dayFormatter = DateFormat('EEE', 'es_ES');
    final rangeFormatter = DateFormat('d \'de\' MMMM', 'es_ES');

    final weekEnd = _weekStart.add(const Duration(days: 6));
    final isCurrentWeek =
        DateTime.now().isBefore(weekEnd) &&
        DateTime.now().isAfter(_weekStart.subtract(const Duration(days: 1)));

    final appointmentsByDay = widget.controller.appointmentsForWeek(_weekStart);

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                icon: const Icon(Icons.chevron_left),
                onPressed: _previousWeek,
              ),
              Column(
                children: [
                  Text(
                    '${rangeFormatter.format(_weekStart)} - ${rangeFormatter.format(weekEnd)}',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  if (!isCurrentWeek)
                    TextButton(
                      onPressed: _goToCurrentWeek,
                      child: const Text('Ir a esta semana'),
                    ),
                ],
              ),
              IconButton(
                icon: const Icon(Icons.chevron_right),
                onPressed: _nextWeek,
              ),
            ],
          ),
        ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            itemCount: 7,
            itemBuilder: (context, dayIndex) {
              final day = _weekStart.add(Duration(days: dayIndex));
              final appointments = appointmentsByDay[dayIndex] ?? [];
              final isToday =
                  DateTime(day.year, day.month, day.day) ==
                  DateTime(
                    DateTime.now().year,
                    DateTime.now().month,
                    DateTime.now().day,
                  );

              return ProfessionalHomeDayCard(
                date: day,
                dayName: dayFormatter.format(day).toUpperCase(),
                appointments: appointments,
                isToday: isToday,
                onTapAppointment: widget.onAppointmentTap,
                onConfirmAppointment: widget.onConfirmAppointment,
              );
            },
          ),
        ),
      ],
    );
  }
}

class ProfessionalHomeDayCard extends StatelessWidget {
  const ProfessionalHomeDayCard({
    super.key,
    required this.date,
    required this.dayName,
    required this.appointments,
    required this.isToday,
    required this.onTapAppointment,
    required this.onConfirmAppointment,
  });

  final DateTime date;
  final String dayName;
  final List<AppointmentModel> appointments;
  final bool isToday;
  final ValueChanged<AppointmentModel> onTapAppointment;
  final Future<void> Function(AppointmentModel appointment)
  onConfirmAppointment;

  @override
  Widget build(BuildContext context) {
    final dateFormatter = DateFormat('d', 'es_ES');

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: isToday ? Colors.blue : Colors.transparent,
          width: 2,
        ),
      ),
      color: isToday ? Colors.blue.shade50 : Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 8),
              decoration: BoxDecoration(
                color: isToday ? Colors.blue : Colors.grey.shade100,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                children: [
                  Text(
                    dayName,
                    style: Theme.of(context).textTheme.labelLarge?.copyWith(
                      color: isToday ? Colors.white : Colors.black,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    dateFormatter.format(date),
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: isToday ? Colors.white : Colors.black,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            if (appointments.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 16),
                child: Center(
                  child: Text(
                    'Sin citas',
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: Colors.grey.shade500,
                    ),
                  ),
                ),
              )
            else
              SizedBox(
                height: appointments.length * 80.0,
                child: ListView.separated(
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: appointments.length,
                  separatorBuilder: (context, index) =>
                      const SizedBox(height: 8),
                  itemBuilder: (context, index) {
                    final appointment = appointments[index];
                    return ProfessionalHomeCompactAppointmentTile(
                      appointment: appointment,
                      onTap: () => onTapAppointment(appointment),
                      onConfirm: () => onConfirmAppointment(appointment),
                    );
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class ProfessionalHomeCompactAppointmentTile extends StatelessWidget {
  const ProfessionalHomeCompactAppointmentTile({
    super.key,
    required this.appointment,
    required this.onTap,
    this.onConfirm,
  });

  final AppointmentModel appointment;
  final VoidCallback onTap;
  final VoidCallback? onConfirm;

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
    final timeFormatter = DateFormat('HH:mm', 'es_ES');
    final time = appointment.scheduledAt != null
        ? timeFormatter.format(appointment.scheduledAt!)
        : '--:--';

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          border: Border(left: BorderSide(color: _statusColor(), width: 4)),
          borderRadius: BorderRadius.circular(8),
          color: Colors.grey.shade50,
        ),
        child: Row(
          children: [
            SizedBox(
              width: 50,
              child: Text(
                time,
                style: Theme.of(
                  context,
                ).textTheme.labelLarge?.copyWith(fontWeight: FontWeight.bold),
              ),
            ),
            Container(
              width: 1,
              height: 30,
              color: Colors.grey.shade300,
              margin: const EdgeInsets.symmetric(horizontal: 8),
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    appointment.clientName,
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    appointment.petName,
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: Colors.grey.shade600,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            if (appointment.status == 'En espera')
              IconButton(
                onPressed: onConfirm,
                icon: const Icon(Icons.check, color: Colors.blue),
                tooltip: 'Confirmar cita',
              ),
          ],
        ),
      ),
    );
  }
}
