import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Pestaña visible en la barra inferior: 0 Inicio · 1 Cuéntamela · 2 Perfil.
///
/// Vive en su propio archivo para que el Home y el chat puedan cambiar de
/// pestaña sin importar el contenedor de pantallas (y sin ciclos de import).
final StateProvider<int> pestanaActualProvider = StateProvider<int>(
  (Ref ref) => 0,
  name: 'pestanaActualProvider',
);

/// Constantes de índice para no repartir números mágicos por la app.
class Pestanas {
  Pestanas._();
  static const int inicio = 0;
  static const int chat = 1;
  static const int perfil = 2;
}
