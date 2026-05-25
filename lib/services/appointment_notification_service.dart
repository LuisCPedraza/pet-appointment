import 'dart:async';

import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:intl/intl.dart';
import 'package:flutter/services.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:pet_appointment/models/appointment_model.dart';
import 'package:pet_appointment/services/appointment_service.dart';
import 'package:pet_appointment/services/auth_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

@pragma('vm:entry-point')
void notificationTapBackground(NotificationResponse response) {
  // El callback de fondo debe ser una función de nivel superior.
  // Aquí solo se recibe el evento de tap cuando la app está en segundo plano.
}

class AppointmentNotificationService {
  AppointmentNotificationService({
    AppointmentService? appointmentService,
    this.onNotificationTap,
  }) : _appointmentService = appointmentService ?? AppointmentService();

  static const _remindersEnabledKey = 'reminders_enabled';
  static final FlutterSecureStorage _secureStorage = FlutterSecureStorage();

  final AppointmentService _appointmentService;
  final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();
  final void Function(String appointmentId)? onNotificationTap;

  RealtimeChannel? _channel;
  final Map<String, String> _lastStatuses = {};
  bool _initialized = false;
  bool? _isClient;
  Future<void>? _startFuture;
  bool _pluginInitialized = false;
  bool _permissionsRequested = false;

  Future<void> start() async {
    if (_initialized) return;
    if (_startFuture != null) {
      await _startFuture;
      return;
    }

    _startFuture = _startInternal();
    try {
      await _startFuture;
    } finally {
      _startFuture = null;
    }
  }

  Future<void> _startInternal() async {
    if (_initialized) return;

    final authService = AuthService();
    if (!authService.hasActiveSession) return;

    final role = await authService.getCurrentUserRole();

    await _initializePlugin();

    if (role == 'client') {
      await _primeLastStatuses(isClient: true);
      _channel = _appointmentService.subscribeToClientAppointments(
        onChanged: _handleAppointmentsChanged,
      );
    } else if (role == 'professional') {
      await _primeLastStatuses(isClient: false);
      _channel = _appointmentService.subscribeToProfessionalAppointments(
        onChanged: _handleAppointmentsChanged,
      );
    } else {
      // Otros roles no reciben notificaciones locales de citas
      return;
    }

    _initialized = true;
  }

  static Future<bool> areRemindersEnabled() async {
    final value = await _secureStorage.read(key: _remindersEnabledKey);
    return value != 'false';
  }

  static Future<void> setRemindersEnabled(bool enabled) async {
    await _secureStorage.write(
      key: _remindersEnabledKey,
      value: enabled ? 'true' : 'false',
    );

    if (!enabled) {
      await _cancelAllScheduledReminders();
    }
  }

  static Future<void> _cancelAllScheduledReminders() async {
    final authService = AuthService();
    final role = await authService.getCurrentUserRole();
    if (role != 'client') return;

    final appointmentService = AppointmentService();
    final upcomingAppointments = await appointmentService
        .fetchUpcomingAppointments(limit: 100);

    final notifications = FlutterLocalNotificationsPlugin();
    for (final appointment in upcomingAppointments) {
      final id = appointment.id.hashCode & 0x7fffffff;
      await notifications.cancel(id);
    }
  }

  Future<void> scheduleAppointmentReminder(AppointmentModel appointment) async {
    if (!await areRemindersEnabled()) return;
    await _initializePlugin();
    await _scheduleAppointmentReminder(appointment);
  }

  Future<void> cancelAppointmentReminder(String appointmentId) async {
    await _initializePlugin();
    await _notifications.cancel(_notificationId(appointmentId));
  }

  Future<void> stop() async {
    _channel?.unsubscribe();
    _channel = null;
    _lastStatuses.clear();
    _isClient = null;
    _initialized = false;
  }

  /// Muestra una notificación local de confirmación inmediata de cita.
  /// Se usa después de que el cliente realiza una reserva exitosa.
  Future<void> showAppointmentConfirmationNotification(
    AppointmentModel appointment,
  ) async {
    await _initializePlugin();
    await _showAppointmentConfirmedNotification(appointment);
  }

  Future<void> _initializePlugin() async {
    if (!_pluginInitialized) {
      const androidSettings = AndroidInitializationSettings('ic_notification');
      const iosSettings = DarwinInitializationSettings();

      await _notifications.initialize(
        const InitializationSettings(
          android: androidSettings,
          iOS: iosSettings,
        ),
        onDidReceiveNotificationResponse: _handleNotificationResponse,
        onDidReceiveBackgroundNotificationResponse: notificationTapBackground,
      );

      _pluginInitialized = true;
    }

    if (_permissionsRequested) {
      tz.initializeTimeZones();
      return;
    }

    final androidImpl = _notifications
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();
    try {
      await androidImpl?.requestNotificationsPermission();
    } on PlatformException catch (error) {
      if (error.code != 'permissionRequestInProgress') {
        rethrow;
      }
    }

    final iosImpl = _notifications
        .resolvePlatformSpecificImplementation<
          IOSFlutterLocalNotificationsPlugin
        >();
    try {
      await iosImpl?.requestPermissions(alert: true, badge: true, sound: true);
    } on PlatformException catch (error) {
      if (error.code != 'permissionRequestInProgress') {
        rethrow;
      }
    }

    _permissionsRequested = true;

    tz.initializeTimeZones();
  }

  void _handleNotificationResponse(NotificationResponse response) {
    final appointmentId = response.payload;
    if (appointmentId?.isNotEmpty == true) {
      onNotificationTap?.call(appointmentId!);
    }
  }

  Future<void> _primeLastStatuses({required bool isClient}) async {
    _isClient = isClient;
    final appointments = isClient
        ? await _appointmentService.fetchClientAppointments()
        : await _appointmentService.fetchProfessionalAppointments();
    _replaceStatusCache(appointments);
  }

  Future<void> _handleAppointmentsChanged() async {
    final appointments = _isClient == true
        ? await _appointmentService.fetchClientAppointments()
        : await _appointmentService.fetchProfessionalAppointments();
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

      if (previousStatus == null &&
          _isClient == false &&
          (currentStatus == 'Confirmada' || currentStatus == 'En espera')) {
        await _showProfessionalNewAppointmentNotification(appointment);
      } else if (currentStatus == 'Confirmada' && previousStatus != null) {
        await _showAppointmentConfirmedNotification(appointment);
        if (_isClient == true) {
          await scheduleAppointmentReminder(appointment);
        }
      } else if (currentStatus == 'En progreso' && previousStatus != null) {
        await _showAppointmentStartedNotification(appointment);
        await cancelAppointmentReminder(appointment.id);
      } else if (currentStatus == 'Atendida' && previousStatus != null) {
        await _showAppointmentCompletedNotification(appointment);
        await cancelAppointmentReminder(appointment.id);
      } else if (currentStatus == 'Cancelada' && previousStatus != null) {
        await _showAppointmentCancelledNotification(appointment);
        await cancelAppointmentReminder(appointment.id);
      }
    }
  }

  Future<void> _showProfessionalNewAppointmentNotification(
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
      _notificationId(appointment.id),
      'Nueva cita agendada',
      '${appointment.clientName} reservó a ${appointment.petName} para ${appointment.serviceName} el $scheduledAt',
      details,
      payload: appointment.id,
    );
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
      _notificationId(appointment.id),
      'Tu cita fue confirmada',
      '${appointment.serviceName.isNotEmpty ? appointment.serviceName : 'Cita'} para ${appointment.petName} el $scheduledAt',
      details,
      payload: appointment.id,
    );
  }

  /// Notificación cuando una cita comienza (estado: En progreso)
  Future<void> _showAppointmentStartedNotification(
    AppointmentModel appointment,
  ) async {
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
      _notificationId(appointment.id),
      'Cita en progreso',
      'La cita de ${appointment.petName} con ${appointment.professionalName} ha comenzado',
      details,
      payload: appointment.id,
    );
  }

  /// Notificación cuando una cita se completa (estado: Atendida)
  Future<void> _showAppointmentCompletedNotification(
    AppointmentModel appointment,
  ) async {
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
      _notificationId(appointment.id),
      'Cita completada',
      'La cita de ${appointment.petName} ha sido completada',
      details,
      payload: appointment.id,
    );
  }

  /// Notificación cuando una cita se cancela (estado: Cancelada)
  Future<void> _showAppointmentCancelledNotification(
    AppointmentModel appointment,
  ) async {
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
      _notificationId(appointment.id),
      'Cita cancelada',
      'La cita de ${appointment.petName} ha sido cancelada',
      details,
      payload: appointment.id,
    );
  }

  int _notificationId(String appointmentId) {
    return appointmentId.hashCode & 0x7fffffff;
  }

  Future<void> _scheduleAppointmentReminder(
    AppointmentModel appointment,
  ) async {
    final scheduledAt = appointment.scheduledAt;
    if (scheduledAt == null) return;

    final reminderTime = scheduledAt.subtract(const Duration(hours: 24));
    final targetTime = reminderTime.isAfter(DateTime.now())
        ? reminderTime
        : (scheduledAt.isAfter(DateTime.now())
              ? DateTime.now().add(const Duration(seconds: 5))
              : null);

    if (targetTime == null) return;

    final timeFormatter = DateFormat('d MMM · HH:mm', 'es_ES');
    final details = NotificationDetails(
      android: AndroidNotificationDetails(
        'appointment_reminders',
        'Recordatorios de citas',
        channelDescription: 'Recordatorios 24 horas antes de la cita',
        importance: Importance.high,
        priority: Priority.high,
      ),
      iOS: DarwinNotificationDetails(),
    );

    await _notifications.zonedSchedule(
      _notificationId(appointment.id),
      'Recordatorio de cita',
      'Recordatorio: ${appointment.petName} - ${appointment.serviceName} con ${appointment.professionalName} el ${timeFormatter.format(scheduledAt)}',
      tz.TZDateTime.from(targetTime.toUtc(), tz.UTC),
      details,
      payload: appointment.id,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
    );
  }
}
