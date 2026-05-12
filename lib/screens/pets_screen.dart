import 'package:flutter/material.dart';
import '../config/theme.dart';
import '../screens/add_pet_screen.dart';
import '../screens/pet_detail_screen.dart';
import '../services/pet_service.dart';
import '../screens/pets/pets_widgets.dart';
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
    return PetsEmptyState(onAddPet: _navigateToAddPet);
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
                          PetsTagChip(
                            icon: _speciesIcon(pet.species),
                            label: _speciesLabel(pet.species),
                            color: AppColors.primary,
                          ),
                          if (pet.weight != null)
                            PetsTagChip(
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

  Future<void> _goToPetDetail(PetListItem item) async {
    final result = await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => PetDetailScreen(
          pet: item.pet,
          lastAppointmentAt: item.lastAppointmentAt,
        ),
      ),
    );

    if (!mounted) return;

    if (result == true) {
      setState(_reloadPets);
    }
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
