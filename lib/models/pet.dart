/// Modelo de datos para una mascota.
class Pet {
  final String id;
  final String ownerId;
  final String name;
  final String species; // 'Perro', 'Gato', 'Otro'
  final String? breed;
  final DateTime? birthDate;
  final double? weight;
  final String? notes;
  final String? photoUrl;
  final DateTime createdAt;

  Pet({
    required this.id,
    required this.ownerId,
    required this.name,
    required this.species,
    this.breed,
    this.birthDate,
    this.weight,
    this.notes,
    this.photoUrl,
    required this.createdAt,
  });

  /// Convierte de JSON (Supabase) a objeto Pet.
  factory Pet.fromJson(Map<String, dynamic> json) {
    return Pet(
      id: json['id'] as String,
      ownerId: json['owner_id'] as String,
      name: json['name'] as String,
      species: json['species'] as String,
      breed: json['breed'] as String?,
      birthDate: json['birth_date'] != null
          ? DateTime.parse(json['birth_date'] as String)
          : null,
      weight: json['weight'] != null
          ? (json['weight'] as num).toDouble()
          : null,
      notes: json['notes'] as String?,
      photoUrl: json['photo_url'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }
}

/// DTO para listado de mascotas con fecha de última cita.
class PetListItem {
  final Pet pet;
  final DateTime? lastAppointmentAt;

  PetListItem({required this.pet, required this.lastAppointmentAt});
}
