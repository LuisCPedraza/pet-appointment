import 'package:flutter/material.dart';
import '../screens/add_pet_screen.dart';
import '../config/theme.dart';
import '../services/pet_service.dart';
import '../widgets/pet_avatar.dart';

class PetDetailScreen extends StatefulWidget {
  const PetDetailScreen({
    super.key,
    required this.pet,
    required this.lastAppointmentAt,
  });

  final Pet pet;
  final DateTime? lastAppointmentAt;

  @override
  State<PetDetailScreen> createState() => _PetDetailScreenState();
}

class _PetDetailScreenState extends State<PetDetailScreen> {
  final _petService = PetService();
  late Pet _pet;
  late DateTime? _lastAppointmentAt;
  bool _didUpdate = false;
  bool _isDeleting = false;

  @override
  void initState() {
    super.initState();
    _pet = widget.pet;
    _lastAppointmentAt = widget.lastAppointmentAt;
  }

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

  Future<void> _openEditPet() async {
    final result = await Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (_) => AddPetScreen(initialPet: _pet)));

    if (!mounted || result == null) return;

    if (result is Pet) {
      setState(() {
        _pet = result;
        _didUpdate = true;
      });
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Mascota actualizada')));
    }
  }

  Future<void> _deletePet() async {
    if (_isDeleting) return;

    setState(() => _isDeleting = true);

    try {
      final activeAppointmentsCount = await _petService
          .getActiveAppointmentsCount(_pet.id);
      if (!mounted) return;

      if (activeAppointmentsCount > 0) {
        await showDialog<void>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('No se puede eliminar'),
            content: Text(
              'Esta mascota tiene $activeAppointmentsCount cita${activeAppointmentsCount == 1 ? '' : 's'} activ${activeAppointmentsCount == 1 ? 'a' : 'as'} en estado "En espera" o "Confirmada". Cancélalas primero para continuar.',
            ),
            actions: [
              FilledButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Entendido'),
              ),
            ],
          ),
        );
        return;
      }

      final confirmed = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Eliminar mascota'),
          content: Text(
            '¿Deseas eliminar a ${_pet.name}? Esta acción no se puede deshacer.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancelar'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(context).pop(true),
              style: FilledButton.styleFrom(backgroundColor: AppColors.error),
              child: const Text('Eliminar'),
            ),
          ],
        ),
      );

      if (confirmed != true || !mounted) return;

      final deleted = await _petService.deletePet(_pet.id);
      if (!mounted) return;

      if (deleted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Mascota eliminada exitosamente')),
        );
        Navigator.of(context).pop(true);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'No fue posible eliminar la mascota. Intenta de nuevo.',
            ),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isDeleting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        Navigator.of(context).pop(_didUpdate);
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Detalle de mascota'),
          centerTitle: true,
          actions: [
            IconButton(
              onPressed: _isDeleting ? null : _deletePet,
              icon: _isDeleting
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.delete_outline),
              tooltip: 'Eliminar',
            ),
            TextButton.icon(
              onPressed: _isDeleting ? null : _openEditPet,
              icon: const Icon(Icons.edit_outlined),
              label: const Text('Editar'),
            ),
          ],
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
                        border: Border.all(
                          color: AppColors.surfaceContainerHigh,
                        ),
                      ),
                      child: PetAvatar(
                        species: _pet.species,
                        photoUrl: _pet.photoUrl,
                        size: 92,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _pet.name,
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
                                icon: _speciesIcon(_pet.species),
                                text: _speciesLabel(_pet.species),
                                color: AppColors.primary,
                              ),
                              _PillChip(
                                icon: Icons.monitor_weight_outlined,
                                text: _weightText(_pet.weight),
                                color: AppColors.secondary,
                              ),
                              _PillChip(
                                icon: Icons.cake_outlined,
                                text: _ageText(_pet.birthDate),
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
                value: (_pet.breed == null || _pet.breed!.isEmpty)
                    ? 'No registrada'
                    : _pet.breed!,
              ),
              _DataCard(
                title: 'Fecha de nacimiento',
                icon: Icons.calendar_month_outlined,
                value: _pet.birthDate == null
                    ? 'No registrada'
                    : _formatDate(_pet.birthDate),
              ),
              _DataCard(
                title: 'Ultima cita',
                icon: Icons.event_available_outlined,
                value: _formatDate(_lastAppointmentAt),
                accent: AppColors.secondary,
              ),
              _DataCard(
                title: 'Notas',
                icon: Icons.sticky_note_2_outlined,
                value: (_pet.notes == null || _pet.notes!.isEmpty)
                    ? 'Sin notas'
                    : _pet.notes!,
                isMultiLine: true,
                accent: AppColors.tertiary,
              ),
            ],
          ),
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
