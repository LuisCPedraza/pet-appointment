/// Representa un slot horario de disponibilidad de un profesional.
///
/// Los datos base vienen de la tabla `availability`.
/// La propiedad [isBooked] se calcula en [AppointmentService]
/// cruzando con la tabla `appointments` — no viene de la BD.
class AvailabilitySlot {
  const AvailabilitySlot({
    required this.id,
    required this.professionalId,
    required this.start,
    required this.end,
    this.serviceId,
    this.professionalName,
    this.isEnabled = true,
    this.isBooked = false,
  });

  final String id;
  final String professionalId;
  final DateTime start;
  final DateTime end;
  final String? serviceId;
  final String? professionalName;

  /// `true` si el slot está habilitado en la configuración del profesional.
  final bool isEnabled;

  /// `true` si este slot ya tiene una cita activa asociada.
  /// Se calcula externamente comparando contra los IDs reservados.
  final bool isBooked;

  /// Crea un [AvailabilitySlot] a partir de una fila de Supabase.
  ///
  /// Campos esperados: `id`, `professional_id`, `slot_start`, `slot_end`,
  /// `service_id` (nullable). Si el query hace join con `users`, también
  /// puede traer `users(full_name)`.
  factory AvailabilitySlot.fromJson(Map<String, dynamic> json) {
    final userMap = json['users'] as Map<String, dynamic>?;
    return AvailabilitySlot(
      id: json['id'] as String,
      professionalId: json['professional_id'] as String,
      start: DateTime.parse(json['slot_start'] as String).toLocal(),
      end: DateTime.parse(json['slot_end'] as String).toLocal(),
      serviceId: json['service_id'] as String?,
      professionalName: userMap?['full_name'] as String?,
      isEnabled: json['is_available'] as bool? ?? true,
    );
  }

  /// Devuelve una copia marcada como reservada o libre.
  AvailabilitySlot copyWith({bool? isEnabled, bool? isBooked}) {
    return AvailabilitySlot(
      id: id,
      professionalId: professionalId,
      start: start,
      end: end,
      serviceId: serviceId,
      professionalName: professionalName,
      isEnabled: isEnabled ?? this.isEnabled,
      isBooked: isBooked ?? this.isBooked,
    );
  }

  /// `true` si el slot ya comenzó (no se puede reservar).
  bool get isPast => start.isBefore(DateTime.now());

  /// `true` si el slot está disponible para reservar.
  bool get isAvailable => isEnabled && !isBooked && !isPast;

  @override
  String toString() =>
      'AvailabilitySlot(id: $id, start: $start, isEnabled: $isEnabled, isBooked: $isBooked)';
}
