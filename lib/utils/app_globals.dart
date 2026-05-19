import 'package:flutter/material.dart';

/// Clave global para acceder al `ScaffoldMessengerState` raíz de la app.
/// Usar `appScaffoldMessengerKey.currentState?.showSnackBar(...)` para evitar
/// lookups inseguros desde `context` cuando un widget puede haber sido
/// desactivado.
final GlobalKey<ScaffoldMessengerState> appScaffoldMessengerKey =
    GlobalKey<ScaffoldMessengerState>();
