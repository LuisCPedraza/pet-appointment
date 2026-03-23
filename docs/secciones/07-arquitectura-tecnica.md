## 7. Arquitectura Técnica

### 7.1 Estructura del Proyecto Flutter

```
pet_appointment/
├── lib/
│   ├── main.dart                    # Punto de entrada de la aplicación
│   ├── app.dart                     # Widget raíz, configuración de tema y router
│   │
│   ├── core/                        # Código transversal reutilizable
│   │   ├── constants/
│   │   │   ├── app_colors.dart
│   │   │   ├── app_strings.dart
│   │   │   └── supabase_constants.dart
│   │   ├── errors/
│   │   │   ├── failures.dart
│   │   │   └── exceptions.dart
│   │   ├── network/
│   │   │   └── supabase_client.dart  # Singleton del cliente Supabase
│   │   ├── router/
│   │   │   └── app_router.dart       # Configuración Go Router + guards por rol
│   │   ├── theme/
│   │   │   └── app_theme.dart
│   │   └── utils/
│   │       ├── date_helpers.dart
│   │       └── validators.dart
│   │
│   ├── features/                    # Módulos por funcionalidad (Feature-First)
│   │   ├── auth/
│   │   │   ├── data/
│   │   │   │   ├── datasources/
│   │   │   │   │   └── auth_supabase_datasource.dart
│   │   │   │   └── repositories/
│   │   │   │       └── auth_repository_impl.dart
│   │   │   ├── domain/
│   │   │   │   ├── entities/
│   │   │   │   │   └── app_user.dart
│   │   │   │   ├── repositories/
│   │   │   │   │   └── auth_repository.dart
│   │   │   │   └── usecases/
│   │   │   │       ├── sign_in_usecase.dart
│   │   │   │       ├── sign_up_usecase.dart
│   │   │   │       └── sign_out_usecase.dart
│   │   │   └── presentation/
│   │   │       ├── providers/
│   │   │       │   └── auth_provider.dart
│   │   │       └── screens/
│   │   │           ├── login_screen.dart
│   │   │           ├── register_screen.dart
│   │   │           └── forgot_password_screen.dart
│   │   │
│   │   ├── pets/                    # Gestión de mascotas
│   │   │   └── [misma estructura data/domain/presentation]
│   │   │
│   │   ├── appointments/            # Reserva y gestión de citas
│   │   │   └── [misma estructura data/domain/presentation]
│   │   │
│   │   ├── calendar/                # Calendario y disponibilidad
│   │   │   └── [misma estructura data/domain/presentation]
│   │   │
│   │   ├── professional/            # Panel del profesional
│   │   │   └── [misma estructura data/domain/presentation]
│   │   │
│   │   ├── admin/                   # Panel de administración
│   │   │   └── [misma estructura data/domain/presentation]
│   │   │
│   │   └── notifications/           # Notificaciones locales y push
│   │       └── [misma estructura data/domain/presentation]
│   │
│   └── shared/                      # Widgets y componentes compartidos
│       ├── widgets/
│       │   ├── custom_button.dart
│       │   ├── custom_text_field.dart
│       │   ├── appointment_card.dart
│       │   ├── pet_avatar.dart
│       │   └── loading_overlay.dart
│       └── extensions/
│           └── context_extensions.dart
│
├── test/                            # Pruebas automatizadas
│   ├── unit/
│   ├── widget/
│   └── integration/
│
├── supabase/                        # Archivos de configuración Supabase
│   ├── migrations/                  # Scripts SQL de migración
│   │   ├── 001_initial_schema.sql
│   │   ├── 002_rls_policies.sql
│   │   └── 003_seed_data.sql
│   └── functions/                   # Edge Functions (Deno)
│       ├── send-appointment-reminder/
│       │   └── index.ts
│       └── send-whatsapp-notification/
│           └── index.ts
│
├── .github/
│   └── workflows/
│       ├── ci.yml                   # Tests y lint en cada PR
│       └── release-apk.yml          # Build y release del APK
│
├── docs/                            # Documentación adicional
│   ├── architecture.md
│   ├── api-reference.md
│   └── screenshots/
│
├── pubspec.yaml
├── pubspec.lock
├── analysis_options.yaml
└── README.md
```

### 7.2 Estructura del Repositorio GitHub

```
pet-appointment/                     # Repositorio raíz
├── .github/
│   ├── workflows/
│   │   ├── ci.yml
│   │   └── release-apk.yml
│   ├── ISSUE_TEMPLATE/
│   │   ├── bug_report.md
│   │   └── feature_request.md
│   └── pull_request_template.md
│
├── android/                         # Configuración nativa Android (auto-generado por Flutter)
├── ios/                             # Configuración nativa iOS
├── lib/                             # Código fuente Flutter (ver sección 7.1)
├── test/                            # Pruebas
├── supabase/                        # Migraciones y Edge Functions
├── docs/                            # Documentación del proyecto
│   ├── PetAppointment_Documentacion_Tecnica.md
│   ├── api-reference.md
│   └── screenshots/
│
├── pubspec.yaml
├── analysis_options.yaml
├── .gitignore
├── .env.example                     # Variables de entorno de ejemplo (sin datos reales)
└── README.md
```

### 7.3 Conexión Flutter ↔ Supabase

#### Configuración inicial del cliente

```dart
// lib/main.dart
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'app.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: const String.fromEnvironment('SUPABASE_URL'),
    anonKey: const String.fromEnvironment('SUPABASE_ANON_KEY'),
  );

  runApp(const PetAppointmentApp());
}

// Acceso global al cliente (desde cualquier parte de la app)
final supabase = Supabase.instance.client;
```

#### Consulta de citas del cliente autenticado

```dart
// lib/features/appointments/data/datasources/appointment_supabase_datasource.dart
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../domain/entities/appointment.dart';

class AppointmentSupabaseDataSource {
  final SupabaseClient _client;

  AppointmentSupabaseDataSource(this._client);

  /// Obtiene todas las citas del usuario autenticado, con joins a pets y services
  Future<List<Map<String, dynamic>>> getClientAppointments() async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) throw Exception('Usuario no autenticado');

    final response = await _client
        .from('appointments')
        .select('''
          id,
          status,
          notes,
          created_at,
          pets (id, name, species),
          services (id, name, duration_minutes, price),
          available_slots (slot_start, slot_end),
          professionals (
            users (full_name)
          )
        ''')
        .eq('client_id', userId)
        .order('created_at', ascending: false);

    return List<Map<String, dynamic>>.from(response);
  }

  /// Crea una nueva cita y marca el slot como ocupado (transacción lógica)
  Future<Map<String, dynamic>> createAppointment({
    required String petId,
    required String professionalId,
    required String serviceId,
    required String slotId,
    String? notes,
  }) async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) throw Exception('Usuario no autenticado');

    // Verificar disponibilidad antes de insertar (optimistic locking simple)
    final slotCheck = await _client
        .from('available_slots')
        .select('is_available')
        .eq('id', slotId)
        .single();

    if (slotCheck['is_available'] != true) {
      throw Exception('El horario seleccionado ya no está disponible');
    }

    // Crear la cita
    final appointment = await _client.from('appointments').insert({
      'client_id': userId,
      'pet_id': petId,
      'professional_id': professionalId,
      'service_id': serviceId,
      'slot_id': slotId,
      'status': 'En espera',
      'notes': notes,
    }).select().single();

    // Marcar el slot como ocupado
    await _client
        .from('available_slots')
        .update({'is_available': false})
        .eq('id', slotId);

    return appointment;
  }

  /// Cancela una cita y libera el slot
  Future<void> cancelAppointment(String appointmentId, String slotId) async {
    await _client
        .from('appointments')
        .update({'status': 'Cancelada'})
        .eq('id', appointmentId);

    await _client
        .from('available_slots')
        .update({'is_available': true})
        .eq('id', slotId);
  }
}
```

#### Suscripción Realtime a cambios de citas

```dart
// lib/features/appointments/presentation/providers/appointments_realtime_provider.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final appointmentsRealtimeProvider = StreamProvider.autoDispose<List<Map<String, dynamic>>>((ref) {
  final supabase = Supabase.instance.client;
  final userId = supabase.auth.currentUser?.id;

  // Canal Realtime para las citas del usuario actual
  final stream = supabase
      .from('appointments')
      .stream(primaryKey: ['id'])
      .eq('client_id', userId!)
      .order('created_at', ascending: false);

  return stream;
});

// Uso en un widget
class AppointmentListScreen extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appointmentsAsync = ref.watch(appointmentsRealtimeProvider);

    return appointmentsAsync.when(
      data: (appointments) => ListView.builder(
        itemCount: appointments.length,
        itemBuilder: (context, index) => AppointmentCard(
          appointment: appointments[index],
        ),
      ),
      loading: () => const CircularProgressIndicator(),
      error: (error, stack) => Text('Error: $error'),
    );
  }
}
```

---

