import 'package:flutter/material.dart';

/// Paleta "Neo-CNC" — CNC_MASTER_LAB_DESIGN_SYSTEM.md, sección 3.
/// Identidad visual propia de Master Lab dentro del ecosistema HETNACNC.
class AppColors {
  AppColors._();

  // Marca / progreso
  static const primary = Color(0xFF17C3B2); // verde-azulado "línea láser"
  static const primaryDark = Color(0xFF0E7F76);

  // Taller / materiales
  static const secondary = Color(0xFFFF8A3D); // ámbar taller

  // Patrocinios / premium (uso deliberadamente escaso)
  static const accent = Color(0xFF7C5CFF);

  // Estado
  static const success = Color(0xFF2ECC71);
  static const warning = Color(0xFFFFB800);
  static const error = Color(0xFFFF4D4F);
  static const info = Color(0xFF3E9CFF);

  // Superficies (tema oscuro por defecto)
  static const background = Color(0xFF0B0F14);
  static const surface = Color(0xFF141A21);
  static const surfaceAlt = Color(0xFF1C232C);

  // Texto
  static const textPrimary = Color(0xFFF2F5F7);
  static const textSecondary = Color(0xFF8B96A3);

  static const border = Color(0xFF2A3339);

  /// Color de acento por rama del Skill Tree (Design System, sección 5).
  static Color ramaColor(String rama) {
    switch (rama) {
      case 'fundamentos':
        return primary;
      case 'origenes':
        return primary;
      case 'herramientas':
        return secondary;
      case 'cam':
        return secondary;
      case 'control':
        return accent;
      default:
        return primary;
    }
  }
}
