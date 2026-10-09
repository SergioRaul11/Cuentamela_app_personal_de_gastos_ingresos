import 'package:flutter/material.dart';

/// Paleta de color de **Cuéntamela**.
///
/// Regla de diseño: un solo color de marca (menta), tres colores semánticos
/// (ingreso / gasto / ahorro) y una escala de neutros fríos. Nada más.
/// Así la interfaz se mantiene minimalista y la jerarquía la marca el espacio,
/// no el color.
class AppColors {
  AppColors._();

  // ───────────────────────── M A R C A ─────────────────────────
  static const Color menta = Color.fromARGB(255, 0, 43, 134);
  static const Color mentaOscura = Color.fromARGB(255, 136, 196, 231);
  static const Color mentaLuz = Color(0xFF6FE3BE);

  // ───────────────── SEMÁNTICOS (movimientos) ─────────────────
  static const Color ingreso =
      Color.fromARGB(255, 0, 81, 173); // verde dinero que entra
  static const Color gasto = Color(0xFFF04438); // rojo dinero que sale
  static const Color ahorro = Color(0xFF7C5CFC); // violeta metas de compra
  static const Color alerta = Color(0xFFF79009); // avisos y validaciones

  // ──────────────────── NEUTROS · MODO CLARO ──────────────────
  static const Color fondoClaro = Color(0xFFF6F7F9);
  static const Color superficieClara = Color(0xFFFFFFFF);
  static const Color bordeClaro = Color(0xFFEBEDF2);
  static const Color textoClaro = Color(0xFF101828);
  static const Color textoSuaveClaro = Color(0xFF667085);

  // ─────────────────── NEUTROS · MODO OSCURO ──────────────────
  static const Color fondoOscuro = Color(0xFF0B0F14);
  static const Color superficieOscura = Color(0xFF151A21);
  static const Color bordeOscuro = Color(0xFF232A34);
  static const Color textoOscuro = Color(0xFFF2F4F7);
  static const Color textoSuaveOscuro = Color(0xFF98A2B3);

  // ───────────────────────── DEGRADADOS ───────────────────────
  /// Tarjeta de dinero actual en Home.
  static const List<Color> degradadoBalance = [
    Color(0xFF00A97F),
    Color(0xFF10B98D),
    Color(0xFF4FD9B1),
  ];

  /// Cabecera del perfil.
  static const List<Color> degradadoPerfil = [
    Color(0xFF6C5CE7),
    Color(0xFF8F7DFF),
  ];
}

/// Atajos de tema para no depender de tokens de Material que cambian de
/// nombre entre versiones de Flutter. Toda la app pregunta aquí.
extension TemaContexto on BuildContext {
  bool get esOscuro => Theme.of(this).brightness == Brightness.dark;

  Color get colorFondo =>
      esOscuro ? AppColors.fondoOscuro : AppColors.fondoClaro;

  Color get colorSuperficie =>
      esOscuro ? AppColors.superficieOscura : AppColors.superficieClara;

  Color get colorBorde =>
      esOscuro ? AppColors.bordeOscuro : AppColors.bordeClaro;

  Color get colorTexto =>
      esOscuro ? AppColors.textoOscuro : AppColors.textoClaro;

  Color get colorTextoSuave =>
      esOscuro ? AppColors.textoSuaveOscuro : AppColors.textoSuaveClaro;

  /// El menta puro sobre fondo oscuro no contrasta: se aclara.
  Color get colorMarca => esOscuro ? AppColors.mentaLuz : AppColors.menta;

  Color get colorSombra => esOscuro
      ? Colors.black.withOpacity(0.35)
      : const Color(0xFF0F1728).withOpacity(0.06);
}
