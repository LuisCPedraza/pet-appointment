# Go-Live Checklist Sprint 4 - Resumen Ejecutivo

**Proyecto:** PetAppointment  
**Uso:** decisión rápida para cerrar Sprint 4 y definir si el proyecto pasa a preparación de despliegue.

---

## Estado rápido

- [ ] **Verde**: listo para seguir.
- [ ] **Amarillo**: funciona, pero falta pulido o validación.
- [ ] **Rojo**: hay bloqueo y no debe cerrarse aún.

---

## 1. Funcionalidad clave

- [ ] Home del usuario con datos reales.
- [ ] Perfil del usuario con datos reales y edición.
- [ ] Reserva con selección de profesional.
- [ ] Panel admin separado del cliente.
- [ ] Cambio de roles de usuarios desde admin.
- [ ] Gestión de servicios desde admin.

---

## 2. Calidad técnica

- [ ] `flutter analyze` sin errores bloqueantes.
- [ ] `flutter test` pasa.
- [ ] Las rutas por rol funcionan correctamente.
- [ ] La RLS de Supabase está validada por rol.
- [ ] No hay secretos en el repositorio.

---

## 3. Datos y backend

- [ ] Migraciones aplicadas y probadas.
- [ ] RPC de cambio de rol y estado probadas.
- [ ] `is_active` validado en login.
- [ ] El admin no puede desactivar su propia cuenta.
- [ ] Las consultas de home y perfil responden bien.

---

## 4. Cierre del sprint

- [ ] Las historias del Sprint 4 están en Jira.
- [ ] Las tasks están enlazadas a sus US.
- [ ] Hay evidencia de pantallas clave.
- [ ] El burndown está actualizado.
- [ ] El alcance del Sprint 5 ya quedó definido.

---

## Decisión final

### Pasar a preparación de despliegue si:
- Todo lo funcional clave está en verde.
- Las pruebas pasan.
- La seguridad y la base de datos están validadas.

### Cerrar Sprint 4, pero no desplegar todavía si:
- El producto funciona, pero faltan pruebas, evidencia o ajustes menores.

### Bloquear cierre si:
- Hay fallas en citas, admin, RLS o login.

---

## Recomendación

Si la mayoría de los puntos están en verde, el Sprint 4 puede cerrarse y el equipo puede preparar el despliegue.

Si quieres, este resumen también se puede convertir en una tabla tipo semáforo para imprimir o pegar en Jira.
