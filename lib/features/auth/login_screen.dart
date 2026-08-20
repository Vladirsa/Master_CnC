import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../core/services/supabase_service.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../core/theme/app_typography.dart';

/// Login con correo + contraseña — versión temporal mientras se resuelve
/// el envío de correo (SMTP). No depende de que salga ningún correo:
/// requiere que en Supabase, Authentication > Providers > Email, el
/// toggle "Confirm email" esté APAGADO (si no, signUp exige confirmar
/// por correo antes de dar sesión, y volvemos al mismo problema).
///
/// Cuando el SMTP quede resuelto, esta pantalla puede coexistir con el
/// login por código OTP (ambos son formas válidas de entrar a la misma
/// cuenta de auth.users) — no hace falta elegir uno para siempre.
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _correoCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  bool _enviando = false;
  String? _error;

  Future<void> _entrarOCrearCuenta() async {
    final correo = _correoCtrl.text.trim();
    final password = _passwordCtrl.text;
    if (correo.isEmpty || !correo.contains('@')) {
      setState(() => _error = 'Escribe un correo válido.');
      return;
    }
    if (password.length < 6) {
      setState(() => _error = 'La contraseña debe tener al menos 6 caracteres.');
      return;
    }
    setState(() {
      _enviando = true;
      _error = null;
    });

    // 1) Intenta entrar como si la cuenta ya existiera.
    try {
      await SupabaseService.client.auth.signInWithPassword(email: correo, password: password);
      return; // AuthGate avanza solo al detectar la sesión.
    } on AuthException {
      // Sigue abajo: probablemente la cuenta no existe todavía.
    } finally {
      if (mounted) setState(() => _enviando = false);
    }

    // 2) Si no existe, la crea con esa misma contraseña.
    setState(() => _enviando = true);
    try {
      await SupabaseService.client.auth.signUp(email: correo, password: password);
    } on AuthException catch (e) {
      setState(() => _error = 'Supabase dice: ${e.message}');
    } catch (e) {
      setState(() => _error = 'Error inesperado: $e');
    } finally {
      if (mounted) setState(() => _enviando = false);
    }
  }

  @override
  void dispose() {
    _correoCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: DesktopFrame(
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.xl),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Icon(Icons.precision_manufacturing_outlined, size: 56, color: AppColors.primary),
                const SizedBox(height: AppSpacing.lg),
                Text('CNC MASTER LAB', style: AppTypography.h1, textAlign: TextAlign.center),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  'Ecosistema HETNACNC — aprende CNC sin miedo a arruinar el material.',
                  style: AppTypography.bodySecondary,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: AppSpacing.xxl),
                TextField(
                  controller: _correoCtrl,
                  keyboardType: TextInputType.emailAddress,
                  style: AppTypography.body,
                  decoration: const InputDecoration(
                    labelText: 'Correo electrónico',
                    hintText: 'tucorreo@ejemplo.com',
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                TextField(
                  controller: _passwordCtrl,
                  obscureText: true,
                  style: AppTypography.body,
                  decoration: const InputDecoration(
                    labelText: 'Contraseña',
                    hintText: 'Mínimo 6 caracteres',
                  ),
                ),
                if (_error != null) ...[
                  const SizedBox(height: AppSpacing.sm),
                  Text(_error!, style: AppTypography.caption.copyWith(color: AppColors.error)),
                ],
                const SizedBox(height: AppSpacing.lg),
                ElevatedButton(
                  onPressed: _enviando ? null : _entrarOCrearCuenta,
                  child: _enviando
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                        )
                      : const Text('Entrar / Crear cuenta'),
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  'Si el correo no existe, se crea la cuenta automáticamente con esta contraseña.',
                  style: AppTypography.caption,
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
