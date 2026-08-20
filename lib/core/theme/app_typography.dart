import 'package:flutter/material.dart';
import 'app_colors.dart';

/// Escala tipográfica. Fuente principal: Inter — la misma que usa el
/// Cotizador HETNA (design_system.md), para consistencia de marca.
/// Se mantiene una tipografía monoespaciada solo para datos técnicos
/// (X/Y/Z, RPM, feed, G-code) porque ahí sí aporta claridad real.
class AppTypography {
  AppTypography._();

  static const _fontFamily = 'Inter';

  static TextStyle get h1 => const TextStyle(
      fontFamily: _fontFamily, fontSize: 28, height: 32 / 28, fontWeight: FontWeight.w700, color: AppColors.textPrimary);
  static TextStyle get h2 => const TextStyle(
      fontFamily: _fontFamily, fontSize: 22, height: 28 / 22, fontWeight: FontWeight.w700, color: AppColors.textPrimary);
  static TextStyle get h3 => const TextStyle(
      fontFamily: _fontFamily, fontSize: 18, height: 24 / 18, fontWeight: FontWeight.w600, color: AppColors.textPrimary);
  static TextStyle get body => const TextStyle(
      fontFamily: _fontFamily, fontSize: 15, height: 22 / 15, fontWeight: FontWeight.w400, color: AppColors.textPrimary);
  static TextStyle get bodySecondary => body.copyWith(color: AppColors.textSecondary);
  static TextStyle get caption => const TextStyle(
      fontFamily: _fontFamily, fontSize: 12, height: 16 / 12, fontWeight: FontWeight.w400, color: AppColors.textSecondary);

  /// Monoespaciada — solo para parámetros técnicos (X/Y/Z, RPM, feed, G-code).
  static TextStyle get monoParam => const TextStyle(
      fontFamily: 'monospace', fontSize: 14, height: 20 / 14, fontWeight: FontWeight.w600, color: AppColors.azul);
}
