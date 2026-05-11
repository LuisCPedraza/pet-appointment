import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pet_appointment/models/availability_slot.dart';
import 'package:pet_appointment/screens/professional_availability_screen.dart';

class FakeChannel {
  void unsubscribe() {}
}

class FakeAppointmentService {
  final List<AvailabilitySlot> _slots = [];
  void Function()? onChangedCallback;

  Future<List<AvailabilitySlot>> fetchSlots({
    required String professionalId,
    required DateTime from,
    required DateTime to,
  }) async {
    return _slots;
  }

  Future<int> createSlotsBetween({
    required String professionalId,
    required DateTime start,
    required DateTime end,
    required int slotMinutes,
    String? serviceId,
  }) async {
    // For tests, create a small predictable set of slots so UI shows items.
    int created = 0;
    var base = start.toLocal();
    for (var i = 0; i < 3; i++) {
      final slotStart = base.add(Duration(minutes: i * slotMinutes));
      final slotEnd = slotStart.add(Duration(minutes: slotMinutes));
      _slots.add(
        AvailabilitySlot(
          id: 'slot-${_slots.length + 1}',
          professionalId: professionalId,
          start: slotStart,
          end: slotEnd,
        ),
      );
      created++;
    }
    // notify
    if (onChangedCallback != null) onChangedCallback!();
    return created;
  }

  Future<void> updateSlotAvailability({
    required String slotId,
    required bool isAvailable,
  }) async {
    final idx = _slots.indexWhere((s) => s.id == slotId);
    if (idx != -1) {
      _slots[idx] = _slots[idx].copyWith(isBooked: !isAvailable);
    }
    if (onChangedCallback != null) onChangedCallback!();
  }

  Future<FakeChannel> subscribeToSlots({
    required String professionalId,
    required void Function() onChanged,
  }) async {
    onChangedCallback = onChanged;
    return FakeChannel();
  }
}

void main() {
  testWidgets('ProfessionalAvailability generates slots and displays them', (
    tester,
  ) async {
    final fake = FakeAppointmentService();
    const profId = 'prof-1';

    // pre-create slots in the fake service so the screen initially shows them
    await fake.createSlotsBetween(
      professionalId: profId,
      start: DateTime.now(),
      end: DateTime.now().add(const Duration(hours: 3)),
      slotMinutes: 30,
    );

    await tester.pumpWidget(
      MaterialApp(
        home: ProfessionalAvailabilityScreen(
          appointmentService: fake,
          professionalId: profId,
        ),
      ),
    );
    await tester.pumpAndSettle();

    // initial state: slots created by fake are shown
    expect(find.byType(ListTile), findsWidgets);
    expect(
      find.textContaining('Slots creados:'),
      findsNothing,
    ); // snack bar may or may not be visible depending on timing
  });
}
