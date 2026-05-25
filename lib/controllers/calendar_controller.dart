import 'package:flutter/foundation.dart';
import 'dart:async';
import 'package:pet_appointment/models/appointment_model.dart';
import 'package:pet_appointment/models/availability_slot.dart';
import 'package:pet_appointment/models/service_model.dart';
import 'package:pet_appointment/services/appointment_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class CalendarController extends ChangeNotifier {
  final _service = AppointmentService();
  static const int _expectedRealtimeSubscriptions = 3;

  List<Map<String, dynamic>> pets = [];
  List<ServiceModel> services = [];
  List<Map<String, String>> professionals = [];
  String? selectedPetId;
  String? selectedServiceId;
  String? selectedProfessionalId;

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
      selectedProfessionalId != null &&
      selectedSlot != null;

  String? get selectedProfessionalName {
    final id = selectedProfessionalId;
    if (id == null) return null;
    try {
      return professionals.firstWhere(
        (professional) => professional['id'] == id,
      )['full_name'];
    } catch (_) {
      return null;
    }
  }

  RealtimeChannel? _appointmentsChannel;
  RealtimeChannel? _slotsChannel;
  RealtimeChannel? _servicesChannel;
  Timer? _reconnectTimer;
  int _reconnectAttempts = 0;
  int _subscribedChannels = 0;
  bool _reconnectScheduled = false;
  bool _isDisposed = false;
  static const int _maxReconnectAttempts = 5;

  // ─── Inicialización ───────────────────────────────────────────────────────

  Future<void> loadInitialData() async {
    isLoading = true;
    notifyListeners();
    try {
      final results = await Future.wait([
        _service.fetchUserPets(),
        _service.fetchServices(),
        _service.fetchProfessionals(),
      ]);
      pets = results[0] as List<Map<String, dynamic>>;
      services = results[1] as List<ServiceModel>;
      professionals = results[2] as List<Map<String, String>>;
      if (pets.isNotEmpty) selectedPetId = pets.first['id'] as String;
      if (professionals.isNotEmpty) {
        selectedProfessionalId ??= professionals.first['id'];
      }
    } catch (e) {
      debugPrint('loadInitialData error: $e');
      rethrow;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  void subscribeRealtime() {
    unsubscribe();
    _subscribedChannels = 0;
    _appointmentsChannel = _service.subscribeToAllAppointments(
      onChanged: refreshBookedIds,
      autoSubscribe: false,
    );
    _slotsChannel = _service.subscribeToAllSlots(
      onChanged: refreshSlots,
      autoSubscribe: false,
    );
    _servicesChannel = _service.subscribeToServices(
      onChanged: refreshServices,
      autoSubscribe: false,
    );

    _subscribeChannel(
      channel: _appointmentsChannel,
      label: 'appointments',
    );
    _subscribeChannel(channel: _slotsChannel, label: 'slots');
    _subscribeChannel(channel: _servicesChannel, label: 'services');
  }

  void _subscribeChannel({
    required RealtimeChannel? channel,
    required String label,
  }) {
    if (channel == null) return;
    try {
      channel.subscribe((status, error) {
        debugPrint(
          '🔌 Realtime [$label] status=$status${error != null ? ' error=$error' : ''}',
        );
        final ok = status == 'SUBSCRIBED' && error == null;
        if (ok) {
          _subscribedChannels += 1;
          if (_subscribedChannels >= _expectedRealtimeSubscriptions) {
            _resetReconnectState();
          }
          return;
        }

        _scheduleReconnect(label: label, status: status, error: error);
      });
    } catch (e) {
      debugPrint('Error subscribing channel [$label]: $e');
    }
  }

  void _scheduleReconnect({
    required String label,
    required String status,
    Object? error,
  }) {
    if (_reconnectScheduled) return;
    if (_reconnectAttempts >= _maxReconnectAttempts) {
      debugPrint(
        '⛔ Realtime reconnect disabled after $_reconnectAttempts attempts for [$label] (last status: $status${error != null ? ', error: $error' : ''})',
      );
      return;
    }

    _reconnectAttempts += 1;
    final seconds = _reconnectAttempts >= 5 ? 60 : (1 << _reconnectAttempts);
    final delay = Duration(seconds: seconds);
    _reconnectScheduled = true;

    debugPrint(
      '🔁 Realtime reconnect #$_reconnectAttempts for [$label] in ${delay.inSeconds}s (status=$status${error != null ? ', error=$error' : ''})',
    );

    _reconnectTimer?.cancel();
    _reconnectTimer = Timer(delay, () {
      _reconnectScheduled = false;
      if (_isDisposed) return;
      try {
        subscribeRealtime();
      } catch (e) {
        debugPrint('Reconnect attempt failed for [$label]: $e');
      }
    });
  }

  void _resetReconnectState() {
    _reconnectAttempts = 0;
    _reconnectScheduled = false;
    _reconnectTimer?.cancel();
    _reconnectTimer = null;
  }

  void unsubscribe() {
    _reconnectTimer?.cancel();
    _reconnectTimer = null;
    _reconnectScheduled = false;
    _subscribedChannels = 0;
    _appointmentsChannel?.unsubscribe();
    _slotsChannel?.unsubscribe();
    _servicesChannel?.unsubscribe();
  }

  @override
  void dispose() {
    _isDisposed = true;
    unsubscribe();
    super.dispose();
  }

  // ─── Carga de datos ───────────────────────────────────────────────────────

  Future<void> loadMonth(DateTime month) async {
    if (selectedProfessionalId == null) {
      slotsByDay = {};
      bookedIds = {};
      notifyListeners();
      return;
    }

    final from = DateTime(month.year, month.month, 1);
    final to = DateTime(month.year, month.month + 1, 0, 23, 59, 59);
    try {
      final slots = await _service.fetchAllSlots(
        from: from,
        to: to,
        serviceId: selectedServiceId,
        professionalId: selectedProfessionalId,
      );
      final booked = await _service.fetchAllBookedSlotIds(
        from: from,
        to: to,
        professionalId: selectedProfessionalId,
      );
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
    if (selectedProfessionalId == null) return;

    final month = focusedDay;
    final from = DateTime(month.year, month.month, 1);
    final to = DateTime(month.year, month.month + 1, 0, 23, 59, 59);
    try {
      final booked = await _service.fetchAllBookedSlotIds(
        from: from,
        to: to,
        professionalId: selectedProfessionalId,
      );
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
    if (selectedProfessionalId == null) return;

    final month = focusedDay;
    final from = DateTime(month.year, month.month, 1);
    final to = DateTime(month.year, month.month + 1, 0, 23, 59, 59);
    try {
      final slots = await _service.fetchAllSlots(
        from: from,
        to: to,
        serviceId: selectedServiceId,
        professionalId: selectedProfessionalId,
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

  Future<void> refreshServices() async {
    try {
      final updatedServices = await _service.fetchServices();
      services = updatedServices;

      final selectedExists = selectedServiceId == null
          ? true
          : updatedServices.any((svc) => svc.id == selectedServiceId);

      if (!selectedExists) {
        selectedServiceId = null;
        selectedSlot = null;
        selectedDay = null;
        slotsByDay = {};
      }

      notifyListeners();
    } catch (e) {
      debugPrint('refreshServices error: $e');
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

  Future<void> changeProfessional(String? professionalId) async {
    selectedProfessionalId = professionalId;
    selectedSlot = null;
    selectedDay = null;
    if (professionalId == null) {
      slotsByDay = {};
      bookedIds = {};
      notifyListeners();
      return;
    }

    notifyListeners();
    await loadMonth(focusedDay);
  }

  Future<AppointmentModel?> confirm({required String notes}) async {
    isSubmitting = true;
    notifyListeners();
    try {
      final appointment = await _service.createAppointment(
        petId: selectedPetId!,
        professionalId: selectedProfessionalId ?? selectedSlot!.professionalId,
        serviceId: selectedServiceId ?? selectedSlot!.serviceId,
        availabilityId: selectedSlot!.id,
        notes: notes.trim().isEmpty ? null : notes.trim(),
      );

      selectedSlot = null;
      selectedDay = null;
      notifyListeners();
      return appointment;
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
