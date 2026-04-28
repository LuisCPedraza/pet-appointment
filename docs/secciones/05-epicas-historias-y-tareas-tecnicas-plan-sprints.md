# 📋 Épicas, Historias de Usuario, Tareas Técnicas y Plan de Sprints

**Documento:** Plan detallado de desarrollo PetAppointment

**Versión:** 2.0

**Fecha de creación:** 12 de abril de 2026

**Última actualización:** 12 de abril de 2026

**Equipo:** 2 desarrolladores (Luis Carlos Pedraza, Nicolas Gonzalez)

**Duración de sprint:** 2 semanas

> Este documento es la fuente de verdad del equipo para planificación, ejecución y seguimiento del desarrollo. Cada historia de usuario incluye contexto de negocio, flujo esperado, dependencias técnicas, criterios de aceptación detallados y tareas técnicas desglosadas listas para importar en Jira.

---

## Tabla de Contenidos

1. [Glosario del Proyecto](https://claude.ai/chat/d54be0a1-feeb-4e34-b1a3-98cd31b4b355#1-glosario-del-proyecto)
2. [Convenciones y Estándares](https://claude.ai/chat/d54be0a1-feeb-4e34-b1a3-98cd31b4b355#2-convenciones-y-est%C3%A1ndares)
3. [Plan de Sprints](https://claude.ai/chat/d54be0a1-feeb-4e34-b1a3-98cd31b4b355#3-plan-de-sprints)
4. [Épicas del Proyecto](https://claude.ai/chat/d54be0a1-feeb-4e34-b1a3-98cd31b4b355#4-%C3%A9picas-del-proyecto)
5. [Historias de Usuario (HU)](https://claude.ai/chat/d54be0a1-feeb-4e34-b1a3-98cd31b4b355#5-historias-de-usuario)
6. [Tareas Técnicas (TASK) por Sprint](https://claude.ai/chat/d54be0a1-feeb-4e34-b1a3-98cd31b4b355#6-tareas-t%C3%A9cnicas-por-sprint)
7. [Lista de Issues para Jira](https://claude.ai/chat/d54be0a1-feeb-4e34-b1a3-98cd31b4b355#7-lista-de-issues-para-jira)
8. [Matriz de Asignación de Tareas](https://claude.ai/chat/d54be0a1-feeb-4e34-b1a3-98cd31b4b355#8-matriz-de-asignaci%C3%B3n-de-tareas)
9. [Definición de Terminado](https://claude.ai/chat/d54be0a1-feeb-4e34-b1a3-98cd31b4b355#9-definici%C3%B3n-de-terminado)
10. [Riesgos por Sprint](https://claude.ai/chat/d54be0a1-feeb-4e34-b1a3-98cd31b4b355#10-riesgos-por-sprint)
11. [Referencias Cruzadas](https://claude.ai/chat/d54be0a1-feeb-4e34-b1a3-98cd31b4b355#11-referencias-cruzadas)

---

## 1. Glosario del Proyecto

| Término                 | Definición                                                                                                  |
| ------------------------ | ------------------------------------------------------------------------------------------------------------ |
| **Cliente**        | Usuario dueño de mascotas. Puede registrar mascotas, agendar citas y consultar historial.                   |
| **Profesional**    | Veterinario o groomer. Gestiona su agenda, confirma citas y actualiza estados.                               |
| **Administrador**  | Gestiona servicios, usuarios y reportes del sistema.                                                         |
| **Cita**           | Reserva de un servicio para una mascota en un horario específico con un profesional.                        |
| **Slot**           | Intervalo de tiempo disponible en la agenda de un profesional.                                               |
| **Estado de cita** | Ciclo de vida:`en_espera → confirmada → en_proceso → completada / cancelada`.                           |
| **RLS**            | Row Level Security — política de acceso a nivel de fila en Supabase/PostgreSQL.                            |
| **RT**             | Realtime — canal de eventos en tiempo real de Supabase.                                                     |
| **Edge Function**  | Función serverless ejecutada en Supabase para lógica de backend como recordatorios.                        |
| **Story Point**    | Unidad relativa de esfuerzo. 1 SP ≈ tareas triviales; 8 SP ≈ tareas complejas con múltiples dependencias. |

---

## 2. Convenciones y Estándares

### Nomenclatura de branches

```
feature/EP-XX-descripcion-corta     → nuevas funcionalidades
fix/EP-XX-descripcion-corta         → corrección de bugs
chore/descripcion-corta             → tareas técnicas sin HU directa
docs/descripcion-corta              → actualizaciones de documentación
```

**Ejemplos:**

```
feature/EP-01-registro-usuario
fix/EP-03-calendario-slots-vacios
chore/configurar-github-actions
```

### Ciclo de vida de un issue en Jira

```
Backlog → To Do → In Progress → In Review → QA → Done
```

* **Backlog:** definido pero no priorizado para el sprint activo.
* **To Do:** priorizado y listo para iniciar.
* **In Progress:** en desarrollo activo.
* **In Review:** PR abierto, esperando revisión del compañero.
* **QA:** revisión funcional / prueba en dispositivo.
* **Done:** cumple todos los criterios de la Definición de Terminado.

### Convención de commits

```
feat(EP-XX): descripción breve del cambio
fix(EP-XX): descripción del bug corregido
chore: descripción de tarea técnica
docs: actualización de documentación
test: añadir o modificar pruebas
```

**Ejemplos:**

```
feat(EP-01): implementar pantalla de registro con validaciones
fix(EP-03): corregir doble reserva en mismo slot
test(EP-02): agregar pruebas unitarias para PetRepository
```

### Escala de Story Points

| SP | Referencia de esfuerzo                                |
| -- | ----------------------------------------------------- |
| 1  | Cambio trivial, menos de 1 hora                       |
| 2  | Tarea pequeña, 1–3 horas                            |
| 3  | Tarea estándar, medio día                           |
| 5  | Tarea compleja, 1 día completo                       |
| 8  | Tarea muy compleja, múltiples dependencias, 2+ días |
| 13 | Épica pequeña, debe dividirse si es posible         |

---

## 3. Plan de Sprints

### Calendario General

| Sprint               | Objetivo Principal               | Inicio | Fin    | Días laborales | Capacidad total | Por Dev |
| -------------------- | -------------------------------- | ------ | ------ | --------------- | --------------- | ------- |
| **Sprint 1**✅ | Base, documentación y bosquejos | 27 mar | 14 abr | 11 días        | 80h             | 40h c/u |
| **Sprint 2**🔜 | Auth + CRUD mascotas             | 15 abr | 28 abr | 10 días        | 80h             | 40h c/u |
| **Sprint 3**📅 | Citas + Panel profesional        | 29 abr | 12 may | 10 días        | 80h             | 40h c/u |
| **Sprint 4**📅 | Admin + Notificaciones + CI/CD   | 13 may | 26 may | 10 días        | 80h             | 40h c/u |

---

### Sprint 1 — Preparación y Base ✅

**Período:** 27 de marzo — 14 de abril de 2026

**Objetivo:** Establecer infraestructura, documentación base y aprobar Entrega 1.

**Estado:** ✅ COMPLETADO

#### Entregables del Sprint 1

| Entregable                                                    | Estado |
| ------------------------------------------------------------- | ------ |
| Repositorio GitHub con ramas `main`,`develop`,`staging` | ✅     |
| Tablero Jira con épicas, historias y tareas                  | ✅     |
| Documentación técnica completa (`.md`)                    | ✅     |
| PDF Entrega 1 con evidencias                                  | ✅     |
| Bosquejos visuales de 4 pantallas principales                 | ✅     |
| Estructura inicial de proyecto Flutter                        | ✅     |

#### Tareas completadas

| ID         | Tarea                                           | Responsable         | Horas | Estado |
| ---------- | ----------------------------------------------- | ------------------- | ----- | ------ |
| TASK-S1-01 | Crear repositorio GitHub + ramas                | Nicolas Gonzalez    | 4h    | ✅     |
| TASK-S1-04 | Configurar Jira con épicas, historias y tareas | Luis Carlos Pedraza | 6h    | ✅     |
| TASK-S1-05 | Redactar documentación técnica base           | Luis Carlos Pedraza | 8h    | ✅     |
| TASK-S1-02 | Crear estructura inicial Flutter                | Nicolas Gonzalez    | 4h    | ✅     |
| TASK-S1-06 | Diseño de bosquetos (wireframes 4 pantallas)   | Luis Carlos Pedraza | 5h    | ✅     |
| TASK-S1-07 | Capturar evidencias (GitHub, Jira, bosquejo)    | Luis Carlos Pedraza | 3h    | ✅     |
| TASK-S1-08 | Generar PDF Entrega 1                           | Luis Carlos Pedraza | 2h    | ✅     |
| TASK-S1-03 | Revisión final y push a develop                | Nicolas Gonzalez    | 2h    | ✅     |

---

### Sprint 2 — Autenticación y Gestión de Mascotas 🔜

**Período:** 15 de abril — 28 de abril de 2026 (10 días laborales)

**Objetivo:** Implementar login/registro funcional con Supabase Auth y el módulo completo de mascotas (CRUD).

**Épicas:** EP-01 (Autenticación), EP-02 (Mascotas)

**Versión objetivo:** `v0.1.0`

#### Contexto técnico del Sprint 2

Este sprint es el más crítico en términos de infraestructura. Antes de escribir una sola línea de lógica de negocio, la conexión con Supabase debe estar operativa y las políticas RLS correctamente configuradas. Un error en este punto se propagará a todos los sprints siguientes.

**Orden recomendado de implementación:**

1. Configurar proyecto Supabase (Auth, DB, Storage, Realtime)
2. Ejecutar migraciones SQL con esquema de tablas
3. Definir RLS policies para `users`, `pets`
4. Implementar autenticación (registro → login → recovery)
5. Implementar navegación por rol (Go Router guards)
6. Implementar CRUD de mascotas

#### Dependencias críticas del Sprint 2

```
Supabase configurado
    └── Auth operativa
        └── Navegación por rol
            └── Módulo mascotas (requiere user autenticado)
```

#### Asignaciones

| Dev                           | Responsabilidades                                    | Horas |
| ----------------------------- | ---------------------------------------------------- | ----- |
| **Luis Carlos Pedraza** | Supabase setup, esquema BD, RLS, CRUD mascotas       | 40h   |
| **Nicolas Gonzalez**    | Auth completa (registro, login, recovery), Go Router | 40h   |

#### Criterios de éxito del Sprint 2

* [x] Usuario puede registrarse, iniciar sesión y cerrar sesión.
* [x] El token JWT se persiste entre sesiones (no pide login cada vez que abre la app).
* [x] La navegación redirecciona correctamente según el rol del usuario.
* [x] Un cliente autenticado puede registrar, listar, editar y eliminar sus mascotas.
* [x] La base de datos en Supabase tiene el esquema completo y las políticas RLS activas.
* [x] `flutter analyze` pasa sin errores ni warnings bloqueadores.

---

### Sprint 3 — Núcleo de Citas 📅

**Período:** 29 de abril — 12 de mayo de 2026 (10 días laborales)

**Objetivo:** Implementar el flujo completo de reserva de citas y el panel del profesional.

**Épicas:** EP-03 (Reserva/Gestión de Citas), EP-04 (Panel Profesional)

**Versión objetivo:** `v0.2.0`

#### Contexto técnico del Sprint 3

Este sprint depende al 100% del Sprint 2. Si Auth o mascotas no están completos, este sprint no puede comenzar. La integración con Supabase Realtime es la parte más delicada: los slots de disponibilidad deben sincronizarse en tiempo real para evitar dobles reservas.

**Orden recomendado de implementación:**

1. Definir disponibilidad del profesional (horarios)
2. Implementar calendario de disponibilidad (table_calendar)
3. Lógica de reserva con validación de conflictos
4. Panel del profesional (agenda)
5. Cambio de estados de cita
6. Suscripción Realtime para slots

#### Dependencias críticas del Sprint 3

```
Auth operativa (Sprint 2)
    └── Mascotas CRUD (Sprint 2)
        └── Disponibilidad del profesional
            └── Calendario de slots
                └── Lógica de reserva
                    └── Panel profesional
                        └── Cambio de estados + Realtime
```

#### Asignaciones

| Dev                           | Responsabilidades                                | Horas |
| ----------------------------- | ------------------------------------------------ | ----- |
| **Nicolas Gonzalez**    | Calendario, lógica de reserva, Realtime slots   | 40h   |
| **Luis Carlos Pedraza** | Panel profesional, estados de cita, testing base | 40h   |

#### Criterios de éxito del Sprint 3

* [ ] El cliente puede ver un calendario con slots disponibles/ocupados en tiempo real.
* [ ] El cliente puede reservar una cita y recibir confirmación inmediata.
* [ ] No es posible reservar dos citas en el mismo slot (validación doble: app + DB).
* [ ] El profesional puede ver su agenda diaria y semanal.
* [ ] El profesional puede cambiar el estado de una cita siguiendo el flujo válido.
* [ ] Los cambios se reflejan en tiempo real sin necesidad de recargar la pantalla.

---

### Sprint 4 — Finalización, Notificaciones y Release 📅

**Período:** 13 de mayo — 26 de mayo de 2026 (10 días laborales)

**Objetivo:** Notificaciones, panel admin, CI/CD y generación del APK de release.

**Épicas:** EP-05 (Notificaciones), EP-06 (Admin), EP-07 (CI/CD)

**Versión objetivo:** `v1.0.0`

#### Asignaciones

| Dev                           | Responsabilidades                                   | Horas |
| ----------------------------- | --------------------------------------------------- | ----- |
| **Luis Carlos Pedraza** | Panel admin, notificaciones locales, Edge Functions | 40h   |
| **Nicolas Gonzalez**    | CI/CD pipeline, Realtime citas, APK release         | 40h   |

#### Criterios de éxito del Sprint 4

* [ ] El cliente recibe notificación local cuando cambia el estado de su cita.
* [ ] El cliente recibe recordatorio 24 horas antes de su cita.
* [ ] El administrador puede gestionar servicios y ver reportes básicos.
* [ ] El pipeline de GitHub Actions ejecuta pruebas y genera el APK automáticamente.
* [ ] La cobertura de pruebas alcanza al menos el 60% en lógica crítica.
* [ ] El APK firmado está disponible como artefacto de la pipeline.

---

## 4. Épicas del Proyecto

| ID              | Épica                                | Descripción                                                                                | Prioridad       | Sprint   |
| --------------- | ------------------------------------- | ------------------------------------------------------------------------------------------- | --------------- | -------- |
| **EP-01** | Autenticación y Gestión de Usuarios | Registro, login, recuperación de contraseña, perfiles por rol, guards de navegación      | **Alta**  | Sprint 2 |
| **EP-02** | Gestión de Mascotas                  | CRUD completo: nombre, especie, raza, edad, foto, historial básico                         | **Alta**  | Sprint 2 |
| **EP-03** | Reserva y Gestión de Citas           | Flujo completo: crear, modificar, cancelar citas con calendario y validación de conflictos | **Alta**  | Sprint 3 |
| **EP-04** | Panel del Profesional                 | Agenda visual diaria/semanal, cambio de estados, configuración de disponibilidad horaria   | **Alta**  | Sprint 3 |
| **EP-05** | Notificaciones y Tiempo Real          | Sincronización RT, notificaciones locales, recordatorios automáticos vía Edge Functions  | **Media** | Sprint 4 |
| **EP-06** | Panel de Administración              | Gestión de servicios, horarios, usuarios y reportes básicos de citas                      | **Media** | Sprint 4 |
| **EP-07** | CI/CD y Calidad                       | Pipeline GitHub Actions, pruebas automatizadas, generación y firma de APK                  | **Media** | Sprint 4 |

---

## 5. Historias de Usuario

> Cada historia incluye: contexto de negocio, flujo de usuario esperado, dependencias técnicas y criterios de aceptación detallados.

---

### Épica EP-01: Autenticación y Gestión de Usuarios

---

#### US-01 — Registro de usuario

> **Como** usuario nuevo,
>
> **quiero** registrarme en la aplicación con mi correo y contraseña,
>
> **para** acceder a las funcionalidades según mi rol (cliente, profesional o administrador).

**Contexto:** Es la puerta de entrada al sistema. Sin registro funcional, ninguna otra historia puede probarse. El rol se asigna en el momento del registro; por defecto todos los usuarios nuevos son `cliente`. Solo un administrador puede cambiar el rol a `profesional`.

**Flujo esperado:**

1. El usuario abre la app y ve la pantalla de bienvenida.
2. Pulsa "Registrarse".
3. Completa el formulario: nombre completo, correo, contraseña, confirmación de contraseña.
4. Pulsa "Crear cuenta".
5. Supabase envía un correo de confirmación.
6. El usuario confirma su correo y es redirigido al home según su rol.

**Dependencias técnicas:**

* Supabase Auth configurado.
* Tabla `users` en PostgreSQL con campo `role`.
* RLS policy que permita insertar solo al propio usuario.
* Email templates configurados en Supabase Dashboard.

**Criterios de aceptación:**

* [X] El formulario valida: correo con formato válido, contraseña mínimo 8 caracteres, campos no vacíos.
* [X] Si el correo ya está registrado, muestra mensaje de error claro sin exponer información sensible.
* [X] Si las contraseñas no coinciden, el error se muestra inline bajo el campo de confirmación.
* [X] Tras registro exitoso, se muestra pantalla de confirmación indicando revisar el correo.
* [X] El usuario no puede acceder al home hasta confirmar el correo.
* [X] El rol `cliente` se asigna automáticamente en la creación del perfil.

| Campo        | Valor            |
| ------------ | ---------------- |
| Story Points | 3                |
| Sprint       | 2                |
| Responsable  | Nicolas Gonzalez |
| Prioridad    | Alta             |

---

#### US-02 — Inicio de sesión

> **Como** usuario registrado,
>
> **quiero** iniciar sesión con mi correo y contraseña,
>
> **para** acceder a mi cuenta de forma segura y ser redirigido a la vista correspondiente a mi rol.

**Contexto:** El flujo de autenticación debe ser fluido y seguro. El token JWT generado por Supabase debe persistirse localmente para que el usuario no tenga que iniciar sesión cada vez que abre la app.

**Flujo esperado:**

1. El usuario abre la app con sesión expirada o sin sesión.
2. Ingresa correo y contraseña.
3. Pulsa "Iniciar sesión".
4. Si las credenciales son correctas, se carga el perfil y se redirige según rol.
5. Si las credenciales son incorrectas, se muestra error genérico (sin indicar cuál campo es incorrecto, por seguridad).

**Dependencias técnicas:**

* US-01 completada.
* Supabase Auth con `signInWithPassword`.
* SharedPreferences o `flutter_secure_storage` para persistencia del token.
* Go Router con guards basados en estado de autenticación.

**Criterios de aceptación:**

* [X] El login con credenciales válidas redirige al home correcto según el rol.
* [X] El login con credenciales inválidas muestra mensaje de error genérico.
* [X] Si el correo no está confirmado, muestra mensaje indicando verificar el correo.
* [X] La sesión persiste entre reinicios de la app (auto-login).
* [X] El botón "Cerrar sesión" invalida el token y redirige al login.
* [X] El campo contraseña tiene opción de mostrar/ocultar el texto.

| Campo        | Valor            |
| ------------ | ---------------- |
| Story Points | 2                |
| Sprint       | 2                |
| Responsable  | Nicolas Gonzalez |
| Prioridad    | Alta             |

---

#### US-03 — Recuperación de contraseña

> **Como** usuario registrado,
>
> **quiero** recuperar el acceso a mi cuenta cuando olvido mi contraseña,
>
> **para** no perder el acceso a mis datos y citas registradas.

**Flujo esperado:**

1. El usuario pulsa "Olvidé mi contraseña" en la pantalla de login.
2. Ingresa su correo registrado.
3. Supabase envía un correo con enlace de recuperación.
4. El usuario accede al enlace, define una nueva contraseña.
5. Es redirigido al login con mensaje de éxito.

**Dependencias técnicas:**

* Supabase `resetPasswordForEmail`.
* Deep link configurado en Flutter para capturar el enlace del correo.

**Criterios de aceptación:**

* [X] Si el correo existe, se envía el correo de recuperación y se muestra confirmación en pantalla.
* [X] Si el correo no existe, **no** se revela esta información (mensaje genérico por seguridad).
* [ ] El enlace de recuperación expira en 1 hora.
* [X] Tras restablecer la contraseña, el usuario puede iniciar sesión con la nueva.
* [X] La nueva contraseña debe cumplir los mismos criterios de validación que el registro.

| Campo        | Valor            |
| ------------ | ---------------- |
| Story Points | 2                |
| Sprint       | 2                |
| Responsable  | Nicolas Gonzalez |
| Prioridad    | Media            |

---

#### US-04 — Edición de perfil

> **Como** usuario autenticado,
>
> **quiero** editar mi información de perfil (nombre, teléfono, foto),
>
> **para** mantener mis datos actualizados en el sistema.

**Flujo esperado:**

1. El usuario accede a "Mi perfil" desde el menú.
2. Ve sus datos actuales prellenados en un formulario editable.
3. Modifica los campos deseados.
4. Pulsa "Guardar cambios".
5. Se actualiza en Supabase y se muestra confirmación.

**Dependencias técnicas:**

* US-02 completada.
* Supabase Storage para foto de perfil.
* `image_picker` para seleccionar imagen del dispositivo.

**Criterios de aceptación:**

* [X] El formulario viene prellenado con los datos actuales del usuario.
* [X] Los cambios se persisten en la tabla `users` de Supabase.
* [X] La foto de perfil se sube a Supabase Storage y se almacena la URL en la tabla.
* [X] Si la subida de foto falla, los demás datos se guardan igualmente.
* [X] Se muestra mensaje de éxito o error según resultado.
* [X] El nombre actualizado se refleja inmediatamente en la barra de navegación / header.

| Campo        | Valor            |
| ------------ | ---------------- |
| Story Points | 3                |
| Sprint       | 2                |
| Responsable  | Nicolas Gonzalez |
| Prioridad    | Media            |

---

#### US-05 — Gestión de usuarios (Admin)

> **Como** administrador,
>
> **quiero** ver y gestionar los usuarios registrados en el sistema,
>
> **para** asignar roles, activar/desactivar cuentas y mantener el control del acceso.

**Flujo esperado:**

1. El admin accede al panel de administración.
2. Ve una tabla paginada con todos los usuarios.
3. Puede filtrar por rol o buscar por nombre/correo.
4. Puede cambiar el rol de un usuario o desactivar su cuenta.

**Dependencias técnicas:**

* US-01 y US-02 completadas.
* RLS policy que permita al admin leer todos los registros de `users`.
* Función de Supabase para cambiar rol sin exponer Admin Key en cliente.

**Criterios de aceptación:**

* [ ] Solo usuarios con rol `admin` pueden acceder a esta pantalla.
* [ ] La tabla muestra: nombre, correo, rol, fecha de registro, estado (activo/inactivo).
* [ ] El admin puede cambiar el rol de `cliente` a `profesional` y viceversa.
* [ ] El admin puede desactivar una cuenta sin eliminarla (soft delete).
* [ ] Un usuario desactivado no puede iniciar sesión.
* [ ] Los cambios se reflejan en tiempo real sin recargar la lista.

| Campo        | Valor               |
| ------------ | ------------------- |
| Story Points | 5                   |
| Sprint       | 4                   |
| Responsable  | Luis Carlos Pedraza |
| Prioridad    | Media               |

---

### Épica EP-02: Gestión de Mascotas

---

#### US-06 — Registrar mascota

> **Como** cliente autenticado,
>
> **quiero** registrar mis mascotas en la aplicación,
>
> **para** poder seleccionarlas al momento de agendar una cita.

**Contexto:** Las mascotas son el núcleo del negocio. Sin ellas, no es posible agendar citas. El formulario debe ser sencillo pero completo para que el profesional tenga la información necesaria al atender al animal.

**Flujo esperado:**

1. El cliente accede a "Mis mascotas".
2. Pulsa el botón "Agregar mascota".
3. Completa el formulario con los datos de la mascota.
4. Opcionalmente sube una foto.
5. Pulsa "Guardar".
6. La mascota aparece en su lista.

**Campos del formulario:**

* Nombre (obligatorio)
* Especie: Perro / Gato / Otro (obligatorio)
* Raza (opcional)
* Fecha de nacimiento o edad aproximada (obligatorio)
* Peso en kg (opcional)
* Notas adicionales / condiciones médicas (opcional)
* Foto (opcional)

**Dependencias técnicas:**

* US-02 completada (usuario autenticado).
* Tabla `pets` con FK a `users.id`.
* RLS: cliente solo puede ver/modificar sus propias mascotas.
* Supabase Storage bucket `pet-photos`.
* `image_picker` para seleccionar imagen.

**Criterios de aceptación:**

* [x] El formulario valida campos obligatorios antes de enviar.
* [x] La mascota se guarda en la tabla `pets` con el `user_id` del cliente autenticado.
* [x] La foto se sube a Storage y se guarda la URL pública en `pets.photo_url`.
* [x] Si no se sube foto, se muestra un avatar genérico según la especie.
* [x] Tras guardar, la mascota aparece inmediatamente en la lista sin recargar.
* [x] Si el guardado falla, se muestra mensaje de error y el formulario no se cierra (para no perder los datos).

| Campo        | Valor               |
| ------------ | ------------------- |
| Story Points | 3                   |
| Sprint       | 2                   |
| Responsable  | Luis Carlos Pedraza |
| Prioridad    | Alta                |

---

#### US-07 — Listar mascotas

> **Como** cliente autenticado,
>
> **quiero** ver la lista de mis mascotas registradas,
>
> **para** consultar su información y acceder a su historial de citas.

**Flujo esperado:**

1. El cliente accede a "Mis mascotas".
2. Ve una lista con foto (o avatar), nombre, especie y la fecha de su última cita.
3. Al pulsar una mascota, ve el detalle completo.

**Dependencias técnicas:**

* US-06 completada.
* Query con JOIN a tabla `appointments` para mostrar última cita.

**Criterios de aceptación:**

* [x] La lista solo muestra las mascotas del cliente autenticado.
* [x] Cada tarjeta muestra: foto/avatar, nombre, especie, y última cita (o "Sin citas aún").
* [x] Si no hay mascotas, se muestra un estado vacío con CTA para registrar la primera.
* [x] Al pulsar una mascota, se navega a la pantalla de detalle con todos sus datos.
* [x] La lista se ordena por nombre alfabéticamente de forma predeterminada.

| Campo        | Valor               |
| ------------ | ------------------- |
| Story Points | 2                   |
| Sprint       | 2                   |
| Responsable  | Luis Carlos Pedraza |
| Prioridad    | Alta                |

---

#### US-08 — Editar mascota

> **Como** cliente autenticado,
>
> **quiero** editar los datos de una mascota registrada,
>
> **para** corregir errores o actualizar su información (peso, notas médicas, foto).

**Flujo esperado:**

1. El cliente entra al detalle de una mascota.
2. Pulsa "Editar".
3. El formulario se abre prellenado con los datos actuales.
4. Modifica los campos deseados.
5. Pulsa "Guardar cambios".

**Dependencias técnicas:**

* US-06 y US-07 completadas.

**Criterios de aceptación:**

* [x] El formulario de edición viene prellenado con todos los datos actuales.
* [x] Solo el propietario de la mascota puede editarla (validado por RLS).
* [x] Si se cambia la foto, la anterior se elimina de Storage para no acumular archivos huérfanos.
* [x] Los cambios se reflejan inmediatamente en la lista y en el detalle.
* [x] Se muestra confirmación visual de éxito o mensaje de error.

| Campo        | Valor               |
| ------------ | ------------------- |
| Story Points | 2                   |
| Sprint       | 2                   |
| Responsable  | Luis Carlos Pedraza |
| Prioridad    | Media               |

---

#### US-09 — Eliminar mascota

> **Como** cliente autenticado,
>
> **quiero** eliminar una mascota de mi perfil,
>
> **para** mantener mi lista actualizada si ya no tengo esa mascota.

**Flujo esperado:**

1. El cliente entra al detalle de una mascota.
2. Pulsa "Eliminar".
3. Aparece un diálogo de confirmación con advertencia si tiene citas activas.
4. Confirma la eliminación.
5. La mascota desaparece de la lista.

**Dependencias técnicas:**

* US-06, US-07 completadas.
* Verificación de citas activas antes de permitir eliminación.
* Cascade delete o soft delete en tabla `pets`.

**Criterios de aceptación:**

* [x] Antes de eliminar, se verifica si la mascota tiene citas en estado `en_espera` o `confirmada`.
* [x] Si tiene citas activas, se muestra advertencia indicando que deberá cancelarlas primero.
* [x] Si no tiene citas activas, el diálogo de confirmación es simple.
* [x] La eliminación borra la foto de Storage (si existe).
* [x] Solo el propietario puede eliminar su mascota (RLS).
* [x] Tras eliminar, el usuario regresa automáticamente a la lista de mascotas.

| Campo        | Valor               |
| ------------ | ------------------- |
| Story Points | 2                   |
| Sprint       | 2                   |
| Responsable  | Luis Carlos Pedraza |
| Prioridad    | Media               |

---

### Épica EP-03: Reserva y Gestión de Citas

---

#### US-10 — Ver calendario de disponibilidad

> **Como** cliente autenticado,
>
> **quiero** ver un calendario interactivo con la disponibilidad de los profesionales,
>
> **para** elegir el horario que mejor se adapte a mis necesidades.

**Contexto:** Esta es la historia más compleja del Sprint 3. El calendario debe mostrar en tiempo real los slots ocupados y libres. La suscripción Realtime garantiza que si otro cliente reserva un slot mientras el usuario está viendo el calendario, ese slot se marque inmediatamente como ocupado.

**Flujo esperado:**

1. El cliente inicia el flujo de "Nueva cita".
2. Selecciona el servicio y el profesional.
3. Ve el calendario del mes actual con días disponibles resaltados.
4. Selecciona un día.
5. Ve los slots horarios del día (ej: 9:00, 9:30, 10:00...).
6. Los slots ocupados se muestran deshabilitados.

**Dependencias técnicas:**

* US-02 completada.
* Tabla `availability` con horarios del profesional.
* Tabla `appointments` para calcular slots ocupados.
* `table_calendar` package.
* Suscripción Supabase Realtime al canal de `appointments`.

**Criterios de aceptación:**

* [ ] El calendario resalta en verde los días con disponibilidad y en gris los sin disponibilidad.
* [ ] Los slots horarios muestran claramente cuáles están libres y cuáles ocupados.
* [ ] Los slots pasados (horas ya transcurridas en el día actual) están deshabilitados.
* [ ] Si otro cliente reserva un slot mientras el usuario está en la pantalla, ese slot se deshabilita automáticamente (Realtime).
* [ ] El calendario carga en menos de 2 segundos en conexión normal.
* [ ] Si no hay disponibilidad en el mes actual, se sugiere navegar al mes siguiente.

| Campo        | Valor            |
| ------------ | ---------------- |
| Story Points | 8                |
| Sprint       | 3                |
| Responsable  | Nicolas Gonzalez |
| Prioridad    | Alta             |

---

#### US-11 — Reservar cita

> **Como** cliente autenticado,
>
> **quiero** reservar una cita seleccionando servicio, mascota, profesional, fecha y hora,
>
> **para** asegurar un turno de atención para mi mascota.

**Flujo esperado (flujo en pasos):**

1. **Paso 1:** Seleccionar servicio (baño, consulta, vacuna, etc.)
2. **Paso 2:** Seleccionar mascota del cliente.
3. **Paso 3:** Seleccionar profesional disponible para el servicio.
4. **Paso 4:** Seleccionar fecha y hora en el calendario.
5. **Paso 5:** Revisar resumen de la cita.
6. **Paso 6:** Confirmar reserva.
7. La cita se crea con estado `en_espera`.

**Dependencias técnicas:**

* US-10 completada.
* US-06/US-07 completadas (debe tener al menos una mascota).
* Tabla `appointments` con campos: `client_id`, `pet_id`, `professional_id`, `service_id`, `scheduled_at`, `status`.
* Validación de conflicto de reservas a nivel de DB (constraint o trigger).

**Criterios de aceptación:**

* [ ] El flujo en pasos tiene navegación "Atrás" sin perder los datos seleccionados.
* [ ] No es posible avanzar al siguiente paso sin completar el actual.
* [ ] Si el slot se ocupa entre que el usuario lo seleccionó y lo confirmó, se muestra error y se regresa al calendario.
* [ ] La cita se crea con estado `en_espera` en la tabla `appointments`.
* [ ] El cliente recibe confirmación visual inmediata (pantalla de éxito).
* [ ] La validación de conflicto existe tanto en la app (UX) como en la base de datos (integridad).

| Campo        | Valor            |
| ------------ | ---------------- |
| Story Points | 8                |
| Sprint       | 3                |
| Responsable  | Nicolas Gonzalez |
| Prioridad    | Alta             |

---

#### US-12 — Confirmación inmediata de reserva

> **Como** cliente,
>
> **quiero** ver una pantalla de confirmación tras reservar una cita,
>
> **para** tener constancia de los detalles del turno que acabo de agendar.

**Flujo esperado:**

1. Tras completar el flujo de reserva exitosamente.
2. Se muestra pantalla de confirmación con resumen completo.
3. El cliente puede ir al "Historial de citas" o "Inicio".

**Criterios de aceptación:**

* [ ] La pantalla muestra: servicio, mascota, profesional, fecha, hora y estado inicial.
* [ ] Se dispara una notificación local de confirmación.
* [ ] El botón "Ver mis citas" navega al historial filtrando por esta cita.
* [ ] El botón "Inicio" navega al home limpiando el stack de navegación.

| Campo        | Valor            |
| ------------ | ---------------- |
| Story Points | 3                |
| Sprint       | 3                |
| Responsable  | Nicolas Gonzalez |
| Prioridad    | Media            |

---

#### US-13 — Historial de citas del cliente

> **Como** cliente autenticado,
>
> **quiero** ver el historial de todas mis citas (pasadas y futuras),
>
> **para** hacer seguimiento de las atenciones de mis mascotas.

**Flujo esperado:**

1. El cliente accede a "Mis citas" desde el menú.
2. Ve una lista ordenada por fecha (más recientes primero).
3. Cada cita muestra: mascota, servicio, profesional, fecha/hora y estado.
4. Al pulsar, ve el detalle completo.

**Criterios de aceptación:**

* [ ] La lista muestra citas futuras arriba y pasadas abajo.
* [ ] Se puede filtrar por estado (todas, pendientes, completadas, canceladas).
* [ ] El estado de cada cita está visualmente diferenciado (colores/íconos por estado).
* [ ] Al pulsar una cita activa, se ofrecen opciones de cancelar o reprogramar.
* [ ] Si no hay citas, se muestra estado vacío con CTA para agendar la primera.

| Campo        | Valor            |
| ------------ | ---------------- |
| Story Points | 3                |
| Sprint       | 3                |
| Responsable  | Nicolas Gonzalez |
| Prioridad    | Media            |

---

#### US-14 — Cancelar cita

> **Como** cliente autenticado,
>
> **quiero** cancelar una cita previamente agendada,
>
> **para** liberar el slot cuando ya no puedo asistir.

**Flujo esperado:**

1. El cliente selecciona una cita activa desde su historial.
2. Pulsa "Cancelar cita".
3. Se muestra diálogo de confirmación con motivo opcional.
4. Confirma la cancelación.
5. La cita cambia a estado `cancelada` y el slot queda libre.

**Reglas de negocio:**

* Solo se pueden cancelar citas en estado `en_espera` o `confirmada`.
* No se puede cancelar una cita con menos de 2 horas de anticipación (configurable).

**Criterios de aceptación:**

* [ ] Solo aparece la opción "Cancelar" para citas en estado `en_espera` o `confirmada`.
* [ ] Si la cita es en menos de 2 horas, se muestra advertencia pero se permite cancelar (decisión de negocio).
* [ ] Tras cancelar, el estado cambia a `cancelada` y el slot queda disponible en el calendario.
* [ ] El profesional recibe notificación de la cancelación.
* [ ] La cita cancelada permanece en el historial con el estado visible.

| Campo        | Valor               |
| ------------ | ------------------- |
| Story Points | 5                   |
| Sprint       | 3                   |
| Responsable  | Luis Carlos Pedraza |
| Prioridad    | Alta                |

---

#### US-15 — Reprogramar cita

> **Como** cliente autenticado,
>
> **quiero** reprogramar una cita a un nuevo horario,
>
> **para** no perder el servicio cuando no puedo en el horario original.

**Flujo esperado:**

1. El cliente selecciona una cita activa.
2. Pulsa "Reprogramar".
3. Se abre el calendario de disponibilidad del mismo profesional.
4. Selecciona nuevo slot.
5. Confirma el cambio.
6. La cita anterior se cancela y se crea una nueva.

**Criterios de aceptación:**

* [ ] Solo se pueden reprogramar citas en estado `en_espera` o `confirmada`.
* [ ] Al reprogramar, se libera el slot anterior automáticamente.
* [ ] La nueva cita comienza en estado `en_espera`.
* [ ] El profesional recibe notificación del cambio.
* [ ] Si no hay disponibilidad alternativa, se informa al cliente.

| Campo        | Valor            |
| ------------ | ---------------- |
| Story Points | 5                |
| Sprint       | 3                |
| Responsable  | Nicolas Gonzalez |
| Prioridad    | Media            |

---

### Épica EP-04: Panel del Profesional

---

#### US-16 — Ver agenda del profesional

> **Como** profesional autenticado,
>
> **quiero** ver mi agenda de citas en vista diaria y semanal,
>
> **para** organizar mi jornada laboral y prepararme para cada atención.

**Contexto:** La agenda es la herramienta principal del profesional. Debe ser clara, rápida de leer y actualizarse en tiempo real cuando llegan nuevas citas o se producen cancelaciones.

**Criterios de aceptación:**

* [ ] Vista diaria: muestra las citas del día con hora, cliente, mascota y servicio.
* [ ] Vista semanal: muestra un resumen visual de citas por día de la semana.
* [ ] Las citas se ordenan cronológicamente.
* [ ] El estado de cada cita está visualmente diferenciado.
* [ ] Al pulsar una cita, se muestra el detalle completo del cliente y la mascota.
* [ ] Las nuevas citas aparecen en tiempo real sin recargar (Realtime).

| Campo        | Valor               |
| ------------ | ------------------- |
| Story Points | 5                   |
| Sprint       | 3                   |
| Responsable  | Luis Carlos Pedraza |
| Prioridad    | Alta                |

---

#### US-17 — Confirmar cita pendiente

> **Como** profesional,
>
> **quiero** confirmar una cita que está en estado "en espera",
>
> **para** indicarle al cliente que su cita ha sido aceptada.

**Flujo del estado:** `en_espera → confirmada`

**Criterios de aceptación:**

* [ ] Las citas en estado `en_espera` tienen un botón de "Confirmar" visible.
* [ ] Al confirmar, el estado cambia a `confirmada` en la DB.
* [ ] El cliente recibe una notificación local informando que su cita fue confirmada.
* [ ] El cambio se refleja en tiempo real en la agenda del profesional.
* [ ] Solo el profesional asignado a la cita puede confirmarla (RLS).

| Campo        | Valor               |
| ------------ | ------------------- |
| Story Points | 3                   |
| Sprint       | 3                   |
| Responsable  | Luis Carlos Pedraza |
| Prioridad    | Media               |

---

#### US-18 — Actualizar estado de cita

> **Como** profesional,
>
> **quiero** actualizar el estado de una cita a lo largo de la atención,
>
> **para** que el cliente pueda seguir en tiempo real el progreso de su mascota.

**Diagrama de transiciones de estado:**

```
en_espera
    └── confirmada
            └── en_proceso
                    ├── completada
                    └── cancelada (por el profesional)
```

**Regla:** No se puede retroceder un estado (ej: no se puede pasar de `completada` a `en_proceso`).

**Criterios de aceptación:**

* [ ] El selector de estado solo muestra las transiciones válidas desde el estado actual.
* [ ] Al cambiar el estado, se registra la fecha/hora del cambio en la tabla `appointment_history`.
* [ ] El cliente recibe notificación local al detectar cada cambio de estado.
* [ ] El cambio se propaga en tiempo real vía Supabase Realtime.
* [ ] Solo el profesional asignado puede cambiar el estado (RLS).

| Campo        | Valor               |
| ------------ | ------------------- |
| Story Points | 5                   |
| Sprint       | 3                   |
| Responsable  | Luis Carlos Pedraza |
| Prioridad    | Alta                |

---

#### US-19 — Configurar disponibilidad

> **Como** profesional,
>
> **quiero** configurar mis días y horarios de atención,
>
> **para** que los clientes solo puedan reservar en mis horas disponibles.

**Flujo esperado:**

1. El profesional accede a "Mi disponibilidad".
2. Selecciona los días de la semana que trabaja.
3. Para cada día, define hora de inicio y fin de jornada.
4. Define la duración de cada slot (ej: 30 min, 1 hora).
5. Guarda la configuración.
6. El calendario de clientes se actualiza automáticamente.

**Criterios de aceptación:**

* [ ] El profesional puede habilitar/deshabilitar días individualmente.
* [ ] Puede definir hora de inicio y fin de jornada por día.
* [ ] Puede bloquear horarios específicos (descanso, reuniones).
* [ ] Los cambios se reflejan en el calendario del cliente en tiempo real.
* [ ] La configuración persiste entre sesiones.

| Campo        | Valor               |
| ------------ | ------------------- |
| Story Points | 8                   |
| Sprint       | 3                   |
| Responsable  | Luis Carlos Pedraza |
| Prioridad    | Alta                |

---

### Épica EP-05: Notificaciones y Tiempo Real

---

#### US-20 — Notificación al cliente por cambio de estado

> **Como** cliente,
>
> **quiero** recibir una notificación en mi dispositivo cuando el estado de mi cita cambie,
>
> **para** estar informado del progreso sin tener que abrir la app constantemente.

**Implementación técnica:**

* Suscripción Realtime al canal de `appointments` filtrada por `client_id`.
* Al detectar cambio, disparar notificación local con `flutter_local_notifications`.

**Criterios de aceptación:**

* [ ] El cliente recibe notificación cuando la cita pasa de `en_espera` a `confirmada`.
* [ ] El cliente recibe notificación cuando la cita pasa a `en_proceso`.
* [ ] El cliente recibe notificación cuando la cita pasa a `completada`.
* [ ] El cliente recibe notificación si la cita es cancelada por el profesional.
* [ ] Al pulsar la notificación, la app abre directamente la pantalla de detalle de esa cita.
* [ ] Las notificaciones funcionan con la app en segundo plano.

| Campo        | Valor            |
| ------------ | ---------------- |
| Story Points | 5                |
| Sprint       | 4                |
| Responsable  | Nicolas Gonzalez |
| Prioridad    | Alta             |

---

#### US-21 — Recordatorio 24 horas antes

> **Como** cliente,
>
> **quiero** recibir un recordatorio un día antes de mi cita,
>
> **para** no olvidar la cita y llegar puntual.

**Implementación técnica:**

* Edge Function de Supabase ejecutada con un cron job diario.
* La función consulta citas confirmadas para el día siguiente y dispara notificaciones locales programadas.

**Criterios de aceptación:**

* [ ] El recordatorio se programa automáticamente al confirmar la cita.
* [ ] Se envía 24 horas antes de la hora de la cita.
* [ ] El recordatorio incluye: nombre de la mascota, servicio, profesional y hora.
* [ ] Si la cita se cancela antes del recordatorio, este se cancela también.
* [ ] El usuario puede deshabilitar recordatorios desde configuración.

| Campo        | Valor            |
| ------------ | ---------------- |
| Story Points | 5                |
| Sprint       | 4                |
| Responsable  | Nicolas Gonzalez |
| Prioridad    | Alta             |

---

#### US-22 — Notificación al profesional por nueva cita

> **Como** profesional,
>
> **quiero** recibir una notificación cuando un cliente agenda una cita conmigo,
>
> **para** estar al tanto de nuevas reservas sin tener que revisar la agenda constantemente.

**Criterios de aceptación:**

* [ ] El profesional recibe notificación al instante cuando se crea una nueva cita asignada a él.
* [ ] La notificación incluye: nombre del cliente, mascota, servicio, fecha y hora.
* [ ] Al pulsar la notificación, se abre el detalle de la cita en su agenda.

| Campo        | Valor            |
| ------------ | ---------------- |
| Story Points | 3                |
| Sprint       | 4                |
| Responsable  | Nicolas Gonzalez |
| Prioridad    | Media            |

---

### Épica EP-06: Panel de Administración

---

#### US-23 — Gestionar servicios

> **Como** administrador,
>
> **quiero** gestionar el catálogo de servicios disponibles (baño, consulta, vacunación, etc.),
>
> **para** mantener actualizada la oferta de la clínica/peluquería.

**Campos de un servicio:** nombre, descripción, duración en minutos, precio, activo/inactivo.

**Criterios de aceptación:**

* [ ] El admin puede crear, editar y desactivar servicios.
* [ ] Los servicios desactivados no aparecen en el flujo de reserva del cliente.
* [ ] No es posible eliminar un servicio que tiene citas asociadas (solo desactivar).
* [ ] Los cambios se reflejan de inmediato en el catálogo visible al cliente.

| Campo        | Valor               |
| ------------ | ------------------- |
| Story Points | 5                   |
| Sprint       | 4                   |
| Responsable  | Luis Carlos Pedraza |
| Prioridad    | Alta                |

---

#### US-24 — Ver reportes de citas

> **Como** administrador,
>
> **quiero** ver un reporte de citas filtrable por fecha y estado,
>
> **para** analizar el desempeño de la clínica y tomar decisiones informadas.

**Métricas del reporte:**

* Total de citas por período.
* Citas por estado (en_espera, confirmada, completada, cancelada).
* Citas por profesional.
* Citas por servicio.

**Criterios de aceptación:**

* [ ] El reporte puede filtrarse por rango de fechas.
* [ ] Muestra contadores por estado con representación visual (barras o números).
* [ ] Se puede filtrar por profesional o servicio.
* [ ] La lista detallada es paginada (máximo 20 registros por página).
* [ ] Hay un indicador de "citas de hoy" en el dashboard principal del admin.

| Campo        | Valor               |
| ------------ | ------------------- |
| Story Points | 8                   |
| Sprint       | 4                   |
| Responsable  | Luis Carlos Pedraza |
| Prioridad    | Media               |

---

## 6. Tareas Técnicas por Sprint

### Sprint 2 — Autenticación y Mascotas

#### Nicolas Gonzalez — Autenticación (20h)

| TASK ID   | Tarea                           | Descripción técnica                                                                                               | Horas | HU    |
| --------- | ------------------------------- | ------------------------------------------------------------------------------------------------------------------- | ----- | ----- |
| TASK-05   | Integrar supabase_flutter       | Añadir dependencia, inicializar cliente con URL y anon key en `main.dart`, crear singleton `SupabaseService`   | 2h    | US-02 |
| TASK-06P1 | Pantalla de registro            | Widget `RegisterScreen`,`TextFormField`con validadores, llamada a `supabase.auth.signUp()`, manejo de errores | 5h    | US-01 |
| TASK-06P2 | Pantalla de login               | Widget `LoginScreen`,`signInWithPassword`, persistencia con `flutter_secure_storage`, redirect por rol        | 4h    | US-02 |
| TASK-06P3 | Recuperación de contraseña    | Widget `ForgotPasswordScreen`,`resetPasswordForEmail`, deep link con `app_links`                              | 3h    | US-03 |
| TASK-07   | Navegación por rol (Go Router) | Configurar `GoRouter`con guards de autenticación, rutas protegidas por rol, redirección automática             | 4h    | US-02 |
| TASK-04P1 | RLS para auth y users           | Policies:`users can read own row`,`users can update own row`, función `get_user_role()`                      | 2h    | US-01 |

#### Luis Carlos Pedraza — Supabase + Mascotas (20h)

| TASK ID   | Tarea                        | Descripción técnica                                                                                                                             | Horas | HU    |
| --------- | ---------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------- | ----- | ----- |
| TASK-02P1 | Configurar proyecto Supabase | Crear proyecto, habilitar Auth, Storage bucket `pet-photos`, activar Realtime en tablas necesarias                                              | 3h    | —    |
| TASK-03   | Esquema de BD y migraciones  | Crear tablas:`users`,`pets`,`services`,`availability`,`appointments`,`appointment_history`. Ejecutar migrations en Supabase Dashboard | 6h    | —    |
| TASK-04P2 | RLS para pets y citas        | Policies: clientes leen/modifican solo sus pets, profesionales leen citas asignadas, admin lee todo                                               | 4h    | US-06 |
| TASK-08P1 | Pantalla crear mascota       | `AddPetScreen`, formulario con `DropdownButton`para especie,`image_picker`para foto,`DatePicker`para nacimiento                           | 3h    | US-06 |
| TASK-08P2 | Pantalla listar mascotas     | `PetListScreen`,`ListView.builder`con `PetCard`, query con última cita vía JOIN, estado vacío                                            | 2h    | US-07 |
| TASK-08P3 | Pantalla editar mascota      | `EditPetScreen`, formulario prellenado, actualizar foto en Storage (delete antigua + upload nueva)                                              | 1h    | US-08 |
| TASK-08P4 | Eliminar mascota             | `AlertDialog`de confirmación, verificar citas activas antes de eliminar, delete de Storage                                                     | 1h    | US-09 |

---

### Sprint 3 — Citas y Panel Profesional

#### Nicolas Gonzalez — Calendario y Reservas (22h)

| TASK ID   | Tarea                   | Descripción técnica                                                                                                             | Horas | HU    |
| --------- | ----------------------- | --------------------------------------------------------------------------------------------------------------------------------- | ----- | ----- |
| TASK-09   | Integrar table_calendar | Añadir `table_calendar`, configurar `CalendarFormat`, marcar días disponibles desde query, highlight de días seleccionados | 8h    | US-10 |
| TASK-10P1 | Lógica de reserva      | `AppointmentRepository.createAppointment()`, validación de conflictos (app + trigger DB), flujo stepper en 6 pasos             | 6h    | US-11 |
| TASK-10P2 | Pantalla confirmación  | `AppointmentConfirmScreen`, resumen de datos, notificación local de confirmación, navegación post-confirmación              | 3h    | US-12 |
| TASK-14   | Notificaciones locales  | Integrar `flutter_local_notifications`, crear `NotificationService`, configurar canales Android/iOS                           | 2h    | US-20 |
| TASK-11P1 | Realtime para slots     | `SupabaseClient.channel('slots').onPostgresChanges(...)`, actualizar estado del calendario en tiempo real                       | 3h    | US-10 |

#### Luis Carlos Pedraza — Panel Profesional (18h)

| TASK ID   | Tarea                          | Descripción técnica                                                                                       | Horas | HU    |
| --------- | ------------------------------ | ----------------------------------------------------------------------------------------------------------- | ----- | ----- |
| TASK-12P1 | Panel profesional - agenda     | `ProfessionalHomeScreen`,`TabBar`para vista diaria/semanal,`AppointmentTile`con datos cliente+mascota | 6h    | US-16 |
| TASK-12P2 | Confirmar cita pendiente       | Botón condicional por estado,`AppointmentRepository.updateStatus()`, trigger notificación al cliente    | 3h    | US-17 |
| TASK-13P1 | Cambio de estado con historial | `StatusSelector`con transiciones válidas, insert en `appointment_history`por cada cambio, RT sync      | 6h    | US-18 |
| TASK-19P1 | GitHub Actions tests           | Workflow `.github/workflows/test.yml`,`flutter test`en cada PR a `develop`                            | 2h    | —    |
| TASK-13P2 | Pruebas unitarias CRUD pets    | Tests para `PetRepository`: crear, leer, actualizar, eliminar con mocks de Supabase                       | 1h    | —    |

---

### Sprint 4 — Admin, Notificaciones y Release

#### Luis Carlos Pedraza — Admin y Notificaciones (20h)

| TASK ID   | Tarea                         | Descripción técnica                                                                                                    | Horas | HU    |
| --------- | ----------------------------- | ------------------------------------------------------------------------------------------------------------------------ | ----- | ----- |
| TASK-17P1 | Admin - gestión de servicios | `ServicesManagementScreen`, CRUD con `DataTable`, activar/desactivar sin eliminar                                    | 8h    | US-23 |
| TASK-17P2 | Admin - gestión de usuarios  | `UsersManagementScreen`, tabla paginada, selector de rol, soft delete                                                  | 4h    | US-05 |
| TASK-17P3 | Admin - reportes              | `ReportsScreen`, contadores por estado, filtros de fecha con `DateRangePicker`, lista paginada                       | 4h    | US-24 |
| TASK-15   | Edge Function recordatorios   | Supabase Edge Function `send-reminders`, cron diario, query citas del día siguiente,`schedule()`notificación local | 4h    | US-21 |

#### Nicolas Gonzalez — CI/CD y Release (20h)

| TASK ID   | Tarea                      | Descripción técnica                                                                                           | Horas | HU    |
| --------- | -------------------------- | --------------------------------------------------------------------------------------------------------------- | ----- | ----- |
| TASK-11P2 | Realtime citas             | Suscripción al canal de `appointments`para cliente y profesional, dispatch de notificaciones locales         | 5h    | US-20 |
| TASK-18   | GitHub Actions APK         | Workflow `build-apk.yml`,`flutter build apk --release`, upload artifact, triggers en push a `main`        | 4h    | —    |
| TASK-19P2 | GitHub Actions CI completo | `flutter analyze`,`flutter test`, badge de estado en README                                                 | 3h    | —    |
| TASK-20   | Pruebas unitarias y widget | Tests para `AppointmentRepository`,`AuthService`,`PetRepository`, widget tests para formularios críticos | 5h    | —    |
| TASK-21   | Keystore y firma APK       | Generar keystore, configurar `key.properties`, firmar APK con `--release`, documentar proceso               | 2h    | —    |
| TASK-22   | Documentación final       | Actualizar README con instrucciones de setup, documentar variables de entorno, DartDoc en clases públicas      | 1h    | —    |

---

## 7. Lista de Issues para Jira

### Jerarquía de issues

```
Epic
  └── Story (Historia de Usuario)
        └── Sub-task (Tarea técnica)
  └── Technical Story (Tarea técnica sin HU directa)
```

### Sprint 2

| Tipo            | Issue                                      | Parent      | Responsable         | Prioridad | SP |
| --------------- | ------------------------------------------ | ----------- | ------------------- | --------- | -- |
| Epic            | Autenticación y gestión de usuarios      | —          | Equipo              | Alta      | — |
| Story           | Registrar usuario con correo y contraseña | EP-01       | Nicolas Gonzalez    | Alta      | 3  |
| Story           | Iniciar sesión y cerrar sesión           | EP-01       | Nicolas Gonzalez    | Alta      | 2  |
| Story           | Recuperar contraseña por email            | EP-01       | Nicolas Gonzalez    | Media     | 2  |
| Story           | Ver y editar perfil de usuario             | EP-01       | Nicolas Gonzalez    | Media     | 3  |
| Epic            | Gestión de mascotas                       | —          | Equipo              | Alta      | — |
| Story           | Registrar mascota                          | EP-02       | Luis Carlos Pedraza | Alta      | 3  |
| Story           | Listar mascotas registradas                | EP-02       | Luis Carlos Pedraza | Alta      | 2  |
| Story           | Editar mascota                             | EP-02       | Luis Carlos Pedraza | Media     | 2  |
| Story           | Eliminar mascota con confirmación         | EP-02       | Luis Carlos Pedraza | Media     | 2  |
| Technical Story | Configurar proyecto Supabase completo      | EP-01/EP-02 | Luis Carlos Pedraza | Alta      | — |
| Technical Story | Esquema de BD y migraciones                | EP-01/EP-02 | Luis Carlos Pedraza | Alta      | — |
| Technical Story | RLS policies iniciales                     | EP-01/EP-02 | Luis Carlos Pedraza | Alta      | — |
| Technical Story | Go Router con guards por rol               | EP-01       | Nicolas Gonzalez    | Alta      | — |

### Sprint 3

| Tipo  | Issue                                 | Parent | Responsable         | Prioridad | SP |
| ----- | ------------------------------------- | ------ | ------------------- | --------- | -- |
| Epic  | Reserva y gestión de citas           | —     | Equipo              | Alta      | — |
| Story | Ver calendario de disponibilidad      | EP-03  | Nicolas Gonzalez    | Alta      | 8  |
| Story | Reservar cita (flujo en pasos)        | EP-03  | Nicolas Gonzalez    | Alta      | 8  |
| Story | Confirmación inmediata de reserva    | EP-03  | Nicolas Gonzalez    | Media     | 3  |
| Story | Ver historial de citas                | EP-03  | Nicolas Gonzalez    | Media     | 3  |
| Story | Cancelar cita con liberación de slot | EP-03  | Luis Carlos Pedraza | Alta      | 5  |
| Story | Reprogramar cita                      | EP-03  | Nicolas Gonzalez    | Media     | 5  |
| Epic  | Panel del profesional                 | —     | Equipo              | Alta      | — |
| Story | Ver agenda diaria y semanal           | EP-04  | Luis Carlos Pedraza | Alta      | 5  |
| Story | Confirmar cita pendiente              | EP-04  | Luis Carlos Pedraza | Media     | 3  |
| Story | Actualizar estado de cita             | EP-04  | Luis Carlos Pedraza | Alta      | 5  |
| Story | Configurar disponibilidad laboral     | EP-04  | Luis Carlos Pedraza | Alta      | 8  |

### Sprint 4

| Tipo            | Issue                                      | Parent | Responsable         | Prioridad | SP |
| --------------- | ------------------------------------------ | ------ | ------------------- | --------- | -- |
| Epic            | Notificaciones y tiempo real               | —     | Equipo              | Media     | — |
| Story           | Notificar cambio de estado al cliente      | EP-05  | Nicolas Gonzalez    | Alta      | 5  |
| Story           | Recordatorio 24 horas antes                | EP-05  | Nicolas Gonzalez    | Alta      | 5  |
| Story           | Notificar nueva cita al profesional        | EP-05  | Nicolas Gonzalez    | Media     | 3  |
| Epic            | Panel de administración                   | —     | Equipo              | Media     | — |
| Story           | Gestionar catálogo de servicios           | EP-06  | Luis Carlos Pedraza | Alta      | 5  |
| Story           | Ver reportes de citas                      | EP-06  | Luis Carlos Pedraza | Media     | 8  |
| Story           | Gestionar usuarios y roles                 | EP-06  | Luis Carlos Pedraza | Media     | 5  |
| Epic            | CI/CD y calidad                            | —     | Equipo              | Media     | — |
| Technical Story | Pipeline GitHub Actions - tests            | EP-07  | Luis Carlos Pedraza | Alta      | — |
| Technical Story | Pipeline GitHub Actions - APK release      | EP-07  | Nicolas Gonzalez    | Alta      | — |
| Technical Story | Pruebas unitarias y widget (60% cobertura) | EP-07  | Nicolas Gonzalez    | Alta      | — |
| Technical Story | Generación y firma de APK                 | EP-07  | Nicolas Gonzalez    | Alta      | — |
| Technical Story | Documentación técnica final y DartDoc    | EP-07  | Luis Carlos Pedraza | Media     | — |

---

## 8. Matriz de Asignación de Tareas

### Luis Carlos Pedraza — Especialista Backend + Admin UI

**Fortalezas:** Diseño UX/UI, persistencia de datos, lógica de negocio, documentación técnica.

| Sprint          | Tareas asignadas                             | Horas         | % carga        |
| --------------- | -------------------------------------------- | ------------- | -------------- |
| Sprint 1        | Documentación, Jira, wireframes, evidencias | 24h           | 60%            |
| Sprint 2        | Supabase setup, BD, RLS, CRUD mascotas       | 20h           | 50%            |
| Sprint 3        | Panel profesional, estados, testing base     | 18h           | 45%            |
| Sprint 4        | Admin panel, Edge Functions, notificaciones  | 20h           | 50%            |
| **TOTAL** | —                                           | **82h** | **~51%** |

### Nicolas Gonzalez — Especialista Frontend + CI/CD

**Fortalezas:** Flutter UI, autenticación, tiempo real, automatización de pipelines.

| Sprint          | Tareas asignadas                                 | Horas         | % carga        |
| --------------- | ------------------------------------------------ | ------------- | -------------- |
| Sprint 1        | Repositorio, estructura Flutter, revisión final | 10h           | 25%            |
| Sprint 2        | Auth completa, Go Router, RLS auth               | 20h           | 50%            |
| Sprint 3        | Calendario, reservas, Realtime slots             | 22h           | 55%            |
| Sprint 4        | CI/CD, Realtime citas, APK, testing              | 20h           | 50%            |
| **TOTAL** | —                                               | **72h** | **~45%** |

---

## 9. Definición de Terminado

Una historia o tarea se considera **COMPLETADA** únicamente cuando cumple **todos** los criterios siguientes:

### Criterios funcionales

* [ ] Código implementado según la especificación de la HU.
* [ ] Todos los criterios de aceptación verificados manualmente.
* [ ] Integración con Supabase (Auth / DB / Realtime / Storage) verificada en entorno real.
* [ ] Sin errores bloqueadores en `flutter analyze`.

### Criterios de calidad

* [ ] Código revisado por el otro miembro del equipo mediante Pull Request.
* [ ] PR aprobado antes de mergear a `develop`.
* [ ] Pruebas unitarias o de widget escritas para lógica crítica.
* [ ] Sin warnings de linting marcados como `error` en `analysis_options.yaml`.
* [ ] Clases y métodos públicos documentados con DartDoc (`///`).

### Criterios de integración

* [ ] Mergeado a rama `develop` (nunca directamente a `main`).
* [ ] Issue en Jira movido a columna  **Done** .
* [ ] Commit SHA enlazado en el comentario del issue en Jira.
* [ ] Evidencia capturada: screenshot o video si es pantalla UI, log de consola si es lógica backend.

### Criterios de documentación

* [ ] Burndown del sprint actualizado.
* [ ] Si se modificó el esquema de BD, la migración está documentada en `/docs`.
* [ ] Si se añadió una variable de entorno, está registrada en `.env.example`.

---

## 10. Riesgos por Sprint

| Sprint   | Riesgo                                                           | Probabilidad | Impacto | Mitigación                                                          |
| -------- | ---------------------------------------------------------------- | ------------ | ------- | -------------------------------------------------------------------- |
| Sprint 2 | Supabase RLS mal configurada bloquea todo el módulo de mascotas | Alta         | Alto    | Probar policies con Supabase SQL Editor antes de integrar en Flutter |
| Sprint 2 | Deep link de recuperación de contraseña no funciona en Android | Media        | Medio   | Probar con `app_links`en dispositivo físico desde el inicio       |
| Sprint 3 | Doble reserva en mismo slot por condición de carrera            | Media        | Alto    | Añadir constraint `UNIQUE(professional_id, scheduled_at)`en DB    |
| Sprint 3 | `table_calendar`no soporta bien carga dinámica de eventos     | Baja         | Medio   | Evaluar `syncfusion_flutter_calendar`como alternativa              |
| Sprint 4 | Edge Function de recordatorios falla silenciosamente             | Media        | Medio   | Añadir logging en la función y revisar Supabase logs regularmente  |
| Sprint 4 | Firma del APK en CI/CD expone keystore                           | Media        | Alto    | Usar GitHub Secrets para almacenar keystore y contraseña            |

---

## 11. Referencias Cruzadas

| Recurso                             | Enlace                                                                                                                                                          |
| ----------------------------------- | --------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| 📄 Documentación técnica completa | [PetAppointment_Documentacion_Tecnica.md](https://claude.ai/PetAppointment_Documentacion_Tecnica.md)                                                               |
| 📋 Tablero Jira                     | https://correounivalle-team-f1bug4uj.atlassian.net/jira/software/projects/PA/summary?atlOrigin=eyJpIjoiM2Y2ZDkwMzk2NWNiNDNmMjk5OTQwMmZkMzIzYjZjZmMiLCJwIjoiaiJ9 |
| 🔗 Repositorio GitHub               | https://github.com/LuisCPedraza/pet-appointment                                                                                                                 |
| 📝 Entrega 1 - evidencias           | [Entrega_1_Primer_Adelanto.md](https://claude.ai/Entrega_1_Primer_Adelanto.md)                                                                                     |
| 🎨 Guía de estilo visual           | [STYLE_GUIDE.md](https://claude.ai/STYLE_GUIDE.md)                                                                                                                 |

---

**Documento generado:** 12 de abril de 2026

**Próxima revisión:** 28 de abril de 2026 (fin Sprint 2)

**Versión:** 2.0
