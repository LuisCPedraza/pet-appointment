import 'package:flutter/material.dart';
import '../config/theme.dart';
import '../screens/add_pet_screen.dart';
import '../screens/pet_detail_screen.dart';
import '../services/pet_service.dart';
import '../widgets/pet_avatar.dart';

class PetsScreen extends StatefulWidget {
  const PetsScreen({super.key});

  @override
  State<PetsScreen> createState() => _PetsScreenState();
}

class _PetsScreenState extends State<PetsScreen> {
  final _petService = PetService();
  late Future<List<PetListItem>> _petsFuture;

  @override
  void initState() {
    super.initState();
    _reloadPets();
  }

  void _reloadPets() {
    _petsFuture = _petService.getUserPetsWithLastAppointment();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Mis Mascotas'), centerTitle: true),
      body: FutureBuilder<List<PetListItem>>(
        future: _petsFuture,
        builder: (context, snapshot) {
          // Cargando
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          // Error
          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, size: 48, color: AppColors.error),
                  const SizedBox(height: 16),
                  Text(
                    'Error cargando mascotas',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 8),
                  Text(snapshot.error.toString()),
                ],
              ),
            );
          }

          final pets = snapshot.data ?? [];

          // Sin mascotas
          if (pets.isEmpty) {
            return _buildEmptyState(context);
          }

          // Lista de mascotas
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: pets.length,
            itemBuilder: (context, index) {
              final item = pets[index];
              return _buildPetCard(context, item);
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _navigateToAddPet,
        icon: const Icon(Icons.add),
        label: const Text('Agregar mascota'),
      ),
    );
  }

  String _formatDate(DateTime? date) {
    if (date == null) return 'Sin citas aun';
    final d = date.toLocal();
    return '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';
  }

  String _speciesLabel(String species) {
    if (species.isEmpty) return 'Especie';
    return species[0].toUpperCase() + species.substring(1).toLowerCase();
  }

  IconData _speciesIcon(String species) {
    switch (species.toLowerCase()) {
      case 'perro':
        return Icons.pets;
      case 'gato':
        return Icons.favorite;
      default:
        return Icons.cruelty_free;
    }
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Container(
          width: double.infinity,
          constraints: const BoxConstraints(maxWidth: 480),
          padding: const EdgeInsets.fromLTRB(22, 24, 22, 22),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFFEAF3FF), Color(0xFFF4F8FF)],
            ),
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: AppColors.surfaceContainerHigh),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 14,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 92,
                height: 92,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white,
                  border: Border.all(color: AppColors.surfaceContainerHigh),
                ),
                child: const Icon(
                  Icons.pets_rounded,
                  size: 44,
                  color: AppColors.tertiary,
                ),
              ),
              const SizedBox(height: 18),
              Text(
                'Aun no tienes mascotas',
                style: Theme.of(
                  context,
                ).textTheme.headlineSmall?.copyWith(height: 1.2),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                'Registra a tu primer companero para llevar su historial y agendar citas facilmente.',
                style: Theme.of(context).textTheme.bodyMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 18),
              Wrap(
                alignment: WrapAlignment.center,
                spacing: 8,
                runSpacing: 8,
                children: const [
                  _EmptyHintChip(
                    icon: Icons.medical_information_outlined,
                    label: 'Historial clinico',
                  ),
                  _EmptyHintChip(
                    icon: Icons.event_available_outlined,
                    label: 'Citas organizadas',
                  ),
                  _EmptyHintChip(
                    icon: Icons.notifications_active_outlined,
                    label: 'Recordatorios',
                  ),
                ],
              ),
              const SizedBox(height: 22),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _navigateToAddPet,
                  icon: const Icon(Icons.add),
                  label: const Text('Agregar mi primera mascota'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPetCard(BuildContext context, PetListItem item) {
    final pet = item.pet;
    final lastAppointmentText = _formatDate(item.lastAppointmentAt);
    final hasAppointments = item.lastAppointmentAt != null;

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.035),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        child: InkWell(
          borderRadius: BorderRadius.circular(18),
          onTap: () => _goToPetDetail(item),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(3),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.surfaceContainerHigh),
                  ),
                  child: PetAvatar(
                    species: pet.species,
                    photoUrl: pet.photoUrl,
                    size: 66,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              pet.name,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: Theme.of(context).textTheme.headlineSmall
                                  ?.copyWith(fontSize: 19, height: 1.1),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Icon(Icons.chevron_right, color: AppColors.outline),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          _TagChip(
                            icon: _speciesIcon(pet.species),
                            label: _speciesLabel(pet.species),
                            color: AppColors.primary,
                          ),
                          if (pet.weight != null)
                            _TagChip(
                              icon: Icons.monitor_weight_outlined,
                              label:
                                  '${pet.weight!.toStringAsFixed(pet.weight! % 1 == 0 ? 0 : 1)} kg',
                              color: AppColors.secondary,
                            ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: hasAppointments
                              ? AppColors.secondary.withValues(alpha: 0.08)
                              : AppColors.surfaceContainerLow,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: hasAppointments
                                ? AppColors.secondary.withValues(alpha: 0.22)
                                : AppColors.surfaceContainerHigh,
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.event_available_outlined,
                              size: 16,
                              color: hasAppointments
                                  ? AppColors.secondary
                                  : AppColors.outline,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'Ultima cita: $lastAppointmentText',
                                style: Theme.of(context).textTheme.bodySmall
                                    ?.copyWith(
                                      color: hasAppointments
                                          ? AppColors.secondary
                                          : AppColors.outline,
                                      fontWeight: FontWeight.w600,
                                    ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _goToPetDetail(PetListItem item) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => PetDetailScreen(
          pet: item.pet,
          lastAppointmentAt: item.lastAppointmentAt,
        ),
      ),
    );
  }

  Future<void> _navigateToAddPet() async {
    final result = await Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (context) => const AddPetScreen()));

    if (!mounted) return;

    if (result == true) {
      setState(_reloadPets);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Mascota agregada exitosamente')),
      );
    }
  }
}

class _TagChip extends StatelessWidget {
  const _TagChip({
    required this.icon,
    required this.label,
    required this.color,
  });

  final IconData icon;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: color.withValues(alpha: 0.22)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: color),
          const SizedBox(width: 6),
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: color,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyHintChip extends StatelessWidget {
  const _EmptyHintChip({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: AppColors.surfaceContainerHigh),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: AppColors.primary),
          const SizedBox(width: 6),
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: AppColors.onSurface,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
