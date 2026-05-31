import 'package:flutter/material.dart';
import 'package:pet_appointment/config/theme.dart';

/// Etiqueta de sección con el color primario de la app.
/// Usada encima de los campos dentro de las tarjetas.
class SectionLabel extends StatelessWidget {
  const SectionLabel(this.text, {super.key});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        fontFamily: AppFonts.primary,
        fontWeight: FontWeight.w600,
        fontSize: 13,
        color: AppColors.primary,
      ),
    );
  }
}
