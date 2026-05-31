import 'package:flutter/material.dart';
import 'package:pet_appointment/config/theme.dart';
import 'package:pet_appointment/screens/admin_dashboard_screen.dart';
import 'package:pet_appointment/screens/admin_reports_screen.dart';
import 'package:pet_appointment/screens/admin_services_screen.dart';
import 'package:pet_appointment/screens/admin_shell_controller.dart';
import 'package:pet_appointment/screens/admin_users_screen.dart';
import 'package:pet_appointment/services/auth_service.dart';

class AdminShell extends StatefulWidget {
  const AdminShell({super.key, this.initialIndex = 0});

  final int initialIndex;

  @override
  State<AdminShell> createState() => _AdminShellState();
}

class _AdminShellState extends State<AdminShell> {
  final _authService = AuthService();
  int _currentIndex = 0;

  static const List<Widget> _screens = [
    AdminDashboardScreen(),
    AdminUsersScreen(),
    AdminServicesScreen(),
    AdminReportsScreen(),
  ];

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    AdminShellController.selectTab(widget.initialIndex);
    AdminShellController.tabIndex.addListener(_syncTabIndex);
  }

  void _syncTabIndex() {
    if (!mounted) return;
    setState(() => _currentIndex = AdminShellController.tabIndex.value);
  }

  Future<void> _logout() async {
    await _authService.logout();
    if (!mounted) return;
    Navigator.of(context).pushNamedAndRemoveUntil('/login', (_) => false);
  }

  void _onDestinationSelected(int index) {
    AdminShellController.selectTab(index);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _currentIndex, children: _screens),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        backgroundColor: Colors.white.withValues(alpha: 0.95),
        indicatorColor: AppColors.primaryContainer,
        onDestinationSelected: _onDestinationSelected,
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.dashboard_outlined),
            selectedIcon: Icon(Icons.dashboard),
            label: 'Dashboard',
          ),
          NavigationDestination(
            icon: Icon(Icons.people_outline),
            selectedIcon: Icon(Icons.people),
            label: 'Usuarios',
          ),
          NavigationDestination(
            icon: Icon(Icons.medical_services_outlined),
            selectedIcon: Icon(Icons.medical_services),
            label: 'Servicios',
          ),
          NavigationDestination(
            icon: Icon(Icons.bar_chart_outlined),
            selectedIcon: Icon(Icons.bar_chart),
            label: 'Reportes',
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _logout,
        icon: const Icon(Icons.logout_rounded),
        label: const Text('Salir'),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }

  @override
  void dispose() {
    AdminShellController.tabIndex.removeListener(_syncTabIndex);
    super.dispose();
  }
}

class AdminAccessGate extends StatefulWidget {
  const AdminAccessGate({super.key, required this.initialIndex});

  final int initialIndex;

  @override
  State<AdminAccessGate> createState() => _AdminAccessGateState();
}

class _AdminAccessGateState extends State<AdminAccessGate> {
  final _authService = AuthService();
  bool _loading = true;
  bool _allowed = false;
  bool _redirectScheduled = false;

  @override
  void initState() {
    super.initState();
    _checkAccess();
  }

  Future<void> _checkAccess() async {
    final hasSession = _authService.hasActiveSession;
    final isAdmin = hasSession && await _authService.isCurrentUserAdmin();

    if (!mounted) return;

    if (isAdmin) {
      setState(() {
        _loading = false;
        _allowed = true;
      });
      return;
    }

    setState(() {
      _loading = false;
      _allowed = false;
    });

    if (_redirectScheduled) return;
    _redirectScheduled = true;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Acceso denegado: se requiere rol admin.'),
          backgroundColor: AppColors.error,
        ),
      );
      Navigator.of(
        context,
      ).pushNamedAndRemoveUntil(hasSession ? '/home' : '/login', (_) => false);
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (!_allowed) {
      return const SizedBox.shrink();
    }

    return AdminShell(initialIndex: widget.initialIndex);
  }
}
