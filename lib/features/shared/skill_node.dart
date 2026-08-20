import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../core/theme/app_typography.dart';
import '../../models/skill.dart';

/// Nodo del árbol de habilidades — Design System sección 4:
/// bloqueado (gris, candado) / disponible (color primario) /
/// en progreso (barra parcial) / dominado (relleno sólido + check).
class SkillNode extends StatelessWidget {
  final Skill skill;
  final SkillEstado estado;
  final VoidCallback? onTap;

  const SkillNode({super.key, required this.skill, required this.estado, this.onTap});

  @override
  Widget build(BuildContext context) {
    final ramaColor = AppColors.ramaColor(skill.rama);
    final habilitado = estado != SkillEstado.bloqueado;

    Color colorPrincipal;
    Widget icono;
    switch (estado) {
      case SkillEstado.bloqueado:
        colorPrincipal = AppColors.border;
        icono = const Icon(Icons.lock_outline, color: AppColors.textSecondary, size: 20);
        break;
      case SkillEstado.disponible:
        colorPrincipal = ramaColor;
        icono = Icon(Icons.play_arrow_rounded, color: ramaColor, size: 22);
        break;
      case SkillEstado.enProgreso:
        colorPrincipal = ramaColor;
        icono = Text('${(skill.dominio * 100).round()}%',
            style: AppTypography.caption.copyWith(color: ramaColor, fontWeight: FontWeight.w700));
        break;
      case SkillEstado.dominado:
        colorPrincipal = AppColors.success;
        icono = const Icon(Icons.check_rounded, color: AppColors.success, size: 22);
        break;
    }

    return InkWell(
      onTap: habilitado ? onTap : null,
      borderRadius: BorderRadius.circular(AppRadius.lg),
      child: AnimatedContainer(
        duration: AppMotion.entrance,
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.md, horizontal: AppSpacing.lg),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppRadius.lg),
          border: Border.all(color: colorPrincipal.withOpacity(habilitado ? 0.6 : 0.3), width: 1.5),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: colorPrincipal.withOpacity(0.12),
                shape: BoxShape.circle,
              ),
              child: icono,
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Text(
                skill.nombre,
                style: AppTypography.body.copyWith(
                  color: habilitado ? AppColors.textPrimary : AppColors.textSecondary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
