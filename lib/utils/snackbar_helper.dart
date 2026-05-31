import 'package:flutter/material.dart';
import 'package:pet_appointment/config/theme.dart';

/// Muestra un [SnackBar] flotante con esquinas redondeadas.
///
/// Uso de error:   showAppSnackBar(context, 'Algo salió mal', color: AppColors.error);
/// Uso de éxito:   showAppSnackBar(context, 'Guardado', color: AppColors.secondary);
void showAppSnackBar(
  BuildContext context,
  String message, {
  Color? color,
}) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(message),
      backgroundColor: color ?? AppColors.secondary,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
    ),
  );
}
