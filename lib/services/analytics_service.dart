import 'dart:async';

import 'package:supabase_flutter/supabase_flutter.dart';

/// Servicio ligero de analítica y reporte de errores que almacena eventos
/// en Supabase. Está pensado como instrumentación mínima para la entrega.
class AnalyticsService {
  static final _client = Supabase.instance.client;

  /// Inicialización ligera (placeholder si se necesita más configuración).
  static void init() {
    // No-op por ahora: el cliente Supabase ya se inicializa en main.
  }

  /// Registra un evento genérico en la tabla `app_events`.
  static Future<void> logEvent(
    String name, [
    Map<String, dynamic>? params,
  ]) async {
    try {
      await _client.from('app_events').insert({
        'event_name': name,
        'payload': params ?? {},
        'created_at': DateTime.now().toUtc().toIso8601String(),
      });
    } catch (_) {
      // Silenciar errores de telemetría para no romper la app si la tabla no existe.
    }
  }

  /// Registra un error/stack en la tabla `crash_reports`.
  static Future<void> logError(
    Object error,
    StackTrace? stack, {
    bool fatal = false,
  }) async {
    try {
      await _client.from('crash_reports').insert({
        'error_message': error.toString(),
        'stack': stack?.toString() ?? '',
        'fatal': fatal,
        'created_at': DateTime.now().toUtc().toIso8601String(),
      });
    } catch (_) {
      // No interrumpir la ejecución si no se puede almacenar el reporte
    }
  }

  /// Evento conveniente para apertura de app
  static Future<void> logAppOpen() => logEvent('open_app');
}
