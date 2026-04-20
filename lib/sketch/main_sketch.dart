import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

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

class AppColors {
  static const Color turquoise = Color(0xFF00D2D3);
  static const Color mint = Color(0xFFB2EBF2);
  static const Color offWhite = Color(0xFFF9FBFB);
  static const Color iceGray = Color(0xFFF0F4F4);
  static const Color petroleum = Color(0xFF2C3E50);
  static const Color coral = Color(0xFFFF7675);
  static const Color sun = Color(0xFFFDCB6E);
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'PetAppointment',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.turquoise,
          primary: AppColors.turquoise,
          secondary: AppColors.mint,
          surface: AppColors.offWhite,
        ),
        scaffoldBackgroundColor: AppColors.offWhite,
        textTheme: TextTheme(
          headlineLarge: GoogleFonts.quicksand(
            fontSize: 24,
            fontWeight: FontWeight.w700,
            color: AppColors.petroleum,
          ),
          headlineSmall: GoogleFonts.quicksand(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: AppColors.petroleum,
          ),
          bodyLarge: GoogleFonts.montserrat(
            fontSize: 16,
            color: AppColors.petroleum,
          ),
          bodyMedium: GoogleFonts.montserrat(
            fontSize: 14,
            color: AppColors.petroleum,
          ),
          labelSmall: GoogleFonts.montserrat(
            fontSize: 12,
            fontWeight: FontWeight.w300,
            color: AppColors.petroleum,
          ),
        ),
        appBarTheme: AppBarTheme(
          backgroundColor: AppColors.offWhite,
          elevation: 0,
          centerTitle: false,
          titleTextStyle: GoogleFonts.quicksand(
            fontSize: 22,
            fontWeight: FontWeight.w700,
            color: AppColors.petroleum,
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: AppColors.iceGray,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide.none,
          ),
        ),
      ),
      home: const WireframeRoot(),
    );
  }
}

class WireframeRoot extends StatefulWidget {
  const WireframeRoot({super.key});

  @override
  State<WireframeRoot> createState() => _WireframeRootState();
}

class _WireframeRootState extends State<WireframeRoot> {
  int _index = 0;

  static const List<Widget> _screens = <Widget>[
    LoginSketchScreen(),
    HomeSketchScreen(),
    BookingSketchScreen(),
    HistorySketchScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_index],
      bottomNavigationBar: NavigationBar(
        backgroundColor: AppColors.offWhite,
        indicatorColor: AppColors.mint,
        selectedIndex: _index,
        onDestinationSelected: (int value) {
          setState(() {
            _index = value;
          });
        },
        destinations: const <NavigationDestination>[
          NavigationDestination(
            icon: Icon(Icons.login_rounded),
            label: 'Login',
          ),
          NavigationDestination(
            icon: Icon(Icons.pets_rounded),
            label: 'Inicio',
          ),
          NavigationDestination(
            icon: Icon(Icons.event_available_rounded),
            label: 'Reserva',
          ),
          NavigationDestination(
            icon: Icon(Icons.history_rounded),
            label: 'Historial',
          ),
        ],
      ),
    );
  }
}

class LoginSketchScreen extends StatelessWidget {
  const LoginSketchScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              'Bienvenido a PetAppointment',
              style: Theme.of(context).textTheme.headlineLarge,
            ),
            const SizedBox(height: 8),
            Text(
              'Ingresa para gestionar citas veterinarias y de grooming.',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 24),
            const _Label('Correo electronico'),
            const SizedBox(height: 8),
            const TextField(
              decoration: InputDecoration(hintText: 'equipo@univalle.edu.co'),
            ),
            const SizedBox(height: 16),
            const _Label('Contrasena'),
            const SizedBox(height: 8),
            const TextField(
              obscureText: true,
              decoration: InputDecoration(hintText: '••••••••'),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.turquoise,
                  foregroundColor: AppColors.petroleum,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                onPressed: () {},
                child: Text(
                  'Iniciar sesion',
                  style: GoogleFonts.quicksand(
                    fontWeight: FontWeight.w700,
                    fontSize: 16,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 14),
            Center(
              child: TextButton(
                onPressed: () {},
                child: Text(
                  'Olvidaste tu contrasena?',
                  style: GoogleFonts.montserrat(
                    color: AppColors.petroleum,
                    fontSize: 12,
                  ),
                ),
              ),
            ),
            const Spacer(),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.iceGray,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Row(
                children: <Widget>[
                  const Icon(Icons.info_outline, color: AppColors.petroleum),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Pantalla de bosquejo para captura: Login',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class HomeSketchScreen extends StatelessWidget {
  const HomeSketchScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: ListView(
          children: <Widget>[
            Text('Inicio', style: Theme.of(context).textTheme.headlineLarge),
            const SizedBox(height: 8),
            Text(
              'Resumen rapido de citas y mascotas.',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: <Color>[AppColors.turquoise, AppColors.mint],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(18),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    'Proxima cita',
                    style: GoogleFonts.quicksand(
                      fontWeight: FontWeight.w700,
                      fontSize: 18,
                      color: AppColors.petroleum,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Luna - Consulta general\nSabado 10:30 AM',
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
            const _SummaryRow(label: 'Mascotas registradas', value: '2'),
            const _SummaryRow(label: 'Citas pendientes', value: '3'),
            const _SummaryRow(label: 'Notificaciones', value: '5'),
            const SizedBox(height: 14),
            Text(
              'Servicios disponibles',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 10),
            const _ServiceChip(
              text: 'Consulta veterinaria',
              color: AppColors.mint,
            ),
            const _ServiceChip(text: 'Bano y secado', color: AppColors.sun),
            const _ServiceChip(text: 'Peluqueria', color: AppColors.iceGray),
          ],
        ),
      ),
    );
  }
}

class BookingSketchScreen extends StatelessWidget {
  const BookingSketchScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: ListView(
          children: <Widget>[
            Text(
              'Reserva de Cita',
              style: Theme.of(context).textTheme.headlineLarge,
            ),
            const SizedBox(height: 8),
            Text(
              'Selecciona mascota, servicio, fecha y horario.',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 16),
            const _Label('Mascota'),
            const SizedBox(height: 8),
            const _FakeDropdown(value: 'Luna (Canina)'),
            const SizedBox(height: 12),
            const _Label('Servicio'),
            const SizedBox(height: 8),
            const _FakeDropdown(value: 'Consulta veterinaria'),
            const SizedBox(height: 12),
            const _Label('Fecha'),
            const SizedBox(height: 8),
            const _FakeDropdown(value: 'Sabado, 13 abril 2026'),
            const SizedBox(height: 12),
            const _Label('Horario'),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: const <Widget>[
                _SlotChip(text: '09:00'),
                _SlotChip(text: '10:30', selected: true),
                _SlotChip(text: '11:00'),
                _SlotChip(text: '14:00'),
              ],
            ),
            const SizedBox(height: 18),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.turquoise,
                  foregroundColor: AppColors.petroleum,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                onPressed: () {},
                child: Text(
                  'Confirmar reserva',
                  style: GoogleFonts.quicksand(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.sun.withAlpha(64),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                'Tip: este bosquejo esta listo para captura de entrega.',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class HistorySketchScreen extends StatelessWidget {
  const HistorySketchScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: ListView(
          children: <Widget>[
            Text(
              'Historial y Agenda',
              style: Theme.of(context).textTheme.headlineLarge,
            ),
            const SizedBox(height: 8),
            Text(
              'Consulta el estado de tus citas recientes.',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 14),
            const _AppointmentCard(
              petName: 'Luna',
              service: 'Consulta general',
              date: '13 abr 2026 - 10:30 AM',
              status: 'Confirmada',
              statusColor: AppColors.turquoise,
            ),
            const _AppointmentCard(
              petName: 'Max',
              service: 'Bano y secado',
              date: '10 abr 2026 - 03:00 PM',
              status: 'Atendida',
              statusColor: AppColors.mint,
            ),
            const _AppointmentCard(
              petName: 'Luna',
              service: 'Peluqueria',
              date: '06 abr 2026 - 09:00 AM',
              status: 'Cancelada',
              statusColor: AppColors.coral,
            ),
          ],
        ),
      ),
    );
  }
}

class _Label extends StatelessWidget {
  const _Label(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: GoogleFonts.quicksand(
        fontWeight: FontWeight.w700,
        color: AppColors.petroleum,
      ),
    );
  }
}

class _FakeDropdown extends StatelessWidget {
  const _FakeDropdown({required this.value});

  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      decoration: BoxDecoration(
        color: AppColors.iceGray,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: <Widget>[
          Expanded(
            child: Text(value, style: Theme.of(context).textTheme.bodyMedium),
          ),
          const Icon(
            Icons.keyboard_arrow_down_rounded,
            color: AppColors.petroleum,
          ),
        ],
      ),
    );
  }
}

class _SlotChip extends StatelessWidget {
  const _SlotChip({required this.text, this.selected = false});

  final String text;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    return Chip(
      label: Text(text),
      backgroundColor: selected ? AppColors.turquoise : AppColors.iceGray,
      labelStyle: GoogleFonts.montserrat(
        color: AppColors.petroleum,
        fontWeight: FontWeight.w600,
      ),
      side: BorderSide.none,
    );
  }
}

class _SummaryRow extends StatelessWidget {
  const _SummaryRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.iceGray,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: <Widget>[
          Expanded(
            child: Text(label, style: Theme.of(context).textTheme.bodyMedium),
          ),
          Text(
            value,
            style: GoogleFonts.quicksand(
              fontWeight: FontWeight.w700,
              fontSize: 18,
              color: AppColors.petroleum,
            ),
          ),
        ],
      ),
    );
  }
}

class _ServiceChip extends StatelessWidget {
  const _ServiceChip({required this.text, required this.color});

  final String text;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: color.withAlpha(128),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(text, style: Theme.of(context).textTheme.bodyMedium),
    );
  }
}

class _AppointmentCard extends StatelessWidget {
  const _AppointmentCard({
    required this.petName,
    required this.service,
    required this.date,
    required this.status,
    required this.statusColor,
  });

  final String petName;
  final String service;
  final String date;
  final String status;
  final Color statusColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.iceGray,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              Expanded(
                child: Text(
                  petName,
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: statusColor.withAlpha(64),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  status,
                  style: GoogleFonts.montserrat(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: AppColors.petroleum,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(service, style: Theme.of(context).textTheme.bodyLarge),
          const SizedBox(height: 2),
          Text(date, style: Theme.of(context).textTheme.labelSmall),
        ],
      ),
    );
  }
}
