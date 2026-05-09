import 'package:flutter/material.dart';
import 'package:pet_appointment/config/theme.dart';

/// Encabezado de la pantalla de agendamiento.
class BookingHeading extends StatelessWidget {
  const BookingHeading({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Nueva Cita',
            style: TextStyle(
              fontFamily: AppFonts.primary,
              fontWeight: FontWeight.w800,
              fontSize: 28,
              color: AppColors.onSurface,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Agenda una sesion de cuidado para tu companero.',
            style: TextStyle(fontSize: 14, color: AppColors.onSurfaceVariant),
          ),
        ],
      ),
    );
  }
}
