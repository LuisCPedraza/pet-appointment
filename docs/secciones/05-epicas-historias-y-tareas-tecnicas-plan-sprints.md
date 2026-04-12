# 📋 Épicas, Historias de Usuario, Tareas Técnicas y Plan de Sprints

**Documento:** Plan detallado de desarrollo PetAppointment
**Versión:** 1.0
**Fecha de creación:** 12 de abril de 2026
**Equipo:** 2 desarrolladores (Luis Carlos Pedraza, Nicolas Gonzalez)
**Duración de sprint:** 2 semanas

Este documento conserva la vista ejecutiva del proyecto, pero además desglosa cada historia de usuario en contexto, dependencias y tareas técnicas más pequeñas para usarla como base directa en Jira.

---

## Tabla de Contenidos

1. [Plan de Sprints](#plan-de-sprints)
2. [Épicas del Proyecto](#épicas-del-proyecto)
3. [Historias de Usuario (HU)](#historias-de-usuario)
4. [Tareas Técnicas (TASK) por Sprint](#tareas-técnicas-por-sprint)
5. [Lista sugerida de issues para Jira](#lista-sugerida-de-issues-para-jira)
6. [Matriz de Asignación de Tareas](#matriz-de-asignación-de-tareas)
7. [Definición de Terminado](#definición-de-terminado)

---

## Plan de Sprints

### Calendario de Entregas

| Sprint                        | Objetivo Principal               | Inicio | Fin    | Duración días laborales | Capacidad total | Por Dev |
| ----------------------------- | -------------------------------- | ------ | ------ | ------------------------- | --------------- | ------- |
| **Sprint 1** ✅         | Base, documentación y bosquejos | 27 mar | 14 abr | 11 días                  | 80h             | 40h c/u |
| **Sprint 2** (Próximo) | Auth + CRUD mascotas             | 15 abr | 28 abr | 10 días                  | 80h             | 40h c/u |
| **Sprint 3**            | Citas + Panel profesional        | 29 abr | 12 may | 10 días                  | 80h             | 40h c/u |
| **Sprint 4**            | Admin + Notificaciones + CI/CD   | 13 may | 26 may | 10 días                  | 80h             | 40h c/u |

### Sprint 1 (Completado) — Preparación y Base ✅

**Período:** 27 de marzo — 14 de abril de 2026
**Objetivo:** Establecer infraestructura, documentación base y aprobar Entrega 1
**Estado:** ✅ COMPLETADO

**Distribución por semanas:**

- **Semana 1:** 27 mar — 2 abr
- **Semana 2:** 3 abr — 9 abr
- **Semana 3:** 10 abr — 14 abr

| Tarea                                                  | Responsable         | Horas | Estado   |
| ------------------------------------------------------ | ------------------- | ----- | -------- |
| Crear repositorio GitHub + ramas (master, qa, staging) | Nicolas Gonzalez    | 4h    | ✅ Hecho |
| Configurar Jira con épicas, historias y tareas        | Luis Carlos Pedraza | 6h    | ✅ Hecho |
| Redactar documentación técnica base                  | Luis Carlos Pedraza | 8h    | ✅ Hecho |
| Crear estructura inicial proyecto Flutter              | Nicolas Gonzalez    | 4h    | ✅ Hecho |
| Diseño de bosquejo (wireframes 4 pantallas)           | Luis Carlos Pedraza | 5h    | ✅ Hecho |
| Capturar evidencias (GitHub, Jira, bosquejo)           | Luis Carlos Pedraza | 3h    | ✅ Hecho |
| Generar PDF Entrega 1                                  | Luis Carlos Pedraza | 2h    | ✅ Hecho |
| Revisión final y push a develop                       | Nicolas Gonzalez    | 2h    | ✅ Hecho |

**Entregables:**

- ✅ Repositorio operativo en GitHub con 3 ramas oficiales
- ✅ Tablero Jira con 7 épicas, 24 historias, 22 tareas técnicas
- ✅ Documentación técnica completa (PetAppointment_Documentacion_Tecnica.md)
- ✅ PDF Entrega_1_Primer_Adelanto.pdf con todas las evidencias
- ✅ Bosquejos visuales de 4 pantallas principales

---

### Sprint 2 (Próximo) — Autenticación y Gestión de Mascotas

**Período:** 15 de abril — 28 de abril de 2026 (10 días laborales)
**Objetivo:** Implementar login/registro y módulo de mascotas funcional
**Épicas incluidas:** EP-01 (Autenticación), EP-02 (Mascotas)

**Distribución por semanas:**

- **Semana 1:** 15 abr — 21 abr
- **Semana 2:** 22 abr — 28 abr

#### Asignaciones Sprint 2

| Dev                           | Responsabilidades                               | Horas disponibles |
| ----------------------------- | ----------------------------------------------- | ----------------- |
| **Luis Carlos Pedraza** | Módulo de mascotas (CRUD) + Datos persistencia | 40h               |
| **Nicolas Gonzalez**    | Autenticación + Navegación por rol            | 40h               |

---

### Sprint 3 (Futuro) — Núcleo de Citas

**Período:** 29 de abril — 12 de mayo de 2026 (10 días laborales)
**Objetivo:** Implementar flujo completo de reserva de citas y panel profesional
**Épicas incluidas:** EP-03 (Reserva/Gestión de Citas), EP-04 (Panel Profesional)

**Distribución por semanas:**

- **Semana 1:** 29 abr — 5 may
- **Semana 2:** 6 may — 12 may

#### Asignaciones Sprint 3

| Dev                           | Responsabilidades                        | Horas disponibles |
| ----------------------------- | ---------------------------------------- | ----------------- |
| **Nicolas Gonzalez**    | Calendario + lógica de reserva de citas | 40h               |
| **Luis Carlos Pedraza** | Panel profesional + gestión de estados  | 40h               |

---

### Sprint 4 (Futuro) — Finalización, Notificaciones y Release

**Período:** 13 de mayo — 26 de mayo de 2026 (10 días laborales)
**Objetivo:** Implementar notificaciones, panel admin, CI/CD y generar APK de release
**Épicas incluidas:** EP-05 (Notificaciones), EP-06 (Admin), EP-07 (CI/CD)

**Distribución por semanas:**

- **Semana 1:** 13 may — 19 may
- **Semana 2:** 20 may — 26 may

#### Asignaciones Sprint 4

| Dev                           | Responsabilidades                             | Horas disponibles |
| ----------------------------- | --------------------------------------------- | ----------------- |
| **Luis Carlos Pedraza** | Panel admin + notificaciones locales          | 40h               |
| **Nicolas Gonzalez**    | CI/CD pipeline + Edge Functions + APK release | 40h               |

---

## Épicas del Proyecto

| ID              | Épica                                | Descripción                                                                | Prioridad       | Sprint planeado |
| --------------- | ------------------------------------- | --------------------------------------------------------------------------- | --------------- | --------------- |
| **EP-01** | Autenticación y Gestión de Usuarios | Registro, login, recuperación de contraseña, gestión de perfiles por rol | **Alta**  | Sprint 2        |
| **EP-02** | Gestión de Mascotas                  | CRUD completo de mascotas del cliente                                       | **Alta**  | Sprint 2        |
| **EP-03** | Reserva y Gestión de Citas           | Flujo completo: crear, modificar, cancelar citas con calendario             | **Alta**  | Sprint 3        |
| **EP-04** | Panel del Profesional                 | Agenda visual, cambio de estados, configuración de disponibilidad          | **Alta**  | Sprint 3        |
| **EP-05** | Notificaciones y Tiempo Real          | Sincronización RT, notificaciones locales, recordatorios automáticos      | **Media** | Sprint 4        |
| **EP-06** | Panel de Administración              | Gestión de servicios, horarios, usuarios y reportes básicos               | **Media** | Sprint 4        |
| **EP-07** | CI/CD y Calidad                       | Pipeline GitHub Actions, pruebas, generación de APK                        | **Media** | Sprint 4        |

---

## Historias de Usuario

### Épica EP-01: Autenticación y Gestión de Usuarios

| ID              | Historia                                                        | Criterios de Aceptación                                      | Story Points | Sprint   |
| --------------- | --------------------------------------------------------------- | ------------------------------------------------------------- | ------------ | -------- |
| **US-01** | Como usuario nuevo, quiero registrarme con correo y contraseña | Formulario con validación, confirmación email, rol asignado | 3            | Sprint 2 |
| **US-02** | Como usuario registrado, quiero iniciar sesión seguramente     | Auth vía Supabase, JWT token, manejo de errores              | 2            | Sprint 2 |
| **US-03** | Como usuario, quiero recuperar contraseña olvidada             | Email de recuperación, enlace funcional, nueva contraseña   | 2            | Sprint 2 |
| **US-04** | Como usuario, quiero editar mi perfil                           | Formulario editable, actualización en DB, confirmación      | 3            | Sprint 2 |
| **US-05** | Como admin, quiero ver usuarios registrados                     | Tabla paginada, filtro por rol, cambiar rol                   | 5            | Sprint 4 |

### Épica EP-02: Gestión de Mascotas

| ID              | Historia                                          | Criterios de Aceptación                             | Story Points | Sprint   |
| --------------- | ------------------------------------------------- | ---------------------------------------------------- | ------------ | -------- |
| **US-06** | Como cliente, quiero registrar mis mascotas       | Formulario validado, foto opcional, guardado en DB   | 3            | Sprint 2 |
| **US-07** | Como cliente, quiero ver mis mascotas registradas | Lista con foto y datos, indicador última cita       | 2            | Sprint 2 |
| **US-08** | Como cliente, quiero editar mascota               | Formulario prellenado, actualización, confirmación | 2            | Sprint 2 |
| **US-09** | Como cliente, quiero eliminar mascota             | Confirmación, verificar citas activas asociadas     | 2            | Sprint 2 |

### Épica EP-03: Reserva y Gestión de Citas

| ID              | Historia                                               | Criterios de Aceptación                                       | Story Points | Sprint   |
| --------------- | ------------------------------------------------------ | -------------------------------------------------------------- | ------------ | -------- |
| **US-10** | Como cliente, quiero ver calendario con disponibilidad | Calendario interactivo, slots libres/ocupados, RT sync         | 8            | Sprint 3 |
| **US-11** | Como cliente, quiero reservar cita                     | Flujo en pasos, validación disponibilidad, estado "En espera" | 8            | Sprint 3 |
| **US-12** | Como cliente, quiero confirmación inmediata           | Pantalla de éxito, resumen, notificación local               | 3            | Sprint 3 |
| **US-13** | Como cliente, quiero ver historial de citas            | Lista ordenada por fecha, estado, detalles al pulsar           | 3            | Sprint 3 |
| **US-14** | Como cliente, quiero cancelar cita                     | Confirmación, estado actualizado, slot liberado               | 5            | Sprint 3 |
| **US-15** | Como cliente, quiero reprogramar cita                  | Nuevo slot, cancelación anterior, nueva cita creada           | 5            | Sprint 3 |

### Épica EP-04: Panel del Profesional

| ID              | Historia                                           | Criterios de Aceptación                                   | Story Points | Sprint   |
| --------------- | -------------------------------------------------- | ---------------------------------------------------------- | ------------ | -------- |
| **US-16** | Como profesional, quiero ver mi agenda             | Vista diaria/semanal, datos cliente y mascota              | 5            | Sprint 3 |
| **US-17** | Como profesional, quiero confirmar cita pendiente  | Botón confirmación, cambio estado, notificación cliente | 3            | Sprint 3 |
| **US-18** | Como profesional, quiero actualizar estado de cita | Selector estado, transiciones válidas, RT sync            | 5            | Sprint 3 |
| **US-19** | Como profesional, quiero configurar disponibilidad | Selector días/horas, persistencia, reflejo en cliente     | 8            | Sprint 3 |

### Épica EP-05: Notificaciones y Tiempo Real

| ID              | Historia                                                  | Criterios de Aceptación                        | Story Points | Sprint   |
| --------------- | --------------------------------------------------------- | ----------------------------------------------- | ------------ | -------- |
| **US-20** | Como cliente, quiero notificación al cambiar estado cita | Notificación local al detectar cambio vía RT  | 5            | Sprint 4 |
| **US-21** | Como cliente, quiero recordatorio 24h antes               | Notificación programada, Edge Function o local | 5            | Sprint 4 |
| **US-22** | Como profesional, quiero notificación nueva cita         | Push en tiempo real vía Realtime               | 3            | Sprint 4 |

### Épica EP-06: Panel de Administración

| ID              | Historia                                 | Criterios de Aceptación                        | Story Points | Sprint   |
| --------------- | ---------------------------------------- | ----------------------------------------------- | ------------ | -------- |
| **US-23** | Como admin, quiero gestionar servicios   | CRUD servicios, activar/desactivar sin eliminar | 5            | Sprint 4 |
| **US-24** | Como admin, quiero ver reportes de citas | Listado filtrable por fecha/estado, contadores  | 8            | Sprint 4 |

---

## Tareas Técnicas por Sprint

### Sprint 2 — Autenticación y Mascotas (EP-01 + EP-02)

#### Asignado a **Nicolas Gonzalez** — Autenticación (20h)

| TASK ID             | Tarea                                                 | Horas | Enlace HU |
| ------------------- | ----------------------------------------------------- | ----- | --------- |
| **TASK-05**   | Integrar supabase_flutter y configurar cliente global | 2h    | US-02     |
| **TASK-06P1** | Implementar pantalla de registro con validaciones     | 5h    | US-01     |
| **TASK-06P2** | Implementar pantalla de login con JWT y token refresh | 4h    | US-02     |
| **TASK-06P3** | Implementar pantalla de recuperación de contraseña  | 3h    | US-03     |
| **TASK-07**   | Implementar navegación por rol con Go Router         | 4h    | US-05     |
| **TASK-04P1** | Configurar RLS policies para auth y users             | 2h    | US-05     |

#### Asignado a **Luis Carlos Pedraza** — Mascotas (20h)

| TASK ID             | Tarea                                                      | Horas | Enlace HU |
| ------------------- | ---------------------------------------------------------- | ----- | --------- |
| **TASK-02P1** | Configurar proyecto Supabase (Auth, DB, Realtime, Storage) | 3h    | HT-02     |
| **TASK-03**   | Definir esquema BD y ejecutar migrations                   | 6h    | HT-03     |
| **TASK-04P2** | Implementar RLS policies para pets y citas                 | 4h    | HT-04     |
| **TASK-08P1** | Desarrollar pantalla de registro de mascotas (CREATE)      | 3h    | US-06     |
| **TASK-08P2** | Desarrollar pantalla de listado de mascotas (READ)         | 2h    | US-07     |
| **TASK-08P3** | Desarrollar pantalla de edición de mascotas (UPDATE)      | 1h    | US-08     |
| **TASK-08P4** | Implementar botón eliminar con confirmación (DELETE)     | 1h    | US-09     |

---

### Sprint 3 — Reserva de Citas y Panel Profesional (EP-03 + EP-04)

#### Asignado a **Nicolas Gonzalez** — Calendario y Reservas (22h)

| TASK ID             | Tarea                                          | Horas | Enlace HU |
| ------------------- | ---------------------------------------------- | ----- | --------- |
| **TASK-09**   | Integrar table_calendar para disponibilidad    | 8h    | US-10     |
| **TASK-10P1** | Implementar lógica de reserva con validación | 6h    | US-11     |
| **TASK-10P2** | Implementar pantalla de confirmación de cita  | 3h    | US-12     |
| **TASK-14**   | Integrar flutter_local_notifications           | 2h    | US-21     |
| **TASK-11P1** | Implementar suscripción Realtime para slots   | 3h    | US-22     |

#### Asignado a **Luis Carlos Pedraza** — Panel Profesional (18h)

| TASK ID             | Tarea                                                       | Horas | Enlace HU |
| ------------------- | ----------------------------------------------------------- | ----- | --------- |
| **TASK-12P1** | Desarrollar panel profesional - vista agenda diaria/semanal | 6h    | US-16     |
| **TASK-12P2** | Implementar confirmación de cita pendiente                 | 3h    | US-17     |
| **TASK-13P1** | Implementar cambio de estado de cita con historial          | 6h    | US-18     |
| **TASK-19P1** | Configurar GitHub Actions para tests básicos               | 2h    | HT-07     |
| **TASK-13P2** | Implementar pruebas unitarias CRUD mascotas                 | 1h    | HT-07     |

---

### Sprint 4 — Admin, Notificaciones y Release (EP-05 + EP-06 + EP-07)

#### Asignado a **Luis Carlos Pedraza** — Admin y Notificaciones (20h)

| TASK ID             | Tarea                                               | Horas | Enlace HU |
| ------------------- | --------------------------------------------------- | ----- | --------- |
| **TASK-17P1** | Desarrollar panel admin - gestión de servicios     | 8h    | US-23     |
| **TASK-17P2** | Desarrollar panel admin - gestión de usuarios      | 4h    | US-05     |
| **TASK-17P3** | Desarrollar panel admin - reportes básicos         | 4h    | US-24     |
| **TASK-15**   | Crear Edge Function para recordatorios automáticos | 4h    | US-21     |

#### Asignado a **Nicolas Gonzalez** — CI/CD y Release (20h)

| TASK ID             | Tarea                                                  | Horas | Enlace HU    |
| ------------------- | ------------------------------------------------------ | ----- | ------------ |
| **TASK-11P2** | Implementar suscripción Realtime para citas           | 5h    | US-20, US-22 |
| **TASK-18**   | Configurar GitHub Actions para build de APK            | 4h    | HT-06        |
| **TASK-19P2** | Configurar GitHub Actions para tests e integración    | 3h    | HT-07        |
| **TASK-20**   | Escribir pruebas unitarias y de widget (60% cobertura) | 5h    | HT-07        |
| **TASK-21**   | Generar keystore y firmar APK para release             | 2h    | HT-08        |
| **TASK-22**   | Documentar API de Supabase y funciones edge            | 1h    | HT-09        |

---

## 5. Lista sugerida de issues para Jira

La siguiente lista propone cómo crear los issues en Jira para ejecutar el plan sin perder trazabilidad. La recomendación es mantener esta jerarquía:

**Epic -> Story -> Sub-task**

Cuando un trabajo sea transversal o técnico puro, usar **Technical Story** o **Task técnica** según la convención del tablero.

### Sprint 2 — Autenticación y Gestión de Mascotas

| Tipo | Issue sugerido | Parent | Responsable | Prioridad |
|---|---|---|---|---|
| Epic | Autenticación y gestión de usuarios | - | Equipo | Alta |
| Story | Registrar usuario con correo y contraseña | EP-01 | Nicolas Gonzalez | Alta |
| Story | Iniciar sesión y cerrar sesión | EP-01 | Nicolas Gonzalez | Alta |
| Story | Recuperar contraseña por email | EP-01 | Nicolas Gonzalez | Media |
| Story | Ver y editar perfil de usuario | EP-01 | Luis Carlos Pedraza | Media |
| Epic | Gestión de mascotas | - | Equipo | Alta |
| Story | Registrar mascota | EP-02 | Luis Carlos Pedraza | Alta |
| Story | Listar mascotas registradas | EP-02 | Luis Carlos Pedraza | Alta |
| Story | Editar mascota | EP-02 | Luis Carlos Pedraza | Media |
| Story | Eliminar mascota con confirmación | EP-02 | Luis Carlos Pedraza | Media |
| Technical Story | Configurar Supabase base y RLS inicial | EP-07 / EP-01 | Luis Carlos Pedraza | Alta |

### Sprint 3 — Reserva de Citas y Panel Profesional

| Tipo | Issue sugerido | Parent | Responsable | Prioridad |
|---|---|---|---|---|
| Epic | Reserva y gestión de citas | - | Equipo | Alta |
| Story | Ver calendario de disponibilidad | EP-03 | Nicolas Gonzalez | Alta |
| Story | Reservar cita con validación de disponibilidad | EP-03 | Nicolas Gonzalez | Alta |
| Story | Confirmación inmediata de reserva | EP-03 | Nicolas Gonzalez | Media |
| Story | Ver historial de citas | EP-03 | Nicolas Gonzalez | Media |
| Story | Cancelar cita con liberación de horario | EP-03 | Luis Carlos Pedraza | Alta |
| Story | Reprogramar cita | EP-03 | Nicolas Gonzalez | Media |
| Epic | Panel del profesional | - | Equipo | Alta |
| Story | Ver agenda diaria y semanal | EP-04 | Luis Carlos Pedraza | Alta |
| Story | Confirmar cita pendiente | EP-04 | Luis Carlos Pedraza | Media |
| Story | Actualizar estado de cita | EP-04 | Luis Carlos Pedraza | Alta |
| Story | Configurar disponibilidad laboral | EP-04 | Luis Carlos Pedraza | Alta |

### Sprint 4 — Notificaciones, Administración y Calidad

| Tipo | Issue sugerido | Parent | Responsable | Prioridad |
|---|---|---|---|---|
| Epic | Notificaciones y tiempo real | - | Equipo | Media |
| Story | Notificar cambio de estado de cita | EP-05 | Nicolas Gonzalez | Alta |
| Story | Recordatorio 24 horas antes | EP-05 | Nicolas Gonzalez | Alta |
| Story | Notificar nueva cita al profesional | EP-05 | Nicolas Gonzalez | Media |
| Epic | Panel de administración | - | Equipo | Media |
| Story | Gestionar servicios | EP-06 | Luis Carlos Pedraza | Alta |
| Story | Ver reportes de citas | EP-06 | Luis Carlos Pedraza | Media |
| Epic | CI/CD y calidad | - | Equipo | Media |
| Technical Story | Pipeline de GitHub Actions | EP-07 | Nicolas Gonzalez | Alta |
| Technical Story | Pruebas unitarias y widget | EP-07 | Nicolas Gonzalez | Alta |
| Technical Story | Generación de APK firmada | EP-07 | Nicolas Gonzalez | Alta |
| Technical Story | Documentación técnica final | EP-07 | Luis Carlos Pedraza | Media |

---

## 6. Matriz de Asignación de Tareas

### Resumen por Desarrollador

#### **Luis Carlos Pedraza** — Especialista en Backend + Admin UI

**Fortalezas:** Diseño UX/UI, backend de datos, lógica de negocio, documentación

| Sprint             | Tareas asignadas                           | Horas         | Porcentaje     |
| ------------------ | ------------------------------------------ | ------------- | -------------- |
| **Sprint 2** | Supabase setup, BD, mascotas CRUD          | 20h           | 50%            |
| **Sprint 3** | Panel profesional, cambio estados, testing | 18h           | 45%            |
| **Sprint 4** | Admin panel, notificaciones edge           | 20h           | 50%            |
| **TOTAL**    | -                                          | **58h** | **~48%** |

#### **Nicolas Gonzalez** — Especialista en Frontend + CI/CD

**Fortalezas:** Flutter front-end, autenticación, tiempo real, automatización

| Sprint             | Tareas asignadas                                     | Horas         | Porcentaje     |
| ------------------ | ---------------------------------------------------- | ------------- | -------------- |
| **Sprint 2** | Auth completa (registro, login, recovery), Go Router | 20h           | 50%            |
| **Sprint 3** | Calendario, reserva de citas, Realtime               | 22h           | 55%            |
| **Sprint 4** | CI/CD, APK release, testing e integración           | 20h           | 50%            |
| **TOTAL**    | -                                                    | **62h** | **~52%** |

---

## 7. Definición de Terminado

Una tarea se considera **COMPLETADA** cuando:

✅ **Criterios funcionales:**

1. Código implementado según especificación de la HU
2. Cumple todos los criterios de aceptación
3. Integración con Supabase (Auth, DB, Realtime) verificada
4. No hay errores bloqueadores en `flutter analyze`

✅ **Criterios de calidad:**
5. Código revisado por otro miembro del equipo (PR review)
6. Pruebas unitarias/widget escritas (mínimo para lógica crítica)
7. Documentación en DartDoc para clases públicas
8. SIN warnings críticos de linting

✅ **Criterios de integración:**
9. Mergeado a rama `develop`
10. Sincronización con Jira: issue movido a columna "Done"
11. Evidencia en screenshot o video grabado (si es UI)

✅ **Criterios de documentación:**
12. Actualizar Jira con comentario de finalización
13. Enlazar commit SHA en issue
14. Actualizar burndown del sprint

---

## Notas Importantes

1. **Gestión de ramas:**

   - Feature branches: `feature/EP-XX-descripcion` (ej: `feature/EP-01-auth`)
   - Mergear a `develop` con pull request y revisión
   - `develop` → `staging` (qa) → `master` (producción)
2. **Comunicación:**

   - Daily standup: 10:00 AM (breve: qué hiciste, qué harás, bloqueadores)
   - Sincronización en Jira al final de cada día
   - Issues/PRs con descripción clara y enlazada a Jira
3. **Versioning:**

   - v0.1.x (Sprint 2): Auth + Mascotas
   - v0.2.x (Sprint 3): Citas
   - v1.0.0 (Sprint 4): Release inicial
4. **Buffer y contingencias:**

   - 10-15% del tiempo reservado para bugs/issues no previstos
   - Si una tarea toma más tiempo, comunicar ASAP
   - Priorizar cierre de HU sobre perfeccionismo en código

---

## Referencias Cruzadas

- 📄 **Documento técnico completo:** [PetAppointment_Documentacion_Tecnica.md](../PetAppointment_Documentacion_Tecnica.md)
- 📋 **Tablero Jira:** https://correounivalle-team-f1bug4uj.atlassian.net/jira/software/projects/KAN
- 🔗 **Repositorio GitHub:** https://github.com/LuisCPedraza/pet-appointment
- 📝 **Entrega 1 evidencias:** [Entrega_1_Primer_Adelanto.md](../Entrega_1_Primer_Adelanto.md)

---

**Documento generado:** 12 de abril de 2026
**Próxima revisión:** 14 de abril de 2026 (fin Sprint 1)
**Versión:** 1.0
