import 'package:flutter/material.dart';
import 'package:pet_appointment/config/theme.dart';
import 'package:pet_appointment/controllers/calendar_controller.dart';
import 'package:pet_appointment/models/availability_slot.dart';
import 'package:pet_appointment/widgets/card_container.dart';
import 'package:table_calendar/table_calendar.dart';

/// Tarjeta con el calendario mensual y marcado de días disponibles.
class CalendarCard extends StatelessWidget {
  const CalendarCard({super.key, required this.controller});

  final CalendarController controller;

  @override
  Widget build(BuildContext context) {
    return CardContainer(
      child: TableCalendar<AvailabilitySlot>(
        firstDay: DateTime.now(),
        lastDay: DateTime.now().add(const Duration(days: 90)),
        focusedDay: controller.focusedDay,
        locale: 'es_ES',
        selectedDayPredicate: (d) => isSameDay(controller.selectedDay, d),
        onDaySelected: (sel, foc) => controller.selectDay(sel, foc),
        onPageChanged: (foc) {
          controller.focusedDay = foc;
          controller.loadMonth(foc);
        },
        eventLoader: (day) {
          final key = DateTime(day.year, day.month, day.day);
          return (controller.slotsByDay[key] ?? [])
              .where((s) => !controller.bookedIds.contains(s.id) && !s.isPast)
              .toList();
        },
        calendarFormat: CalendarFormat.month,
        availableGestures: AvailableGestures.none,
        headerStyle: HeaderStyle(
          formatButtonVisible: false,
          titleCentered: true,
          titleTextStyle: TextStyle(
            fontFamily: AppFonts.primary,
            fontWeight: FontWeight.w700,
            fontSize: 16,
            color: AppColors.onSurface,
          ),
          leftChevronIcon: const _CalendarChevron(icon: Icons.chevron_left),
          rightChevronIcon: const _CalendarChevron(icon: Icons.chevron_right),
        ),
        daysOfWeekStyle: DaysOfWeekStyle(
          weekdayStyle: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w700,
            color: AppColors.outline,
            letterSpacing: 0.4,
          ),
          weekendStyle: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w700,
            color: AppColors.outline,
            letterSpacing: 0.4,
          ),
        ),
        calendarStyle: CalendarStyle(
          selectedDecoration: const BoxDecoration(
            color: AppColors.primary,
            shape: BoxShape.circle,
          ),
          selectedTextStyle: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w700,
          ),
          todayDecoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.18),
            shape: BoxShape.circle,
          ),
          todayTextStyle: const TextStyle(
            color: AppColors.primary,
            fontWeight: FontWeight.w700,
          ),
          markersMaxCount: 0,
          outsideDaysVisible: false,
        ),
        calendarBuilders: CalendarBuilders<AvailabilitySlot>(
          defaultBuilder: (ctx, day, _) {
            if (controller.slotsByDay.isEmpty) return null;
            if (day.year != controller.focusedDay.year ||
                day.month != controller.focusedDay.month) return null;
            final key = DateTime(day.year, day.month, day.day);
            final slots = controller.slotsByDay[key] ?? [];
            if (slots.isEmpty) return null;
            final hasFree = slots.any(
              (s) => !controller.bookedIds.contains(s.id) && !s.isPast,
            );
            return Container(
              margin: const EdgeInsets.all(6),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: hasFree
                    ? AppColors.secondary.withValues(alpha: 0.15)
                    : AppColors.surfaceContainerLow,
                shape: BoxShape.circle,
              ),
              child: Text(
                '${day.day}',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: hasFree ? FontWeight.w700 : FontWeight.w400,
                  color: hasFree ? AppColors.secondary : AppColors.outline,
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _CalendarChevron extends StatelessWidget {
  const _CalendarChevron({required this.icon});

  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 30,
      height: 30,
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerHigh,
        shape: BoxShape.circle,
      ),
      child: Icon(icon, size: 16, color: AppColors.onSurfaceVariant),
    );
  }
}
