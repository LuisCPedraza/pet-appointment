# PetAppointment

![Estado](https://img.shields.io/badge/Estado-En%20desarrollo-orange?style=for-the-badge)
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
- Notificaciones (pendiente integración).

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
