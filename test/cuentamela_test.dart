import 'package:flutter_test/flutter_test.dart';

import 'package:cuentamela/core/utils/formatters.dart';
import 'package:cuentamela/core/utils/validators.dart';
import 'package:cuentamela/domain/entities/objetivo.dart';
import 'package:cuentamela/domain/entities/resumen_financiero.dart';
import 'package:cuentamela/domain/entities/transaccion.dart';
import 'package:cuentamela/domain/entities/usuario.dart';

void main() {
  group('Formatters.moneda', () {
    test('formatea con separador de miles y dos decimales', () {
      expect(Formatters.moneda(1234.5), r'$1.234,50');
      expect(Formatters.moneda(0), r'$0,00');
      expect(Formatters.moneda(1234567.891), r'$1.234.567,89');
    });

    test('marca los negativos', () {
      expect(Formatters.moneda(-250), '−\$250,00');
    });

    test('compacta cifras grandes', () {
      expect(Formatters.moneda(15000, compacto: true), r'$15,0k');
      expect(Formatters.moneda(2500000, compacto: true), r'$2,5M');
    });
  });

  group('Validators · fechas', () {
    test('rechaza fechas futuras', () {
      final DateTime hoy = DateTime(2026, 3, 12);
      expect(
        Validators.esFechaFutura(DateTime(2026, 3, 13), hoy: hoy),
        isTrue,
      );
      expect(
        Validators.esFechaFutura(DateTime(2026, 3, 12), hoy: hoy),
        isFalse,
      );
      expect(
        Validators.validarFecha(DateTime(2026, 3, 13), hoy: hoy),
        Validators.mensajeFechaFutura,
      );
    });

    test('interpreta hoy y ayer', () {
      final DateTime hoy = DateTime(2026, 3, 12, 18);
      expect(Validators.parsearFecha('hoy', hoy: hoy), DateTime(2026, 3, 12));
      expect(Validators.parsearFecha('ayer', hoy: hoy), DateTime(2026, 3, 11));
    });

    test('interpreta formatos numéricos y textuales', () {
      expect(Validators.parsearFecha('12/03/2026'), DateTime(2026, 3, 12));
      expect(Validators.parsearFecha('12-3-26'), DateTime(2026, 3, 12));
      expect(Validators.parsearFecha('2026-03-12'), DateTime(2026, 3, 12));
      expect(Validators.parsearFecha('12 de marzo de 2026'),
          DateTime(2026, 3, 12));
      expect(Validators.parsearFecha('31/02/2026'), isNull);
      expect(Validators.parsearFecha('cualquier cosa'), isNull);
    });
  });

  group('Validators · montos', () {
    test('acepta las convenciones habituales', () {
      expect(Validators.parsearMonto('25'), 25);
      expect(Validators.parsearMonto('25,5'), 25.5);
      expect(Validators.parsearMonto('1.234,56'), 1234.56);
      expect(Validators.parsearMonto(r'$1,234.56'), 1234.56);
      expect(Validators.parsearMonto('1234.56'), 1234.56);
      expect(Validators.parsearMonto('1.500'), 1500);
    });

    test('rechaza montos inválidos', () {
      expect(Validators.parsearMonto('abc'), isNull);
      expect(Validators.validarMonto(null), Validators.mensajeMontoObligatorio);
      expect(Validators.validarMonto(0), Validators.mensajeMontoInvalido);
      expect(Validators.validarMonto(-5), Validators.mensajeMontoInvalido);
    });
  });

  group('Objetivo', () {
    final Objetivo meta = Objetivo(
      id: 'meta-1',
      nombre: 'Portátil nuevo',
      montoObjetivo: 2000,
      montoAhorrado: 500,
      creadoEn: DateTime(2026, 1, 1),
    );

    test('calcula progreso, restante y descripción del ahorro', () {
      expect(meta.progreso, 0.25);
      expect(meta.restante, 1500);
      expect(meta.completado, isFalse);
      expect(meta.descripcionAhorro, 'Ahorro para el "Portátil nuevo"');
    });

    test('el progreso nunca supera el 100 %', () {
      final Objetivo llena = meta.copyWith(montoAhorrado: 3000);
      expect(llena.progreso, 1.0);
      expect(llena.restante, 0);
      expect(llena.completado, isTrue);
    });
  });

  group('ResumenFinanciero', () {
    test('resta gastos y ahorros del dinero disponible', () {
      final ResumenFinanciero resumen = ResumenFinanciero.calcular(
        usuario: Usuario(
          nombre: 'Ana',
          balanceInicial: 1000,
          creadoEn: DateTime(2026, 1, 1),
        ),
        transacciones: <Transaccion>[
          Transaccion(
            id: '1',
            tipo: TipoMovimiento.ingreso,
            descripcion: 'Sueldo',
            monto: 500,
            fecha: DateTime(2026, 3, 1),
            creadoEn: DateTime(2026, 3, 1),
          ),
          Transaccion(
            id: '2',
            tipo: TipoMovimiento.gasto,
            descripcion: 'Supermercado',
            monto: 200,
            fecha: DateTime(2026, 3, 2),
            creadoEn: DateTime(2026, 3, 2),
          ),
          Transaccion(
            id: '3',
            tipo: TipoMovimiento.ahorro,
            descripcion: 'Ahorro para el "Portátil nuevo"',
            monto: 100,
            fecha: DateTime(2026, 3, 3),
            creadoEn: DateTime(2026, 3, 3),
            objetivoId: 'meta-1',
          ),
        ],
        objetivos: <Objetivo>[
          Objetivo(
            id: 'meta-1',
            nombre: 'Portátil nuevo',
            montoObjetivo: 2000,
            montoAhorrado: 100,
            creadoEn: DateTime(2026, 1, 1),
          ),
        ],
      );

      expect(resumen.balanceActual, 1200); // 1000 + 500 − 200 − 100
      expect(resumen.totalIngresos, 500);
      expect(resumen.totalGastos, 200);
      expect(resumen.totalAhorrado, 100); // el ahorro sale, pero no es consumo
      expect(resumen.totalSalidas, 300);
      expect(resumen.totalEnMetas, 100);
      expect(resumen.numeroMovimientos, 3);
    });
  });

  group('TipoMovimiento', () {
    test('el código guardado en Hive es estable y reversible', () {
      for (final TipoMovimiento t in TipoMovimiento.values) {
        expect(TipoMovimientoX.desdeCodigo(t.codigo), t);
      }
      expect(TipoMovimientoX.desdeCodigo('desconocido'), TipoMovimiento.gasto);
    });
  });
}
