## 2. Alcance Funcional Inicial

### 2.1 Incluido en la Versión 1.0

| # | Módulo | Funcionalidad incluida |
|---|---|---|
| 1 | Autenticación | Registro, inicio de sesión y cierre de sesión con Supabase Auth |
| 2 | Perfil | Gestión de datos del usuario y de sus mascotas (CRUD básico) |
| 3 | Catálogo de servicios | Listado de servicios disponibles (consulta veterinaria, baño, peluquería) |
| 4 | Reserva de citas | Selección de fecha, hora, mascota y servicio; confirmación de cita |
| 5 | Calendario visual | Vista de calendario con disponibilidad en tiempo real |
| 6 | Gestión de citas (cliente) | Visualizar, reprogramar y cancelar citas propias |
| 7 | Panel veterinario | Vista de agenda diaria/semanal; actualización de estado de citas |
| 8 | Panel administrador | Gestión de usuarios, servicios y horarios disponibles |
| 9 | Estados de cita | Flujo completo: En espera → Confirmada → En progreso → Atendida / Cancelada |
| 10 | Notificaciones | Notificaciones locales en dispositivo (recordatorios y cambios de estado) |
| 11 | Tiempo real | Sincronización de disponibilidad y estados vía Supabase Realtime |
| 12 | Seguridad | Row Level Security (RLS) en todas las tablas sensibles |
| 13 | APK | Generación de APK Android firmado mediante GitHub Actions |

### 2.2 Fuera del Alcance de la Versión 1.0

| # | Funcionalidad excluida | Razón |
|---|---|---|
| 1 | Pagos en línea (PSE, tarjeta, PayPal) | Complejidad regulatoria y técnica; roadmap v2.0 |
| 2 | Chat en tiempo real entre cliente y veterinario | Fuera del alcance académico de v1.0 |
| 3 | Historia clínica digital completa | Módulo especializado; roadmap v2.0 |
| 4 | Notificaciones por WhatsApp (producción) | Requiere cuenta verificada de negocio; incluido como prototipo |
| 5 | Soporte multiidioma (i18n) | No requerido para el contexto local del proyecto |
| 6 | Portal web administrativo | Solo aplicación móvil en v1.0 |
| 7 | Integración con wearables / IoT | Fuera del alcance del proyecto |
| 8 | Sistema de reseñas y calificaciones | Roadmap v2.0 |
| 9 | Módulo de inventario y farmacia | Fuera del alcance académico |
| 10 | App iOS en producción (App Store) | Se intentará soporte iOS; prioridad es Android APK |

---

