import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:pet_appointment/config/theme.dart';
import 'package:pet_appointment/controllers/calendar_controller.dart';
import 'package:pet_appointment/widgets/card_container.dart';
import 'package:pet_appointment/widgets/section_label.dart';

/// Tarjeta con los horarios disponibles para el día seleccionado.
class TimeSlotsCard extends StatelessWidget {
  const TimeSlotsCard({super.key, required this.controller});

  final CalendarController controller;

  @override
  Widget build(BuildContext context) {
    final slots = controller.slotsForDay(controller.selectedDay);
    return CardContainer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionLabel('Hora Disponible'),
          const SizedBox(height: 12),
          if (slots.isEmpty)
            Text(
              'No hay horarios disponibles para este dia.',
              style: TextStyle(
                fontSize: 13,
                color: AppColors.onSurfaceVariant,
              ),
            )
          else
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: slots.map((slot) {
                final booked = controller.bookedIds.contains(slot.id);
                final sel = controller.selectedSlot?.id == slot.id;
                return _TimeChip(
                  label: DateFormat('hh:mm a').format(slot.start),
                  sublabel: slot.professionalName,
                  selected: sel,
                  booked: booked,
                  onTap: booked ? null : () => controller.selectSlot(slot),
                );
              }).toList(),
            ),
        ],
      ),
    );
  }
}

class _TimeChip extends StatelessWidget {
  const _TimeChip({
    required this.label,
    required this.selected,
    required this.booked,
    this.sublabel,
    this.onTap,
  });

  final String label;
  final String? sublabel;
  final bool selected;
  final bool booked;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final Color bg;
    final Color fg;
    final Color subFg;
    final BoxBorder? border;

    if (booked) {
      bg = Colors.transparent;
      fg = AppColors.outline.withValues(alpha: 0.35);
      subFg = AppColors.outline.withValues(alpha: 0.3);
      border = Border.all(color: AppColors.outline.withValues(alpha: 0.18));
    } else if (selected) {
      bg = AppColors.secondaryContainer;
      fg = const Color(0xFF005E3E);
      subFg = const Color(0xFF337A5A);
      border = null;
    } else {
      bg = Colors.transparent;
      fg = AppColors.onSurface;
      subFg = AppColors.onSurfaceVariant;
      border = Border.all(color: AppColors.outline.withValues(alpha: 0.28));
    }

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 150,
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 9),
        decoration: BoxDecoration(
          color: bg,
          border: border,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                color: fg,
              ),
            ),
            if (sublabel != null) ...[
              const SizedBox(height: 2),
              Text(
                sublabel!,
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 11, color: subFg),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
