import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/theme/app_typography.dart';
import '../../../models/mission_template.dart';

/// Tipo 'ordenar' — Blueprint sección 6, Tipo 2. El jugador arrastra los
/// pasos hasta dejarlos en la secuencia correcta del flujo de trabajo CNC
/// (ej. Diseño → Toolpath → Simulación → G-code → Configuración → Mecanizado).
class OrdenarWidget extends StatefulWidget {
  final List<MissionPaso> pasos;
  final ValueChanged<List<String>> onOrdenChanged;

  const OrdenarWidget({super.key, required this.pasos, required this.onOrdenChanged});

  @override
  State<OrdenarWidget> createState() => _OrdenarWidgetState();
}

class _OrdenarWidgetState extends State<OrdenarWidget> {
  late List<MissionPaso> _orden;

  @override
  void initState() {
    super.initState();
    // Se muestra desordenado desde el inicio — invertido es suficiente
    // para el MVP sin necesitar un shuffle con semilla por sesión.
    _orden = widget.pasos.reversed.toList();
    // El jugador debe interactuar para "confirmar" un orden — se notifica
    // el orden inicial igual, así "Confirmar" nunca queda deshabilitado
    // esperando un evento que no depende de decisión real, solo de arrastrar.
    WidgetsBinding.instance.addPostFrameCallback((_) => _notificar());
  }

  void _notificar() {
    widget.onOrdenChanged(_orden.map((p) => p.id).toList());
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Arrastra para poner los pasos en el orden correcto:', style: AppTypography.bodySecondary),
        const SizedBox(height: AppSpacing.sm),
        Expanded(
          child: ReorderableListView.builder(
            itemCount: _orden.length,
            onReorder: (oldIndex, newIndex) {
              setState(() {
                if (newIndex > oldIndex) newIndex -= 1;
                final paso = _orden.removeAt(oldIndex);
                _orden.insert(newIndex, paso);
              });
              _notificar();
            },
            itemBuilder: (context, i) {
              final paso = _orden[i];
              return Container(
                key: ValueKey(paso.id),
                margin: const EdgeInsets.only(bottom: AppSpacing.sm),
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.sm),
                decoration: BoxDecoration(
                  color: AppColors.surfaceAlt,
                  borderRadius: BorderRadius.circular(AppRadius.md),
                  border: Border.all(color: AppColors.border),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 26,
                      height: 26,
                      alignment: Alignment.center,
                      decoration: const BoxDecoration(color: AppColors.primary, shape: BoxShape.circle),
                      child: Text('${i + 1}',
                          style: AppTypography.caption.copyWith(
                              color: AppColors.background, fontWeight: FontWeight.w700)),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(child: Text(paso.texto, style: AppTypography.body)),
                    const Icon(Icons.drag_handle, color: AppColors.textSecondary),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
