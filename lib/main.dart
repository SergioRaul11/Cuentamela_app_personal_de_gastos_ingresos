import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'app.dart';
import 'data/datasources/hive_database.dart';
import 'data/models/objetivo_model.dart';
import 'data/models/transaccion_model.dart';
import 'data/models/usuario_model.dart';
import 'presentation/providers/database_provider.dart';

/// Arranque de **Cuéntamela**.
///
/// Orden estricto (importante: no se puede invertir):
///   1. Hive apuntando al directorio de la app;
///   2. adaptadores registrados (los tres `TypeAdapter`);
///   3. cajas abiertas: userBox, transactionsBox y goalsBox;
///   4. `ProviderScope` con la base de datos inyectada;
///   5. `runApp`.
///
/// Como las cajas quedan abiertas antes de `runApp`, los providers leen de
/// forma sincrónica: la app nunca parpadea un spinner al mostrar el nombre o
/// el dinero del usuario.
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      systemNavigationBarColor: Colors.transparent,
    ),
  );

  // 1 · Hive en el almacenamiento privado de la app.
  await Hive.initFlutter();

  // 2 · Adaptadores generados por Hive (Usuario, Transaccion, Objetivo).
  if (!Hive.isAdapterRegistered(0)) Hive.registerAdapter(UsuarioModelAdapter());
  if (!Hive.isAdapterRegistered(1)) {
    Hive.registerAdapter(TransaccionModelAdapter());
  }
  if (!Hive.isAdapterRegistered(2)) Hive.registerAdapter(ObjetivoModelAdapter());

  // 3 · Las tres cajas del proyecto.
  final Box<UsuarioModel> userBox = await Hive.openBox<UsuarioModel>(Cajas.user);
  final Box<TransaccionModel> transactionsBox =
      await Hive.openBox<TransaccionModel>(Cajas.transactions);
  final Box<ObjetivoModel> goalsBox =
      await Hive.openBox<ObjetivoModel>(Cajas.goals);

  final HiveDatabase baseDeDatos = HiveDatabase.desdeCajas(
    userBox,
    transactionsBox,
    goalsBox,
  );

  // 4 y 5 · Inyección de dependencias y arranque de la interfaz.
  runApp(
    ProviderScope(
      overrides: <Override>[
        databaseProvider.overrideWithValue(baseDeDatos),
      ],
      child: const CuentamelaApp(),
    ),
  );
}
