import 'package:flutter/material.dart';
import '../../config/theme.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pet-Appointment'),
        centerTitle: true,
      ),
      body: const SingleChildScrollView(
        child: Column(
          children: [
            _HeroSection(),
            _ServicesSection(),
            _StatsSection(),
            _CtaSection(),
            SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}

class _HeroSection extends StatelessWidget {
  const _HeroSection();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Container(
        height: 320,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [AppColors.primary, AppColors.primaryContainer],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(24),
        ),
        child: Stack(
          children: [

            Padding(
              padding: const EdgeInsets.all(28),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text(
                    'El amor se escribe\ncon cuatro patas.',
                    style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                          color: Colors.white,
                          height: 1.2,
                        ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Cuida la salud, el bienestar y la felicidad\nde tu mascota en un solo lugar.',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.white.withOpacity(0.85),
                        ),
                  ),
                  const SizedBox(height: 20),
                  FilledButton.icon(
                    style: FilledButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: AppColors.primary,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 24, vertical: 14),
                      shape: const StadiumBorder(),
                    ),
                    onPressed: () {},
                    icon: const Text(
                      'Comenzar',
                      style: TextStyle(fontWeight: FontWeight.w700),
                    ),
                    label: const Icon(Icons.arrow_forward, size: 18),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ServicesSection extends StatelessWidget {
  const _ServicesSection();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Nuestros Servicios',
                  style: Theme.of(context).textTheme.headlineMedium),
            ],
          ),
          const SizedBox(height: 16),
          // Tarjeta ancha: Veterinary Care
          _ServiceCard(
            icon: Icons.medical_services_outlined,
            title: 'Cuidado veterinario',
            subtitle: 'Conecta con expertos y cuida a tu mascota en segundos.',
            color: AppColors.surfaceContainerLow,
            iconColor: AppColors.primary,
            wide: true,
          ),
          const SizedBox(height: 12),
          // Dos tarjetas pequeñas en fila
          Row(
            children: [
              Expanded(
                child: _ServiceCard(
                  icon: Icons.content_cut_outlined,
                  title: 'Cuidado y peluquería',
                  color: AppColors.secondaryContainer.withOpacity(0.3),
                  iconColor: AppColors.secondary,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _ServiceCard(
                  icon: Icons.pets_outlined,
                  title: 'Perfiles de mascotas',
                  color: AppColors.tertiaryContainer.withOpacity(0.3),
                  iconColor: AppColors.tertiary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}

class _ServiceCard extends StatelessWidget {
  const _ServiceCard({
    required this.icon,
    required this.title,
    this.subtitle,
    required this.color,
    required this.iconColor,
    this.wide = false,
    this.horizontal = false,
  });

  final IconData icon;
  final String title;
  final String? subtitle;
  final Color color;
  final Color iconColor;
  final bool wide;
  final bool horizontal;

  @override
  Widget build(BuildContext context) {
    final iconWidget = Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        color: iconColor,
        shape: BoxShape.circle,
      ),
      child: Icon(icon, color: Colors.white, size: 22),
    );

    final textWidget = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title,
            style: Theme.of(context)
                .textTheme
                .headlineSmall
                ?.copyWith(fontSize: 16)),
        if (subtitle != null) ...[
          const SizedBox(height: 4),
          Text(subtitle!,
              style: Theme.of(context).textTheme.bodyMedium,
              maxLines: 2),
        ]
      ],
    );

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(20),
      ),
      child: horizontal
          ? Row(children: [
              iconWidget,
              const SizedBox(width: 16),
              Expanded(child: textWidget),
            ])
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                iconWidget,
                const SizedBox(height: 16),
                textWidget,
              ],
            ),
    );
  }
}

class _StatsSection extends StatelessWidget {
  const _StatsSection();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        padding: const EdgeInsets.all(28),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withOpacity(0.06),
              blurRadius: 24,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '¿Por qué elegirnos?',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 6),
            Text(
              'Todo lo que tu mascota necesita, en un solo lugar.',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 24),
            const _StatItem(
              icon: Icons.favorite_rounded,
              title: 'Hecho con amor',
              subtitle: 'Diseñado pensando en el bienestar de tu mascota.',
              color: AppColors.primary,
            ),
            const SizedBox(height: 16),
            const _StatItem(
              icon: Icons.calendar_month_rounded,
              title: 'Agenda sin complicaciones',
              subtitle: 'Reserva citas en segundos, desde donde estés.',
              color: AppColors.secondary,
            ),
            const SizedBox(height: 16),
            const _StatItem(
              icon: Icons.shield_rounded,
              title: 'Tu información segura',
              subtitle: 'Datos protegidos y siempre disponibles.',
              color: AppColors.tertiary,
            ),
          ],
        ),
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  const _StatItem({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: color.withOpacity(0.12),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: color, size: 22),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: AppColors.onSurface,
                    ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _CtaSection extends StatelessWidget {
  const _CtaSection();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Container(
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          color: AppColors.onSurface,
          borderRadius: BorderRadius.circular(24),
        ),
        child: Column(
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: AppColors.primaryContainer,
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.surface, width: 4),
              ),
              child: const Icon(Icons.star_rounded,
                  color: AppColors.primary, size: 32),
            ),
            const SizedBox(height: 20),
            Text(
              '¿Listo para consentir a tu\nmejor amigo?',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    color: Colors.white,
                    height: 1.3,
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.primary,
                padding: const EdgeInsets.symmetric(
                    horizontal: 40, vertical: 16),
                shape: const StadiumBorder(),
              ),
              onPressed: () {},
              child: const Text('Unete ahora',
                  style: TextStyle(
                      fontSize: 16, fontWeight: FontWeight.w700)),
            ),
          ],
        ),
      ),
    );
  }
}