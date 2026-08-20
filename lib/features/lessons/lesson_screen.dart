import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../core/theme/app_typography.dart';
import '../../models/skill.dart';
import '../../models/lesson.dart';
import '../../repositories/lesson_repository.dart';
import '../missions/mission_screen.dart';

/// Pantalla de Lección — enseña el concepto ANTES de la misión, en vez de
/// que la única explicación llegue cuando el usuario ya falló. Cierra el
/// hueco detectado por el propietario: "¿por qué solo preguntas, no
/// capacitas?". El Error Engine (explicación al fallar) sigue existiendo
/// tal cual — esta pantalla lo complementa, no lo reemplaza.
class LessonScreen extends StatefulWidget {
  final Skill skill;
  const LessonScreen({super.key, required this.skill});

  @override
  State<LessonScreen> createState() => _LessonScreenState();
}

class _LessonScreenState extends State<LessonScreen> {
  final _repo = LessonRepository();
  late Future<Lesson?> _future;

  @override
  void initState() {
    super.initState();
    _future = _repo.obtenerLeccion(widget.skill.id);
  }

  @override
  Widget build(BuildContext context) {
    final colorRama = AppColors.ramaColor(widget.skill.rama);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: Text(widget.skill.nombre)),
      body: FutureBuilder<Lesson?>(
        future: _future,
        builder: (context, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: AppColors.primary));
          }
          final leccion = snap.data;

          return Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  child: ListView(
                    children: [
                      if (leccion == null) ...[
                        Text(
                          'Todavía no hay lección escrita para esta habilidad — puedes ir directo a la misión.',
                          style: AppTypography.bodySecondary,
                        ),
                      ] else ...[
                        Container(
                          padding: const EdgeInsets.all(AppSpacing.sm),
                          decoration: BoxDecoration(
                            color: colorRama.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(AppRadius.sm),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.menu_book_outlined, size: 16, color: colorRama),
                              const SizedBox(width: 6),
                              Text('LECCIÓN', style: AppTypography.caption.copyWith(
                                color: colorRama, fontWeight: FontWeight.w700, letterSpacing: 1.0)),
                            ],
                          ),
                        ),
                        const SizedBox(height: AppSpacing.md),
                        Text(leccion.titulo, style: AppTypography.h1),
                        const SizedBox(height: AppSpacing.lg),
                        for (final parrafo in leccion.parrafos) ...[
                          Text(parrafo, style: AppTypography.body.copyWith(height: 1.5)),
                          const SizedBox(height: AppSpacing.md),
                        ],
                        if (leccion.datoClave != null) ...[
                          const SizedBox(height: AppSpacing.sm),
                          Container(
                            padding: const EdgeInsets.all(AppSpacing.md),
                            decoration: BoxDecoration(
                              color: AppColors.ambarClaro,
                              borderRadius: BorderRadius.circular(AppRadius.md),
                              border: Border.all(color: AppColors.ambar.withOpacity(0.4)),
                            ),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Icon(Icons.lightbulb_outline, color: AppColors.ambar, size: 20),
                                const SizedBox(width: AppSpacing.sm),
                                Expanded(
                                  child: Text(leccion.datoClave!,
                                      style: AppTypography.body.copyWith(fontStyle: FontStyle.italic)),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                ElevatedButton(
                  onPressed: () => Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (_) => MissionScreen(skill: widget.skill)),
                  ),
                  child: const Text('Comenzar misión'),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
