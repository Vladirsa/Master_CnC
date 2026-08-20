import 'package:flutter/material.dart';
import 'app_colors.dart';
import 'app_typography.dart';

class AppRadius {
  AppRadius._();
  static const sm = 8.0;
  static const md = 10.0; // igual al radius del Cotizador (10, no 12)
  static const lg = 16.0;
  static const chamfer = 10.0;
}

class AppSpacing {
  AppSpacing._();
  static const xs = 4.0;
  static const sm = 8.0;
  static const md = 12.0;
  static const lg = 16.0;
  static const xl = 24.0;
  static const xxl = 32.0;
}

class AppMotion {
  AppMotion._();
  static const entrance = Duration(milliseconds: 220);
  static const success = Duration(milliseconds: 320);
  static const errorShake = Duration(milliseconds: 180);
  static const levelUp = Duration(milliseconds: 600);
}

/// Tema claro — igual al patrón del Cotizador HETNA (design_system.md):
/// ColorScheme.fromSeed(AppColors.azul) + fondo gris claro + tarjetas
/// blancas. Reemplaza el tema oscuro "Neo-CNC" de la primera iteración.
class AppTheme {
  AppTheme._();

  static ThemeData get light {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(seedColor: AppColors.azul, brightness: Brightness.light),
      fontFamily: 'Inter',
      scaffoldBackgroundColor: AppColors.gris,
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.white,
        foregroundColor: AppColors.azul,
        elevation: 0,
      ),
      cardTheme: CardTheme(
        color: Colors.white,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
          side: const BorderSide(color: AppColors.grisBorde, width: 0.5),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.azul,
          foregroundColor: Colors.white,
          minimumSize: const Size.fromHeight(46),
          textStyle: AppTypography.body.copyWith(fontWeight: FontWeight.w700, color: Colors.white),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.md)),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.textPrimary,
          side: const BorderSide(color: AppColors.grisBorde),
          minimumSize: const Size.fromHeight(46),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.md)),
        ),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: Colors.white,
        selectedItemColor: AppColors.azul,
        unselectedItemColor: AppColors.textoSecundario,
        type: BottomNavigationBarType.fixed,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.azulClaro,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
          borderSide: const BorderSide(color: AppColors.azul, width: 1.5),
        ),
      ),
      textTheme: TextTheme(
        headlineLarge: AppTypography.h1,
        headlineMedium: AppTypography.h2,
        headlineSmall: AppTypography.h3,
        bodyLarge: AppTypography.body,
        bodyMedium: AppTypography.body,
        bodySmall: AppTypography.caption,
      ),
    );
  }
}

/// Marco de escritorio para web — mismo patrón del Cotizador: centra la
/// app en pantallas anchas con un degradado azul alrededor.
class DesktopFrame extends StatelessWidget {
  final Widget child;
  const DesktopFrame({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      if (constraints.maxWidth <= 760) return child;
      final ancho = (constraints.maxWidth * 0.5).clamp(420.0, 720.0);
      return Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF0f2438), AppColors.azul],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Center(
          child: Container(
            width: ancho,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
            ),
            clipBehavior: Clip.antiAlias,
            child: child,
          ),
        ),
      );
    });
  }
}
