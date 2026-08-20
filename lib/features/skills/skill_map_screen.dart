import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../core/theme/app_typography.dart';
import '../../models/skill.dart';
import '../../repositories/skill_repository.dart';
import '../shared/skill_node.dart';
import '../lessons/lesson_screen.dart';

const _nombreRama = {
  'fundamentos': 'FUNDAMENTOS',
  'herramientas': 'HERRAMIENTAS',
  'cam': 'CAM',
  'control': 'CONTROL',
};

const _descripcionRama = {
  'fundamentos': 'Coordenadas y orígenes — la base antes de tocar CAM y G-code.',
  'herramientas': 'End Mill, Ball Nose, V-Bit — elegir la herramienta correcta según la geometría.',
  'cam': 'Vectores, toolpaths, roughing y finishing.',
  'control': 'G-code, feed, spindle y simulación.',
};

/// Home ("Aprender") — Design System sección 4: responde inmediatamente
/// "¿qué debo hacer ahora?", no un dashboard de métricas.
///
/// Ciclo 2: ahora agrupa TODAS las ramas que tengan contenido cargado
/// (antes solo mostraba Fundamentos a propósito, por alcance del Ciclo 1).
/// Una rama nueva aparece sola en cuanto se le carga contenido en
/// Supabase — no hace falta tocar este archivo cada vez.
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
    _futureSkills = _repo.todasLasSkills();
  }

  Future<void> _refrescar() async {
    setState(() => _futureSkills = _repo.todasLasSkills());
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
          return Center(
            child: Padding(
              padding: EdgeInsets.all(AppSpacing.xl),
              child: Text(
                'Todavía no hay habilidades cargadas. Revisa el seed de Supabase.',
                style: AppTypography.bodySecondary,
                textAlign: TextAlign.center,
              ),
            ),
          );
        }

        final porId = {for (final s in skills) s.id: s};
        bool previoDominado(Skill s) {
          if (s.requisitoPrevioId == null) return true;
          final previo = porId[s.requisitoPrevioId];
          return previo == null || previo.dominio >= 0.85;
        }

        // Agrupa por rama, respetando el orden pedagógico del Blueprint
        // (Fundamentos → Herramientas → CAM → Control), y deja al final
        // cualquier rama nueva que no esté en la lista conocida todavía.
        final ramasConContenido = skills.map((s) => s.rama).toSet();
        final ramasOrdenadas = [
          ...SkillRepository.ordenRamas.where(ramasConContenido.contains),
          ...ramasConContenido.where((r) => !SkillRepository.ordenRamas.contains(r)),
        ];

        return RefreshIndicator(
          onRefresh: _refrescar,
          color: AppColors.primary,
          backgroundColor: AppColors.surface,
          child: ListView(
            padding: const EdgeInsets.all(AppSpacing.lg),
            children: [
              for (final rama in ramasOrdenadas) ...[
                Text(_nombreRama[rama] ?? rama.toUpperCase(), style: AppTypography.h2),
                const SizedBox(height: AppSpacing.xs),
                Text(_descripcionRama[rama] ?? '', style: AppTypography.bodySecondary),
                const SizedBox(height: AppSpacing.lg),
                ...skills.where((s) => s.rama == rama).map((skill) {
                  final estado = skill.estado(previoDominado: previoDominado(skill));
                  return Padding(
                    padding: const EdgeInsets.only(bottom: AppSpacing.md),
                    child: SkillNode(
                      skill: skill,
                      estado: estado,
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => LessonScreen(skill: skill)),
                      ).then((_) => _refrescar()),
                    ),
                  );
                }),
                const SizedBox(height: AppSpacing.xl),
              ],
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
            Text('No se pudo cargar el árbol de habilidades.',
                style: AppTypography.body, textAlign: TextAlign.center),
            const SizedBox(height: AppSpacing.md),
            OutlinedButton(onPressed: onReintentar, child: const Text('Reintentar')),
          ],
        ),
      ),
    );
  }
}
