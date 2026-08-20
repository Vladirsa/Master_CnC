import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

/// Escala tipográfica — CNC_MASTER_LAB_DESIGN_SYSTEM.md, sección 3.
/// Principal: Sora (UI/lecciones). Técnica: JetBrains Mono (parámetros/G-code).
class AppTypography {
  AppTypography._();

  static TextStyle get h1 => GoogleFonts.sora(
      fontSize: 28, height: 32 / 28, fontWeight: FontWeight.w700, color: AppColors.textPrimary);
  static TextStyle get h2 => GoogleFonts.sora(
      fontSize: 22, height: 28 / 22, fontWeight: FontWeight.w700, color: AppColors.textPrimary);
  static TextStyle get h3 => GoogleFonts.sora(
      fontSize: 18, height: 24 / 18, fontWeight: FontWeight.w600, color: AppColors.textPrimary);
  static TextStyle get body => GoogleFonts.sora(
      fontSize: 15, height: 22 / 15, fontWeight: FontWeight.w400, color: AppColors.textPrimary);
  static TextStyle get bodySecondary => body.copyWith(color: AppColors.textSecondary);
  static TextStyle get caption => GoogleFonts.sora(
      fontSize: 12, height: 16 / 12, fontWeight: FontWeight.w400, color: AppColors.textSecondary);

  /// Tipografía monoespaciada para X/Y/Z, RPM, feed, G-code.
  static TextStyle get monoParam => GoogleFonts.jetBrainsMono(
      fontSize: 14, height: 20 / 14, fontWeight: FontWeight.w600, color: AppColors.primary);
}
