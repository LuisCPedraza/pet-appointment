## Reportes de Pruebas y Cobertura

Archivos generados por la pipeline de CI y por ejecuciones locales:

- `coverage/lcov.info` — archivo de cobertura generado por `flutter test --coverage`.
- Artifact CI: `coverage-lcov` (GitHub Actions) — contiene `lcov.info`.

Comandos para generar el reporte HTML localmente:

```bash
flutter test --coverage
genhtml coverage/lcov.info -o coverage/html
# Luego abrir coverage/html/index.html en tu navegador
```

Si no tienes `genhtml` instalado, en Ubuntu se instala con `sudo apt-get install lcov`.

Dónde buscar los artifacts en GitHub Actions:

1. Ve al workflow `Tests and Coverage` en Actions.
2. Abre la ejecución y descarga el artifact llamado `coverage-lcov`.
