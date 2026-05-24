import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:pet_appointment/models/availability_slot.dart';

// theme not required in these widgets; styling uses defaults or values from context

class ProfessionalAvailabilityWeekdays extends StatelessWidget {
  const ProfessionalAvailabilityWeekdays({
    super.key,
    required this.weekdayEnabled,
    required this.onToggle,
  });

  final Map<int, bool> weekdayEnabled;
  final void Function(int day, bool enabled) onToggle;

  @override
  Widget build(BuildContext context) {
    final labels = {
      1: 'Lun',
      2: 'Mar',
      3: 'Mié',
      4: 'Jue',
      5: 'Vie',
      6: 'Sáb',
      7: 'Dom',
    };
    return Wrap(
      spacing: 8,
      children: labels.entries.map((e) {
        final enabled = weekdayEnabled[e.key] ?? false;
        return FilterChip(
          label: Text(e.value),
          selected: enabled,
          onSelected: (v) => onToggle(e.key, v),
        );
      }).toList(),
    );
  }
}

class ProfessionalAvailabilityTimePicker extends StatelessWidget {
  const ProfessionalAvailabilityTimePicker({
    super.key,
    required this.label,
    required this.value,
    required this.onChanged,
  });

  final String label;
  final TimeOfDay value;
  final ValueChanged<TimeOfDay> onChanged;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () async {
        final picked = await showTimePicker(
          context: context,
          initialTime: value,
        );
        if (picked != null) onChanged(picked);
      },
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(),
        ),
        child: Text(value.format(context)),
      ),
    );
  }
}

class ProfessionalAvailabilityControls extends StatelessWidget {
  const ProfessionalAvailabilityControls({
    super.key,
    required this.slotMinutes,
    required this.onSlotMinutesChanged,
    required this.weeksToGenerate,
    required this.onWeeksToGenerateChanged,
    required this.loading,
    required this.onGenerate,
  });

  final int slotMinutes;
  final void Function(int) onSlotMinutesChanged;
  final int weeksToGenerate;
  final void Function(int) onWeeksToGenerateChanged;
  final bool loading;
  final VoidCallback onGenerate;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final compact = constraints.maxWidth < 420;
        final controlWidth = compact
            ? ((constraints.maxWidth - 12).clamp(220.0, 400.0) / 2)
            : 170.0;

        return Wrap(
          spacing: 12,
          runSpacing: 12,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            SizedBox(
              width: controlWidth,
              child: DropdownButtonFormField<int>(
                initialValue: slotMinutes,
                isExpanded: true,
                decoration: const InputDecoration(
                  labelText: 'Duración',
                  border: OutlineInputBorder(),
                ),
                items: const [30, 60, 90, 120]
                    .map(
                      (m) => DropdownMenuItem(value: m, child: Text('$m min')),
                    )
                    .toList(),
                onChanged: (v) => onSlotMinutesChanged(v ?? 30),
              ),
            ),
            SizedBox(
              width: controlWidth,
              child: DropdownButtonFormField<int>(
                initialValue: weeksToGenerate,
                isExpanded: true,
                decoration: const InputDecoration(
                  labelText: 'Semanas',
                  border: OutlineInputBorder(),
                ),
                items: const [1, 2, 3, 4, 6, 8]
                    .map(
                      (w) => DropdownMenuItem(
                        value: w,
                        child: Text('$w sem${w == 1 ? '' : 's'}'),
                      ),
                    )
                    .toList(),
                onChanged: (v) => onWeeksToGenerateChanged(v ?? 4),
              ),
            ),
            ElevatedButton.icon(
              onPressed: loading ? null : onGenerate,
              icon: const Icon(Icons.sync_alt_rounded),
              label: Text('Aplicar ($weeksToGenerate sem)'),
            ),
          ],
        );
      },
    );
  }
}

class ProfessionalAvailabilitySlotList extends StatelessWidget {
  const ProfessionalAvailabilitySlotList({
    super.key,
    required this.slots,
    required this.updateSlotAvailability,
  });

  final List<AvailabilitySlot> slots;
  final Future<void> Function(String slotId, bool available)
  updateSlotAvailability;

  @override
  Widget build(BuildContext context) {
    if (slots.isEmpty) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 24),
        child: Center(child: Text('Todavía no hay slots para mostrar.')),
      );
    }

    final groupedSlots = SplayTreeMap<DateTime, List<AvailabilitySlot>>();
    final sortedSlots = [...slots]
      ..sort((left, right) => left.start.compareTo(right.start));

    for (final slot in sortedSlots) {
      final dayKey = DateTime(
        slot.start.year,
        slot.start.month,
        slot.start.day,
      );
      groupedSlots.putIfAbsent(dayKey, () => <AvailabilitySlot>[]).add(slot);
    }

    return Column(
      children: groupedSlots.entries
          .map(
            (entry) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _SlotDayCard(
                dayLabel: _formatDay(entry.key),
                slots: entry.value,
                updateSlotAvailability: updateSlotAvailability,
              ),
            ),
          )
          .toList(),
    );
  }

  String _formatDay(DateTime day) {
    const monthNames = [
      'enero',
      'febrero',
      'marzo',
      'abril',
      'mayo',
      'junio',
      'julio',
      'agosto',
      'septiembre',
      'octubre',
      'noviembre',
      'diciembre',
    ];
    return '${day.day} de ${monthNames[day.month - 1]} de ${day.year}';
  }
}

class _SlotDayCard extends StatelessWidget {
  const _SlotDayCard({
    required this.dayLabel,
    required this.slots,
    required this.updateSlotAvailability,
  });

  final String dayLabel;
  final List<AvailabilitySlot> slots;
  final Future<void> Function(String slotId, bool available)
  updateSlotAvailability;

  @override
  Widget build(BuildContext context) {
    final activeCount = slots.where((slot) => slot.isEnabled).length;
    final inactiveCount = slots.length - activeCount;
    final bookedCount = slots.where((slot) => slot.isBooked).length;

    return Card(
      margin: EdgeInsets.zero,
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(
                    Icons.event_available,
                    color: Colors.blue.shade700,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        dayLabel,
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.w800),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '$activeCount activos · $inactiveCount inactivos · $bookedCount reservados',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.blueGrey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: slots.map((slot) {
                final label =
                    '${_formatTime(slot.start)} - ${_formatTime(slot.end)}';
                final enabled = slot.isEnabled;
                final canToggle = !slot.isBooked && !slot.isPast;
                final MaterialColor chipColor = slot.isBooked
                    ? Colors.amber
                    : enabled
                    ? Colors.green
                    : Colors.red;
                final selectedColor = slot.isBooked
                    ? Colors.amber.shade100
                    : Colors.green.shade50;
                return FilterChip(
                  label: Text(label),
                  selected: enabled,
                  avatar: Icon(
                    slot.isBooked
                        ? Icons.event_busy_outlined
                        : enabled
                        ? Icons.check_circle_outline
                        : Icons.block_outlined,
                    size: 18,
                    color: chipColor.shade700,
                  ),
                  showCheckmark: false,
                  selectedColor: selectedColor,
                  backgroundColor: Colors.grey.shade100,
                  labelStyle: TextStyle(
                    color: slot.isBooked
                        ? Colors.amber.shade900
                        : enabled
                        ? Colors.green.shade900
                        : Colors.grey.shade800,
                    fontWeight: FontWeight.w600,
                  ),
                  onSelected: canToggle
                      ? (_) async {
                          await updateSlotAvailability(slot.id, !enabled);
                        }
                      : null,
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  String _formatTime(DateTime value) {
    final hour = value.hour.toString().padLeft(2, '0');
    final minute = value.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }
}
