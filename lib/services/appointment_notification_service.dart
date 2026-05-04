import 'dart:async';

import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:intl/intl.dart';
import 'package:pet_appointment/models/appointment_model.dart';
import 'package:pet_appointment/services/appointment_service.dart';
import 'package:pet_appointment/services/auth_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AppointmentNotificationService {
  AppointmentNotificationService({AppointmentService? appointmentService})
      : _appointmentService = appointmentService ?? AppointmentService();

  final AppointmentService _appointmentService;
  final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();

  RealtimeChannel? _channel;
  final Map<String, String> _lastStatuses = {};
  bool _initialized = false;

  Future<void> start() async {
    if (_initialized) return;

    final authService = AuthService();
    if (!authService.hasActiveSession) return;

    final role = await authService.getCurrentUserRole();
    if (role != 'client') return;

    await _initializePlugin();
    await _primeLastStatuses();

    _channel = _appointmentService.subscribeToClientAppointments(
      onChanged: _handleAppointmentsChanged,
    );

    _initialized = true;
  }

  Future<void> stop() async {
    _channel?.unsubscribe();
    _channel = null;
    _lastStatuses.clear();
    _initialized = false;
  }

  Future<void> _initializePlugin() async {
    const androidSettings = AndroidInitializationSettings('ic_launcher');
    const iosSettings = DarwinInitializationSettings();

    await _notifications.initialize(
      const InitializationSettings(
        android: androidSettings,
        iOS: iosSettings,
      ),
    );

    final androidImpl = _notifications.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    await androidImpl?.requestNotificationsPermission();

    final iosImpl = _notifications.resolvePlatformSpecificImplementation<
      IOSFlutterLocalNotificationsPlugin>();
    await iosImpl?.requestPermissions(alert: true, badge: true, sound: true);
  }

  Future<void> _primeLastStatuses() async {
    final appointments = await _appointmentService.fetchClientAppointments();
    _replaceStatusCache(appointments);
  }

  Future<void> _handleAppointmentsChanged() async {
    final appointments = await _appointmentService.fetchClientAppointments();
    await _notifyOnMeaningfulStatusChanges(appointments);
    _replaceStatusCache(appointments);
  }

  void _replaceStatusCache(List<AppointmentModel> appointments) {
    _lastStatuses
      ..clear()
      ..addEntries(
        appointments.map(
          (appointment) => MapEntry(appointment.id, appointment.status),
        ),
      );
  }

  Future<void> _notifyOnMeaningfulStatusChanges(
    List<AppointmentModel> appointments,
  ) async {
    for (final appointment in appointments) {
      final previousStatus = _lastStatuses[appointment.id];
      final currentStatus = appointment.status;

      if (previousStatus == currentStatus) continue;

      if (currentStatus == 'Confirmada' && previousStatus != null) {
        await _showAppointmentConfirmedNotification(appointment);
      }
    }
  }

  Future<void> _showAppointmentConfirmedNotification(
    AppointmentModel appointment,
  ) async {
    final timeFormatter = DateFormat('d MMM · HH:mm', 'es_ES');
    final scheduledAt = appointment.scheduledAt != null
        ? timeFormatter.format(appointment.scheduledAt!)
        : 'pronto';

    final details = NotificationDetails(
      android: AndroidNotificationDetails(
        'appointment_updates',
        'Actualizaciones de citas',
        channelDescription: 'Notificaciones sobre cambios de estado de citas',
        importance: Importance.high,
        priority: Priority.high,
      ),
      iOS: DarwinNotificationDetails(),
    );

    await _notifications.show(
      appointment.id.hashCode,
      'Tu cita fue confirmada',
      '${appointment.serviceName.isNotEmpty ? appointment.serviceName : 'Cita'} para ${appointment.petName} el $scheduledAt',
      details,
      payload: appointment.id,
    );
  }
}