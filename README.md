# PetAppointment

![Estado](https://img.shields.io/badge/Estado-En%20desarrollo-orange?style=for-the-badge)
![CI](https://img.shields.io/github/actions/workflow/status/LuisCPedraza/pet-appointment/test.yml?branch=develop&style=for-the-badge)
![Flutter](https://img.shields.io/badge/Flutter-3.x-02569B?style=for-the-badge&logo=flutter&logoColor=white)
![Dart](https://img.shields.io/badge/Dart-3.x-0175C2?style=for-the-badge&logo=dart&logoColor=white)
![License](https://img.shields.io/badge/License-MIT-green?style=for-the-badge)

PetAppointment es una aplicación multiplataforma (Flutter) para gestionar citas veterinarias y servicios de grooming. Permite a dueños de mascotas reservar citas, y a profesionales administrar su agenda y atender solicitudes.

---

## Tabla de contenidos
- [Características](#caracter%C3%ADsticas)
- [Estado del Proyecto](#estado-del-proyecto)
- [Quickstart](#quickstart)
- [Requisitos](#requisitos)
- [Desarrollo](#desarrollo)
- [Testing](#testing)
- [Branching y flujo Git](#branching-y-flujo-git)
- [Contribuir](#contribuir)
- [Contacto y Soporte](#contacto-y-soporte)
- [Licencia](#licencia)

---

## Características
- Registro e inicio de sesión (roles: cliente, profesional, admin).
- Gestión de mascotas y servicios.
- Reserva, reprogramación y cancelación de citas.
- Agenda profesional (vistas diarias/semanales).
- Notificaciones locales activas, registro remoto de tokens y cola de eventos en preparación de envío remoto.

## Estado del proyecto
El proyecto está en desarrollo activo. Las ramas oficiales son `main`, `develop` y `staging`.

## Quickstart
Instala Flutter (ver versión recomendada en `pubspec.yaml`) y ejecuta:

```bash
flutter pub get
flutter run
```

Para análisis estático y pruebas:

```bash
flutter analyze
flutter test
```

### Variables de entorno
Configura un archivo `.env` en la raíz con al menos:

- `SUPABASE_URL`
- `SUPABASE_ANON_KEY`

### Icono de la app
El icono de Android e iOS se genera desde [lib/images/Logo2.png](lib/images/Logo2.png) usando `flutter_launcher_icons`.

### Firma APK release
Para compilar un APK firmado, crea `android/key.properties` a partir de [android/key.properties.example](android/key.properties.example) y coloca el keystore en `android/app/upload-keystore.jks`.

Para firmar en GitHub Actions (workflow [build-apk.yml](.github/workflows/build-apk.yml)), configura estos secretos del repositorio:

- `ANDROID_KEYSTORE_BASE64`: contenido del archivo `.jks` en base64.
- `ANDROID_STORE_PASSWORD`: contraseña del keystore.
- `ANDROID_KEY_PASSWORD`: contraseña de la key.
- `ANDROID_KEY_ALIAS`: alias de la key (por ejemplo, `pet_appointment`).

En Windows PowerShell puedes generar el base64 así:

```powershell
[Convert]::ToBase64String([IO.File]::ReadAllBytes("android/app/upload-keystore.jks"))
```

El workflow ahora valida secrets y falla con mensaje explícito si falta alguno. Además, genera y publica dos artifacts firmados: APK y AAB.

## Requisitos
- Flutter SDK 3.x
- Git
- (Opcional) Cuenta Supabase para pruebas de integración

## Desarrollo
1. Crea una rama feature desde `develop` para tu cambio: `git checkout -b feature/mi-cambio develop`.
2. Mantén commits pequeños y revisables.
3. Abre PR hacia `develop` y asigna revisores.

## Testing
- Ejecuta pruebas unitarias con `flutter test`.
- Usa `flutter analyze` para mantener la calidad del código.
- Para validar push remoto en Android, sigue [docs/secciones/17-push-end-to-end-android.md](docs/secciones/17-push-end-to-end-android.md).

## Branching y flujo Git
- `main`: código listo para producción.
- `staging`: pre-release; aquí se integran cambios probados en `develop` para validación final.
- `develop`: integración de features activos. Haz PRs hacia `develop`.

Recomendación: usar `staging` como entorno donde se despliegan candidate builds antes de mergear a `main`.

## Contribuir
1. Lee `docs/README.md` y la guía de estilo en `docs/STYLE_GUIDE.md`.
2. Crea issues claros y asigna labels.
3. Sigue el flujo Git descrito arriba.

## Contacto y Soporte
Si tienes dudas, abre un issue o contacta al equipo por el canal del proyecto.

## Licencia
Este proyecto se distribuye bajo la licencia MIT. Ver [LICENSE](LICENSE) para más detalles.

## Guía rápida: añadir filtros por especialidad / ubicación

Pasos mínimos para añadir filtros por `specialty` y `location` en la app:

1. Esquema DB
	- Añadir columnas en la tabla `users` (o la tabla de profesionales si existe):
	  - `specialty` (text), `location` (text), `rating` (numeric) si aplica.
	- Crear migration SQL con valores por defecto y `NULL` seguro para datos existentes.

2. RLS y seguridad
	- Actualizar las políticas RLS que lean campos de `users` para que sigan aplicando.
	- Revisar policies que usen `select`/`filter` para permitir lectura de `specialty`/`location` a los roles que correspondan.

3. API / servicio
	- Actualizar `AppointmentService.fetchProfessionals()` para seleccionar `specialty, location, rating`.
	- Añadir parámetros opcionales a los métodos que obtienen profesionales para filtrar por `specialty` y/o `location`.

4. UI
	- Añadir campos/combos en el selector de profesionales: chips o dropdown para `specialty` y `location`.
	- Llamar al servicio con los filtros aplicados o filtrar localmente si los datos ya están cargados.
	- Mantener accesibilidad y estados (carga, vacío, error) consistentes.

5. Tests
	- Añadir tests unitarios para la serialización y el service layer.
	- Añadir widget tests para la UI: confirmar que al aplicar filtro aparecen sólo profesionales coincidentes.

Notas:
- Si la app debe soportar búsquedas geolocalizadas, considerar almacenar `location` con lat/lng y usar consultas geoespaciales en el servidor.
- Revisar el impacto en RLS: exponer más columnas puede requerir restricciones adicionales según política de privacidad.
