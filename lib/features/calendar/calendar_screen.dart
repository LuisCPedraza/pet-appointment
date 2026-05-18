import 'package:flutter/material.dart';
import 'package:pet_appointment/config/theme.dart';
import 'package:pet_appointment/controllers/calendar_controller.dart';
import 'package:pet_appointment/services/appointment_notification_service.dart';
import 'package:pet_appointment/widgets/card_container.dart';
import 'package:pet_appointment/widgets/calendar/booking_heading.dart';
import 'package:pet_appointment/widgets/calendar/calendar_card.dart';
import 'package:pet_appointment/widgets/calendar/confirm_button.dart';
import 'package:pet_appointment/widgets/calendar/notes_card.dart';
import 'package:pet_appointment/widgets/calendar/professional_selector_card.dart';
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
      final appointment = await _controller.confirm(
        notes: _notesController.text,
      );

      if (mounted) {
        _notesController.clear();

        // Mostrar notificación local de confirmación
        if (appointment != null) {
          final notificationService = AppointmentNotificationService();
          await notificationService.showAppointmentConfirmationNotification(
            appointment,
          );

          // Navegar a la pantalla de confirmación
          if (mounted) {
            Navigator.of(context).pushNamed('/confirm', arguments: appointment);
          }
        }
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
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                child: CardContainer(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Resumen de reserva',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          _SummaryChip(
                            label: 'Mascotas',
                            value: '${_controller.pets.length}',
                            icon: Icons.pets,
                          ),
                          _SummaryChip(
                            label: 'Servicios',
                            value: '${_controller.services.length}',
                            icon: Icons.medical_services,
                          ),
                          _SummaryChip(
                            label: 'Profesionales',
                            value: '${_controller.professionals.length}',
                            icon: Icons.person_search,
                          ),
                          _SummaryChip(
                            label: 'Slots',
                            value: '${_controller.slotsByDay.length}',
                            icon: Icons.schedule,
                          ),
                        ],
                      ),
                      if (_controller.selectedProfessionalName != null) ...[
                        const SizedBox(height: 10),
                        Text(
                          'Profesional seleccionado: ${_controller.selectedProfessionalName}',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: AppColors.onSurfaceVariant,
                          ),
                        ),
                      ],
                      const SizedBox(height: 12),
                      Text(
                        _controller.selectedServiceId == null
                            ? 'Selecciona un servicio para mostrar el calendario y los horarios disponibles.'
                            : _controller.selectedProfessionalId == null
                            ? 'Selecciona un profesional para cargar su disponibilidad.'
                            : _controller.selectedDay == null
                            ? 'Ya puedes elegir una fecha y continuar con la hora disponible.'
                            : 'Selecciona una hora y completa la nota si quieres dejar un comentario para la cita.',
                        style: TextStyle(
                          fontSize: 13,
                          color: AppColors.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            if (_controller.pets.isNotEmpty)
              SliverToBoxAdapter(
                child: PetSelectorCard(controller: _controller),
              ),
            if (_controller.services.isNotEmpty)
              SliverToBoxAdapter(
                child: ServiceSelectorCard(controller: _controller),
              ),
            if (_controller.selectedServiceId != null &&
                _controller.professionals.isNotEmpty)
              SliverToBoxAdapter(
                child: ProfessionalSelectorCard(controller: _controller),
              ),
            if (_controller.selectedServiceId == null)
              const SliverToBoxAdapter(child: ServiceRequiredHint())
            else if (_controller.selectedProfessionalId == null)
              const SliverToBoxAdapter(child: ProfessionalRequiredHint())
            else ...[
              SliverToBoxAdapter(child: CalendarCard(controller: _controller)),
              if (_controller.selectedDay != null)
                SliverToBoxAdapter(
                  child: TimeSlotsCard(controller: _controller),
                ),
            ],
            SliverToBoxAdapter(child: NotesCard(controller: _notesController)),
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

class _SummaryChip extends StatelessWidget {
  const _SummaryChip({
    required this.label,
    required this.value,
    required this.icon,
  });

  final String label;
  final String value;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.outline.withValues(alpha: 0.15)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 18, color: AppColors.primary),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                value,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                ),
              ),
              Text(
                label,
                style: TextStyle(
                  fontSize: 11,
                  color: AppColors.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class ProfessionalRequiredHint extends StatelessWidget {
  const ProfessionalRequiredHint({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
      child: Row(
        children: [
          Icon(
            Icons.info_outline_rounded,
            size: 16,
            color: AppColors.onSurfaceVariant,
          ),
          const SizedBox(width: 8),
          Text(
            'Selecciona un profesional para ver su disponibilidad.',
            style: TextStyle(fontSize: 13, color: AppColors.onSurfaceVariant),
          ),
        ],
      ),
    );
  }
}
