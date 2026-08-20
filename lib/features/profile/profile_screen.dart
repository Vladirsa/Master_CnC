import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../core/theme/app_typography.dart';
import '../../models/player_profile.dart';
import '../../repositories/player_repository.dart';

/// Perfil del jugador — Kickoff sección 5: nivel, XP total, barra de
/// dominio por skill de Fundamentos (esta última se agrega en cuanto
/// haya más de 1 skill visible; por ahora, XP + nivel).
class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _repo = PlayerRepository();
  late Future<PlayerProfile> _future;

  @override
  void initState() {
    super.initState();
    _future = _repo.obtenerPerfil();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<PlayerProfile>(
      future: _future,
      builder: (context, snap) {
        if (snap.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator(color: AppColors.primary));
        }
        if (snap.hasError || !snap.hasData) {
          return Center(child: Text('No se pudo cargar tu perfil.', style: AppTypography.body));
        }
        final perfil = snap.data!;
        return ListView(
          padding: const EdgeInsets.all(AppSpacing.lg),
          children: [
            Text('PERFIL', style: AppTypography.h2),
            const SizedBox(height: AppSpacing.lg),
            Container(
              padding: const EdgeInsets.all(AppSpacing.lg),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(AppRadius.lg),
                border: Border.all(color: AppColors.border),
              ),
              child: Row(
                children: [
                  Container(
                    width: 56,
                    height: 56,
                    alignment: Alignment.center,
                    decoration: const BoxDecoration(color: AppColors.primary, shape: BoxShape.circle),
                    child: Text('${perfil.nivel}',
                        style: AppTypography.h2.copyWith(color: Colors.white)),
                  ),
                  const SizedBox(width: AppSpacing.lg),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Nivel ${perfil.nivel}', style: AppTypography.h3),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            const Icon(Icons.bolt, size: 14, color: AppColors.secondary),
                            const SizedBox(width: 4),
                            Text('${perfil.xp} XP total', style: AppTypography.bodySecondary),
                          ],
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: LinearProgressIndicator(
                            value: perfil.progresoNivel,
                            backgroundColor: AppColors.surfaceAlt,
                            color: AppColors.primary,
                            minHeight: 6,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            Text('Dificultad actual: ${perfil.dificultadActual}', style: AppTypography.bodySecondary),
          ],
        );
      },
    );
  }
}
