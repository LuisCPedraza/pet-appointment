import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:pet_appointment/config/theme.dart';
import 'package:pet_appointment/controllers/reschedule_appointment_controller.dart';
import 'package:pet_appointment/models/appointment_model.dart';
import 'package:pet_appointment/widgets/calendar/calendar_card.dart';
import 'package:pet_appointment/widgets/calendar/confirm_button.dart';
import 'package:pet_appointment/widgets/calendar/notes_card.dart';
import 'package:pet_appointment/widgets/calendar/pet_selector_card.dart';
import 'package:pet_appointment/widgets/calendar/service_selector_card.dart';
import 'package:pet_appointment/widgets/calendar/time_slots_card.dart';
import 'package:pet_appointment/utils/app_globals.dart';

/// Pantalla de reprogramación de citas.
/// Permite al cliente cambiar la mascota, el servicio y el horario
/// con la misma experiencia de selección que en creación.
class RescheduleAppointmentScreen extends StatefulWidget {
  final AppointmentModel appointment;

  const RescheduleAppointmentScreen({super.key, required this.appointment});

  @override
  State<RescheduleAppointmentScreen> createState() =>
      _RescheduleAppointmentScreenState();
}

class _RescheduleAppointmentScreenState
    extends State<RescheduleAppointmentScreen> {
  late final RescheduleAppointmentController _controller;
  final TextEditingController _notesController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _controller = RescheduleAppointmentController();
    _controller.addListener(_onControllerChange);
    _initializeController();
  }

  Future<void> _initializeController() async {
    await _controller.initialize(widget.appointment);
  }

  void _onControllerChange() {
    if (mounted) setState(() {});
  }

  Future<void> _handleReschedule() async {
    final success = await _controller.rescheduleAppointment(
      _notesController.text,
    );
    if (!mounted) return;

    if (success) {
      appScaffoldMessengerKey.currentState?.showSnackBar(
        const SnackBar(
          content: Text('Cita reprogramada exitosamente'),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.of(context).pop(true);
    } else {
      appScaffoldMessengerKey.currentState?.showSnackBar(
        SnackBar(
          content: Text(_controller.errorMessage ?? 'Error desconocido'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  void dispose() {
    _controller.removeListener(_onControllerChange);
    _controller.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Reprogramar Cita'),
        centerTitle: true,
        elevation: 0,
      ),
      body: ListenableBuilder(
        listenable: _controller,
        builder: (context, _) {
          if (_controller.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (_controller.errorMessage != null &&
              _controller.services.isEmpty &&
              _controller.pets.isEmpty) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    _controller.errorMessage!,
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 16),
                  FilledButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('Volver'),
                  ),
                ],
              ),
            );
          }

          return SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSectionTitle('Cita Actual'),
                  _buildCurrentAppointmentCard(),
                  const SizedBox(height: 24),
                  _buildSectionTitle('Mascota'),
                  if (_controller.pets.isEmpty)
                    _buildEmptyState('No hay mascotas disponibles')
                  else
                    PetSelectorCard(controller: _controller),
                  const SizedBox(height: 24),
                  _buildSectionTitle('Tipo de Servicio'),
                  ServiceSelectorCard(controller: _controller),
                  const SizedBox(height: 24),
                  if (_controller.selectedServiceId == null)
                    const ServiceRequiredHint()
                  else
                    CalendarCard(controller: _controller),
                  if (_controller.selectedDay != null) ...[
                    const SizedBox(height: 24),
                    TimeSlotsCard(controller: _controller),
                  ],
                  const SizedBox(height: 24),
                  _buildSectionTitle('Notas adicionales'),
                  NotesCard(controller: _notesController),
                  const SizedBox(height: 24),
                  ConfirmAppointmentButton(
                    controller: _controller,
                    label: 'Confirmar Reprogramación',
                    onPressed: _handleReschedule,
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: Colors.grey,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Widget _buildCurrentAppointmentCard() {
    final appointment = widget.appointment;
    final dateFormatter = DateFormat('EEEE d MMMM yyyy · HH:mm', 'es_ES');

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.medical_services,
                  color: AppColors.primary,
                  size: 20,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    appointment.serviceName.isNotEmpty
                        ? appointment.serviceName
                        : 'Servicio no especificado',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Icon(Icons.pets, color: AppColors.primary, size: 20),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    appointment.petName.isNotEmpty
                        ? appointment.petName
                        : 'Mascota no especificada',
                    style: const TextStyle(fontSize: 14),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Icon(Icons.calendar_today, color: AppColors.primary, size: 20),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    appointment.scheduledAt != null
                        ? dateFormatter
                              .format(appointment.scheduledAt!)
                              .replaceFirstMapped(
                                RegExp(r'^[a-z]'),
                                (m) => m.group(0)!.toUpperCase(),
                              )
                        : 'Fecha no disponible',
                    style: const TextStyle(fontSize: 14),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(String message) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(message, style: const TextStyle(color: Colors.grey)),
    );
  }
}
