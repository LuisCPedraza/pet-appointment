import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'package:pet_appointment/widgets/widgets.dart';
import 'package:pet_appointment/config/config.dart';
import 'package:pet_appointment/screens/register_screen.dart';
import 'package:pet_appointment/screens/login_screen.dart';
import 'package:pet_appointment/screens/forgot_password_screen.dart';
import 'package:pet_appointment/screens/reset_password_screen.dart';
import 'package:pet_appointment/screens/calendar_screen.dart';
import 'package:pet_appointment/screens/appointment_confirm_screen.dart';
import 'package:pet_appointment/screens/appointment_history_screen.dart';
import 'package:pet_appointment/screens/professional_home_screen.dart';
import 'package:pet_appointment/controllers/professional_agenda_controller.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: '.env');
  await _initializeSupabase();
  await initializeDateFormatting('es_ES', null);
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
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ProfessionalAgendaController()),
      ],
      child: MaterialApp(
        title: 'PetAppointment',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light,
        home: const AppShell(),
        localizationsDelegates: const [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: const [Locale('es', 'ES'), Locale('en', 'US')],
        locale: const Locale('es', 'ES'),
        routes: {
          '/home': (_) => const AppShell(),
          '/login': (_) => const LoginScreen(),
          '/register': (_) => const RegisterScreen(),
          '/forgot-password': (_) => const ForgotPasswordScreen(),
          '/reset-password': (_) => const ResetPasswordScreen(),
          '/calendar': (_) => const CalendarScreen(),
          '/appointments-history': (_) => const AppointmentHistoryScreen(),
          '/professional-home': (_) => const ProfessionalHomeScreen(),
        },
        onGenerateRoute: _generateRoute,
      ),
    );
  }

  /// Generador de rutas dinámicas para pasar argumentos a las pantallas.
  Route<dynamic> _generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case '/appointment-confirm':
        final appointment = settings.arguments;
        return MaterialPageRoute(
          builder: (context) => AppointmentConfirmScreen(
            appointment: appointment as dynamic,
          ),
        );
      case '/appointments-history':
        return MaterialPageRoute(
          builder: (context) => const AppShell(),
        );
      default:
        return MaterialPageRoute(
          builder: (context) => const Scaffold(
            body: Center(child: Text('Ruta no encontrada')),
          ),
        );
    }
  }
}