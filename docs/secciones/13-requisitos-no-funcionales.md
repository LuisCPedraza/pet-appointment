## 13. Requisitos No Funcionales

### 13.1 Rendimiento

| Requisito | Métrica objetivo |
|---|---|
| Tiempo de carga inicial de la app | < 3 segundos en conexión 4G |
| Tiempo de respuesta al reservar una cita | < 2 segundos |
| Latencia de actualización en tiempo real | < 2 segundos desde el cambio en DB |
| Tamaño del APK | < 30 MB |
| Soporte de usuarios concurrentes (plan gratuito Supabase) | ≤ 500 conexiones simultáneas |

### 13.2 Seguridad

- **Autenticación:** Todos los endpoints están protegidos por JWT de Supabase Auth. Los tokens tienen expiración de 1 hora con refresh automático.
- **Row Level Security (RLS):** Habilitado en todas las tablas. Los usuarios solo pueden leer y modificar sus propios registros.
- **Políticas RLS de ejemplo:**

```sql
-- Política: un cliente solo ve sus propias citas
create policy "Clientes ven sus citas"
  on appointments
  for select
  using (auth.uid() = client_id);

-- Política: un profesional ve las citas que le fueron asignadas
create policy "Profesionales ven sus citas asignadas"
  on appointments
  for select
  using (
    auth.uid() in (
      select user_id from professionals where id = professional_id
    )
  );

-- Política: admin ve todas las citas
create policy "Admins ven todo"
  on appointments
  for all
  using (
    exists (
      select 1 from users
      where id = auth.uid() and role = 'admin'
    )
  );
```

- **Variables de entorno:** Las claves de Supabase nunca se almacenan en el código fuente; se inyectan como variables de compilación mediante `--dart-define` o GitHub Secrets.
- **HTTPS:** Toda comunicación con Supabase utiliza HTTPS/TLS por defecto.

### 13.3 Escalabilidad

- La arquitectura serverless de Supabase permite escalar horizontalmente sin cambios en el código de la aplicación.
- El esquema de base de datos está diseñado con índices en columnas de filtro frecuente (`client_id`, `professional_id`, `slot_start`, `status`).
- Los canales Realtime se diseñan con filtros específicos para minimizar el tráfico innecesario.

### 13.4 Mantenibilidad

- Arquitectura Clean Architecture con separación clara entre capas (data, domain, presentation).
- Cobertura de pruebas mínima del 60% en lógica de negocio.
- Documentación inline con DartDoc en todas las clases públicas.
- Uso de `analysis_options.yaml` con reglas estrictas de linting.

---

