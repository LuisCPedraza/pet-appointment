import 'package:flutter/material.dart';
import '../models/appointment.dart';

class AppointmentTile extends StatelessWidget {
  final Appointment appointment;
  final VoidCallback? onTap;

  const AppointmentTile({Key? key, required this.appointment, this.onTap}) : super(key: key);

  Color _statusColor(String s) {
    switch (s) {
      case 'cancelled':
        return Colors.red.shade300;
      case 'completed':
        return Colors.green.shade300;
      default:
        return Colors.blue.shade200;
    }
  }

  @override
  Widget build(BuildContext context) {
    final time = TimeOfDay.fromDateTime(appointment.startsAt).format(context);
    return Card(
      child: ListTile(
        onTap: onTap,
        leading: CircleAvatar(
          backgroundColor: _statusColor(appointment.status),
          child: Text(time.split(':').first),
        ),
        title: Text('${appointment.clientName} — ${appointment.petName}'),
        subtitle: Text('${appointment.serviceName} • $time'),
        trailing: Icon(Icons.chevron_right),
      ),
    );
  }
}
