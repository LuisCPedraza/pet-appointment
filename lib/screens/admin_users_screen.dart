import 'package:flutter/material.dart';
import 'package:pet_appointment/config/theme.dart';
import 'package:pet_appointment/services/auth_service.dart';

/// Panel de administración: lista paginada de usuarios con búsqueda,
/// filtrado por rol, cambio de rol y activación/desactivación (soft delete).
class AdminUsersScreen extends StatefulWidget {
  const AdminUsersScreen({super.key});

  @override
  State<AdminUsersScreen> createState() => _AdminUsersScreenState();
}

class _AdminUsersScreenState extends State<AdminUsersScreen> {
  final _auth = AuthService();
  final _searchController = TextEditingController();
  String? _roleFilter;
  int _page = 0;
  final int _pageSize = 10;

  List<Map<String, dynamic>> _users = [];
  bool _loading = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _ensureAdmin();
    _load();
  }

  Future<void> _ensureAdmin() async {
    final isAdmin = await _auth.isCurrentUserAdmin();
    if (!isAdmin) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Acceso denegado: se requiere rol admin.'),
            backgroundColor: AppColors.error,
          ),
        );
        Navigator.of(context).pop();
      }
    }
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
      final users = await _auth.fetchUsers(
        limit: _pageSize,
        offset: _page * _pageSize,
        roleFilter: _roleFilter,
        search: _searchController.text.trim().isEmpty
            ? null
            : _searchController.text.trim(),
      );
      if (mounted) setState(() => _users = users);
    } catch (e) {
      debugPrint('Error al cargar usuarios: $e');
      if (mounted) {
        setState(() {
          _users = [];
          _errorMessage =
              'No se pudieron cargar los usuarios. Revisa la migración 012 y las policies RLS.';
        });
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error cargando usuarios: $e')));
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Administración — Usuarios'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    decoration: const InputDecoration(
                      labelText: 'Buscar por nombre o correo',
                      prefixIcon: Icon(Icons.search),
                    ),
                    onSubmitted: (_) => _load(),
                  ),
                ),
                const SizedBox(width: 12),
                DropdownButton<String>(
                  value: _roleFilter,
                  hint: const Text('Filtrar rol'),
                  items: const [null, 'client', 'professional', 'admin']
                      .map(
                        (r) => DropdownMenuItem<String>(
                          value: r,
                          child: Text(r ?? 'Todos'),
                        ),
                      )
                      .toList(),
                  onChanged: (v) {
                    setState(() => _roleFilter = v);
                    _load();
                  },
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (_errorMessage != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Text(
                  _errorMessage!,
                  style: TextStyle(color: Theme.of(context).colorScheme.error),
                ),
              ),
            Expanded(
              child: _loading
                  ? const Center(child: CircularProgressIndicator())
                  : _users.isEmpty
                  ? const Center(child: Text('Sin resultados'))
                  : ListView.builder(
                      itemCount: _users.length,
                      itemBuilder: (context, idx) {
                        final u = _users[idx];
                        final id = u['id'] as String? ?? '';
                        final photo =
                            u['photo_url'] as String? ??
                            u['avatar_url'] as String?;
                        final name = u['full_name'] ?? u['email'] ?? '';
                        final email = u['email'] ?? '';
                        final phone = u['phone'] ?? '';
                        final role = u['role'] ?? 'client';
                        final active = u['is_active'] ?? true;
                        final currentId = _auth.currentUserId;

                        return Card(
                          margin: const EdgeInsets.only(bottom: 12),
                          elevation: 0,
                          color: Theme.of(context)
                              .colorScheme
                              .surfaceContainerHighest
                              .withValues(alpha: 0.45),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(18),
                            side: BorderSide(
                              color: Theme.of(
                                context,
                              ).dividerColor.withValues(alpha: 0.25),
                            ),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    photo != null && photo.isNotEmpty
                                        ? CircleAvatar(
                                            radius: 24,
                                            backgroundImage: NetworkImage(
                                              photo,
                                            ),
                                          )
                                        : const CircleAvatar(
                                            radius: 24,
                                            child: Icon(Icons.person_outline),
                                          ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            name,
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            style: Theme.of(context)
                                                .textTheme
                                                .titleMedium
                                                ?.copyWith(
                                                  fontWeight: FontWeight.w700,
                                                ),
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            email,
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            style: Theme.of(
                                              context,
                                            ).textTheme.bodyMedium,
                                          ),
                                          if (phone.isNotEmpty) ...[
                                            const SizedBox(height: 2),
                                            Text(
                                              phone,
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .bodySmall
                                                  ?.copyWith(
                                                    color: Theme.of(
                                                      context,
                                                    ).hintColor,
                                                  ),
                                            ),
                                          ],
                                          const SizedBox(height: 8),
                                          Wrap(
                                            spacing: 8,
                                            runSpacing: 8,
                                            children: [
                                              Chip(
                                                avatar: const Icon(
                                                  Icons.badge_outlined,
                                                  size: 16,
                                                ),
                                                label: Text(role),
                                              ),
                                              Chip(
                                                avatar: Icon(
                                                  active
                                                      ? Icons.check_circle
                                                      : Icons.pause_circle,
                                                  size: 16,
                                                  color: active
                                                      ? Colors.green
                                                      : Colors.red,
                                                ),
                                                label: Text(
                                                  active
                                                      ? 'Activo'
                                                      : 'Inactivo',
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 14),
                                LayoutBuilder(
                                  builder: (context, constraints) {
                                    final narrow = constraints.maxWidth < 360;
                                    if (narrow) {
                                      return Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.stretch,
                                        children: [
                                          DropdownButtonFormField<String>(
                                            isExpanded: true,
                                            initialValue: role,
                                            decoration: const InputDecoration(
                                              labelText: 'Rol',
                                              border: OutlineInputBorder(),
                                              isDense: true,
                                            ),
                                            items: const [
                                              DropdownMenuItem(
                                                value: 'client',
                                                child: Text('client'),
                                              ),
                                              DropdownMenuItem(
                                                value: 'professional',
                                                child: Text('professional'),
                                              ),
                                              DropdownMenuItem(
                                                value: 'admin',
                                                child: Text('admin'),
                                              ),
                                            ],
                                            onChanged: (v) async {
                                              final messenger =
                                                  ScaffoldMessenger.maybeOf(
                                                    context,
                                                  );
                                              if (v == null || v == role) {
                                                return;
                                              }
                                              if (id == currentId) {
                                                messenger?.showSnackBar(
                                                  const SnackBar(
                                                    content: Text(
                                                      'No puedes cambiar tu propio rol.',
                                                    ),
                                                  ),
                                                );
                                                return;
                                              }
                                              final confirm = await showDialog<bool>(
                                                context: context,
                                                builder: (dialogContext) =>
                                                    AlertDialog(
                                                      title: const Text(
                                                        'Confirmar cambio de rol',
                                                      ),
                                                      content: Text(
                                                        'Cambiar rol de "$name" a "$v"?',
                                                      ),
                                                      actions: [
                                                        TextButton(
                                                          onPressed: () =>
                                                              Navigator.of(
                                                                dialogContext,
                                                              ).pop(false),
                                                          child: const Text(
                                                            'Cancelar',
                                                          ),
                                                        ),
                                                        TextButton(
                                                          onPressed: () =>
                                                              Navigator.of(
                                                                dialogContext,
                                                              ).pop(true),
                                                          child: const Text(
                                                            'Aceptar',
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                              );
                                              if (confirm != true) return;
                                              final ok = await _auth
                                                  .changeUserRole(
                                                    userId: id,
                                                    newRole: v,
                                                  );
                                              if (ok) {
                                                messenger?.showSnackBar(
                                                  const SnackBar(
                                                    content: Text(
                                                      'Rol actualizado',
                                                    ),
                                                  ),
                                                );
                                                await _load();
                                              } else {
                                                messenger?.showSnackBar(
                                                  const SnackBar(
                                                    content: Text(
                                                      'Error actualizando rol',
                                                    ),
                                                  ),
                                                );
                                              }
                                            },
                                          ),
                                          const SizedBox(height: 8),
                                          FilledButton.icon(
                                            onPressed: id == currentId
                                                ? null
                                                : () async {
                                                    final messenger =
                                                        ScaffoldMessenger.maybeOf(
                                                          context,
                                                        );
                                                    final nextActive = !active;
                                                    final confirm = await showDialog<bool>(
                                                      context: context,
                                                      builder: (dialogContext) => AlertDialog(
                                                        title: Text(
                                                          nextActive
                                                              ? 'Confirmar activación'
                                                              : 'Confirmar desactivación',
                                                        ),
                                                        content: Text(
                                                          '${nextActive ? 'Activar' : 'Desactivar'} la cuenta de "$name"?',
                                                        ),
                                                        actions: [
                                                          TextButton(
                                                            onPressed: () =>
                                                                Navigator.of(
                                                                  dialogContext,
                                                                ).pop(false),
                                                            child: const Text(
                                                              'Cancelar',
                                                            ),
                                                          ),
                                                          TextButton(
                                                            onPressed: () =>
                                                                Navigator.of(
                                                                  dialogContext,
                                                                ).pop(true),
                                                            child: const Text(
                                                              'Aceptar',
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    );
                                                    if (confirm != true) return;
                                                    final ok = await _auth
                                                        .setUserActive(
                                                          userId: id,
                                                          active: nextActive,
                                                        );
                                                    if (ok) {
                                                      messenger?.showSnackBar(
                                                        const SnackBar(
                                                          content: Text(
                                                            'Estado actualizado',
                                                          ),
                                                        ),
                                                      );
                                                      await _load();
                                                    } else {
                                                      messenger?.showSnackBar(
                                                        const SnackBar(
                                                          content: Text(
                                                            'Error actualizando estado',
                                                          ),
                                                        ),
                                                      );
                                                    }
                                                  },
                                            icon: Icon(
                                              active
                                                  ? Icons.check_circle
                                                  : Icons.pause_circle,
                                            ),
                                            label: Text(
                                              active ? 'Activo' : 'Inactivo',
                                            ),
                                            style: FilledButton.styleFrom(
                                              backgroundColor: active
                                                  ? Colors.green
                                                  : Colors.red,
                                              foregroundColor: Colors.white,
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                    horizontal: 14,
                                                    vertical: 12,
                                                  ),
                                            ),
                                          ),
                                        ],
                                      );
                                    }

                                    return Row(
                                      children: [
                                        Expanded(
                                          child: DropdownButtonFormField<String>(
                                            isExpanded: true,
                                            initialValue: role,
                                            decoration: const InputDecoration(
                                              labelText: 'Rol',
                                              border: OutlineInputBorder(),
                                              isDense: true,
                                            ),
                                            items: const [
                                              DropdownMenuItem(
                                                value: 'client',
                                                child: Text('client'),
                                              ),
                                              DropdownMenuItem(
                                                value: 'professional',
                                                child: Text('professional'),
                                              ),
                                              DropdownMenuItem(
                                                value: 'admin',
                                                child: Text('admin'),
                                              ),
                                            ],
                                            onChanged: (v) async {
                                              final messenger =
                                                  ScaffoldMessenger.maybeOf(
                                                    context,
                                                  );
                                              if (v == null || v == role) {
                                                return;
                                              }
                                              if (id == currentId) {
                                                messenger?.showSnackBar(
                                                  const SnackBar(
                                                    content: Text(
                                                      'No puedes cambiar tu propio rol.',
                                                    ),
                                                  ),
                                                );
                                                return;
                                              }
                                              final confirm = await showDialog<bool>(
                                                context: context,
                                                builder: (dialogContext) =>
                                                    AlertDialog(
                                                      title: const Text(
                                                        'Confirmar cambio de rol',
                                                      ),
                                                      content: Text(
                                                        'Cambiar rol de "$name" a "$v"?',
                                                      ),
                                                      actions: [
                                                        TextButton(
                                                          onPressed: () =>
                                                              Navigator.of(
                                                                dialogContext,
                                                              ).pop(false),
                                                          child: const Text(
                                                            'Cancelar',
                                                          ),
                                                        ),
                                                        TextButton(
                                                          onPressed: () =>
                                                              Navigator.of(
                                                                dialogContext,
                                                              ).pop(true),
                                                          child: const Text(
                                                            'Aceptar',
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                              );
                                              if (confirm != true) return;
                                              final ok = await _auth
                                                  .changeUserRole(
                                                    userId: id,
                                                    newRole: v,
                                                  );
                                              if (ok) {
                                                messenger?.showSnackBar(
                                                  const SnackBar(
                                                    content: Text(
                                                      'Rol actualizado',
                                                    ),
                                                  ),
                                                );
                                                await _load();
                                              } else {
                                                messenger?.showSnackBar(
                                                  const SnackBar(
                                                    content: Text(
                                                      'Error actualizando rol',
                                                    ),
                                                  ),
                                                );
                                              }
                                            },
                                          ),
                                        ),
                                        const SizedBox(width: 12),
                                        ConstrainedBox(
                                          constraints: const BoxConstraints(
                                            minWidth: 110,
                                          ),
                                          child: FilledButton.icon(
                                            onPressed: id == currentId
                                                ? null
                                                : () async {
                                                    final messenger =
                                                        ScaffoldMessenger.maybeOf(
                                                          context,
                                                        );
                                                    final nextActive = !active;
                                                    final confirm = await showDialog<bool>(
                                                      context: context,
                                                      builder: (dialogContext) => AlertDialog(
                                                        title: Text(
                                                          nextActive
                                                              ? 'Confirmar activación'
                                                              : 'Confirmar desactivación',
                                                        ),
                                                        content: Text(
                                                          '${nextActive ? 'Activar' : 'Desactivar'} la cuenta de "$name"?',
                                                        ),
                                                        actions: [
                                                          TextButton(
                                                            onPressed: () =>
                                                                Navigator.of(
                                                                  dialogContext,
                                                                ).pop(false),
                                                            child: const Text(
                                                              'Cancelar',
                                                            ),
                                                          ),
                                                          TextButton(
                                                            onPressed: () =>
                                                                Navigator.of(
                                                                  dialogContext,
                                                                ).pop(true),
                                                            child: const Text(
                                                              'Aceptar',
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    );
                                                    if (confirm != true) return;
                                                    final ok = await _auth
                                                        .setUserActive(
                                                          userId: id,
                                                          active: nextActive,
                                                        );
                                                    if (ok) {
                                                      messenger?.showSnackBar(
                                                        const SnackBar(
                                                          content: Text(
                                                            'Estado actualizado',
                                                          ),
                                                        ),
                                                      );
                                                      await _load();
                                                    } else {
                                                      messenger?.showSnackBar(
                                                        const SnackBar(
                                                          content: Text(
                                                            'Error actualizando estado',
                                                          ),
                                                        ),
                                                      );
                                                    }
                                                  },
                                            icon: Icon(
                                              active
                                                  ? Icons.check_circle
                                                  : Icons.pause_circle,
                                            ),
                                            label: Text(
                                              active ? 'Activo' : 'Inactivo',
                                            ),
                                            style: FilledButton.styleFrom(
                                              backgroundColor: active
                                                  ? Colors.green
                                                  : Colors.red,
                                              foregroundColor: Colors.white,
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                    horizontal: 14,
                                                    vertical: 12,
                                                  ),
                                            ),
                                          ),
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
                    ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Página ${_page + 1}'),
                Row(
                  children: [
                    IconButton(
                      onPressed: _page == 0
                          ? null
                          : () {
                              setState(() => _page--);
                              _load();
                            },
                      icon: const Icon(Icons.chevron_left),
                    ),
                    IconButton(
                      onPressed: () {
                        setState(() => _page++);
                        _load();
                      },
                      icon: const Icon(Icons.chevron_right),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
