## 10. Manual de Usuario

### 10.1 Instalación

**Requisitos del dispositivo:**
- Android 7.0 (API 24) o superior.
- Conexión a internet activa.
- Al menos 50 MB de espacio libre.

**Pasos para instalar:**

1. Descargar el archivo `app-release.apk` desde la sección Releases del repositorio GitHub o desde el enlace compartido por el equipo.
2. En el dispositivo Android, ir a **Configuración > Seguridad** y habilitar la opción *"Instalar aplicaciones de fuentes desconocidas"* (o *"Instalar aplicaciones desconocidas"* en Android 8+).
3. Abrir el archivo APK descargado y pulsar **Instalar**.
4. Esperar a que finalice la instalación y pulsar **Abrir**.

### 10.2 Registro e Inicio de Sesión

**Registro de nueva cuenta:**

```
[Pantalla de bienvenida]
┌─────────────────────────────────────┐
│  🐾 PetAppointment                  │
│                                     │
│  Tu veterinaria en tu bolsillo      │
│                                     │
│  [  Iniciar sesión  ]               │
│  [  Registrarse     ]               │
└─────────────────────────────────────┘
```

1. Pulsar **Registrarse**.
2. Completar el formulario: nombre completo, correo electrónico, contraseña (mínimo 8 caracteres).
3. Seleccionar el tipo de cuenta: **Cliente** o **Profesional**.
4. Pulsar **Crear cuenta**.
5. Revisar el correo electrónico para confirmar la cuenta.
6. Una vez confirmada, iniciar sesión con las credenciales registradas.

### 10.3 Gestión de Mascotas (Rol: Cliente)

```
[Mi perfil] → [Mis mascotas] → [+ Agregar mascota]
┌─────────────────────────────────────┐
│  🐕 Nueva mascota                   │
│                                     │
│  Nombre: [________________]         │
│  Especie: [Perro ▼]                 │
│  Raza:    [________________]        │
│  Fecha nacimiento: [DD/MM/AAAA]     │
│  Notas adicionales:                 │
│  [                              ]   │
│                                     │
│  [  Guardar mascota  ]              │
└─────────────────────────────────────┘
```

1. Desde el menú principal, ir a **Mi perfil > Mis mascotas**.
2. Pulsar el botón **+** o **Agregar mascota**.
3. Completar los datos: nombre, especie, raza y fecha de nacimiento.
4. Pulsar **Guardar**. La mascota aparecerá en el listado.

### 10.4 Reservar una Cita (Rol: Cliente)

```
[Inicio] → [Nueva cita]

Paso 1: Seleccionar servicio
┌─────────────────────────────────────┐
│  ¿Qué servicio necesitas?           │
│                                     │
│  🏥 Consulta veterinaria    [→]     │
│  ✂️  Peluquería canina       [→]     │
│  🛁 Baño y desparasitación  [→]     │
└─────────────────────────────────────┘

Paso 2: Seleccionar mascota
Paso 3: Ver calendario de disponibilidad
Paso 4: Confirmar cita
```

1. Desde el panel principal, pulsar **Nueva cita** o el ícono de calendario.
2. **Paso 1:** Seleccionar el servicio deseado de la lista.
3. **Paso 2:** Elegir la mascota para la que se agenda la cita.
4. **Paso 3:** Se muestra el calendario visual. Los días con disponibilidad aparecen marcados en verde. Pulsar un día para ver los horarios disponibles.
5. Seleccionar el horario deseado.
6. **Paso 4:** Revisar el resumen de la cita y pulsar **Confirmar reserva**.
7. Aparece una pantalla de confirmación con el código de la cita y los detalles. Se enviará una notificación de confirmación.

### 10.5 Ver y Gestionar Citas (Rol: Cliente)

```
[Mis citas]
┌─────────────────────────────────────┐
│  PRÓXIMAS                           │
│  ┌───────────────────────────────┐  │
│  │ 🐕 Luna — Baño y peluquería   │  │
│  │ 📅 15 Abr 2026, 10:00 AM      │  │
│  │ 👨‍⚕️ Dr. Martínez              │  │
│  │ 🟡 En espera                  │  │
│  │  [Ver detalle]  [Cancelar]    │  │
│  └───────────────────────────────┘  │
│                                     │
│  HISTORIAL                          │
│  [Citas pasadas con estado final]   │
└─────────────────────────────────────┘
```

- **Ver detalle:** Muestra toda la información de la cita.
- **Cancelar:** Solicita confirmación antes de cancelar. Una vez cancelada, el horario queda libre para otros usuarios.
- **Estados visuales:** 🟡 En espera | 🟢 Confirmada | 🔵 En progreso | ✅ Atendida | ❌ Cancelada

### 10.6 Panel del Profesional (Rol: Profesional)

```
[Agenda hoy — Lunes 14 Abr 2026]
┌─────────────────────────────────────┐
│  9:00 AM  │ 🐱 Simba — Consulta     │
│           │ Cliente: Ana López      │
│           │ [Iniciar] [Ver detalle] │
├───────────┼─────────────────────────┤
│ 11:00 AM  │ 🐕 Max — Peluquería    │
│           │ Cliente: Carlos Ruiz    │
│           │ [Confirmar]             │
├───────────┼─────────────────────────┤
│  3:00 PM  │ (Disponible)            │
└─────────────────────────────────────┘
```

1. Al iniciar sesión como profesional, se muestra directamente la agenda del día.
2. Cambiar entre vista **Día**, **Semana** o **Mes** usando el selector superior.
3. Pulsar sobre una cita para ver los detalles completos.
4. Usar los botones de acción para **Confirmar**, **Iniciar atención** o **Marcar como Atendida**.
5. Los cambios se reflejan en tiempo real en la app del cliente.

### 10.7 Panel de Administración (Rol: Administrador)

El administrador accede a un menú extendido con las siguientes secciones:

- **Usuarios:** Listado de todos los usuarios, con opción de cambiar rol o deshabilitar cuenta.
- **Servicios:** Crear, editar y activar/desactivar servicios del catálogo.
- **Horarios:** Configurar horarios de disponibilidad por profesional.
- **Citas:** Vista global de todas las citas con filtros por estado, fecha y profesional.
- **Reportes:** Resumen estadístico de citas por período.

---

