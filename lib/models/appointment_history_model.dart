/// Representa un registro en el historial de cambios de estado de una cita.
class AppointmentHistoryModel {
  const AppointmentHistoryModel({
    required this.id,
    required this.appointmentId,
    this.previousStatus,
    required this.newStatus,
    this.changedById,
    this.changedByName,
    required this.changedAt,
  });

  final String id;
  final String appointmentId;
  final String? previousStatus;
  final String newStatus;
  final String? changedById;
  final String? changedByName;
  final DateTime changedAt;

  /// Mapea desde un JSON de Supabase
  factory AppointmentHistoryModel.fromJson(Map<String, dynamic> json) {
    // Extrae datos del usuario que cambió el estado
    var userData = json['users'];
    String? changedById = json['changed_by'] as String?;
    String? changedByName;

    if (userData != null) {
      if (userData is Map) {
        changedByName = userData['full_name'] as String?;
      } else if (userData is List && userData.isNotEmpty) {
        final user = userData[0] as Map<String, dynamic>?;
        if (user != null) {
          changedByName = user['full_name'] as String?;
        }
      }
    }

    return AppointmentHistoryModel(
      id: json['id'] as String,
      appointmentId: json['appointment_id'] as String,
      previousStatus: json['previous_status'] as String?,
      newStatus: json['new_status'] as String,
      changedById: changedById,
      changedByName: changedByName,
      changedAt: DateTime.parse(
        json['changed_at'] as String,
      ).toLocal(),
    );
  }

  /// Convierte a JSON para Supabase
  Map<String, dynamic> toJson() {
    return {
      'appointment_id': appointmentId,
      'previous_status': previousStatus,
      'new_status': newStatus,
      'changed_by': changedById,
      'changed_at': changedAt.toUtc().toIso8601String(),
    };
  }

  /// Crea una copia con propiedades opcionales reemplazadas
  AppointmentHistoryModel copyWith({
    String? id,
    String? appointmentId,
    String? previousStatus,
    String? newStatus,
    String? changedById,
    String? changedByName,
    DateTime? changedAt,
  }) {
    return AppointmentHistoryModel(
      id: id ?? this.id,
      appointmentId: appointmentId ?? this.appointmentId,
      previousStatus: previousStatus ?? this.previousStatus,
      newStatus: newStatus ?? this.newStatus,
      changedById: changedById ?? this.changedById,
      changedByName: changedByName ?? this.changedByName,
      changedAt: changedAt ?? this.changedAt,
    );
  }

  @override
  String toString() =>
      'AppointmentHistoryModel(id: $id, appointmentId: $appointmentId, previousStatus: $previousStatus, newStatus: $newStatus, changedBy: $changedByName, changedAt: $changedAt)';
}
