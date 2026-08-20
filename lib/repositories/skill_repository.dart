import 'package:supabase_flutter/supabase_flutter.dart';
import '../core/services/supabase_service.dart';
import '../models/skill.dart';

class SkillRepository {
  final SupabaseClient _db = SupabaseService.client;

  /// Orden de ramas del árbol tal como lo define el Blueprint:
  /// Fundamentos → Orígenes → Herramientas → CAM → Control.
  /// (En este ciclo "Orígenes" vive dentro de "fundamentos" — ver seed.)
  static const ordenRamas = ['fundamentos', 'herramientas', 'cam', 'control'];

  /// Trae TODAS las skills del árbol (sin filtrar por rama), con el
  /// progreso del usuario ya combinado. Antes (Ciclo 1) solo traía la
  /// rama 'fundamentos' a propósito; desde que hay más de una rama con
  /// contenido real, SkillMapScreen agrupa por rama en vez de que el
  /// repositorio decida cuál mostrar.
  Future<List<Skill>> todasLasSkills() async {
    final user = _db.auth.currentUser;

    final skillsRaw = await _db.from('skills').select().order('codigo');

    if (user == null) {
      return (skillsRaw as List)
          .map((m) => Skill.fromMap(m as Map<String, dynamic>))
          .toList();
    }

    final progresoRaw = await _db
        .from('skill_progress')
        .select('skill_id, dominio')
        .eq('user_id', user.id);

    final dominioPorSkill = {
      for (final p in (progresoRaw as List))
        (p as Map<String, dynamic>)['skill_id'] as String: (p['dominio'] as num).toDouble()
    };

    return (skillsRaw as List).map((m) {
      final map = m as Map<String, dynamic>;
      return Skill.fromMap(map, dominio: dominioPorSkill[map['id']] ?? 0.0);
    }).toList();
  }

  /// Actualiza el dominio de una skill tras completar una misión.
  /// Incremento simple en el MVP (+0.25 por acierto, tope 1.0) — el
  /// cálculo real de dominio por precisión/tiempo/intentos es del
  /// Difficulty Engine completo (Ciclo 2, ya activo para dificultad global;
  /// el dominio por-skill sigue esta regla simple por ahora).
  Future<void> registrarIntento({required String skillId, required bool correcto}) async {
    final user = _db.auth.currentUser;
    if (user == null) throw StateError('Sin sesión activa');

    final existente = await _db
        .from('skill_progress')
        .select('dominio, intentos')
        .eq('user_id', user.id)
        .eq('skill_id', skillId)
        .limit(1);

    final lista = existente as List;
    final dominioActual =
        lista.isEmpty ? 0.0 : ((lista.first as Map<String, dynamic>)['dominio'] as num).toDouble();
    final intentosActuales =
        lista.isEmpty ? 0 : (lista.first as Map<String, dynamic>)['intentos'] as int;

    final nuevoDominio =
        correcto ? (dominioActual + 0.25).clamp(0.0, 1.0) : dominioActual;

    if (lista.isEmpty) {
      await _db.from('skill_progress').insert({
        'user_id': user.id,
        'skill_id': skillId,
        'dominio': nuevoDominio,
        'intentos': 1,
      });
    } else {
      await _db
          .from('skill_progress')
          .update({'dominio': nuevoDominio, 'intentos': intentosActuales + 1})
          .eq('user_id', user.id)
          .eq('skill_id', skillId);
    }
  }
}
