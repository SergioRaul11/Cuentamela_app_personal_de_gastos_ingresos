import 'package:hive/hive.dart';

import '../../domain/entities/objetivo.dart';

part 'objetivo_model.g.dart';

/// Modelo de persistencia de una meta de compra.
///
/// Se guarda en la caja `goalsBox` con el `id` como clave.
/// Límite de negocio: máximo 3 objetivos activos.
@HiveType(typeId: 2)
class ObjetivoModel {
  const ObjetivoModel({
    required this.id,
    required this.nombre,
    required this.montoObjetivo,
    required this.montoAhorrado,
    required this.creadoEn,
    required this.iconoIndex,
    required this.colorValor,
  });

  /// Tope de metas activas en la app.
  static const int maximo = 3;

  @HiveField(0)
  final String id;

  @HiveField(1)
  final String nombre;

  @HiveField(2)
  final double montoObjetivo;

  @HiveField(3)
  final double montoAhorrado;

  @HiveField(4)
  final DateTime creadoEn;

  @HiveField(5)
  final int iconoIndex;

  @HiveField(6)
  final int colorValor;

  // ─────────────────── Mapeo modelo ⇄ entidad ───────────────────

  factory ObjetivoModel.desdeEntidad(Objetivo o) => ObjetivoModel(
        id: o.id,
        nombre: o.nombre,
        montoObjetivo: o.montoObjetivo,
        montoAhorrado: o.montoAhorrado,
        creadoEn: o.creadoEn,
        iconoIndex: o.iconoIndex,
        colorValor: o.colorValor,
      );

  Objetivo aEntidad() => Objetivo(
        id: id,
        nombre: nombre,
        montoObjetivo: montoObjetivo,
        montoAhorrado: montoAhorrado,
        creadoEn: creadoEn,
        iconoIndex: iconoIndex,
        colorValor: colorValor,
      );
}
