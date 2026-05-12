import 'package:flutter/material.dart';
// Imports for daily/weekly views moved to their dedicated files when needed

/// =============================================
/// lib/screens/professional_home/professional_home_widgets.dart
/// Descripción: Widgets extraídos de la agenda del profesional para mantener la pantalla principal más corta.
/// Responsabilidad: Renderizar la vista diaria, semanal y sus estados auxiliares sin cambiar el comportamiento.
/// =============================================

class ProfessionalHomeEmptyState extends StatelessWidget {
  const ProfessionalHomeEmptyState({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.event_note, size: 64, color: Colors.grey.shade400),
          const SizedBox(height: 16),
          Text(
            'No hay citas agendadas',
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(color: Colors.grey.shade600),
          ),
          const SizedBox(height: 8),
          Text(
            'Las citas aparecerán aquí',
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(color: Colors.grey.shade500),
          ),
        ],
      ),
    );
  }
}

// Weekly/day/compact components moved to professional_home_weekly.dart
