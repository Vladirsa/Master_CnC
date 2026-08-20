import 'package:flutter/material.dart';

/// Paleta oficial del ecosistema HETNACNC — la misma del Cotizador
/// (flutter-supabase-saas-mx/references/design_system.md), aplicada tal
/// cual a Master Lab para consistencia total de marca. Reemplaza la
/// paleta "Neo-CNC" (verde-azulado/oscuro) de la primera iteración del
/// Design System — se descartó por sentirse "de videojuego" en vez de
/// confiable/profesional para el mercado real (talleres, hobbyistas).
class AppColors {
  AppColors._();

  static const azul            = Color(0xFF1a3a5c); // color primario de marca
  static const azulClaro       = Color(0xFFe6f1fb);
  static const verde           = Color(0xFF1d9e75); // éxito, dominado
  static const verdeClaro      = Color(0xFFe1f5ee);
  static const ambar           = Color(0xFFef9f27); // advertencia, concepto débil
  static const ambarClaro      = Color(0xFFfaeeda);
  static const rojo            = Color(0xFFe24b4a); // error
  static const rojoClaro       = Color(0xFFfcebeb);
  static const gris            = Color(0xFFf5f6fa); // fondo de pantalla
  static const grisBorde       = Color(0xFFE5E7EB);
  static const textoSecundario = Color(0xFF6B7280);
  static const textoPrincipal  = Color(0xFF111827);

  // Alias usados en el resto del código de Master Lab (nombres genéricos
  // por rol, para no tener que renombrar cada referencia en pantallas).
  static const primary = azul;
  static const primaryDark = Color(0xFF0f2438);
  static const secondary = ambar;
  static const accent = verde;
  static const success = verde;
  static const warning = ambar;
  static const error = rojo;
  static const info = azul;
  static const background = gris;
  static const surface = Colors.white;
  static const surfaceAlt = azulClaro;
  static const textPrimary = textoPrincipal;
  static const textSecondary = textoSecundario;
  static const border = grisBorde;

  /// Color de acento por rama del Skill Tree — cicla dentro de la paleta
  /// oficial en vez de inventar tonos nuevos (Fundamentos=azul,
  /// Herramientas=verde, CAM=ámbar, Control=azul otra vez).
  static Color ramaColor(String rama) {
    switch (rama) {
      case 'fundamentos':
        return azul;
      case 'herramientas':
        return verde;
      case 'cam':
        return ambar;
      case 'control':
        return azul;
      default:
        return azul;
    }
  }
}
