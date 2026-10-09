import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';

import 'package:cuentamela/data/datasources/hive_database.dart';
import 'package:cuentamela/data/models/objetivo_model.dart';
import 'package:cuentamela/data/models/transaccion_model.dart';
import 'package:cuentamela/data/models/usuario_model.dart';
import 'package:cuentamela/domain/entities/transaccion.dart';
import 'package:cuentamela/domain/entities/usuario.dart';

/// Pruebas de las reglas de negocio que viven en la capa de datos:
/// apertura de cajas, onboarding, tope de 3 metas y abono a un objetivo.
void main() {
  late HiveDatabase db;

  setUpAll(() async {
    Hive.init('/tmp/cuentamela_test_hive');
    if (!Hive.isAdapterRegistered(0)) Hive.registerAdapter(UsuarioModelAdapter());
    if (!Hive.isAdapterRegistered(1)) {
      Hive.registerAdapter(TransaccionModelAdapter());
    }
    if (!Hive.isAdapterRegistered(2)) Hive.registerAdapter(ObjetivoModelAdapter());
  });

  setUp(() async {
    db = await HiveDatabase.abrir();
    await db.reiniciarTodo();
  });

  tearDown(() async {
    await Hive.deleteFromDisk();
  });

  test('sin usuario, el onboarding no está completado', () {
    expect(db.hayUsuario, isFalse);
    expect(db.onboardingCompletado, isFalse);
  });

  test('el usuario se guarda y el onboarding queda completado', () async {
    await db.guardarUsuario(
      Usuario(
        nombre: 'Ana',
        balanceInicial: 1000,
        creadoEn: DateTime(2026, 1, 1),
      ),
    );

    expect(db.onboardingCompletado, isTrue);
    expect(db.leerUsuario()!.nombre, 'Ana');
    expect(db.leerUsuario()!.primerNombre, 'Ana');
    expect(db.leerUsuario()!.balanceInicial, 1000);
  });

  test('no se admiten más de 3 objetivos', () async {
    for (int i = 1; i <= 3; i++) {
      await db.crearObjetivo(nombre: 'Meta $i', montoObjetivo: 100.0 * i);
    }
    expect(db.leerObjetivos(), hasLength(3));
    expect(db.puedeAgregarObjetivo, isFalse);

    expect(
      () => db.crearObjetivo(nombre: 'Meta 4', montoObjetivo: 400.0),
      throwsStateError,
    );
  });

  test('abonar a un objetivo actualiza la meta y crea el gasto "Ahorro para el ..."',
      () async {
    final objetivo = await db.crearObjetivo(
      nombre: 'Portátil nuevo',
      montoObjetivo: 2000,
    );

    final Transaccion abono = await db.abonarAObjetivo(
      objetivoId: objetivo.id,
      monto: 250,
      fecha: DateTime.now(),
    );

    // 1 · La meta sube.
    expect(db.leerObjetivo(objetivo.id)!.montoAhorrado, 250);

    // 2 · Aparece en la lista como salida de tipo ahorro.
    expect(abono.tipo, TipoMovimiento.ahorro);
    expect(abono.tipo.esSalida, isTrue);
    expect(abono.descripcion, 'Ahorro para el "Portátil nuevo"');
    expect(abono.impacto, -250);
    expect(db.leerTransacciones().single.objetivoId, objetivo.id);
  });

  test('los movimientos se ordenan por fecha descendente', () async {
    await db.guardarTransaccion(
      Transaccion(
        id: 'a',
        tipo: TipoMovimiento.gasto,
        descripcion: 'Viejo',
        monto: 10,
        fecha: DateTime(2026, 1, 1),
        creadoEn: DateTime(2026, 1, 1),
      ),
    );
    await db.guardarTransaccion(
      Transaccion(
        id: 'b',
        tipo: TipoMovimiento.ingreso,
        descripcion: 'Nuevo',
        monto: 20,
        fecha: DateTime(2026, 3, 1),
        creadoEn: DateTime(2026, 3, 1),
      ),
    );

    expect(db.leerTransacciones().first.descripcion, 'Nuevo');
  });

  test('borrar un ahorro devuelve el dinero a su meta', () async {
    final objetivo = await db.crearObjetivo(
      nombre: 'Viaje',
      montoObjetivo: 1000,
    );
    final Transaccion abono = await db.abonarAObjetivo(
      objetivoId: objetivo.id,
      monto: 300,
      fecha: DateTime.now(),
    );

    await db.eliminarTransaccion(abono.id);

    expect(db.leerObjetivo(objetivo.id)!.montoAhorrado, 0);
    expect(db.leerTransacciones(), isEmpty);
  });
}
