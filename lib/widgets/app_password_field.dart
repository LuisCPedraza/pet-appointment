import 'package:flutter/material.dart';
import 'package:pet_appointment/config/theme.dart';

/// Campo de contraseña con toggle para mostrar/ocultar el texto.
/// Reutilizable en login, registro, cambio de contraseña, etc.
///
/// Ejemplo de uso:
/// ```dart
/// AppPasswordField(
///   label: 'Contraseña',
///   controller: _passwordController,
///   validator: (v) => v!.length < 6 ? 'Mínimo 6 caracteres' : null,
/// )
/// ```
class AppPasswordField extends StatefulWidget {
  const AppPasswordField({
    super.key,
    required this.label,
    required this.controller,
    required this.validator,
    this.textInputAction = TextInputAction.done,
  });

  final String label;
  final TextEditingController controller;
  final String? Function(String?) validator;
  final TextInputAction textInputAction;

  @override
  State<AppPasswordField> createState() => _AppPasswordFieldState();
}

class _AppPasswordFieldState extends State<AppPasswordField> {
  // El estado del toggle vive aquí dentro, no en la pantalla que lo usa
  bool _obscure = true;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.label,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: AppColors.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 6),
        TextFormField(
          controller: widget.controller,
          obscureText: _obscure,
          textInputAction: widget.textInputAction,
          validator: widget.validator,
          decoration: InputDecoration(
            hintText: '••••••••',
            hintStyle: TextStyle(color: AppColors.outline.withValues(alpha: 0.5)),
            filled: true,
            fillColor: AppColors.surfaceContainerHigh,
            contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(color: AppColors.primary, width: 2),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(color: AppColors.error, width: 1),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(color: AppColors.error, width: 2),
            ),
            suffixIcon: GestureDetector(
              onTap: () => setState(() => _obscure = !_obscure),
              child: Icon(
                _obscure ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                color: AppColors.outline,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
