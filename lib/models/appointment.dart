class Appointment {
  final String id;
  final DateTime startsAt;
  final String clientName;
  final String petName;
  final String serviceName;
  final String status; // e.g. scheduled, cancelled, completed

  Appointment({
    required this.id,
    required this.startsAt,
    required this.clientName,
    required this.petName,
    required this.serviceName,
    required this.status,
  });

  factory Appointment.fromMap(Map<String, dynamic> m) => Appointment(
        id: m['id'] as String,
        startsAt: DateTime.parse(m['starts_at'] as String),
        clientName: m['client_name'] as String? ?? '',
        petName: m['pet_name'] as String? ?? '',
        serviceName: m['service_name'] as String? ?? '',
        status: m['status'] as String? ?? 'scheduled',
      );

  Map<String, dynamic> toMap() => {
        'id': id,
        'starts_at': startsAt.toIso8601String(),
        'client_name': clientName,
        'pet_name': petName,
        'service_name': serviceName,
        'status': status,
      };
}
