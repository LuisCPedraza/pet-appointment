## 1. Visión General, Contexto y Objetivos

### 1.1 Contexto

El sector veterinario en América Latina ha experimentado un crecimiento sostenido debido al aumento en la tenencia responsable de mascotas. Sin embargo, la gestión de citas en clínicas veterinarias y peluquerías caninas/felinas continúa realizándose mayoritariamente de forma manual — mediante llamadas telefónicas, cuadernos físicos o grupos de mensajería informal — lo que genera conflictos de horarios, falta de trazabilidad y una experiencia deficiente tanto para el cliente como para el prestador del servicio.

**PetAppointment** surge como respuesta a esta problemática: una aplicación móvil multiplataforma desarrollada en Flutter y Dart, conectada directamente a Supabase como plataforma de backend, que permite gestionar de forma integral el ciclo de vida de las citas veterinarias y de peluquería para mascotas.

### 1.2 Objetivo General

Desarrollar una aplicación móvil funcional (APK para Android) que permita a los dueños de mascotas reservar, modificar y cancelar citas en clínicas veterinarias y peluquerías caninas/felinas, al tiempo que provee a los prestadores del servicio un panel de gestión con calendario visual, actualización de estados en tiempo real y notificaciones automáticas, aprovechando la infraestructura serverless de Supabase (Auth, Database, Realtime y Edge Functions).

### 1.3 Objetivos Específicos

1. Implementar un módulo de autenticación seguro mediante Supabase Auth que soporte registro e inicio de sesión para tres roles diferenciados: Cliente/Dueño de Mascota, Veterinario/Peluquero y Administrador.
2. Desarrollar un calendario visual interactivo en Flutter que permita visualizar la disponibilidad de horarios y evitar colisiones mediante sincronización en tiempo real utilizando Supabase Realtime.
3. Construir el modelo de datos relacional en PostgreSQL (Supabase) con tablas normalizadas para usuarios, mascotas, servicios, citas y estados, aplicando políticas de Row Level Security (RLS) para garantizar el acceso diferenciado por rol.
4. Integrar un sistema de notificaciones que incluya alertas push locales en el dispositivo y recordatorios automáticos mediante Supabase Edge Functions, con la posibilidad de extensión hacia notificaciones por WhatsApp a través de la API de Twilio o WhatsApp Business Cloud API.
5. Configurar un pipeline de integración y entrega continua (CI/CD) con GitHub Actions que automatice la compilación, las pruebas y la generación del APK instalable publicado como GitHub Release.
6. Implementar un flujo completo de gestión de estados de cita ("En espera", "Confirmada", "En progreso", "Atendida", "Cancelada") con actualización en tiempo real visible desde todos los roles del sistema.
7. Documentar el proyecto de forma completa para facilitar su comprensión, mantenimiento y extensión futura por parte del equipo de desarrollo y de evaluadores académicos.

---

