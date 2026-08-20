import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/theme/app_typography.dart';
import '../../../models/mission_template.dart';

/// Lista de opciones tocables — usado por 'seleccion' y 'detectar_error'
/// (misma mecánica visual, la diferencia es solo semántica de la pregunta).
class SeleccionWidget extends StatelessWidget {
  final List<MissionOpcion> opciones;
  final String? seleccionada;
  final ValueChanged<String> onSeleccionar;

  const SeleccionWidget({
    super.key,
    required this.opciones,
    required this.seleccionada,
    required this.onSeleccionar,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      itemCount: opciones.length,
      separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.sm),
      itemBuilder: (context, i) {
        final opcion = opciones[i];
        final activa = seleccionada == opcion.id;
        return InkWell(
          onTap: () => onSeleccionar(opcion.id),
          borderRadius: BorderRadius.circular(AppRadius.md),
          child: Container(
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              color: activa ? AppColors.primary.withOpacity(0.12) : AppColors.surfaceAlt,
              borderRadius: BorderRadius.circular(AppRadius.md),
              border: Border.all(
                color: activa ? AppColors.primary : AppColors.border,
                width: activa ? 1.5 : 1,
              ),
            ),
            child: Text(opcion.texto, style: AppTypography.body),
          ),
        );
      },
    );
  }
}
