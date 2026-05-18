import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:pet_appointment/config/theme.dart';
import 'package:pet_appointment/models/appointment_model.dart';
import 'package:pet_appointment/services/appointment_service.dart';

class AdminReportsScreen extends StatefulWidget {
  const AdminReportsScreen({super.key});

  @override
  State<AdminReportsScreen> createState() => _AdminReportsScreenState();
}

class _AdminReportsScreenState extends State<AdminReportsScreen> {
  final _service = AppointmentService();

  bool _loading = true;
  String? _errorMessage;

  List<Map<String, String>> _professionals = [];
  List<Map<String, String>> _services = [];
  DateTimeRange? _dateRange;
  String? _professionalFilter;
  String? _serviceFilter;

  Map<String, int> _summary = const {
    'total': 0,
    'En espera': 0,
    'Confirmada': 0,
    'En progreso': 0,
    'Atendida': 0,
    'Cancelada': 0,
  };
  List<AppointmentModel> _appointments = [];
  int _page = 0;
  final int _pageSize = 20;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _dateRange = DateTimeRange(
      start: DateTime(now.year, now.month, 1),
      end: DateTime(now.year, now.month, now.day, 23, 59, 59, 999),
    );
    _load();
  }

  Future<void> _load() async {
    if (_dateRange == null) return;
    if (mounted) {
      setState(() {
        _loading = true;
        _errorMessage = null;
      });
    }

    try {
      final results = await Future.wait([
        _service.fetchProfessionals(),
        _service.fetchAllServices(),
        _service.fetchAppointmentReportSummary(
          from: _dateRange!.start,
          to: _dateRange!.end,
          professionalId: _professionalFilter,
          serviceId: _serviceFilter,
        ),
        _service.fetchAdminAppointments(
          from: _dateRange!.start,
          to: _dateRange!.end,
          professionalId: _professionalFilter,
          serviceId: _serviceFilter,
          limit: _pageSize,
          offset: _page * _pageSize,
        ),
      ]);

      if (!mounted) return;
      setState(() {
        _professionals = results[0] as List<Map<String, String>>;
        _services = (results[1] as List)
            .map(
              (service) => {
                'id': service.id as String,
                'name': service.name as String,
              },
            )
            .toList();
        _summary = results[2] as Map<String, int>;
        _appointments = results[3] as List<AppointmentModel>;
      });
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'No se pudo cargar el reporte.';
          _appointments = [];
        });
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  String _formatDateRange(DateTimeRange range) {
    final formatter = DateFormat('dd MMM yyyy', 'es_ES');
    return '${formatter.format(range.start)} - ${formatter.format(range.end)}';
  }

  Color _statusColor(String status) {
    return switch (status) {
      'En espera' => Colors.blue,
      'Confirmada' => Colors.green,
      'En progreso' => Colors.orange,
      'Atendida' => Colors.grey,
      'Cancelada' => Colors.red,
      _ => Colors.grey,
    };
  }

  Future<void> _pickDateRange() async {
    final now = DateTime.now();
    final initial =
        _dateRange ??
        DateTimeRange(
          start: DateTime(now.year, now.month, 1),
          end: DateTime(now.year, now.month, now.day, 23, 59, 59, 999),
        );

    final selected = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2023),
      lastDate: DateTime(now.year + 1),
      initialDateRange: initial,
    );

    if (selected == null) return;
    setState(() {
      _dateRange = DateTimeRange(
        start: DateTime(
          selected.start.year,
          selected.start.month,
          selected.start.day,
        ),
        end: DateTime(
          selected.end.year,
          selected.end.month,
          selected.end.day,
          23,
          59,
          59,
          999,
        ),
      );
      _page = 0;
    });
    await _load();
  }

  Future<void> _showStatusDetails(String status) async {
    if (_dateRange == null) return;
    showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text('Detalle: $status'),
          content: SizedBox(
            width: 400,
            height: 400,
            child: FutureBuilder<List<AppointmentModel>>(
              future: _service.fetchAdminAppointments(
                from: _dateRange!.start,
                to: _dateRange!.end,
                professionalId: _professionalFilter,
                serviceId: _serviceFilter,
                limit: 1000,
                offset: 0,
              ),
              builder: (context, snapshot) {
                if (snapshot.connectionState != ConnectionState.done) {
                  return const Center(child: CircularProgressIndicator());
                }
                final list =
                    snapshot.data?.where((a) => a.status == status).toList() ??
                    [];
                if (list.isEmpty) {
                  return const Center(
                    child: Text('No hay citas para este estado.'),
                  );
                }
                return ListView.separated(
                  itemCount: list.length,
                  separatorBuilder: (_, __) => const Divider(height: 1),
                  itemBuilder: (context, idx) {
                    final ap = list[idx];
                    return ListTile(
                      title: Text(
                        ap.serviceName.isEmpty ? 'Servicio' : ap.serviceName,
                      ),
                      subtitle: Text('${ap.clientName} · ${ap.petName}'),
                      trailing: Text(
                        ap.scheduledAt == null
                            ? '-'
                            : DateFormat('dd/MM HH:mm').format(ap.scheduledAt!),
                      ),
                    );
                  },
                );
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('Cerrar'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final totalCount = _summary['total'] ?? 0;
    final maxPage = totalCount == 0 ? 0 : ((totalCount - 1) ~/ _pageSize);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Administración — Reportes'),
        centerTitle: true,
        actions: [
          IconButton(
            tooltip: 'Actualizar',
            icon: const Icon(Icons.refresh),
            onPressed: _load,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Card(
              elevation: 0,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    LayoutBuilder(
                      builder: (context, constraints) {
                        if (constraints.maxWidth < 600) {
                          // Stack vertically on narrow screens
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              OutlinedButton.icon(
                                onPressed: _pickDateRange,
                                icon: const Icon(Icons.date_range_outlined),
                                label: Text(
                                  _dateRange == null
                                      ? 'Elegir rango'
                                      : _formatDateRange(_dateRange!),
                                ),
                              ),
                              const SizedBox(height: 8),
                              DropdownButtonFormField<String?>(
                                initialValue: _professionalFilter,
                                decoration: const InputDecoration(
                                  labelText: 'Profesional',
                                  border: OutlineInputBorder(),
                                  isDense: true,
                                ),
                                items: [
                                  const DropdownMenuItem<String?>(
                                    value: null,
                                    child: Text('Todos'),
                                  ),
                                  ..._professionals.map(
                                    (professional) => DropdownMenuItem<String?>(
                                      value: professional['id'],
                                      child: Text(
                                        professional['full_name']?.isNotEmpty ==
                                                true
                                            ? professional['full_name']!
                                            : professional['email'] ??
                                                  'Profesional',
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ),
                                ],
                                onChanged: (value) async {
                                  setState(() {
                                    _professionalFilter = value;
                                    _page = 0;
                                  });
                                  await _load();
                                },
                              ),
                              const SizedBox(height: 8),
                              DropdownButtonFormField<String?>(
                                initialValue: _serviceFilter,
                                decoration: const InputDecoration(
                                  labelText: 'Servicio',
                                  border: OutlineInputBorder(),
                                  isDense: true,
                                ),
                                items: [
                                  const DropdownMenuItem<String?>(
                                    value: null,
                                    child: Text('Todos'),
                                  ),
                                  ..._services.map(
                                    (service) => DropdownMenuItem<String?>(
                                      value: service['id'],
                                      child: Text(
                                        service['name'] ?? 'Servicio',
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ),
                                ],
                                onChanged: (value) async {
                                  setState(() {
                                    _serviceFilter = value;
                                    _page = 0;
                                  });
                                  await _load();
                                },
                              ),
                            ],
                          );
                        }

                        // Wider screens keep compact layout
                        return Wrap(
                          spacing: 12,
                          runSpacing: 12,
                          children: [
                            OutlinedButton.icon(
                              onPressed: _pickDateRange,
                              icon: const Icon(Icons.date_range_outlined),
                              label: Text(
                                _dateRange == null
                                    ? 'Elegir rango'
                                    : _formatDateRange(_dateRange!),
                              ),
                            ),
                            SizedBox(
                              width: 220,
                              child: DropdownButtonFormField<String?>(
                                initialValue: _professionalFilter,
                                decoration: const InputDecoration(
                                  labelText: 'Profesional',
                                  border: OutlineInputBorder(),
                                  isDense: true,
                                ),
                                items: [
                                  const DropdownMenuItem<String?>(
                                    value: null,
                                    child: Text('Todos'),
                                  ),
                                  ..._professionals.map(
                                    (professional) => DropdownMenuItem<String?>(
                                      value: professional['id'],
                                      child: Text(
                                        professional['full_name']?.isNotEmpty ==
                                                true
                                            ? professional['full_name']!
                                            : professional['email'] ??
                                                  'Profesional',
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ),
                                ],
                                onChanged: (value) async {
                                  setState(() {
                                    _professionalFilter = value;
                                    _page = 0;
                                  });
                                  await _load();
                                },
                              ),
                            ),
                            SizedBox(
                              width: 220,
                              child: DropdownButtonFormField<String?>(
                                initialValue: _serviceFilter,
                                decoration: const InputDecoration(
                                  labelText: 'Servicio',
                                  border: OutlineInputBorder(),
                                  isDense: true,
                                ),
                                items: [
                                  const DropdownMenuItem<String?>(
                                    value: null,
                                    child: Text('Todos'),
                                  ),
                                  ..._services.map(
                                    (service) => DropdownMenuItem<String?>(
                                      value: service['id'],
                                      child: Text(
                                        service['name'] ?? 'Servicio',
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ),
                                ],
                                onChanged: (value) async {
                                  setState(() {
                                    _serviceFilter = value;
                                    _page = 0;
                                  });
                                  await _load();
                                },
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Rango actual: ${_dateRange == null ? '-' : _formatDateRange(_dateRange!)}',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
            Card(
              elevation: 0,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Resumen por estado',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 12),
                    ...[
                      'En espera',
                      'Confirmada',
                      'En progreso',
                      'Atendida',
                      'Cancelada',
                    ].map(
                      (status) => Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: InkWell(
                          borderRadius: BorderRadius.circular(8),
                          onTap: () => _showStatusDetails(status),
                          child: Row(
                            children: [
                              SizedBox(width: 110, child: Text(status)),
                              const SizedBox(width: 12),
                              Expanded(
                                child: LinearProgressIndicator(
                                  minHeight: 12,
                                  value: totalCount == 0
                                      ? 0
                                      : (_summary[status] ?? 0) / totalCount,
                                  backgroundColor: _statusColor(
                                    status,
                                  ).withValues(alpha: 0.15),
                                  color: _statusColor(status),
                                ),
                              ),
                              const SizedBox(width: 12),
                              SizedBox(
                                width: 36,
                                child: Text(
                                  '${_summary[status] ?? 0}',
                                  textAlign: TextAlign.right,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              const Icon(
                                Icons.chevron_right,
                                size: 18,
                                color: Colors.black26,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Align(
                      alignment: Alignment.centerRight,
                      child: Text(
                        'Total de citas: $totalCount',
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: _loading
                  ? const Center(child: CircularProgressIndicator())
                  : _errorMessage != null
                  ? Center(child: Text(_errorMessage!))
                  : _appointments.isEmpty
                  ? const Center(child: Text('No hay citas en este rango.'))
                  : RefreshIndicator(
                      onRefresh: _load,
                      child: ListView.separated(
                        physics: const AlwaysScrollableScrollPhysics(),
                        itemCount: _appointments.length + 1,
                        separatorBuilder: (context, index) =>
                            const SizedBox(height: 10),
                        itemBuilder: (context, index) {
                          if (index == _appointments.length) {
                            return Padding(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text('Página ${_page + 1} de ${maxPage + 1}'),
                                  Row(
                                    children: [
                                      IconButton(
                                        onPressed: _page == 0
                                            ? null
                                            : () async {
                                                setState(() => _page--);
                                                await _load();
                                              },
                                        icon: const Icon(Icons.chevron_left),
                                      ),
                                      IconButton(
                                        onPressed: _page >= maxPage
                                            ? null
                                            : () async {
                                                setState(() => _page++);
                                                await _load();
                                              },
                                        icon: const Icon(Icons.chevron_right),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            );
                          }

                          final appointment = _appointments[index];
                          return Card(
                            elevation: 0,
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Expanded(
                                        child: Text(
                                          appointment.serviceName.isEmpty
                                              ? 'Servicio no disponible'
                                              : appointment.serviceName,
                                          style: Theme.of(context)
                                              .textTheme
                                              .titleMedium
                                              ?.copyWith(
                                                fontWeight: FontWeight.w700,
                                              ),
                                        ),
                                      ),
                                      Chip(
                                        label: Text(appointment.status),
                                        backgroundColor: _statusColor(
                                          appointment.status,
                                        ).withValues(alpha: 0.12),
                                        labelStyle: TextStyle(
                                          color: _statusColor(
                                            appointment.status,
                                          ),
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    '${appointment.clientName.isEmpty ? 'Cliente' : appointment.clientName} · ${appointment.petName.isEmpty ? 'Mascota' : appointment.petName}',
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Profesional: ${appointment.professionalName.isEmpty ? 'Sin nombre' : appointment.professionalName}',
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    appointment.scheduledAt == null
                                        ? 'Fecha no disponible'
                                        : DateFormat(
                                            'EEEE, dd MMM yyyy · HH:mm',
                                            'es_ES',
                                          ).format(appointment.scheduledAt!),
                                  ),
                                  if (appointment.notes != null &&
                                      appointment.notes!.isNotEmpty) ...[
                                    const SizedBox(height: 8),
                                    Text(
                                      appointment.notes!,
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                      style: Theme.of(
                                        context,
                                      ).textTheme.bodySmall,
                                    ),
                                  ],
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
