import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/utils/ids.dart';
import '../../core/utils/validators.dart';
import '../../domain/entities/transaccion.dart';
import 'database_provider.dart';

/// Lista de movimientos, siempre ordenada de más reciente a más antiguo.
///
/// Se suscribe a `transactionsBox.watch()`: cualquier escritura (desde el chat,
/// el perfil o un borrado) refresca la lista sin refrescar la pantalla a mano.
class TransaccionesNotifier extends StateNotifier<List<Transaccion>> {
  TransaccionesNotifier(this._ref)
      : super(_ref.read(databaseProvider).leerTransacciones()) {
    _suscripcion = _ref
        .read(databaseProvider)
        .escuchaTransacciones
        .listen((_) => _recargar());
  }

  final Ref _ref;
  StreamSubscription<dynamic>? _suscripcion;

  void _recargar() {
    if (!mounted) return;
    state = _ref.read(databaseProvider).leerTransacciones();
  }

  /// Registra un movimiento validando las reglas duras antes de tocar Hive.
  ///
  /// Lanza [ArgumentError] con un mensaje apto para mostrar al usuario si el
  /// monto no es positivo o si la fecha es futura.
  Future<Transaccion> registrar({
    required TipoMovimiento tipo,
    required String descripcion,
    required double monto,
    required DateTime fecha,
    String? objetivoId,
  }) async {
    if (monto <= 0) {
      throw ArgumentError(Validators.mensajeMontoInvalido);
    }
    if (Validators.esFechaFutura(fecha)) {
      throw ArgumentError(Validators.mensajeFechaFutura);
    }
    if (descripcion.trim().isEmpty) {
      throw ArgumentError(Validators.mensajeTextoObligatorio);
    }

    final Transaccion nueva = Transaccion(
      id: Ids.nuevoConPrefijo('mov'),
      tipo: tipo,
      descripcion: descripcion.trim(),
      monto: monto,
      fecha: fecha,
      creadoEn: DateTime.now(),
      objetivoId: objetivoId,
    );

    await _ref.read(databaseProvider).guardarTransaccion(nueva);
    return nueva;
  }

  Future<void> eliminar(String id) async {
    await _ref.read(databaseProvider).eliminarTransaccion(id);
  }

  @override
  void dispose() {
    _suscripcion?.cancel();
    super.dispose();
  }
}

final StateNotifierProvider<TransaccionesNotifier, List<Transaccion>>
    transaccionesProvider =
    StateNotifierProvider<TransaccionesNotifier, List<Transaccion>>(
  TransaccionesNotifier.new,
  name: 'transaccionesProvider',
);

/// Solo los gastos por consumo (sin ahorros).
final Provider<List<Transaccion>> gastosProvider = Provider<List<Transaccion>>(
  (Ref ref) => ref
      .watch(transaccionesProvider)
      .where((Transaccion t) => t.tipo == TipoMovimiento.gasto)
      .toList(),
  name: 'gastosProvider',
);

/// Solo los ingresos.
final Provider<List<Transaccion>> ingresosProvider = Provider<List<Transaccion>>(
  (Ref ref) => ref
      .watch(transaccionesProvider)
      .where((Transaccion t) => t.tipo == TipoMovimiento.ingreso)
      .toList(),
  name: 'ingresosProvider',
);

/// Solo los abonos a metas.
final Provider<List<Transaccion>> ahorrosProvider = Provider<List<Transaccion>>(
  (Ref ref) => ref
      .watch(transaccionesProvider)
      .where((Transaccion t) => t.tipo == TipoMovimiento.ahorro)
      .toList(),
  name: 'ahorrosProvider',
);
