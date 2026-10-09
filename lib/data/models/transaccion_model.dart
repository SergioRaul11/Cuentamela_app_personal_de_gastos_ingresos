import 'package:hive/hive.dart';

import '../../domain/entities/transaccion.dart';

part 'transaccion_model.g.dart';

/// Modelo de persistencia de un movimiento (ingreso, gasto o ahorro).
///
/// Se guarda en la caja `transactionsBox` con el `id` como clave.
///
/// El tipo se guarda como **texto** (`ingreso` / `gasto` / `ahorro`) y no como
/// índice del enum: así, si algún día se reordena [TipoMovimiento], los datos
/// ya escritos en los teléfonos de los usuarios siguen siendo válidos.
@HiveType(typeId: 1)
class TransaccionModel {
  const TransaccionModel({
    required this.id,
    required this.tipoCodigo,
    required this.descripcion,
    required this.monto,
    required this.fecha,
    required this.creadoEn,
    this.objetivoId,
  });

  @HiveField(0)
  final String id;

  /// `ingreso` | `gasto` | `ahorro`
  @HiveField(1)
  final String tipoCodigo;

  @HiveField(2)
  final String descripcion;

  @HiveField(3)
  final double monto;

  @HiveField(4)
  final DateTime fecha;

  @HiveField(5)
  final DateTime creadoEn;

  /// Solo en ahorros: id del objetivo al que se abonó.
  @HiveField(6)
  final String? objetivoId;

  /// `true` si el registro es un ahorro.
  bool get esAhorro => tipoCodigo == 'ahorro';

  TipoMovimiento get tipo => TipoMovimientoX.desdeCodigo(tipoCodigo);

  // ─────────────────── Mapeo modelo ⇄ entidad ───────────────────

  factory TransaccionModel.desdeEntidad(Transaccion t) => TransaccionModel(
        id: t.id,
        tipoCodigo: t.tipo.codigo,
        descripcion: t.descripcion,
        monto: t.monto,
        fecha: t.fecha,
        creadoEn: t.creadoEn,
        objetivoId: t.objetivoId,
      );

  Transaccion aEntidad() => Transaccion(
        id: id,
        tipo: TipoMovimientoX.desdeCodigo(tipoCodigo),
        descripcion: descripcion,
        monto: monto,
        fecha: fecha,
        creadoEn: creadoEn,
        objetivoId: objetivoId,
      );
}
