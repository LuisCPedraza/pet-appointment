/// Representa una cita en el sistema.
class AppointmentModel {
  const AppointmentModel({
    required this.id,
    required this.clientId,
    required this.clientName,
    required this.clientEmail,
    required this.petId,
    required this.petName,
    required this.petSpecies,
    required this.professionalId,
    required this.professionalName,
    required this.serviceId,
    required this.serviceName,
    required this.scheduledAt,
    required this.status,
    this.notes,
    this.createdAt,
    this.availabilityId,
  });

  final String id;
  final String clientId;
  final String clientName;
  final String clientEmail;
  final String petId;
  final String petName;
  final String petSpecies;
  final String professionalId;
  final String professionalName;
  final String serviceId;
  final String serviceName;
  final DateTime? scheduledAt;
  final String
  status; // 'En espera', 'Confirmada', 'En progreso', 'Atendida', 'Cancelada'
  final String? notes;
  final DateTime? createdAt;
  final String? availabilityId;

  /// Mapea desde un JSON de Supabase (con joins)
  factory AppointmentModel.fromJson(Map<String, dynamic> json) {
    String readString(List<String> keys) {
      for (final key in keys) {
        final value = json[key];
        if (value is String && value.isNotEmpty) {
          return value;
        }
      }
      return '';
    }

    Map<String, dynamic>? readMap(List<String> keys) {
      for (final key in keys) {
        final value = json[key];
        if (value is Map<String, dynamic>) {
          return value;
        }
        if (value is Map) {
          return value.cast<String, dynamic>();
        }
        if (value is List && value.isNotEmpty) {
          final first = value.first;
          if (first is Map<String, dynamic>) {
            return first;
          }
          if (first is Map) {
            return first.cast<String, dynamic>();
          }
        }
      }
      return null;
    }

    DateTime? readDateTime(List<String> keys) {
      for (final key in keys) {
        final value = json[key];
        if (value is String && value.isNotEmpty) {
          return DateTime.tryParse(value)?.toLocal();
        }
        if (value is Map<String, dynamic>) {
          final nested = value['slot_start'] ?? value['scheduled_at'];
          if (nested is String && nested.isNotEmpty) {
            return DateTime.tryParse(nested)?.toLocal();
          }
        }
        if (value is Map) {
          final nested = value['slot_start'] ?? value['scheduled_at'];
          if (nested is String && nested.isNotEmpty) {
            return DateTime.tryParse(nested)?.toLocal();
          }
        }
      }
      return null;
    }

    final clientData = readMap([
      'users',
      'client',
      'client_user',
      'appointments_client',
    ]);
    final professionalData = readMap([
      'users!appointments_professional_id_fkey',
      'professional',
      'professional_user',
      'appointments_professional',
    ]);
    final petData = readMap(['pets', 'pet']);
    final serviceData = readMap(['services', 'service']);
    final clientId = readString(['client_id']).isNotEmpty
        ? readString(['client_id'])
        : clientData?['id'] as String? ?? '';
    final clientName =
        clientData?['full_name'] as String? ?? readString(['client_name']);
    final clientEmail =
        clientData?['email'] as String? ?? readString(['client_email']);

    final professionalId = readString(['professional_id']);
    final professionalName =
        professionalData?['full_name'] as String? ??
        readString(['professional_name']);

    final petId = readString(['pet_id']).isNotEmpty
        ? readString(['pet_id'])
        : petData?['id'] as String? ?? '';
    final petName = petData?['name'] as String? ?? readString(['pet_name']);
    final petSpecies =
        petData?['species'] as String? ?? readString(['pet_species']);

    final serviceId = readString(['service_id']).isNotEmpty
        ? readString(['service_id'])
        : serviceData?['id'] as String? ?? '';
    final serviceName =
        serviceData?['name'] as String? ?? readString(['service_name']);

    final scheduledAt = readDateTime([
      'availability',
      'scheduled_at',
      'slot_start',
    ]);

    return AppointmentModel(
      id: json['id'] as String,
      clientId: clientId,
      clientName: clientName,
      clientEmail: clientEmail,
      petId: petId,
      petName: petName,
      petSpecies: petSpecies,
      professionalId: professionalId,
      professionalName: professionalName,
      serviceId: serviceId,
      serviceName: serviceName,
      scheduledAt: scheduledAt,
      status: json['status'] as String? ?? 'En espera',
      notes: json['notes'] as String?,
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'] as String)?.toLocal()
          : null,
      availabilityId: json['availability_id'] as String?,
    );
  }

  /// Copia con override de campos opcionales.
  AppointmentModel copyWith({
    String? id,
    String? clientId,
    String? clientName,
    String? clientEmail,
    String? petId,
    String? petName,
    String? petSpecies,
    String? professionalId,
    String? professionalName,
    String? serviceId,
    String? serviceName,
    DateTime? scheduledAt,
    String? status,
    String? notes,
    DateTime? createdAt,
    String? availabilityId,
  }) {
    return AppointmentModel(
      id: id ?? this.id,
      clientId: clientId ?? this.clientId,
      clientName: clientName ?? this.clientName,
      clientEmail: clientEmail ?? this.clientEmail,
      petId: petId ?? this.petId,
      petName: petName ?? this.petName,
      petSpecies: petSpecies ?? this.petSpecies,
      professionalId: professionalId ?? this.professionalId,
      professionalName: professionalName ?? this.professionalName,
      serviceId: serviceId ?? this.serviceId,
      serviceName: serviceName ?? this.serviceName,
      scheduledAt: scheduledAt ?? this.scheduledAt,
      status: status ?? this.status,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
      availabilityId: availabilityId ?? this.availabilityId,
    );
  }

  @override
  String toString() =>
      'AppointmentModel(id: $id, clientName: $clientName, petName: $petName, status: $status)';
}
