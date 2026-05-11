import 'package:flutter/material.dart';
import 'package:pet_appointment/models/availability_slot.dart';
import 'package:pet_appointment/services/appointment_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ProfessionalAvailabilityScreen extends StatefulWidget {
  const ProfessionalAvailabilityScreen({
    super.key,
    this.appointmentService,
    this.professionalId,
  });

  final dynamic appointmentService;
  final String? professionalId;

  @override
  State<ProfessionalAvailabilityScreen> createState() =>
      _ProfessionalAvailabilityScreenState();
}

class _ProfessionalAvailabilityScreenState
    extends State<ProfessionalAvailabilityScreen> {
  late final dynamic _service;
  final Map<int, bool> _weekdayEnabled = {
    1: true,
    2: true,
    3: true,
    4: true,
    5: true,
    6: false,
    7: false,
  };
  TimeOfDay _start = const TimeOfDay(hour: 9, minute: 0);
  TimeOfDay _end = const TimeOfDay(hour: 17, minute: 0);
  int _slotMinutes = 30;
  List<AvailabilitySlot> _slots = [];
  bool _loading = false;
  dynamic _channel;

  @override
  void initState() {
    super.initState();
    _service = widget.appointmentService ?? AppointmentService();
    _loadSlots();
    _subscribe();
  }

  @override
  void dispose() {
    _channel?.unsubscribe();
    super.dispose();
  }

  Future<void> _subscribe() async {
    final profId =
        widget.professionalId ?? Supabase.instance.client.auth.currentUser?.id;
    if (profId == null) return;
    _channel = await _service.subscribeToSlots(
      professionalId: profId,
      onChanged: _loadSlots,
    );
  }

  Future<void> _loadSlots() async {
    setState(() => _loading = true);
    final profId =
        widget.professionalId ?? Supabase.instance.client.auth.currentUser?.id;
    if (profId == null) {
      setState(() => _loading = false);
      return;
    }
    final from = DateTime.now();
    final to = from.add(const Duration(days: 28));
    final slots = await _service.fetchSlots(
      professionalId: profId,
      from: from,
      to: to,
    );
    setState(() {
      _slots = slots;
      _loading = false;
    });
  }

  Future<void> _generateSlotsNextWeeks() async {
    final profId =
        widget.professionalId ?? Supabase.instance.client.auth.currentUser?.id;
    if (profId == null) return;
    setState(() => _loading = true);

    final startDate = DateTime.now();
    final endDate = startDate.add(const Duration(days: 28));

    // iterate days and create slots where weekday enabled
    int created = 0;
    for (
      var d = startDate;
      d.isBefore(endDate);
      d = d.add(const Duration(days: 1))
    ) {
      final weekday = d.weekday; // 1..7
      if (!(_weekdayEnabled[weekday] ?? false)) continue;
      final dayStart = DateTime(
        d.year,
        d.month,
        d.day,
        _start.hour,
        _start.minute,
      );
      final dayEnd = DateTime(d.year, d.month, d.day, _end.hour, _end.minute);
      if (!dayEnd.isAfter(dayStart)) continue;
      final count = await _service.createSlotsBetween(
        professionalId: profId,
        start: dayStart.toUtc(),
        end: dayEnd.toUtc(),
        slotMinutes: _slotMinutes,
      );
      created += count as int;
    }

    await _loadSlots();
    setState(() => _loading = false);
    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('Slots creados: $created')));
  }

  Widget _weekdayToggle(int day, String label) {
    final enabled = _weekdayEnabled[day] ?? false;
    return FilterChip(
      label: Text(label),
      selected: enabled,
      onSelected: (v) => setState(() => _weekdayEnabled[day] = v),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Mi Disponibilidad')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Días de trabajo',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: [
                _weekdayToggle(1, 'Lun'),
                _weekdayToggle(2, 'Mar'),
                _weekdayToggle(3, 'Mié'),
                _weekdayToggle(4, 'Jue'),
                _weekdayToggle(5, 'Vie'),
                _weekdayToggle(6, 'Sáb'),
                _weekdayToggle(7, 'Dom'),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _timePicker(
                    'Inicio',
                    _start,
                    (t) => setState(() => _start = t),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _timePicker(
                    'Fin',
                    _end,
                    (t) => setState(() => _end = t),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                const Text('Duración:'),
                const SizedBox(width: 8),
                DropdownButton<int>(
                  value: _slotMinutes,
                  items: const [15, 30, 45, 60]
                      .map(
                        (m) =>
                            DropdownMenuItem(value: m, child: Text('$m min')),
                      )
                      .toList(),
                  onChanged: (v) => setState(() => _slotMinutes = v ?? 30),
                ),
                const Spacer(),
                ElevatedButton.icon(
                  onPressed: _loading ? null : _generateSlotsNextWeeks,
                  icon: const Icon(Icons.playlist_add),
                  label: const Text('Generar 4 semanas'),
                ),
              ],
            ),
            const SizedBox(height: 20),
            const Text(
              'Próximos slots',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            if (_loading)
              const Center(child: CircularProgressIndicator())
            else
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _slots.length,
                separatorBuilder: (_, i) => const Divider(),
                itemBuilder: (context, i) {
                  final s = _slots[i];
                  return ListTile(
                    title: Text('${s.start.toLocal()} - ${s.end.toLocal()}'),
                    subtitle: Text(
                      s.isAvailable ? 'Disponible' : 'Ocupado/Blocked',
                    ),
                    trailing: Switch(
                      value: s.isAvailable,
                      onChanged: (v) async {
                        await _service.updateSlotAvailability(
                          slotId: s.id,
                          isAvailable: v,
                        );
                        await _loadSlots();
                      },
                    ),
                  );
                },
              ),
          ],
        ),
      ),
    );
  }

  Widget _timePicker(
    String label,
    TimeOfDay value,
    void Function(TimeOfDay) onChanged,
  ) {
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
