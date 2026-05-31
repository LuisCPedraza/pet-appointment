import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:pet_appointment/services/push_token_service.dart';

typedef OnOpenAppCallback = Future<void> Function(String appointmentId);

/// Handler para mensajes en background (debe ser top-level).
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  try {
    await Firebase.initializeApp();
  } catch (_) {}
  debugPrint('Background message received: ${message.messageId}');
}

class FcmService {
  FcmService._();
  static final FcmService _instance = FcmService._();
  factory FcmService() => _instance;
  FirebaseMessaging? _messaging;
  OnOpenAppCallback? _onOpenApp;

  Future<void> init({OnOpenAppCallback? onOpenApp}) async {
    _onOpenApp = onOpenApp;
    // Intentar inicializar Firebase; si falla, deshabilitamos FCM sin romper la app
    try {
      await Firebase.initializeApp();
      _messaging = FirebaseMessaging.instance;
    } catch (e) {
      debugPrint('Firebase init failed, disabling FCM: $e');
      return;
    }

    // Registrar handler de background
    try {
      FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
    } catch (e) {
      debugPrint('Could not register background handler: $e');
    }

    // Solicitar permisos en iOS/macOS
    if (!kIsWeb && (Platform.isIOS || Platform.isMacOS)) {
      try {
        await _messaging?.requestPermission(
          alert: true,
          badge: true,
          sound: true,
        );
      } catch (e) {
        debugPrint('Error requesting FCM permissions: $e');
      }
    }

    // Obtener token
    try {
      final token = await _messaging?.getToken();
      if (token != null) {
        await _registerToken(token);
      }
    } catch (e) {
      debugPrint('FCM token error: $e');
    }

    // Refrescar token
    _messaging?.onTokenRefresh.listen((token) async {
      await _registerToken(token);
    });

    // Mensajes en foreground
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      debugPrint('Push foreground: ${message.messageId} ${message.data}');
    });

    // Mensajes que abren la app
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      final appointmentId = message.data['appointment_id'] as String?;
      if (appointmentId != null && _onOpenApp != null) {
        _onOpenApp!(appointmentId);
      }
    });
  }

  Future<void> _registerToken(String token) async {
    final platform = _detectPlatform();
    try {
      await PushTokenService().registerDeviceToken(
        token: token,
        platform: platform,
      );
    } catch (e) {
      debugPrint('Error registrando token en Supabase: $e');
    }
  }

  String _detectPlatform() {
    if (kIsWeb) return 'web';
    if (Platform.isAndroid) return 'android';
    if (Platform.isIOS) return 'ios';
    if (Platform.isWindows || Platform.isMacOS || Platform.isLinux) {
      return 'desktop';
    }
    return 'unknown';
  }
}
