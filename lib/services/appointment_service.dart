import 'package:flutter/foundation.dart';
import 'package:pet_appointment/models/appointment_history_model.dart';
import 'package:pet_appointment/models/appointment_model.dart';
import 'package:pet_appointment/models/appointment_status.dart';
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
      debugPrint(
        '🔌 Realtime appointments [$professionalId]: $status${error != null ? ' — $error' : ''}',
      );
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
      debugPrint(
        '🔌 Realtime slots [$professionalId]: $status${error != null ? ' — $error' : ''}',
      );
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
    String? professionalId,
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
    if (professionalId != null) {
      query = query.eq('professional_id', professionalId);
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
  RealtimeChannel subscribeToAllSlots({required void Function() onChanged}) {
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

  /// Crea una nueva cita para el usuario autenticado y devuelve el objeto creado.
  Future<AppointmentModel> createAppointment({
    required String petId,
    required String professionalId,
    String? serviceId,
    required String availabilityId,
    String? notes,
  }) async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) throw Exception('No hay sesión activa');

    final insertResponse = await _client
        .from('appointments')
        .insert({
          'client_id': userId,
          'pet_id': petId,
          'professional_id': professionalId,
          'service_id': serviceId,
          'availability_id': availabilityId,
          'status': 'En espera',
          'notes': notes?.isNotEmpty == true ? notes : null,
        })
        .select('id')
        .single();

    final appointmentId = insertResponse['id'] as String;

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
        .eq('id', appointmentId)
        .single();

    var appointment = AppointmentModel.fromJson(rows);

    if (appointment.professionalName.isEmpty) {
      try {
        final professionalRow = await _client
            .from('users')
            .select('full_name')
            .eq('id', professionalId)
            .single();
        final professionalName = professionalRow['full_name'] as String? ?? '';
        appointment = appointment.copyWith(professionalName: professionalName);
      } catch (e) {
        debugPrint('No se pudo cargar el nombre del profesional: $e');
      }
    }

    return appointment;
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
            'pets(id, name, species), '
            'services(id, name), '
            'availability(slot_start, slot_end)',
          )
          .eq('professional_id', professionalId)
          .order('created_at', ascending: false);

      final appointments = <AppointmentModel>[];
      for (final row in (rows as List)) {
        try {
          final appointment = AppointmentModel.fromJson(
            row as Map<String, dynamic>,
          );
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

  /// Obtiene las citas del cliente autenticado actual con detalles de cliente, mascota y servicio.
  Future<List<AppointmentModel>> fetchClientAppointments() async {
    final clientId = _client.auth.currentUser?.id;
    if (clientId == null) return [];

    try {
      final rows = await _client
          .from('appointments')
          .select(
            'id, professional_id, status, notes, created_at, '
            'client_id, pet_id, service_id, availability_id, '
            'pets(id, name, species), '
            'services(id, name), '
            'availability(slot_start, slot_end)',
          )
          .eq('client_id', clientId)
          .order('created_at', ascending: false);

      final appointments = <AppointmentModel>[];
      for (final row in (rows as List)) {
        try {
          final appointment = AppointmentModel.fromJson(
            row as Map<String, dynamic>,
          );
          appointments.add(appointment);
        } catch (e) {
          debugPrint('Error parsing client appointment: $e');
          continue;
        }
      }
      return appointments;
    } catch (e) {
      debugPrint('Error fetching client appointments: $e');
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

  /// Suscribe a cambios en las citas del cliente autenticado.
  RealtimeChannel subscribeToClientAppointments({
    required void Function() onChanged,
  }) {
    final clientId = _client.auth.currentUser?.id;
    if (clientId == null) {
      return _client.channel('empty');
    }

    final channel = _client
        .channel('client:$clientId:appointments')
        .onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: 'appointments',
          filter: PostgresChangeFilter(
            type: PostgresChangeFilterType.eq,
            column: 'client_id',
            value: clientId,
          ),
          callback: (_) => onChanged(),
        );

    channel.subscribe((status, error) {
      debugPrint(
        '🔌 Realtime client appointments [$clientId]: $status${error != null ? ' — $error' : ''}',
      );
    });

    return channel;
  }

  /// Actualiza el estado de una cita y registra el cambio en `appointment_history`.
  /// Solo el profesional asignado podrá actualizar (verificación por `professional_id`).
  Future<void> updateAppointmentStatus({
    required String appointmentId,
    required String newStatus,
  }) async {
    final professionalId = _client.auth.currentUser?.id;
    if (professionalId == null) throw Exception('No hay sesión activa');

    // Obtener estado actual y profesional asignado
    final selectRows = await _client
        .from('appointments')
        .select('id, status, professional_id')
        .eq('id', appointmentId)
        .limit(1);

    if (selectRows.isEmpty) throw Exception('Cita no encontrada');
    final current = selectRows.first;
    final previousStatus = current['status'] as String? ?? '';
    final assignedProfessional = current['professional_id'] as String? ?? '';

    if (assignedProfessional != professionalId) {
      throw Exception('No autorizado para confirmar esta cita');
    }

    // Actualizar estado
    await _client
        .from('appointments')
        .update({
          'status': newStatus,
          'updated_at': DateTime.now().toUtc().toIso8601String(),
        })
        .eq('id', appointmentId)
        .eq('professional_id', professionalId);

    // Insertar en historial
    await _client.from('appointment_history').insert({
      'appointment_id': appointmentId,
      'previous_status': previousStatus.isNotEmpty ? previousStatus : null,
      'new_status': newStatus,
      'changed_by': professionalId,
      'changed_at': DateTime.now().toUtc().toIso8601String(),
    });
  }

  /// Cancela una cita del cliente autenticado.
  Future<void> cancelClientAppointment({
    required String appointmentId,
    String? reason,
  }) async {
    final clientId = _client.auth.currentUser?.id;
    if (clientId == null) throw Exception('No hay sesión activa');

    await _client.rpc(
      'cancel_client_appointment',
      params: {
        'p_appointment_id': appointmentId,
        'p_reason': reason,
      },
    );
  }

  /// Obtiene el historial completo de cambios de estado de una cita.
  /// Devuelve los registros ordenados por fecha (más reciente primero).
  Future<List<AppointmentHistoryModel>> fetchAppointmentHistory(
    String appointmentId,
  ) async {
    try {
      final rows = await _client
          .from('appointment_history')
          .select(
            'id, appointment_id, previous_status, new_status, change_reason, changed_by, changed_at, '
            'users(full_name)',
          )
          .eq('appointment_id', appointmentId)
          .order('changed_at', ascending: false);

      return (rows as List)
          .map(
            (row) =>
                AppointmentHistoryModel.fromJson(row as Map<String, dynamic>),
          )
          .toList();
    } catch (e) {
      debugPrint('Error fetching appointment history: $e');
      return [];
    }
  }

  /// Suscribe a cambios en el historial de una cita específica.
  RealtimeChannel subscribeToAppointmentHistory({
    required String appointmentId,
    required void Function() onChanged,
  }) {
    final channel = _client
        .channel('appointment_history:$appointmentId')
        .onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: 'appointment_history',
          filter: PostgresChangeFilter(
            type: PostgresChangeFilterType.eq,
            column: 'appointment_id',
            value: appointmentId,
          ),
          callback: (_) => onChanged(),
        );

    channel.subscribe((status, error) {
      debugPrint(
        '🔌 Realtime appointment_history [$appointmentId]: $status${error != null ? ' — $error' : ''}',
      );
    });

    return channel;
  }

  /// Retorna los estados válidos a los que se puede transicionar
  /// desde el estado actual de la cita.
  List<AppointmentStatus> getValidNextStatuses(String currentStatusString) {
    final currentStatus = AppointmentStatus.fromString(currentStatusString);
    if (currentStatus == null) return [];
    return currentStatus.getValidNextStates();
  }

  /// Valida si una transición de estado es permitida
  bool isValidStatusTransition(
    String currentStatusString,
    String nextStatusString,
  ) {
    final currentStatus = AppointmentStatus.fromString(currentStatusString);
    final nextStatus = AppointmentStatus.fromString(nextStatusString);

    if (currentStatus == null || nextStatus == null) return false;
    return currentStatus.canTransitionTo(nextStatus);
  }
}
