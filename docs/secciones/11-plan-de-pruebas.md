## 11. Plan de Pruebas

### 11.1 Pruebas Unitarias

| # | Módulo | Caso de prueba | Tipo |
|---|---|---|---|
| UT-01 | Autenticación | Registro con email inválido retorna error de validación | Unit |
| UT-02 | Autenticación | Login con credenciales correctas retorna usuario autenticado | Unit |
| UT-03 | Citas | Crear cita con slot disponible retorna cita con estado "En espera" | Unit |
| UT-04 | Citas | Crear cita con slot ocupado lanza excepción de disponibilidad | Unit |
| UT-05 | Citas | Cancelar cita actualiza estado a "Cancelada" y libera slot | Unit |
| UT-06 | Mascotas | CRUD completo de mascotas sin errores | Unit |
| UT-07 | Validadores | Validar teléfono con formato correcto e incorrecto | Unit |
| UT-08 | Validadores | Validar fecha de nacimiento no futura | Unit |

### 11.2 Pruebas de Widget

| # | Widget | Caso de prueba | Tipo |
|---|---|---|---|
| WT-01 | LoginScreen | Muestra error cuando el email está vacío al enviar el formulario | Widget |
| WT-02 | CalendarScreen | Muestra slots disponibles correctamente al cargar la pantalla | Widget |
| WT-03 | AppointmentCard | Muestra el estado correcto según el valor recibido | Widget |
| WT-04 | PetFormScreen | Valida campos obligatorios antes de guardar | Widget |
| WT-05 | AppointmentList | Muestra mensaje vacío cuando no hay citas registradas | Widget |

### 11.3 Pruebas de Integración

| # | Flujo | Caso de prueba | Tipo |
|---|---|---|---|
| IT-01 | Registro completo | Usuario puede registrarse, confirmar email e iniciar sesión | Integración |
| IT-02 | Reserva de cita | Cliente puede completar el flujo completo de reserva de cita | Integración |
| IT-03 | Cancelación | Cliente puede cancelar una cita y el slot queda disponible inmediatamente | Integración |
| IT-04 | Tiempo real | Cambio de estado por profesional se refleja en la app del cliente en menos de 2 segundos | Integración |

### 11.4 Comandos de Prueba

```bash
# Ejecutar todas las pruebas
flutter test

# Pruebas con cobertura
flutter test --coverage

# Ver reporte de cobertura
genhtml coverage/lcov.info -o coverage/html
open coverage/html/index.html

# Prueba de integración específica
flutter test integration_test/
```

---

