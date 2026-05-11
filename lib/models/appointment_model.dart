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
    // Extrae datos del cliente (puede venir como Map o lista)
    var clientData = json['users'];
    String clientId = '';
    String clientName = '';
    String clientEmail = '';

    if (clientData != null) {
      if (clientData is Map) {
        clientId = clientData['id'] as String? ?? '';
        clientName = clientData['full_name'] as String? ?? '';
        clientEmail = clientData['email'] as String? ?? '';
      } else if (clientData is List && clientData.isNotEmpty) {
        final client = clientData[0] as Map<String, dynamic>?;
        if (client != null) {
          clientId = client['id'] as String? ?? '';
          clientName = client['full_name'] as String? ?? '';
          clientEmail = client['email'] as String? ?? '';
        }
      }
    }

    // Extrae datos del profesional desde el alias de relación
    String professionalName = '';
    final professionalKey = 'users!appointments_professional_id_fkey';
    if (json.containsKey(professionalKey)) {
      var professionalData = json[professionalKey];
      if (professionalData != null) {
        if (professionalData is Map) {
          professionalName = professionalData['full_name'] as String? ?? '';
        } else if (professionalData is List && professionalData.isNotEmpty) {
          final prof = professionalData[0] as Map<String, dynamic>?;
          if (prof != null) {
            professionalName = prof['full_name'] as String? ?? '';
          }
        }
      }
    }

    // Extrae datos de la mascota
    var petData = json['pets'];
    String petId = '';
    String petName = '';
    String petSpecies = '';

    if (petData != null) {
      if (petData is Map) {
        petId = petData['id'] as String? ?? '';
        petName = petData['name'] as String? ?? '';
        petSpecies = petData['species'] as String? ?? '';
      } else if (petData is List && petData.isNotEmpty) {
        final pet = petData[0] as Map<String, dynamic>?;
        if (pet != null) {
          petId = pet['id'] as String? ?? '';
          petName = pet['name'] as String? ?? '';
          petSpecies = pet['species'] as String? ?? '';
        }
      }
    }

    // Extrae datos del servicio
    var serviceData = json['services'];
    String serviceId = '';
    String serviceName = '';

    if (serviceData != null) {
      if (serviceData is Map) {
        serviceId = serviceData['id'] as String? ?? '';
        serviceName = serviceData['name'] as String? ?? '';
      } else if (serviceData is List && serviceData.isNotEmpty) {
        final service = serviceData[0] as Map<String, dynamic>?;
        if (service != null) {
          serviceId = service['id'] as String? ?? '';
          serviceName = service['name'] as String? ?? '';
        }
      }
    }

    // Extrae la hora del slot de availability
    var availabilityData = json['availability'];
    DateTime? scheduledAt;

    if (availabilityData != null) {
      if (availabilityData is Map && availabilityData['slot_start'] != null) {
        scheduledAt = DateTime.tryParse(
          availabilityData['slot_start'] as String,
        )?.toLocal();
      } else if (availabilityData is List &&
          availabilityData.isNotEmpty &&
          availabilityData[0] is Map) {
        final avail = availabilityData[0] as Map<String, dynamic>;
        if (avail['slot_start'] != null) {
          scheduledAt = DateTime.tryParse(
            avail['slot_start'] as String,
          )?.toLocal();
        }
      }
    }

    return AppointmentModel(
      id: json['id'] as String,
      clientId: clientId.isNotEmpty
          ? clientId
          : (json['client_id'] as String? ?? ''),
      clientName: clientName,
      clientEmail: clientEmail,
      petId: petId.isNotEmpty ? petId : (json['pet_id'] as String? ?? ''),
      petName: petName,
      petSpecies: petSpecies,
      professionalId: json['professional_id'] as String,
      professionalName: professionalName,
      serviceId: serviceId.isNotEmpty
          ? serviceId
          : (json['service_id'] as String? ?? ''),
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
