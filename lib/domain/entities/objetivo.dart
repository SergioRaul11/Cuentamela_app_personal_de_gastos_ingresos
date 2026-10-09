/// Entidad de negocio pura de un objetivo de compra (meta de ahorro).
class Objetivo {
  const Objetivo({
    required this.id,
    required this.nombre,
    required this.montoObjetivo,
    required this.creadoEn,
    this.montoAhorrado = 0,
    this.iconoIndex = 0,
    this.colorValor = 0xFF7C5CFC,
  });

  final String id;

  /// Nombre de la meta: "Portátil nuevo", "Viaje a Oaxaca"…
  final String nombre;

  /// Cuánto cuesta lo que se quiere comprar.
  final double montoObjetivo;

  /// Cuánto se lleva abonado.
  final double montoAhorrado;

  final DateTime creadoEn;

  /// Índice dentro del catálogo de iconos (`AppIconosMeta`).
  final int iconoIndex;

  /// Color en formato ARGB. Se guarda como `int` para no arrastrar Flutter al
  /// dominio; la interfaz lo convierte con `Color(colorValor)`.
  final int colorValor;

  /// 0.0 – 1.0, listo para la barra de progreso.
  double get progreso {
    if (montoObjetivo <= 0) return 0;
    return (montoAhorrado / montoObjetivo).clamp(0.0, 1.0);
  }

  /// Cuánto falta para completarla.
  double get restante {
    final double r = montoObjetivo - montoAhorrado;
    return r > 0 ? r : 0;
  }

  bool get completado => montoAhorrado >= montoObjetivo;

  /// Descripción exacta que se registra en la lista principal al abonar.
  String get descripcionAhorro => 'Ahorro para el "$nombre"';

  Objetivo copyWith({
    String? id,
    String? nombre,
    double? montoObjetivo,
    double? montoAhorrado,
    DateTime? creadoEn,
    int? iconoIndex,
    int? colorValor,
  }) {
    return Objetivo(
      id: id ?? this.id,
      nombre: nombre ?? this.nombre,
      montoObjetivo: montoObjetivo ?? this.montoObjetivo,
      montoAhorrado: montoAhorrado ?? this.montoAhorrado,
      creadoEn: creadoEn ?? this.creadoEn,
      iconoIndex: iconoIndex ?? this.iconoIndex,
      colorValor: colorValor ?? this.colorValor,
    );
  }
}
