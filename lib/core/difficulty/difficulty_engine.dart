/// Niveles de dificultad — coinciden con el CHECK constraint de
/// `players.dificultad_actual` en Supabase.
enum Dificultad { principiante, intermedio, avanzado, profesional }

Dificultad dificultadFromString(String s) {
  switch (s) {
    case 'principiante':
      return Dificultad.principiante;
    case 'intermedio':
      return Dificultad.intermedio;
    case 'avanzado':
      return Dificultad.avanzado;
    case 'profesional':
      return Dificultad.profesional;
    default:
      return Dificultad.principiante;
  }
}

String dificultadToString(Dificultad d) => d.name;

Dificultad _subir(Dificultad d) {
  switch (d) {
    case Dificultad.principiante:
      return Dificultad.intermedio;
    case Dificultad.intermedio:
      return Dificultad.avanzado;
    case Dificultad.avanzado:
      return Dificultad.profesional;
    case Dificultad.profesional:
      return Dificultad.profesional;
  }
}

Dificultad _bajar(Dificultad d) {
  switch (d) {
    case Dificultad.principiante:
      return Dificultad.principiante;
    case Dificultad.intermedio:
      return Dificultad.principiante;
    case Dificultad.avanzado:
      return Dificultad.intermedio;
    case Dificultad.profesional:
      return Dificultad.avanzado;
  }
}

/// Resumen de desempeño reciente de un jugador, calculado por quien llama
/// al motor (repositorio) a partir de `mission_attempts` — el motor en sí
/// es puro y no toca la base de datos, para que sea fácil de probar.
class DesempenoReciente {
  final int totalIntentos;
  final int correctos;
  final int ayudasUsadas; // sistema de ayudas llega en Ciclo 4+; por ahora siempre 0

  const DesempenoReciente({
    required this.totalIntentos,
    required this.correctos,
    this.ayudasUsadas = 0,
  });

  double get precision => totalIntentos == 0 ? 0.0 : correctos / totalIntentos;
  double get tasaError => 1.0 - precision;
}

/// Motor de dificultad — Blueprint sección 9 y sección 34, reglas EXACTAS:
///
/// SI precisión > 90% Y errores < 10% Y ayudas = 0   → subir dificultad
/// SI precisión < 60%                                 → bajar dificultad
/// SI mismo error ≥ 3 veces                           → marcar concepto débil
/// SI habilidad > 85%                                  → marcar como dominada
///
/// Deliberadamente basado en reglas, no en machine learning (Blueprint
/// sección 34: "Crear inicialmente un sistema basado en reglas").
class DifficultyEngine {
  const DifficultyEngine();

  /// Evalúa si corresponde subir, bajar o mantener la dificultad actual.
  Dificultad siguienteDificultad({
    required Dificultad actual,
    required DesempenoReciente desempeno,
  }) {
    final subirCondicion =
        desempeno.precision > 0.90 && desempeno.tasaError < 0.10 && desempeno.ayudasUsadas == 0;
    if (subirCondicion) return _subir(actual);

    if (desempeno.precision < 0.60 && desempeno.totalIntentos > 0) {
      return _bajar(actual);
    }

    return actual;
  }

  /// "SI mismo error ≥ 3 veces ENTONCES crear misión de recuperación" —
  /// en este ciclo el motor solo detecta la condición; la generación real
  /// de la Recovery Mission con contenido propio llega en el Ciclo 3.
  bool esConceptoDebil({required int vecesRepetidoMismoError}) {
    return vecesRepetidoMismoError >= 3;
  }

  /// "SI habilidad > 85% ENTONCES marcar como dominada"
  bool esHabilidadDominada({required double dominio}) {
    return dominio > 0.85;
  }
}
