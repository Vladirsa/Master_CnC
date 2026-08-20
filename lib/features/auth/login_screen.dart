import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../core/services/supabase_service.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../core/theme/app_typography.dart';

/// Login con cuenta única del ecosistema HETNACNC (Blueprint sección 4bis).
///
/// Usa CÓDIGO OTP de 6 dígitos en vez de enlace mágico clicable: el
/// enlace mágico necesita una Site URL / Redirect URL real configurada
/// en Supabase (dominio o deep link), y todavía no la tenemos definida
/// (Blueprint sección 19). El código OTP no depende de ninguna URL —
/// Supabase manda el mismo correo, pero el usuario escribe el código
/// directamente aquí. Cuando el dominio esté decidido, se puede volver
/// a habilitar el enlace mágico como opción adicional, no como reemplazo.
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

enum _Paso { correo, codigo }

class _LoginScreenState extends State<LoginScreen> {
  final _correoCtrl = TextEditingController();
  final _codigoCtrl = TextEditingController();
  _Paso _paso = _Paso.correo;
  bool _enviando = false;
  String? _error;

  Future<void> _enviarCodigo() async {
    final correo = _correoCtrl.text.trim();
    if (correo.isEmpty || !correo.contains('@')) {
      setState(() => _error = 'Escribe un correo válido.');
      return;
    }
    setState(() {
      _enviando = true;
      _error = null;
    });
    try {
      await SupabaseService.client.auth.signInWithOtp(email: correo);
      setState(() => _paso = _Paso.codigo);
    } catch (e) {
      setState(() => _error = 'No se pudo enviar el código. Intenta de nuevo.');
    } finally {
      setState(() => _enviando = false);
    }
  }

  Future<void> _verificarCodigo() async {
    final codigo = _codigoCtrl.text.trim();
    if (codigo.length < 6) {
      setState(() => _error = 'El código tiene 6 dígitos.');
      return;
    }
    setState(() {
      _enviando = true;
      _error = null;
    });
    try {
      await SupabaseService.client.auth.verifyOTP(
        type: OtpType.email,
        email: _correoCtrl.text.trim(),
        token: codigo,
      );
      // AuthGate escucha onAuthStateChange y avanza solo a HomeShell.
    } catch (e) {
      setState(() => _error = 'Código incorrecto o vencido. Pide uno nuevo.');
    } finally {
      if (mounted) setState(() => _enviando = false);
    }
  }

  @override
  void dispose() {
    _correoCtrl.dispose();
    _codigoCtrl.dispose();
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
                Icon(Icons.precision_manufacturing_outlined,
                    size: 56, color: AppColors.primary),
                const SizedBox(height: AppSpacing.lg),
                Text('CNC MASTER LAB', style: AppTypography.h1, textAlign: TextAlign.center),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  'Ecosistema HETNACNC — aprende CNC sin miedo a arruinar el material.',
                  style: AppTypography.bodySecondary,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: AppSpacing.xxl),
                if (_paso == _Paso.correo) ..._pasoCorreo() else ..._pasoCodigo(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  List<Widget> _pasoCorreo() {
    return [
      TextField(
        controller: _correoCtrl,
        keyboardType: TextInputType.emailAddress,
        style: AppTypography.body,
        decoration: const InputDecoration(
          labelText: 'Correo electrónico',
          hintText: 'tucorreo@ejemplo.com',
        ),
      ),
      if (_error != null) ...[
        const SizedBox(height: AppSpacing.sm),
        Text(_error!, style: AppTypography.caption.copyWith(color: AppColors.error)),
      ],
      const SizedBox(height: AppSpacing.lg),
      ElevatedButton(
        onPressed: _enviando ? null : _enviarCodigo,
        child: _enviando
            ? const SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
              )
            : const Text('Enviar código'),
      ),
    ];
  }

  List<Widget> _pasoCodigo() {
    return [
      Icon(Icons.mark_email_read_outlined, size: 40, color: AppColors.success),
      const SizedBox(height: AppSpacing.md),
      Text(
        'Te enviamos un código de 6 dígitos a ${_correoCtrl.text.trim()}.',
        style: AppTypography.body,
        textAlign: TextAlign.center,
      ),
      const SizedBox(height: AppSpacing.lg),
      TextField(
        controller: _codigoCtrl,
        keyboardType: TextInputType.number,
        textAlign: TextAlign.center,
        maxLength: 6,
        style: AppTypography.monoParam.copyWith(fontSize: 24, letterSpacing: 8),
        decoration: const InputDecoration(
          counterText: '',
          hintText: '000000',
        ),
      ),
      if (_error != null) ...[
        const SizedBox(height: AppSpacing.sm),
        Text(_error!, style: AppTypography.caption.copyWith(color: AppColors.error)),
      ],
      const SizedBox(height: AppSpacing.md),
      ElevatedButton(
        onPressed: _enviando ? null : _verificarCodigo,
        child: _enviando
            ? const SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
              )
            : const Text('Entrar'),
      ),
      const SizedBox(height: AppSpacing.sm),
      TextButton(
        onPressed: _enviando
            ? null
            : () => setState(() {
                  _paso = _Paso.correo;
                  _codigoCtrl.clear();
                  _error = null;
                }),
        child: const Text('Usar otro correo'),
      ),
    ];
  }
}
