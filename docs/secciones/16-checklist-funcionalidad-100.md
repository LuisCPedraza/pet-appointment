# Checklist de Funcionalidad al 100%

**Proyecto:** PetAppointment  
**Objetivo:** usar este documento como checklist vivo para cerrar la funcionalidad pendiente y seguir el avance por fases.

---

## Estado general

- [ ] **Hecho**: ya está implementado y validado.
- [ ] **Parcial**: existe una base, pero falta cerrar el flujo o endurecerlo.
- [ ] **Pendiente**: no está implementado o no está validado todavía.

---

## 0. Check inicial del estado actual

- [x] **Notificaciones push**: integración local y remota validada end-to-end en Android con cola, Edge Function y Firebase.
- [x] Base de registro de tokens remotos en Supabase.
- [x] Cola de eventos push remotos en Supabase.
- [x] Edge Function para enviar eventos push.
- [x] Scheduler programado para invocar `send-push-events` cada 5 minutos.
- [x] **Slots del profesional**: ahora se pueden activar y desactivar desde la UI, y los slots inactivos siguen visibles.
- [x] **Edición de perfil**: ya permite conservar la foto actual o elegir galería/cámara.

---

## 1. Prioridad alta

### Notificaciones push

- [x] Integración completa de `flutter_local_notifications` con backend remoto.
- [x] Base de registro de tokens remotos en Supabase.
- [x] Disparar notificación cuando se crea una cita.
- [x] Disparar notificación cuando se modifica una cita.
- [x] Disparar notificación cuando se cancela una cita.
- [x] Definir si el canal será Supabase Edge Functions o Firebase Messaging.

### Roles y permisos

- [x] Diferenciar claramente los flujos de cliente, profesional y admin.
- [x] Validar rutas protegidas por rol.
- [x] Validar acciones permitidas por rol en UI y backend.
- [ ] Revisar consistencia de RLS con los permisos de la app.

### Flujo de citas

- [x] Confirmación automática o manual de citas por el profesional.
- [x] Validación fuerte de disponibilidad para evitar doble booking.
- [x] El filtro de slots ocupados respeta el rango visible del calendario y la reprogramación.
- [x] Cancelación con motivo.
- [ ] Definir si aplica reembolso y cómo se registra.
- [x] Historial de cambios de estado completamente trazable.
- [x] Reglas puras de transición y cancelación cubiertas con pruebas unitarias.

### Perfil de profesional

- [x] Gestión de horarios disponibles por día y hora.
- [x] Lista de citas pendientes.
- [x] Lista de citas confirmadas.
- [x] Vista de agenda clara para el profesional.

---

## 2. Prioridad media

### Realtime

- [x] Manejo de errores de conexión.
- [x] Manejo de reconexión.
- [x] Actualización automática de agenda sin refrescar.
- [x] Validar que la experiencia no se rompa cuando Realtime falla.

### Errores y UX

- [x] Mensajes de error más amigables en historial y disponibilidad.
- [x] Estados de carga consistentes en historial y disponibilidad.
- [x] Pantallas vacías bien resueltas en historial y agenda profesional.
- [ ] Validaciones de formulario más completas.

### Imágenes y storage

- [x] Subida de fotos de mascotas estable.
- [x] Visualización correcta de fotos de mascotas.
- [ ] Optimización básica de imágenes.

### Búsqueda y filtros

- [x] Buscar profesionales por nombre/email (filtro local en UI, tests añadidos).
- [ ] Buscar profesionales por especialidad.
- [ ] Buscar profesionales por ubicación.
- [ ] Buscar profesionales por calificación.
- [ ] Validar filtros útiles para el usuario final.

---

## 3. Prioridad baja

### Pruebas

- [x] Ampliar pruebas unitarias.
- [x] Ampliar pruebas de integración.
- [x] Cubrir los flujos críticos de cita, rol y disponibilidad.
- [x] Documentar y validar el flujo de push end-to-end en Android.

### Plataforma y calidad

- [ ] Revisar manejo offline si aplica.
- [ ] Validar soporte iOS completo.
- [ ] Analizar rendimiento y optimizaciones.
- [ ] Completar dark mode.
- [ ] Revisar accesibilidad.

---

## 4. Arranque de trabajo

### En curso

- [~] Cerrar el alcance real del MVP con criterios medibles.
- [~] Priorizar roles/permisos y flujo de citas.
 - [x] Revisar filtros profesionales (filtro por nombre/email implementado)
- [x] Validación en staging de reconexión Realtime con desconexión forzada

### Siguiente paso recomendado

1. Validar el alcance exacto de cliente, profesional y admin.
2. Definir el flujo de cita final y sus reglas de negocio.
3. Cerrar notificaciones push con la solución elegida.

---

## 5. Criterio de cierre

- [ ] Todo lo de prioridad alta está en **hecho**.
- [ ] Lo de prioridad media está al menos en **parcial validado**.
 - [x] Las pruebas cubren los flujos críticos. (tests unitarios y widget: todos pasan en CI local)
- [ ] No quedan huecos funcionales bloqueantes para producción.

---

## 6. Observación

Este checklist debe actualizarse cuando cambie el alcance o se cierre una tarea relevante. Si algo queda discutido pero no validado, debe seguir marcado como parcial o pendiente.

---

## 7. Cierre

- **Estado:** En progreso (quedan items pendientes que deben verificarse en staging).
- **Fecha de actualización:** 31 de mayo de 2026.
- **Nota:** Varias entradas están marcadas como resueltas para Android y backend; quedan pendientes optimizaciones, cobertura de tests adicionales y validación iOS/QA en staging.
