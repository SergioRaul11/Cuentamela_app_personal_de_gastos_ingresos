/// Catálogo de iconos disponibles para las metas de compra.
///
/// Se guarda el **índice** en Hive (no el `IconData`), así que la lista puede
/// crecer al final sin romper los datos ya guardados.
library;

import 'package:flutter/material.dart';

class IconosMeta {
  IconosMeta._();

  static const List<IconData> catalogo = <IconData>[
    Icons.shopping_bag_rounded,
    Icons.laptop_mac_rounded,
    Icons.phone_iphone_rounded,
    Icons.flight_takeoff_rounded,
    Icons.home_rounded,
    Icons.directions_car_rounded,
    Icons.school_rounded,
    Icons.fitness_center_rounded,
    Icons.celebration_rounded,
    Icons.pets_rounded,
    Icons.camera_alt_rounded,
    Icons.savings_rounded,
  ];

  static IconData icono(int indice) =>
      catalogo[indice.clamp(0, catalogo.length - 1)];

  /// Paleta de acento para las tarjetas de meta (ARGB).
  static const List<int> colores = <int>[
    0xFF7C5CFC,
    0xFF00A97F,
    0xFFF79009,
    0xFF2E90FA,
    0xFFEE46BC,
    0xFF12B76A,
  ];

  static int color(int indice) =>
      colores[indice.clamp(0, colores.length - 1)];
}
