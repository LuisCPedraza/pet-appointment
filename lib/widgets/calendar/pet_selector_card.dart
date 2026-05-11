import 'package:flutter/material.dart';
import 'package:pet_appointment/config/theme.dart';
import 'package:pet_appointment/controllers/calendar_controller.dart';
import 'package:pet_appointment/widgets/card_container.dart';
import 'package:pet_appointment/widgets/section_label.dart';

/// Tarjeta para seleccionar la mascota del usuario.
class PetSelectorCard extends StatelessWidget {
  const PetSelectorCard({super.key, required this.controller});

  final CalendarController controller;

  @override
  Widget build(BuildContext context) {
    return CardContainer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionLabel('Mascota'),
          const SizedBox(height: 10),
          _PetDropdown(
            value: controller.selectedPetId,
            items: controller.pets.map((p) {
              final name = p['name'] as String? ?? '';
              final breed = p['breed'] as String? ?? '';
              final species = p['species'] as String? ?? '';
              final sub = breed.isNotEmpty ? breed : species;
              return DropdownMenuItem(
                value: p['id'] as String,
                child: Text('$name${sub.isNotEmpty ? " ($sub)" : ""}'),
              );
            }).toList(),
            onChanged: controller.selectPet,
          ),
        ],
      ),
    );
  }
}

class _PetDropdown extends StatelessWidget {
  const _PetDropdown({
    required this.value,
    required this.items,
    required this.onChanged,
  });

  final String? value;
  final List<DropdownMenuItem<String>> items;
  final void Function(String?) onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 2),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(12),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          isExpanded: true,
          icon: const Icon(Icons.expand_more_rounded),
          style: TextStyle(fontSize: 15, color: AppColors.onSurface),
          items: items,
          onChanged: onChanged,
        ),
      ),
    );
  }
}
