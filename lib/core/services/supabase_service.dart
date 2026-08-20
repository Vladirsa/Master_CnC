import 'package:supabase_flutter/supabase_flutter.dart';

/// Inicializa el cliente de Supabase del ecosistema HETNACNC.
///
/// IMPORTANTE: estas credenciales son públicas (anon key), protegidas por
/// RLS del lado del servidor — nunca poner aquí una service_role key.
/// En build real, inyectar por --dart-define en el workflow de CI, no
/// hardcodear un proyecto de producción en el repo.
class SupabaseService {
  SupabaseService._();

  static const _supabaseUrl = String.fromEnvironment(
    'SUPABASE_URL',
    defaultValue: 'https://TU-PROYECTO.supabase.co',
  );

  static const _supabaseAnonKey = String.fromEnvironment(
    'SUPABASE_ANON_KEY',
    defaultValue: 'TU-ANON-KEY',
  );

  static Future<void> init() async {
    await Supabase.initialize(
      url: _supabaseUrl,
      anonKey: _supabaseAnonKey,
    );
  }

  static SupabaseClient get client => Supabase.instance.client;
}
