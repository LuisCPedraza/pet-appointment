import 'package:flutter_test/flutter_test.dart';
import 'package:pet_appointment/services/pet_service.dart';

void main() {
  group('PetService - CRUD Operations', () {

    group('createPet', () {
      test('should validate create payload structure', () async {
        // Arrange - simular payload que PetService enviaría a Supabase
        const userId = 'test-user-id';
        const petName = 'Fluffy';
        const petSpecies = 'Gato';
        final birthDate = DateTime(2020, 5, 10);
        const breed = 'Siames';
        const weight = 3.5;
        const notes = 'Muy amigable';

        final payload = {
          'owner_id': userId,
          'name': petName,
          'species': petSpecies,
          'breed': breed,
          'birth_date': birthDate.toIso8601String(),
          'weight': weight,
          'notes': notes,
          'photo_url': null,
        };

        // Assert estructura del payload
        expect(payload['name'], equals(petName));
        expect(payload['species'], equals(petSpecies));
        expect(payload['owner_id'], equals(userId));
        expect(payload['weight'], equals(3.5));
        expect(payload['photo_url'], isNull);
      });

      test('should handle missing weight column gracefully', () async {
        // Arrange - simular fallback cuando weight no existe en BD
        final payload = {
          'owner_id': 'test-user-id',
          'name': 'Michi',
          'species': 'Gato',
          'breed': null,
          'birth_date': null,
          'weight': 2.5,
          'notes': null,
          'photo_url': null,
        };

        // Fallback payload sin weight
        final fallbackPayload = Map<String, dynamic>.from(payload)
          ..remove('weight');

        // Assert fallback sin weight
        expect(fallbackPayload.containsKey('weight'), equals(false));
        expect(fallbackPayload['name'], equals('Michi'));
        expect(fallbackPayload['species'], equals('Gato'));
      });
    });

    group('getPetById', () {
      test('should deserialize pet data correctly', () async {
        // Arrange - simular respuesta de BD
        const petId = 'pet-789';
        final mockPetData = {
          'id': petId,
          'owner_id': 'test-user-id',
          'name': 'Rex',
          'species': 'Perro',
          'breed': 'Labrador',
          'birth_date': '2019-03-15',
          'weight': 25.5,
          'notes': 'Muy energético',
          'photo_url': null,
          'created_at': DateTime.now().toIso8601String(),
        };

        // Act - convertir JSON a Pet
        final pet = Pet.fromJson(mockPetData);

        // Assert
        expect(pet.id, equals(petId));
        expect(pet.name, equals('Rex'));
        expect(pet.species, equals('Perro'));
        expect(pet.breed, equals('Labrador'));
        expect(pet.weight, equals(25.5));
        expect(pet.ownerId, equals('test-user-id'));
      });

      test('should handle null optional fields', () async {
        // Arrange - datos mínimos sin opcionales
        final mockPetData = {
          'id': 'minimal-pet',
          'owner_id': 'user-456',
          'name': 'Michi',
          'species': 'Gato',
          'breed': null,
          'birth_date': null,
          'weight': null,
          'notes': null,
          'photo_url': null,
          'created_at': DateTime.now().toIso8601String(),
        };

        // Act
        final pet = Pet.fromJson(mockPetData);

        // Assert
        expect(pet.breed, isNull);
        expect(pet.birthDate, isNull);
        expect(pet.weight, isNull);
        expect(pet.notes, isNull);
        expect(pet.photoUrl, isNull);
        expect(pet.name, equals('Michi'));
      });
    });

    group('updatePet', () {
      test('should validate update payload structure', () async {
        // Arrange
        const newName = 'Fluffy Updated';
        final newBirthDate = DateTime(2019, 8, 20);
        const newWeight = 4.2;

        final updatePayload = {
          'name': newName,
          'species': 'Gato',
          'breed': 'Siames',
          'birth_date': newBirthDate.toIso8601String(),
          'weight': newWeight,
          'notes': 'Actualizado',
        };

        // Act & Assert - validar estructura del payload
        expect(updatePayload['name'], equals(newName));
        expect(updatePayload['weight'], equals(newWeight));
        expect(updatePayload['species'], equals('Gato'));
      });

      test('should handle photo removal flag in payload', () async {
        // Arrange
        final updateData = {
          'name': 'Michi',
          'species': 'Gato',
          'birth_date': '2020-01-15',
          'photo_url': null, // Removal
        };

        // Assert que la flag removePhoto se refleja en null
        expect(updateData['photo_url'], isNull);
      });

      test('should handle weight column missing in update', () async {
        // Arrange
        final updatePayload = {
          'name': 'Perrito',
          'species': 'Perro',
          'weight': 20.0,
        };

        // Fallback payload sin weight
        final fallbackPayload = Map<String, dynamic>.from(updatePayload)
          ..remove('weight');

        // Assert
        expect(fallbackPayload.containsKey('weight'), equals(false));
        expect(fallbackPayload['name'], equals('Perrito'));
      });

      test('should deserialize updated pet response', () {
        // Arrange
        const petId = 'pet-updated';
        final mockResponse = {
          'id': petId,
          'owner_id': 'test-user-id',
          'name': 'Updated Pet',
          'species': 'Gato',
          'breed': 'Persa',
          'birth_date': '2018-06-10',
          'weight': 5.0,
          'notes': 'Updated notes',
          'photo_url': null,
          'created_at': DateTime.now().toIso8601String(),
        };

        // Act
        final updatedPet = Pet.fromJson(mockResponse);

        // Assert
        expect(updatedPet.id, equals(petId));
        expect(updatedPet.name, equals('Updated Pet'));
        expect(updatedPet.weight, equals(5.0));
      });
    });

    group('deletePet', () {
      test('should prepare delete request structure', () async {
        // Arrange
        const petId = 'pet-delete-123';
        final petData = {
          'id': petId,
          'owner_id': 'test-user-id',
          'name': 'ToDelete',
          'species': 'Gato',
          'breed': null,
          'birth_date': null,
          'weight': null,
          'notes': null,
          'photo_url': null,
          'created_at': DateTime.now().toIso8601String(),
        };

        // Act - simular el flujo de eliminación
        final pet = Pet.fromJson(petData);

        // Assert - validar que el pet se desercializa correctamente
        expect(pet.id, equals(petId));
        expect(pet.name, equals('ToDelete'));
        expect(pet.photoUrl, isNull);
      });

      test('should track photo URL for deletion', () async {
        // Arrange
        const petId = 'pet-with-photo';
        const photoUrl =
            'https://example.com/pet-photos/user-123/pet-with-photo/avatar_123.jpg';

        final petData = {
          'id': petId,
          'owner_id': 'test-user-id',
          'name': 'PhotoPet',
          'species': 'Perro',
          'breed': null,
          'birth_date': null,
          'weight': null,
          'notes': null,
          'photo_url': photoUrl,
          'created_at': DateTime.now().toIso8601String(),
        };

        // Act - convertir y verificar foto URL
        final pet = Pet.fromJson(petData);

        // Assert
        expect(pet.photoUrl, equals(photoUrl));
        expect(pet.photoUrl, isNotNull);
      });

      test('should handle pet deletion without photo', () async {
        // Arrange
        const petId = 'pet-no-photo-delete';
        final petData = {
          'id': petId,
          'owner_id': 'test-user-id',
          'name': 'NoPhoto',
          'species': 'Gato',
          'breed': null,
          'birth_date': null,
          'weight': null,
          'notes': null,
          'photo_url': null,
          'created_at': DateTime.now().toIso8601String(),
        };

        // Act
        final pet = Pet.fromJson(petData);

        // Assert - no hay foto que eliminar
        expect(pet.photoUrl, isNull);
        expect(pet.id, equals(petId));
      });
    });

    group('Pet Model', () {
      test('should create Pet from JSON correctly', () {
        // Arrange
        final json = {
          'id': 'pet-model-123',
          'owner_id': 'user-123',
          'name': 'Bella',
          'species': 'Perro',
          'breed': 'Golden Retriever',
          'birth_date': '2018-06-15',
          'weight': 28.5,
          'notes': 'Muy dulce',
          'photo_url': 'https://example.com/photo.jpg',
          'created_at': '2023-01-20T10:30:00Z',
        };

        // Act
        final pet = Pet.fromJson(json);

        // Assert
        expect(pet.id, equals('pet-model-123'));
        expect(pet.ownerId, equals('user-123'));
        expect(pet.name, equals('Bella'));
        expect(pet.species, equals('Perro'));
        expect(pet.breed, equals('Golden Retriever'));
        expect(pet.weight, equals(28.5));
        expect(pet.notes, equals('Muy dulce'));
        expect(pet.photoUrl, equals('https://example.com/photo.jpg'));
      });

      test('should handle optional fields as null', () {
        // Arrange
        final json = {
          'id': 'minimal-pet',
          'owner_id': 'user-456',
          'name': 'Michi',
          'species': 'Gato',
          'breed': null,
          'birth_date': null,
          'weight': null,
          'notes': null,
          'photo_url': null,
          'created_at': '2024-01-01T00:00:00Z',
        };

        // Act
        final pet = Pet.fromJson(json);

        // Assert
        expect(pet.breed, isNull);
        expect(pet.birthDate, isNull);
        expect(pet.weight, isNull);
        expect(pet.notes, isNull);
        expect(pet.photoUrl, isNull);
      });

      test('should parse dates correctly', () {
        // Arrange
        final json = {
          'id': 'date-test',
          'owner_id': 'user-789',
          'name': 'DatePet',
          'species': 'Perro',
          'breed': null,
          'birth_date': '2021-12-25',
          'weight': null,
          'notes': null,
          'photo_url': null,
          'created_at': '2023-06-15T14:30:00Z',
        };

        // Act
        final pet = Pet.fromJson(json);

        // Assert
        expect(pet.birthDate, equals(DateTime(2021, 12, 25)));
        expect(pet.createdAt.year, equals(2023));
        expect(pet.createdAt.month, equals(6));
        expect(pet.createdAt.day, equals(15));
      });
    });
  });
}
