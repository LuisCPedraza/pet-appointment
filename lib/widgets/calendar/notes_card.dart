import 'package:flutter/material.dart';
import 'package:pet_appointment/config/theme.dart';
import 'package:pet_appointment/widgets/card_container.dart';
import 'package:pet_appointment/widgets/section_label.dart';

/// Tarjeta con campo de texto para notas adicionales de la cita.
class NotesCard extends StatelessWidget {
  const NotesCard({super.key, required this.controller});

  final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    return CardContainer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionLabel('Notas adicionales'),
          const SizedBox(height: 10),
          TextField(
            controller: controller,
            maxLines: 3,
            decoration: InputDecoration(
              hintText: 'Sintomas, alergias o solicitudes especiales...',
              hintStyle: TextStyle(
                color: AppColors.outline.withValues(alpha: 0.6),
                fontSize: 14,
              ),
              filled: true,
              fillColor: AppColors.surfaceContainerHigh,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.all(14),
            ),
          ),
        ],
      ),
    );
  }
}
