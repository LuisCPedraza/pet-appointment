import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:pet_appointment/config/theme.dart';
import 'package:pet_appointment/models/appointment_model.dart';
import 'package:pet_appointment/screens/appointment_detail_screen.dart';
import 'package:pet_appointment/screens/appointment_history/appointment_history.dart';
import 'package:pet_appointment/screens/appointment_history/reschedule_appointment_screen.dart';
import 'package:pet_appointment/services/appointment_service.dart';
import 'package:pet_appointment/widgets/app_shell.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AppointmentHistoryScreen extends StatefulWidget {
  const AppointmentHistoryScreen({super.key});

  @override
  State<AppointmentHistoryScreen> createState() =>
      _AppointmentHistoryScreenState();
}

class _AppointmentHistoryScreenState extends State<AppointmentHistoryScreen> {
  final _service = AppointmentService();
  final List<String> _filters = [
    'Todas',
    'Pendientes',
    'Completadas',
    'Canceladas',
  ];
  String _selectedFilter = 'Todas';
  bool _isLoading = true;
  final bool _isSubmitting = false;
  String? _errorMessage;
  List<AppointmentModel> _appointments = [];
  RealtimeChannel? _appointmentsChannel;

  @override
  void initState() {
    super.initState();
    _loadAppointments();
    _appointmentsChannel = _service.subscribeToClientAppointments(
      onChanged: _loadAppointments,
    );
    AppShell.tabIndexNotifier.addListener(_onTabChanged);
  }

  void _onTabChanged() {
    if (AppShell.tabIndexNotifier.value == 3) {
      _loadAppointments();
    }
  }

  @override
  void dispose() {
    AppShell.tabIndexNotifier.removeListener(_onTabChanged);
    _appointmentsChannel?.unsubscribe();
    super.dispose();
  }

  Future<void> _loadAppointments() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    try {
      final appointments = await _service.fetchClientAppointments();
      setState(() {
        _appointments = appointments;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Error al cargar tus citas. Intenta de nuevo.';
      });
    } finally {
      setState(() => _isLoading = false);
    }
  }

  List<AppointmentModel> get _filteredAppointments {
    return _appointments.where((appointment) {
      if (_selectedFilter == 'Todas') return true;
      if (_selectedFilter == 'Pendientes') {
        return [
          'En espera',
          'Confirmada',
          'En progreso',
        ].contains(appointment.status);
      }
      if (_selectedFilter == 'Completadas') {
        return appointment.status == 'Atendida';
      }
      if (_selectedFilter == 'Canceladas') {
        return appointment.status == 'Cancelada';
      }
      return true;
    }).toList();
  }

  List<AppointmentModel> get _futureAppointments {
    final now = DateTime.now();
    final items = _filteredAppointments
        .where(
          (appointment) =>
              appointment.scheduledAt != null &&
              appointment.scheduledAt!.isAfter(now) &&
              appointment.status != 'Cancelada',
        )
        .toList();
    items.sort((a, b) => a.scheduledAt!.compareTo(b.scheduledAt!));
    return items;
  }

  List<AppointmentModel> get _pastAppointments {
    final now = DateTime.now();
    final items = _filteredAppointments
        .where(
          (appointment) =>
              appointment.status == 'Cancelada' ||
              appointment.scheduledAt == null ||
              !appointment.scheduledAt!.isAfter(now),
        )
        .toList();
    items.sort((a, b) {
      final left = a.scheduledAt ?? DateTime.fromMillisecondsSinceEpoch(0);
      final right = b.scheduledAt ?? DateTime.fromMillisecondsSinceEpoch(0);
      return right.compareTo(left);
    });
    return items;
  }

  bool _isActiveAppointment(AppointmentModel appointment) {
    final now = DateTime.now();
    return appointment.scheduledAt != null &&
        appointment.scheduledAt!.isAfter(now) &&
        ['En espera', 'Confirmada'].contains(appointment.status);
  }

  Color _statusColor(String status) {
    return switch (status) {
      'En espera' => Colors.blue,
      'Confirmada' => Colors.green,
      'En progreso' => Colors.amber,
      'Atendida' => Colors.grey,
      'Cancelada' => Colors.red,
      _ => Colors.grey,
    };
  }

  IconData _statusIcon(String status) {
    return switch (status) {
      'En espera' => Icons.schedule,
      'Confirmada' => Icons.check_circle,
      'En progreso' => Icons.hourglass_top,
      'Atendida' => Icons.done_all,
      'Cancelada' => Icons.cancel,
      _ => Icons.info,
    };
  }

  String _formatAppointmentDate(AppointmentModel appointment) {
    if (appointment.scheduledAt == null) return 'Fecha no disponible';
    return DateFormat('EEEE, dd MMM yyyy · HH:mm', 'es_ES')
        .format(appointment.scheduledAt!)
        .replaceFirstMapped(
          RegExp(r'^[a-z]'),
          (m) => m.group(0)!.toUpperCase(),
        );
  }

  void _openAppointmentDetail(AppointmentModel appointment) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => AppointmentDetailScreen(appointment: appointment),
      ),
    );
  }

  void _openRescheduleAppointment(AppointmentModel appointment) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) =>
            RescheduleAppointmentScreen(appointment: appointment),
      ),
    ).then((result) {
      if (result == true) {
        _loadAppointments();
      }
    });
  }

  void _openCancelAppointmentDialog(AppointmentModel appointment) {
    final reasonController = TextEditingController();
    final now = DateTime.now().toUtc();
    final scheduled = appointment.scheduledAt?.toUtc();
    final withinTwoHours =
        scheduled != null && scheduled.difference(now).inMinutes <= 120;

    showDialog<bool>(
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
    ).then((confirmed) async {
      if (confirmed != true) {
        reasonController.dispose();
        return;
      }

      try {
        await _service.cancelClientAppointment(
          appointmentId: appointment.id,
          reason: reasonController.text.trim().isEmpty
              ? null
              : reasonController.text.trim(),
        );

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Cita cancelada correctamente'),
              backgroundColor: Colors.green,
            ),
          );
          _loadAppointments();
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error al cancelar la cita: ${e.toString()}'),
              backgroundColor: Colors.red,
            ),
          );
        }
      } finally {
        reasonController.dispose();
      }
    });
  }

  bool _canCancelAppointment(AppointmentModel appointment) {
    return ['En espera', 'Confirmada'].contains(appointment.status);
  }

  Future<void> _showAppointmentActions(AppointmentModel appointment) async {
    await showModalBottomSheet<void>(
      context: context,
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.info_outline),
                title: const Text('Ver detalle'),
                onTap: () {
                  Navigator.of(context).pop();
                  _openAppointmentDetail(appointment);
                },
              ),
              if (_isActiveAppointment(appointment))
                ListTile(
                  leading: const Icon(Icons.edit_calendar),
                  title: const Text('Reprogramar'),
                  onTap: () {
                    Navigator.of(context).pop();
                    _openRescheduleAppointment(appointment);
                  },
                ),
              if (_canCancelAppointment(appointment))
                ListTile(
                  leading: const Icon(Icons.cancel),
                  title: const Text('Cancelar cita'),
                  textColor: Colors.red,
                  iconColor: Colors.red,
                  onTap: () {
                    Navigator.of(context).pop();
                    _openCancelAppointmentDialog(appointment);
                  },
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildFilterChips() {
    return Wrap(
      spacing: 8,
      children: _filters.map((filter) {
        final selected = filter == _selectedFilter;
        return ChoiceChip(
          label: Text(filter),
          selected: selected,
          selectedColor: AppColors.primary,
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          labelStyle: TextStyle(
            color: selected ? Colors.white : AppColors.onSurface,
          ),
          onSelected: (_) {
            setState(() {
              _selectedFilter = filter;
            });
          },
        );
      }).toList(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Mis citas'), centerTitle: true),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _errorMessage != null
                ? Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          _errorMessage!,
                          textAlign: TextAlign.center,
                          style: const TextStyle(fontSize: 16),
                        ),
                        const SizedBox(height: 16),
                        FilledButton(
                          onPressed: _loadAppointments,
                          child: const Text('Reintentar'),
                        ),
                      ],
                    ),
                  )
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildFilterChips(),
                      const SizedBox(height: 20),
                      if (_appointments.isEmpty)
                        const AppointmentHistoryEmptyState()
                      else if (_filteredAppointments.isEmpty)
                        const AppointmentHistoryFilterEmptyState()
                      else ...[
                        if (_futureAppointments.isNotEmpty) ...[
                          const Text(
                            'Próximas citas',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 10),
                          ..._futureAppointments.map(
                            (appointment) => AppointmentHistoryCard(
                              appointment: appointment,
                              statusColor: _statusColor,
                              statusIcon: _statusIcon,
                              formatAppointmentDate: _formatAppointmentDate,
                              isActiveAppointment: _isActiveAppointment,
                              onOpenAppointmentDetail: _openAppointmentDetail,
                              onShowAppointmentActions: _showAppointmentActions,
                            ),
                          ),
                        ],
                        if (_pastAppointments.isNotEmpty) ...[
                          const SizedBox(height: 16),
                          const Text(
                            'Historial',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 10),
                          ..._pastAppointments.map(
                            (appointment) => AppointmentHistoryCard(
                              appointment: appointment,
                              statusColor: _statusColor,
                              statusIcon: _statusIcon,
                              formatAppointmentDate: _formatAppointmentDate,
                              isActiveAppointment: _isActiveAppointment,
                              onOpenAppointmentDetail: _openAppointmentDetail,
                              onShowAppointmentActions: _showAppointmentActions,
                            ),
                          ),
                        ],
                      ],
                    ],
                  ),
          ),
        ),
      ),
      floatingActionButton: _isSubmitting
          ? const FloatingActionButton.small(
              onPressed: null,
              child: CircularProgressIndicator.adaptive(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            )
          : null,
    );
  }
}
