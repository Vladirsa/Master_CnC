import 'package:supabase_flutter/supabase_flutter.dart';
import '../core/services/supabase_service.dart';
import '../core/difficulty/difficulty_engine.dart';
import '../models/player_profile.dart';

class PlayerRepository {
  final SupabaseClient _db = SupabaseService.client;
  final _difficultyEngine = const DifficultyEngine();

  /// Se llama desde AuthGate en cada login. Crea la fila en
  /// `usuarios_plataforma` (identidad compartida del ecosistema HETNACNC)
  /// si es la primera vez que este usuario entra a CUALQUIER app del
  /// ecosistema, y la fila en `players` si es su primera vez en Master Lab.
  /// Ver Blueprint sección 4bis.
  Future<PlayerProfile> asegurarPerfil() async {
    final user = _db.auth.currentUser;
    if (user == null) {
      throw StateError('asegurarPerfil() llamado sin sesión activa');
    }

    // 1. Identidad compartida del ecosistema (idempotente por upsert).
    await _db.from('usuarios_plataforma').upsert({
      'id': user.id,
      'correo': user.email,
    }, onConflict: 'id');

    // 2. Perfil de aprendizaje de Master Lab (idempotente).
    final existentes = await _db
        .from('players')
        .select('user_id')
        .eq('user_id', user.id)
        .limit(1);
    if ((existentes as List).isEmpty) {
      await _db.from('players').insert({'user_id': user.id});
    }

    return obtenerPerfil();
  }

  Future<PlayerProfile> obtenerPerfil() async {
    final user = _db.auth.currentUser;
    if (user == null) throw StateError('Sin sesión activa');

    final fila = await _db
        .from('players')
        .select('*, usuarios_plataforma(nombre)')
        .eq('user_id', user.id)
        .limit(1)
        .single();

    return PlayerProfile.fromMap(fila);
  }

  /// Registra un evento de XP (xp_events) y actualiza el acumulado + nivel
  /// en `players`. Regla de nivel simple del MVP (el Difficulty Engine
  /// completo, Ciclo 2, ajusta `dificultad_actual`, no el nivel).
  Future<PlayerProfile> otorgarXp({required int cantidad, required String motivo}) async {
    final user = _db.auth.currentUser;
    if (user == null) throw StateError('Sin sesión activa');

    await _db.from('xp_events').insert({
      'user_id': user.id,
      'cantidad': cantidad,
      'motivo': motivo,
    });

    final actual = await obtenerPerfil();
    final nuevoXp = actual.xp + cantidad;
    var nuevoNivel = actual.nivel;
    final totalRequeridoNivelActual = nuevoNivel * 100;
    if (nuevoXp >= totalRequeridoNivelActual) {
      nuevoNivel += 1;
    }

    await _db.from('players').update({
      'xp': nuevoXp,
      'nivel': nuevoNivel,
    }).eq('user_id', user.id);

    return obtenerPerfil();
  }

  /// Difficulty Engine (Ciclo 2, Blueprint sección 9): tras cada intento,
  /// mide el desempeño reciente (últimos 20 intentos del jugador en
  /// cualquier misión) y sube/baja `dificultad_actual` según las reglas.
  /// Devuelve la nueva dificultad para que la UI pueda avisar al jugador
  /// si cambió (ej. "subiste a intermedio").
  Future<Dificultad> recalcularDificultad() async {
    final user = _db.auth.currentUser;
    if (user == null) throw StateError('Sin sesión activa');

    final intentosRaw = await _db
        .from('mission_attempts')
        .select('correcto')
        .eq('user_id', user.id)
        .order('created_at', ascending: false)
        .limit(20);

    final intentos = intentosRaw as List;
    final total = intentos.length;
    final correctos = intentos
        .where((i) => (i as Map<String, dynamic>)['correcto'] == true)
        .length;

    final perfil = await obtenerPerfil();
    final actual = dificultadFromString(perfil.dificultadActual);

    final nueva = _difficultyEngine.siguienteDificultad(
      actual: actual,
      desempeno: DesempenoReciente(totalIntentos: total, correctos: correctos),
    );

    if (nueva != actual) {
      await _db
          .from('players')
          .update({'dificultad_actual': dificultadToString(nueva)})
          .eq('user_id', user.id);
    }

    return nueva;
  }
}
