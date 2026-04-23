import 'dart:typed_data';
import 'package:supabase_flutter/supabase_flutter.dart';

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

/// Servicio para gestionar mascotas del usuario autenticado.
class PetService {
  final SupabaseClient _client = Supabase.instance.client;

  bool _isMissingWeightColumnError(Object error) {
    return error is PostgrestException &&
        (error.code == 'PGRST204' ||
            error.message.toLowerCase().contains("'weight'"));
  }

  /// Sube una foto de mascota a Storage.
  ///
  /// Guarda en: `pet-photos/{userId}/{petId}/avatar.{ext}`
  /// Retorna la URL pública completa.
  Future<String?> uploadPetPhoto({
    required String userId,
    required String petId,
    required Uint8List photoBytes,
    String fileExtension = 'jpg',
  }) async {
    try {
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final path = '$userId/$petId/avatar_$timestamp.$fileExtension';

      await _client.storage
          .from('pet-photos')
          .uploadBinary(
            path,
            photoBytes,
            fileOptions: const FileOptions(cacheControl: '3600', upsert: true),
          );

      // Retorna URL pública del archivo subido
      final publicUrl = _client.storage.from('pet-photos').getPublicUrl(path);
      return publicUrl;
    } catch (e) {
      print('Error subiendo foto de mascota: $e');
      return null;
    }
  }

  /// Crea una nueva mascota para el usuario autenticado.
  ///
  /// [name]: Nombre de la mascota (requerido)
  /// [species]: Especie (Perro, Gato, Otro) — requerido
  /// [breed]: Raza (opcional)
  /// [birthDate]: Fecha de nacimiento (opcional)
  /// [weight]: Peso en kg (opcional)
  /// [notes]: Notas adicionales (opcional)
  /// [photoBytes]: Bytes de la imagen (opcional)
  ///
  /// Retorna el Pet creado con ID y URL de foto (si aplica).
  Future<Pet> createPet({
    required String name,
    required String species,
    String? breed,
    DateTime? birthDate,
    double? weight,
    String? notes,
    Uint8List? photoBytes,
  }) async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) {
      throw Exception('Usuario no autenticado');
    }

    final payload = {
      'owner_id': userId,
      'name': name,
      'species': species,
      'breed': breed,
      'birth_date': birthDate?.toIso8601String(),
      'weight': weight,
      'notes': notes,
      'photo_url': null, // Será actualizado si hay foto
    };

    dynamic response;
    try {
      // Inserta con peso cuando la columna existe.
      response = await _client.from('pets').insert(payload).select().single();
    } catch (e) {
      if (!_isMissingWeightColumnError(e)) rethrow;

      // Compatibilidad temporal: si falta la columna weight en BD,
      // reintenta sin ese campo para no romper el flujo de registro.
      final fallbackPayload = Map<String, dynamic>.from(payload)
        ..remove('weight');
      response = await _client
          .from('pets')
          .insert(fallbackPayload)
          .select()
          .single();
    }

    final petId = response['id'] as String;

    // Si hay foto, la sube y actualiza la URL
    String? photoUrl;
    if (photoBytes != null && photoBytes.isNotEmpty) {
      photoUrl = await uploadPetPhoto(
        userId: userId,
        petId: petId,
        photoBytes: photoBytes,
      );

      if (photoUrl != null) {
        await _client
            .from('pets')
            .update({'photo_url': photoUrl})
            .eq('id', petId);
      }
    }

    // Retorna el Pet completo
    return Pet(
      id: petId,
      ownerId: userId,
      name: name,
      species: species,
      breed: breed,
      birthDate: birthDate,
      weight: weight,
      notes: notes,
      photoUrl: photoUrl,
      createdAt: DateTime.parse(response['created_at'] as String),
    );
  }

  /// Obtiene todas las mascotas del usuario autenticado como Stream.
  /// Permite actualizaciones en tiempo real con Realtime.
  Stream<List<Pet>> userPetsStream() {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) {
      return Stream.value([]);
    }

    return _client
        .from('pets')
        .stream(primaryKey: ['id'])
        .eq('owner_id', userId)
        .order('created_at', ascending: false)
        .map((maps) => maps.map((map) => Pet.fromJson(map)).toList());
  }

  /// Obtiene todas las mascotas del usuario como Future (una sola lectura).
  Future<List<Pet>> getUserPets() async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) {
      return [];
    }

    final response = await _client
        .from('pets')
        .select()
        .eq('owner_id', userId)
        .order('created_at', ascending: false);

    return (response as List)
        .map((map) => Pet.fromJson(map as Map<String, dynamic>))
        .toList();
  }

  /// Obtiene una mascota por su ID.
  Future<Pet?> getPetById(String petId) async {
    try {
      final response = await _client
          .from('pets')
          .select()
          .eq('id', petId)
          .single();
      return Pet.fromJson(response as Map<String, dynamic>);
    } catch (e) {
      print('Error obteniendo mascota: $e');
      return null;
    }
  }

  /// Actualiza una mascota existente.
  Future<Pet?> updatePet({
    required String petId,
    String? name,
    String? species,
    String? breed,
    DateTime? birthDate,
    double? weight,
    String? notes,
    Uint8List? photoBytes,
  }) async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) {
      throw Exception('Usuario no autenticado');
    }

    final updateData = <String, dynamic>{};
    if (name != null) updateData['name'] = name;
    if (species != null) updateData['species'] = species;
    if (breed != null) updateData['breed'] = breed;
    if (birthDate != null)
      updateData['birth_date'] = birthDate.toIso8601String();
    if (weight != null) updateData['weight'] = weight;
    if (notes != null) updateData['notes'] = notes;

    // Si hay nueva foto, la sube primero
    if (photoBytes != null && photoBytes.isNotEmpty) {
      final photoUrl = await uploadPetPhoto(
        userId: userId,
        petId: petId,
        photoBytes: photoBytes,
      );
      if (photoUrl != null) {
        updateData['photo_url'] = photoUrl;
      }
    }

    try {
      dynamic response;
      try {
        response = await _client
            .from('pets')
            .update(updateData)
            .eq('id', petId)
            .select()
            .single();
      } catch (e) {
        if (!_isMissingWeightColumnError(e) ||
            !updateData.containsKey('weight')) {
          rethrow;
        }

        final fallbackUpdate = Map<String, dynamic>.from(updateData)
          ..remove('weight');
        response = await _client
            .from('pets')
            .update(fallbackUpdate)
            .eq('id', petId)
            .select()
            .single();
      }
      return Pet.fromJson(response as Map<String, dynamic>);
    } catch (e) {
      print('Error actualizando mascota: $e');
      return null;
    }
  }

  /// Elimina una mascota.
  Future<bool> deletePet(String petId) async {
    try {
      await _client.from('pets').delete().eq('id', petId);
      return true;
    } catch (e) {
      print('Error eliminando mascota: $e');
      return false;
    }
  }
}
