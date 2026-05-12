import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:pet_appointment/config/theme.dart';
import 'package:pet_appointment/widgets/widgets.dart';
import 'package:pet_appointment/utils/field_validators.dart';

/// Widgets extraídos de EditProfileScreen para mantener la pantalla concentrada en la lógica.

class EditProfileAvatar extends StatelessWidget {
  const EditProfileAvatar({
    super.key,
    required this.selectedPhotoBytes,
    required this.currentPhotoUrl,
    required this.isLoading,
    required this.onPickPhoto,
    required this.userEmail,
  });

  final Uint8List? selectedPhotoBytes;
  final String currentPhotoUrl;
  final bool isLoading;
  final VoidCallback onPickPhoto;
  final String userEmail;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Center(
          child: Stack(
            children: [
              Container(
                width: 96,
                height: 96,
                decoration: BoxDecoration(
                  color: AppColors.primaryContainer.withValues(alpha: 0.3),
                  shape: BoxShape.circle,
                ),
                child: ClipOval(
                  child: selectedPhotoBytes != null
                      ? Image.memory(
                          selectedPhotoBytes!,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) => Icon(
                            Icons.person_rounded,
                            size: 46,
                            color: AppColors.primary,
                          ),
                        )
                      : (currentPhotoUrl.isNotEmpty
                            ? Image.network(
                                currentPhotoUrl,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) =>
                                    Icon(
                                      Icons.person_rounded,
                                      size: 46,
                                      color: AppColors.primary,
                                    ),
                              )
                            : Icon(
                                Icons.person_rounded,
                                size: 46,
                                color: AppColors.primary,
                              )),
                ),
              ),
              Positioned(
                right: 0,
                bottom: 0,
                child: GestureDetector(
                  onTap: isLoading ? null : onPickPhoto,
                  child: Container(
                    width: 34,
                    height: 34,
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2),
                    ),
                    child: const Icon(
                      Icons.photo_camera_rounded,
                      size: 16,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Center(
          child: TextButton(
            onPressed: isLoading ? null : onPickPhoto,
            child: const Text('Cambiar foto'),
          ),
        ),
        Center(
          child: Text(
            userEmail,
            style: TextStyle(
              fontSize: 13,
              color: AppColors.onSurfaceVariant,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        const SizedBox(height: 32),
      ],
    );
  }
}

class EditProfileFormCard extends StatelessWidget {
  const EditProfileFormCard({
    super.key,
    required this.formKey,
    required this.nameController,
    required this.phoneController,
  });

  final GlobalKey<FormState> formKey;
  final TextEditingController nameController;
  final TextEditingController phoneController;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 30,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Form(
        key: formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Información personal',
              style: TextStyle(
                fontFamily: 'Plus Jakarta Sans',
                fontWeight: FontWeight.w700,
                fontSize: 16,
                color: AppColors.onSurface,
              ),
            ),
            const SizedBox(height: 20),
            AppTextField(
              label: 'Nombre completo',
              hint: 'Tu nombre',
              controller: nameController,
              validator: FieldValidators.fullName,
              keyboardType: TextInputType.name,
            ),
            const SizedBox(height: 16),
            AppTextField(
              label: 'Teléfono',
              hint: '+1 (555) 000-0000',
              controller: phoneController,
              validator: FieldValidators.phone,
              keyboardType: TextInputType.phone,
              textInputAction: TextInputAction.done,
            ),
          ],
        ),
      ),
    );
  }
}
