import 'package:flutter/material.dart';
import '../config/theme.dart';
import '../screens/add_pet_screen.dart';
import '../services/pet_service.dart';
import '../widgets/pet_avatar.dart';

class PetsScreen extends StatefulWidget {
  const PetsScreen({super.key});

  @override
  State<PetsScreen> createState() => _PetsScreenState();
}

class _PetsScreenState extends State<PetsScreen> {
  final _petService = PetService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Mis Mascotas'), centerTitle: true),
      body: StreamBuilder<List<Pet>>(
        stream: _petService.userPetsStream(),
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
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.pets_rounded, size: 72, color: AppColors.tertiary),
                  const SizedBox(height: 16),
                  Text(
                    'Aún no tienes mascotas',
                    style: Theme.of(context).textTheme.headlineSmall,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Agrega tu primera mascota para agendar citas',
                    style: Theme.of(context).textTheme.bodyMedium,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: _navigateToAddPet,
                    icon: const Icon(Icons.add),
                    label: const Text('Agregar mascota'),
                  ),
                ],
              ),
            );
          }

          // Lista de mascotas
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: pets.length,
            itemBuilder: (context, index) {
              final pet = pets[index];
              return _buildPetCard(context, pet);
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

  Widget _buildPetCard(BuildContext context, Pet pet) {
    // Calcula edad aproximada
    final age = DateTime.now()
        .difference(pet.birthDate ?? DateTime.now())
        .inDays;
    final ageText = pet.birthDate != null
        ? '${(age / 365).toStringAsFixed(1)} años'
        : 'Edad desconocida';

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Avatar
            PetAvatar(species: pet.species, photoUrl: pet.photoUrl, size: 64),
            const SizedBox(width: 12),

            // Información
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    pet.name,
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${pet.species}${pet.breed != null ? ' • ${pet.breed}' : ''}',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Text(
                        ageText,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.outline,
                        ),
                      ),
                      if (pet.weight != null) ...[
                        const SizedBox(width: 8),
                        Text(
                          '• ${pet.weight} kg',
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(color: AppColors.outline),
                        ),
                      ],
                    ],
                  ),
                  if (pet.notes != null && pet.notes!.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceContainerLow,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        pet.notes!,
                        style: Theme.of(context).textTheme.bodySmall,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ],
              ),
            ),

            // Opciones
            PopupMenuButton<String>(
              onSelected: (value) {
                if (value == 'edit') {
                  _navigateToEditPet(pet);
                } else if (value == 'delete') {
                  _showDeleteConfirmation(context, pet);
                }
              },
              itemBuilder: (BuildContext context) => [
                const PopupMenuItem(value: 'edit', child: Text('Editar')),
                const PopupMenuItem(value: 'delete', child: Text('Eliminar')),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _navigateToAddPet() async {
    final result = await Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (context) => const AddPetScreen()));

    // El Stream se actualiza automáticamente, pero aquí
    // podrías mostrar un SnackBar si lo deseas
    if (result == true && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Mascota agregada exitosamente')),
      );
    }
  }

  void _navigateToEditPet(Pet pet) {
    // TODO: Implementar pantalla de edición (HU-7)
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Edición próximamente disponible')),
    );
  }

  void _showDeleteConfirmation(BuildContext context, Pet pet) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Eliminar mascota'),
        content: Text('¿Estás seguro de que deseas eliminar a ${pet.name}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await _petService.deletePet(pet.id);
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Mascota eliminada')),
                );
              }
            },
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
  }
}
