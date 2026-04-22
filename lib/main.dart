import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:pet_appointment/widgets/widgets.dart';
import 'package:pet_appointment/config/config.dart';
import 'package:pet_appointment/screens/register_screen.dart';
import 'package:pet_appointment/screens/login_screen.dart';
import 'package:pet_appointment/screens/forgot_password_screen.dart';
import 'package:pet_appointment/screens/reset_password_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: '.env');
  await _initializeSupabase();
  runApp(const MyApp());
}

Future<void> _initializeSupabase() async {
  final supabaseUrl = dotenv.maybeGet('SUPABASE_URL') ?? '';
  final supabaseAnonKey = dotenv.maybeGet('SUPABASE_ANON_KEY') ?? '';

  if (supabaseUrl.isEmpty || supabaseAnonKey.isEmpty) {
    debugPrint(
      'Supabase no configurado: asegúrate de que .env contiene SUPABASE_URL y SUPABASE_ANON_KEY.',
    );
    return;
  }

  await Supabase.initialize(url: supabaseUrl, anonKey: supabaseAnonKey);
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'PetAppointment',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      home: const AppShell(),
      routes: {
        '/home': (_) => const AppShell(),
        '/login': (_) => const LoginScreen(),
        '/register': (_) => const RegisterScreen(),
        '/forgot-password': (_) => const ForgotPasswordScreen(),
        '/reset-password': (_) => const ResetPasswordScreen(),
      },
    );
  }
}
