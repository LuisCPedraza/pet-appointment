import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:pet_appointment/models/appointment_model.dart';
import 'package:pet_appointment/services/appointment_service.dart';
import 'package:pet_appointment/widgets/status_selector.dart';
import 'package:pet_appointment/screens/appointment_detail/appointment_detail.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Pantalla que muestra los detalles completos de una cita.
/// Incluye información del cliente, la mascota, el servicio y el estado.
/// El profesional asignado puede cambiar el estado de la cita.
class AppointmentDetailScreen extends StatefulWidget {
  final AppointmentModel appointment;

  const AppointmentDetailScreen({super.key, required this.appointment});

  @override
  State<AppointmentDetailScreen> createState() =>
      _AppointmentDetailScreenState();
}

class _AppointmentDetailScreenState extends State<AppointmentDetailScreen> {
  final _appointmentService = AppointmentService();

  late AppointmentModel _appointment;
  bool _statusChanging = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _appointment = widget.appointment;
  }

  @override
  void dispose() {
    super.dispose();
  }

  /// Maneja el cambio de estado
  Future<void> _handleStatusChange(String newStatus) async {
    // Mostrar confirmación
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar cambio de estado'),
        content: Text(
          'Cambiar estado de "${_appointment.status}" a "$newStatus"?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Confirmar'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    if (!mounted) return;
    setState(() {
      _statusChanging = true;
      _errorMessage = null;
    });

    try {
      await _appointmentService.updateAppointmentStatus(
        appointmentId: _appointment.id,
        newStatus: newStatus,
      );

      if (mounted) {
        setState(() {
          _appointment = _appointment.copyWith(status: newStatus);
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Estado actualizado a: $newStatus'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'Error: ${e.toString()}';
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(_errorMessage!), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _statusChanging = false);
      }
    }
  }

  /// Verifica si el usuario actual es el profesional asignado
  bool get _canChangeStatus {
    final currentUserId = Supabase.instance.client.auth.currentUser?.id;
    return currentUserId == _appointment.professionalId && !_statusChanging;
  }

  /// Retorna el color del badge del estado.
  Color _statusColor() {
    return switch (_appointment.status) {
      'En espera' => Colors.blue,
      'Confirmada' => Colors.green,
      'En progreso' => Colors.amber,
      'Atendida' => Colors.grey,
      'Cancelada' => Colors.red,
      _ => Colors.grey,
    };
  }

  /// Retorna el icono según el estado.
  IconData _statusIcon() {
    return switch (_appointment.status) {
      'En espera' => Icons.schedule,
      'Confirmada' => Icons.check_circle,
      'En progreso' => Icons.hourglass_bottom,
      'Atendida' => Icons.done_all,
      'Cancelada' => Icons.cancel,
      _ => Icons.info,
    };
  }

  @override
  Widget build(BuildContext context) {
    final dateFormatter = DateFormat('dd/MM/yyyy HH:mm', 'es_ES');
    final appointmentDate = _appointment.scheduledAt != null
        ? dateFormatter.format(_appointment.scheduledAt!)
        : 'Fecha no disponible';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Detalle de la Cita'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            AppointmentDetailStatusHeader(
              status: _appointment.status,
              statusColor: _statusColor(),
              statusIcon: _statusIcon(),
            ),

            // Contenido principal
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Mensajes de error
                  if (_errorMessage != null)
                    AppointmentDetailErrorBanner(message: _errorMessage!),
                  if (_errorMessage != null) const SizedBox(height: 16),

                  // Selector de estado (solo si es el profesional asignado)
                  if (_canChangeStatus) ...[
                    const AppointmentDetailSectionTitle('Gestionar Estado'),
                    StatusSelector(
                      currentStatus: _appointment.status,
                      onStatusChanged: _handleStatusChange,
                      enabled: !_statusChanging,
                    ),
                    const SizedBox(height: 24),
                  ],

                  // Sección de fecha y hora
                  const AppointmentDetailSectionTitle('Cita'),
                  AppointmentDetailRow(
                    icon: Icons.calendar_today,
                    label: 'Fecha y hora',
                    value: appointmentDate,
                  ),
                  const SizedBox(height: 20),

                  // Sección de cliente
                  const AppointmentDetailSectionTitle('Cliente'),
                  AppointmentDetailRow(
                    icon: Icons.person,
                    label: 'Nombre',
                    value: _appointment.clientName.isNotEmpty
                        ? _appointment.clientName
                        : 'No disponible',
                  ),
                  AppointmentDetailRow(
                    icon: Icons.email,
                    label: 'Email',
                    value: _appointment.clientEmail.isNotEmpty
                        ? _appointment.clientEmail
                        : 'No disponible',
                  ),
                  const SizedBox(height: 20),

                  // Sección de mascota
                  const AppointmentDetailSectionTitle('Mascota'),
                  AppointmentDetailRow(
                    icon: Icons.pets,
                    label: 'Nombre',
                    value: _appointment.petName.isNotEmpty
                        ? _appointment.petName
                        : 'No disponible',
                  ),
                  AppointmentDetailRow(
                    icon: Icons.category,
                    label: 'Especie',
                    value: _appointment.petSpecies.isNotEmpty
                        ? _appointment.petSpecies
                        : 'No disponible',
                  ),
                  const SizedBox(height: 20),

                  // Sección de profesional
                  const AppointmentDetailSectionTitle('Profesional'),
                  AppointmentDetailRow(
                    icon: Icons.person_search,
                    label: 'Nombre',
                    value: _appointment.professionalName.isNotEmpty
                        ? _appointment.professionalName
                        : 'No disponible',
                  ),
                  const SizedBox(height: 20),

                  // Sección de servicio
                  const AppointmentDetailSectionTitle('Servicio'),
                  AppointmentDetailRow(
                    icon: Icons.medical_services,
                    label: 'Tipo',
                    value: _appointment.serviceName.isNotEmpty
                        ? _appointment.serviceName
                        : 'No disponible',
                  ),

                  // Notas (si existen)
                  if (_appointment.notes != null &&
                      _appointment.notes!.isNotEmpty) ...[
                    const SizedBox(height: 20),
                    const AppointmentDetailSectionTitle('Notas'),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        _appointment.notes!,
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ),
                  ],
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
