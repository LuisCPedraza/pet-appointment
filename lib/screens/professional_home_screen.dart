import 'package:flutter/material.dart';
import '../models/appointment.dart';
import '../services/appointment_service.dart';
import '../widgets/appointment_tile.dart';

class ProfessionalHomeScreen extends StatefulWidget {
  const ProfessionalHomeScreen({Key? key}) : super(key: key);

  @override
  State<ProfessionalHomeScreen> createState() => _ProfessionalHomeScreenState();
}

class _ProfessionalHomeScreenState extends State<ProfessionalHomeScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final AppointmentService _service = AppointmentService();
  late DateTime _today;

  @override
  void initState() {
    super.initState();
    _today = DateTime.now();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Widget _dailyView() {
    return FutureBuilder<List<Appointment>>(
      future: _service.fetchDailyAppointments(_today),
      builder: (context, snap) {
        if (snap.connectionState == ConnectionState.waiting)
          return Center(child: CircularProgressIndicator());
        final list = snap.data ?? [];
        if (list.isEmpty) return Center(child: Text('No hay citas para hoy'));
        list.sort((a, b) => a.startsAt.compareTo(b.startsAt));
        return ListView.builder(
          padding: EdgeInsets.all(8),
          itemCount: list.length,
          itemBuilder: (c, i) {
            final ap = list[i];
            return AppointmentTile(
              appointment: ap,
              onTap: () => showDialog(
                context: context,
                builder: (_) => AlertDialog(
                  title: Text('Detalle de cita'),
                  content: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Cliente: ${ap.clientName}'),
                      Text('Mascota: ${ap.petName}'),
                      Text('Servicio: ${ap.serviceName}'),
                      Text(
                        'Hora: ${TimeOfDay.fromDateTime(ap.startsAt).format(context)}',
                      ),
                      Text('Estado: ${ap.status}'),
                    ],
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text('Cerrar'),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _weeklyView() {
    return FutureBuilder<Map<String, int>>(
      future: _service.fetchWeeklySummary(_today),
      builder: (context, snap) {
        if (snap.connectionState == ConnectionState.waiting)
          return Center(child: CircularProgressIndicator());
        final map = snap.data ?? {};
        final days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
        return Padding(
          padding: EdgeInsets.all(12),
          child: GridView.count(
            crossAxisCount: 2,
            childAspectRatio: 3,
            children: days.map((d) {
              final count = map[d] ?? 0;
              return Card(
                child: ListTile(
                  title: Text(d),
                  trailing: CircleAvatar(child: Text('$count')),
                ),
              );
            }).toList(),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Panel Profesional'),
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(text: 'Diaria'),
            Tab(text: 'Semanal'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [_dailyView(), _weeklyView()],
      ),
    );
  }
}
