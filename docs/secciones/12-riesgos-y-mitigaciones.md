## 12. Riesgos y Mitigaciones

| ID | Riesgo | Probabilidad | Impacto | Mitigación |
|---|---|---|---|---|
| R-01 | Colisiones de horario si dos usuarios reservan el mismo slot simultáneamente | Media | Alto | Verificación de disponibilidad con transacción atómica; índice UNIQUE en slot activo |
| R-02 | Límite de conexiones Realtime en plan gratuito de Supabase | Baja | Medio | Monitorear conexiones; diseñar listeners eficientes; prever upgrade a plan Pro |
| R-03 | Fallo en el envío de notificaciones push (FCM) | Media | Medio | Retry logic en Edge Function; fallback a notificación local |
| R-04 | Cuenta de WhatsApp Business no aprobada a tiempo | Alta | Bajo | Usar Twilio Sandbox para demostración; documentar como prototipo |
| R-05 | Rotación de credenciales / claves de Supabase expuestas en código | Baja | Alto | Usar GitHub Secrets; nunca commitear el archivo .env; revisión con gitleaks |
| R-06 | Deuda técnica por cambios de última hora en el esquema de BD | Media | Alto | Usar sistema de migraciones desde el día 1; no modificar tablas directamente en producción |
| R-07 | Falta de experiencia del equipo con Flutter/Riverpod | Alta | Medio | Dedicar primera semana a spikes técnicos y prototipos; documentar decisiones en ADR |
| R-08 | Dispositivos de prueba con versiones antiguas de Android | Media | Medio | Definir `minSdkVersion 24` (Android 7); probar en emulador con API 24 y 33 |
| R-09 | Cambios en la API de Supabase que rompan la integración | Baja | Alto | Fijar versiones en `pubspec.yaml`; revisar changelog de Supabase en cada actualización |

---

