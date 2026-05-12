import 'package:flutter/material.dart';

/// =============================================
/// lib/screens/appointment_detail/appointment_detail_widgets.dart
/// Descripción: Widgets de presentación usados por la pantalla de detalle de cita.
/// Responsabilidad: Encapsular el header de estado, errores y filas informativas para mantener la pantalla principal más corta.
/// =============================================

class AppointmentDetailStatusHeader extends StatelessWidget {
  const AppointmentDetailStatusHeader({
    super.key,
    required this.status,
    required this.statusColor,
    required this.statusIcon,
  });

  final String status;
  final Color statusColor;
  final IconData statusIcon;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      color: statusColor.withAlpha((0.1 * 255).toInt()),
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: statusColor.withAlpha((0.2 * 255).toInt()),
            ),
            child: Icon(statusIcon, size: 40, color: statusColor),
          ),
          const SizedBox(height: 16),
          Chip(
            label: Text(
              status,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            backgroundColor: statusColor,
          ),
        ],
      ),
    );
  }
}

class AppointmentDetailErrorBanner extends StatelessWidget {
  const AppointmentDetailErrorBanner({super.key, required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.red.withAlpha(26),
        border: Border.all(color: Colors.red),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          const Icon(Icons.error, color: Colors.red),
          const SizedBox(width: 8),
          Expanded(
            child: Text(message, style: const TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}

class AppointmentDetailSectionTitle extends StatelessWidget {
  const AppointmentDetailSectionTitle(this.text, {super.key});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: Theme.of(
        context,
      ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
    );
  }
}

class AppointmentDetailRow extends StatelessWidget {
  const AppointmentDetailRow({
    super.key,
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Colors.grey.shade600),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: Theme.of(
                  context,
                ).textTheme.labelSmall?.copyWith(color: Colors.grey.shade600),
              ),
              Text(
                value,
                style: Theme.of(
                  context,
                ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w500),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
