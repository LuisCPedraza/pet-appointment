import 'package:flutter/material.dart';
import '../config/theme.dart';
import '../services/pet_service.dart';
import '../widgets/pet_avatar.dart';

class PetDetailScreen extends StatelessWidget {
  const PetDetailScreen({
    super.key,
    required this.pet,
    required this.lastAppointmentAt,
  });

  final Pet pet;
  final DateTime? lastAppointmentAt;

  String _formatDate(DateTime? date) {
    if (date == null) return 'Sin citas aun';
    final d = date.toLocal();
    return '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';
  }

  String _speciesLabel(String species) {
    if (species.isEmpty) return 'Especie no definida';
    return species[0].toUpperCase() + species.substring(1).toLowerCase();
  }

  String _ageText(DateTime? birthDate) {
    if (birthDate == null) return 'Edad no registrada';
    final now = DateTime.now();
    int years = now.year - birthDate.year;
    if (now.month < birthDate.month ||
        (now.month == birthDate.month && now.day < birthDate.day)) {
      years -= 1;
    }
    if (years <= 0) return 'Menos de 1 ano';
    return years == 1 ? '1 ano' : '$years anos';
  }

  String _weightText(double? weight) {
    if (weight == null) return 'No registrado';
    return '${weight.toStringAsFixed(weight % 1 == 0 ? 0 : 1)} kg';
  }

  IconData _speciesIcon(String species) {
    switch (species.toLowerCase()) {
      case 'perro':
        return Icons.pets;
      case 'gato':
        return Icons.favorite;
      default:
        return Icons.cruelty_free;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detalle de mascota'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFFE8F2FF), Color(0xFFF5F7FA)],
                ),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppColors.surfaceContainerHigh),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.04),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white,
                      border: Border.all(color: AppColors.surfaceContainerHigh),
                    ),
                    child: PetAvatar(
                      species: pet.species,
                      photoUrl: pet.photoUrl,
                      size: 92,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          pet.name,
                          style: Theme.of(
                            context,
                          ).textTheme.headlineMedium?.copyWith(height: 1.1),
                        ),
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: [
                            _PillChip(
                              icon: _speciesIcon(pet.species),
                              text: _speciesLabel(pet.species),
                              color: AppColors.primary,
                            ),
                            _PillChip(
                              icon: Icons.monitor_weight_outlined,
                              text: _weightText(pet.weight),
                              color: AppColors.secondary,
                            ),
                            _PillChip(
                              icon: Icons.cake_outlined,
                              text: _ageText(pet.birthDate),
                              color: AppColors.tertiary,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),
            Padding(
              padding: const EdgeInsets.only(left: 4),
              child: Text(
                'Informacion general',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: AppColors.onSurface,
                ),
              ),
            ),
            const SizedBox(height: 10),
            _DataCard(
              title: 'Raza',
              icon: Icons.pets_outlined,
              value: (pet.breed == null || pet.breed!.isEmpty)
                  ? 'No registrada'
                  : pet.breed!,
            ),
            _DataCard(
              title: 'Fecha de nacimiento',
              icon: Icons.calendar_month_outlined,
              value: pet.birthDate == null
                  ? 'No registrada'
                  : _formatDate(pet.birthDate),
            ),
            _DataCard(
              title: 'Ultima cita',
              icon: Icons.event_available_outlined,
              value: _formatDate(lastAppointmentAt),
              accent: AppColors.secondary,
            ),
            _DataCard(
              title: 'Notas',
              icon: Icons.sticky_note_2_outlined,
              value: (pet.notes == null || pet.notes!.isEmpty)
                  ? 'Sin notas'
                  : pet.notes!,
              isMultiLine: true,
              accent: AppColors.tertiary,
            ),
          ],
        ),
      ),
    );
  }
}

class _PillChip extends StatelessWidget {
  const _PillChip({
    required this.icon,
    required this.text,
    required this.color,
  });

  final IconData icon;
  final String text;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: color.withValues(alpha: 0.25)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 6),
          Text(
            text,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: color,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _DataCard extends StatelessWidget {
  const _DataCard({
    required this.title,
    required this.icon,
    required this.value,
    this.isMultiLine = false,
    this.accent = AppColors.primary,
  });

  final String title;
  final IconData icon;
  final String value;
  final bool isMultiLine;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.surfaceContainerHigh),
      ),
      child: Row(
        crossAxisAlignment: isMultiLine
            ? CrossAxisAlignment.start
            : CrossAxisAlignment.center,
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: accent.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, size: 18, color: accent),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: AppColors.onSurfaceVariant,
                    letterSpacing: 0.6,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  maxLines: isMultiLine ? null : 2,
                  overflow: isMultiLine ? null : TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: AppColors.onSurface,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
