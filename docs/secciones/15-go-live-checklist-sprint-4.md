# Go-Live Checklist - Sprint 4

**Proyecto:** PetAppointment  
**Objetivo:** revisar si el Sprint 4 ya está listo para cerrar y pasar a despliegue / preparación de release.

---

## Estado general

- [ ] **Listo**: funcionalidad completa y validada.
- [x] **Pendiente**: falta trabajo, pero no bloquea por completo.  
	(Hay validaciones pendientes: iOS nativo, analíticas e instrumentación.)
- [ ] **Bloqueado**: depende de corrección urgente o de una validación externa.

---

## Checklist funcional

### Cliente

- [x] Home del usuario muestra datos reales, próxima cita y accesos rápidos. (verificado en Android)
- [x] Perfil del usuario muestra datos reales y permite edición.
- [x] Flujo de reserva permite escoger profesional.
- [x] Confirmación de cita muestra la información correcta.

### Admin

- [x] El admin entra a su propio panel con navegación separada.
- [x] El admin puede asignar roles a usuarios.
- [x] El admin puede gestionar servicios.
- [x] El admin puede ver el catálogo y el estado correcto de los registros.

### Citas

- [x] El flujo de reserva guarda el `professional_id` correcto.
- [x] El calendario filtra slots por profesional seleccionado.
- [x] No hay regresiones en cancelación o reprogramación (tests y validación manual).

---

## Checklist técnico


- [x] `flutter analyze` pasa sin errores bloqueadores.
- [x] `flutter test` pasa (hay advertencias relacionadas con Supabase en entorno de test, no bloqueantes).
- [ ] Las tareas críticas tienen pruebas base o de widget. (se agregaron algunas; completar cobertura)
 - [x] Las tareas críticas tienen pruebas base o de widget. (tests unitarios y widget añadidos; `flutter test --coverage` pasa)
- [x] Las rutas protegidas por rol funcionan correctamente (revisión manual y políticas RLS en docs).
- [x] Las RLS de Supabase están validadas para `client`, `professional` y `admin` (migraciones y documentación existentes).
- [x] No hay credenciales sensibles en el repositorio (variables en `.env`, `key.properties.example` incluido como ejemplo).

Nota: se agregó inicialización defensiva de Firebase y dependencia `firebase_crashlytics` en el `pubspec.yaml`; verificación de Crashlytics en consola pendiente.

---

## Checklist de datos y backend


- [x] Las migraciones necesarias están aplicadas en Supabase (migrations/ y docs).
- [ ] Las RPC de roles y estado están probadas (parciales, completar pruebas automatizadas).
- [x] La columna `is_active` está validada en login.
- [x] El admin no puede desactivar su propia cuenta (lógica implementada en backend y UI preventiva).
- [x] Las consultas de home, perfil y profesional responden correctamente en pruebas manuales.

---

## Checklist de release


- [x] El Sprint 4 quedó documentado en el plan de sprints (docs/secciones y README).
- [ ] Los issues de Jira están creados y vinculados a sus US (depende del control de proyecto externo).
- [x] El burndown o seguimiento del sprint está actualizado (según tablero de proyecto).
- [x] Hay evidencias de las pantallas clave (APK generado y revisión en dispositivo).
- [x] Se definió el alcance real del Sprint 5 en el roadmap.

---

## Semáforo final


### Verde
- Todo lo funcional crítico está listo.
- Los tests pasan en el entorno local y CI.
- La base de datos y las RLS están validadas.

### Amarillo
- Falta instrumentación de analíticas y métricas (DAU/MAU, retención).
- Validación nativa en iOS no realizada (pendiente Xcode / Apple Developer).

### Rojo
- No hay elementos rojos críticos actualmente: ningún flujo crítico bloquea el cierre del sprint.

---

## Recomendación

Si la mayoría de los puntos están en **verde**, el proyecto está listo para pasar a preparación de despliegue.  
Si hay varios puntos en **amarillo**, conviene cerrar primero Sprint 4 y dejar Sprint 5 para estabilización, pruebas y release.
