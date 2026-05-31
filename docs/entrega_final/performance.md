## Perfilado y pruebas de rendimiento

Pasos rápidos para generar perfiles y métricas de arranque/CPU/RAM:

1. Ejecutar la app en modo profile (recomendado en dispositivo/emulador físico):

```bash
flutter run --profile -d <device-id>
```

2. Abrir DevTools y conectarse al VM Service para ver timeline, CPU y memoria.

3. Generar trazas de arranque:

```bash
flutter run --trace-startup --profile -d <device-id>
```

4. Uso de `flutter analyze` y `flutter build apk --release` para comparar tiempos de compilación y tamaño de APK.

5. Recomendación para pruebas de carga: crear un script que cree citas repetidas vía Supabase RPC o API y medir latencia del endpoint. No se ejecuta desde CI por seguridad.

Evidencias sugeridas:
- Trazas exportadas desde DevTools (Timeline) en formato JSON.
- Capturas de pantalla de uso de memoria y CPU durante flujos críticos.

## Ejecución real en profile

Prueba ejecutada el 30 de mayo de 2026 en `emulator-5554` con:

```bash
flutter run --profile --trace-startup -d emulator-5554
```

Resultado relevante:

- `Time to first frame: 1987ms`
- Archivo de startup generado: `build/start_up_info.json`
- Tiempos medidos:
	- `timeToFrameworkInitMicros`: 1731021
	- `timeToFirstFrameRasterizedMicros`: 3400189
	- `timeToFirstFrameMicros`: 1987474

Observación:

- La primera corrida falló por conflicto de firma del paquete instalado en el emulador; se desinstaló `com.example.pet_appointment` y se relanzó en limpio.
