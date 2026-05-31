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
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 88,
              height: 88,
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.event_note,
                size: 42,
                color: Colors.blue.shade400,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'No hay citas agendadas',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w700,
                color: Colors.grey.shade800,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'La agenda está lista para mostrar consultas, cambios de estado y la vista semanal en cuanto entren nuevas reservas.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.grey.shade600,
                height: 1.4,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Text(
                'Tip para pantallazo: entra a Mi disponibilidad y confirma que el profesional ya tiene slots cargados.',
                style: Theme.of(
                  context,
                ).textTheme.bodySmall?.copyWith(color: Colors.grey.shade700),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Weekly/day/compact components moved to professional_home_weekly.dart
