import 'package:flutter/material.dart';

class PetAppointmentApp extends StatelessWidget {
  const PetAppointmentApp({super.key, required this.isSupabaseReady});

  final bool isSupabaseReady;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'PetAppointment - Sprint 2',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF00D2D3)),
        useMaterial3: true,
      ),
      home: Sprint2HomeScreen(isSupabaseReady: isSupabaseReady),
    );
  }
}

class Sprint2HomeScreen extends StatelessWidget {
  const Sprint2HomeScreen({super.key, required this.isSupabaseReady});

  final bool isSupabaseReady;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('PetAppointment - Sprint 2')),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            const Text(
              'Base técnica activa',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 12),
            const Text(
              'Pantalla de respaldo para validar configuración base cuando faltan variables de entorno.',
            ),
            const SizedBox(height: 24),
            Row(
              children: <Widget>[
                Icon(
                  isSupabaseReady ? Icons.check_circle : Icons.warning_amber,
                  color: isSupabaseReady ? Colors.green : Colors.orange,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    isSupabaseReady
                        ? 'Supabase configurado correctamente.'
                        : 'Supabase no configurado. Ejecuta con --dart-define-from-file=.env o define SUPABASE_URL/SUPABASE_ANON_KEY.',
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            const Text('Bosquejo conservado en: lib/sketch/main_sketch.dart'),
          ],
        ),
      ),
    );
  }
}
