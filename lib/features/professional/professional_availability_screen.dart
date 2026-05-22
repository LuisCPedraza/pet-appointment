import 'package:flutter/material.dart';
import 'package:pet_appointment/models/availability_slot.dart';
import 'package:pet_appointment/services/appointment_service.dart';
import 'package:pet_appointment/screens/professional_availability/professional_availability.dart';
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
  int _weeksToGenerate = 4;
  List<AvailabilitySlot> _slots = [];
  DateTime? _selectedSlotDate;
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
    final to = from.add(Duration(days: _weeksToGenerate * 7));
    final slots = await _service.fetchSlots(
      professionalId: profId,
      from: from,
      to: to,
    );

    final availableDays = _extractAvailableDays(slots);
    final selectedDay = _selectedSlotDate;
    final hasSelectedDay =
        selectedDay != null &&
        availableDays.any((day) => _isSameDay(day, selectedDay));

    setState(() {
      _slots = slots;
      _selectedSlotDate = hasSelectedDay
          ? selectedDay
          : (availableDays.isNotEmpty ? availableDays.first : null);
      _loading = false;
    });
  }

  Future<void> _applyConfiguration() async {
    if (_loading) return;
    final profId =
        widget.professionalId ?? Supabase.instance.client.auth.currentUser?.id;
    if (profId == null) return;
    setState(() => _loading = true);

    final startDate = DateTime.now();
    final endDate = startDate.add(Duration(days: _weeksToGenerate * 7));

    final deleted = await _service.deleteSlotsBetween(
      professionalId: profId,
      from: startDate.toUtc(),
      to: endDate.toUtc(),
    );

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
    final message =
        'Configuración aplicada. Slots actualizados: $created · slots reemplazados: $deleted';
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  List<DateTime> _extractAvailableDays(List<AvailabilitySlot> slots) {
    final days =
        slots
            .map(
              (slot) =>
                  DateTime(slot.start.year, slot.start.month, slot.start.day),
            )
            .toSet()
            .toList()
          ..sort((left, right) => left.compareTo(right));
    return days;
  }

  bool _isSameDay(DateTime left, DateTime right) {
    return left.year == right.year &&
        left.month == right.month &&
        left.day == right.day;
  }

  String _formatDate(DateTime value) {
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
    return '${value.day} de ${monthNames[value.month - 1]} de ${value.year}';
  }

  Future<void> _pickSlotDate(List<DateTime> availableDays) async {
    if (availableDays.isEmpty) return;
    final first = availableDays.first;
    final last = availableDays.last;

    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedSlotDate ?? first,
      firstDate: first,
      lastDate: last,
    );

    if (picked == null) return;
    final matchingDay = availableDays
        .where((day) => _isSameDay(day, picked))
        .toList();
    if (matchingDay.isEmpty) return;

    setState(() {
      _selectedSlotDate = matchingDay.first;
    });
  }

  @override
  Widget build(BuildContext context) {
    final availableDays = _extractAvailableDays(_slots);
    final selectedDay = _selectedSlotDate;
    final selectedSlots = selectedDay == null
        ? _slots
        : _slots.where((slot) => _isSameDay(slot.start, selectedDay)).toList();

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
            ProfessionalAvailabilityWeekdays(
              weekdayEnabled: _weekdayEnabled,
              onToggle: (day, v) => setState(() => _weekdayEnabled[day] = v),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: ProfessionalAvailabilityTimePicker(
                    label: 'Inicio',
                    value: _start,
                    onChanged: (t) => setState(() => _start = t),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ProfessionalAvailabilityTimePicker(
                    label: 'Fin',
                    value: _end,
                    onChanged: (t) => setState(() => _end = t),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ProfessionalAvailabilityControls(
              slotMinutes: _slotMinutes,
              onSlotMinutesChanged: (v) {
                setState(() => _slotMinutes = v);
                _applyConfiguration();
              },
              weeksToGenerate: _weeksToGenerate,
              onWeeksToGenerateChanged: (v) {
                setState(() => _weeksToGenerate = v);
                _loadSlots();
              },
              loading: _loading,
              onGenerate: _applyConfiguration,
            ),
            const SizedBox(height: 20),
            const Text(
              'Próximos slots',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            if (availableDays.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: DropdownButtonFormField<DateTime>(
                            initialValue: selectedDay,
                            decoration: const InputDecoration(
                              labelText: 'Filtrar por fecha',
                              border: OutlineInputBorder(),
                            ),
                            items: availableDays
                                .map(
                                  (day) => DropdownMenuItem<DateTime>(
                                    value: day,
                                    child: Text(_formatDate(day)),
                                  ),
                                )
                                .toList(),
                            onChanged: (value) {
                              setState(() => _selectedSlotDate = value);
                            },
                          ),
                        ),
                        const SizedBox(width: 8),
                        IconButton(
                          tooltip: 'Elegir fecha',
                          onPressed: () => _pickSlotDate(availableDays),
                          icon: const Icon(Icons.calendar_month_outlined),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Mostrando ${selectedSlots.length} slots del día seleccionado.',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
            if (_loading)
              const Center(child: CircularProgressIndicator())
            else
              ProfessionalAvailabilitySlotList(
                slots: selectedSlots,
                updateSlotAvailability: (slotId, available) async {
                  await _service.updateSlotAvailability(
                    slotId: slotId,
                    isAvailable: available,
                  );
                  await _loadSlots();
                },
              ),
          ],
        ),
      ),
    );
  }

  // Helper UI moved to professional_availability_widgets.dart
}
