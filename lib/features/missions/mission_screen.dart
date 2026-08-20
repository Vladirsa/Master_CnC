import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../core/theme/app_typography.dart';
import '../../models/skill.dart';
import '../../models/mission_template.dart';
import '../../repositories/mission_repository.dart';
import '../../repositories/skill_repository.dart';
import '../../repositories/player_repository.dart';
import '../shared/chamfer_card.dart';
import 'mission_result_screen.dart';

/// Pantalla de Misión — Kickoff sección 5: un solo componente que
/// renderiza según `tipo` de mission_templates ('seleccion' y
/// 'detectar_error' en este ciclo). El texto viene de `contenido` jsonb,
/// nunca hardcodeado aquí.
class MissionScreen extends StatefulWidget {
  final Skill skill;
  const MissionScreen({super.key, required this.skill});

  @override
  State<MissionScreen> createState() => _MissionScreenState();
}

class _MissionScreenState extends State<MissionScreen> {
  final _missionRepo = MissionRepository();
  final _skillRepo = SkillRepository();
  final _playerRepo = PlayerRepository();

  late Future<_MisionesDeSkill> _future;
  String? _opcionSeleccionada;

  @override
  void initState() {
    super.initState();
    _future = _cargarMisiones();
  }

  Future<_MisionesDeSkill> _cargarMisiones() async {
    final seleccion =
        await _missionRepo.obtenerMision(skillId: widget.skill.id, tipo: 'seleccion');
    final detectarError =
        await _missionRepo.obtenerMision(skillId: widget.skill.id, tipo: 'detectar_error');
    return _MisionesDeSkill(seleccion: seleccion, detectarError: detectarError);
  }

  Future<void> _responder(MissionTemplate mision) async {
    final correcto = _opcionSeleccionada == mision.respuestaCorrectaId;

    await _missionRepo.registrarIntento(
      templateId: mision.id,
      correcto: correcto,
      errorCodigo: mision.errorCodigoSiFalla,
    );
    await _skillRepo.registrarIntento(skillId: widget.skill.id, correcto: correcto);

    if (correcto) {
      await _playerRepo.otorgarXp(cantidad: mision.xpRecompensa, motivo: 'mision_completada');
    }

    if (!mounted) return;
    final reintentar = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => MissionResultScreen(
          correcto: correcto,
          xpGanado: correcto ? mision.xpRecompensa : 0,
          errorCodigo: correcto ? null : mision.errorCodigoSiFalla,
        ),
      ),
    );

    if (reintentar == true) {
      setState(() => _opcionSeleccionada = null);
    } else if (mounted) {
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: Text(widget.skill.nombre)),
      body: FutureBuilder<_MisionesDeSkill>(
        future: _future,
        builder: (context, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: AppColors.primary));
          }
          final misiones = snap.data;
          final mision = misiones?.seleccion ?? misiones?.detectarError;
          if (mision == null) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(AppSpacing.xl),
                child: Text(
                  'Todavía no hay misiones cargadas para esta habilidad.',
                  style: AppTypography.bodySecondary,
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }

          return Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                ChamferCard(
                  borderColor: AppColors.ramaColor(widget.skill.rama),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        mision.tipo == MissionTipo.seleccion ? 'SELECCIÓN' : 'DETECTAR ERROR',
                        style: AppTypography.caption.copyWith(
                          color: AppColors.ramaColor(widget.skill.rama),
                          fontWeight: FontWeight.w700,
                          letterSpacing: 1.2,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      Text(mision.pregunta, style: AppTypography.h3),
                      const SizedBox(height: AppSpacing.sm),
                      Row(
                        children: [
                          const Icon(Icons.bolt, size: 14, color: AppColors.secondary),
                          const SizedBox(width: 4),
                          Text('+${mision.xpRecompensa} XP', style: AppTypography.caption),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),
                Expanded(
                  child: ListView.separated(
                    itemCount: mision.opciones.length,
                    separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.sm),
                    itemBuilder: (context, i) {
                      final opcion = mision.opciones[i];
                      final seleccionada = _opcionSeleccionada == opcion.id;
                      return InkWell(
                        onTap: () => setState(() => _opcionSeleccionada = opcion.id),
                        borderRadius: BorderRadius.circular(AppRadius.md),
                        child: Container(
                          padding: const EdgeInsets.all(AppSpacing.md),
                          decoration: BoxDecoration(
                            color: seleccionada
                                ? AppColors.primary.withOpacity(0.12)
                                : AppColors.surfaceAlt,
                            borderRadius: BorderRadius.circular(AppRadius.md),
                            border: Border.all(
                              color: seleccionada ? AppColors.primary : AppColors.border,
                              width: seleccionada ? 1.5 : 1,
                            ),
                          ),
                          child: Text(opcion.texto, style: AppTypography.body),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                ElevatedButton(
                  onPressed: _opcionSeleccionada == null ? null : () => _responder(mision),
                  child: const Text('Confirmar respuesta'),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _MisionesDeSkill {
  final MissionTemplate? seleccion;
  final MissionTemplate? detectarError;
  _MisionesDeSkill({this.seleccion, this.detectarError});
}
