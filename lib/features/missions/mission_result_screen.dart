import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../core/theme/app_typography.dart';
import '../../models/error_entry.dart';
import '../../repositories/mission_repository.dart';

/// Resultado de misión — Kickoff sección 5 + Design System sección 6.
/// Si acierta: celebración simple + XP ganado.
/// Si falla: Error → Causa → Consecuencia → Explicación → Corrección,
/// revelados uno a uno (no todo el texto de golpe) — reduce sensación
/// de "regaño", coherente con "no castigar excesivamente el error".
class MissionResultScreen extends StatefulWidget {
  final bool correcto;
  final int xpGanado;
  final String? errorCodigo;

  const MissionResultScreen({
    super.key,
    required this.correcto,
    required this.xpGanado,
    this.errorCodigo,
  });

  @override
  State<MissionResultScreen> createState() => _MissionResultScreenState();
}

class _MissionResultScreenState extends State<MissionResultScreen> {
  final _repo = MissionRepository();
  ErrorEntry? _error;
  int _pasoRevelado = 0; // 0=Error, 1=Causa, 2=Consecuencia, 3=Explicación, 4=Corrección
  bool _cargando = true;

  @override
  void initState() {
    super.initState();
    if (!widget.correcto && widget.errorCodigo != null) {
      _cargarError();
    } else {
      _cargando = false;
    }
  }

  Future<void> _cargarError() async {
    final error = await _repo.obtenerError(widget.errorCodigo!);
    setState(() {
      _error = error;
      _cargando = false;
    });
  }

  void _siguientePaso() {
    if (_pasoRevelado < 4) setState(() => _pasoRevelado++);
  }

  @override
  Widget build(BuildContext context) {
    if (widget.correcto) return _buildExito(context);
    return _buildError(context);
  }

  Widget _buildExito(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.xl),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.check_circle_rounded, color: AppColors.success, size: 72),
              const SizedBox(height: AppSpacing.lg),
              Text('¡Correcto!', style: AppTypography.h1),
              const SizedBox(height: AppSpacing.sm),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.bolt, color: AppColors.secondary),
                  const SizedBox(width: 4),
                  Text('+${widget.xpGanado} XP', style: AppTypography.h3),
                ],
              ),
              const SizedBox(height: AppSpacing.xxl),
              ElevatedButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Continuar'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildError(BuildContext context) {
    if (_cargando) {
      return const Scaffold(
        backgroundColor: AppColors.background,
        body: Center(child: CircularProgressIndicator(color: AppColors.primary)),
      );
    }

    final pasos = _error == null
        ? <_PasoError>[]
        : [
            _PasoError('ERROR', 'La respuesta seleccionada no es correcta.', AppColors.error),
            _PasoError('CAUSA', _error!.causa, AppColors.textSecondary),
            _PasoError('CONSECUENCIA', _error!.consecuencia, AppColors.textSecondary),
            _PasoError('EXPLICACIÓN', _error!.explicacion, AppColors.textSecondary),
            _PasoError('CORRECCIÓN', _error!.correccion, AppColors.success),
          ];

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Resultado')),
      body: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: pasos.isEmpty
                  ? Center(
                      child: Text('No fue correcto. Inténtalo de nuevo.', style: AppTypography.body),
                    )
                  : ListView.separated(
                      itemCount: _pasoRevelado + 1,
                      separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.md),
                      itemBuilder: (context, i) {
                        final paso = pasos[i];
                        return AnimatedOpacity(
                          duration: AppMotion.entrance,
                          opacity: 1,
                          child: Container(
                            padding: const EdgeInsets.all(AppSpacing.md),
                            decoration: BoxDecoration(
                              color: i == 0 ? AppColors.error.withOpacity(0.08) : AppColors.surfaceAlt,
                              borderRadius: BorderRadius.circular(AppRadius.md),
                              border: Border.all(
                                color: i == 0 ? AppColors.error : AppColors.border,
                              ),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(paso.titulo,
                                    style: AppTypography.caption.copyWith(
                                      color: paso.color,
                                      fontWeight: FontWeight.w700,
                                      letterSpacing: 1.0,
                                    )),
                                const SizedBox(height: 4),
                                Text(paso.texto, style: AppTypography.body),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
            ),
            const SizedBox(height: AppSpacing.md),
            if (pasos.isNotEmpty && _pasoRevelado < pasos.length - 1)
              ElevatedButton(onPressed: _siguientePaso, child: const Text('Siguiente'))
            else
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context, false),
                      child: const Text('Salir'),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => Navigator.pop(context, true),
                      child: const Text('Intentar de nuevo'),
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}

class _PasoError {
  final String titulo;
  final String texto;
  final Color color;
  _PasoError(this.titulo, this.texto, this.color);
}
