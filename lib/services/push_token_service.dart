import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Gestiona el registro local de tokens de push remoto en Supabase.
///
/// Esta capa no envía notificaciones por sí misma; deja listo el almacenamiento
/// de tokens para que una Edge Function o un backend de mensajería los use.
class PushTokenService {
  PushTokenService({SupabaseClient? client})
    : _client = client ?? Supabase.instance.client;

  final SupabaseClient _client;

  static const _supportedPlatforms = <String>{
    'android',
    'ios',
    'web',
    'desktop',
    'unknown',
  };

  /// Guarda o actualiza el token del dispositivo actual.
  ///
  /// Si el token ya existía, se reasocia al usuario actual y se refresca el
  /// timestamp de última actividad.
  Future<void> registerDeviceToken({
    required String token,
    required String platform,
  }) async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) {
      throw Exception('No hay sesión activa');
    }

    final normalizedPlatform = _normalizePlatform(platform);
    if (!_supportedPlatforms.contains(normalizedPlatform)) {
      throw Exception('Plataforma de push no soportada');
    }

    try {
      await _client.rpc(
        'register_push_device_token',
        params: {
          'p_token': token.trim(),
          'p_platform': normalizedPlatform,
        },
      );
    } catch (e) {
      debugPrint('Error registrando token de push remoto: $e');
      rethrow;
    }
  }

  /// Desactiva todos los tokens del usuario autenticado actual.
  Future<void> deactivateCurrentUserTokens() async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) return;

    try {
      await _client
          .from('push_device_tokens')
          .update({
            'is_active': false,
            'updated_at': DateTime.now().toUtc().toIso8601String(),
          })
          .eq('user_id', userId);
    } catch (e) {
      debugPrint('Error desactivando tokens de push remoto: $e');
    }
  }

  /// Refresca el token para el usuario autenticado si ya existe uno.
  Future<void> touchToken({required String token}) async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) return;

    try {
      await _client
          .from('push_device_tokens')
          .update({
            'last_seen_at': DateTime.now().toUtc().toIso8601String(),
            'updated_at': DateTime.now().toUtc().toIso8601String(),
            'is_active': true,
          })
          .eq('user_id', userId)
          .eq('token', token.trim());
    } catch (e) {
      debugPrint('Error actualizando token de push remoto: $e');
    }
  }

  String _normalizePlatform(String platform) {
    final value = platform.trim().toLowerCase();
    if (value.isEmpty) return 'unknown';
    if (value.contains('android')) return 'android';
    if (value.contains('ios') ||
        value.contains('iphone') ||
        value.contains('ipad')) {
      return 'ios';
    }
    if (value.contains('web')) return 'web';
    if (value.contains('windows') ||
        value.contains('linux') ||
        value.contains('mac')) {
      return 'desktop';
    }
    return 'unknown';
  }
}
