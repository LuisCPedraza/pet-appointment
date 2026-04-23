import 'dart:typed_data';

import 'package:supabase_flutter/supabase_flutter.dart';

/// Maneja toda la comunicación con Supabase Auth.
/// La pantalla no sabe cómo funciona Supabase, solo llama métodos de aquí.
class AuthService {
  // Acceso al cliente de Supabase (ya inicializado en main.dart)
  final _client = Supabase.instance.client;

  /// Registra un nuevo usuario.
  /// Lanza [AuthException] si Supabase rechaza la solicitud
  /// (email duplicado, contraseña débil, etc.).
  Future<void> register({
    required String email,
    required String password,
    required String name,
    required String phone,
  }) async {
    // Crea el usuario en Auth. El trigger on_auth_user_created (migración 003)
    // inserta automáticamente la fila en public.users con los metadatos aquí
    // enviados, sin depender de la sesión activa ni de RLS.
    await _client.auth.signUp(
      email: email,
      password: password,
      data: {'full_name': name, 'phone': phone, 'role': 'client'},
    );
  }

  /// Retorna true si hay una sesión activa (usuario ya autenticado).
  bool get hasActiveSession => _client.auth.currentSession != null;

  /// URL de la foto de perfil guardada en metadata.
  String get currentUserPhotoUrl =>
      _client.auth.currentUser?.userMetadata?['photo_url'] as String? ?? '';

  /// Nombre del usuario autenticado (del metadata de registro).
  String get currentUserName =>
      _client.auth.currentUser?.userMetadata?['full_name'] as String? ??
      _client.auth.currentUser?.email ??
      'Usuario';

  /// Inicia sesión y retorna el rol del usuario autenticado.
  /// Valida además que el correo esté confirmado.
  Future<String> login({
    required String email,
    required String password,
  }) async {
    final response = await _client.auth.signInWithPassword(
      email: email,
      password: password,
    );

    final user = response.user ?? _client.auth.currentUser;
    if (user == null) {
      throw const AuthException('No se pudo iniciar sesión. Intenta de nuevo.');
    }

    if (user.emailConfirmedAt == null) {
      await _client.auth.signOut();
      throw const AuthException(
        'Debes confirmar tu correo antes de iniciar sesión. Revisa tu bandeja.',
      );
    }

    return getCurrentUserRole();
  }

  /// Obtiene el rol desde public.users; si falla, intenta metadata y finalmente client.
  Future<String> getCurrentUserRole() async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) return 'client';

    try {
      final response = await _client
          .from('users')
          .select('role')
          .eq('id', userId)
          .maybeSingle();

      final role = response?['role'] as String?;
      if (role != null && role.isNotEmpty) return role;
    } catch (_) {
      // fallback a metadata cuando no se pueda consultar public.users
    }

    return _client.auth.currentUser?.userMetadata?['role'] as String? ??
        'client';
  }

  /// Cierra la sesión del usuario actual.
  Future<void> logout() async {
    await _client.auth.signOut();
  }

  /// Envía un correo de recuperación con un código OTP de 8 dígitos.
  /// Por seguridad no revela si el correo existe o no: siempre completa sin lanzar.
  /// Lanza [AuthException] únicamente en errores de configuración o red.
  Future<void> sendPasswordResetEmail({required String email}) async {
    await _client.auth.resetPasswordForEmail(email);
  }

  /// Verifica el código OTP de 8 dígitos enviado al correo.
  /// Si el código es válido, Supabase establece una sesión temporal de
  /// tipo "recovery" que permite llamar a [updatePassword] a continuación.
  /// Lanza [AuthException] si el código es incorrecto o ha expirado.
  Future<void> verifyRecoveryOtp({
    required String email,
    required String otp,
  }) async {
    await _client.auth.verifyOTP(
      email: email,
      token: otp,
      type: OtpType.recovery,
    );
  }

  /// Actualiza la contraseña del usuario autenticado con el token de recuperación.
  /// Debe llamarse cuando la sesión ya fue establecida por el deep link.
  Future<void> updatePassword({required String newPassword}) async {
    await _client.auth.updateUser(UserAttributes(password: newPassword));
  }

  /// Correo del usuario autenticado.
  String get currentUserEmail => _client.auth.currentUser?.email ?? '';

  /// Teléfono del usuario autenticado (del metadata de registro).
  String get currentUserPhone =>
      _client.auth.currentUser?.userMetadata?['phone'] as String? ?? '';

  /// Sube la imagen de perfil a Supabase Storage y retorna su URL pública.
  Future<String> uploadProfilePhoto({
    required Uint8List bytes,
    required String extension,
  }) async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) throw Exception('No hay sesión activa');

    final safeExtension = extension.isEmpty ? 'jpg' : extension.toLowerCase();
    final objectPath =
        '$userId/avatar_${DateTime.now().millisecondsSinceEpoch}.$safeExtension';

    await _client.storage
        .from('profile-photos')
        .uploadBinary(
          objectPath,
          bytes,
          fileOptions: const FileOptions(upsert: true),
        );

    return _client.storage.from('profile-photos').getPublicUrl(objectPath);
  }

  /// Actualiza el nombre, teléfono y opcionalmente foto en Auth y public.users.
  Future<void> updateProfile({
    required String name,
    required String phone,
    String? photoUrl,
  }) async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) throw Exception('No hay sesión activa');

    final metadata = <String, dynamic>{'full_name': name, 'phone': phone};
    if (photoUrl != null && photoUrl.isNotEmpty) {
      metadata['photo_url'] = photoUrl;
    }

    // 1. Actualizar metadata en auth.users
    await _client.auth.updateUser(UserAttributes(data: metadata));

    // 2. Sincronizar con public.users
    final payload = <String, dynamic>{'full_name': name, 'phone': phone};
    if (photoUrl != null && photoUrl.isNotEmpty) {
      payload['photo_url'] = photoUrl;
    }

    await _client.from('users').update(payload).eq('id', userId);
  }
}
