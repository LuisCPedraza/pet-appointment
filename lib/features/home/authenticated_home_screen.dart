import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:pet_appointment/config/theme.dart';
import 'package:pet_appointment/models/appointment_model.dart';
import 'package:pet_appointment/models/user_profile_model.dart';
import 'package:pet_appointment/services/appointment_service.dart';
import 'package:pet_appointment/services/auth_service.dart';
import 'package:pet_appointment/services/pet_service.dart';
import 'package:pet_appointment/widgets/app_logo_title.dart';
import 'package:pet_appointment/widgets/app_shell.dart';

class AuthenticatedHomeScreen extends StatefulWidget {
  const AuthenticatedHomeScreen({super.key});

  @override
  State<AuthenticatedHomeScreen> createState() =>
      _AuthenticatedHomeScreenState();
}

class _AuthenticatedHomeScreenState extends State<AuthenticatedHomeScreen> {
  final _authService = AuthService();
  final _appointmentService = AppointmentService();
  final _petService = PetService();

  late Future<_HomeDashboardData> _dashboardFuture;

  @override
  void initState() {
    super.initState();
    _dashboardFuture = _loadDashboard();
    AppShell.tabIndexNotifier.addListener(_handleTabChange);
  }

  void _handleTabChange() {
    if (!mounted || AppShell.tabIndexNotifier.value != 0) return;
    setState(() {
      _dashboardFuture = _loadDashboard();
    });
  }

  Future<_HomeDashboardData> _loadDashboard() async {
    final results = await Future.wait([
      _authService.getCurrentUserProfile(),
      _appointmentService.fetchUpcomingAppointments(limit: 5),
      _petService.getUserPets(),
    ]);

    final profile = results[0] as UserProfileModel;
    final appointments = results[1] as List<AppointmentModel>;
    final pets = results[2] as List<Pet>;

    return _HomeDashboardData(
      profile: profile,
      nextAppointment: appointments.isNotEmpty ? appointments.first : null,
      upcomingAppointments: appointments,
      pets: pets,
    );
  }

  Future<void> _refresh() async {
    setState(() {
      _dashboardFuture = _loadDashboard();
    });
    await _dashboardFuture;
  }

  @override
  void dispose() {
    AppShell.tabIndexNotifier.removeListener(_handleTabChange);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        title: const AppLogoTitle(iconSize: 26),
        titleSpacing: 16,
      ),
      body: RefreshIndicator(
        onRefresh: _refresh,
        child: FutureBuilder<_HomeDashboardData>(
          future: _dashboardFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (snapshot.hasError || !snapshot.hasData) {
              return ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(24),
                children: [
                  const SizedBox(height: 120),
                  Icon(
                    Icons.error_outline_rounded,
                    size: 64,
                    color: AppColors.error,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No pudimos cargar tu inicio.',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Desliza hacia abajo para reintentar.',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              );
            }

            final data = snapshot.data!;
            final firstName = data.profile.name.trim().isEmpty
                ? 'Usuario'
                : data.profile.name.trim().split(RegExp(r'\s+')).first;
            final nextAppointment = data.nextAppointment;

            return ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 28),
              children: [
                _GreetingCard(firstName: firstName, profile: data.profile),
                const SizedBox(height: 16),
                _SummaryRow(
                  pets: data.pets,
                  appointments: data.upcomingAppointments,
                ),
                const SizedBox(height: 16),
                if (nextAppointment != null)
                  _NextAppointmentCard(appointment: nextAppointment)
                else
                  _NoAppointmentCard(onBookNow: () => AppShell.selectTab(2)),
                const SizedBox(height: 16),
                _QuickActionsCard(
                  onNewAppointment: () => AppShell.selectTab(2),
                  onPets: () => AppShell.selectTab(1),
                ),
                const SizedBox(height: 16),
                _PetsCard(pets: data.pets),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _HomeDashboardData {
  const _HomeDashboardData({
    required this.profile,
    required this.nextAppointment,
    required this.upcomingAppointments,
    required this.pets,
  });

  final UserProfileModel profile;
  final AppointmentModel? nextAppointment;
  final List<AppointmentModel> upcomingAppointments;
  final List<Pet> pets;
}

class _GreetingCard extends StatelessWidget {
  const _GreetingCard({required this.firstName, required this.profile});

  final String firstName;
  final UserProfileModel profile;

  @override
  Widget build(BuildContext context) {
    final avatar = profile.photoUrl;

    return Card(
      elevation: 0,
      color: AppColors.primary.withValues(alpha: 0.07),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            CircleAvatar(
              radius: 28,
              backgroundColor: AppColors.primaryContainer,
              backgroundImage: avatar == null || avatar.isEmpty
                  ? null
                  : NetworkImage(avatar),
              child: avatar == null || avatar.isEmpty
                  ? Text(
                      profile.initials,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                      ),
                    )
                  : null,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '¡Hola, $firstName!',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Aquí tienes un resumen rápido de tu actividad.',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  const _SummaryRow({required this.pets, required this.appointments});

  final List<Pet> pets;
  final List<AppointmentModel> appointments;

  @override
  Widget build(BuildContext context) {
    final activeAppointments = appointments.length;

    return Row(
      children: [
        Expanded(
          child: _SummaryTile(
            icon: Icons.pets_rounded,
            label: 'Mascotas',
            value: '${pets.length}',
            subtitle: pets.isEmpty
                ? 'Todavía no tienes mascotas registradas.'
                : '${pets.first.name}${pets.length > 1 ? ' y ${pets.length - 1} más' : ''}',
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _SummaryTile(
            icon: Icons.event_available_rounded,
            label: 'Próximas citas',
            value: '$activeAppointments',
            subtitle: activeAppointments == 0
                ? 'Sin citas futuras.'
                : 'Tienes citas activas por venir.',
          ),
        ),
      ],
    );
  }
}

class _SummaryTile extends StatelessWidget {
  const _SummaryTile({
    required this.icon,
    required this.label,
    required this.value,
    required this.subtitle,
  });

  final IconData icon;
  final String label;
  final String value;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: AppColors.primary),
            const SizedBox(height: 12),
            Text(
              value,
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.w800,
                color: AppColors.onSurface,
              ),
            ),
            const SizedBox(height: 4),
            Text(label, style: Theme.of(context).textTheme.titleSmall),
            const SizedBox(height: 4),
            Text(subtitle, style: Theme.of(context).textTheme.bodySmall),
          ],
        ),
      ),
    );
  }
}

class _NextAppointmentCard extends StatelessWidget {
  const _NextAppointmentCard({required this.appointment});

  final AppointmentModel appointment;

  @override
  Widget build(BuildContext context) {
    final scheduledAt = appointment.scheduledAt;
    final formattedDate = scheduledAt == null
        ? 'Pendiente de horario'
        : DateFormat('EEEE, dd MMM • HH:mm', 'es_ES').format(scheduledAt);

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.event_note_rounded, color: AppColors.primary),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Próxima cita',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                Chip(label: Text(appointment.status)),
              ],
            ),
            const SizedBox(height: 16),
            _DetailLine(label: 'Mascota', value: appointment.petName),
            _DetailLine(label: 'Servicio', value: appointment.serviceName),
            _DetailLine(
              label: 'Profesional',
              value: appointment.professionalName.isEmpty
                  ? 'Por asignar'
                  : appointment.professionalName,
            ),
            _DetailLine(label: 'Fecha y hora', value: formattedDate),
          ],
        ),
      ),
    );
  }
}

class _DetailLine extends StatelessWidget {
  const _DetailLine({required this.label, required this.value});

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
            width: 110,
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

class _NoAppointmentCard extends StatelessWidget {
  const _NoAppointmentCard({required this.onBookNow});

  final VoidCallback onBookNow;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'No tienes citas futuras.',
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 6),
            Text(
              'Agenda una cita para ver aquí tu próxima visita.',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed: onBookNow,
              icon: const Icon(Icons.calendar_month_rounded),
              label: const Text('Agendar cita'),
            ),
          ],
        ),
      ),
    );
  }
}

class _QuickActionsCard extends StatelessWidget {
  const _QuickActionsCard({
    required this.onNewAppointment,
    required this.onPets,
  });

  final VoidCallback onNewAppointment;
  final VoidCallback onPets;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Accesos rápidos',
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(
                  child: FilledButton.icon(
                    onPressed: onNewAppointment,
                    icon: const Icon(Icons.add_circle_outline_rounded),
                    label: const Text('Nueva cita'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: onPets,
                    icon: const Icon(Icons.pets_rounded),
                    label: const Text('Mis mascotas'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _PetsCard extends StatelessWidget {
  const _PetsCard({required this.pets});

  final List<Pet> pets;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Tus mascotas',
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 12),
            if (pets.isEmpty)
              Text(
                'Aún no has registrado mascotas.',
                style: Theme.of(context).textTheme.bodyMedium,
              )
            else
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: pets
                    .take(5)
                    .map(
                      (pet) => Chip(
                        avatar: const Icon(Icons.pets_rounded, size: 16),
                        label: Text(pet.name),
                      ),
                    )
                    .toList(),
              ),
          ],
        ),
      ),
    );
  }
}
