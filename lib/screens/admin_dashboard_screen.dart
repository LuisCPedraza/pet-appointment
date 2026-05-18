import 'package:flutter/material.dart';
import 'package:pet_appointment/config/theme.dart';
import 'package:pet_appointment/services/appointment_service.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  final _service = AppointmentService();
  bool _loading = true;
  // String? _errorMessage; // removed (unused)
  int _todayAppointments = 0;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    if (mounted) {
      setState(() {
        _loading = true;
      });
    }

    try {
      final now = DateTime.now();
      final from = DateTime(now.year, now.month, now.day);
      final to = DateTime(now.year, now.month, now.day, 23, 59, 59, 999);
      final summary = await _service.fetchAppointmentReportSummary(
        from: from,
        to: to,
      );
      if (mounted) {
        setState(() {
          _todayAppointments = summary['total'] ?? 0;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          // ignore: avoid_print
          debugPrint('Error cargando indicador de hoy: $e');
        });
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Administración'), centerTitle: true),
      body: RefreshIndicator(
        onRefresh: _load,
        child: ListView(
          padding: const EdgeInsets.all(12),
          children: [
            Card(
              elevation: 0,
              color: AppColors.primary.withValues(alpha: 0.06),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  vertical: 12,
                  horizontal: 14,
                ),
                child: Row(
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: AppColors.primaryContainer,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.dashboard_customize,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Panel principal del admin',
                            style: Theme.of(context).textTheme.titleMedium
                                ?.copyWith(fontWeight: FontWeight.w800),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Gestiona usuarios, servicios y reportes desde un solo lugar.',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    if (_loading)
                      const SizedBox(
                        width: 48,
                        height: 48,
                        child: Center(child: CircularProgressIndicator()),
                      )
                    else
                      _TodayMetric(count: _todayAppointments),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
            LayoutBuilder(
              builder: (context, constraints) {
                final columns = constraints.maxWidth >= 900
                    ? 3
                    : constraints.maxWidth >= 600
                    ? 2
                    : 1;

                // Ajuste dinámico para evitar overflow en móvil y mantener compacidad.
                final ratio = columns == 1 ? 1.95 : (columns == 2 ? 1.45 : 1.2);
                return GridView.count(
                  crossAxisCount: columns,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                  childAspectRatio: ratio,
                  children: [
                    _ActionCard(
                      icon: Icons.people_outline,
                      title: 'Usuarios',
                      subtitle: 'Roles y estado de cuentas.',
                      color: AppColors.primary,
                      onTap: () =>
                          Navigator.of(context).pushNamed('/admin/users'),
                    ),
                    _ActionCard(
                      icon: Icons.medical_services_outlined,
                      title: 'Servicios',
                      subtitle: 'Catálogo, precio, duración y activación.',
                      color: AppColors.secondary,
                      onTap: () =>
                          Navigator.of(context).pushNamed('/admin/services'),
                    ),
                    _ActionCard(
                      icon: Icons.bar_chart_rounded,
                      title: 'Reportes',
                      subtitle: 'Citas por estado, profesional y servicio.',
                      color: AppColors.tertiary,
                      onTap: () =>
                          Navigator.of(context).pushNamed('/admin/reports'),
                    ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _TodayMetric extends StatelessWidget {
  const _TodayMetric({required this.count});

  final int count;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 58,
          height: 58,
          decoration: BoxDecoration(
            color: AppColors.primaryContainer,
            borderRadius: BorderRadius.circular(18),
          ),
          child: const Icon(Icons.today_rounded, color: Colors.white),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Citas de hoy',
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 4),
              Text(
                '$count cita${count == 1 ? '' : 's'} programada${count == 1 ? '' : 's'} para hoy.',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ],
          ),
        ),
        Text(
          '$count',
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
            color: AppColors.primary,
            fontWeight: FontWeight.w800,
          ),
        ),
      ],
    );
  }
}

class _ActionCard extends StatelessWidget {
  const _ActionCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(icon, color: color),
              ),
              const SizedBox(height: 8),
              Text(
                title,
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
              ),
              Text(subtitle, style: Theme.of(context).textTheme.bodyMedium),
              Align(
                alignment: Alignment.centerRight,
                child: Icon(Icons.arrow_forward_rounded, color: color),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
