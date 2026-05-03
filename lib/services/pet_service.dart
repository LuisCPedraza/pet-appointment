import 'dart:typed_data';
import 'package:pet_appointment/models/pet.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

export 'package:pet_appointment/models/pet.dart';

/// Servicio para gestionar mascotas del usuario autenticado.
class PetService {
  final SupabaseClient _client = Supabase.instance.client;
  static const List<String> _activeAppointmentStatuses = [
    'En espera',
    'Confirmada',
  ];

  String? _extractStoragePathFromPublicUrl(String? publicUrl) {
    if (publicUrl == null || publicUrl.isEmpty) return null;

    try {
      final uri = Uri.parse(publicUrl);
      final bucketIndex = uri.pathSegments.indexOf('pet-photos');
      if (bucketIndex == -1 || bucketIndex + 1 >= uri.pathSegments.length) {
        return null;
      }

      final relativeSegments = uri.pathSegments
          .sublist(bucketIndex + 1)
          .map(Uri.decodeComponent)
          .toList();

      if (relativeSegments.isEmpty) return null;
      return relativeSegments.join('/');
    } catch (_) {
      return null;
    }
  }

  Future<void> _deletePetPhotoByUrl(String? photoUrl) async {
    final path = _extractStoragePathFromPublicUrl(photoUrl);
    if (path == null || path.isEmpty) return;

    try {
      await _client.storage.from('pet-photos').remove([path]);
    } catch (e) {
      print('Error eliminando foto de mascota en storage: $e');
    }
  }

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
        .order('name', ascending: true)
        .map((maps) => maps.map((map) => Pet.fromJson(map)).toList());
  }

  /// Obtiene mascotas del usuario con la fecha de la última cita por mascota.
  ///
  /// Usa JOIN a appointments para calcular la última cita visible por RLS.
  Future<List<PetListItem>> getUserPetsWithLastAppointment() async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) return [];

    final response = await _client
        .from('pets')
        .select('''
          id,
          owner_id,
          name,
          species,
          breed,
          birth_date,
          weight,
          notes,
          photo_url,
          created_at,
          appointments!left (
            created_at,
            client_id
          )
        ''')
        .eq('owner_id', userId)
        .order('name', ascending: true);

    return (response as List).map((row) {
      final map = row as Map<String, dynamic>;
      final pet = Pet.fromJson(map);

      final appointmentsRaw = (map['appointments'] as List?) ?? const [];
      DateTime? latest;

      for (final item in appointmentsRaw) {
        final appt = item as Map<String, dynamic>;
        final createdAtRaw = appt['created_at'] as String?;
        if (createdAtRaw == null) continue;
        final dt = DateTime.tryParse(createdAtRaw);
        if (dt == null) continue;
        if (latest == null || dt.isAfter(latest)) {
          latest = dt;
        }
      }

      return PetListItem(pet: pet, lastAppointmentAt: latest);
    }).toList();
  }

  /// Retorna cuántas citas activas tiene una mascota.
  ///
  /// Se consideran activas las citas en estado `En espera` o `Confirmada`.
  Future<int> getActiveAppointmentsCount(String petId) async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) return 0;

    final response = await _client
        .from('appointments')
        .select('id')
        .eq('pet_id', petId)
        .inFilter('status', _activeAppointmentStatuses);

    return (response as List).length;
  }

  /// Indica si una mascota tiene citas activas pendientes de atención.
  Future<bool> hasActiveAppointments(String petId) async {
    return (await getActiveAppointmentsCount(petId)) > 0;
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
      return Pet.fromJson(response);
    } catch (e) {
      print('Error obteniendo mascota: $e');
      return null;
    }
  }

  /// Actualiza una mascota existente.
  Future<Pet?> updatePet({
    required String petId,
    required String name,
    required String species,
    required DateTime birthDate,
    String? breed,
    double? weight,
    String? notes,
    Uint8List? photoBytes,
    bool removePhoto = false,
  }) async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) {
      throw Exception('Usuario no autenticado');
    }

    final currentPet = await getPetById(petId);
    final oldPhotoUrl = currentPet?.photoUrl;

    String? newPhotoUrl;
    if (photoBytes != null && photoBytes.isNotEmpty) {
      newPhotoUrl = await uploadPetPhoto(
        userId: userId,
        petId: petId,
        photoBytes: photoBytes,
      );
    }

    final updateData = <String, dynamic>{
      'name': name,
      'species': species,
      'breed': breed,
      'birth_date': birthDate.toIso8601String(),
      'weight': weight,
      'notes': notes,
    };

    if (newPhotoUrl != null) {
      updateData['photo_url'] = newPhotoUrl;
    } else if (removePhoto) {
      updateData['photo_url'] = null;
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

      final updatedPet = Pet.fromJson(response as Map<String, dynamic>);

      final photoChanged =
          newPhotoUrl != null &&
          oldPhotoUrl != null &&
          oldPhotoUrl != newPhotoUrl;
      final photoRemoved = removePhoto && oldPhotoUrl != null;

      if (photoChanged || photoRemoved) {
        await _deletePetPhotoByUrl(oldPhotoUrl);
      }

      return updatedPet;
    } catch (e) {
      print('Error actualizando mascota: $e');
      return null;
    }
  }

  /// Elimina una mascota.
  Future<bool> deletePet(String petId) async {
    try {
      final currentPet = await getPetById(petId);

      await _client.from('pets').delete().eq('id', petId);

      await _deletePetPhotoByUrl(currentPet?.photoUrl);

      return true;
    } catch (e) {
      print('Error eliminando mascota: $e');
      return false;
    }
  }
}
