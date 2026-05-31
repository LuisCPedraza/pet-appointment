## Accesibilidad — evidencias y pasos

Se añadieron utilidades para facilitar el etiquetado Semantics y comprobaciones manuales.

1. Widget helper: `lib/widgets/semantics_wrapper.dart` — use para envolver controles y proveer `label` legible por lectores de pantalla.

2. Comprobaciones recomendadas:

```bash
# Ejecutar tests de widget que verifiquen Semantics
flutter test test/widget/accessibility_test.dart
```

3. Recomendaciones rápidas:
- Añadir `SemanticsWrapper(label: 'Confirmar cita', child: ElevatedButton(...))` en botones críticos.
- Revisar contrastes y tamaños táctiles según la guía WCAG.

Evidencia:
- Archivo `lib/widgets/semantics_wrapper.dart` añadido.
- Instrucciones para incluir pruebas y capturas en `docs/entrega_final`.
