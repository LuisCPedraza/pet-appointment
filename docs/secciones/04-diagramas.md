## 4. Diagramas

> **Nota:** Todos los diagramas están escritos en sintaxis Mermaid y se renderizan automáticamente en GitHub, GitLab y herramientas compatibles.

### 4.1 Diagrama de Casos de Uso

```mermaid
---
title: PetAppointment — Diagrama de Casos de Uso
---
flowchart TD
    %% Actores
    C([👤 Cliente])
    P([👨‍⚕️ Profesional])
    A([🔧 Administrador])
    SB([☁️ Supabase])

    %% Casos de uso — Cliente
    C --> UC1(Registrarse / Iniciar sesión)
    C --> UC2(Registrar mascota)
    C --> UC3(Ver servicios disponibles)
    C --> UC4(Reservar cita)
    C --> UC5(Ver calendario de disponibilidad)
    C --> UC6(Cancelar cita)
    C --> UC7(Ver historial de citas)
    C --> UC8(Recibir notificaciones)

    %% Casos de uso — Profesional
    P --> UC1
    P --> UC9(Ver agenda diaria / semanal)
    P --> UC10(Confirmar cita)
    P --> UC11(Actualizar estado de cita)
    P --> UC12(Cancelar cita)
    P --> UC8

    %% Casos de uso — Administrador
    A --> UC1
    A --> UC13(Gestionar usuarios)
    A --> UC14(Gestionar servicios)
    A --> UC15(Configurar horarios disponibles)
    A --> UC16(Ver reportes)
    A --> UC9
    A --> UC11

    %% Sistema externo
    UC1 --> SB
    UC4 --> SB
    UC5 --> SB
    UC11 --> SB
    SB --> UC8
```

### 4.2 Diagrama Entidad-Relación (ERD)

```mermaid
---
title: PetAppointment — Modelo Entidad-Relación
---
erDiagram
    USERS {
        uuid id PK
        text email
        text full_name
        text phone
        text role
        timestamp created_at
    }

    PETS {
        uuid id PK
        uuid owner_id FK
        text name
        text species
        text breed
        date birth_date
        text notes
        timestamp created_at
    }

    SERVICES {
        uuid id PK
        text name
        text description
        int duration_minutes
        decimal price
        boolean is_active
    }

    PROFESSIONALS {
        uuid id PK
        uuid user_id FK
        text specialization
        text bio
    }

    AVAILABLE_SLOTS {
        uuid id PK
        uuid professional_id FK
        uuid service_id FK
        timestamp slot_start
        timestamp slot_end
        boolean is_available
    }

    APPOINTMENTS {
        uuid id PK
        uuid client_id FK
        uuid pet_id FK
        uuid professional_id FK
        uuid service_id FK
        uuid slot_id FK
        text status
        text notes
        timestamp created_at
        timestamp updated_at
    }

    APPOINTMENT_HISTORY {
        uuid id PK
        uuid appointment_id FK
        text previous_status
        text new_status
        uuid changed_by FK
        timestamp changed_at
    }

    NOTIFICATIONS {
        uuid id PK
        uuid user_id FK
        uuid appointment_id FK
        text type
        text message
        boolean is_read
        timestamp created_at
    }

    USERS ||--o{ PETS : "posee"
    USERS ||--o| PROFESSIONALS : "es"
    PROFESSIONALS ||--o{ AVAILABLE_SLOTS : "tiene"
    SERVICES ||--o{ AVAILABLE_SLOTS : "aplica a"
    USERS ||--o{ APPOINTMENTS : "agenda"
    PETS ||--o{ APPOINTMENTS : "protagoniza"
    PROFESSIONALS ||--o{ APPOINTMENTS : "atiende"
    SERVICES ||--o{ APPOINTMENTS : "incluye"
    AVAILABLE_SLOTS ||--o{ APPOINTMENTS : "ocupa"
    APPOINTMENTS ||--o{ APPOINTMENT_HISTORY : "registra"
    USERS ||--o{ NOTIFICATIONS : "recibe"
    APPOINTMENTS ||--o{ NOTIFICATIONS : "genera"
```

### 4.3 Diagrama de Secuencia — Reservar una Cita

```mermaid
sequenceDiagram
    actor Cliente
    participant App as App Flutter
    participant SB as Supabase DB
    participant RT as Supabase Realtime
    participant Prof as Panel Profesional

    Cliente->>App: Abre calendario y selecciona fecha
    App->>SB: GET available_slots WHERE date = ? AND is_available = true
    SB-->>App: Lista de horarios disponibles
    App-->>Cliente: Muestra horarios en calendario

    Cliente->>App: Selecciona horario, mascota y servicio
    Cliente->>App: Confirma reserva

    App->>SB: BEGIN TRANSACTION
    App->>SB: INSERT INTO appointments (...)
    App->>SB: UPDATE available_slots SET is_available = false WHERE id = ?
    SB-->>App: COMMIT — cita creada con status "En espera"

    SB->>RT: Broadcast evento "new_appointment"
    RT->>Prof: Notificación en tiempo real (nueva cita)
    RT->>App: Confirmación de sincronización

    App-->>Cliente: Pantalla de confirmación con detalles de la cita
    App->>SB: INSERT INTO notifications (user_id, message, type='new_appointment')
```

### 4.4 Diagrama de Secuencia — Cancelar una Cita

```mermaid
sequenceDiagram
    actor Cliente
    participant App as App Flutter
    participant SB as Supabase DB
    participant RT as Supabase Realtime
    participant Prof as Panel Profesional
    participant EF as Edge Function

    Cliente->>App: Selecciona cita activa → "Cancelar cita"
    App-->>Cliente: Diálogo de confirmación con motivo (opcional)
    Cliente->>App: Confirma cancelación

    App->>SB: UPDATE appointments SET status = 'Cancelada' WHERE id = ?
    App->>SB: UPDATE available_slots SET is_available = true WHERE id = ?
    SB-->>App: OK

    SB->>EF: Trigger on_appointment_status_change
    EF->>SB: INSERT INTO notifications para cliente y profesional
    EF-->>SB: Opcional: enviar WhatsApp vía Twilio API

    SB->>RT: Broadcast "appointment_cancelled"
    RT->>Prof: Actualización en tiempo real en agenda
    RT->>App: Estado actualizado en UI

    App-->>Cliente: Confirmación de cancelación + slot liberado en calendario
```

### 4.5 Diagrama de Secuencia — Actualización de Estado en Tiempo Real

```mermaid
sequenceDiagram
    actor Profesional
    participant PanelProf as Panel Profesional (Flutter)
    participant SB as Supabase DB
    participant RT as Supabase Realtime
    participant AppCliente as App Cliente (Flutter)
    actor Cliente

    Profesional->>PanelProf: Selecciona cita → cambia estado a "En progreso"
    PanelProf->>SB: UPDATE appointments SET status = 'En progreso' WHERE id = ?
    SB-->>PanelProf: OK — estado actualizado

    SB->>RT: INSERT en appointment_history dispara evento Realtime
    RT-->>AppCliente: Evento "appointment_updated" { id, status: 'En progreso' }
    AppCliente->>AppCliente: Actualiza UI sin recargar página
    AppCliente-->>Cliente: Badge/notificación: "Tu cita está en progreso"

    Profesional->>PanelProf: Finaliza atención → cambia estado a "Atendida"
    PanelProf->>SB: UPDATE appointments SET status = 'Atendida' WHERE id = ?
    SB->>RT: Broadcast "appointment_updated" { status: 'Atendida' }
    RT-->>AppCliente: Evento recibido
    AppCliente-->>Cliente: "Tu mascota fue atendida exitosamente 🐾"
```

### 4.6 Diagrama de Arquitectura Técnica

```mermaid
flowchart TD
    subgraph MOBILE["📱 Aplicación Móvil — Flutter / Dart"]
        UI[Capa de Presentación\nWidgets & Screens]
        BL[Capa de Negocio\nProviders / Bloc / Riverpod]
        DS[Capa de Datos\nRepositories & Data Sources]
    end

    subgraph SUPABASE["☁️ Supabase Platform"]
        AUTH[Supabase Auth\nJWT + Email/Social]
        DB[(PostgreSQL\nTablas + RLS)]
        RT[Supabase Realtime\nWebSocket Channels]
        ST[Supabase Storage\nAvatares de mascotas]
        EF[Edge Functions\nDeno — Notificaciones]
    end

    subgraph EXTERNAL["🌐 Servicios Externos"]
        FCM[Firebase Cloud Messaging\nPush Notifications]
        TWILIO[Twilio / WhatsApp\nCloud API]
    end

    subgraph CICD["🔄 CI/CD"]
        GH[GitHub Actions\nBuild APK + Tests]
        REL[GitHub Releases\nAPK Distribución]
    end

    UI --> BL --> DS
    DS <-->|supabase_flutter SDK| AUTH
    DS <-->|supabase_flutter SDK| DB
    DS <-->|supabase_flutter SDK| RT
    DS <-->|supabase_flutter SDK| ST
    EF --> FCM
    EF --> TWILIO
    DB -->|Database Triggers| EF
    GH --> REL
```

### 4.7 Flujo General del Sistema

```mermaid
flowchart TD
    A([Inicio]) --> B{¿Tiene cuenta?}
    B -->|No| C[Registro con email y contraseña]
    B -->|Sí| D[Inicio de sesión]
    C --> D
    D --> E{¿Qué rol tienes?}

    E -->|Cliente| F[Dashboard Cliente]
    E -->|Profesional| G[Dashboard Profesional]
    E -->|Admin| H[Panel Administración]

    F --> F1[Ver mis mascotas]
    F --> F2[Reservar nueva cita]
    F --> F3[Ver mis citas]

    F2 --> I[Seleccionar servicio]
    I --> J[Ver calendario disponible]
    J --> K[Elegir horario libre]
    K --> L[Confirmar cita]
    L --> M[Cita creada — Estado: En espera]
    M --> N[Notificación al profesional]

    G --> G1[Ver agenda del día]
    G --> G2[Confirmar cita]
    G --> G3[Actualizar estado]
    G3 --> G3A[En progreso → Atendida]

    G2 --> O[Notificación al cliente]
    G3 --> O

    H --> H1[Gestionar usuarios]
    H --> H2[Gestionar servicios]
    H --> H3[Gestionar horarios]
    H --> H4[Ver reportes]
```

---

