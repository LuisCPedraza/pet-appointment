/// Definición de estados válidos de una cita
enum AppointmentStatus {
  enEspera('En espera'),
  confirmada('Confirmada'),
  enProgreso('En progreso'),
  atendida('Atendida'),
  cancelada('Cancelada');

  const AppointmentStatus(this.label);

  /// Etiqueta en español
  final String label;

  /// Devuelve el valor del estado
  String get value => label;

  /// Determina si se puede realizar una transición desde este estado a otro
  bool canTransitionTo(AppointmentStatus nextStatus) {
    return validTransitions[this]?.contains(nextStatus) ?? false;
  }

  /// Retorna los estados a los que se puede transicionar desde el actual
  List<AppointmentStatus> getValidNextStates() {
    return validTransitions[this] ?? <AppointmentStatus>[];
  }

  /// Convierte un String de Supabase a enum
  static AppointmentStatus? fromString(String? value) {
    if (value == null) return null;
    try {
      return AppointmentStatus.values.firstWhere(
        (status) => status.label == value,
      );
    } catch (e) {
      return null;
    }
  }

  /// Describe la transición en español
  String describeTransition(AppointmentStatus nextStatus) {
    return 'Cambiar de "$label" a "${nextStatus.label}"';
  }
}

/// Matriz de transiciones válidas
const Map<AppointmentStatus, List<AppointmentStatus>> validTransitions = {
  AppointmentStatus.enEspera: <AppointmentStatus>[AppointmentStatus.confirmada],
  AppointmentStatus.confirmada: <AppointmentStatus>[
    AppointmentStatus.enProgreso,
  ],
  AppointmentStatus.enProgreso: <AppointmentStatus>[
    AppointmentStatus.atendida,
    AppointmentStatus.cancelada,
  ],
  AppointmentStatus.atendida: <AppointmentStatus>[],
  AppointmentStatus.cancelada: <AppointmentStatus>[],
};
