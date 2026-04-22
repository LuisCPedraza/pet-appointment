import 'package:flutter/material.dart';
import 'package:pet_appointment/config/theme.dart';
import 'package:pet_appointment/screens/otp_verification_screen.dart';
import 'package:pet_appointment/services/auth_service.dart';
import 'package:pet_appointment/utils/field_validators.dart';
import 'package:pet_appointment/widgets/widgets.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Pantalla donde el usuario ingresa su correo para recibir
/// el código OTP de recuperación de contraseña.
class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _authService = AuthService();
  final _emailController = TextEditingController();

  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _sendResetEmail() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    setState(() => _isLoading = true);

    try {
      await _authService.sendPasswordResetEmail(
        email: _emailController.text.trim(),
      );
      if (mounted) {
        setState(() => _isLoading = false);
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => OtpVerificationScreen(
              email: _emailController.text.trim(),
            ),
          ),
        );
      }
    } on AuthException catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.message),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } catch (_) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Error inesperado. Intenta de nuevo.'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: _buildAppBar(context),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
        child: _buildForm(),
      ),
    );
  }

  // ── Formulario de ingreso de correo ───────────────────────────────────────
  Widget _buildForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '¿Olvidaste tu contraseña?',
          style: TextStyle(
            fontFamily: 'Plus Jakarta Sans',
            fontWeight: FontWeight.w800,
            fontSize: 28,
            color: AppColors.onSurface,
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          'Ingresa el correo con el que te registraste y te enviaremos un enlace para recuperar tu acceso.',
          style: TextStyle(fontSize: 15, color: AppColors.onSurfaceVariant),
        ),
        const SizedBox(height: 32),

        // ── Tarjeta del formulario ───────────────────────────────────────
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 30,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppTextField(
                  label: 'Correo electrónico',
                  hint: 'hola@sanctuary.com',
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  validator: FieldValidators.email,
                ),
                const SizedBox(height: 28),

                // ── Botón enviar ─────────────────────────────────────────
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [AppColors.primary, Color(0xFF2F517A)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(18),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primary.withValues(alpha: 0.35),
                          blurRadius: 20,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _sendResetEmail,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        shadowColor: Colors.transparent,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(18),
                        ),
                      ),
                      child: _isLoading
                          ? const SizedBox(
                              width: 22,
                              height: 22,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Text(
                              'Enviar enlace de recuperación',
                              style: TextStyle(
                                fontFamily: 'Plus Jakarta Sans',
                                fontWeight: FontWeight.w700,
                                fontSize: 15,
                                color: Colors.white,
                              ),
                            ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.white.withValues(alpha: 0.85),
      elevation: 0,
      scrolledUnderElevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios_new_rounded),
        color: AppColors.onSurfaceVariant,
        onPressed: () => Navigator.of(context).pop(),
      ),
      title: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.pets, color: AppColors.primary, size: 26),
          const SizedBox(width: 8),
          const Text(
            'Pet Sanctuary',
            style: TextStyle(
              fontFamily: 'Plus Jakarta Sans',
              fontWeight: FontWeight.w800,
              fontSize: 20,
              color: AppColors.primary,
            ),
          ),
        ],
      ),
      centerTitle: true,
    );
  }
}
