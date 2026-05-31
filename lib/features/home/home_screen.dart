import 'package:flutter/material.dart';
import 'package:pet_appointment/features/home/authenticated_home_screen.dart';
import 'package:pet_appointment/services/auth_service.dart';
import 'package:pet_appointment/screens/admin_shell.dart';
import 'package:pet_appointment/screens/home/home.dart';
import 'package:pet_appointment/features/professional/professional_home_screen.dart';
// duplicate import removed

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _authService = AuthService();

  @override
  Widget build(BuildContext context) {
    if (!_authService.hasActiveSession) {
      return Scaffold(
        appBar: AppBar(title: const Text('Pet-Appointment'), centerTitle: true),
        body: const SingleChildScrollView(
          child: Column(
            children: [
              HomeHeroSection(),
              HomeServicesSection(),
              HomeStatsSection(),
              HomeCtaSection(),
              SizedBox(height: 24),
            ],
          ),
        ),
      );
    }

    // Usuario autenticado: resolver rol antes de decidir la pantalla.
    return FutureBuilder<String>(
      future: _authService.getCurrentUserRole(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        final role = snapshot.data ?? 'client';
        if (role == 'admin') {
          return const AdminAccessGate(initialIndex: 0);
        }
        if (role == 'professional') {
          return const ProfessionalHomeScreen();
        }

        return const AuthenticatedHomeScreen();
      },
    );
  }
}
