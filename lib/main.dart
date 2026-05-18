import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'package:pet_appointment/features/features.dart';
import 'package:pet_appointment/widgets/widgets.dart';
import 'package:pet_appointment/config/config.dart';
import 'package:pet_appointment/controllers/professional_agenda_controller.dart';
import 'package:pet_appointment/screens/login_callback_screen.dart';
import 'package:pet_appointment/screens/admin_shell.dart';

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

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final GlobalKey<NavigatorState> _navigatorKey = GlobalKey<NavigatorState>();

  @override
  void initState() {
    super.initState();
    // Escuchar cambios de autenticación
    Supabase.instance.client.auth.onAuthStateChange.listen((event) {
      if (event.event == AuthChangeEvent.signedIn) {
        // Navegar al home reemplazando la ruta actual
        _navigatorKey.currentState?.pushReplacementNamed('/home');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ProfessionalAgendaController()),
      ],
      child: MaterialApp(
        navigatorKey: _navigatorKey,
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
          '/admin': (_) => const AdminAccessGate(initialIndex: 0),
          '/admin/users': (_) => const AdminAccessGate(initialIndex: 1),
          '/admin/services': (_) => const AdminAccessGate(initialIndex: 2),
          '/admin/reports': (_) => const AdminAccessGate(initialIndex: 3),
          '/edit-profile': (_) => const EditProfileScreen(),
          '/login': (_) => const LoginScreen(),
          '/register': (_) => const RegisterScreen(),
          '/forgot-password': (_) => const ForgotPasswordScreen(),
          '/reset-password': (_) => const ResetPasswordScreen(),
          '/calendar': (_) => const AppShell(initialIndex: 2),
          '/appointments-history': (_) => const AppointmentHistoryScreen(),
          '/professional-home': (_) => const ProfessionalHomeScreen(),
          '/professional-availability': (_) =>
              const ProfessionalAvailabilityScreen(),
          '/login-callback': (_) => const LoginCallbackScreen(),
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
          builder: (context) =>
              AppointmentConfirmScreen(appointment: appointment as dynamic),
        );
      case '/appointments-history':
        return MaterialPageRoute(builder: (context) => const AppShell());
      case '/professional-availability':
        return MaterialPageRoute(
          builder: (context) => const ProfessionalAvailabilityScreen(),
        );
      default:
        // Redirigir a home en lugar de mostrar "ruta no encontrada"
        return MaterialPageRoute(builder: (context) => const AppShell());
    }
  }
}
