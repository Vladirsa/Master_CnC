import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';

/// Tarjeta con esquina superior-derecha cortada a 45° — motivo propio
/// "Neo-CNC" (Design System sección 2 y 5): comunica "esto fue mecanizado".
class ChamferCard extends StatelessWidget {
  final Widget child;
  final Color borderColor;
  final EdgeInsets padding;

  const ChamferCard({
    super.key,
    required this.child,
    this.borderColor = AppColors.primary,
    this.padding = const EdgeInsets.all(AppSpacing.lg),
  });

  @override
  Widget build(BuildContext context) {
    return ClipPath(
      clipper: _ChamferClipper(cut: AppRadius.chamfer + 6),
      child: Container(
        padding: padding,
        decoration: BoxDecoration(color: AppColors.surface),
        child: CustomPaint(
          foregroundPainter: _ChamferBorderPainter(cut: AppRadius.chamfer + 6, color: borderColor),
          child: child,
        ),
      ),
    );
  }
}

class _ChamferClipper extends CustomClipper<Path> {
  final double cut;
  _ChamferClipper({required this.cut});

  @override
  Path getClip(Size size) {
    final path = Path();
    path.moveTo(0, 0);
    path.lineTo(size.width - cut, 0);
    path.lineTo(size.width, cut);
    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}

class _ChamferBorderPainter extends CustomPainter {
  final double cut;
  final Color color;
  _ChamferBorderPainter({required this.cut, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color.withOpacity(0.6)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
    final path = Path()
      ..moveTo(0, 0)
      ..lineTo(size.width - cut, 0)
      ..lineTo(size.width, cut)
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
