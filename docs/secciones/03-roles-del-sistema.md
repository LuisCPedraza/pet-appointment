## 3. Roles del Sistema

### 3.1 Descripción de Roles

| Rol | Identificador interno | Descripción |
|---|---|---|
| **Cliente / Dueño de Mascota** | `client` | Usuario final que registra sus mascotas y agenda citas. Puede visualizar su historial de citas y recibir notificaciones. |
| **Veterinario / Peluquero** | `professional` | Profesional que presta el servicio. Gestiona su agenda, confirma o cancela citas y actualiza el estado de atención. |
| **Administrador** | `admin` | Gestiona la configuración global del sistema: usuarios, servicios ofrecidos, horarios habilitados y reportes básicos. |

### 3.2 Permisos por Rol

| Acción | Cliente | Profesional | Administrador |
|---|:---:|:---:|:---:|
| Registrarse / Iniciar sesión | ✅ | ✅ | ✅ |
| Registrar mascotas | ✅ | ❌ | ✅ |
| Ver servicios disponibles | ✅ | ✅ | ✅ |
| Crear cita | ✅ | ❌ | ✅ |
| Cancelar cita propia | ✅ | ❌ | ✅ |
| Ver agenda de citas | Solo propias | Todas asignadas | Todas |
| Actualizar estado de cita | ❌ | ✅ | ✅ |
| Crear/editar servicios | ❌ | ❌ | ✅ |
| Gestionar horarios | ❌ | ❌ | ✅ |
| Ver panel de administración | ❌ | ❌ | ✅ |
| Gestionar usuarios | ❌ | ❌ | ✅ |

---

