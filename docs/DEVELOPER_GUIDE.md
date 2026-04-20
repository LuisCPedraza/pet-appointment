# Guía de Desarrollador — PetAppointment

## Requisitos previos

| Herramienta | Versión mínima |
|---|---|
| Flutter | 3.41.1 (stable) |
| Dart SDK | 3.11.0 |
| Android SDK | 36+ |

Verifica tu entorno con:
```bash
flutter doctor
```

---

## Configuración inicial

### 1. Clonar el repositorio
```bash
git clone https://github.com/nicolas-202/pet-appointment.git
cd pet-appointment
```

### 2. Crear el archivo `.env`
El archivo `.env` **no está en el repositorio** (está en `.gitignore` por seguridad). Debes crearlo manualmente en la raíz del proyecto `pet-appointment/`:

```
SUPABASE_URL=https://tu-proyecto.supabase.co
SUPABASE_ANON_KEY=tu-clave-anonima
```

> Solicita las credenciales a un compañero de equipo. **Nunca subas este archivo a Git.**

### 3. Instalar dependencias
```bash
flutter pub get
```

### 4. Correr la app
```bash
flutter run
```

---

## Estructura del proyecto

```
lib/
├── main.dart                   # Punto de entrada: inicializa dotenv, Supabase y la app
│
├── config/
│   ├── theme.dart              # Colores (AppColors) y tema global (AppTheme)
│   └── config.dart             # Barrel: exporta todo lo de config/
│
├── widgets/
│   ├── app_shell.dart          # Contenedor de navegación principal (NavigationBar + tabs)
│   └── widgets.dart            # Barrel: exporta todo lo de widgets/
│
├── screens/
│   ├── home_screen.dart        # Pantalla de inicio (implementada)
│   ├── pets_screen.dart        # Mis Mascotas (placeholder)
│   ├── calendar_screen.dart    # Mis Citas (placeholder)
│   ├── profile_screen.dart     # Mi Perfil (placeholder)
│   └── screens.dart            # Barrel: exporta todas las screens
│
└── sketch/
    └── main_sketch.dart        # Bosquejo visual de referencia (no modificar)
```

---

## Dependencias principales

| Paquete | Uso |
|---|---|
| `supabase_flutter` | Backend: auth, base de datos, storage |
| `flutter_dotenv` | Carga variables de entorno desde `.env` |
| `google_fonts` | Tipografía: Plus Jakarta Sans |

---

## Sistema de diseño

### Colores — `AppColors` en `lib/config/theme.dart`

Todos los colores de la app están centralizados. **Nunca uses `Color(0xFF...)` directamente en un widget.** Usa siempre `AppColors`:

```dart
// ✅ Correcto
color: AppColors.primary

// ❌ Incorrecto
color: Color(0xFF025E9F)
```

| Token | Hex | Uso |
|---|---|---|
| `AppColors.primary` | `#025E9F` | Botones principales, íconos activos, énfasis |
| `AppColors.primaryContainer` | `#73B2F9` | Fondos de elementos primarios, indicador de tab |
| `AppColors.secondary` | `#006945` | Acciones secundarias, estado "atendida" |
| `AppColors.secondaryContainer` | `#90F7C2` | Fondos de tarjetas secundarias |
| `AppColors.tertiary` | `#7C40A1` | Acentos decorativos, estado "cancelada" |
| `AppColors.tertiaryContainer` | `#D896FE` | Fondos de tarjetas terciarias |
| `AppColors.surface` | `#F5F7FA` | Fondo general de la app |
| `AppColors.onSurface` | `#2C2F32` | Texto principal |
| `AppColors.onSurfaceVariant` | `#595C5E` | Texto secundario, subtítulos |
| `AppColors.error` | `#B31B25` | Estados de error |

### Tipografía — `TextTheme` en `lib/config/theme.dart`

Fuente: **Plus Jakarta Sans**. Usa siempre los roles del tema, no definas `TextStyle` manual:

```dart
// ✅ Correcto
style: Theme.of(context).textTheme.headlineLarge

// ❌ Incorrecto
style: TextStyle(fontSize: 30, fontWeight: FontWeight.w800)
```

| Rol | Tamaño | Peso | Uso típico |
|---|---|---|---|
| `headlineLarge` | 30 | 800 | Título principal de pantalla |
| `headlineMedium` | 24 | 700 | Título de sección |
| `headlineSmall` | 20 | 700 | Título de tarjeta |
| `bodyLarge` | 17 | 400 | Párrafo importante |
| `bodyMedium` | 15 | 400 | Texto descriptivo |
| `labelSmall` | 12 | 700 | Etiquetas en mayúsculas, badges |

Para ajustes puntuales usa `.copyWith()`:
```dart
style: Theme.of(context).textTheme.headlineLarge?.copyWith(
  color: Colors.white,
)
```

---

## Navegación

La navegación principal está en `AppShell` (`lib/widgets/app_shell.dart`). Tiene 4 tabs:

| Índice | Label | Pantalla |
|---|---|---|
| 0 | Home | `HomeScreen` |
| 1 | Pets | `PetsScreen` |
| 2 | Calendar | `CalendarScreen` |
| 3 | Profile | `ProfileScreen` |

### ¿Cómo agregar una nueva pantalla a los tabs?

1. Crea tu pantalla en `lib/screens/nueva_screen.dart`
2. Expórtala en `lib/screens/screens.dart`
3. Agrégala a `_screens` en `AppShell`
4. Agrega su `NavigationDestination` en la `NavigationBar`

### ¿Cómo navegar desde una pantalla a otra (sin tabs)?

```dart
Navigator.push(
  context,
  MaterialPageRoute(builder: (_) => const OtraPantalla()),
);
```

---

## Archivos barrel

El proyecto usa el patrón **barrel** para simplificar imports. En lugar de:

```dart
import '../config/theme.dart';
import '../widgets/app_shell.dart';
```

Se importa el barrel:

```dart
import 'package:pet_appointment/config/config.dart';
import 'package:pet_appointment/widgets/widgets.dart';
```

Cuando crees un archivo nuevo, agrégalo al barrel correspondiente:
```dart
// screens/screens.dart
export 'package:pet_appointment/screens/nueva_screen.dart';
```

---

## Variables de entorno

La app usa `flutter_dotenv` para leer el `.env`. Las variables disponibles son:

| Variable | Descripción |
|---|---|
| `SUPABASE_URL` | URL del proyecto Supabase |
| `SUPABASE_ANON_KEY` | Clave pública anónima de Supabase |

Si alguna variable falta, la app arranca igual pero sin conexión al backend. Verás este mensaje en consola:
```
Supabase no configurado: asegúrate de que .env contiene SUPABASE_URL y SUPABASE_ANON_KEY.
```

---

## Convenciones del proyecto

- **Nombres de archivos**: `snake_case` → `home_screen.dart`
- **Nombres de clases**: `PascalCase` → `HomeScreen`
- **Widgets privados** (solo usados en un archivo): prefijo `_` → `_HeroSection`
- **Un widget por responsabilidad**: si un widget crece, divídelo en subwidgets privados
- **No hardcodear colores ni tamaños de fuente**: siempre usar `AppColors` y `textTheme`

---

## Flujo de arranque de la app

```
main()
 └── WidgetsFlutterBinding.ensureInitialized()
 └── dotenv.load('.env')
 └── Supabase.initialize(url, anonKey)
 └── runApp(MyApp)
      └── MaterialApp(theme: AppTheme.light, home: AppShell)
           └── AppShell
                ├── NavigationBar (siempre visible)
                └── body: screens[currentIndex]
```
