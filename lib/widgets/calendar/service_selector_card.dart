import 'package:flutter/material.dart';
import 'package:pet_appointment/config/theme.dart';
import 'package:pet_appointment/controllers/calendar_controller.dart';
import 'package:pet_appointment/widgets/card_container.dart';
import 'package:pet_appointment/widgets/section_label.dart';

/// Tarjeta con chips para seleccionar el tipo de servicio.
class ServiceSelectorCard extends StatelessWidget {
  const ServiceSelectorCard({super.key, required this.controller});

  final CalendarController controller;

  @override
  Widget build(BuildContext context) {
    return CardContainer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionLabel('Tipo de Servicio'),
          const SizedBox(height: 12),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: controller.services.map((svc) {
                final sel = controller.selectedServiceId == svc.id;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: _ServiceChip(
                    label: svc.name,
                    selected: sel,
                    onTap: () => controller.changeService(sel ? null : svc.id),
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

/// Indicador informativo cuando aún no se seleccionó un servicio.
class ServiceRequiredHint extends StatelessWidget {
  const ServiceRequiredHint({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
      child: Row(
        children: [
          Icon(Icons.info_outline_rounded,
              size: 16, color: AppColors.onSurfaceVariant),
          const SizedBox(width: 8),
          Text(
            'Selecciona un servicio para ver el calendario.',
            style: TextStyle(fontSize: 13, color: AppColors.onSurfaceVariant),
          ),
        ],
      ),
    );
  }
}

class _ServiceChip extends StatelessWidget {
  const _ServiceChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
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
              ? AppColors.secondaryContainer
              : AppColors.surfaceContainerHigh,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: selected
                ? const Color(0xFF005E3E)
                : AppColors.onSurfaceVariant,
          ),
        ),
      ),
    );
  }
}
