enum SkillEstado { bloqueado, disponible, enProgreso, dominado }

class Skill {
  final String id;
  final String codigo;
  final String nombre;
  final String rama;
  final String? requisitoPrevioId;
  final double dominio; // 0.0 - 1.0, viene de skill_progress si existe

  const Skill({
    required this.id,
    required this.codigo,
    required this.nombre,
    required this.rama,
    this.requisitoPrevioId,
    this.dominio = 0.0,
  });

  factory Skill.fromMap(Map<String, dynamic> map, {double dominio = 0.0}) {
    return Skill(
      id: map['id'] as String,
      codigo: map['codigo'] as String,
      nombre: map['nombre'] as String,
      rama: map['rama'] as String,
      requisitoPrevioId: map['requisito_previo'] as String?,
      dominio: dominio,
    );
  }

  Skill copyWith({double? dominio}) => Skill(
        id: id,
        codigo: codigo,
        nombre: nombre,
        rama: rama,
        requisitoPrevioId: requisitoPrevioId,
        dominio: dominio ?? this.dominio,
      );

  /// El estado visual depende de si tiene requisito previo dominado.
  /// `previoDominado` lo calcula quien arma el árbol completo (necesita
  /// ver todos los nodos a la vez, no solo este).
  SkillEstado estado({required bool previoDominado}) {
    if (dominio >= 0.85) return SkillEstado.dominado;
    if (dominio > 0.0) return SkillEstado.enProgreso;
    if (requisitoPrevioId == null || previoDominado) return SkillEstado.disponible;
    return SkillEstado.bloqueado;
  }
}
