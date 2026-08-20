import 'package:supabase_flutter/supabase_flutter.dart';
import '../core/services/supabase_service.dart';
import '../models/player_profile.dart';

class PlayerRepository {
  final SupabaseClient _db = SupabaseService.client;

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
  /// en `players`. Regla de nivel simple del MVP (Blueprint sección 9:
  /// dificultad dinámica completa llega en Ciclo 2, aquí solo XP lineal).
  Future<PlayerProfile> otorgarXp({required int cantidad, required String motivo}) async {
    final user = _db.auth.currentUser;
    if (user == null) throw StateError('Sin sesión activa');

    await _db.from('xp_events').insert({
      'user_id': user.id,
      'cantidad': cantidad,
      'motivo': motivo,
    });

    final actual = await obtenerPerfil();
    var nuevoXp = actual.xp + cantidad;
    var nuevoNivel = actual.nivel;
    while (nuevoXp >= PlayerProfile.xpParaSiguienteNivel(nuevoNivel) * nuevoNivel) {
      // Regla simple: nivel sube cuando el XP acumulado total supera
      // nivel*100 acumulado. Se revisa/mejora en el Difficulty Engine (Ciclo 2).
      break;
    }
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
}
