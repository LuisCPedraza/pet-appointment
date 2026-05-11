import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:pet_appointment/controllers/professional_agenda_controller.dart';
import 'package:pet_appointment/screens/appointment_detail_screen.dart';
import 'package:pet_appointment/widgets/appointment_tile.dart';
import 'package:provider/provider.dart';

/// Pantalla principal del profesional que muestra su agenda con:
/// - Vista diaria: citas del día actual
/// - Vista semanal: citas agrupadas por día de la semana
/// - Actualización en tiempo real vía Realtime
class ProfessionalHomeScreen extends StatefulWidget {
  const ProfessionalHomeScreen({super.key});

  @override
  State<ProfessionalHomeScreen> createState() => _ProfessionalHomeScreenState();
}

class _ProfessionalHomeScreenState extends State<ProfessionalHomeScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late DateTime _currentWeekStart;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _currentWeekStart = DateTime.now();
    _currentWeekStart = _currentWeekStart.subtract(
      Duration(days: _currentWeekStart.weekday - 1), // lunes
    );

    // Cargar citas al inicializar
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final controller = context.read<ProfessionalAgendaController>();
      controller.loadAppointments().then((_) {
        controller.subscribeRealtime();
      });
    });
  }

  @override
  void dispose() {
    final controller = context.read<ProfessionalAgendaController>();
    controller.unsubscribe();
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mi Agenda'),
        centerTitle: true,
        actions: [
          IconButton(
            tooltip: 'Mi disponibilidad',
            icon: const Icon(Icons.schedule),
            onPressed: () {
              Navigator.of(context).pushNamed('/professional-availability');
            },
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Hoy', icon: Icon(Icons.calendar_today)),
            Tab(text: 'Semana', icon: Icon(Icons.date_range)),
          ],
        ),
      ),
      body: Consumer<ProfessionalAgendaController>(
        builder: (context, controller, _) {
          if (controller.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (controller.appointments.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.event_note, size: 64, color: Colors.grey.shade400),
                  const SizedBox(height: 16),
                  Text(
                    'No hay citas agendadas',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: Colors.grey.shade600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Las citas aparecerán aquí',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.grey.shade500,
                    ),
                  ),
                ],
              ),
            );
          }

          return TabBarView(
            controller: _tabController,
            children: [
              // Tab 1: Vista diaria (hoy)
              _DailyView(controller: controller),
              // Tab 2: Vista semanal
              _WeeklyView(controller: controller, weekStart: _currentWeekStart),
            ],
          );
        },
      ),
    );
  }
}

/// Vista diaria: muestra todas las citas de hoy ordenadas por hora.
class _DailyView extends StatelessWidget {
  final ProfessionalAgendaController controller;

  const _DailyView({required this.controller});

  @override
  Widget build(BuildContext context) {
    final today = DateTime.now();
    final appointmentsToday = controller.appointmentsForDay(today);

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
              'No hay citas hoy',
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
        // Header con la fecha
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Text(
              formattedDate,
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
          ),
        ),
        // Lista de citas
        SliverList(
          delegate: SliverChildBuilderDelegate((context, index) {
            final appointment = appointmentsToday[index];
            return AppointmentTile(
              appointment: appointment,
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) =>
                        AppointmentDetailScreen(appointment: appointment),
                  ),
                );
              },
              onConfirm: () async {
                try {
                  await controller.confirmAppointment(appointment.id);
                  if (!context.mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Cita confirmada')),
                  );
                } catch (e) {
                  if (!context.mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Error: ${e.toString()}')),
                  );
                }
              },
            );
          }, childCount: appointmentsToday.length),
        ),
      ],
    );
  }
}

/// Vista semanal: muestra citas agrupadas por cada día de la semana.
class _WeeklyView extends StatefulWidget {
  final ProfessionalAgendaController controller;
  final DateTime weekStart;

  const _WeeklyView({required this.controller, required this.weekStart});

  @override
  State<_WeeklyView> createState() => _WeeklyViewState();
}

class _WeeklyViewState extends State<_WeeklyView> {
  late DateTime _weekStart;

  @override
  void initState() {
    super.initState();
    _weekStart = widget.weekStart;
  }

  /// Avanza a la siguiente semana.
  void _nextWeek() {
    setState(() {
      _weekStart = _weekStart.add(const Duration(days: 7));
    });
  }

  /// Retrocede a la semana anterior.
  void _previousWeek() {
    setState(() {
      _weekStart = _weekStart.subtract(const Duration(days: 7));
    });
  }

  /// Vuelve a la semana actual.
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
        // Header con navegación de semanas
        Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Row(
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
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.bold),
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
            ],
          ),
        ),
        // Grid de días de la semana
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

              return _DayCard(
                date: day,
                dayName: dayFormatter.format(day).toUpperCase(),
                appointments: appointments,
                isToday: isToday,
                onTapAppointment: (appointment) {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) =>
                          AppointmentDetailScreen(appointment: appointment),
                    ),
                  );
                },
                onConfirmAppointment: (appointment) async {
                  try {
                    await widget.controller.confirmAppointment(appointment.id);
                    if (!context.mounted) return;
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Cita confirmada')),
                    );
                  } catch (e) {
                    if (!context.mounted) return;
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Error: ${e.toString()}')),
                    );
                  }
                },
              );
            },
          ),
        ),
      ],
    );
  }
}

/// Tarjeta de un día de la semana con sus citas.
class _DayCard extends StatelessWidget {
  final DateTime date;
  final String dayName;
  final List appointments;
  final bool isToday;
  final Function(dynamic) onTapAppointment;
  final Function(dynamic)? onConfirmAppointment;

  const _DayCard({
    required this.date,
    required this.dayName,
    required this.appointments,
    required this.isToday,
    required this.onTapAppointment,
    this.onConfirmAppointment,
  });

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
            // Encabezado del día
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
            // Lista de citas del día
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
                    return _CompactAppointmentTile(
                      appointment: appointments[index],
                      onTap: () => onTapAppointment(appointments[index]),
                      onConfirm: onConfirmAppointment == null
                          ? null
                          : () => onConfirmAppointment!(appointments[index]),
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

/// Versión compacta del AppointmentTile para la vista semanal.
class _CompactAppointmentTile extends StatelessWidget {
  final dynamic appointment;
  final VoidCallback onTap;
  final VoidCallback? onConfirm;

  const _CompactAppointmentTile({
    required this.appointment,
    required this.onTap,
    this.onConfirm,
  });

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
        ? timeFormatter.format(appointment.scheduledAt)
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
            // Hora
            SizedBox(
              width: 50,
              child: Text(
                time,
                style: Theme.of(
                  context,
                ).textTheme.labelLarge?.copyWith(fontWeight: FontWeight.bold),
              ),
            ),
            // Separador
            Container(
              width: 1,
              height: 30,
              color: Colors.grey.shade300,
              margin: const EdgeInsets.symmetric(horizontal: 8),
            ),
            // Cliente y mascota
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
            // Botón confirmar si aplica
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
