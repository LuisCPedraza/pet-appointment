import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:pet_appointment/models/appointment_history_model.dart';
import 'package:pet_appointment/models/appointment_model.dart';
import 'package:pet_appointment/services/appointment_service.dart';
import 'package:pet_appointment/widgets/appointment_history_view.dart';
import 'package:pet_appointment/widgets/status_selector.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Pantalla que muestra los detalles completos de una cita.
/// Incluye información del cliente, la mascota, el servicio, el estado y el historial.
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
  List<AppointmentHistoryModel> _history = [];
  bool _historyLoading = false;
  bool _statusChanging = false;
  String? _errorMessage;
  RealtimeChannel? _historyChannel;

  @override
  void initState() {
    super.initState();
    _appointment = widget.appointment;
    _loadHistory();
    _subscribeToHistoryChanges();
  }

  @override
  void dispose() {
    _historyChannel?.unsubscribe();
    super.dispose();
  }

  /// Carga el historial de cambios de estado
  Future<void> _loadHistory() async {
    if (!mounted) return;
    setState(() => _historyLoading = true);
    
    try {
      final history =
          await _appointmentService.fetchAppointmentHistory(_appointment.id);
      if (mounted) {
        setState(() {
          _history = history;
          _errorMessage = null;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'Error al cargar el historial: $e';
        });
      }
    } finally {
      if (mounted) {
        setState(() => _historyLoading = false);
      }
    }
  }

  /// Se suscribe a cambios en el historial en tiempo real
  void _subscribeToHistoryChanges() {
    _historyChannel =
        _appointmentService.subscribeToAppointmentHistory(
          appointmentId: _appointment.id,
          onChanged: _loadHistory,
        );
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

        // Recargar historial
        await _loadHistory();
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'Error: ${e.toString()}';
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_errorMessage!),
            backgroundColor: Colors.red,
          ),
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
    return currentUserId == _appointment.professionalId &&
        !_statusChanging;
  }

  /// Verifica si el cliente autenticado puede cancelar esta cita
  bool get _canCancel {
    final currentUserId = Supabase.instance.client.auth.currentUser?.id;
    final isClient = currentUserId != null && currentUserId == _appointment.clientId;
    final allowedStatus = _appointment.status == 'En espera' || _appointment.status == 'Confirmada';
    return isClient && allowedStatus && !_statusChanging;
  }

  /// Maneja la cancelación por parte del cliente. Muestra diálogo con aviso
  /// si la cita está a menos de 2 horas y permite ingresar un motivo opcional.
  Future<void> _handleClientCancel() async {
    final now = DateTime.now().toUtc();
    final scheduled = _appointment.scheduledAt?.toUtc();
    final withinTwoHours = scheduled != null && scheduled.difference(now).inMinutes <= 120;

    final reasonController = TextEditingController();

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cancelar cita'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (withinTwoHours)
              Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: Text(
                  'Advertencia: la cita está a menos de 2 horas. Al cancelar podría aplicarse una penalización.',
                  style: TextStyle(color: Colors.orange.shade800),
                ),
              ),
            TextField(
              controller: reasonController,
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: 'Motivo (opcional)',
                border: OutlineInputBorder(),
              ),
            ),
          ],
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
      await _appointmentService.cancelClientAppointment(_appointment.id);

      if (mounted) {
        setState(() {
          _appointment = _appointment.copyWith(status: 'Cancelada');
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Cita cancelada correctamente'), backgroundColor: Colors.green),
        );

        await _loadHistory();
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'Error cancelando la cita: ${e.toString()}';
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(_errorMessage!), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _statusChanging = false);
    }
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
            // Header con estado
            Container(
              width: double.infinity,
              color: _statusColor().withAlpha((0.1 * 255).toInt()),
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: _statusColor().withAlpha((0.2 * 255).toInt()),
                    ),
                    child:
                        Icon(_statusIcon(), size: 40, color: _statusColor()),
                  ),
                  const SizedBox(height: 16),
                  Chip(
                    label: Text(
                      _appointment.status,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    backgroundColor: _statusColor(),
                  ),
                ],
              ),
            ),

            // Contenido principal
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Mensajes de error
                  if (_errorMessage != null)
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.red.withAlpha(26),
                        border: Border.all(color: Colors.red),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.error, color: Colors.red),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              _errorMessage!,
                              style: const TextStyle(color: Colors.red),
                            ),
                          ),
                        ],
                      ),
                    ),
                  if (_errorMessage != null)
                    const SizedBox(height: 16),

                  // Selector de estado (solo si es el profesional asignado)
                  if (_canChangeStatus) ...[
                    _SectionTitle('Gestionar Estado'),
                    StatusSelector(
                      currentStatus: _appointment.status,
                      onStatusChanged: _handleStatusChange,
                      enabled: !_statusChanging,
                    ),
                    const SizedBox(height: 24),
                  ],

                  // Sección de fecha y hora
                  _SectionTitle('Cita'),
                  _DetailRow(
                    icon: Icons.calendar_today,
                    label: 'Fecha y hora',
                    value: appointmentDate,
                  ),
                  const SizedBox(height: 20),

                  // Sección de cliente
                  _SectionTitle('Cliente'),
                  _DetailRow(
                    icon: Icons.person,
                    label: 'Nombre',
                    value: _appointment.clientName.isNotEmpty
                        ? _appointment.clientName
                        : 'No disponible',
                  ),
                  _DetailRow(
                    icon: Icons.email,
                    label: 'Email',
                    value: _appointment.clientEmail.isNotEmpty
                        ? _appointment.clientEmail
                        : 'No disponible',
                  ),
                  const SizedBox(height: 20),

                  // Sección de mascota
                  _SectionTitle('Mascota'),
                  _DetailRow(
                    icon: Icons.pets,
                    label: 'Nombre',
                    value: _appointment.petName.isNotEmpty
                        ? _appointment.petName
                        : 'No disponible',
                  ),
                  _DetailRow(
                    icon: Icons.category,
                    label: 'Especie',
                    value: _appointment.petSpecies.isNotEmpty
                        ? _appointment.petSpecies
                        : 'No disponible',
                  ),
                  const SizedBox(height: 20),

                  // Sección de servicio
                  _SectionTitle('Servicio'),
                  _DetailRow(
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
                    _SectionTitle('Notas'),
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

                  // Historial de cambios
                  const SizedBox(height: 24),
                  // Botón de cancelación para el cliente
                  if (_canCancel) ...[
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                        ),
                        icon: const Icon(Icons.cancel),
                        label: const Text('Cancelar cita'),
                        onPressed: _handleClientCancel,
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],

                  _SectionTitle('Historial de Cambios'),
                  const SizedBox(height: 12),
                  AppointmentHistoryView(
                    history: _history,
                    isLoading: _historyLoading,
                  ),
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

/// Widget para mostrar un título de sección.
class _SectionTitle extends StatelessWidget {
  final String text;

  const _SectionTitle(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: Theme.of(
        context,
      ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
    );
  }
}

/// Widget para mostrar una fila de detalles (icono, etiqueta, valor).
class _DetailRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _DetailRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Colors.grey.shade600),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: Theme.of(
                  context,
                ).textTheme.labelSmall?.copyWith(color: Colors.grey.shade600),
              ),
              Text(
                value,
                style: Theme.of(
                  context,
                ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w500),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
