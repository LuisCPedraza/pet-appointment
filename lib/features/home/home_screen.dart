import 'package:flutter/material.dart';
import 'package:pet_appointment/features/home/authenticated_home_screen.dart';
import 'package:pet_appointment/services/auth_service.dart';
import 'package:pet_appointment/screens/home/home.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authService = AuthService();

    if (authService.hasActiveSession) {
      return AuthenticatedHomeScreen(name: authService.currentUserName);
    }

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
}
