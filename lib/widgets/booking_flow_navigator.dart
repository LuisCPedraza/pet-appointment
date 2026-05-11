import 'package:flutter/material.dart';
import 'package:pet_appointment/screens/appointment_confirm_screen.dart';
import 'package:pet_appointment/screens/calendar_screen.dart';

/// Tab de agendamiento — mantiene un Navigator interno para que la
/// confirmación de cita se muestre sobre la misma shell y conserve la
/// navegación inferior.
class BookingFlowNavigator extends StatelessWidget {
  const BookingFlowNavigator({super.key});

  @override
  Widget build(BuildContext context) {
    return Navigator(
      initialRoute: '/',
      onGenerateRoute: (settings) {
        Widget page;
        switch (settings.name) {
          case '/confirm':
            final appointment = settings.arguments;
            page = AppointmentConfirmScreen(
              appointment: appointment as dynamic,
            );
            break;
          case '/':
          default:
            page = const CalendarScreen();
            break;
        }
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => page,
        );
      },
    );
  }
}
