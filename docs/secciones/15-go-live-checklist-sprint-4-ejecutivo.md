# Go-Live Checklist Sprint 4 - Resumen Ejecutivo

**Proyecto:** PetAppointment  
**Uso:** decisión rápida para cerrar Sprint 4 y definir si el proyecto pasa a preparación de despliegue.

---

## Estado rápido

- [ ] **Verde**: listo para seguir.
- [x] **Amarillo**: funciona, pero falta pulido o validación. (iOS nativo y analíticas pendientes)
- [ ] **Rojo**: hay bloqueo y no debe cerrarse aún.

---

## 1. Funcionalidad clave

- [x] Home del usuario con datos reales. (verificado en Android)
- [x] Perfil del usuario con datos reales y edición.
- [x] Reserva con selección de profesional.
- [x] Panel admin separado del cliente.
- [x] Cambio de roles de usuarios desde admin.
- [x] Gestión de servicios desde admin.

---

## 2. Calidad técnica

- [x] `flutter analyze` sin errores bloqueantes.
- [x] `flutter test` pasa en local (existen advertencias de Supabase y un `unawaited` por corregir en CI/tests).
- [x] Las rutas por rol funcionan correctamente.
- [x] La RLS de Supabase está validada por rol.
- [x] No hay secretos en el repositorio (ejemplos y `key.properties.example` incluidos).

---

## 3. Datos y backend

- [x] Migraciones aplicadas y probadas (carpeta `migrations/`).
- [ ] RPC de cambio de rol y estado probadas (parcialmente; automatizar pruebas pendientes).
- [x] `is_active` validado en login.
- [x] El admin no puede desactivar su propia cuenta.
- [x] Las consultas de home y perfil responden bien (verificación manual en staging/local).

---

## 4. Cierre del sprint

- [x] Las historias del Sprint 4 están documentadas en el repo y plan de sprints.
- [ ] Las tasks están enlazadas a sus US (dependiente de Jira externo).
- [x] Hay evidencia de pantallas clave (APK generado y revisado en dispositivo).
- [x] El burndown está actualizado.
- [x] El alcance del Sprint 5 ya quedó definido.

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
