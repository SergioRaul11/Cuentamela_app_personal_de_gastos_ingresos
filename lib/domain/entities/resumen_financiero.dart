import 'objetivo.dart';
import 'transaccion.dart';
import 'usuario.dart';

/// Totales que alimentan las tarjetas de la pantalla principal.
///
/// Es una entidad derivada: no se guarda en Hive, se calcula a partir del
/// usuario, sus movimientos y sus metas.
class ResumenFinanciero {
  const ResumenFinanciero({
    required this.balanceActual,
    required this.totalIngresos,
    required this.totalGastos,
    required this.totalAhorrado,
    required this.totalEnMetas,
    required this.numeroMovimientos,
    required this.creadoEn,
  });

  /// Dinero disponible: base + ingresos − gastos − ahorros.
  final double balanceActual;

  final double totalIngresos;

  /// Gastos por consumo, sin contar ahorros.
  final double totalGastos;

  /// Ahorros abonados a metas (también son salida).
  final double totalAhorrado;

  /// Suma de lo abonado en todas las metas (debe coincidir con
  /// [totalAhorrado] mientras no se borren movimientos a mano).
  final double totalEnMetas;

  final int numeroMovimientos;

  /// Momento del cálculo, para el "actualizado hace un momento".
  final DateTime creadoEn;

  /// Todo lo que salió del bolsillo: consumos + ahorros.
  double get totalSalidas => totalGastos + totalAhorrado;

  bool get sinMovimientos => numeroMovimientos == 0;

  /// Porcentaje del dinero disponible que está guardado en metas.
  double get porcentajeAhorrado => balanceActual + totalAhorrado <= 0
      ? 0
      : totalAhorrado / (balanceActual + totalAhorrado);

  /// Estado inicial: usuario nuevo, sin movimientos ni metas.
  factory ResumenFinanciero.vacio() => ResumenFinanciero(
        balanceActual: 0,
        totalIngresos: 0,
        totalGastos: 0,
        totalAhorrado: 0,
        totalEnMetas: 0,
        numeroMovimientos: 0,
        creadoEn: DateTime.now(),
      );

  factory ResumenFinanciero.calcular({
    required Usuario? usuario,
    required List<Transaccion> transacciones,
    required List<Objetivo> objetivos,
  }) {
    double ingresos = 0;
    double gastos = 0;
    double ahorros = 0;

    for (final Transaccion t in transacciones) {
      switch (t.tipo) {
        case TipoMovimiento.ingreso:
          ingresos += t.monto;
          break;
        case TipoMovimiento.gasto:
          gastos += t.monto;
          break;
        case TipoMovimiento.ahorro:
          ahorros += t.monto;
          break;
      }
    }

    final double base = usuario?.balanceInicial ?? 0;

    return ResumenFinanciero(
      balanceActual: base + ingresos - gastos - ahorros,
      totalIngresos: ingresos,
      totalGastos: gastos,
      totalAhorrado: ahorros,
      totalEnMetas:
          objetivos.fold<double>(0, (double a, Objetivo o) => a + o.montoAhorrado),
      numeroMovimientos: transacciones.length,
      creadoEn: DateTime.now(),
    );
  }
}
