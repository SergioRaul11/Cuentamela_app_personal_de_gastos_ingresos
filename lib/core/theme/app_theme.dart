import 'package:flutter/material.dart';

import 'app_colors.dart';
import 'app_typography.dart';

// Se reexporta la paleta y sus extensiones de contexto (`context.colorMarca`,
// `context.esOscuro`…) para que cualquier archivo que importe el tema tenga
// disponibles los colores de la app sin dobles importaciones.
export 'app_colors.dart';

/// Radios, espaciados y sombras: los tres pilares del look "moderno suave".
class AppRadii {
  AppRadii._();
  static const double xs = 10;
  static const double s = 14;
  static const double m = 18;
  static const double l = 24;
  static const double xl = 32;
  static const double pastilla = 999;

  static BorderRadius get tarjeta => BorderRadius.circular(m);
  static BorderRadius get tarjetaGrande => BorderRadius.circular(l);
  static BorderRadius get hoja => const BorderRadius.vertical(top: Radius.circular(xl));
}

class AppEspacios {
  AppEspacios._();
  static const double xs = 4;
  static const double s = 8;
  static const double m = 16;
  static const double g = 20;
  static const double l = 24;
  static const double xl = 32;

  /// Margen lateral universal de la app.
  static const EdgeInsets lateral = EdgeInsets.symmetric(horizontal: m);
}

class AppSombras {
  AppSombras._();

  /// Sombra muy tenue: en modo claro diferencia la tarjeta del fondo;
  /// en oscuro basta con un borde, así que la sombra casi desaparece.
  static List<BoxShadow> suave(bool oscuro) => <BoxShadow>[
        BoxShadow(
          color: oscuro
              ? Colors.black.withOpacity(0.30)
              : const Color(0xFF0F1728).withOpacity(0.05),
          blurRadius: oscuro ? 18 : 24,
          offset: const Offset(0, 8),
        ),
      ];

  static List<BoxShadow> marca = <BoxShadow>[
    BoxShadow(
      color: AppColors.menta.withOpacity(0.28),
      blurRadius: 28,
      offset: const Offset(0, 14),
    ),
  ];
}

/// Tema claro y oscuro de la aplicación.
///
/// Se configuran a propósito **pocos** componentes globales (AppBar, SnackBar,
/// NavigationBar) para que el estilo de las tarjetas y campos viva en widgets
/// propios y no dependa de tokens que cambian entre versiones de Flutter.
class AppTheme {
  AppTheme._();

  static ThemeData get claro => _construir(Brightness.light);
  static ThemeData get oscuro => _construir(Brightness.dark);

  static ThemeData _construir(Brightness brillo) {
    final bool oscuro = brillo == Brightness.dark;

    final Color fondo = oscuro ? AppColors.fondoOscuro : AppColors.fondoClaro;
    final Color superficie =
        oscuro ? AppColors.superficieOscura : AppColors.superficieClara;
    final Color borde = oscuro ? AppColors.bordeOscuro : AppColors.bordeClaro;
    final Color texto = oscuro ? AppColors.textoOscuro : AppColors.textoClaro;
    final Color textoSuave =
        oscuro ? AppColors.textoSuaveOscuro : AppColors.textoSuaveClaro;
    final Color marca = oscuro ? AppColors.mentaLuz : AppColors.menta;

    final ColorScheme esquema = ColorScheme.fromSeed(
      seedColor: AppColors.menta,
      brightness: brillo,
    ).copyWith(
      primary: marca,
      surface: superficie,
      onSurface: texto,
      outline: borde,
      error: AppColors.gasto,
    );

    final TextTheme tipografia = AppTypography.construir(texto, textoSuave);

    return ThemeData(
      useMaterial3: true,
      brightness: brillo,
      colorScheme: esquema,
      scaffoldBackgroundColor: fondo,
      fontFamilyFallback: AppTypography.fallbacks,
      textTheme: tipografia,
      splashFactory: InkRipple.splashFactory,
      appBarTheme: AppBarTheme(
        backgroundColor: fondo,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        foregroundColor: texto,
        titleTextStyle: tipografia.titleLarge,
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: oscuro ? const Color(0xFF1F2733) : const Color(0xFF101828),
        contentTextStyle: tipografia.bodyMedium?.copyWith(color: Colors.white),
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadii.s)),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: superficie,
        indicatorColor: marca.withOpacity(0.14),
        elevation: 0,
        height: 68,
      ),
      iconTheme: IconThemeData(color: texto, size: 22),
      dividerColor: borde,
    );
  }
}
