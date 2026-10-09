/// Generador de identificadores locales.
///
/// Sin dependencias (nada de `uuid`): la marca de tiempo en microsegundos es
/// única en un dispositivo para dos movimientos creados a mano, que es todo
/// lo que esta app necesita para enlazar un ahorro con su objetivo.
class Ids {
  Ids._();

  static String nuevo() => DateTime.now().microsecondsSinceEpoch.toString();

  /// Id legible solo para depuración.
  static String nuevoConPrefijo(String prefijo) => '$prefijo-${nuevo()}';
}
