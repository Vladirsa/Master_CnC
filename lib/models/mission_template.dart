/// Tipos de misión soportados hasta este ciclo (de los 8 del Blueprint).
/// Ciclo 1: seleccion, detectar_error. Ciclo 2 agrega: ordenar, configurar.
/// Los 4 restantes (simulacion, diagnostico, reparacion, proyecto) llegan
/// cuando exista el simulador 3D (Ciclo 3+).
enum MissionTipo { seleccion, detectarError, ordenar, configurar }

MissionTipo missionTipoFromString(String s) {
  switch (s) {
    case 'seleccion':
      return MissionTipo.seleccion;
    case 'detectar_error':
      return MissionTipo.detectarError;
    case 'ordenar':
      return MissionTipo.ordenar;
    case 'configurar':
      return MissionTipo.configurar;
    default:
      throw ArgumentError('Tipo de misión no soportado en este ciclo: $s');
  }
}

String missionTipoLabel(MissionTipo t) {
  switch (t) {
    case MissionTipo.seleccion:
      return 'SELECCIÓN';
    case MissionTipo.detectarError:
      return 'DETECTAR ERROR';
    case MissionTipo.ordenar:
      return 'ORDENAR';
    case MissionTipo.configurar:
      return 'CONFIGURAR';
  }
}

class MissionOpcion {
  final String id;
  final String texto;
  const MissionOpcion({required this.id, required this.texto});

  factory MissionOpcion.fromMap(Map<String, dynamic> map) =>
      MissionOpcion(id: map['id'] as String, texto: map['texto'] as String);
}

/// Un paso a ordenar (tipo 'ordenar') — se muestra desordenado y el
/// jugador debe arrastrarlo a su posición correcta.
class MissionPaso {
  final String id;
  final String texto;
  const MissionPaso({required this.id, required this.texto});

  factory MissionPaso.fromMap(Map<String, dynamic> map) =>
      MissionPaso(id: map['id'] as String, texto: map['texto'] as String);
}

/// Un parámetro a configurar (tipo 'configurar') — ej. herramienta, RPM,
/// profundidad. `opciones` define los valores posibles (siempre selección
/// cerrada en este ciclo, no un slider numérico libre — eso es Ciclo 3+).
class MissionParametro {
  final String id;
  final String nombre;
  final List<MissionOpcion> opciones;
  final String valorCorrectoId;

  const MissionParametro({
    required this.id,
    required this.nombre,
    required this.opciones,
    required this.valorCorrectoId,
  });

  factory MissionParametro.fromMap(Map<String, dynamic> map) => MissionParametro(
        id: map['id'] as String,
        nombre: map['nombre'] as String,
        opciones: (map['opciones'] as List)
            .map((o) => MissionOpcion.fromMap(o as Map<String, dynamic>))
            .toList(),
        valorCorrectoId: map['valor_correcto_id'] as String,
      );
}

/// El contenido (pregunta, opciones/pasos/parámetros, respuesta correcta,
/// código de error asociado si aplica) viene del jsonb `contenido` —
/// NUNCA hardcodeado en Dart, tal como exige el criterio de "terminado"
/// del Ciclo 1 Kickoff. Los campos que no aplican a un `tipo` quedan vacíos.
class MissionTemplate {
  final String id;
  final MissionTipo tipo;
  final String skillId;
  final String dificultad;
  final String pregunta;
  final int xpRecompensa;
  final String? errorCodigoSiFalla;

  // Selección / Detectar error
  final List<MissionOpcion> opciones;
  final String? respuestaCorrectaId;

  // Ordenar
  final List<MissionPaso> pasos;
  final List<String> ordenCorrecto;

  // Configurar
  final List<MissionParametro> parametros;

  const MissionTemplate({
    required this.id,
    required this.tipo,
    required this.skillId,
    required this.dificultad,
    required this.pregunta,
    this.xpRecompensa = 50,
    this.errorCodigoSiFalla,
    this.opciones = const [],
    this.respuestaCorrectaId,
    this.pasos = const [],
    this.ordenCorrecto = const [],
    this.parametros = const [],
  });

  factory MissionTemplate.fromMap(Map<String, dynamic> map) {
    final contenido = map['contenido'] as Map<String, dynamic>;
    final tipo = missionTipoFromString(map['tipo'] as String);

    return MissionTemplate(
      id: map['id'] as String,
      tipo: tipo,
      skillId: map['skill_id'] as String,
      dificultad: map['dificultad'] as String,
      pregunta: contenido['pregunta'] as String,
      xpRecompensa: (contenido['xp_recompensa'] as num?)?.toInt() ?? 50,
      errorCodigoSiFalla: contenido['error_codigo_si_falla'] as String?,
      opciones: contenido['opciones'] == null
          ? []
          : (contenido['opciones'] as List)
              .map((o) => MissionOpcion.fromMap(o as Map<String, dynamic>))
              .toList(),
      respuestaCorrectaId: contenido['respuesta_correcta_id'] as String?,
      pasos: contenido['pasos'] == null
          ? []
          : (contenido['pasos'] as List)
              .map((p) => MissionPaso.fromMap(p as Map<String, dynamic>))
              .toList(),
      ordenCorrecto: contenido['orden_correcto'] == null
          ? []
          : List<String>.from(contenido['orden_correcto'] as List),
      parametros: contenido['parametros'] == null
          ? []
          : (contenido['parametros'] as List)
              .map((p) => MissionParametro.fromMap(p as Map<String, dynamic>))
              .toList(),
    );
  }
}
