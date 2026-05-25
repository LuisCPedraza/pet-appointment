# Verificación de push end-to-end en Android

Este procedimiento valida que la app Flutter registra el token FCM del dispositivo y que Supabase puede enviar una notificación real usando la Edge Function `send-push-events`.

## 1. Requisitos previos

- Proyecto creado en Firebase Console.
- `android/app/google-services.json` descargado desde Firebase y copiado al proyecto.
- Secrets configurados:
  - En Supabase: `FCM_SERVER_KEY`
  - En GitHub Actions: `SUPABASE_SERVICE_ROLE_KEY` y `SUPABASE_SEND_PUSH_EVENTS_URL`
- La Edge Function `send-push-events` ya desplegada en Supabase.

## 2. Verificación en Android

1. Ejecuta la app en un dispositivo o emulador con Google Play Services.
2. Inicia sesión con un usuario real.
3. Abre la app y deja que `FcmService` obtenga el token.
4. Verifica en Supabase que se insertó un registro en `public.push_device_tokens`.

Consulta útil:

```sql
select user_id, token, platform, is_active, last_seen_at
from public.push_device_tokens
order by last_seen_at desc
limit 10;
```

## 3. Generar un evento de prueba

1. Crea o modifica una cita para disparar un registro en `push_notification_events`.
2. Lanza el workflow `Schedule Send Push` desde GitHub Actions o invoca manualmente la Edge Function.
3. Confirma que el evento pasa de `pending` a `sent`.

## 4. Qué debe pasar

- El token se guarda con `platform = android`.
- La Edge Function lee los eventos pendientes.
- El dispositivo recibe la notificación.
- El evento queda marcado como enviado.

## 5. Fallos comunes

- Si no aparece token, revisa `google-services.json` y que la app esté corriendo en un dispositivo con Google Play Services.
- Si la Edge Function falla, revisa que existan `FCM_SERVER_KEY` en Supabase y `SUPABASE_SERVICE_ROLE_KEY` en GitHub Actions.
- Si el envío se procesa pero no llega al móvil, revisa el token registrado y los logs de Firebase.
