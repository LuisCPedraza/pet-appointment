import 'package:flutter/foundation.dart';
import 'package:pet_appointment/models/appointment_model.dart';
import 'package:pet_appointment/models/availability_slot.dart';
import 'package:pet_appointment/models/service_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AppointmentService {
  final _client = Supabase.instance.client;

  /// Obtiene todos los slots habilitados de un profesional en un rango de fechas.
  /// Si se pasa [serviceId], filtra por ese servicio o slots sin servicio asignado.
  Future<List<AvailabilitySlot>> fetchSlots({
    required String professionalId,
    required DateTime from,
    required DateTime to,
    String? serviceId,
  }) async {
    var query = _client
        .from('availability')
        .select()
        .eq('professional_id', professionalId)
        .eq('is_available', true)
        .gte('slot_start', from.toUtc().toIso8601String())
        .lte('slot_start', to.toUtc().toIso8601String());

    // Slots del servicio seleccionado O slots sin servicio asignado (genéricos)
    if (serviceId != null) {
      query = query.or('service_id.eq.$serviceId,service_id.is.null');
    }

    final rows = await query.order('slot_start');

    return (rows as List)
        .map((row) => AvailabilitySlot.fromJson(row as Map<String, dynamic>))
        .toList();
  }

  /// Devuelve los [availability_id] que ya tienen una cita activa
  /// (estados que bloquean el slot: En espera, Confirmada, En progreso).
  Future<Set<String>> fetchBookedSlotIds({
    required String professionalId,
    required DateTime from,
    required DateTime to,
  }) async {
    // Traemos TODOS los availability_id reservados del profesional.
    // No filtramos por fecha aquí — el cruce con _slotsByDay (que sí está
    // filtrado por mes) garantiza que solo se marquen los del mes visible.
    // Nota: la política RLS de appointments solo permite ver las citas propias,
    // por eso agregamos la política "appointments_select_booked_slots" en Supabase
    // (ver comentario en 001_initial_schema.sql).
    final rows = await _client
        .from('appointments')
        .select('availability_id')
        .eq('professional_id', professionalId)
        .inFilter('status', ['En espera', 'Confirmada', 'En progreso']);

    return (rows as List)
        .map((row) => row['availability_id'] as String?)
        .whereType<String>()
        .where((id) => id.isNotEmpty)
        .toSet();
  }

  /// Suscribe a cambios en la tabla [appointments] del profesional indicado.
  /// Llama a [onChanged] cada vez que se inserta, actualiza o elimina una cita.
  /// Debes guardar el canal devuelto y llamar [channel.unsubscribe()] en dispose().
  RealtimeChannel subscribeToAppointments({
    required String professionalId,
    required void Function() onChanged,
  }) {
    final channel = _client
        .channel('appointments:$professionalId')
        .onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: 'appointments',
          filter: PostgresChangeFilter(
            type: PostgresChangeFilterType.eq,
            column: 'professional_id',
            value: professionalId,
          ),
          callback: (_) => onChanged(),
        );

    channel.subscribe((status, error) {
      debugPrint('🔌 Realtime appointments [$professionalId]: $status${error != null ? ' — $error' : ''}');
    });
    return channel;
  }

  /// Suscribe a cambios en la tabla [availability] del profesional indicado.
  /// Llama a [onChanged] cuando se agrega, modifica o elimina un slot.
  /// Debes guardar el canal devuelto y llamar [channel.unsubscribe()] en dispose().
  RealtimeChannel subscribeToSlots({
    required String professionalId,
    required void Function() onChanged,
  }) {
    final channel = _client
        .channel('slots:$professionalId')
        .onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: 'availability',
          filter: PostgresChangeFilter(
            type: PostgresChangeFilterType.eq,
            column: 'professional_id',
            value: professionalId,
          ),
          callback: (_) => onChanged(),
        );

    channel.subscribe((status, error) {
      debugPrint('🔌 Realtime slots [$professionalId]: $status${error != null ? ' — $error' : ''}');
    });
    return channel;
  }

  /// Devuelve la lista de usuarios con rol [professional].
  /// Cada elemento tiene: `id`, `full_name`, `email`.
  Future<List<Map<String, String>>> fetchProfessionals() async {
    final rows = await _client
        .from('users')
        .select('id, full_name, email')
        .eq('role', 'professional')
        .order('full_name');

    return (rows as List).map((row) {
      return {
        'id': row['id'] as String,
        'full_name': row['full_name'] as String? ?? '',
        'email': row['email'] as String? ?? '',
      };
    }).toList();
  }

  /// Devuelve los servicios activos disponibles para agendar.
  Future<List<ServiceModel>> fetchServices() async {
    final rows = await _client
        .from('services')
        .select('id, name, description, duration_minutes, price')
        .eq('is_active', true)
        .order('name');

    return (rows as List)
        .map((row) => ServiceModel.fromJson(row as Map<String, dynamic>))
        .toList();
  }

  /// Devuelve las mascotas del usuario autenticado actual.
  Future<List<Map<String, dynamic>>> fetchUserPets() async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) return [];
    final rows = await _client
        .from('pets')
        .select('id, name, species, breed')
        .eq('owner_id', userId)
        .order('name');
    return (rows as List).cast<Map<String, dynamic>>();
  }

  /// Obtiene todos los slots habilitados (todos los profesionales) en un rango.
  /// Si se pasa [serviceId], filtra por ese servicio o slots sin servicio asignado.
  Future<List<AvailabilitySlot>> fetchAllSlots({
    required DateTime from,
    required DateTime to,
    String? serviceId,
  }) async {
    var query = _client
        .from('availability')
        .select('*, users!availability_professional_id_fkey(full_name)')
        .eq('is_available', true)
        .gte('slot_start', from.toUtc().toIso8601String())
        .lte('slot_start', to.toUtc().toIso8601String());

    if (serviceId != null) {
      query = query.or('service_id.eq.$serviceId,service_id.is.null');
    }

    final rows = await query.order('slot_start');
    return (rows as List)
        .map((row) => AvailabilitySlot.fromJson(row as Map<String, dynamic>))
        .toList();
  }

  /// Devuelve los [availability_id] con cita activa (todos los profesionales).
  Future<Set<String>> fetchAllBookedSlotIds({
    required DateTime from,
    required DateTime to,
  }) async {
    final rows = await _client
        .from('appointments')
        .select('availability_id')
        .inFilter('status', ['En espera', 'Confirmada', 'En progreso']);

    return (rows as List)
        .map((row) => row['availability_id'] as String?)
        .whereType<String>()
        .where((id) => id.isNotEmpty)
        .toSet();
  }

  /// Suscribe a cambios en [appointments] sin filtro de profesional.
  RealtimeChannel subscribeToAllAppointments({
    required void Function() onChanged,
  }) {
    final channel = _client
        .channel('appointments:all')
        .onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: 'appointments',
          callback: (_) => onChanged(),
        );
    channel.subscribe((status, error) {
      debugPrint(
        '🔌 Realtime all-appointments: $status${error != null ? ' — $error' : ''}',
      );
    });
    return channel;
  }

  /// Suscribe a cambios en [availability] sin filtro de profesional.
  RealtimeChannel subscribeToAllSlots({
    required void Function() onChanged,
  }) {
    final channel = _client
        .channel('slots:all')
        .onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: 'availability',
          callback: (_) => onChanged(),
        );
    channel.subscribe((status, error) {
      debugPrint(
        '🔌 Realtime all-slots: $status${error != null ? ' — $error' : ''}',
      );
    });
    return channel;
  }

  /// Crea una nueva cita para el usuario autenticado.
  Future<void> createAppointment({
    required String petId,
    required String professionalId,
    String? serviceId,
    required String availabilityId,
    String? notes,
  }) async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) throw Exception('No hay sesión activa');
    await _client.from('appointments').insert({
      'client_id': userId,
      'pet_id': petId,
      'professional_id': professionalId,
      'service_id': serviceId,
      'availability_id': availabilityId,
      'status': 'En espera',
      'notes': notes?.isNotEmpty == true ? notes : null,
    });
  }

  /// Obtiene todas las citas del profesional autenticado actual con detalles de cliente, mascota y servicio.
  Future<List<AppointmentModel>> fetchProfessionalAppointments() async {
    final professionalId = _client.auth.currentUser?.id;
    if (professionalId == null) return [];

    try {
      final rows = await _client
          .from('appointments')
          .select(
            'id, professional_id, status, notes, created_at, '
            'client_id, pet_id, service_id, availability_id, '
            'users!appointments_client_id_fkey(id, full_name, email), '
            'pets(id, name, species), '
            'services(id, name), '
            'availability(slot_start, slot_end)',
          )
          .eq('professional_id', professionalId)
          .order('availability(slot_start)', ascending: true);

      final appointments = <AppointmentModel>[];
      for (final row in (rows as List)) {
        try {
          final appointment = AppointmentModel.fromJson(row as Map<String, dynamic>);
          appointments.add(appointment);
        } catch (e) {
          debugPrint('Error parsing appointment: $e');
          continue;
        }
      }
      return appointments;
    } catch (e) {
      debugPrint('Error fetching professional appointments: $e');
      return [];
    }
  }

  /// Suscribe a cambios en las citas del profesional autenticado.
  RealtimeChannel subscribeToProfessionalAppointments({
    required void Function() onChanged,
  }) {
    final professionalId = _client.auth.currentUser?.id;
    if (professionalId == null) {
      return _client.channel('empty'); // canal dummy si no hay usuario
    }

    final channel = _client
        .channel('professional:$professionalId:appointments')
        .onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: 'appointments',
          filter: PostgresChangeFilter(
            type: PostgresChangeFilterType.eq,
            column: 'professional_id',
            value: professionalId,
          ),
          callback: (_) => onChanged(),
        );

    channel.subscribe((status, error) {
      debugPrint(
        '🔌 Realtime professional appointments [$professionalId]: $status${error != null ? ' — $error' : ''}',
      );
    });

    return channel;
  }
}