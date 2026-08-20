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
///
/// Ciclo 2: agrega dos avisos del Difficulty Engine (Blueprint sección 9):
/// - `conceptoDebil`: mismo error ≥3 veces → sugerencia de repaso.
/// - `nuevaDificultad`: si el nivel de dificultad cambió tras este intento.
class MissionResultScreen extends StatefulWidget {
  final bool correcto;
  final int xpGanado;
  final String? errorCodigo;
  final bool conceptoDebil;
  final String? nuevaDificultad;

  const MissionResultScreen({
    super.key,
    required this.correcto,
    required this.xpGanado,
    this.errorCodigo,
    this.conceptoDebil = false,
    this.nuevaDificultad,
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
              if (widget.nuevaDificultad != null) ...[
                const SizedBox(height: AppSpacing.lg),
                _AvisoDificultad(dificultad: widget.nuevaDificultad!),
              ],
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
            if (widget.conceptoDebil) ...[
              const _AvisoConceptoDebil(),
              const SizedBox(height: AppSpacing.md),
            ],
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

/// Difficulty Engine (Ciclo 2): "mismo error ≥3 veces → concepto débil".
/// Aviso suave, sin bloquear — la Recovery Mission con contenido propio
/// llega en el Ciclo 3; por ahora solo se le avisa al jugador qué repasar.
class _AvisoConceptoDebil extends StatelessWidget {
  const _AvisoConceptoDebil();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.warning.withOpacity(0.10),
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: AppColors.warning.withOpacity(0.5)),
      ),
      child: Row(
        children: [
          const Icon(Icons.lightbulb_outline, color: AppColors.warning, size: 20),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Text(
              'Notamos que este concepto se te sigue complicando. Vale la pena repasarlo con calma.',
              style: AppTypography.caption.copyWith(color: AppColors.textPrimary),
            ),
          ),
        ],
      ),
    );
  }
}

class _AvisoDificultad extends StatelessWidget {
  final String dificultad;
  const _AvisoDificultad({required this.dificultad});

  @override
  Widget build(BuildContext context) {
    final etiqueta = {
      'principiante': 'Principiante',
      'intermedio': 'Intermedio',
      'avanzado': 'Avanzado',
      'profesional': 'Profesional',
    }[dificultad] ?? dificultad;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.sm),
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.10),
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: AppColors.primary.withOpacity(0.5)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.trending_up, color: AppColors.primary, size: 18),
          const SizedBox(width: 6),
          Text('Dificultad actual: $etiqueta',
              style: AppTypography.caption.copyWith(color: AppColors.primary, fontWeight: FontWeight.w600)),
        ],
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
