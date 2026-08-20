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
import 'widgets/seleccion_widget.dart';
import 'widgets/ordenar_widget.dart';
import 'widgets/configurar_widget.dart';

/// Pantalla de Misión — Ciclo 2: ahora recorre TODAS las misiones
/// disponibles de la skill (no solo 'seleccion'/'detectar_error' fijos),
/// una a la vez, sin importar el orden en que se hayan cargado en Supabase.
/// El widget de respuesta cambia según `tipo`, pero el flujo alrededor
/// (tarjeta, XP, botón) es el mismo para los 4 tipos.
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

  late Future<List<MissionTemplate>> _future;
  int _indice = 0;

  // Estado de respuesta en construcción — cada widget de tipo lo actualiza.
  String? _opcionSeleccionada; // seleccion / detectar_error
  List<String>? _ordenPropuesto; // ordenar
  Map<String, String> _seleccionParametros = {}; // configurar: parametroId -> opcionId

  @override
  void initState() {
    super.initState();
    _future = _missionRepo.obtenerMisionesDeSkill(widget.skill.id);
  }

  void _resetRespuesta() {
    _opcionSeleccionada = null;
    _ordenPropuesto = null;
    _seleccionParametros = {};
  }

  bool _respuestaCompleta(MissionTemplate m) {
    switch (m.tipo) {
      case MissionTipo.seleccion:
      case MissionTipo.detectarError:
        return _opcionSeleccionada != null;
      case MissionTipo.ordenar:
        return _ordenPropuesto != null;
      case MissionTipo.configurar:
        return _seleccionParametros.length == m.parametros.length;
    }
  }

  bool _esCorrecto(MissionTemplate m) {
    switch (m.tipo) {
      case MissionTipo.seleccion:
      case MissionTipo.detectarError:
        return _opcionSeleccionada == m.respuestaCorrectaId;
      case MissionTipo.ordenar:
        final propuesto = _ordenPropuesto ?? [];
        if (propuesto.length != m.ordenCorrecto.length) return false;
        for (var i = 0; i < propuesto.length; i++) {
          if (propuesto[i] != m.ordenCorrecto[i]) return false;
        }
        return true;
      case MissionTipo.configurar:
        for (final p in m.parametros) {
          if (_seleccionParametros[p.id] != p.valorCorrectoId) return false;
        }
        return true;
    }
  }

  Future<void> _responder(MissionTemplate mision) async {
    final correcto = _esCorrecto(mision);

    final conceptoDebil = await _missionRepo.registrarIntento(
      templateId: mision.id,
      correcto: correcto,
      errorCodigo: mision.errorCodigoSiFalla,
    );
    await _skillRepo.registrarIntento(skillId: widget.skill.id, correcto: correcto);

    if (correcto) {
      await _playerRepo.otorgarXp(cantidad: mision.xpRecompensa, motivo: 'mision_completada');
    }
    final nuevaDificultad = await _playerRepo.recalcularDificultad();

    if (!mounted) return;
    final reintentar = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => MissionResultScreen(
          correcto: correcto,
          xpGanado: correcto ? mision.xpRecompensa : 0,
          errorCodigo: correcto ? null : mision.errorCodigoSiFalla,
          conceptoDebil: conceptoDebil,
          nuevaDificultad: nuevaDificultad.name,
        ),
      ),
    );

    if (!mounted) return;
    if (reintentar == true) {
      setState(_resetRespuesta);
    } else {
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: Text(widget.skill.nombre)),
      body: FutureBuilder<List<MissionTemplate>>(
        future: _future,
        builder: (context, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: AppColors.primary));
          }
          final misiones = snap.data ?? [];
          if (misiones.isEmpty) {
            return Center(
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

          final mision = misiones[_indice % misiones.length];

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
                      Row(
                        children: [
                          Text(
                            missionTipoLabel(mision.tipo),
                            style: AppTypography.caption.copyWith(
                              color: AppColors.ramaColor(widget.skill.rama),
                              fontWeight: FontWeight.w700,
                              letterSpacing: 1.2,
                            ),
                          ),
                          const Spacer(),
                          Text('${_indice + 1}/${misiones.length}', style: AppTypography.caption),
                        ],
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
                Expanded(child: _widgetDeRespuesta(mision)),
                const SizedBox(height: AppSpacing.md),
                ElevatedButton(
                  onPressed: _respuestaCompleta(mision) ? () => _responder(mision) : null,
                  child: const Text('Confirmar respuesta'),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _widgetDeRespuesta(MissionTemplate mision) {
    switch (mision.tipo) {
      case MissionTipo.seleccion:
      case MissionTipo.detectarError:
        return SeleccionWidget(
          opciones: mision.opciones,
          seleccionada: _opcionSeleccionada,
          onSeleccionar: (id) => setState(() => _opcionSeleccionada = id),
        );
      case MissionTipo.ordenar:
        return OrdenarWidget(
          pasos: mision.pasos,
          onOrdenChanged: (orden) => setState(() => _ordenPropuesto = orden),
        );
      case MissionTipo.configurar:
        return ConfigurarWidget(
          parametros: mision.parametros,
          seleccion: _seleccionParametros,
          onCambiar: (parametroId, opcionId) => setState(() {
            _seleccionParametros = {..._seleccionParametros, parametroId: opcionId};
          }),
        );
    }
  }
}
