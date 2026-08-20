import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/theme/app_typography.dart';
import '../../../models/mission_template.dart';

/// Tipo 'configurar' — Blueprint sección 6, Tipo 4. El jugador elige
/// valores para cada parámetro (herramienta, RPM, profundidad, etc.) en
/// vez de responder una sola pregunta de opción múltiple. Este ciclo usa
/// selección cerrada por parámetro (chips); un slider numérico libre con
/// tolerancia llega cuando el simulador dé retroalimentación en vivo.
class ConfigurarWidget extends StatelessWidget {
  final List<MissionParametro> parametros;
  final Map<String, String> seleccion;
  final void Function(String parametroId, String opcionId) onCambiar;

  const ConfigurarWidget({
    super.key,
    required this.parametros,
    required this.seleccion,
    required this.onCambiar,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      itemCount: parametros.length,
      separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.lg),
      itemBuilder: (context, i) {
        final parametro = parametros[i];
        final valorElegido = seleccion[parametro.id];
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(parametro.nombre, style: AppTypography.body.copyWith(fontWeight: FontWeight.w700)),
            const SizedBox(height: AppSpacing.sm),
            Wrap(
              spacing: AppSpacing.sm,
              runSpacing: AppSpacing.sm,
              children: parametro.opciones.map((opcion) {
                final activa = valorElegido == opcion.id;
                return ChoiceChip(
                  label: Text(opcion.texto, style: AppTypography.monoParam.copyWith(
                    color: activa ? AppColors.background : AppColors.textPrimary,
                    fontSize: 13,
                  )),
                  selected: activa,
                  onSelected: (_) => onCambiar(parametro.id, opcion.id),
                  backgroundColor: AppColors.surfaceAlt,
                  selectedColor: AppColors.primary,
                  side: BorderSide(color: activa ? AppColors.primary : AppColors.border),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.sm)),
                );
              }).toList(),
            ),
          ],
        );
      },
    );
  }
}
