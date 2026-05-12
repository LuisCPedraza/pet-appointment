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
    required this.loading,
    required this.onGenerate,
  });

  final int slotMinutes;
  final void Function(int) onSlotMinutesChanged;
  final bool loading;
  final VoidCallback onGenerate;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Text('Duración:'),
        const SizedBox(width: 8),
        DropdownButton<int>(
          value: slotMinutes,
          items: const [15, 30, 45, 60]
              .map((m) => DropdownMenuItem(value: m, child: Text('$m min')))
              .toList(),
          onChanged: (v) => onSlotMinutesChanged(v ?? 30),
        ),
        const Spacer(),
        ElevatedButton.icon(
          onPressed: loading ? null : onGenerate,
          icon: const Icon(Icons.playlist_add),
          label: const Text('Generar 4 semanas'),
        ),
      ],
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
    if (slots.isEmpty) return const SizedBox.shrink();
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: slots.length,
      separatorBuilder: (_, i) => const Divider(),
      itemBuilder: (context, i) {
        final s = slots[i];
        return ListTile(
          title: Text('${s.start.toLocal()} - ${s.end.toLocal()}'),
          subtitle: Text(s.isAvailable ? 'Disponible' : 'Ocupado/Blocked'),
          trailing: Switch(
            value: s.isAvailable,
            onChanged: (v) async {
              await updateSlotAvailability(s.id, v);
            },
          ),
        );
      },
    );
  }
}
