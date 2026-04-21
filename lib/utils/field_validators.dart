/// Validadores reutilizables para formularios de la app.
///
/// Son funciones puras: reciben un String? y devuelven
/// un mensaje de error (String) o null si es válido.
///
/// Uso directo:
///   validator: FieldValidators.email
///
/// Uso con parámetros:
///   validator: FieldValidators.minLength(8)
class FieldValidators {
  FieldValidators._(); // evita instanciar la clase

  /// Campo obligatorio — no puede estar vacío.
  static String? required(String? v) {
    if (v == null || v.trim().isEmpty) return 'Este campo es requerido';
    return null;
  }

  /// Nombre completo — solo letras y espacios, mínimo 2 caracteres.
  static String? fullName(String? v) {
    if (v == null || v.trim().isEmpty) return 'Ingresa tu nombre';
    if (v.trim().length < 2) return 'El nombre es muy corto';
    return null;
  }

  /// Correo electrónico con formato válido.
  static String? email(String? v) {
    if (v == null || v.trim().isEmpty) return 'Ingresa tu correo';
    final isValid = RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',).hasMatch(v.trim());
    if (!isValid) return 'Correo inválido';
    return null;
  }

  /// Teléfono — no puede estar vacío.
  static String? phone(String? v) {
    if (v == null || v.trim().isEmpty) return 'Ingresa tu teléfono';
    return null;
  }

  /// Contraseña con longitud mínima de 6 caracteres.
  static String? password(String? v) {
    if (v == null || v.isEmpty) return 'Ingresa una contraseña';
    if (v.length < 6) return 'Mínimo 6 caracteres';
    return null;
  }

  /// Confirmación de contraseña — compara contra el valor original.
  ///
  /// Uso:
  ///   validator: FieldValidators.confirmPassword(_passwordController)
  static String? Function(String?) confirmPassword(
    dynamic passwordController,
  ) {
    return (v) {
      if (v != passwordController.text) return 'Las contraseñas no coinciden';
      return null;
    };
  }

  /// Valida que el texto tenga al menos [min] caracteres.
  ///
  /// Uso:
  ///   validator: FieldValidators.minLength(8)
  static String? Function(String?) minLength(int min) {
    return (v) {
      if (v == null || v.length < min) return 'Mínimo $min caracteres';
      return null;
    };
  }
}
