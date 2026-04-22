import 'package:flutter/foundation.dart';
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
    // 1. Crear usuario en Auth
    await _client.auth.signUp(
      email: email,
      password: password,
      data: {'full_name': name, 'phone': phone, 'role': 'client'},
    );

    // 2. Insertar registro en tabla users (requiere autenticación)
    // La sesión se crea automáticamente después de signUp
    try {
      await _client.from('users').insert({
        'email': email,
        'full_name': name,
        'phone': phone,
        'role': 'client',
      });
    } catch (e) {
      debugPrint('Error al insertar usuario en tabla users: $e');
      // No re-lanzar para no romper el flujo si la tabla ya tiene el registro
    }
  }

  /// Retorna true si hay una sesión activa (usuario ya autenticado).
  bool get hasActiveSession => _client.auth.currentSession != null;

  /// Nombre del usuario autenticado (del metadata de registro).
  String get currentUserName =>
      _client.auth.currentUser?.userMetadata?['full_name'] as String? ??
      _client.auth.currentUser?.email ??
      'Usuario';

  /// Inicia sesión con email y contraseña.
  /// Lanza [AuthException] si las credenciales son incorrectas.
  Future<void> login({required String email, required String password}) async {
    await _client.auth.signInWithPassword(email: email, password: password);
  }

  /// Cierra la sesión del usuario actual.
  Future<void> logout() async {
    await _client.auth.signOut();
  }

  /// Envía un correo de recuperación con un código OTP de 6 dígitos.
  /// Por seguridad no revela si el correo existe o no: siempre completa sin lanzar.
  /// Lanza [AuthException] únicamente en errores de configuración o red.
  Future<void> sendPasswordResetEmail({required String email}) async {
    await _client.auth.resetPasswordForEmail(email);
  }

  /// Verifica el código OTP de 6 dígitos enviado al correo.
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
}
