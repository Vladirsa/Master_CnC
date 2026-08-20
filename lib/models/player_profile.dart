class PlayerProfile {
  final String userId;
  final String? nombre;
  final int nivel;
  final int xp;
  final String dificultadActual;

  const PlayerProfile({
    required this.userId,
    this.nombre,
    required this.nivel,
    required this.xp,
    required this.dificultadActual,
  });

  factory PlayerProfile.fromMap(Map<String, dynamic> map) {
    return PlayerProfile(
      userId: map['user_id'] as String,
      nombre: map['usuarios_plataforma']?['nombre'] as String?,
      nivel: map['nivel'] as int? ?? 1,
      xp: map['xp'] as int? ?? 0,
      dificultadActual: map['dificultad_actual'] as String? ?? 'principiante',
    );
  }

  /// Regla simple de nivel para el MVP: 100 XP por nivel.
  /// (El Difficulty Engine completo llega en el Ciclo 2 — Blueprint sección 9.)
  static int xpParaSiguienteNivel(int nivelActual) => nivelActual * 100;

  double get progresoNivel {
    final requerido = xpParaSiguienteNivel(nivel);
    final base = (nivel - 1) * 100;
    final actual = xp - base;
    return (actual / requerido).clamp(0.0, 1.0);
  }
}
