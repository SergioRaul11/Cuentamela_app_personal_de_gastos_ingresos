import 'package:hive_flutter/hive_flutter.dart';

import '../../core/utils/ids.dart';
import '../../domain/entities/objetivo.dart';
import '../../domain/entities/transaccion.dart';
import '../../domain/entities/usuario.dart';
import '../models/objetivo_model.dart';
import '../models/transaccion_model.dart';
import '../models/usuario_model.dart';

/// Nombres de las tres cajas de Hive que usa Cuéntamela.
class Cajas {
  Cajas._();
  static const String user = 'userBox';
  static const String transactions = 'transactionsBox';
  static const String goals = 'goalsBox';
}

/// Punto único de acceso a la base de datos local.
///
/// Responsabilidades:
///  * Abrir Hive y registrar los adaptadores (una sola vez, en `main`).
///  * Exponer operaciones tipadas (entidades dentro, modelos fuera).
///
/// Toda la escritura pasa por aquí, así que las reglas de negocio duras
/// (fechas no futuras, máximo 3 metas, descripción del ahorro) se aplican en
/// un único sitio.
class HiveDatabase {
  HiveDatabase.desdeCajas(this._userBox, this._transactionsBox, this._goalsBox);

  final Box<UsuarioModel> _userBox;
  final Box<TransaccionModel> _transactionsBox;
  final Box<ObjetivoModel> _goalsBox;

  // ─────────────────────────── ARRANQUE ───────────────────────────

  /// Inicializa Hive en el directorio de la app y registra los adaptadores.
  /// Debe llamarse **antes** de `open()` y antes de `runApp`.
  static Future<void> inicializar() async {
    await Hive.initFlutter();

    if (!Hive.isAdapterRegistered(0)) Hive.registerAdapter(UsuarioModelAdapter());
    if (!Hive.isAdapterRegistered(1)) {
      Hive.registerAdapter(TransaccionModelAdapter());
    }
    if (!Hive.isAdapterRegistered(2)) Hive.registerAdapter(ObjetivoModelAdapter());
  }

  /// Alias cómodo para pruebas y para el arranque: `main.dart` abre las cajas
  /// explícitamente y las pasa aquí.
  factory HiveDatabase.con(Box<UsuarioModel> userBox,
          Box<TransaccionModel> transactionsBox, Box<ObjetivoModel> goalsBox) =>
      HiveDatabase.desdeCajas(userBox, transactionsBox, goalsBox);

  /// Abre las tres cajas y devuelve el repositorio listo para usar.
  static Future<HiveDatabase> abrir() async {
    final Box<UsuarioModel> userBox = await Hive.openBox<UsuarioModel>(Cajas.user);
    final Box<TransaccionModel> transactionsBox =
        await Hive.openBox<TransaccionModel>(Cajas.transactions);
    final Box<ObjetivoModel> goalsBox =
        await Hive.openBox<ObjetivoModel>(Cajas.goals);

    return HiveDatabase.desdeCajas(userBox, transactionsBox, goalsBox);
  }

  /// `true` mientras las cajas estén abiertas y utilizables.
  bool get listo =>
      _userBox.isOpen && _transactionsBox.isOpen && _goalsBox.isOpen;

  /// Observables para que Riverpod reaccione a los cambios en tiempo real.
  Stream<BoxEvent> get escuchaUsuario => _userBox.watch();
  Stream<BoxEvent> get escuchaTransacciones => _transactionsBox.watch();
  Stream<BoxEvent> get escuchaObjetivos => _goalsBox.watch();

  // ──────────────────────────── USUARIO ───────────────────────────

  Usuario? leerUsuario() {
    final UsuarioModel? m = _userBox.get(UsuarioModel.claveUnica);
    return m?.aEntidad();
  }

  bool get hayUsuario => _userBox.containsKey(UsuarioModel.claveUnica);

  /// ¿Ya se completó el onboarding? Se valida en cada arranque para decidir
  /// si se muestra la pantalla de bienvenida o el Home.
  bool get onboardingCompletado {
    final UsuarioModel? m = _userBox.get(UsuarioModel.claveUnica);
    return m != null && m.onboardingCompletado && m.nombre.trim().isNotEmpty;
  }

  /// Crea o reemplaza el usuario. Solo el onboarding y el perfil llaman aquí.
  Future<void> guardarUsuario(Usuario usuario) async {
    await _userBox.put(
      UsuarioModel.claveUnica,
      UsuarioModel.desdeEntidad(usuario),
    );
  }

  Future<void> actualizarNombre(String nombre) async {
    final Usuario? u = leerUsuario();
    if (u == null) return;
    await guardarUsuario(u.copyWith(nombre: nombre.trim()));
  }

  Future<void> actualizarBalanceInicial(double balance) async {
    final Usuario? u = leerUsuario();
    if (u == null) return;
    await guardarUsuario(u.copyWith(balanceInicial: balance));
  }

  Future<void> actualizarTemaOscuro(bool oscuro) async {
    final Usuario? u = leerUsuario();
    if (u == null) return;
    await guardarUsuario(u.copyWith(temaOscuro: oscuro));
  }

  /// Borra todo (usado por "empezar de cero" en el perfil).
  Future<void> reiniciarTodo() async {
    await _transactionsBox.clear();
    await _goalsBox.clear();
    await _userBox.clear();
  }

  // ────────────────────────── MOVIMIENTOS ─────────────────────────

  /// Todos los movimientos, más recientes primero (fecha y hora de captura).
  List<Transaccion> leerTransacciones() {
    final List<Transaccion> lista =
        _transactionsBox.values.map((TransaccionModel m) => m.aEntidad()).toList();
    lista.sort(_porFechaDescendente);
    return lista;
  }

  static int _porFechaDescendente(Transaccion a, Transaccion b) {
    final int porFecha = b.fecha.compareTo(a.fecha);
    if (porFecha != 0) return porFecha;
    return b.creadoEn.compareTo(a.creadoEn);
  }

  List<Transaccion> movimientosDeObjetivo(String objetivoId) => _transactionsBox.values
      .map((TransaccionModel m) => m.aEntidad())
      .where((Transaccion t) => t.objetivoId == objetivoId)
      .toList();

  Future<void> guardarTransaccion(Transaccion transaccion) async {
    assert(
      !transaccion.fecha.isAfter(DateTime.now()),
      'Cuéntamela no permite registrar fechas futuras.',
    );
    await _transactionsBox.put(
      transaccion.id,
      TransaccionModel.desdeEntidad(transaccion),
    );
  }

  Future<void> eliminarTransaccion(String id) async {
    final TransaccionModel? m = _transactionsBox.get(id);
    if (m == null) return;

    // Si era un ahorro, se devuelve el dinero a la meta correspondiente
    // para que la barra de progreso no quede descuadrada.
    if (m.tipo == TipoMovimiento.ahorro && m.objetivoId != null) {
      final ObjetivoModel? o = _goalsBox.get(m.objetivoId);
      if (o != null) {
        final double nuevo = (o.montoAhorrado - m.monto).clamp(0, double.infinity);
        await _goalsBox.put(
          o.id,
          ObjetivoModel(
            id: o.id,
            nombre: o.nombre,
            montoObjetivo: o.montoObjetivo,
            montoAhorrado: nuevo,
            creadoEn: o.creadoEn,
            iconoIndex: o.iconoIndex,
            colorValor: o.colorValor,
          ),
        );
      }
    }
    await _transactionsBox.delete(id);
  }

  // ──────────────────────────── METAS ─────────────────────────────

  /// Las metas, en el orden en que se crearon.
  List<Objetivo> leerObjetivos() {
    final List<Objetivo> lista =
        _goalsBox.values.map((ObjetivoModel m) => m.aEntidad()).toList();
    lista.sort((Objetivo a, Objetivo b) => a.creadoEn.compareTo(b.creadoEn));
    return lista;
  }

  Objetivo? leerObjetivo(String id) => _goalsBox.get(id)?.aEntidad();

  bool get puedeAgregarObjetivo => _goalsBox.length < ObjetivoModel.maximo;

  /// Crea una meta. Lanza si ya hay 3 (el tope definido por el producto).
  Future<Objetivo> crearObjetivo({
    required String nombre,
    required double montoObjetivo,
    int iconoIndex = 0,
    int colorValor = 0xFF7C5CFC,
  }) async {
    if (!puedeAgregarObjetivo) {
      throw StateError('Solo puedes tener ${ObjetivoModel.maximo} objetivos activos.');
    }
    final Objetivo nuevo = Objetivo(
      id: Ids.nuevoConPrefijo('meta'),
      nombre: nombre.trim(),
      montoObjetivo: montoObjetivo,
      creadoEn: DateTime.now(),
      iconoIndex: iconoIndex,
      colorValor: colorValor,
    );
    await _goalsBox.put(nuevo.id, ObjetivoModel.desdeEntidad(nuevo));
    return nuevo;
  }

  Future<void> actualizarObjetivo(Objetivo objetivo) async {
    await _goalsBox.put(objetivo.id, ObjetivoModel.desdeEntidad(objetivo));
  }

  /// Borra la meta. Los ahorros ya registrados **no** se eliminan: siguen
  /// apareciendo en la lista como salidas, así el histórico no se falsea.
  Future<void> eliminarObjetivo(String id) async {
    await _goalsBox.delete(id);
  }

  /// Abona a una meta y devuelve la transacción de salida generada.
  ///
  /// Regla de negocio: el abono actualiza `montoAhorrado` de la meta **y**
  /// crea en la lista principal un movimiento de tipo [TipoMovimiento.ahorro]
  /// con la descripción `Ahorro para el "Nombre de la meta"`.
  Future<Transaccion> abonarAObjetivo({
    required String objetivoId,
    required double monto,
    required DateTime fecha,
  }) async {
    final ObjetivoModel? o = _goalsBox.get(objetivoId);
    if (o == null) throw StateError('Esa meta ya no existe.');

    final double nuevoAhorrado = o.montoAhorrado + monto;

    await _goalsBox.put(
      o.id,
      ObjetivoModel(
        id: o.id,
        nombre: o.nombre,
        montoObjetivo: o.montoObjetivo,
        montoAhorrado: nuevoAhorrado,
        creadoEn: o.creadoEn,
        iconoIndex: o.iconoIndex,
        colorValor: o.colorValor,
      ),
    );

    final Transaccion abono = Transaccion(
      id: Ids.nuevoConPrefijo('mov'),
      tipo: TipoMovimiento.ahorro,
      descripcion: 'Ahorro para el "${o.nombre}"',
      monto: monto,
      fecha: fecha,
      creadoEn: DateTime.now(),
      objetivoId: o.id,
    );
    await _transactionsBox.put(abono.id, TransaccionModel.desdeEntidad(abono));
    return abono;
  }

  /// Vacía la app sin borrar el usuario (útil para probar).
  Future<void> limpiarMovimientos() async {
    await _transactionsBox.clear();
    await _goalsBox.clear();
  }
}
