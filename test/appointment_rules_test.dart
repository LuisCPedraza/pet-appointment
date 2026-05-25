import 'package:flutter_test/flutter_test.dart';
import 'package:pet_appointment/utils/appointment_rules.dart';

void main() {
  group('appointment_rules', () {
    test('permite al cliente cancelar solo citas pendientes o confirmadas', () {
      expect(canClientCancelAppointment('En espera'), isTrue);
      expect(canClientCancelAppointment('Confirmada'), isTrue);
      expect(canClientCancelAppointment('En progreso'), isFalse);
      expect(canClientCancelAppointment('Atendida'), isFalse);
      expect(canClientCancelAppointment('Cancelada'), isFalse);
    });

    test('permite transiciones válidas de estado para profesional y admin', () {
      expect(
        canProfessionalUpdateAppointmentStatus('En espera', 'Confirmada'),
        isTrue,
      );
      expect(
        canProfessionalUpdateAppointmentStatus('Confirmada', 'En progreso'),
        isTrue,
      );
      expect(
        canProfessionalUpdateAppointmentStatus('En progreso', 'Atendida'),
        isTrue,
      );
      expect(
        canProfessionalUpdateAppointmentStatus('En progreso', 'Cancelada'),
        isTrue,
      );

      expect(
        canProfessionalUpdateAppointmentStatus('En espera', 'Atendida'),
        isFalse,
      );
      expect(
        canProfessionalUpdateAppointmentStatus('Atendida', 'Confirmada'),
        isFalse,
      );
      expect(
        canProfessionalUpdateAppointmentStatus('Cancelada', 'En progreso'),
        isFalse,
      );

      expect(
        canAdminUpdateAppointmentStatus('En espera', 'Confirmada'),
        isTrue,
      );
      expect(
        canAdminUpdateAppointmentStatus('Atendida', 'Confirmada'),
        isFalse,
      );
    });

    test('rechaza estados desconocidos', () {
      expect(
        canProfessionalUpdateAppointmentStatus('desconocido', 'Confirmada'),
        isFalse,
      );
      expect(
        canProfessionalUpdateAppointmentStatus('En espera', 'desconocido'),
        isFalse,
      );
      expect(canAdminUpdateAppointmentStatus('foo', 'bar'), isFalse);
    });
  });
}
