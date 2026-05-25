import 'dart:async';

import 'package:flutter/material.dart';
import 'package:pet_appointment/controllers/professional_agenda_controller.dart';
import 'package:pet_appointment/models/appointment_model.dart';
import 'package:pet_appointment/services/auth_service.dart';
import 'package:pet_appointment/utils/app_globals.dart';
import 'package:pet_appointment/features/appointments/appointment_detail_screen.dart';
import 'package:pet_appointment/screens/professional_home/professional_home.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

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
  ProfessionalAgendaController? _agendaController;
  StreamSubscription? _authSubscription;
  String _statusFilter = 'Todas';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _currentWeekStart = DateTime.now();
    _currentWeekStart = _currentWeekStart.subtract(
      Duration(days: _currentWeekStart.weekday - 1), // lunes
    );

    _authSubscription = Supabase.instance.client.auth.onAuthStateChange.listen((
      event,
    ) {
      if (!mounted) return;
      if (event.event == AuthChangeEvent.signedOut) {
        _agendaController?.unsubscribe();
        return;
      }

      if (event.event == AuthChangeEvent.initialSession ||
          event.event == AuthChangeEvent.signedIn ||
          event.event == AuthChangeEvent.tokenRefreshed) {
        final controller = _agendaController;
        if (controller != null && AuthService().hasValidSession) {
          controller.restartRealtime();
          unawaited(controller.loadAppointments());
        }
      }
    });

    // Cargar citas al inicializar
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final controller = context.read<ProfessionalAgendaController>();
      _agendaController = controller;
      controller.loadAppointments().then((_) {
        controller.subscribeRealtime();
      });
    });
  }

  @override
  void dispose() {
    _authSubscription?.cancel();
    _agendaController?.unsubscribe();
    _tabController.dispose();
    super.dispose();
  }

  void _openAppointmentDetail(AppointmentModel appointment) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => AppointmentDetailScreen(appointment: appointment),
      ),
    );
  }

  Future<void> _confirmAppointment(AppointmentModel appointment) async {
    final controller = context.read<ProfessionalAgendaController>();

    try {
      await controller.confirmAppointment(appointment.id);
      if (!mounted) return;
      appScaffoldMessengerKey.currentState?.showSnackBar(
        const SnackBar(content: Text('Cita confirmada')),
      );
    } catch (e) {
      if (!mounted) return;
      appScaffoldMessengerKey.currentState?.showSnackBar(
        SnackBar(content: Text('Error: ${e.toString()}')),
      );
    }
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
          final todayAppointments = controller.appointmentsForDay(
            DateTime.now(),
          );
          final pendingAppointments = controller.appointments
              .where((appointment) => appointment.status == 'En espera')
              .length;
          final confirmedAppointments = controller.appointments
              .where((appointment) => appointment.status == 'Confirmada')
              .length;
          final upcomingCount = controller.appointments.length;

          Widget body;

          if (controller.isLoading) {
            body = const Center(child: CircularProgressIndicator());
          } else if (controller.appointments.isEmpty) {
            body = const ProfessionalHomeEmptyState();
          } else {
            body = TabBarView(
              controller: _tabController,
              children: [
                ProfessionalHomeDailyView(
                  controller: controller,
                  statusFilter: _statusFilter,
                  onAppointmentTap: _openAppointmentDetail,
                  onConfirmAppointment: _confirmAppointment,
                ),
                ProfessionalHomeWeeklyView(
                  controller: controller,
                  weekStart: _currentWeekStart,
                  statusFilter: _statusFilter,
                  onAppointmentTap: _openAppointmentDetail,
                  onConfirmAppointment: _confirmAppointment,
                ),
              ],
            );
          }

          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                child: _AgendaOverviewCard(
                  totalAppointments: upcomingCount,
                  todayAppointments: todayAppointments.length,
                  pendingAppointments: pendingAppointments,
                  confirmedAppointments: confirmedAppointments,
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                child: Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: ['Todas', 'Pendientes', 'Confirmadas'].map((label) {
                    final selected = _statusFilter == label;
                    return ChoiceChip(
                      label: Text(label),
                      selected: selected,
                      selectedColor: Colors.blue,
                      labelStyle: TextStyle(
                        color: selected ? Colors.white : Colors.black87,
                        fontWeight: FontWeight.w600,
                      ),
                      onSelected: (_) {
                        setState(() => _statusFilter = label);
                      },
                    );
                  }).toList(),
                ),
              ),
              Expanded(child: body),
            ],
          );
        },
      ),
    );
  }
}

class _AgendaOverviewCard extends StatelessWidget {
  const _AgendaOverviewCard({
    required this.totalAppointments,
    required this.todayAppointments,
    required this.pendingAppointments,
    required this.confirmedAppointments,
  });

  final int totalAppointments;
  final int todayAppointments;
  final int pendingAppointments;
  final int confirmedAppointments;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      color: Colors.blue.shade50,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              width: 54,
              height: 54,
              decoration: BoxDecoration(
                color: Colors.blue.shade100,
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Icon(Icons.event_available, color: Colors.blue),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Agenda profesional',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    totalAppointments == 0
                        ? 'Sin citas todavía, pero la disponibilidad ya está lista para la demo.'
                        : 'Tienes $totalAppointments citas cargadas, con $todayAppointments para hoy.',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.blueGrey.shade700,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      _MetricPill(
                        icon: Icons.today,
                        label: 'Hoy',
                        value: '$todayAppointments',
                      ),
                      _MetricPill(
                        icon: Icons.calendar_month,
                        label: 'Total',
                        value: '$totalAppointments',
                      ),
                      _MetricPill(
                        icon: Icons.schedule,
                        label: 'Pendientes',
                        value: '$pendingAppointments',
                      ),
                      _MetricPill(
                        icon: Icons.check_circle,
                        label: 'Confirmadas',
                        value: '$confirmedAppointments',
                      ),
                    ],
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

class _MetricPill extends StatelessWidget {
  const _MetricPill({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: Colors.blue.shade100),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: Colors.blue.shade700),
          const SizedBox(width: 6),
          Text(
            '$label: ',
            style: Theme.of(
              context,
            ).textTheme.labelMedium?.copyWith(color: Colors.blueGrey.shade700),
          ),
          Text(
            value,
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
              fontWeight: FontWeight.w700,
              color: Colors.blue.shade800,
            ),
          ),
        ],
      ),
    );
  }
}
