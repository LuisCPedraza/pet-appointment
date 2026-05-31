# Evidencias y Plan de Entrega Final

Fecha: 30 de mayo de 2026

Objetivo
- Reunir evidencias concretas para validar QA, UX/UI, KPIs y plan de soporte/mantenimiento requerido por la entrega final.

1) Evidencias técnicas a adjuntar (por el equipo)
- Código fuente completo y documentado: repositorio Git con rama principal y tags de versión.
- Diagrama de arquitectura (mermaid incluido en docs/PetAppointment_Documentacion_Tecnica.md).
- Migraciones SQL en supabase/migrations/* con RLS y seeds.
- Build APK release generado: build/app/outputs/flutter-apk/app-release.apk (adjuntar hash y tamaño).

2) QA (evidencias y comandos)
- Reportes de tests unitarios y de widget: ejecutar

```bash
flutter test --coverage
genhtml coverage/lcov.info -o coverage/html
```
- Adjuntar: coverage/lcov.info y screenshots del reporte HTML.
- Reportes de integración (integration_test): adjuntar logs y vídeo corto si aplica.
- Crash reports: integrar Crashlytics y exportar última 30 días o periodo de pruebas.

3) UX/UI (evidencias)
- Prototipos: Figma/Sketch/Adobe (archivo o link).
- Onboarding: screenshots del flujo de onboarding en Android (3 pantallas principales).
- Tests de usabilidad: resumen de sesiones (n personas, tareas clave, éxito/fallo, tiempo medio por tarea).

4) Accesibilidad
- Checklist de accesibilidad (WCAG móvil): contraste, etiquetas Semantics, tamaños táctiles, navegación por teclado y lector de pantalla.
- Evidencia: capturas con TalkBack (Android) o VoiceOver (iOS) mostrando lectura de elementos críticos.

5) KPIs y Analítica
- Recomendación mínima: integrar Firebase Analytics o Amplitude. Eventos mínimos a instrumentar:
  - `sign_up`, `login`, `create_appointment`, `cancel_appointment`, `open_app`, `complete_onboarding`.
- Entregable: dar acceso al dashboard o exportar CSV de eventos (periodo de pruebas).

6) Plan de despliegue y mantenimiento
- Credenciales/Accesos: Google Play Console (rol administrador o editor), Apple Developer (si aplica).
- Procedimiento de publicación: pasos para subir APK/AAB, firmar con keystore (key.properties) y release notes.
- SLA básico: 72 horas para bugs críticos (P0), 2 semanas para P1, parches emergentes fuera de ciclo si aplica.

7) Checklist rápido para completar antes de entrega
- [ ] Generar y adjuntar reportes de tests + cobertura.
- [~] Añadir instrumentación de analítica y pruebas de Crashlytics. (instrumentación mínima mediante `AnalyticsService` y tabla `app_events` implementada; Crashlytics no integrado)
- [ ] Ejecutar pruebas de rendimiento y documentar (arranque y reserva).
- [ ] Registrar evidencia offline (test sin red) y captura de logs.
- [ ] Hacer revisión básica de accesibilidad y corregir los items críticos.

- [x] Generar y adjuntar reportes de tests + cobertura. (ver `docs/entrega_final/lcov.info` y `docs/entrega_final/coverage-lcov.info`)
- [ ] Añadir instrumentación de analítica y pruebas de Crashlytics. (pendiente)
- [ ] Ejecutar pruebas de rendimiento y documentar (arranque y reserva). (pendiente)
 - [x] Registrar evidencia offline (test sin red) y captura de logs. (tests ajustados para modo offline/mocks; `test/test_setup.dart` incluido)
- [ ] Hacer revisión básica de accesibilidad y corregir los items críticos. (parcial)

8) Cómo puedo ayudarte ahora
- Puedo instrumentar eventos básicos de Firebase Analytics en el código Flutter y añadir Crashlytics.
- Puedo configurar y ejecutar las pruebas y subir los artefactos al repo/docs/entrega_final.
- Puedo crear un README con pasos de publicación y checklist de despliegue.

---
