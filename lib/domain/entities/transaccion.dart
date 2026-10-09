/// Los tres tipos de movimiento que Cuéntamela entiende.
enum TipoMovimiento {
  /// Dinero que entra.
  ingreso,

  /// Dinero que sale por un consumo.
  gasto,

  /// Dinero que sale del disponible para ir a una meta de compra.
  /// Contablemente es una salida, aunque el dinero siga siendo del usuario.
  ahorro,
}

extension TipoMovimientoX on TipoMovimiento {
  /// `true` si suma al dinero disponible.
  bool get esEntrada => this == TipoMovimiento.ingreso;

  /// `true` si resta del dinero disponible (gasto o ahorro).
  bool get esSalida => !esEntrada;

  /// Etiqueta corta para la interfaz.
  String get etiqueta {
    switch (this) {
      case TipoMovimiento.ingreso:
        return 'Ingreso';
      case TipoMovimiento.gasto:
        return 'Gasto';
      case TipoMovimiento.ahorro:
        return 'Ahorro';
    }
  }

  /// Texto para el selector del chat.
  String get preguntaChat {
    switch (this) {
      case TipoMovimiento.ingreso:
        return '¿Cuál es la descripción del ingreso?';
      case TipoMovimiento.gasto:
        return '¿En qué gastaste? Cuéntame la descripción.';
      case TipoMovimiento.ahorro:
        return '¿Cuánto quieres abonar a tu meta?';
    }
  }

  static TipoMovimiento desdeCodigo(String codigo) {
    switch (codigo) {
      case 'ingreso':
        return TipoMovimiento.ingreso;
      case 'ahorro':
        return TipoMovimiento.ahorro;
      default:
        return TipoMovimiento.gasto;
    }
  }

  /// Código estable: se guarda en Hive para no depender del índice del enum.
  String get codigo {
    switch (this) {
      case TipoMovimiento.ingreso:
        return 'ingreso';
      case TipoMovimiento.gasto:
        return 'gasto';
      case TipoMovimiento.ahorro:
        return 'ahorro';
    }
  }
}

/// Entidad de negocio pura de un movimiento.
class Transaccion {
  const Transaccion({
    required this.id,
    required this.tipo,
    required this.descripcion,
    required this.monto,
    required this.fecha,
    required this.creadoEn,
    this.objetivoId,
  });

  final String id;
  final TipoMovimiento tipo;

  /// Texto visible. En los ahorros lo genera la app:
  /// `Ahorro para el "Portátil nuevo"`.
  final String descripcion;

  /// Siempre positivo. El signo lo aporta [tipo].
  final double monto;

  /// Fecha del movimiento (nunca futura). Es la que ordena la lista.
  final DateTime fecha;

  /// Momento de captura, para desempatar movimientos del mismo día.
  final DateTime creadoEn;

  /// Solo en ahorros: la meta a la que se abonó.
  final String? objetivoId;

  /// Efecto sobre el dinero disponible.
  double get impacto => tipo.esEntrada ? monto : -monto;

  bool get esAhorro => tipo == TipoMovimiento.ahorro;

  Transaccion copyWith({
    String? id,
    TipoMovimiento? tipo,
    String? descripcion,
    double? monto,
    DateTime? fecha,
    DateTime? creadoEn,
    String? objetivoId,
  }) {
    return Transaccion(
      id: id ?? this.id,
      tipo: tipo ?? this.tipo,
      descripcion: descripcion ?? this.descripcion,
      monto: monto ?? this.monto,
      fecha: fecha ?? this.fecha,
      creadoEn: creadoEn ?? this.creadoEn,
      objetivoId: objetivoId ?? this.objetivoId,
    );
  }
}
