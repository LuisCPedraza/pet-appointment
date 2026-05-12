import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:pet_appointment/config/theme.dart';
import 'package:pet_appointment/models/appointment_model.dart';
import 'package:pet_appointment/screens/appointment_detail_screen.dart';
import 'package:pet_appointment/services/appointment_service.dart';
import 'package:pet_appointment/widgets/app_shell.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AppointmentHistoryScreen extends StatefulWidget {
  const AppointmentHistoryScreen({super.key});

  @override
  State<AppointmentHistoryScreen> createState() => _AppointmentHistoryScreenState();
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
        .where((appointment) =>
            appointment.scheduledAt != null &&
            appointment.scheduledAt!.isAfter(now) &&
            appointment.status != 'Cancelada')
        .toList();
    items.sort((a, b) => a.scheduledAt!.compareTo(b.scheduledAt!));
    return items;
  }

  List<AppointmentModel> get _pastAppointments {
    final now = DateTime.now();
    final items = _filteredAppointments
        .where((appointment) =>
            appointment.scheduledAt == null ||
            !appointment.scheduledAt!.isAfter(now))
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
        .replaceFirstMapped(RegExp(r'^[a-z]'), (m) => m.group(0)!.toUpperCase());
  }

  void _openAppointmentDetail(AppointmentModel appointment) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => AppointmentDetailScreen(appointment: appointment),
      ),
    );
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

  Widget _buildAppointmentCard(AppointmentModel appointment) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 10),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () {
          if (_isActiveAppointment(appointment)) {
            _showAppointmentActions(appointment);
          } else {
            _openAppointmentDetail(appointment);
          }
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Text(
                      appointment.serviceName.isNotEmpty
                          ? appointment.serviceName
                          : 'Servicio no especificado',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Chip(
                    backgroundColor:
                        _statusColor(appointment.status).withAlpha(40),
                    label: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          _statusIcon(appointment.status),
                          size: 16,
                          color: _statusColor(appointment.status),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          appointment.status,
                          style: TextStyle(
                            color: _statusColor(appointment.status),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                'Mascota: ${appointment.petName.isNotEmpty ? appointment.petName : 'No disponible'}',
                style: const TextStyle(fontSize: 14),
              ),
              const SizedBox(height: 6),
              Text(
                'Profesional: ${appointment.professionalId.isNotEmpty ? appointment.professionalId : 'No disponible'}',
                style: const TextStyle(fontSize: 14),
              ),
              const SizedBox(height: 6),
              Text(
                _formatAppointmentDate(appointment),
                style: TextStyle(
                  fontSize: 14,
                  color: AppColors.onSurfaceVariant,
                ),
              ),
              if (_isActiveAppointment(appointment))
                Padding(
                  padding: const EdgeInsets.only(top: 12),
                  child: Row(
                    children: const [
                      Icon(Icons.arrow_forward, size: 16),
                      SizedBox(width: 6),
                      Text(
                        'Toca para cancelar o reprogramar',
                        style: TextStyle(fontSize: 12),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mis citas'),
        centerTitle: true,
      ),
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
                            _buildEmptyState()
                          else if (_filteredAppointments.isEmpty)
                            _buildFilterEmptyState()
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
                              ..._futureAppointments.map(_buildAppointmentCard),
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
                              ..._pastAppointments.map(_buildAppointmentCard),
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

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.calendar_month_outlined,
            size: 64,
            color: AppColors.primary.withValues(alpha: 0.7),
          ),
          const SizedBox(height: 20),
          const Text(
            'Aún no tienes citas registradas.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 12),
          const Text(
            'Agenda tu primera cita para empezar a cuidar a tu mascota.',
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          FilledButton(
            onPressed: () {
              AppShell.selectTab(2);
            },
            child: const Text('Agendar mi primera cita'),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterEmptyState() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.search_off_outlined,
            size: 64,
            color: AppColors.primary.withValues(alpha: 0.7),
          ),
          const SizedBox(height: 20),
          const Text(
            'No hay citas que cumplan con ese criterio.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 12),
          Text(
            'Prueba con otro filtro o revisa tus citas próximas y pasadas.',
            textAlign: TextAlign.center,
            style: TextStyle(color: AppColors.onSurfaceVariant),
          ),
        ],
      ),
    );
  }
}
