import 'package:flutter/material.dart';
import 'package:pet_appointment/config/theme.dart';
import 'package:pet_appointment/services/auth_service.dart';
import 'package:pet_appointment/utils/field_validators.dart';
import 'package:pet_appointment/utils/snackbar_helper.dart';
import 'package:pet_appointment/widgets/widgets.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _authService = AuthService();

  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _acceptedTerms = false;
  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _register() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    setState(() => _isLoading = true);

    try {
      // Delegamos toda la lógica de Supabase al servicio
      await _authService.register(
        email: _emailController.text.trim(),
        password: _passwordController.text,
        name: _nameController.text.trim(),
        phone: _phoneController.text.trim(),
      );

      if (mounted) {
        showAppSnackBar(
          context,
          '¡Cuenta creada! Revisa tu correo para confirmarla.',
        );
        Navigator.of(context).pushReplacementNamed('/login');
      }
    } on AuthException catch (e) {
      if (mounted) showAppSnackBar(context, e.message, color: AppColors.error);
    } catch (_) {
      if (mounted) {
        showAppSnackBar(
          context,
          'Error inesperado. Intenta de nuevo.',
          color: AppColors.error,
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
      appBar: _buildAppBar(context),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Comienza tu historia.',
              style: TextStyle(
                fontFamily: AppFonts.primary,
                fontWeight: FontWeight.w800,
                fontSize: 30,
                color: AppColors.onSurface,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Crea tu perfil y dales a tus mascotas el cuidado premium que merecen.',
              style: TextStyle(fontSize: 15, color: AppColors.onSurfaceVariant),
            ),
            const SizedBox(height: 32),

            FormCard(
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AppTextField(
                      label: 'Nombre completo',
                      hint: 'Juan Pérez',
                      controller: _nameController,
                      validator: FieldValidators.fullName,
                    ),
                    const SizedBox(height: 20),
                    AppTextField(
                      label: 'Teléfono',
                      hint: '+52 (55) 0000-0000',
                      controller: _phoneController,
                      keyboardType: TextInputType.phone,
                      autocorrect: false,
                      enableSuggestions: false,
                      validator: FieldValidators.phone,
                    ),
                    const SizedBox(height: 20),
                    AppTextField(
                      label: 'Correo electrónico',
                      hint: 'hola@sanctuary.com',
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      autocorrect: false,
                      enableSuggestions: false,
                      validator: FieldValidators.email,
                    ),
                    const SizedBox(height: 20),
                    AppPasswordField(
                      label: 'Contraseña',
                      controller: _passwordController,
                      validator: FieldValidators.password,
                    ),
                    const SizedBox(height: 20),
                    AppPasswordField(
                      label: 'Confirmar contraseña',
                      controller: _confirmPasswordController,
                      textInputAction: TextInputAction.done,
                      validator: FieldValidators.confirmPassword(
                        _passwordController,
                      ),
                    ),
                    const SizedBox(height: 24),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Checkbox(
                          value: _acceptedTerms,
                          onChanged: (value) =>
                              setState(() => _acceptedTerms = value ?? false),
                          activeColor: AppColors.primary,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                        Expanded(
                          child: Text.rich(
                            TextSpan(
                              text: 'Acepto los ',
                              style: TextStyle(
                                fontSize: 13,
                                color: AppColors.onSurfaceVariant,
                              ),
                              children: [
                                TextSpan(
                                  text: 'Términos de Servicio',
                                  style: TextStyle(
                                    color: AppColors.primary,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const TextSpan(text: ' y la '),
                                TextSpan(
                                  text: 'Política de Privacidad',
                                  style: TextStyle(
                                    color: AppColors.primary,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const TextSpan(text: '.'),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 28),
                    GradientPrimaryButton(
                      label: 'Crear cuenta',
                      onPressed: _acceptedTerms ? _register : null,
                      isLoading: _isLoading,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.white.withValues(alpha: 0.85),
      elevation: 0,
      scrolledUnderElevation: 0,
      title: const AppLogoTitle(),
      titleSpacing: 16,
      actions: [
        TextButton(
          onPressed: () =>
              Navigator.of(context).pushReplacementNamed('/login'),
          child: Text(
            'Iniciar sesión',
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: AppColors.primary,
              fontSize: 14,
            ),
          ),
        ),
        const SizedBox(width: 8),
      ],
    );
  }
}
