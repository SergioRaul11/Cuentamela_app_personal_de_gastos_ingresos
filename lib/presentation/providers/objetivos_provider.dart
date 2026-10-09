import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/iconos_meta.dart';
import '../../data/models/objetivo_model.dart';
import '../../domain/entities/objetivo.dart';
import '../../domain/entities/transaccion.dart';
import 'database_provider.dart';

/// Las metas de compra del usuario (máximo 3).
class ObjetivosNotifier extends StateNotifier<List<Objetivo>> {
  ObjetivosNotifier(this._ref) : super(_ref.read(databaseProvider).leerObjetivos()) {
    _suscripcion =
        _ref.read(databaseProvider).escuchaObjetivos.listen((_) => _recargar());
  }

  final Ref _ref;
  StreamSubscription<dynamic>? _suscripcion;

  void _recargar() {
    if (!mounted) return;
    state = _ref.read(databaseProvider).leerObjetivos();
  }

  bool get puedeAgregar => _ref.read(databaseProvider).puedeAgregarObjetivo;

  /// Crea una meta. Lanza [StateError] si ya hay 3.
  Future<Objetivo> crear({
    required String nombre,
    required double montoObjetivo,
    int iconoIndex = 0,
    int? colorValor,
  }) async {
    if (nombre.trim().isEmpty) {
      throw ArgumentError('Ponle un nombre a tu objetivo.');
    }
    if (montoObjetivo <= 0) {
      throw ArgumentError('El precio objetivo debe ser mayor que cero.');
    }
    final Objetivo nuevo = await _ref.read(databaseProvider).crearObjetivo(
          nombre: nombre,
          montoObjetivo: montoObjetivo,
          iconoIndex: iconoIndex,
          colorValor: colorValor ?? IconosMeta.color(iconoIndex),
        );
    _recargar();
    return nuevo;
  }

  Future<void> editar(Objetivo objetivo) async {
    await _ref.read(databaseProvider).actualizarObjetivo(objetivo);
    _recargar();
  }

  Future<void> renombrar(String id, String nombre) async {
    final Objetivo? o = _ref.read(databaseProvider).leerObjetivo(id);
    if (o == null) return;
    await editar(o.copyWith(nombre: nombre.trim()));
  }

  Future<void> cambiarMontoObjetivo(String id, double monto) async {
    final Objetivo? o = _ref.read(databaseProvider).leerObjetivo(id);
    if (o == null) return;
    await editar(o.copyWith(montoObjetivo: monto));
  }

  /// Elimina la meta. Los movimientos de ahorro ya registrados se conservan.
  Future<void> eliminar(String id) async {
    await _ref.read(databaseProvider).eliminarObjetivo(id);
    _recargar();
  }

  /// Abona a una meta y devuelve el movimiento de salida generado
  /// (`Ahorro para el "Nombre"`).
  Future<Transaccion> abonar({
    required String objetivoId,
    required double monto,
    required DateTime fecha,
  }) async {
    final Transaccion abono = await _ref.read(databaseProvider).abonarAObjetivo(
          objetivoId: objetivoId,
          monto: monto,
          fecha: fecha,
        );
    _recargar();
    return abono;
  }

  @override
  void dispose() {
    _suscripcion?.cancel();
    super.dispose();
  }
}

final StateNotifierProvider<ObjetivosNotifier, List<Objetivo>> objetivosProvider =
    StateNotifierProvider<ObjetivosNotifier, List<Objetivo>>(
  ObjetivosNotifier.new,
  name: 'objetivosProvider',
);

/// Cuántas metas más puede crear el usuario (0 cuando ya tiene 3).
final Provider<int> cuposObjetivoProvider = Provider<int>(
  (Ref ref) => ObjetivoModel.maximo - ref.watch(objetivosProvider).length,
  name: 'cuposObjetivoProvider',
);

/// Meta concreta por id, o `null` si ya no existe.
final ProviderFamily<Objetivo?, String> objetivoPorIdProvider =
    Provider.family<Objetivo?, String>(
  (Ref ref, String id) {
    for (final Objetivo o in ref.watch(objetivosProvider)) {
      if (o.id == id) return o;
    }
    return null;
  },
  name: 'objetivoPorIdProvider',
);
