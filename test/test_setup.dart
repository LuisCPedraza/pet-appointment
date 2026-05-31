import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Inicializa Supabase con valores de prueba para evitar aserciones
/// en entornos de test donde no se cargó `.env` ni se llamó a `main()`.
Future<void> initTestSupabase() async {
  // Asegurar bindings para que los plugins de Flutter Test funcionen.
  TestWidgetsFlutterBinding.ensureInitialized();

  // Mock de SharedPreferences para evitar MissingPluginException
  SharedPreferences.setMockInitialValues(<String, Object>{});

  try {
    await Supabase.initialize(
      url: 'http://127.0.0.1:8000',
      anonKey: 'test-anon-key',
    );
  } catch (_) {
    // Ignorar si ya está inicializado o si falla por entorno.
  }
}
