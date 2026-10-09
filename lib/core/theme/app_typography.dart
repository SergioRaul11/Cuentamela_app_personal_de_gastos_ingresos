import 'package:flutter/material.dart';

/// Tipografía de **Cuéntamela**.
///
/// No se descargan fuentes por red: se declara la pila del sistema con
/// *fallback* a `Inter`, `SF Pro` (iOS) y `Roboto` (Android). Si quieres la
/// fuente fija empaquetada, añade `google_fonts` y usa
/// `GoogleFonts.interTextTheme(...)` en `app_theme.dart` (ver README).
class AppTypography {
  AppTypography._();

  static const List<String> fallbacks = <String>[
    'Inter',
    'SF Pro Display',
    'SF Pro Text',
    'Segoe UI',
    'Roboto',
    'Helvetica Neue',
    'Arial',
  ];

  static TextStyle _estilo({
    required double tamano,
    required FontWeight peso,
    required Color color,
    double? altura,
    double interletra = 0,
  }) {
    return TextStyle(
      fontSize: tamano,
      fontWeight: peso,
      color: color,
      height: altura,
      letterSpacing: interletra,
      fontFamilyFallback: fallbacks,
    );
  }

  /// Escala tipográfica. Se usan números de línea altos (1,25–1,45) porque
  /// son textos cortos en pantallas grandes: respiración > densidad.
  static TextTheme construir(Color principal, Color suave) {
    return TextTheme(
      // Cifras grandes (dinero actual).
      displaySmall: _estilo(
        tamano: 40,
        peso: FontWeight.w700,
        color: principal,
        altura: 1.1,
        interletra: -1.0,
      ),
      headlineMedium: _estilo(
        tamano: 28,
        peso: FontWeight.w700,
        color: principal,
        altura: 1.15,
        interletra: -0.6,
      ),
      headlineSmall: _estilo(
        tamano: 24,
        peso: FontWeight.w700,
        color: principal,
        altura: 1.2,
        interletra: -0.4,
      ),
      titleLarge: _estilo(
        tamano: 20,
        peso: FontWeight.w700,
        color: principal,
        altura: 1.25,
        interletra: -0.2,
      ),
      titleMedium: _estilo(
        tamano: 16,
        peso: FontWeight.w600,
        color: principal,
        altura: 1.3,
      ),
      titleSmall: _estilo(
        tamano: 14,
        peso: FontWeight.w600,
        color: principal,
        altura: 1.3,
      ),
      bodyLarge: _estilo(
        tamano: 16,
        peso: FontWeight.w400,
        color: principal,
        altura: 1.45,
      ),
      bodyMedium: _estilo(
        tamano: 14,
        peso: FontWeight.w400,
        color: principal,
        altura: 1.45,
      ),
      bodySmall: _estilo(
        tamano: 12.5,
        peso: FontWeight.w400,
        color: suave,
        altura: 1.4,
      ),
      labelLarge: _estilo(
        tamano: 14,
        peso: FontWeight.w600,
        color: principal,
        altura: 1.2,
        interletra: 0.1,
      ),
      labelMedium: _estilo(
        tamano: 12,
        peso: FontWeight.w600,
        color: suave,
        altura: 1.2,
        interletra: 0.3,
      ),
      labelSmall: _estilo(
        tamano: 11,
        peso: FontWeight.w600,
        color: suave,
        altura: 1.2,
        interletra: 0.4,
      ),
    );
  }
}
