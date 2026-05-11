import 'package:flutter/material.dart';

/// Genera rangos de slots consecutivos entre [start] y [end].
/// El rango se recorta para no exceder [end].
List<DateTimeRange> buildSlotRanges({
  required DateTime start,
  required DateTime end,
  required int slotMinutes,
}) {
  if (!end.isAfter(start) || slotMinutes <= 0) {
    return <DateTimeRange>[];
  }

  final ranges = <DateTimeRange>[];
  var cursor = start.toUtc();
  final utcEnd = end.toUtc();

  while (true) {
    final slotStart = cursor;
    final slotEnd = slotStart.add(Duration(minutes: slotMinutes));
    if (slotEnd.isAfter(utcEnd)) break;

    ranges.add(DateTimeRange(start: slotStart, end: slotEnd));
    cursor = slotEnd;
  }

  return ranges;
}
