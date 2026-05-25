import 'package:flutter/foundation.dart';
import 'package:pet_appointment/models/appointment_history_model.dart';
import 'package:pet_appointment/models/appointment_model.dart';
import 'package:pet_appointment/models/appointment_status.dart';
import 'package:pet_appointment/models/availability_slot.dart';
import 'package:pet_appointment/models/service_model.dart';
import 'package:pet_appointment/services/auth_service.dart';
import 'package:pet_appointment/utils/appointment_rules.dart';
import 'package:pet_appointment/utils/slot_generation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AppointmentService {
  SupabaseClient get _client => Supabase.instance.client;
  static const List<String> _activeUpcomingStatuses = [
    'En espera',
    'Confirmada',
  ];
  static const List<String> _blockingAppointmentStatuses = [
    'En espera',
    'Confirmada',
    'En progreso',
  ];

  /// Obtiene todos los slots habilitados de un profesional en un rango de fechas.
  /// Si se pasa [serviceId], filtra por ese servicio o slots sin servicio asignado.
  Future<List<AvailabilitySlot>> fetchSlots({
    required String professionalId,
    required DateTime from,
    required DateTime to,
    String? serviceId,
    bool includeInactive = false,
  }) async {
    var query = _client
        .from('availability')
        .select()
        .eq('professional_id', professionalId)
        .gte('slot_start', from.toUtc().toIso8601String())
        .lte('slot_start', to.toUtc().toIso8601String());

    if (!includeInactive) {
      query = query.eq('is_available', true);
    }

    // Slots del servicio seleccionado O slots sin servicio asignado (genéricos)
    if (serviceId != null) {
      query = query.or('service_id.eq.$serviceId,service_id.is.null');
    }

    final rows = await query.order('slot_start');

    return (rows as List)
        .map((row) => AvailabilitySlot.fromJson(row as Map<String, dynamic>))
        .toList();
  }

  /// Crea slots entre dos timestamps (UTC) para el profesional.
  /// Retorna la cantidad de slots creados.
  Future<int> createSlotsBetween({
    required String professionalId,
    required DateTime start,
    required DateTime end,
    required int slotMinutes,
    String? serviceId,
  }) async {
    final candidateRanges = buildSlotRanges(
      start: start,
      end: end,
      slotMinutes: slotMinutes,
    );
    if (candidateRanges.isEmpty) return 0;

    final existingRows = await _client
        .from('availability')
        .select('slot_start')
        .eq('professional_id', professionalId)
        .gte('slot_start', start.toUtc().toIso8601String())
        .lte('slot_start', end.toUtc().toIso8601String());

    final existingStarts = (existingRows as List)
        .map(
          (row) =>
              DateTime.tryParse(row['slot_start'] as String? ?? '')?.toUtc(),
        )
        .whereType<DateTime>()
        .toSet();

    final inserts = candidateRanges
        .where((range) => !existingStarts.contains(range.start.toUtc()))
        .map(
          (range) => {
            'professional_id': professionalId,
            'service_id': serviceId,
            'slot_start': range.start.toUtc().toIso8601String(),
            'slot_end': range.end.toUtc().toIso8601String(),
            'is_available': true,
          },
        )
        .toList();

    if (inserts.isEmpty) return 0;

    try {
      await _client.from('availability').insert(inserts);
      return inserts.length;
    } catch (e) {
      debugPrint('Error creando slots: $e');
      return 0;
    }
  }

  /// Elimina slots en un rango para volver a generar configuración.
  ///
  /// Conserva slots que ya estén asociados a una cita para evitar conflictos.
  Future<int> deleteSlotsBetween({
    required String professionalId,
    required DateTime from,
    required DateTime to,
  }) async {
    final rows = await _client
        .from('availability')
        .select('id')
        .eq('professional_id', professionalId)
        .gte('slot_start', from.toUtc().toIso8601String())
        .lte('slot_start', to.toUtc().toIso8601String());

    final slotIds = (rows as List)
        .map((row) => row['id'] as String?)
        .whereType<String>()
        .toList();
    if (slotIds.isEmpty) return 0;

    final linkedRows = await _client
        .from('appointments')
        .select('availability_id')
        .inFilter('availability_id', slotIds);

    final linkedIds = (linkedRows as List)
        .map((row) => row['availability_id'] as String?)
        .whereType<String>()
        .toSet();

    final deletableIds = slotIds
        .where((id) => !linkedIds.contains(id))
        .toList();
    if (deletableIds.isEmpty) return 0;

    await _client.from('availability').delete().inFilter('id', deletableIds);
    return deletableIds.length;
  }

  /// Actualiza el flag `is_available` de un slot por su id.
  Future<void> updateSlotAvailability({
    required String slotId,
    required bool isAvailable,
  }) async {
    try {
      await _client
          .from('availability')
          .update({'is_available': isAvailable})
          .eq('id', slotId);
    } catch (e) {
      debugPrint('Error actualizando availability: $e');
      rethrow;
    }
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
  Future<List<Map<String, String>>> fetchProfessionals({
    bool activeOnly = true,
  }) async {
    var query = _client
        .from('users')
        .select('id, full_name, email')
        .eq('role', 'professional');
    if (activeOnly) {
      query = query.eq('is_active', true);
    }

    final rows = await query.order('full_name');

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
    return fetchAllServices(activeOnly: true);
  }

  /// Devuelve las próximas citas activas del usuario autenticado.
  Future<List<AppointmentModel>> fetchUpcomingAppointments({
    int limit = 5,
  }) async {
    final clientId = _client.auth.currentUser?.id;
    if (clientId == null) return [];

    try {
      final rows = await _fetchAppointmentsDetailsRows();
      final now = DateTime.now();
      final appointments = rows
          .where((row) {
            if (row['client_id'] != clientId) return false;
            final appointment = AppointmentModel.fromJson(row);
            final scheduledAt = appointment.scheduledAt;
            return scheduledAt != null &&
                scheduledAt.isAfter(now) &&
                _activeUpcomingStatuses.contains(appointment.status);
          })
          .map(AppointmentModel.fromJson)
          .toList();

      appointments.sort((left, right) {
        final leftDate =
            left.scheduledAt ?? DateTime.fromMillisecondsSinceEpoch(0);
        final rightDate =
            right.scheduledAt ?? DateTime.fromMillisecondsSinceEpoch(0);
        return leftDate.compareTo(rightDate);
      });

      return appointments.take(limit).toList();
    } catch (e) {
      debugPrint('fetchUpcomingAppointments error: $e');
      return [];
    }
  }

  /// Devuelve todos los servicios para administración.
  Future<List<ServiceModel>> fetchAllServices({bool activeOnly = false}) async {
    var query = _client
        .from('services')
        .select(
          'id, name, description, duration_minutes, price, is_active, created_at',
        );

    if (activeOnly) {
      query = query.eq('is_active', true);
    }

    final rows = await query.order('name');

    return (rows as List)
        .map((row) => ServiceModel.fromJson(row as Map<String, dynamic>))
        .toList();
  }

  /// Crea un servicio nuevo.
  Future<bool> createService({
    required String name,
    String? description,
    required int durationMinutes,
    required double price,
    bool isActive = true,
  }) async {
    try {
      await _client.from('services').insert({
        'name': name.trim(),
        'description': description?.trim().isEmpty == true
            ? null
            : description?.trim(),
        'duration_minutes': durationMinutes,
        'price': price,
        'is_active': isActive,
      });
      return true;
    } catch (e) {
      debugPrint('createService error: $e');
      return false;
    }
  }

  /// Actualiza un servicio existente.
  Future<bool> updateService({
    required String serviceId,
    required String name,
    String? description,
    required int durationMinutes,
    required double price,
    bool? isActive,
  }) async {
    try {
      final payload = <String, dynamic>{
        'name': name.trim(),
        'description': description?.trim().isEmpty == true
            ? null
            : description?.trim(),
        'duration_minutes': durationMinutes,
        'price': price,
      };
      if (isActive != null) {
        payload['is_active'] = isActive;
      }

      await _client.from('services').update(payload).eq('id', serviceId);
      return true;
    } catch (e) {
      debugPrint('updateService error: $e');
      return false;
    }
  }

  /// Activa o desactiva un servicio.
  Future<bool> setServiceActive({
    required String serviceId,
    required bool active,
  }) async {
    try {
      await _client
          .from('services')
          .update({'is_active': active})
          .eq('id', serviceId);
      return true;
    } catch (e) {
      debugPrint('setServiceActive error: $e');
      return false;
    }
  }

  /// Elimina un servicio. La base de datos impide borrar servicios con citas asociadas.
  Future<void> deleteService({required String serviceId}) async {
    await _client.from('services').delete().eq('id', serviceId);
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
    String? professionalId,
  }) async {
    var query = _client.from('appointments').select('availability_id').inFilter(
      'status',
      ['En espera', 'Confirmada', 'En progreso'],
    );

    if (professionalId != null) {
      query = query.eq('professional_id', professionalId);
    }

    final rows = await query;

    return (rows as List)
        .map((row) => row['availability_id'] as String?)
        .whereType<String>()
        .where((id) => id.isNotEmpty)
        .toSet();
  }

  /// Suscribe a cambios en la tabla de servicios para refrescar el catálogo.
  RealtimeChannel subscribeToServices({required void Function() onChanged}) {
    final channel = _client
        .channel('services:catalog')
        .onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: 'services',
          callback: (_) => onChanged(),
        );

    channel.subscribe((status, error) {
      debugPrint(
        '🔌 Realtime services: $status${error != null ? ' — $error' : ''}',
      );
    });

    return channel;
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

    await _assertSlotIsBookable(
      availabilityId: availabilityId,
      professionalId: professionalId,
      serviceId: serviceId,
    );

    try {
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
      return _fetchAppointmentById(appointmentId);
    } catch (e) {
      if (_isSlotConflictError(e)) {
        throw Exception('Ese horario ya no está disponible. Elige otro.');
      }
      rethrow;
    }
  }

  Future<List<Map<String, dynamic>>> _fetchAppointmentsDetailsRows() async {
    final response = await _client.rpc('get_my_appointments_with_details');

    if (response is List) {
      return response
          .whereType<Map>()
          .map((row) => row.cast<String, dynamic>())
          .toList();
    }

    if (response is Map<String, dynamic>) {
      return [response];
    }

    return [];
  }

  Future<AppointmentModel> _fetchAppointmentById(String appointmentId) async {
    final rows = await _fetchAppointmentsDetailsRows();
    final row = rows.cast<Map<String, dynamic>?>().firstWhere(
      (item) => item?['id'] == appointmentId,
      orElse: () => null,
    );

    if (row == null) {
      throw Exception('No se pudo cargar el detalle de la cita');
    }

    return AppointmentModel.fromJson(row);
  }

  /// Obtiene una cita por su id con todos los detalles asociados.
  Future<AppointmentModel?> fetchAppointmentById(String appointmentId) async {
    try {
      return await _fetchAppointmentById(appointmentId);
    } catch (e) {
      debugPrint('Error fetching appointment by id: $e');
      return null;
    }
  }

  /// Obtiene todas las citas del profesional autenticado actual con detalles de cliente, mascota y servicio.
  Future<List<AppointmentModel>> fetchProfessionalAppointments() async {
    try {
      final professionalId = _client.auth.currentUser?.id;
      if (professionalId == null) return [];

      final rows = await _fetchAppointmentsDetailsRows();
      return rows
          .where((row) => row['professional_id'] == professionalId)
          .map(AppointmentModel.fromJson)
          .toList()
        ..sort((a, b) {
          final aDate = a.scheduledAt ?? DateTime.fromMillisecondsSinceEpoch(0);
          final bDate = b.scheduledAt ?? DateTime.fromMillisecondsSinceEpoch(0);
          return bDate.compareTo(aDate);
        });
    } catch (e) {
      debugPrint('Error fetching professional appointments: $e');
      return [];
    }
  }

  /// Obtiene las citas del cliente autenticado actual con detalles de cliente, mascota y servicio.
  Future<List<AppointmentModel>> fetchClientAppointments() async {
    try {
      final clientId = _client.auth.currentUser?.id;
      if (clientId == null) return [];

      final rows = await _fetchAppointmentsDetailsRows();
      return rows
          .where((row) => row['client_id'] == clientId)
          .map(AppointmentModel.fromJson)
          .toList()
        ..sort((a, b) {
          final aDate = a.scheduledAt ?? DateTime.fromMillisecondsSinceEpoch(0);
          final bDate = b.scheduledAt ?? DateTime.fromMillisecondsSinceEpoch(0);
          return bDate.compareTo(aDate);
        });
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

  /// Devuelve citas administrativas filtradas por rango de fechas y opcionales.
  Future<List<AppointmentModel>> fetchAdminAppointments({
    required DateTime from,
    required DateTime to,
    String? professionalId,
    String? serviceId,
    required int limit,
    required int offset,
  }) async {
    try {
      var query = _client
          .from('appointments')
          .select(
            'id, professional_id, status, notes, created_at, '
            'client_id, pet_id, service_id, availability_id, '
            'users!appointments_client_id_fkey(id, full_name, email), '
            'users!appointments_professional_id_fkey(full_name), '
            'pets(id, name, species), '
            'services(id, name), '
            'availability(slot_start, slot_end)',
          )
          .gte('availability.slot_start', from.toUtc().toIso8601String())
          .lte('availability.slot_start', to.toUtc().toIso8601String());

      if (professionalId != null && professionalId.isNotEmpty) {
        query = query.eq('professional_id', professionalId);
      }
      if (serviceId != null && serviceId.isNotEmpty) {
        query = query.eq('service_id', serviceId);
      }

      final rows = await query
          .order('created_at', ascending: false)
          .range(offset, offset + limit - 1);

      return (rows as List)
          .map((row) => AppointmentModel.fromJson(row as Map<String, dynamic>))
          .toList();
    } catch (e) {
      debugPrint('fetchAdminAppointments error: $e');
      return [];
    }
  }

  /// Devuelve contadores del reporte de citas para un rango y filtros opcionales.
  Future<Map<String, int>> fetchAppointmentReportSummary({
    required DateTime from,
    required DateTime to,
    String? professionalId,
    String? serviceId,
  }) async {
    try {
      final response = await _client.rpc(
        'admin_appointments_report_summary',
        params: {
          'p_from': from.toUtc().toIso8601String(),
          'p_to': to.toUtc().toIso8601String(),
          'p_professional_id': professionalId,
          'p_service_id': serviceId,
        },
      );

      final rows = response as List<dynamic>;
      if (rows.isEmpty) {
        return {
          'total': 0,
          'En espera': 0,
          'Confirmada': 0,
          'En progreso': 0,
          'Atendida': 0,
          'Cancelada': 0,
        };
      }

      final row = rows.first as Map<String, dynamic>;
      return {
        'total': (row['total_count'] as num?)?.toInt() ?? 0,
        'En espera': (row['waiting_count'] as num?)?.toInt() ?? 0,
        'Confirmada': (row['confirmed_count'] as num?)?.toInt() ?? 0,
        'En progreso': (row['in_progress_count'] as num?)?.toInt() ?? 0,
        'Atendida': (row['attended_count'] as num?)?.toInt() ?? 0,
        'Cancelada': (row['cancelled_count'] as num?)?.toInt() ?? 0,
      };
    } catch (e) {
      debugPrint('fetchAppointmentReportSummary error: $e');
      return {
        'total': 0,
        'En espera': 0,
        'Confirmada': 0,
        'En progreso': 0,
        'Atendida': 0,
        'Cancelada': 0,
      };
    }
  }

  /// Actualiza el estado de una cita y registra el cambio en `appointment_history`.
  /// Solo el profesional asignado podrá actualizar (verificación por `professional_id`).
  Future<void> updateAppointmentStatus({
    required String appointmentId,
    required String newStatus,
  }) async {
    final currentUserId = _client.auth.currentUser?.id;
    if (currentUserId == null) throw Exception('No hay sesión activa');

    final role = await AuthService().getCurrentUserRole();
    if (role != 'professional' && role != 'admin') {
      throw Exception('No autorizado para actualizar esta cita');
    }

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

    if (role == 'professional' && assignedProfessional != currentUserId) {
      throw Exception('No autorizado para confirmar esta cita');
    }

    if (role == 'admin') {
      if (!canAdminUpdateAppointmentStatus(previousStatus, newStatus)) {
        throw Exception('Transición de estado no permitida');
      }
    } else if (!canProfessionalUpdateAppointmentStatus(
      previousStatus,
      newStatus,
    )) {
      throw Exception('Transición de estado no permitida');
    }

    // Actualizar estado
    await _client
        .from('appointments')
        .update({
          'status': newStatus,
          'updated_at': DateTime.now().toUtc().toIso8601String(),
        })
        .eq('id', appointmentId)
        .eq('professional_id', assignedProfessional);

    // Insertar en historial
    await _client.from('appointment_history').insert({
      'appointment_id': appointmentId,
      'previous_status': previousStatus.isNotEmpty ? previousStatus : null,
      'new_status': newStatus,
      'changed_by': currentUserId,
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

    final role = await AuthService().getCurrentUserRole();
    if (role != 'client') {
      throw Exception('No autorizado para cancelar esta cita');
    }

    await _client.rpc(
      'cancel_client_appointment',
      params: {'p_appointment_id': appointmentId, 'p_reason': reason},
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

  /// Actualiza una cita existente con un nuevo slot, servicio, mascota y notas.
  /// Retorna la cita actualizada con todos sus detalles.
  Future<AppointmentModel> updateAppointment({
    required String appointmentId,
    required String newAvailabilityId,
    required String petId,
    String? serviceId,
    String? notes,
  }) async {
    final clientId = _client.auth.currentUser?.id;
    if (clientId == null) throw Exception('No hay sesión activa');

    await _assertSlotIsBookable(
      availabilityId: newAvailabilityId,
      serviceId: serviceId,
      excludeAppointmentId: appointmentId,
    );

    try {
      await _client
          .from('appointments')
          .update({
            'availability_id': newAvailabilityId,
            'pet_id': petId,
            'service_id': serviceId,
            'notes': notes?.isNotEmpty == true ? notes : null,
            'updated_at': DateTime.now().toUtc().toIso8601String(),
          })
          .eq('id', appointmentId)
          .eq('client_id', clientId);

      return _fetchAppointmentById(appointmentId);
    } catch (e) {
      if (_isSlotConflictError(e)) {
        throw Exception('Ese horario ya no está disponible. Elige otro.');
      }
      rethrow;
    }
  }

  bool _isSlotConflictError(Object error) {
    return error is PostgrestException &&
        (error.code == '23505' ||
            error.message.toLowerCase().contains('availability') ||
            error.message.toLowerCase().contains('appointments_availability'));
  }

  Future<void> _assertSlotIsBookable({
    required String availabilityId,
    String? professionalId,
    String? serviceId,
    String? excludeAppointmentId,
  }) async {
    final availabilityRows = await _client
        .from('availability')
        .select('id, professional_id, service_id, is_available')
        .eq('id', availabilityId)
        .limit(1);

    if (availabilityRows.isEmpty) {
      throw Exception('El horario seleccionado no existe');
    }

    final slotRow = availabilityRows.first;
    final slotProfessionalId = slotRow['professional_id'] as String? ?? '';
    final slotServiceId = slotRow['service_id'] as String?;
    final slotIsAvailable = slotRow['is_available'] as bool? ?? false;

    if (professionalId != null && slotProfessionalId != professionalId) {
      throw Exception('El horario no pertenece al profesional seleccionado');
    }

    if (serviceId != null &&
        slotServiceId != null &&
        slotServiceId != serviceId) {
      throw Exception('El horario no corresponde al servicio seleccionado');
    }

    if (!slotIsAvailable) {
      throw Exception('Ese horario ya no está disponible. Elige otro.');
    }

    final blockedRows = await _client
        .from('appointments')
        .select('id')
        .eq('availability_id', availabilityId)
        .inFilter('status', _blockingAppointmentStatuses)
        .limit(1);

    final hasConflict = blockedRows.any((row) {
      final appointmentRow = row;
      return appointmentRow['id'] != excludeAppointmentId;
    });

    if (hasConflict) {
      throw Exception('Ese horario ya no está disponible. Elige otro.');
    }
  }
}
