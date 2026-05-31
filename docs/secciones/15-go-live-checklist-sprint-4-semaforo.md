# Go-Live Checklist Sprint 4 - Semáforo

**Proyecto:** PetAppointment  
**Objetivo:** decisión rápida sobre cierre de Sprint 4 y paso a preparación de despliegue.

---

## Semáforo de decisión

| Área | Verde | Amarillo | Rojo |
| --- | --- | --- | --- |
| Home del usuario | Muestra datos reales, próxima cita y accesos rápidos | Muestra datos, pero falta pulido visual o refresh | Sigue en placeholder o con datos incorrectos |
| Perfil del usuario | Muestra datos reales y permite edición | Muestra datos, pero falta navegación o recarga | Sigue en placeholder o no carga datos reales |
| Reserva con profesional | Permite escoger profesional y guarda `professional_id` correcto | Hay selector, pero falta ajustar validación o UX | No existe selector o guarda mal la cita |
| Panel admin | Accede con rol admin y tiene navegación separada | Accede, pero faltan tabs o pulido | No abre o abre como cliente |
| Gestión de roles | Admin cambia roles con seguridad y RLS | Cambia roles, pero falta validación o feedback | No funciona o expone permisos |
| Gestión de servicios | Admin crea, edita y desactiva servicios | Funciona parcialmente | No funciona |
| RLS y seguridad | Policies validadas por rol | Algunas policies faltan validación | Hay riesgo de acceso indebido |
| Pruebas | `flutter analyze` y `flutter test` pasan | Pasa parcialmente o con warnings | Falla en errores bloqueantes |
| Release | Hay checklist, evidencia y alcance de Sprint 5 definido | Falta evidencia o ajuste menor | No hay base para release |

---

## Cómo usarlo

- Marca **Verde** cuando esté listo.
- Marca **Amarillo** cuando funcione pero falte pulido.
- Marca **Rojo** cuando haya bloqueo real.

---

## Decisión final

- **Mayoría Verde:** pasar a preparación de despliegue.
- **Mayoría Amarillo:** cerrar Sprint 4 y dejar Sprint 5 para estabilización.
- **Algún Rojo en flujo crítico:** no cerrar Sprint 4 todavía.

---

## Observación recomendada

Si el Home, Perfil, selector de profesional y panel admin están en verde, el Sprint 4 ya se puede considerar suficientemente sólido para avanzar.
