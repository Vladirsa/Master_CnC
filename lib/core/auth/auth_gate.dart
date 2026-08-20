import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../services/supabase_service.dart';
import '../../repositories/player_repository.dart';
import '../../features/auth/login_screen.dart';
import '../../features/home/home_shell.dart';
import '../theme/app_colors.dart';

/// Revisa la sesión real de Supabase en cada arranque — patrón ya probado
/// en design_system.md del Cotizador. CRÍTICO: ignora
/// AuthChangeEvent.passwordRecovery aquí (no aplica todavía en Ciclo 1,
/// pero se deja el guard para no repetir el bug cuando se agregue).
class AuthGate extends StatefulWidget {
  const AuthGate({super.key});

  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
  late final Stream<AuthState> _authStream;
  Session? _session;
  bool _perfilListo = false;

  @override
  void initState() {
    super.initState();
    _session = SupabaseService.client.auth.currentSession;
    _authStream = SupabaseService.client.auth.onAuthStateChange;
    _authStream.listen((data) {
      if (data.event == AuthChangeEvent.passwordRecovery) return;
      setState(() {
        _session = data.session;
        _perfilListo = false;
      });
    });
    if (_session != null) _asegurarPerfil();
  }

  Future<void> _asegurarPerfil() async {
    await PlayerRepository().asegurarPerfil();
    if (mounted) setState(() => _perfilListo = true);
  }

  @override
  Widget build(BuildContext context) {
    if (_session == null) return const LoginScreen();

    if (!_perfilListo) {
      _asegurarPerfil();
      return const Scaffold(
        backgroundColor: AppColors.background,
        body: Center(child: CircularProgressIndicator(color: AppColors.primary)),
      );
    }

    return const HomeShell();
  }
}
