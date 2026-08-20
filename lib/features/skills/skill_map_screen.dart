import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../core/theme/app_typography.dart';
import '../../models/skill.dart';
import '../../repositories/skill_repository.dart';
import '../shared/skill_node.dart';
import '../missions/mission_screen.dart';

/// Home ("Aprender") — Design System sección 4: responde inmediatamente
/// "¿qué debo hacer ahora?", no un dashboard de métricas. Ciclo 1 solo
/// muestra la rama Fundamentos (Kickoff sección 2).
class SkillMapScreen extends StatefulWidget {
  const SkillMapScreen({super.key});

  @override
  State<SkillMapScreen> createState() => _SkillMapScreenState();
}

class _SkillMapScreenState extends State<SkillMapScreen> {
  final _repo = SkillRepository();
  late Future<List<Skill>> _futureSkills;

  @override
  void initState() {
    super.initState();
    _futureSkills = _repo.skillsDeRama('fundamentos');
  }

  Future<void> _refrescar() async {
    setState(() => _futureSkills = _repo.skillsDeRama('fundamentos'));
    await _futureSkills;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Skill>>(
      future: _futureSkills,
      builder: (context, snap) {
        if (snap.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator(color: AppColors.primary));
        }
        if (snap.hasError) {
          return _ErrorCargando(onReintentar: _refrescar);
        }
        final skills = snap.data ?? [];
        if (skills.isEmpty) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(AppSpacing.xl),
              child: Text(
                'Todavía no hay habilidades cargadas en Fundamentos. '
                'Revisa el seed de Supabase.',
                style: AppTypography.bodySecondary,
                textAlign: TextAlign.center,
              ),
            ),
          );
        }

        // Un skill se considera "previo dominado" si no requiere nada
        // o si el skill al que apunta requisito_previo_id ya tiene dominio alto.
        final porId = {for (final s in skills) s.id: s};
        bool previoDominado(Skill s) {
          if (s.requisitoPrevioId == null) return true;
          final previo = porId[s.requisitoPrevioId];
          return previo == null || previo.dominio >= 0.85;
        }

        return RefreshIndicator(
          onRefresh: _refrescar,
          color: AppColors.primary,
          backgroundColor: AppColors.surface,
          child: ListView(
            padding: const EdgeInsets.all(AppSpacing.lg),
            children: [
              Text('FUNDAMENTOS', style: AppTypography.h2),
              const SizedBox(height: AppSpacing.xs),
              Text(
                'Coordenadas y orígenes — la base antes de tocar CAM y G-code.',
                style: AppTypography.bodySecondary,
              ),
              const SizedBox(height: AppSpacing.lg),
              ...skills.map((skill) {
                final estado = skill.estado(previoDominado: previoDominado(skill));
                return Padding(
                  padding: const EdgeInsets.only(bottom: AppSpacing.md),
                  child: SkillNode(
                    skill: skill,
                    estado: estado,
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => MissionScreen(skill: skill)),
                    ).then((_) => _refrescar()),
                  ),
                );
              }),
            ],
          ),
        );
      },
    );
  }
}

class _ErrorCargando extends StatelessWidget {
  final VoidCallback onReintentar;
  const _ErrorCargando({required this.onReintentar});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.wifi_off_rounded, color: AppColors.textSecondary, size: 40),
            const SizedBox(height: AppSpacing.md),
            Text('No se pudo cargar el árbol de Fundamentos.',
                style: AppTypography.body, textAlign: TextAlign.center),
            const SizedBox(height: AppSpacing.md),
            OutlinedButton(onPressed: onReintentar, child: const Text('Reintentar')),
          ],
        ),
      ),
    );
  }
}
