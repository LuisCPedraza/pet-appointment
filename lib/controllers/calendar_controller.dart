import 'package:flutter/foundation.dart';
import 'package:pet_appointment/models/availability_slot.dart';
import 'package:pet_appointment/models/service_model.dart';
import 'package:pet_appointment/services/appointment_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class CalendarController extends ChangeNotifier {
  final _service = AppointmentService();

  List<Map<String, dynamic>> pets = [];
  List<ServiceModel> services = [];
  String? selectedPetId;
  String? selectedServiceId;

  DateTime focusedDay = DateTime.now();
  DateTime? selectedDay;
  Map<DateTime, List<AvailabilitySlot>> slotsByDay = {};
  Set<String> bookedIds = {};
  AvailabilitySlot? selectedSlot;

  bool isLoading = false;
  bool isSubmitting = false;

  bool get canSubmit =>
      selectedPetId != null &&
      selectedServiceId != null &&
      selectedSlot != null;

  RealtimeChannel? _appointmentsChannel;
  RealtimeChannel? _slotsChannel;

  // ─── Inicialización ───────────────────────────────────────────────────────

  Future<void> loadInitialData() async {
    isLoading = true;
    notifyListeners();
    try {
      final results = await Future.wait([
        _service.fetchUserPets(),
        _service.fetchServices(),
      ]);
      pets = results[0] as List<Map<String, dynamic>>;
      services = results[1] as List<ServiceModel>;
      if (pets.isNotEmpty) selectedPetId = pets.first['id'] as String;
    } catch (e) {
      debugPrint('loadInitialData error: $e');
      rethrow;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  void subscribeRealtime() {
    _appointmentsChannel = _service.subscribeToAllAppointments(
      onChanged: refreshBookedIds,
    );
    _slotsChannel = _service.subscribeToAllSlots(
      onChanged: refreshSlots,
    );
  }

  void unsubscribe() {
    _appointmentsChannel?.unsubscribe();
    _slotsChannel?.unsubscribe();
  }

  // ─── Carga de datos ───────────────────────────────────────────────────────

  Future<void> loadMonth(DateTime month) async {
    final from = DateTime(month.year, month.month, 1);
    final to = DateTime(month.year, month.month + 1, 0, 23, 59, 59);
    try {
      final slots = await _service.fetchAllSlots(
        from: from,
        to: to,
        serviceId: selectedServiceId,
      );
      final booked = await _service.fetchAllBookedSlotIds(from: from, to: to);
      final Map<DateTime, List<AvailabilitySlot>> grouped = {};
      for (final s in slots) {
        final key = DateTime(s.start.year, s.start.month, s.start.day);
        grouped.putIfAbsent(key, () => []).add(s);
      }
      slotsByDay = grouped;
      bookedIds = booked;
      notifyListeners();
    } catch (e) {
      debugPrint('loadMonth error: $e');
    }
  }

  Future<void> refreshBookedIds() async {
    final month = focusedDay;
    final from = DateTime(month.year, month.month, 1);
    final to = DateTime(month.year, month.month + 1, 0, 23, 59, 59);
    try {
      final booked = await _service.fetchAllBookedSlotIds(from: from, to: to);
      bookedIds = booked;
      if (selectedSlot != null && booked.contains(selectedSlot!.id)) {
        selectedSlot = null;
      }
      notifyListeners();
    } catch (e) {
      debugPrint('refreshBookedIds error: $e');
    }
  }

  Future<void> refreshSlots() async {
    final month = focusedDay;
    final from = DateTime(month.year, month.month, 1);
    final to = DateTime(month.year, month.month + 1, 0, 23, 59, 59);
    try {
      final slots = await _service.fetchAllSlots(
        from: from,
        to: to,
        serviceId: selectedServiceId,
      );
      final Map<DateTime, List<AvailabilitySlot>> grouped = {};
      for (final s in slots) {
        final key = DateTime(s.start.year, s.start.month, s.start.day);
        grouped.putIfAbsent(key, () => []).add(s);
      }
      slotsByDay = grouped;
      notifyListeners();
    } catch (e) {
      debugPrint('refreshSlots error: $e');
    }
  }

  // ─── Acciones del usuario ─────────────────────────────────────────────────

  void selectPet(String? petId) {
    selectedPetId = petId;
    notifyListeners();
  }

  void selectSlot(AvailabilitySlot? slot) {
    selectedSlot = slot;
    notifyListeners();
  }

  void selectDay(DateTime day, DateTime focused) {
    selectedDay = day;
    focusedDay = focused;
    selectedSlot = null;
    notifyListeners();
  }

  Future<void> changeService(String? serviceId) async {
    selectedServiceId = serviceId;
    selectedSlot = null;
    selectedDay = null;
    if (serviceId == null) {
      slotsByDay = {};
      notifyListeners();
      return;
    }
    notifyListeners();
    await loadMonth(focusedDay);
  }

  Future<void> confirm({required String notes}) async {
    isSubmitting = true;
    notifyListeners();
    try {
      await _service.createAppointment(
        petId: selectedPetId!,
        professionalId: selectedSlot!.professionalId,
        serviceId: selectedServiceId ?? selectedSlot!.serviceId,
        availabilityId: selectedSlot!.id,
        notes: notes.trim().isEmpty ? null : notes.trim(),
      );
      selectedSlot = null;
      selectedDay = null;
      notifyListeners();
    } finally {
      isSubmitting = false;
      notifyListeners();
    }
  }

  // ─── Helpers ──────────────────────────────────────────────────────────────

  List<AvailabilitySlot> slotsForDay(DateTime? day) {
    if (day == null) return [];
    final key = DateTime(day.year, day.month, day.day);
    return (slotsByDay[key] ?? []).where((s) => !s.isPast).toList();
  }
}
