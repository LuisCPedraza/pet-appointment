import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pet_appointment/models/appointment_history_model.dart';
import 'package:pet_appointment/utils/appointment_rules.dart';
import 'package:pet_appointment/widgets/appointment_history_view.dart';

void main() {
  group('Cancelación de cita', () {
    test(
      'permite cancelar solo cuando la cita está en espera o confirmada',
      () {
        expect(canClientCancelAppointment('En espera'), isTrue);
        expect(canClientCancelAppointment('Confirmada'), isTrue);
        expect(canClientCancelAppointment('En progreso'), isFalse);
        expect(canClientCancelAppointment('Atendida'), isFalse);
        expect(canClientCancelAppointment('Cancelada'), isFalse);
      },
    );
  });

  group('Historial de cita', () {
    test('parsea el motivo de cambio desde Supabase', () {
      final record = AppointmentHistoryModel.fromJson({
        'id': 'history-1',
        'appointment_id': 'appt-1',
        'previous_status': 'Confirmada',
        'new_status': 'Cancelada',
        'changed_by': 'user-1',
        'changed_at': '2026-05-11T15:30:00Z',
        'change_reason': 'El cliente no podrá asistir',
        'users': {'full_name': 'María López'},
      });

      expect(record.changeReason, 'El cliente no podrá asistir');
      expect(record.changedByName, 'María López');
      expect(record.newStatus, 'Cancelada');
    });

    testWidgets('muestra el motivo de cancelación en la vista de historial', (
      tester,
    ) async {
      final history = [
        AppointmentHistoryModel(
          id: 'history-1',
          appointmentId: 'appt-1',
          previousStatus: 'Confirmada',
          newStatus: 'Cancelada',
          changedById: 'user-1',
          changedByName: 'María López',
          changeReason: 'Cliente con gripe',
          changedAt: DateTime.utc(2026, 5, 11, 15, 30),
        ),
      ];

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(body: AppointmentHistoryView(history: history)),
        ),
      );

      expect(find.text('Motivo: Cliente con gripe'), findsOneWidget);
      expect(find.text('María López'), findsOneWidget);

      final richTexts = tester.widgetList<RichText>(find.byType(RichText));
      expect(
        richTexts.any(
          (widget) => widget.text.toPlainText().contains('Cancelada'),
        ),
        isTrue,
      );
    });

    testWidgets('muestra el estado vacío cuando no hay historial', (
      tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: AppointmentHistoryView(history: [])),
        ),
      );

      expect(find.text('Sin historial de cambios'), findsOneWidget);
      expect(find.byIcon(Icons.history), findsOneWidget);
    });
  });
}
