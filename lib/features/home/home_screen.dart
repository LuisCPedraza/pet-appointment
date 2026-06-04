import 'package:flutter/material.dart';
import 'package:pet_appointment/features/home/authenticated_home_screen.dart';
import 'package:pet_appointment/services/auth_service.dart';
import 'package:pet_appointment/screens/home/home.dart';
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

    return const AuthenticatedHomeScreen();
  }
}
