import 'package:supabase_flutter/supabase_flutter.dart';
import '../core/services/supabase_service.dart';
import '../models/mission_template.dart';
import '../models/error_entry.dart';

class MissionRepository {
  final SupabaseClient _db = SupabaseService.client;

  /// Trae una misión de un `tipo` para una `skillId` dada. El contenido
  /// (pregunta/opciones) viene de `mission_templates.contenido` — nunca
  /// hardcodeado en Dart (criterio de "terminado" del Ciclo 1 Kickoff).
  Future<MissionTemplate?> obtenerMision({
    required String skillId,
    required String tipo,
  }) async {
    final rows = await _db
        .from('mission_templates')
        .select()
        .eq('skill_id', skillId)
        .eq('tipo', tipo)
        .limit(1);

    final lista = rows as List;
    if (lista.isEmpty) return null;
    return MissionTemplate.fromMap(lista.first as Map<String, dynamic>);
  }

  Future<ErrorEntry?> obtenerError(String codigo) async {
    final rows = await _db.from('errors_catalog').select().eq('codigo', codigo).limit(1);
    final lista = rows as List;
    if (lista.isEmpty) return null;
    return ErrorEntry.fromMap(lista.first as Map<String, dynamic>);
  }

  /// Registra el intento y, si falló, el error asociado en `error_history`
  /// (alimenta el futuro "concepto débil" del Difficulty Engine, Ciclo 2).
  Future<void> registrarIntento({
    required String templateId,
    required bool correcto,
    String? errorCodigo,
  }) async {
    final user = _db.auth.currentUser;
    if (user == null) throw StateError('Sin sesión activa');

    final attempt = await _db
        .from('mission_attempts')
        .insert({
          'user_id': user.id,
          'template_id': templateId,
          'correcto': correcto,
        })
        .select('id')
        .single();

    if (!correcto && errorCodigo != null) {
      await _db.from('error_history').insert({
        'user_id': user.id,
        'error_codigo': errorCodigo,
        'mission_attempt_id': attempt['id'],
      });
    }
  }
}
