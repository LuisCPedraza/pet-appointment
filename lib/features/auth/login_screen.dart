import 'package:flutter/material.dart';
import 'package:pet_appointment/config/theme.dart';
import 'package:pet_appointment/services/auth_service.dart';
import 'package:pet_appointment/utils/field_validators.dart';
import 'package:pet_appointment/utils/snackbar_helper.dart';
import 'package:pet_appointment/widgets/widgets.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _authService = AuthService();

  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    setState(() => _isLoading = true);

    try {
      await _authService.login(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );

      if (mounted) {
        Navigator.of(context).pushNamedAndRemoveUntil('/home', (_) => false);
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

  Future<void> _loginWithGoogle() async {
    setState(() => _isLoading = true);

    try {
      await _authService.signInWithGoogle();
      if (!mounted) return;
      Navigator.of(context).pushNamedAndRemoveUntil('/home', (_) => false);
    } on AuthException catch (e) {
      if (!mounted) return;
      showAppSnackBar(context, e.message, color: AppColors.error);
    } catch (_) {
      if (!mounted) return;
      showAppSnackBar(
        context,
        'Error iniciando sesión con Google. Intenta de nuevo.',
        color: AppColors.error,
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _loginWithGithub() async {
    setState(() => _isLoading = true);

    try {
      await _authService.signInWithGithub();
      if (!mounted) return;
      Navigator.of(context).pushNamedAndRemoveUntil('/home', (_) => false);
    } on AuthException catch (e) {
      if (!mounted) return;
      showAppSnackBar(context, e.message, color: AppColors.error);
    } catch (_) {
      if (!mounted) return;
      showAppSnackBar(
        context,
        'Error iniciando sesión con GitHub.',
        color: AppColors.error,
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _loginWithApple() async {
    setState(() => _isLoading = true);

    try {
      await _authService.signInWithApple();
      if (!mounted) return;
      Navigator.of(context).pushNamedAndRemoveUntil('/home', (_) => false);
    } on AuthException catch (e) {
      if (!mounted) return;
      showAppSnackBar(context, e.message, color: AppColors.error);
    } catch (_) {
      if (!mounted) return;
      showAppSnackBar(
        context,
        'Error iniciando sesión con Apple. Intenta de nuevo.',
        color: AppColors.error,
      );
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
            // --- Encabezado ---
            Text(
              'Bienvenido de vuelta.',
              style: TextStyle(
                fontFamily: AppFonts.primary,
                fontWeight: FontWeight.w800,
                fontSize: 30,
                color: AppColors.onSurface,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Inicia sesión para continuar cuidando a tus mascotas.',
              style: TextStyle(fontSize: 15, color: AppColors.onSurfaceVariant),
            ),
            const SizedBox(height: 32),

            // --- Tarjeta del formulario ---
            FormCard(
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // --- Correo ---
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

                    // --- Contraseña ---
                    AppPasswordField(
                      label: 'Contraseña',
                      controller: _passwordController,
                      textInputAction: TextInputAction.done,
                      validator: FieldValidators.password,
                    ),
                    const SizedBox(height: 12),

                    // --- ¿Olvidaste tu contraseña? ---
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: () =>
                            Navigator.of(context).pushNamed('/forgot-password'),
                        style: TextButton.styleFrom(
                          padding: EdgeInsets.zero,
                          minimumSize: Size.zero,
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                        child: Text(
                          '¿Olvidaste tu contraseña?',
                          style: TextStyle(
                            fontSize: 13,
                            color: AppColors.primary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 28),

                    // --- Botón Iniciar sesión ---
                    GradientPrimaryButton(
                      label: 'Iniciar sesión',
                      onPressed: _login,
                      isLoading: _isLoading,
                    ),
                    const SizedBox(height: 12),
                    // --- Botón Google ---
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        icon: const Icon(Icons.login_rounded),
                        label: const Text('Continuar con Google'),
                        onPressed: _isLoading ? null : _loginWithGoogle,
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          side: BorderSide(
                            color: AppColors.onSurfaceVariant.withValues(
                              alpha: 0.2,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    // --- Botón GitHub ---
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        icon: const Icon(Icons.code_rounded),
                        label: const Text('Continuar con GitHub'),
                        onPressed: _isLoading ? null : _loginWithGithub,
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          side: BorderSide(
                            color: AppColors.onSurfaceVariant.withValues(
                              alpha: 0.2,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    // --- Botón Apple ---
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        icon: Icon(Icons.apple),
                        label: const Text('Continuar con Apple'),
                        onPressed: _isLoading ? null : _loginWithApple,
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          side: BorderSide(
                            color: AppColors.onSurfaceVariant.withValues(
                              alpha: 0.2,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 32),

            // --- Link para registrarse ---
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  '¿Aún no tienes cuenta? ',
                  style: TextStyle(
                    fontSize: 14,
                    color: AppColors.onSurfaceVariant,
                  ),
                ),
                GestureDetector(
                  onTap: () =>
                      Navigator.of(context).pushReplacementNamed('/register'),
                  child: Text(
                    'Regístrate',
                    style: TextStyle(
                      fontSize: 14,
                      color: AppColors.primary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    final canPop = Navigator.of(context).canPop();
    return AppBar(
      backgroundColor: Colors.white.withValues(alpha: 0.85),
      elevation: 0,
      scrolledUnderElevation: 0,
      automaticallyImplyLeading: false,
      leading: IconButton(
        icon: const Icon(Icons.close_rounded),
        color: AppColors.onSurfaceVariant,
        onPressed: () {
          if (canPop) {
            Navigator.of(context).pop();
          } else {
            Navigator.of(context).pushReplacementNamed('/home');
          }
        },
      ),
      title: const AppLogoTitle(),
    );
  }
}
