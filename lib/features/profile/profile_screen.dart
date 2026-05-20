import 'package:flutter/material.dart';
import 'package:pet_appointment/features/profile/edit_profile_screen.dart';
import 'package:pet_appointment/config/theme.dart';
import 'package:pet_appointment/models/user_profile_model.dart';
import 'package:pet_appointment/services/appointment_notification_service.dart';
import 'package:pet_appointment/services/auth_service.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _authService = AuthService();
  late Future<UserProfileModel> _profileFuture;
  bool _remindersEnabled = true;

  @override
  void initState() {
    super.initState();
    _profileFuture = _loadProfile();
    _loadRemindersEnabled();
  }

  Future<UserProfileModel> _loadProfile() async {
    return _authService.getCurrentUserProfile();
  }

  Future<void> _loadRemindersEnabled() async {
    final enabled = await AppointmentNotificationService.areRemindersEnabled();
    if (mounted) {
      setState(() {
        _remindersEnabled = enabled;
      });
    }
  }

  Future<void> _editProfile() async {
    final changed = await Navigator.of(
      context,
    ).push<bool>(MaterialPageRoute(builder: (_) => const EditProfileScreen()));

    if (changed == true && mounted) {
      setState(() {
        _profileFuture = _loadProfile();
      });
    }
  }

  Future<void> _toggleRemindersEnabled(bool value) async {
    await AppointmentNotificationService.setRemindersEnabled(value);
    if (mounted) {
      setState(() {
        _remindersEnabled = value;
      });
    }
  }

  Future<void> _logout() async {
    await _authService.logout();
    if (!mounted) return;
    Navigator.of(context).pushNamedAndRemoveUntil('/login', (_) => false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mi Perfil'),
        centerTitle: true,
        actions: [
          IconButton(
            tooltip: 'Editar perfil',
            onPressed: _editProfile,
            icon: const Icon(Icons.edit_outlined),
          ),
        ],
      ),
      body: FutureBuilder<UserProfileModel>(
        future: _profileFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text(
                  'No se pudo cargar tu perfil.',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ),
            );
          }

          final profile = snapshot.data!;

          return RefreshIndicator(
            onRefresh: () async {
              setState(() {
                _profileFuture = _loadProfile();
              });
              await _profileFuture;
            },
            child: ListView(
              padding: const EdgeInsets.all(20),
              physics: const AlwaysScrollableScrollPhysics(),
              children: [
                Card(
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      children: [
                        CircleAvatar(
                          radius: 44,
                          backgroundColor: AppColors.primaryContainer,
                          backgroundImage:
                              profile.photoUrl == null ||
                                  profile.photoUrl!.isEmpty
                              ? null
                              : NetworkImage(profile.photoUrl!),
                          child:
                              profile.photoUrl == null ||
                                  profile.photoUrl!.isEmpty
                              ? Text(
                                  profile.initials,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w800,
                                    fontSize: 20,
                                  ),
                                )
                              : null,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          profile.name,
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.headlineSmall
                              ?.copyWith(fontWeight: FontWeight.w800),
                        ),
                        const SizedBox(height: 4),
                        Text(profile.email, textAlign: TextAlign.center),
                        const SizedBox(height: 12),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          alignment: WrapAlignment.center,
                          children: [
                            Chip(label: Text(profile.role)),
                            Chip(
                              avatar: Icon(
                                profile.isActive
                                    ? Icons.check_circle
                                    : Icons.pause_circle,
                                color: profile.isActive
                                    ? Colors.green
                                    : Colors.red,
                                size: 16,
                              ),
                              label: Text(
                                profile.isActive ? 'Activo' : 'Inactivo',
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        if (profile.role == 'admin')
                          OutlinedButton.icon(
                            onPressed: () {
                              Navigator.of(context).pushNamed('/admin');
                            },
                            icon: const Icon(
                              Icons.admin_panel_settings_outlined,
                            ),
                            label: const Text('Ir al panel admin'),
                            style: OutlinedButton.styleFrom(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Card(
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Datos de contacto',
                          style: Theme.of(context).textTheme.titleLarge
                              ?.copyWith(fontWeight: FontWeight.w800),
                        ),
                        const SizedBox(height: 12),
                        _ProfileLine(
                          label: 'Teléfono',
                          value: profile.phone.isEmpty
                              ? 'Sin registrar'
                              : profile.phone,
                        ),
                        _ProfileLine(label: 'Correo', value: profile.email),
                        _ProfileLine(label: 'Rol', value: profile.role),
                        const Divider(height: 32),
                        SwitchListTile(
                          contentPadding: EdgeInsets.zero,
                          title: const Text('Recordatorios de citas'),
                          subtitle: const Text(
                            'Recibe un aviso 24 horas antes de tus citas confirmadas.',
                          ),
                          value: _remindersEnabled,
                          onChanged: _toggleRemindersEnabled,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                FilledButton.icon(
                  onPressed: _editProfile,
                  icon: const Icon(Icons.edit_outlined),
                  label: const Text('Editar perfil'),
                ),
                const SizedBox(height: 12),
                OutlinedButton.icon(
                  onPressed: _logout,
                  icon: const Icon(Icons.logout_rounded),
                  label: const Text('Cerrar sesión'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.error,
                    side: BorderSide(color: AppColors.error),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _ProfileLine extends StatelessWidget {
  const _ProfileLine({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 90,
            child: Text(
              label,
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w700),
            ),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }
}
