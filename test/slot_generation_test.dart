import 'package:flutter_test/flutter_test.dart';
import 'package:pet_appointment/utils/slot_generation.dart';

void main() {
  group('Slot generation', () {
    test('buildSlotRanges generates consecutive ranges without overlap', () {
      final ranges = buildSlotRanges(
        start: DateTime.utc(2026, 5, 11, 9, 0),
        end: DateTime.utc(2026, 5, 11, 11, 0),
        slotMinutes: 30,
      );

      expect(ranges, hasLength(4));
      expect(ranges.first.start, DateTime.utc(2026, 5, 11, 9, 0));
      expect(ranges.first.end, DateTime.utc(2026, 5, 11, 9, 30));
      expect(ranges.last.start, DateTime.utc(2026, 5, 11, 10, 30));
      expect(ranges.last.end, DateTime.utc(2026, 5, 11, 11, 0));
    });

    test('buildSlotRanges returns empty for invalid inputs', () {
      expect(
        buildSlotRanges(
          start: DateTime.utc(2026, 5, 11, 11, 0),
          end: DateTime.utc(2026, 5, 11, 9, 0),
          slotMinutes: 30,
        ),
        isEmpty,
      );

      expect(
        buildSlotRanges(
          start: DateTime.utc(2026, 5, 11, 9, 0),
          end: DateTime.utc(2026, 5, 11, 11, 0),
          slotMinutes: 0,
        ),
        isEmpty,
      );
    });
  });
}
