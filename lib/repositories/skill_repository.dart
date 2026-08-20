import 'package:supabase_flutter/supabase_flutter.dart';
import '../core/services/supabase_service.dart';
import '../models/skill.dart';

class SkillRepository {
  final SupabaseClient _db = SupabaseService.client;

  /// Trae solo la rama 'fundamentos' — único alcance del Ciclo 1
  /// (Kickoff, sección 2). El resto de ramas se agregan en ciclos futuros
  /// sin cambiar este método: solo cambia el filtro `rama`.
  Future<List<Skill>> skillsDeRama(String rama) async {
    final user = _db.auth.currentUser;

    final skillsRaw = await _db
        .from('skills')
        .select()
        .eq('rama', rama)
        .order('codigo');

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
  /// Difficulty Engine completo (Ciclo 2).
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
