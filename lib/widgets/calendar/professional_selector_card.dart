import 'package:flutter/material.dart';
import 'package:pet_appointment/config/theme.dart';
import 'package:pet_appointment/controllers/calendar_controller.dart';
import 'package:pet_appointment/widgets/card_container.dart';
import 'package:pet_appointment/widgets/section_label.dart';

/// Tarjeta para escoger el profesional que atenderá la cita.
class ProfessionalSelectorCard extends StatelessWidget {
  const ProfessionalSelectorCard({super.key, required this.controller});

  final CalendarController controller;

  @override
  Widget build(BuildContext context) {
    return CardContainer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionLabel('Profesional'),
          const SizedBox(height: 12),
          if (controller.professionals.isEmpty)
            Text(
              'No hay profesionales activos disponibles.',
              style: TextStyle(fontSize: 13, color: AppColors.onSurfaceVariant),
            )
          else
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: controller.professionals.map((professional) {
                  final id = professional['id'] ?? '';
                  final name = professional['full_name'] ?? 'Profesional';
                  final email = professional['email'] ?? '';
                  final selected = controller.selectedProfessionalId == id;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: _ProfessionalChip(
                      label: name,
                      sublabel: email,
                      selected: selected,
                      onTap: () =>
                          controller.changeProfessional(selected ? null : id),
                    ),
                  );
                }).toList(),
              ),
            ),
        ],
      ),
    );
  }
}

class _ProfessionalChip extends StatelessWidget {
  const _ProfessionalChip({
    required this.label,
    required this.sublabel,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final String sublabel;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: selected
              ? AppColors.primaryContainer
              : AppColors.surfaceContainerHigh,
          borderRadius: BorderRadius.circular(12),
          border: selected
              ? Border.all(color: AppColors.primary, width: 1.2)
              : Border.all(color: AppColors.outline.withValues(alpha: 0.16)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: selected ? AppColors.primary : AppColors.onSurface,
              ),
            ),
            if (sublabel.isNotEmpty) ...[
              const SizedBox(height: 2),
              Text(
                sublabel,
                style: TextStyle(
                  fontSize: 11,
                  color: AppColors.onSurfaceVariant,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
