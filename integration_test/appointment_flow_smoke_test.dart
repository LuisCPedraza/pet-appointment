import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:pet_appointment/models/appointment_model.dart';
import 'package:pet_appointment/screens/appointment_confirm_screen.dart';
import 'package:pet_appointment/widgets/app_shell.dart';

Future<void> main() async {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('es_ES', null);

  testWidgets('muestra la confirmación de cita y cambia a historial', (
    tester,
  ) async {
    AppShell.tabIndexNotifier.value = 0;

    final appointment = AppointmentModel(
      id: 'appt-1',
      clientId: 'client-1',
      clientEmail: 'carlo@example.com',
      petId: 'pet-1',
      professionalId: 'prof-1',
      serviceId: 'service-1',
      status: 'En espera',
      notes: 'Corte completo',
      createdAt: DateTime.utc(2026, 5, 24, 14, 0),
      availabilityId: 'slot-1',
      clientName: 'Carlo',
      professionalName: 'Dra. Ana',
      petName: 'Luna',
      petSpecies: 'Perro',
      serviceName: 'Baño y corte',
      scheduledAt: DateTime.utc(2026, 5, 25, 16, 30),
    );

    await tester.pumpWidget(
      MaterialApp(
        routes: {
          '/home': (_) => const Scaffold(body: Text('Home placeholder')),
        },
        home: AppointmentConfirmScreen(appointment: appointment),
      ),
    );

    expect(
      find.text('¡Tu cita ha sido\nagendada exitosamente!'),
      findsOneWidget,
    );
    expect(find.text('Baño y corte'), findsWidgets);
    expect(find.text('Luna'), findsWidgets);

    await tester.ensureVisible(find.text('Ver mis citas'));
    await tester.tap(find.text('Ver mis citas'));
    await tester.pumpAndSettle();

    expect(AppShell.tabIndexNotifier.value, 3);
    expect(find.text('Home placeholder'), findsOneWidget);
  });
}
