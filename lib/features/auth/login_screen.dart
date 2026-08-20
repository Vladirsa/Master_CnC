import 'package:flutter/material.dart';
import '../../core/services/supabase_service.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../core/theme/app_typography.dart';

/// Login con cuenta única del ecosistema HETNACNC (Blueprint sección 4bis).
/// MVP: magic link por correo — sin contraseña que mantener, y compatible
/// con que el mismo correo se use en el Cotizador u otras apps futuras.
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _correoCtrl = TextEditingController();
  bool _enviando = false;
  bool _enviado = false;
  String? _error;

  Future<void> _enviarMagicLink() async {
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
      setState(() => _enviado = true);
    } catch (e) {
      setState(() => _error = 'No se pudo enviar el enlace. Intenta de nuevo.');
    } finally {
      setState(() => _enviando = false);
    }
  }

  @override
  void dispose() {
    _correoCtrl.dispose();
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
                if (!_enviado) ...[
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
                    onPressed: _enviando ? null : _enviarMagicLink,
                    child: _enviando
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.background),
                          )
                        : const Text('Entrar con enlace mágico'),
                  ),
                ] else ...[
                  Icon(Icons.mark_email_read_outlined, size: 40, color: AppColors.success),
                  const SizedBox(height: AppSpacing.md),
                  Text(
                    'Te enviamos un enlace a ${_correoCtrl.text.trim()}. Ábrelo desde este dispositivo para entrar.',
                    style: AppTypography.body,
                    textAlign: TextAlign.center,
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
