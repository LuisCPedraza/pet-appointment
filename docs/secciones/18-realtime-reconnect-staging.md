# Validación en Staging: Realtime con desconexión forzada

## Objetivo
Verificar en entorno staging que:
- La app detecta caída de Realtime.
- Se aplican reintentos con backoff exponencial.
- Se respeta el tope de reintentos por sesión.
- La experiencia de agenda no se rompe al reconectar.

## Alcance
- Pantalla/flujo de calendario que utiliza `CalendarController`.
- Canales monitoreados: `appointments`, `slots`, `services`.

## Precondiciones
- Build en staging con credenciales válidas de Supabase.
- Cuenta de prueba con permisos para ver agenda y cambios de citas.
- Logs visibles desde `flutter run` o `flutter logs`.

## Procedimiento manual
1. Inicia la app en staging y abre el flujo de calendario/agendamiento.
2. Confirma en logs al menos 1 evento de suscripción exitosa por canal.
   - Patrón esperado:
     - `Realtime [appointments] status=SUBSCRIBED`
     - `Realtime [slots] status=SUBSCRIBED`
     - `Realtime [services] status=SUBSCRIBED`
3. Fuerza desconexión de red del dispositivo/emulador:
   - Activa modo avión 20–40 segundos.
   - O desactiva Wi-Fi/datos móviles temporalmente.
4. Observa logs de error/estado no suscrito.
5. Restablece conectividad.
6. Verifica en logs los reintentos:
   - `Realtime reconnect #1 ... in 2s`
   - `Realtime reconnect #2 ... in 4s`
   - `Realtime reconnect #3 ... in 8s`
   - `Realtime reconnect #4 ... in 16s`
   - `Realtime reconnect #5 ... in 60s`
7. Si se excede el máximo sin éxito, debe aparecer:
   - `Realtime reconnect disabled after 5 attempts ...`
8. Con conexión restablecida, confirma que la agenda se refresca sin reiniciar la app:
   - Cambia un slot/cita desde otro cliente o panel y valida actualización automática.

## Criterios de aceptación
- Se detecta caída de Realtime y no hay crash.
- Backoff visible en logs y coherente con la secuencia esperada.
- Se respeta límite de 5 reintentos por sesión.
- Tras reconexión, la agenda vuelve a actualizarse en tiempo real.

## Resultado (plantilla)
- Fecha/hora:
- Entorno:
- Usuario de prueba:
- Resultado por criterio:
  - Detección de caída: OK/FAIL
  - Backoff: OK/FAIL
  - Límite de reintentos: OK/FAIL
  - Recuperación de agenda: OK/FAIL
- Evidencia:
  - Capturas o fragmentos de logs:
- Observaciones:
