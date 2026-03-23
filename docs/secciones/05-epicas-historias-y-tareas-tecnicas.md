## 5. Épicas, Historias de Usuario y Tareas Técnicas

### 5.1 Épicas del Proyecto

| ID | Épica | Descripción | Prioridad |
|---|---|---|---|
| EP-01 | Autenticación y Gestión de Usuarios | Registro, inicio de sesión, recuperación de contraseña y gestión de perfiles por rol | Alta |
| EP-02 | Gestión de Mascotas | CRUD completo de mascotas asociadas a un cliente | Alta |
| EP-03 | Reserva y Gestión de Citas | Flujo completo de creación, modificación y cancelación de citas con calendario visual | Alta |
| EP-04 | Panel del Profesional | Agenda visual, actualización de estados y gestión de disponibilidad | Alta |
| EP-05 | Notificaciones y Tiempo Real | Sincronización en tiempo real, notificaciones locales y recordatorios automáticos | Media |
| EP-06 | Panel de Administración | Gestión de catálogos (servicios, horarios, usuarios) y reportes | Media |
| EP-07 | CI/CD y Calidad | Pipeline de GitHub Actions, pruebas automatizadas y generación de APK | Media |

### 5.2 Historias de Usuario

#### Épica EP-01: Autenticación y Gestión de Usuarios

| ID | Historia de Usuario | Criterios de Aceptación | Story Points |
|---|---|---|---|
| US-01 | Como **usuario nuevo**, quiero **registrarme con mi correo y contraseña** para **acceder a la aplicación y gestionar mis citas**. | Formulario con validación, confirmación por email, asignación de rol | 3 |
| US-02 | Como **usuario registrado**, quiero **iniciar sesión con mi correo y contraseña** para **acceder a mi cuenta de forma segura**. | Autenticación vía Supabase Auth, token JWT, manejo de errores | 2 |
| US-03 | Como **usuario**, quiero **recuperar mi contraseña mediante email** para **no perder acceso a mi cuenta si la olvido**. | Email de recuperación enviado, enlace funcional, nueva contraseña actualizada | 2 |
| US-04 | Como **usuario**, quiero **ver y editar mi perfil** (nombre, teléfono, foto) para **mantener mis datos actualizados**. | Formulario editable, actualización en Supabase, confirmación visual | 3 |
| US-05 | Como **administrador**, quiero **ver el listado de usuarios registrados** para **gestionar accesos y roles**. | Tabla paginada con filtro por rol, opción de cambiar rol o deshabilitar cuenta | 5 |

#### Épica EP-02: Gestión de Mascotas

| ID | Historia de Usuario | Criterios de Aceptación | Story Points |
|---|---|---|---|
| US-06 | Como **cliente**, quiero **registrar mis mascotas** (nombre, especie, raza, fecha de nacimiento) para **asociarlas a mis citas**. | Formulario con validación, foto opcional, guardado en Supabase | 3 |
| US-07 | Como **cliente**, quiero **ver el listado de mis mascotas registradas** para **seleccionar la correcta al agendar una cita**. | Lista con foto y datos básicos, indicador de última cita | 2 |
| US-08 | Como **cliente**, quiero **editar la información de mi mascota** para **mantener sus datos actualizados**. | Formulario prellenado, actualización en DB, confirmación | 2 |
| US-09 | Como **cliente**, quiero **eliminar una mascota de mi perfil** para **mantener solo los registros vigentes**. | Confirmación antes de eliminar, verificación de citas activas asociadas | 2 |

#### Épica EP-03: Reserva y Gestión de Citas

| ID | Historia de Usuario | Criterios de Aceptación | Story Points |
|---|---|---|---|
| US-10 | Como **cliente**, quiero **ver un calendario con los horarios disponibles** para **elegir el que mejor se adapte a mi agenda**. | Calendario visual con slots libres/ocupados, sincronizado en tiempo real | 8 |
| US-11 | Como **cliente**, quiero **reservar una cita** seleccionando servicio, profesional, mascota, fecha y hora para **garantizar mi atención**. | Flujo de reserva en pasos, validación de disponibilidad, cita creada con estado "En espera" | 8 |
| US-12 | Como **cliente**, quiero **recibir una confirmación inmediata** tras reservar una cita para **tener certeza de que fue registrada**. | Pantalla de éxito con resumen de la cita, notificación local | 3 |
| US-13 | Como **cliente**, quiero **ver el historial de todas mis citas** (pasadas y futuras) para **llevar un control de la salud de mis mascotas**. | Lista ordenada por fecha, indicador de estado, detalle al pulsar | 3 |
| US-14 | Como **cliente**, quiero **cancelar una cita con antelación** para **liberar el horario y notificar al profesional**. | Confirmación de cancelación, estado actualizado, slot liberado, notificación enviada | 5 |
| US-15 | Como **cliente**, quiero **reprogramar una cita** para **adaptarla a cambios en mi agenda sin perder el servicio**. | Selección de nuevo slot, cancelación del anterior, nueva cita creada | 5 |

#### Épica EP-04: Panel del Profesional

| ID | Historia de Usuario | Criterios de Aceptación | Story Points |
|---|---|---|---|
| US-16 | Como **profesional**, quiero **ver mi agenda diaria y semanal** para **planificar mi jornada de trabajo**. | Vista de calendario con citas agrupadas, datos del cliente y mascota visibles | 5 |
| US-17 | Como **profesional**, quiero **confirmar una cita pendiente** para **notificar al cliente que su reserva fue aceptada**. | Botón de confirmación, estado cambia a "Confirmada", notificación automática al cliente | 3 |
| US-18 | Como **profesional**, quiero **actualizar el estado de una cita** (en progreso, atendida) para **reflejar el avance en tiempo real**. | Selector de estado con transiciones válidas, actualización instantánea vía Realtime | 5 |
| US-19 | Como **profesional**, quiero **configurar mis horarios de disponibilidad** para **que solo se puedan agendar citas en mis horas laborales**. | Selector de días/horas, persistencia en available_slots, reflejo en el calendario del cliente | 8 |

#### Épica EP-05: Notificaciones y Tiempo Real

| ID | Historia de Usuario | Criterios de Aceptación | Story Points |
|---|---|---|---|
| US-20 | Como **cliente**, quiero **recibir una notificación** cuando el estado de mi cita cambie para **estar siempre informado**. | Notificación local en dispositivo al detectar cambio de estado vía Realtime | 5 |
| US-21 | Como **cliente**, quiero **recibir un recordatorio 24 horas antes** de mi cita para **no olvidarla**. | Notificación programada vía Supabase Edge Function o flutter_local_notifications | 5 |
| US-22 | Como **profesional**, quiero **ser notificado al instante** cuando se registre una nueva cita para **preparar mi agenda con anticipación**. | Notificación push en tiempo real vía Supabase Realtime | 3 |

#### Épica EP-06: Panel de Administración

| ID | Historia de Usuario | Criterios de Aceptación | Story Points |
|---|---|---|---|
| US-23 | Como **administrador**, quiero **crear, editar y desactivar servicios** para **mantener actualizado el catálogo de la clínica**. | CRUD completo de servicios, activación/desactivación sin eliminar | 5 |
| US-24 | Como **administrador**, quiero **ver un reporte básico de citas** por período y estado para **evaluar la demanda del servicio**. | Listado filtrable por fecha y estado, contadores por categoría | 8 |

### 5.3 Tareas Técnicas e Issues

| ID | Tarea Técnica | Épica | Estimación |
|---|---|---|---|
| TASK-01 | Configurar proyecto Flutter con estructura de carpetas por features | EP-07 | 4h |
| TASK-02 | Configurar proyecto Supabase (Auth, DB, Realtime, Storage) | EP-01 | 3h |
| TASK-03 | Definir esquema de base de datos y ejecutar migrations | EP-01 | 6h |
| TASK-04 | Implementar RLS policies para todas las tablas | EP-01 | 6h |
| TASK-05 | Integrar paquete `supabase_flutter` y configurar cliente global | EP-01 | 2h |
| TASK-06 | Implementar flujo de autenticación (registro, login, logout) | EP-01 | 8h |
| TASK-07 | Implementar navegación por rol con Go Router | EP-01 | 4h |
| TASK-08 | Desarrollar pantallas de gestión de mascotas (CRUD) | EP-02 | 10h |
| TASK-09 | Integrar `table_calendar` para vista de disponibilidad | EP-03 | 8h |
| TASK-10 | Implementar lógica de reserva con validación de colisiones | EP-03 | 10h |
| TASK-11 | Implementar suscripción Realtime para slots y citas | EP-05 | 8h |
| TASK-12 | Desarrollar panel del profesional con agenda interactiva | EP-04 | 12h |
| TASK-13 | Implementar cambio de estado de citas con historial | EP-04 | 6h |
| TASK-14 | Integrar `flutter_local_notifications` para recordatorios | EP-05 | 6h |
| TASK-15 | Crear Edge Function para recordatorios automáticos (cron) | EP-05 | 8h |
| TASK-16 | Prototipo de Edge Function para notificación por WhatsApp (Twilio) | EP-05 | 6h |
| TASK-17 | Desarrollar panel de administración (servicios, horarios, usuarios) | EP-06 | 16h |
| TASK-18 | Configurar GitHub Actions para build de APK | EP-07 | 4h |
| TASK-19 | Configurar GitHub Actions para tests y lint | EP-07 | 3h |
| TASK-20 | Escribir pruebas unitarias y de widget (cobertura mínima 60%) | EP-07 | 12h |
| TASK-21 | Generar keystore y firmar APK para release | EP-07 | 2h |
| TASK-22 | Documentar API de Supabase y funciones edge | EP-07 | 4h |

---

