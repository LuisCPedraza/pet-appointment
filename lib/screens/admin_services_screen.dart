import 'package:flutter/material.dart';
import 'package:pet_appointment/config/theme.dart';
import 'package:pet_appointment/models/service_model.dart';
import 'package:pet_appointment/services/appointment_service.dart';

class AdminServicesScreen extends StatefulWidget {
  const AdminServicesScreen({super.key});

  @override
  State<AdminServicesScreen> createState() => _AdminServicesScreenState();
}

class _AdminServicesScreenState extends State<AdminServicesScreen> {
  final _service = AppointmentService();
  final _searchController = TextEditingController();

  bool _loading = true;
  String? _errorMessage;
  List<ServiceModel> _services = [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    if (mounted) {
      setState(() {
        _loading = true;
        _errorMessage = null;
      });
    }

    try {
      final services = await _service.fetchAllServices();
      if (mounted) setState(() => _services = services);
    } catch (e) {
      if (mounted) {
        setState(() {
          _services = [];
          _errorMessage = 'No se pudo cargar el catálogo de servicios.';
        });
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  List<ServiceModel> get _filteredServices {
    final query = _searchController.text.trim().toLowerCase();
    if (query.isEmpty) return _services;
    return _services.where((service) {
      return service.name.toLowerCase().contains(query) ||
          (service.description ?? '').toLowerCase().contains(query);
    }).toList();
  }

  Future<void> _openEditor({ServiceModel? service}) async {
    final formKey = GlobalKey<FormState>();
    final nameController = TextEditingController(text: service?.name ?? '');
    final descriptionController = TextEditingController(
      text: service?.description ?? '',
    );
    final durationController = TextEditingController(
      text: (service?.durationMinutes ?? 30).toString(),
    );
    final priceController = TextEditingController(
      text: (service?.price ?? 0).toStringAsFixed(0),
    );
    bool isActive = service?.isActive ?? true;

    try {
      final confirmed = await showDialog<bool>(
        context: context,
        barrierDismissible: false,
        builder: (dialogContext) {
          return StatefulBuilder(
            builder: (context, setDialogState) {
              return AlertDialog(
                title: Text(
                  service == null ? 'Nuevo servicio' : 'Editar servicio',
                ),
                content: SizedBox(
                  width: 420,
                  child: SingleChildScrollView(
                    child: Form(
                      key: formKey,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          TextFormField(
                            controller: nameController,
                            decoration: const InputDecoration(
                              labelText: 'Nombre',
                              border: OutlineInputBorder(),
                            ),
                            validator: (value) =>
                                (value == null || value.trim().isEmpty)
                                ? 'Ingresa un nombre'
                                : null,
                          ),
                          const SizedBox(height: 12),
                          TextFormField(
                            controller: descriptionController,
                            maxLines: 3,
                            decoration: const InputDecoration(
                              labelText: 'Descripción',
                              border: OutlineInputBorder(),
                            ),
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Expanded(
                                child: TextFormField(
                                  controller: durationController,
                                  keyboardType: TextInputType.number,
                                  decoration: const InputDecoration(
                                    labelText: 'Duración (min)',
                                    border: OutlineInputBorder(),
                                  ),
                                  validator: (value) {
                                    final parsed = int.tryParse(value ?? '');
                                    if (parsed == null || parsed <= 0)
                                      return 'Minutos válidos';
                                    return null;
                                  },
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: TextFormField(
                                  controller: priceController,
                                  keyboardType:
                                      const TextInputType.numberWithOptions(
                                        decimal: true,
                                      ),
                                  decoration: const InputDecoration(
                                    labelText: 'Precio',
                                    border: OutlineInputBorder(),
                                  ),
                                  validator: (value) {
                                    final parsed = double.tryParse(
                                      (value ?? '').replaceAll(',', '.'),
                                    );
                                    if (parsed == null || parsed < 0)
                                      return 'Precio válido';
                                    return null;
                                  },
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          SwitchListTile.adaptive(
                            contentPadding: EdgeInsets.zero,
                            title: const Text('Activo'),
                            value: isActive,
                            onChanged: (value) =>
                                setDialogState(() => isActive = value),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.of(dialogContext).pop(false),
                    child: const Text('Cancelar'),
                  ),
                  FilledButton(
                    onPressed: () {
                      if (formKey.currentState?.validate() ?? false)
                        Navigator.of(dialogContext).pop(true);
                    },
                    child: const Text('Guardar'),
                  ),
                ],
              );
            },
          );
        },
      );

      if (confirmed != true) return;

      final name = nameController.text.trim();
      final description = descriptionController.text.trim();
      final duration = int.parse(durationController.text.trim());
      final price = double.parse(
        priceController.text.trim().replaceAll(',', '.'),
      );

      final ok = service == null
          ? await _service.createService(
              name: name,
              description: description.isEmpty ? null : description,
              durationMinutes: duration,
              price: price,
              isActive: isActive,
            )
          : await _service.updateService(
              serviceId: service.id,
              name: name,
              description: description.isEmpty ? null : description,
              durationMinutes: duration,
              price: price,
              isActive: isActive,
            );

      if (ok) {
        if (mounted)
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                service == null
                    ? 'Servicio creado correctamente'
                    : 'Servicio actualizado correctamente',
              ),
            ),
          );
        await _load();
      } else {
        if (mounted)
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('No se pudo guardar el servicio.')),
          );
      }
    } finally {
      nameController.dispose();
      descriptionController.dispose();
      durationController.dispose();
      priceController.dispose();
    }
  }

  Future<void> _toggleActive(ServiceModel service, bool active) async {
    final ok = await _service.setServiceActive(
      serviceId: service.id,
      active: active,
    );
    if (ok) {
      await _load();
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No se pudo actualizar el estado.')),
      );
    }
  }

  Future<void> _deleteService(ServiceModel service) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Eliminar servicio'),
        content: Text(
          '¿Eliminar "${service.name}"? Si ya tiene citas asociadas, el sistema bloqueará el borrado y deberás desactivarlo.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    try {
      await _service.deleteService(serviceId: service.id);
      if (mounted)
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Servicio eliminado')));
      await _load();
    } catch (e) {
      if (mounted)
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString().replaceFirst('Exception: ', ''))),
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    final visibleServices = _filteredServices;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Administración — Servicios'),
        centerTitle: true,
        actions: [
          IconButton(
            tooltip: 'Agregar servicio',
            onPressed: () => _openEditor(),
            icon: const Icon(Icons.add_circle_outline),
          ),
          IconButton(
            tooltip: 'Actualizar',
            onPressed: _load,
            icon: const Icon(Icons.refresh),
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
                  children: [
                    TextField(
                      controller: _searchController,
                      onChanged: (_) => setState(() {}),
                      decoration: const InputDecoration(
                        labelText: 'Buscar servicio',
                        prefixIcon: Icon(Icons.search),
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'Crear, editar, activar o desactivar servicios. Si hay citas asociadas, el borrado queda bloqueado y se debe desactivar.',
                        style: Theme.of(context).textTheme.bodySmall,
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
                  : visibleServices.isEmpty
                  ? const Center(child: Text('Sin servicios'))
                  : LayoutBuilder(
                      builder: (context, constraints) {
                        if (constraints.maxWidth < 600) {
                          return ListView.separated(
                            itemCount: visibleServices.length,
                            separatorBuilder: (c, i) =>
                                const SizedBox(height: 8),
                            padding: const EdgeInsets.only(top: 8),
                            itemBuilder: (context, index) {
                              final service = visibleServices[index];
                              return Card(
                                margin: const EdgeInsets.symmetric(vertical: 6),
                                elevation: 0,
                                color: Theme.of(context)
                                    .colorScheme
                                    .surfaceContainerHighest
                                    .withValues(alpha: 0.25),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14),
                                  side: BorderSide(
                                    color: Theme.of(
                                      context,
                                    ).dividerColor.withValues(alpha: 0.18),
                                  ),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.all(12),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Container(
                                            width: 44,
                                            height: 44,
                                            decoration: BoxDecoration(
                                              color: AppColors.secondary
                                                  .withValues(alpha: 0.12),
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                            ),
                                            child: const Icon(
                                              Icons.medical_services_outlined,
                                              color: AppColors.secondary,
                                            ),
                                          ),
                                          const SizedBox(width: 12),
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  service.name,
                                                  maxLines: 1,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                  style: Theme.of(context)
                                                      .textTheme
                                                      .titleMedium
                                                      ?.copyWith(
                                                        fontWeight:
                                                            FontWeight.w700,
                                                      ),
                                                ),
                                                const SizedBox(height: 4),
                                                Text(
                                                  service
                                                              .description
                                                              ?.isNotEmpty ==
                                                          true
                                                      ? service.description!
                                                      : 'Sin descripción',
                                                  maxLines: 2,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                  style: Theme.of(
                                                    context,
                                                  ).textTheme.bodySmall,
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 10),
                                      Wrap(
                                        spacing: 8,
                                        runSpacing: 8,
                                        children: [
                                          Chip(
                                            avatar: const Icon(
                                              Icons.timer,
                                              size: 16,
                                            ),
                                            label: Text(
                                              service.durationFormatted,
                                            ),
                                          ),
                                          Chip(
                                            avatar: const Icon(
                                              Icons.attach_money,
                                              size: 16,
                                            ),
                                            label: Text(service.priceFormatted),
                                          ),
                                          Chip(
                                            avatar: Icon(
                                              service.isActive
                                                  ? Icons.check_circle
                                                  : Icons.pause_circle,
                                              size: 16,
                                              color: service.isActive
                                                  ? Colors.green
                                                  : Colors.red,
                                            ),
                                            label: Text(
                                              service.isActive
                                                  ? 'Activo'
                                                  : 'Inactivo',
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 10),
                                      LayoutBuilder(
                                        builder: (context, constraints) {
                                          final narrowAction =
                                              constraints.maxWidth < 360;
                                          if (narrowAction) {
                                            return Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.stretch,
                                              children: [
                                                FilledButton.icon(
                                                  onPressed: () => _openEditor(
                                                    service: service,
                                                  ),
                                                  icon: const Icon(
                                                    Icons.edit_outlined,
                                                  ),
                                                  label: const Text('Editar'),
                                                ),
                                                const SizedBox(height: 8),
                                                FilledButton.icon(
                                                  onPressed: () =>
                                                      _toggleActive(
                                                        service,
                                                        !service.isActive,
                                                      ),
                                                  icon: Icon(
                                                    service.isActive
                                                        ? Icons.check_circle
                                                        : Icons.pause_circle,
                                                  ),
                                                  label: Text(
                                                    service.isActive
                                                        ? 'Activo'
                                                        : 'Inactivo',
                                                  ),
                                                  style: FilledButton.styleFrom(
                                                    backgroundColor:
                                                        service.isActive
                                                        ? Colors.green
                                                        : Colors.red,
                                                    foregroundColor:
                                                        Colors.white,
                                                  ),
                                                ),
                                                const SizedBox(height: 8),
                                                OutlinedButton.icon(
                                                  onPressed: () =>
                                                      _deleteService(service),
                                                  icon: const Icon(
                                                    Icons.delete_outline,
                                                  ),
                                                  label: const Text('Eliminar'),
                                                ),
                                              ],
                                            );
                                          }

                                          return Row(
                                            children: [
                                              FilledButton.icon(
                                                onPressed: () => _openEditor(
                                                  service: service,
                                                ),
                                                icon: const Icon(
                                                  Icons.edit_outlined,
                                                ),
                                                label: const Text('Editar'),
                                              ),
                                              const SizedBox(width: 8),
                                              FilledButton.icon(
                                                onPressed: () => _toggleActive(
                                                  service,
                                                  !service.isActive,
                                                ),
                                                icon: Icon(
                                                  service.isActive
                                                      ? Icons.check_circle
                                                      : Icons.pause_circle,
                                                ),
                                                label: Text(
                                                  service.isActive
                                                      ? 'Activo'
                                                      : 'Inactivo',
                                                ),
                                                style: FilledButton.styleFrom(
                                                  backgroundColor:
                                                      service.isActive
                                                      ? Colors.green
                                                      : Colors.red,
                                                  foregroundColor: Colors.white,
                                                ),
                                              ),
                                              const SizedBox(width: 8),
                                              OutlinedButton.icon(
                                                onPressed: () =>
                                                    _deleteService(service),
                                                icon: const Icon(
                                                  Icons.delete_outline,
                                                ),
                                                label: const Text('Eliminar'),
                                              ),
                                            ],
                                          );
                                        },
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          );
                        }

                        // Wider screens: keep DataTable for admin overview
                        return SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: DataTable(
                            headingRowColor: const WidgetStatePropertyAll(
                              AppColors.surfaceContainerLow,
                            ),
                            columns: const [
                              DataColumn(label: Text('Servicio')),
                              DataColumn(label: Text('Duración')),
                              DataColumn(label: Text('Precio')),
                              DataColumn(label: Text('Activo')),
                              DataColumn(label: Text('Acciones')),
                            ],
                            rows: visibleServices.map((service) {
                              return DataRow(
                                color: WidgetStatePropertyAll(
                                  service.isActive
                                      ? Colors.transparent
                                      : AppColors.surfaceContainerLow,
                                ),
                                cells: [
                                  DataCell(
                                    SizedBox(
                                      width: 260,
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Text(
                                            service.name,
                                            style: const TextStyle(
                                              fontWeight: FontWeight.w700,
                                            ),
                                          ),
                                          const SizedBox(height: 2),
                                          Text(
                                            service.description?.isNotEmpty ==
                                                    true
                                                ? service.description!
                                                : 'Sin descripción',
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                            style: Theme.of(
                                              context,
                                            ).textTheme.bodySmall,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  DataCell(Text(service.durationFormatted)),
                                  DataCell(Text(service.priceFormatted)),
                                  DataCell(
                                    Switch.adaptive(
                                      value: service.isActive,
                                      activeThumbColor: AppColors.secondary,
                                      onChanged: (value) =>
                                          _toggleActive(service, value),
                                    ),
                                  ),
                                  DataCell(
                                    Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        IconButton(
                                          tooltip: 'Editar',
                                          icon: const Icon(Icons.edit_outlined),
                                          onPressed: () =>
                                              _openEditor(service: service),
                                        ),
                                        IconButton(
                                          tooltip: 'Eliminar',
                                          icon: const Icon(
                                            Icons.delete_outline,
                                          ),
                                          onPressed: () =>
                                              _deleteService(service),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              );
                            }).toList(),
                          ),
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
