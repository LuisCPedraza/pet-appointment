import 'package:flutter/material.dart';
import 'package:pet_appointment/config/theme.dart';
import 'package:pet_appointment/controllers/calendar_controller.dart';
import 'package:pet_appointment/widgets/calendar/booking_heading.dart';
import 'package:pet_appointment/widgets/calendar/calendar_card.dart';
import 'package:pet_appointment/widgets/calendar/confirm_button.dart';
import 'package:pet_appointment/widgets/calendar/notes_card.dart';
import 'package:pet_appointment/widgets/calendar/pet_selector_card.dart';
import 'package:pet_appointment/widgets/calendar/service_selector_card.dart';
import 'package:pet_appointment/widgets/calendar/time_slots_card.dart';

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  final _controller = CalendarController();
  final _notesController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _controller.addListener(_onControllerChange);
    _init();
  }

  Future<void> _init() async {
    try {
      await _controller.loadInitialData();
      _controller.subscribeRealtime();
    } catch (e) {
      if (mounted) _showSnack('Error al cargar datos: $e', isError: true);
    }
  }

  void _onControllerChange() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _controller.removeListener(_onControllerChange);
    _controller.unsubscribe();
    _controller.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _confirm() async {
    if (_controller.selectedPetId == null) {
      _showSnack('Selecciona una mascota');
      return;
    }
    if (_controller.selectedSlot == null) {
      _showSnack('Selecciona una hora disponible');
      return;
    }
    try {
      await _controller.confirm(notes: _notesController.text);
      if (mounted) {
        _showSnack('Cita agendada con exito!');
        _notesController.clear();
      }
    } catch (e) {
      if (mounted) _showSnack('Error al agendar: $e', isError: true);
    }
  }

  void _showSnack(String msg, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: isError ? AppColors.error : AppColors.secondary,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_controller.isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    return Scaffold(
      backgroundColor: AppColors.surface,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            const SliverToBoxAdapter(child: BookingHeading()),
            if (_controller.pets.isNotEmpty)
              SliverToBoxAdapter(
                child: PetSelectorCard(controller: _controller),
              ),
            if (_controller.services.isNotEmpty)
              SliverToBoxAdapter(
                child: ServiceSelectorCard(controller: _controller),
              ),
            if (_controller.selectedServiceId == null)
              const SliverToBoxAdapter(child: ServiceRequiredHint())
            else ...[
              SliverToBoxAdapter(
                child: CalendarCard(controller: _controller),
              ),
              if (_controller.selectedDay != null)
                SliverToBoxAdapter(
                  child: TimeSlotsCard(controller: _controller),
                ),
            ],
            SliverToBoxAdapter(
              child: NotesCard(controller: _notesController),
            ),
            SliverToBoxAdapter(
              child: ConfirmAppointmentButton(
                controller: _controller,
                onPressed: _confirm,
              ),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 24)),
          ],
        ),
      ),
    );
  }
}
