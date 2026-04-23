import 'package:flutter/material.dart';
import '../config/theme.dart';

/// Widget reutilizable para mostrar el avatar de una mascota.
///
/// Si hay [photoUrl], muestra la imagen.
/// De lo contrario, muestra un ícono genérico según la [species].
class PetAvatar extends StatelessWidget {
  final String species;
  final String? photoUrl;
  final double size;

  const PetAvatar({
    super.key,
    required this.species,
    this.photoUrl,
    this.size = 48,
  });

  IconData _getSpeciesIcon() {
    switch (species.toLowerCase()) {
      case 'perro':
        return Icons.pets; // Dog icon
      case 'gato':
        return Icons.favorite; // Cat-like icon
      default:
        return Icons.cruelty_free; // Generic animal icon
    }
  }

  @override
  Widget build(BuildContext context) {
    if (photoUrl != null && photoUrl!.isNotEmpty) {
      return ClipOval(
        child: Image.network(
          photoUrl!,
          width: size,
          height: size,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return _buildDefaultAvatar();
          },
          loadingBuilder: (context, child, loadingProgress) {
            if (loadingProgress == null) return child;
            return _buildDefaultAvatar();
          },
        ),
      );
    }

    return _buildDefaultAvatar();
  }

  Widget _buildDefaultAvatar() {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: AppColors.surfaceContainerLow,
      ),
      child: Icon(
        _getSpeciesIcon(),
        size: size * 0.6,
        color: AppColors.primary,
      ),
    );
  }
}
