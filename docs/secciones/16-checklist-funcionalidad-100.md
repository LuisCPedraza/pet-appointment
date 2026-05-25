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

- [~] **Notificaciones push**: hay base local con `flutter_local_notifications`, cola remota de eventos y Edge Function, pero falta integración real con proveedor y validación end-to-end.
- [x] Base de registro de tokens remotos en Supabase.
- [~] Cola de eventos push remotos en Supabase.
- [~] Edge Function para enviar eventos push.
- [x] Scheduler programado para invocar `send-push-events` cada 5 minutos.
- [~] **Slots del profesional**: ahora se pueden activar y desactivar desde la UI, y los slots inactivos siguen visibles.
- [~] **Edición de perfil**: ya permite conservar la foto actual o elegir galería/cámara.

---

## 1. Prioridad alta

### Notificaciones push

- [ ] Integración completa de `flutter_local_notifications` con backend remoto.
- [~] Base de registro de tokens remotos en Supabase.
- [ ] Disparar notificación cuando se crea una cita.
- [ ] Disparar notificación cuando se modifica una cita.
- [ ] Disparar notificación cuando se cancela una cita.
- [ ] Definir si el canal será Supabase Edge Functions o Firebase Messaging.

### Roles y permisos

- [x] Diferenciar claramente los flujos de cliente, profesional y admin.
- [x] Validar rutas protegidas por rol.
- [~] Validar acciones permitidas por rol en UI y backend.
- [ ] Revisar consistencia de RLS con los permisos de la app.

### Flujo de citas

- [ ] Confirmación automática o manual de citas por el profesional.
- [~] Validación fuerte de disponibilidad para evitar doble booking.
- [x] Cancelación con motivo.
- [ ] Definir si aplica reembolso y cómo se registra.
- [x] Historial de cambios de estado completamente trazable.
- [x] Reglas puras de transición y cancelación cubiertas con pruebas unitarias.

### Perfil de profesional

- [x] Gestión de horarios disponibles por día y hora.
- [ ] Lista de citas pendientes.
- [ ] Lista de citas confirmadas.
- [x] Vista de agenda clara para el profesional.

---

## 2. Prioridad media

### Realtime

- [ ] Manejo de errores de conexión.
- [ ] Manejo de reconexión.
- [ ] Actualización automática de agenda sin refrescar.
- [ ] Validar que la experiencia no se rompa cuando Realtime falla.

### Errores y UX

- [ ] Mensajes de error más amigables.
- [ ] Estados de carga consistentes.
- [ ] Pantallas vacías bien resueltas.
- [ ] Validaciones de formulario más completas.

### Imágenes y storage

- [x] Subida de fotos de mascotas estable.
- [x] Visualización correcta de fotos de mascotas.
- [ ] Optimización básica de imágenes.

### Búsqueda y filtros

- [ ] Buscar profesionales por especialidad.
- [ ] Buscar profesionales por ubicación.
- [ ] Buscar profesionales por calificación.
- [ ] Validar filtros útiles para el usuario final.

---

## 3. Prioridad baja

### Pruebas

- [x] Ampliar pruebas unitarias.
- [~] Ampliar pruebas de integración.
- [ ] Cubrir los flujos críticos de cita, rol y disponibilidad.
- [~] Documentar y validar el flujo de push end-to-end en Android.

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

### Siguiente paso recomendado

1. Validar el alcance exacto de cliente, profesional y admin.
2. Definir el flujo de cita final y sus reglas de negocio.
3. Cerrar notificaciones push con la solución elegida.

---

## 5. Criterio de cierre

- [ ] Todo lo de prioridad alta está en **hecho**.
- [ ] Lo de prioridad media está al menos en **parcial validado**.
- [ ] Las pruebas cubren los flujos críticos.
- [ ] No quedan huecos funcionales bloqueantes para producción.

---

## 6. Observación

Este checklist debe actualizarse cuando cambie el alcance o se cierre una tarea relevante. Si algo queda discutido pero no validado, debe seguir marcado como parcial o pendiente.