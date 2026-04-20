# Guía de Desarrollador — PetAppointment

## Requisitos previos

| Herramienta | Versión mínima |
|---|---|
| Flutter | 3.41.1 (stable) |
| Dart SDK | 3.11.0 |
| Android SDK | 36+ |

El archivo `.env` **no está en el repositorio**. Créalo en la raíz del proyecto con:
```
SUPABASE_URL=https://tu-proyecto.supabase.co
SUPABASE_ANON_KEY=tu-clave-anonima
```
> Solicita las credenciales a un compañero. **Nunca subas este archivo a Git.**

---

## Estructura del proyecto

```
lib/
├── main.dart                   # Arranque: dotenv → Supabase → MyApp(AppTheme) → AppShell
│
├── config/
│   ├── theme.dart              # AppColors y AppTheme (fuente única de verdad visual)
│   └── config.dart             # Barrel de config/
│
├── widgets/
│   ├── app_shell.dart          # Shell de navegación: NavigationBar + body intercambiable
│   └── widgets.dart            # Barrel de widgets/
│
├── screens/
│   ├── home_screen.dart        # Pantalla de inicio (implementada)
│   ├── pets_screen.dart        # Mis Mascotas (placeholder)
│   ├── calendar_screen.dart    # Mis Citas (placeholder)
│   ├── profile_screen.dart     # Mi Perfil (placeholder)
│   └── screens.dart            # Barrel de screens/
│
└── sketch/
    └── main_sketch.dart        # Bosquejo visual de referencia (no modificar)
```

---

## Sistema de diseño

### Colores — `AppColors` en `lib/config/theme.dart`

**Nunca uses `Color(0xFF...)` directamente.** Usa siempre `AppColors`:

```dart
// ✅
color: AppColors.primary
// ❌
color: Color(0xFF025E9F)
```

| Token | Hex | Uso |
|---|---|---|
| `primary` | `#025E9F` | Botones principales, íconos activos |
| `primaryContainer` | `#73B2F9` | Fondos de elementos primarios, indicador de tab |
| `secondary` | `#006945` | Acciones secundarias |
| `secondaryContainer` | `#90F7C2` | Fondos de tarjetas secundarias |
| `tertiary` | `#7C40A1` | Acentos decorativos |
| `tertiaryContainer` | `#D896FE` | Fondos de tarjetas terciarias |
| `surface` | `#F5F7FA` | Fondo general de la app |
| `onSurface` | `#2C2F32` | Texto principal |
| `onSurfaceVariant` | `#595C5E` | Texto secundario, subtítulos |
| `error` | `#B31B25` | Estados de error |

### Tipografía — `TextTheme` en `lib/config/theme.dart`

**Nunca definas `TextStyle` manual.** Usa siempre el tema:

```dart
// ✅
style: Theme.of(context).textTheme.headlineLarge

// Para ajustes puntuales:
style: Theme.of(context).textTheme.headlineLarge?.copyWith(color: Colors.white)
```

| Rol | Tamaño | Uso |
|---|---|---|
| `headlineLarge` | 30 | Título principal de pantalla |
| `headlineMedium` | 24 | Título de sección |
| `headlineSmall` | 20 | Título de tarjeta |
| `bodyLarge` | 17 | Párrafo importante |
| `bodyMedium` | 15 | Texto descriptivo |
| `labelSmall` | 12 | Etiquetas en mayúsculas, badges |

---

## Navegación

`AppShell` es el contenedor fijo. Nunca pongas la `NavigationBar` dentro de una pantalla.

| Índice | Pantalla |
|---|---|
| 0 | `HomeScreen` |
| 1 | `PetsScreen` |
| 2 | `CalendarScreen` |
| 3 | `ProfileScreen` |

Para navegar a una pantalla secundaria (fuera de los tabs):
```dart
Navigator.push(context, MaterialPageRoute(builder: (_) => const OtraPantalla()));
```

---

## Archivos barrel

Cada carpeta tiene un barrel (ej. `screens/screens.dart`) que re-exporta todos sus archivos. Importa siempre el barrel, no el archivo individual:

```dart
// ✅
import 'package:pet_appointment/screens/screens.dart';
// ❌
import '../screens/home_screen.dart';
```

Al crear un archivo nuevo, agrégalo al barrel de su carpeta.

---

## Convenciones

- Archivos: `snake_case` → `home_screen.dart`
- Clases: `PascalCase` → `HomeScreen`
- Widgets privados (solo en un archivo): prefijo `_` → `_HeroSection`
- Si un widget crece, divídelo en subwidgets privados dentro del mismo archivo

