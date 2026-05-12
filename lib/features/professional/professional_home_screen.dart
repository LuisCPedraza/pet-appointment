import 'package:flutter/material.dart';
import 'package:pet_appointment/controllers/professional_agenda_controller.dart';
import 'package:pet_appointment/models/appointment_model.dart';
import 'package:pet_appointment/features/appointments/appointment_detail_screen.dart';
import 'package:pet_appointment/screens/professional_home/professional_home.dart';
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
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Cita confirmada')));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: ${e.toString()}')));
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
          if (controller.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (controller.appointments.isEmpty) {
            return const ProfessionalHomeEmptyState();
          }

          return TabBarView(
            controller: _tabController,
            children: [
              ProfessionalHomeDailyView(
                controller: controller,
                onAppointmentTap: _openAppointmentDetail,
                onConfirmAppointment: _confirmAppointment,
              ),
              ProfessionalHomeWeeklyView(
                controller: controller,
                weekStart: _currentWeekStart,
                onAppointmentTap: _openAppointmentDetail,
                onConfirmAppointment: _confirmAppointment,
              ),
            ],
          );
        },
      ),
    );
  }
}
