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
    final isValid = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    ).hasMatch(v.trim());
    if (!isValid) return 'Correo inválido';
    return null;
  }

  /// Teléfono — no puede estar vacío.
  static String? phone(String? v) {
    if (v == null || v.trim().isEmpty) return 'Ingresa tu teléfono';
    return null;
  }

  /// Contraseña con longitud mínima de 8 caracteres.
  static String? password(String? v) {
    if (v == null || v.isEmpty) return 'Ingresa una contraseña';
    if (v.length < 8) return 'Mínimo 8 caracteres';
    return null;
  }

  /// Confirmación de contraseña — compara contra el valor original.
  ///
  /// Uso:
  ///   validator: FieldValidators.confirmPassword(_passwordController)
  static String? Function(String?) confirmPassword(dynamic passwordController) {
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

  /// Nombre de mascota — mínimo 2 caracteres, máximo 50.
  static String? petName(String? v) {
    if (v == null || v.trim().isEmpty) return 'Ingresa el nombre de la mascota';
    if (v.trim().length < 2)
      return 'El nombre es muy corto (mínimo 2 caracteres)';
    if (v.trim().length > 50)
      return 'El nombre es muy largo (máximo 50 caracteres)';
    return null;
  }

  /// Raza de mascota — máximo 50 caracteres (opcional).
  static String? petBreed(String? v) {
    if (v != null && v.length > 50)
      return 'La raza es muy larga (máximo 50 caracteres)';
    return null;
  }

  /// Peso de mascota — debe ser un número válido entre 0.1 y 300 kg.
  static String? petWeight(String? v) {
    if (v == null || v.trim().isEmpty) return null; // Opcional
    final weight = double.tryParse(v.trim());
    if (weight == null) return 'Ingresa un peso válido';
    if (weight <= 0 || weight > 300)
      return 'El peso debe estar entre 0.1 y 300 kg';
    return null;
  }

  /// Notas de mascota — máximo 500 caracteres (opcional).
  static String? petNotes(String? v) {
    if (v != null && v.length > 500)
      return 'Las notas son muy largas (máximo 500 caracteres)';
    return null;
  }
}
