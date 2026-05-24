import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import 'package:pet_appointment/config/theme.dart';
import 'package:pet_appointment/services/auth_service.dart';
// field validators moved to widget file
import 'package:pet_appointment/screens/edit_profile/edit_profile.dart';

enum _PhotoAction { keepCurrent, gallery, camera }

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _authService = AuthService();

  late final TextEditingController _nameController;
  late final TextEditingController _phoneController;
  final _imagePicker = ImagePicker();

  XFile? _selectedPhoto;
  Uint8List? _selectedPhotoBytes;
  late String _currentPhotoUrl;

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: _authService.currentUserName);
    _phoneController = TextEditingController(
      text: _authService.currentUserPhone,
    );
    _currentPhotoUrl = _authService.currentUserPhotoUrl;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _pickPhoto(ImageSource source) async {
    final image = await _imagePicker.pickImage(
      source: source,
      imageQuality: 85,
      maxWidth: 1200,
    );

    if (image == null || !mounted) return;
    final bytes = await image.readAsBytes();
    if (!mounted) return;
    setState(() {
      _selectedPhoto = image;
      _selectedPhotoBytes = bytes;
    });
  }

  Future<void> _choosePhotoSource() async {
    if (_isLoading) return;

    final action = await showModalBottomSheet<_PhotoAction>(
      context: context,
      showDragHandle: true,
      builder: (sheetContext) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.photo_camera_back_outlined),
                title: const Text('Usar foto actual'),
                subtitle: const Text('Mantener la imagen ya guardada'),
                onTap: () =>
                    Navigator.of(sheetContext).pop(_PhotoAction.keepCurrent),
              ),
              ListTile(
                leading: const Icon(Icons.photo_library_outlined),
                title: const Text('Elegir de galería'),
                subtitle: const Text('Seleccionar una foto existente'),
                onTap: () =>
                    Navigator.of(sheetContext).pop(_PhotoAction.gallery),
              ),
              ListTile(
                leading: const Icon(Icons.photo_camera_outlined),
                title: const Text('Tomar foto con la cámara'),
                subtitle: const Text('Capturar una nueva imagen'),
                onTap: () =>
                    Navigator.of(sheetContext).pop(_PhotoAction.camera),
              ),
            ],
          ),
        );
      },
    );

    if (!mounted || action == null) return;

    if (action == _PhotoAction.keepCurrent) {
      setState(() {
        _selectedPhoto = null;
        _selectedPhotoBytes = null;
      });
      return;
    }

    await _pickPhoto(
      action == _PhotoAction.gallery ? ImageSource.gallery : ImageSource.camera,
    );
  }

  Future<void> _save() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    setState(() => _isLoading = true);

    String? uploadedPhotoUrl;

    if (_selectedPhoto != null) {
      try {
        final bytes = await _selectedPhoto!.readAsBytes();
        final ext = _selectedPhoto!.path.split('.').last;
        uploadedPhotoUrl = await _authService.uploadProfilePhoto(
          bytes: bytes,
          extension: ext,
        );
      } catch (_) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'No se pudo subir la foto. Guardaremos el resto de tus cambios.',
              ),
              backgroundColor: AppColors.error,
            ),
          );
        }
      }
    }

    try {
      await _authService.updateProfile(
        name: _nameController.text.trim(),
        phone: _phoneController.text.trim(),
        photoUrl: uploadedPhotoUrl,
      );

      if (uploadedPhotoUrl != null) {
        _currentPhotoUrl = uploadedPhotoUrl;
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Perfil actualizado correctamente.'),
            backgroundColor: AppColors.secondary,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );
        Navigator.of(context).pop(true); // indica que hubo cambios
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al guardar: ${e.toString()}'),
            backgroundColor: AppColors.error,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          color: AppColors.primary,
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'Editar perfil',
          style: TextStyle(
            fontFamily: 'Plus Jakarta Sans',
            fontWeight: FontWeight.w800,
            fontSize: 20,
            color: AppColors.primary,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            EditProfileAvatar(
              selectedPhotoBytes: _selectedPhotoBytes,
              currentPhotoUrl: _currentPhotoUrl,
              isLoading: _isLoading,
              onPickPhoto: _choosePhotoSource,
              userEmail: _authService.currentUserEmail,
            ),

            EditProfileFormCard(
              formKey: _formKey,
              nameController: _nameController,
              phoneController: _phoneController,
            ),
            const SizedBox(height: 32),

            // Botón guardar
            SizedBox(
              width: double.infinity,
              height: 52,
              child: FilledButton(
                onPressed: _isLoading ? null : _save,
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: AppColors.onPrimary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  disabledBackgroundColor: AppColors.primary.withValues(
                    alpha: 0.5,
                  ),
                ),
                child: _isLoading
                    ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.5,
                          color: Colors.white,
                        ),
                      )
                    : const Text(
                        'Guardar cambios',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
