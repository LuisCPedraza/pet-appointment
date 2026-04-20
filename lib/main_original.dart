import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'app/sprint2_app.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: '.env');
  final isSupabaseReady = await initializeSupabase();
  runApp(PetAppointmentApp(isSupabaseReady: isSupabaseReady));
}

Future<bool> initializeSupabase() async {
  final supabaseUrl = dotenv.maybeGet('SUPABASE_URL') ?? '';
  final supabaseAnonKey = dotenv.maybeGet('SUPABASE_ANON_KEY') ?? '';

  if (supabaseUrl.isEmpty || supabaseAnonKey.isEmpty) {
    debugPrint(
      'Supabase no configurado: asegúrate de que .env contiene SUPABASE_URL y SUPABASE_ANON_KEY.',
    );
    return false;
  }

  await Supabase.initialize(url: supabaseUrl, anonKey: supabaseAnonKey);
  return true;
}
