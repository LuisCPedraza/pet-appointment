import 'package:flutter/material.dart';
import 'package:pet_appointment/config/theme.dart';

/// Título del AppBar con el logo de la app (ícono + nombre).
/// Reutilizable en todas las pantallas que muestran la marca.
class AppLogoTitle extends StatelessWidget {
  const AppLogoTitle({super.key, this.iconSize = 28});

  final double iconSize;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(Icons.pets, color: AppColors.primary, size: iconSize),
        const SizedBox(width: 8),
        Text(
          'Pet Sanctuary',
          style: TextStyle(
            fontFamily: AppFonts.primary,
            fontWeight: FontWeight.w800,
            fontSize: 18,
            color: AppColors.primary,
          ),
        ),
      ],
    );
  }
}
