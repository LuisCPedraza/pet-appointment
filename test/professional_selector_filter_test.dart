import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'test_setup.dart';
import 'package:pet_appointment/controllers/calendar_controller.dart';
import 'package:pet_appointment/widgets/calendar/professional_selector_card.dart';

void main() {
  setUpAll(() async => await initTestSupabase());

  testWidgets('El filtro muestra sólo profesionales coincidentes', (
    tester,
  ) async {
    final controller = CalendarController();
    controller.professionals = [
      {'id': 'p1', 'full_name': 'Ana Pérez', 'email': 'ana@example.com'},
      {'id': 'p2', 'full_name': 'Carlos Ruiz', 'email': 'carlos@example.com'},
    ];

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(body: ProfessionalSelectorCard(controller: controller)),
      ),
    );

    await tester.pumpAndSettle();

    // Ambos profesionales visibles inicialmente
    expect(find.text('Ana Pérez'), findsOneWidget);
    expect(find.text('Carlos Ruiz'), findsOneWidget);

    // Escribir "ana" y pulsar el icono de búsqueda
    await tester.enterText(find.byType(TextField), 'ana');
    await tester.tap(find.byIcon(Icons.search));
    await tester.pumpAndSettle();

    expect(find.text('Ana Pérez'), findsOneWidget);
    expect(find.text('Carlos Ruiz'), findsNothing);
  });
}
