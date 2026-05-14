# Go-Live Checklist - Sprint 4

**Proyecto:** PetAppointment  
**Objetivo:** revisar si el Sprint 4 ya está listo para cerrar y pasar a despliegue / preparación de release.

---

## Estado general

- [ ] **Listo**: funcionalidad completa y validada.
- [ ] **Pendiente**: falta trabajo, pero no bloquea por completo.
- [ ] **Bloqueado**: depende de corrección urgente o de una validación externa.

---

## Checklist funcional

### Cliente

- [ ] Home del usuario muestra datos reales, próxima cita y accesos rápidos.
- [ ] Perfil del usuario muestra datos reales y permite edición.
- [ ] Flujo de reserva permite escoger profesional.
- [ ] Confirmación de cita muestra la información correcta.

### Admin

- [ ] El admin entra a su propio panel con navegación separada.
- [ ] El admin puede asignar roles a usuarios.
- [ ] El admin puede gestionar servicios.
- [ ] El admin puede ver el catálogo y el estado correcto de los registros.

### Citas

- [ ] El flujo de reserva guarda el `professional_id` correcto.
- [ ] El calendario filtra slots por profesional seleccionado.
- [ ] No hay regresiones en cancelación o reprogramación.

---

## Checklist técnico

- [ ] `flutter analyze` pasa sin errores bloqueadores.
- [ ] `flutter test` pasa.
- [ ] Las tareas críticas tienen pruebas base o de widget.
- [ ] Las rutas protegidas por rol funcionan correctamente.
- [ ] Las RLS de Supabase están validadas para `client`, `professional` y `admin`.
- [ ] No hay credenciales sensibles en el repositorio.

---

## Checklist de datos y backend

- [ ] Las migraciones necesarias están aplicadas en Supabase.
- [ ] Las RPC de roles y estado están probadas.
- [ ] La columna `is_active` está validada en login.
- [ ] El admin no puede desactivar su propia cuenta.
- [ ] Las consultas de home, perfil y profesional responden correctamente.

---

## Checklist de release

- [ ] El Sprint 4 quedó documentado en el plan de sprints.
- [ ] Los issues de Jira están creados y vinculados a sus US.
- [ ] El burndown o seguimiento del sprint está actualizado.
- [ ] Hay evidencias de las pantallas clave.
- [ ] Se definió el alcance real del Sprint 5.

---

## Semáforo final

### Verde
- Todo lo funcional crítico está listo.
- Los tests pasan.
- La base de datos y las RLS están validadas.
- El equipo puede mover el proyecto a preparación de despliegue.

### Amarillo
- El producto funciona, pero faltan pruebas, evidencia o pulido menor.
- Se puede cerrar Sprint 4, pero no conviene liberar todavía.

### Rojo
- Hay fallos en flujo de cita, admin, seguridad o datos.
- El Sprint 4 no debe cerrarse hasta corregirlos.

---

## Recomendación

Si la mayoría de los puntos están en **verde**, el proyecto está listo para pasar a preparación de despliegue.  
Si hay varios puntos en **amarillo**, conviene cerrar primero Sprint 4 y dejar Sprint 5 para estabilización, pruebas y release.
