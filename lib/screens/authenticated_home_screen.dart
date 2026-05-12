import 'package:flutter/material.dart';
import 'package:pet_appointment/config/theme.dart';
import 'package:pet_appointment/widgets/app_logo_title.dart';
import 'package:pet_appointment/widgets/app_shell.dart';

/// Pantalla principal autenticada temporal mientras se completa el dashboard.
class AuthenticatedHomeScreen extends StatelessWidget {
  const AuthenticatedHomeScreen({super.key, required this.name});

  final String name;

  String get _firstName => name.split(' ').first;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        title: const AppLogoTitle(iconSize: 26),
        titleSpacing: 16,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: _AuthenticatedHomeContent(firstName: _firstName),
        ),
      ),
    );
  }
}

class _AuthenticatedHomeContent extends StatelessWidget {
  const _AuthenticatedHomeContent({required this.firstName});

  final String firstName;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const _ConstructionCircle(),
        const SizedBox(height: 32),
        _Greeting(firstName: firstName),
        const SizedBox(height: 12),
        const _MainMessage(),
        const SizedBox(height: 8),
        const _SupportMessage(),
        const SizedBox(height: 48),
        _AppointmentsButton(onPressed: () => AppShell.selectTab(3)),
        const SizedBox(height: 24),
        const _ConstructionBadge(),
      ],
    );
  }
}

class _ConstructionCircle extends StatelessWidget {
  const _ConstructionCircle();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 120,
      height: 120,
      decoration: BoxDecoration(
        color: AppColors.primaryContainer.withValues(alpha: 0.3),
        shape: BoxShape.circle,
      ),
      child: const Icon(
        Icons.construction_rounded,
        size: 56,
        color: AppColors.primary,
      ),
    );
  }
}

class _Greeting extends StatelessWidget {
  const _Greeting({required this.firstName});

  final String firstName;

  @override
  Widget build(BuildContext context) {
    return Text(
      '¡Hola, $firstName! 👋',
      style: const TextStyle(
        fontFamily: AppFonts.primary,
        fontWeight: FontWeight.w800,
        fontSize: 28,
        color: AppColors.onSurface,
      ),
      textAlign: TextAlign.center,
    );
  }
}

class _MainMessage extends StatelessWidget {
  const _MainMessage();

  @override
  Widget build(BuildContext context) {
    return Text(
      'Aquí estará tu página de inicio.',
      style: const TextStyle(
        fontSize: 17,
        fontWeight: FontWeight.w600,
        color: AppColors.onSurfaceVariant,
      ),
      textAlign: TextAlign.center,
    );
  }
}

class _SupportMessage extends StatelessWidget {
  const _SupportMessage();

  @override
  Widget build(BuildContext context) {
    return Text(
      'Estamos trabajando para darte la mejor experiencia. ¡Vuelve pronto!',
      style: TextStyle(
        fontSize: 14,
        color: AppColors.onSurfaceVariant.withValues(alpha: 0.7),
        height: 1.5,
      ),
      textAlign: TextAlign.center,
    );
  }
}

class _AppointmentsButton extends StatelessWidget {
  const _AppointmentsButton({required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return FilledButton.icon(
      onPressed: onPressed,
      icon: const Icon(Icons.history_edu_outlined),
      label: const Text('Mis citas'),
      style: FilledButton.styleFrom(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      ),
    );
  }
}

class _ConstructionBadge extends StatelessWidget {
  const _ConstructionBadge();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(50),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.25)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.schedule_rounded,
            size: 16,
            color: AppColors.primary,
          ),
          const SizedBox(width: 8),
          Text(
            'En construcción',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: AppColors.primary,
            ),
          ),
        ],
      ),
    );
  }
}
