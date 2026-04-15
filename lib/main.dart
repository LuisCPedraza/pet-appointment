import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'app/sprint2_app.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final isSupabaseReady = await initializeSupabase();
  runApp(PetAppointmentApp(isSupabaseReady: isSupabaseReady));
}

Future<bool> initializeSupabase() async {
  const supabaseUrl = String.fromEnvironment('SUPABASE_URL');
  const supabaseAnonKey = String.fromEnvironment('SUPABASE_ANON_KEY');

  if (supabaseUrl.isEmpty || supabaseAnonKey.isEmpty) {
    debugPrint(
      'Supabase no configurado: define SUPABASE_URL y SUPABASE_ANON_KEY para habilitar backend.',
    );
    return false;
  }

  await Supabase.initialize(url: supabaseUrl, anonKey: supabaseAnonKey);
  return true;
}
