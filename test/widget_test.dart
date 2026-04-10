// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:pet_appointment/main.dart';

void main() {
  testWidgets('Muestra secciones principales del bosquejo', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const MyApp());

    expect(find.text('Bienvenido a PetAppointment'), findsOneWidget);
    expect(find.byIcon(Icons.login_rounded), findsOneWidget);
    expect(find.byIcon(Icons.pets_rounded), findsOneWidget);
    expect(find.byIcon(Icons.event_available_rounded), findsOneWidget);
    expect(find.byIcon(Icons.history_rounded), findsOneWidget);
  });
}
