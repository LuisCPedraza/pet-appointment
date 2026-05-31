# PetAppointment

## Portada

**Proyecto:** PetAppointment

**Tipo de entrega:** Proyecto móvil académico y funcional

**Tecnología principal:** Flutter / Dart / Supabase

**Estado:** Entrega final preparada y validada en Android

**Repositorio de trabajo:** [README principal](README.md)

![Estado](https://img.shields.io/badge/Estado-Entrega%20final%20preparada-success?style=for-the-badge)
![Flutter](https://img.shields.io/badge/Flutter-3.x-02569B?style=for-the-badge&logo=flutter&logoColor=white)
![Dart](https://img.shields.io/badge/Dart-3.x-0175C2?style=for-the-badge&logo=dart&logoColor=white)
![License](https://img.shields.io/badge/License-MIT-green?style=for-the-badge)

### Datos académicos

| Campo | Detalle |
|---|---|
| **Nombre del proyecto** | PetAppointment |
| **Asignatura** | Proyecto de dispositivos móviles |
| **Entrega** | Final |
| **Plataforma objetivo** | Android, con base Flutter multiplataforma |
| **Responsables** | Completar con nombres del equipo |
| **Fecha** | 31 de mayo de 2026 |

## Resumen Ejecutivo

PetAppointment es una aplicación móvil desarrollada en Flutter para la gestión de citas veterinarias y servicios de grooming. La solución contempla autenticación por roles, administración de mascotas, reserva de citas con calendario, agenda profesional y documentación de soporte para evaluación académica.

## Autores

> Reemplazar estos campos con los nombres oficiales del equipo antes de la entrega.

| Nombre | Rol | Correo |
|---|---|---|
| Autor 1 | Desarrollo Flutter | Pendiente |
| Autor 2 | UI/UX | Pendiente |
| Autor 3 | Backend / Supabase | Pendiente |

## Objetivos del proyecto

### Objetivo general

Desarrollar una aplicación móvil funcional que permita a los dueños de mascotas reservar, gestionar y cancelar citas veterinarias o de grooming, proporcionando también herramientas de administración y control para los profesionales del servicio.

### Objetivos específicos

1. Implementar autenticación segura por roles con Supabase.
2. Gestionar mascotas, servicios y citas desde una interfaz móvil clara.
3. Visualizar disponibilidad en calendario y reducir errores de reserva.
4. Mantener una experiencia de usuario coherente y adaptable en pantalla móvil.
5. Dejar evidencia técnica, pruebas y documentación para sustentación final.

## Tabla de contenidos

- [Portada](#portada)
- [Resumen Ejecutivo](#resumen-ejecutivo)
- [Autores](#autores)
- [Objetivos del proyecto](#objetivos-del-proyecto)
- [Documentación de apoyo](#documentación-de-apoyo)
- [Estado actual](#estado-actual)
- [Funcionalidades verificadas](#funcionalidades-verificadas)
- [Evidencia de validación](#evidencia-de-validación)
- [Instalación y ejecución](#instalación-y-ejecución)
- [Configuración requerida](#configuración-requerida)
- [Estructura del proyecto](#estructura-del-proyecto)
- [Soporte y licencia](#soporte-y-licencia)

## Documentación de apoyo

| Entregable | Archivo |
|---|---|
| Documento técnico principal | [docs/PetAppointment_Documentacion_Tecnica.md](docs/PetAppointment_Documentacion_Tecnica.md) |
| Guía de desarrollador | [docs/DEVELOPER_GUIDE.md](docs/DEVELOPER_GUIDE.md) |
| Guía visual de estilo | [docs/STYLE_GUIDE.md](docs/STYLE_GUIDE.md) |
| Plan de pruebas | [docs/secciones/11-plan-de-pruebas.md](docs/secciones/11-plan-de-pruebas.md) |
| Requisitos no funcionales | [docs/secciones/13-requisitos-no-funcionales.md](docs/secciones/13-requisitos-no-funcionales.md) |
| Riesgos y mitigaciones | [docs/secciones/12-riesgos-y-mitigaciones.md](docs/secciones/12-riesgos-y-mitigaciones.md) |
| Roadmap | [docs/secciones/14-roadmap-y-futuras-mejoras.md](docs/secciones/14-roadmap-y-futuras-mejoras.md) |
| Checklist final | [docs/secciones/16-checklist-funcionalidad-100.md](docs/secciones/16-checklist-funcionalidad-100.md) |
| Evidencia de push Android | [docs/secciones/17-push-end-to-end-android.md](docs/secciones/17-push-end-to-end-android.md) |
| Entrega final solicitada | [entrega_final/entraga_final_proyecto.md](entrega_final/entraga_final_proyecto.md) |

## Estado Actual

| Área | Estado |
|---|---|
| Funcionalidad principal | Completada y validada en Android |
| UI/UX del flujo de cita | Mejorada y clara para el usuario |
| Generación de APK | Completada |
| Documentación de entrega | En preparación final |
| Compatibilidad iOS | Base Flutter presente, validación nativa pendiente |
| Métricas/analíticas | Pendiente de instrumentación |

## Funcionalidades Verificadas

- Registro e inicio de sesión por roles.
- Gestión de mascotas con foto.
- Selección visual de mascota para reservas.
- Calendario de citas con disponibilidad.
- Agenda profesional y actualización de estados.
- Soporte de notificaciones con inicialización defensiva.

## Evidencia de Validación

- APK de release generado: [build/app/outputs/flutter-apk/app-release.apk](build/app/outputs/flutter-apk/app-release.apk)
- Pruebas automáticas ejecutadas con éxito.
- Revisión manual en dispositivo reportada por el usuario como correcta.

## Instalación y Ejecución

```bash
flutter pub get
flutter run
```

Para compilar la entrega Android:

```bash
flutter build apk --release
```

Para instalar en un dispositivo conectado:

```bash
adb -s emulator-5554 install -r build/app/outputs/flutter-apk/app-release.apk
```

## Configuración Requerida

Crear un archivo `.env` en la raíz con estas variables:

- `SUPABASE_URL`
- `SUPABASE_ANON_KEY`

## Recomendaciones para la Entrega

1. Revisar [docs/PetAppointment_Documentacion_Tecnica.md](docs/PetAppointment_Documentacion_Tecnica.md) como documento base de sustentación.
2. Usar [entrega_final/entraga_final_proyecto.md](entrega_final/entraga_final_proyecto.md) como anexo de evaluación final.
3. Adjuntar el APK ubicado en [build/app/outputs/flutter-apk/app-release.apk](build/app/outputs/flutter-apk/app-release.apk) para la demo.

## Estructura del Proyecto

```text
lib/                 Lógica principal de Flutter
docs/                Documentación técnica, guía y evidencias
integration_test/    Pruebas de integración
test/                Pruebas unitarias y de widgets
android/             Configuración y build Android
ios/                 Configuración nativa iOS
supabase/            Migraciones y funciones de backend
```

## Soporte y Licencia

Si necesitas continuar la entrega o generar una nueva versión, revisa primero la documentación enlazada arriba. Este proyecto se distribuye bajo licencia MIT. Ver [LICENSE](LICENSE) para más detalles.
