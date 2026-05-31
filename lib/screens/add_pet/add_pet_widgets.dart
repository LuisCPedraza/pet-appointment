import 'dart:typed_data';

import 'package:flutter/material.dart';

import '../../config/theme.dart';

/// =============================================
/// lib/screens/add_pet/add_pet_widgets.dart
/// Descripción: Widgets auxiliares de la pantalla de alta y edición de mascotas.
/// Responsabilidad: Encapsular los selectores de especie, foto y fecha para mantener el formulario principal más corto.
/// =============================================

class AddPetSpeciesSelector extends StatelessWidget {
  const AddPetSpeciesSelector({
    super.key,
    required this.selectedSpecies,
    required this.onChanged,
  });

  final String selectedSpecies;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Especie *', style: Theme.of(context).textTheme.labelLarge),
        const SizedBox(height: 8),
        SegmentedButton<String>(
          segments: const [
            ButtonSegment(label: Text('Perro'), value: 'Perro'),
            ButtonSegment(label: Text('Gato'), value: 'Gato'),
            ButtonSegment(label: Text('Otro'), value: 'Otro'),
          ],
          selected: {selectedSpecies},
          onSelectionChanged: (selected) {
            onChanged(selected.first);
          },
        ),
      ],
    );
  }
}

class AddPetPhotoSelector extends StatelessWidget {
  const AddPetPhotoSelector({
    super.key,
    required this.selectedPhotoBytes,
    required this.existingPhotoUrl,
    required this.removeExistingPhoto,
    required this.onPickPhoto,
    required this.onRemoveSelectedPhoto,
    required this.onRemoveExistingPhoto,
  });

  final Uint8List? selectedPhotoBytes;
  final String? existingPhotoUrl;
  final bool removeExistingPhoto;
  final VoidCallback onPickPhoto;
  final VoidCallback onRemoveSelectedPhoto;
  final VoidCallback onRemoveExistingPhoto;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Foto (opcional)', style: Theme.of(context).textTheme.labelLarge),
        const SizedBox(height: 12),
        if (selectedPhotoBytes != null)
          Stack(
            alignment: Alignment.topRight,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.memory(
                  selectedPhotoBytes!,
                  width: 120,
                  height: 120,
                  fit: BoxFit.cover,
                ),
              ),
              Positioned(
                right: 0,
                top: 0,
                child: GestureDetector(
                  onTap: onRemoveSelectedPhoto,
                  child: Container(
                    decoration: BoxDecoration(
                      color: AppColors.error,
                      shape: BoxShape.circle,
                    ),
                    padding: const EdgeInsets.all(4),
                    child: const Icon(
                      Icons.close,
                      color: Colors.white,
                      size: 16,
                    ),
                  ),
                ),
              ),
            ],
          )
        else if (existingPhotoUrl != null && !removeExistingPhoto)
          Stack(
            alignment: Alignment.topRight,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(
                  existingPhotoUrl!,
                  width: 120,
                  height: 120,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Container(
                    width: 120,
                    height: 120,
                    color: AppColors.surfaceContainerLow,
                    child: const Icon(Icons.broken_image_outlined),
                  ),
                ),
              ),
              Positioned(
                right: 0,
                top: 0,
                child: GestureDetector(
                  onTap: onRemoveExistingPhoto,
                  child: Container(
                    decoration: const BoxDecoration(
                      color: AppColors.error,
                      shape: BoxShape.circle,
                    ),
                    padding: const EdgeInsets.all(4),
                    child: const Icon(
                      Icons.close,
                      color: Colors.white,
                      size: 16,
                    ),
                  ),
                ),
              ),
            ],
          )
        else
          ElevatedButton.icon(
            onPressed: onPickPhoto,
            icon: const Icon(Icons.image_outlined),
            label: const Text('Seleccionar foto'),
          ),
      ],
    );
  }
}

class AddPetBirthDateSelector extends StatelessWidget {
  const AddPetBirthDateSelector({
    super.key,
    required this.selectedBirthDate,
    required this.onTap,
  });

  final DateTime? selectedBirthDate;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Fecha de nacimiento *',
          style: Theme.of(context).textTheme.labelLarge,
        ),
        const SizedBox(height: 8),
        InkWell(
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
            decoration: BoxDecoration(
              border: Border.all(color: AppColors.outline),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                const Icon(Icons.calendar_today_outlined),
                const SizedBox(width: 12),
                Text(
                  selectedBirthDate != null
                      ? '${selectedBirthDate!.day}/${selectedBirthDate!.month}/${selectedBirthDate!.year}'
                      : 'Selecciona una fecha',
                  style: selectedBirthDate != null
                      ? Theme.of(context).textTheme.bodyMedium
                      : Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppColors.outline,
                        ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
