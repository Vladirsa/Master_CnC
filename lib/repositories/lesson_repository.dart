import 'package:supabase_flutter/supabase_flutter.dart';
import '../core/services/supabase_service.dart';
import '../models/lesson.dart';

class LessonRepository {
  final SupabaseClient _db = SupabaseService.client;

  Future<Lesson?> obtenerLeccion(String skillId) async {
    final rows = await _db.from('lessons').select().eq('skill_id', skillId).limit(1);
    final lista = rows as List;
    if (lista.isEmpty) return null;
    return Lesson.fromMap(lista.first as Map<String, dynamic>);
  }
}
