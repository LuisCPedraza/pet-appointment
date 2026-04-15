## 9. Puesta en Marcha y Workflow Recomendado

### 9.1 Prerrequisitos

1. Flutter SDK instalado y en PATH (`flutter doctor` sin errores).
2. Android Studio o VS Code con extensión Flutter.
3. Cuenta en [supabase.com](https://supabase.com) con proyecto creado.
4. Cuenta en GitHub con repositorio creado.
5. (Opcional) Cuenta en Twilio para notificaciones WhatsApp.

### 9.2 Configuración Inicial del Proyecto

```bash
# 1. Clonar el repositorio
git clone https://github.com/tu-usuario/pet-appointment.git
cd pet-appointment

# 2. Instalar dependencias
flutter pub get

# 3. Configurar variables de entorno
cp .env.example .env
# Editar .env con las credenciales de Supabase

# 4. Ejecutar migraciones en Supabase
# Ir a Supabase Dashboard > SQL Editor y ejecutar:
# supabase/migrations/001_initial_schema.sql
# supabase/migrations/002_rls_policies.sql
# supabase/migrations/003_seed_data.sql

# 5. Ejecutar la aplicación
flutter run

# 6. Generar APK de debug
flutter build apk --debug

# 7. Generar APK de release (requiere keystore configurado)
flutter build apk --release
```

### 9.3 CI/CD con GitHub Actions

#### Workflow de integración continua (tests y lint)

```yaml
# .github/workflows/ci.yml
name: CI — Tests y Lint

on:
  push:
    branches: [main, develop]
  pull_request:
    branches: [main, develop]

jobs:
  test-and-lint:
    name: Tests y Análisis Estático
    runs-on: ubuntu-latest

    steps:
      - name: Checkout código
        uses: actions/checkout@v4

      - name: Configurar Flutter
        uses: subosito/flutter-action@v2
        with:
          flutter-version: '3.27.0'
          channel: 'stable'

      - name: Instalar dependencias
        run: flutter pub get

      - name: Verificar formato de código
        run: dart format --output=none --set-exit-if-changed .

      - name: Análisis estático (flutter analyze)
        run: flutter analyze

      - name: Ejecutar pruebas unitarias y de widget
        run: flutter test --coverage

      - name: Subir reporte de cobertura
        uses: codecov/codecov-action@v4
        with:
          file: coverage/lcov.info
```

#### Workflow de release (build APK)

```yaml
# .github/workflows/release-apk.yml
name: Release — Build y Publicar APK

on:
  push:
    tags:
      - 'v*.*.*'  # Se activa con tags tipo v1.0.0

jobs:
  build-apk:
    name: Build APK Android
    runs-on: ubuntu-latest

    steps:
      - name: Checkout código
        uses: actions/checkout@v4

      - name: Configurar Java
        uses: actions/setup-java@v4
        with:
          distribution: 'temurin'
          java-version: '17'

      - name: Configurar Flutter
        uses: subosito/flutter-action@v2
        with:
          flutter-version: '3.27.0'
          channel: 'stable'

      - name: Instalar dependencias
        run: flutter pub get

      - name: Configurar keystore desde secrets
        run: |
          echo "${{ secrets.KEYSTORE_BASE64 }}" | base64 --decode > android/app/keystore.jks
          echo "storeFile=keystore.jks" >> android/key.properties
          echo "storePassword=${{ secrets.KEYSTORE_PASSWORD }}" >> android/key.properties
          echo "keyAlias=${{ secrets.KEY_ALIAS }}" >> android/key.properties
          echo "keyPassword=${{ secrets.KEY_PASSWORD }}" >> android/key.properties

      - name: Build APK Release
        run: flutter build apk --release
        env:
          SUPABASE_URL: ${{ secrets.SUPABASE_URL }}
          SUPABASE_ANON_KEY: ${{ secrets.SUPABASE_ANON_KEY }}

      - name: Publicar en GitHub Releases
        uses: softprops/action-gh-release@v2
        with:
          files: build/app/outputs/flutter-apk/app-release.apk
          name: PetAppointment ${{ github.ref_name }}
          body: |
            ## PetAppointment ${{ github.ref_name }}
            ### Cambios en esta versión
            - Ver CHANGELOG.md para detalles
            
            ### Instalación
            Descarga el archivo `app-release.apk` e instálalo en tu dispositivo Android.
        env:
          GITHUB_TOKEN: ${{ secrets.GITHUB_TOKEN }}
```

### 9.4 Estrategia de Branching (Entrega 1)

```
main                  ← Rama principal del repositorio
  ↑
develop               ← Rama de desarrollo/integración
  ↑
staging               ← Rama de pruebas previas
  ↑
feature/US-10-calendario   ← Feature branches por historia de usuario
feature/US-11-reservar-cita
fix/BUG-05-slot-collision
```

**Reglas de protección de ramas:**

- `main`: Requiere PR aprobado por al menos 1 revisor + CI verde.
- `develop`: Requiere CI verde antes de merge.
- `staging`: Se usa para validaciones funcionales antes de promover a `main`.
- No se permite push directo a `main`.

### 9.5 Convenciones de Commits (Conventional Commits)

```
<tipo>(<alcance>): <descripción breve en español>

feat(auth): implementar registro con Supabase Auth
fix(calendar): corregir colisión de slots al reservar simultáneamente
docs(readme): actualizar instrucciones de instalación
test(appointments): agregar pruebas unitarias para cancelar cita
refactor(core): extraer cliente Supabase a singleton
chore(ci): configurar workflow de GitHub Actions para APK
```

**Tipos permitidos:** `feat`, `fix`, `docs`, `style`, `refactor`, `test`, `chore`, `perf`

### 9.6 Integración con Jira (Scrum)

Tablero oficial del equipo: [PA - PetAppointment](https://correounivalle-team-f1bug4uj.atlassian.net/jira/software/projects/PA/summary?atlOrigin=eyJpIjoiM2Y2ZDkwMzk2NWNiNDNmMjk5OTQwMmZkMzIzYjZjZmMiLCJwIjoiaiJ9)

| Elemento en Documentación | Equivalente en Jira |
|---|---|
| Épica (EP-01 a EP-07) | **Epic** en Jira con mismo nombre y descripción |
| Historia de Usuario (US-XX) | **Story** dentro de la épica correspondiente |
| Tarea técnica (TASK-XX) | **Task** o **Sub-task** vinculada a la Story |
| Bug encontrado durante desarrollo | **Bug** en el backlog |
| Pull Request de GitHub | Vinculado al issue de Jira mediante smart commit: `git commit -m "feat(auth): login screen [PET-15]"` |

**Columnas del tablero Kanban:**

| Por hacer | En progreso | En revisión (PR) | Listo para QA | Completado |
|---|---|---|---|---|
| Backlog priorizado | Máx. 2 por persona | PR abierto en GitHub | APK de test disponible | Merge a develop ✅ |

---

