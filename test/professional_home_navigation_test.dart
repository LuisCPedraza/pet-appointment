import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pet_appointment/models/availability_slot.dart';
import 'package:pet_appointment/screens/professional_availability_screen.dart';

class _FakeChannel {
  void unsubscribe() {}
}

class _FakeAppointmentService {
  Future<List<AvailabilitySlot>> fetchSlots({
    required String professionalId,
    required DateTime from,
    required DateTime to,
    String? serviceId,
  }) async {
    return [];
  }

  Future<int> createSlotsBetween({
    required String professionalId,
    required DateTime start,
    required DateTime end,
    required int slotMinutes,
    String? serviceId,
  }) async {
    return 0;
  }

  Future<void> updateSlotAvailability({
    required String slotId,
    required bool isAvailable,
  }) async {}

  Future<_FakeChannel> subscribeToSlots({
    required String professionalId,
    required void Function() onChanged,
  }) async {
    return _FakeChannel();
  }
}

class _RouteHost extends StatelessWidget {
  const _RouteHost();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: ElevatedButton(
          onPressed: () =>
              Navigator.of(context).pushNamed('/professional-availability'),
          child: const Text('Abrir disponibilidad'),
        ),
      ),
    );
  }
}

void main() {
  testWidgets('La ruta de disponibilidad abre la pantalla correcta', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        routes: {
          '/professional-availability': (_) => ProfessionalAvailabilityScreen(
            appointmentService: _FakeAppointmentService(),
            professionalId: 'prof-1',
          ),
        },
        home: const _RouteHost(),
      ),
    );

    expect(find.text('Abrir disponibilidad'), findsOneWidget);

    await tester.tap(find.text('Abrir disponibilidad'));
    await tester.pumpAndSettle(const Duration(seconds: 1));

    expect(find.text('Mi Disponibilidad'), findsOneWidget);
    expect(find.text('Generar 4 semanas'), findsOneWidget);
  });
}
