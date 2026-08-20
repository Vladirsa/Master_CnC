/// Tipos de misión soportados en Ciclo 1 (de los 8 del Blueprint,
/// aquí solo 'seleccion' y 'detectar_error' — el resto llega en Ciclo 2).
enum MissionTipo { seleccion, detectarError }

MissionTipo missionTipoFromString(String s) {
  switch (s) {
    case 'seleccion':
      return MissionTipo.seleccion;
    case 'detectar_error':
      return MissionTipo.detectarError;
    default:
      throw ArgumentError('Tipo de misión no soportado en este ciclo: $s');
  }
}

class MissionOpcion {
  final String id;
  final String texto;
  const MissionOpcion({required this.id, required this.texto});

  factory MissionOpcion.fromMap(Map<String, dynamic> map) =>
      MissionOpcion(id: map['id'] as String, texto: map['texto'] as String);
}

/// El contenido (pregunta, opciones, respuesta correcta, código de error
/// asociado si aplica) viene del jsonb `contenido` — NUNCA hardcodeado en
/// Dart, tal como exige el criterio de "terminado" del Ciclo 1 Kickoff.
class MissionTemplate {
  final String id;
  final MissionTipo tipo;
  final String skillId;
  final String dificultad;
  final String pregunta;
  final List<MissionOpcion> opciones;
  final String respuestaCorrectaId;
  final String? errorCodigoSiFalla;
  final int xpRecompensa;

  const MissionTemplate({
    required this.id,
    required this.tipo,
    required this.skillId,
    required this.dificultad,
    required this.pregunta,
    required this.opciones,
    required this.respuestaCorrectaId,
    this.errorCodigoSiFalla,
    this.xpRecompensa = 50,
  });

  factory MissionTemplate.fromMap(Map<String, dynamic> map) {
    final contenido = map['contenido'] as Map<String, dynamic>;
    return MissionTemplate(
      id: map['id'] as String,
      tipo: missionTipoFromString(map['tipo'] as String),
      skillId: map['skill_id'] as String,
      dificultad: map['dificultad'] as String,
      pregunta: contenido['pregunta'] as String,
      opciones: (contenido['opciones'] as List)
          .map((o) => MissionOpcion.fromMap(o as Map<String, dynamic>))
          .toList(),
      respuestaCorrectaId: contenido['respuesta_correcta_id'] as String,
      errorCodigoSiFalla: contenido['error_codigo_si_falla'] as String?,
      xpRecompensa: (contenido['xp_recompensa'] as num?)?.toInt() ?? 50,
    );
  }
}
