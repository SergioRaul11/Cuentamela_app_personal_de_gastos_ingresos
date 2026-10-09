import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/datasources/hive_database.dart';

/// Acceso a la base de datos local.
///
/// El valor real se inyecta en `main.dart` con
/// `ProviderScope(overrides: [databaseProvider.overrideWithValue(db)])`,
/// después de abrir las cajas de Hive. Si algo olvida la inyección, el
/// proveedor falla con un mensaje claro en lugar de devolver `null`.
final Provider<HiveDatabase> databaseProvider = Provider<HiveDatabase>(
  (Ref ref) => throw UnimplementedError(
    'databaseProvider debe sobrescribirse en ProviderScope tras abrir Hive.',
  ),
  name: 'databaseProvider',
);
