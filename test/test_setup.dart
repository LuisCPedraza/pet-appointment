import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter/services.dart';

/// Inicializa Supabase con valores de prueba para evitar aserciones
/// en entornos de test donde no se cargó `.env` ni se llamó a `main()`.
Future<void> initTestSupabase() async {
  // Asegurar bindings para que los plugins de Flutter Test funcionen.
  TestWidgetsFlutterBinding.ensureInitialized();

  // Mock de SharedPreferences para evitar MissingPluginException
  SharedPreferences.setMockInitialValues(<String, Object>{});

  // Mockear el canal de plataforma usado por `app_links` para evitar
  // MissingPluginException en tests unitarios. Debe registrarse antes
  // de inicializar Supabase ya que Supabase puede consultar deep links
  // durante su inicialización.
  const appLinksChannel = MethodChannel('com.llfbandit.app_links/messages');
  appLinksChannel.setMockMethodCallHandler((MethodCall call) async {
    switch (call.method) {
      case 'getInitialAppLink':
      case 'getInitialAppLinkFromUri':
        return null;
      default:
        return null;
    }
  });

  try {
    await Supabase.initialize(
      url: 'http://127.0.0.1:8000',
      anonKey: 'test-anon-key',
    );
  } catch (_) {
    // Ignorar si ya está inicializado o si falla por entorno.
  }
}
