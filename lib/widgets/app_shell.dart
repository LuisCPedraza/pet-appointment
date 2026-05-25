import 'dart:async';

import 'package:flutter/material.dart';
import 'package:pet_appointment/config/config.dart';
import 'package:pet_appointment/features/features.dart';
import 'package:pet_appointment/services/appointment_notification_service.dart';
import 'package:pet_appointment/services/auth_service.dart';
import 'package:pet_appointment/widgets/booking_flow_navigator.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AppShell extends StatefulWidget {
  const AppShell({super.key, this.initialIndex = 0, this.onNotificationTap});

  final int initialIndex;
  final void Function(String appointmentId)? onNotificationTap;
  static final ValueNotifier<int> tabIndexNotifier = ValueNotifier<int>(0);

  static void selectTab(int index) => tabIndexNotifier.value = index;

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  int _currentIndex = 0;
  late final AppointmentNotificationService _notificationService;
  StreamSubscription? _authSubscription;

  // IndexedStack mantiene vivos todos los tabs — el estado no se pierde
  // al cambiar de pestaña (ej. el stack de navegación de Citas se preserva).
  static const List<Widget> _screens = [
    HomeScreen(),
    PetsScreen(),
    BookingFlowNavigator(), // flujo Servicio → Profesional → Calendario
    AppointmentHistoryScreen(),
    ProfileScreen(),
  ];

  // Tabs que requieren sesión activa
  static const _protectedTabs = {1, 2, 3, 4};

  @override
  void initState() {
    super.initState();
    _currentIndex = AppShell.tabIndexNotifier.value;
    if (widget.initialIndex != 0 && widget.initialIndex != _currentIndex) {
      _currentIndex = widget.initialIndex;
      AppShell.tabIndexNotifier.value = widget.initialIndex;
    }
    _notificationService = AppointmentNotificationService(
      onNotificationTap: widget.onNotificationTap,
    );
    _authSubscription = Supabase.instance.client.auth.onAuthStateChange.listen((
      event,
    ) {
      if (event.event == AuthChangeEvent.signedOut) {
        unawaited(_notificationService.stop());
        return;
      }

      if (event.event == AuthChangeEvent.initialSession ||
          event.event == AuthChangeEvent.signedIn ||
          event.event == AuthChangeEvent.tokenRefreshed) {
        unawaited(_restartNotificationService());
      }
    });
    unawaited(_restartNotificationService());
    AppShell.tabIndexNotifier.addListener(_onExternalTabSelected);
  }

  Future<void> _restartNotificationService() async {
    if (!AuthService().hasValidSession) return;

    await _notificationService.stop();
    await _notificationService.start();
  }

  void _onExternalTabSelected() {
    if (!mounted) return;
    setState(() => _currentIndex = AppShell.tabIndexNotifier.value);
  }

  void _onTabSelected(int index) {
    if (_protectedTabs.contains(index) && !AuthService().hasActiveSession) {
      Navigator.of(context).pushNamed('/login');
      return;
    }
    AppShell.selectTab(index);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // IndexedStack muestra solo el tab activo pero mantiene todos en memoria.
      // Ventaja: volver al tab de Citas mantiene en qué pantalla estabas.
      body: IndexedStack(index: _currentIndex, children: _screens),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        backgroundColor: Colors.white.withValues(alpha: 0.9),
        indicatorColor: AppColors.primaryContainer,
        onDestinationSelected: _onTabSelected,
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.pets_outlined),
            selectedIcon: Icon(Icons.pets),
            label: 'Mascotas',
          ),
          NavigationDestination(
            icon: Icon(Icons.calendar_month_outlined),
            selectedIcon: Icon(Icons.calendar_month),
            label: 'Calendario',
          ),
          NavigationDestination(
            icon: Icon(Icons.history_outlined),
            selectedIcon: Icon(Icons.history),
            label: 'Historial',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outlined),
            selectedIcon: Icon(Icons.person),
            label: 'Perfil',
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _authSubscription?.cancel();
    AppShell.tabIndexNotifier.removeListener(_onExternalTabSelected);
    unawaited(_notificationService.stop());
    super.dispose();
  }
}
