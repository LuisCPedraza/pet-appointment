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

  /// Actualiza el nombre y teléfono del usuario en Auth y en public.users.
  Future<void> updateProfile({
    required String name,
    required String phone,
  }) async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) throw Exception('No hay sesión activa');

    // 1. Actualizar metadata en auth.users
    await _client.auth.updateUser(
      UserAttributes(data: {'full_name': name, 'phone': phone}),
    );

    // 2. Sincronizar con public.users
    await _client
        .from('users')
        .update({'full_name': name, 'phone': phone})
        .eq('id', userId);
  }
}
