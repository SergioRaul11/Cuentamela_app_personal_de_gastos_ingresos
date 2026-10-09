import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/utils/formatters.dart';
import '../../../core/utils/validators.dart';
import '../../../domain/entities/objetivo.dart';
import '../../../domain/entities/transaccion.dart';
import '../../providers/objetivos_provider.dart';
import '../../providers/transacciones_provider.dart';
import '../../providers/usuario_provider.dart';
import 'chat_state_provider.dart';

/// En qué punto de la conversación está el usuario.
enum PasoChat {
  /// "¿Te entró dinero o gastaste algo?" (+ opción de abonar a una meta).
  tipo,

  /// "¿En qué gastaste?" / "¿Cuál es la descripción del ingreso?"
  descripcion,

  /// "¿Cuánto fue?"
  monto,

  /// "¿Qué fecha fue?" (nunca futura)
  fecha,

  /// "¿A qué objetivo quieres abonar?"
  elegirObjetivo,

  /// Confirmación final: "¿Lo registro?"
  confirmar,

  /// Terminado: se ofrece registrar otro.
  fin,
}

/// Un mensaje del chat.
class Mensaje {
  const Mensaje({
    required this.texto,
    required this.deApp,
    required this.hora,
    this.opciones,
    this.esError = false,
  });

  final String texto;

  /// `true` si lo escribió la app, `false` si es del usuario.
  final bool deApp;
  final DateTime hora;

  /// Respuestas sugeridas que se muestran como pastillas bajo el mensaje.
  final List<String>? opciones;

  /// Se pinta como aviso (por ejemplo, una fecha futura rechazada).
  final bool esError;
}

/// Estado completo de la conversación de "Cuéntamela".
class EstadoChat {
  const EstadoChat({
    required this.mensajes,
    required this.paso,
    this.tipo,
    this.descripcion,
    this.monto,
    this.fecha,
    this.objetivoId,
    this.ahorroRestante,
  });

  const EstadoChat.inicial()
      : mensajes = const <Mensaje>[],
        paso = PasoChat.tipo,
        tipo = null,
        descripcion = null,
        monto = null,
        fecha = null,
        objetivoId = null,
        ahorroRestante = null;

  final List<Mensaje> mensajes;
  final PasoChat paso;
  final TipoMovimiento? tipo;
  final String? descripcion;
  final double? monto;
  final DateTime? fecha;
  final String? objetivoId;
  final double? ahorroRestante;

  /// Pista que se muestra dentro del campo de texto según el paso.
  String get placeholder {
    switch (paso) {
      case PasoChat.tipo:
        return 'Escribe: ingreso, gasto o ahorro…';
      case PasoChat.descripcion:
        return 'Descripción del movimiento…';
      case PasoChat.monto:
        return 'Monto, por ejemplo 145,50';
      case PasoChat.fecha:
        return 'Fecha: hoy, ayer o 12/03';
      case PasoChat.elegirObjetivo:
        return 'Nombre del objetivo…';
      case PasoChat.confirmar:
        return 'Sí o no…';
      case PasoChat.fin:
        return 'Escribe algo para empezar de nuevo…';
    }
  }

  EstadoChat copiarCon({
    List<Mensaje>? mensajes,
    PasoChat? paso,
    TipoMovimiento? tipo,
    String? descripcion,
    double? monto,
    DateTime? fecha,
    String? objetivoId,
    double? ahorroRestante,
  }) {
    return EstadoChat(
      mensajes: mensajes ?? this.mensajes,
      paso: paso ?? this.paso,
      tipo: tipo ?? this.tipo,
      descripcion: descripcion ?? this.descripcion,
      monto: monto ?? this.monto,
      fecha: fecha ?? this.fecha,
      objetivoId: objetivoId ?? this.objetivoId,
      ahorroRestante: ahorroRestante ?? this.ahorroRestante,
    );
  }
}

/// Motor de la conversación.
///
/// Es un `StateNotifier` puro: no dibuja nada y solo encadena preguntas,
/// aplicando las reglas de negocio (fechas nunca futuras, descripción fija
/// del ahorro, actualización de la meta) y delegando la escritura en los
/// proveedores de datos, que a su vez escriben en Hive.
class ChatNotifier extends StateNotifier<EstadoChat> {
  ChatNotifier(this._ref) : super(const EstadoChat.inicial()) {
    // Si el Home fija una meta y salta al chat, arrancamos el flujo de abono.
    _ref.listen<String?>(objetivoSeleccionadoProvider, (String? previo, String? nuevo) {
      if (nuevo != null && nuevo != previo) arrancarAbono(nuevo);
    });
  }

  final Ref _ref;

  static const List<String> opcionesTipo = <String>[
    'Fue un ingreso',
    'Fue un gasto',
    'Quiero ahorrar',
  ];

  static const List<String> opcionesContinuar = <String>[
    'Registrar otro movimiento',
  ];

  /// Arranca el chat desde cero con la primera pregunta.
  void iniciar() {
    final String nombre = _ref.read(usuarioProvider)?.primerNombre ?? 'amig@';
    state = EstadoChat(
      mensajes: <Mensaje>[
        Mensaje(
          texto: '¡Hola, $nombre! Cuéntame: ¿te entró dinero o gastaste algo?',
          deApp: true,
          hora: DateTime.now(),
          opciones: opcionesTipo,
        ),
      ],
      paso: PasoChat.tipo,
    );
  }

  /// Punto de entrada único: lo que el usuario escribe o pulsa.
  Future<void> responder(String entrada) async {
    final String limpio = entrada.trim();
    if (limpio.isEmpty) return;

    _agregarUsuario(limpio);

    switch (state.paso) {
      case PasoChat.tipo:
        _procesarTipo(limpio);
        break;
      case PasoChat.descripcion:
        _procesarDescripcion(limpio);
        break;
      case PasoChat.monto:
        _procesarMonto(limpio);
        break;
      case PasoChat.fecha:
        await _procesarFecha(limpio);
        break;
      case PasoChat.elegirObjetivo:
        _procesarEleccionObjetivo(limpio);
        break;
      case PasoChat.confirmar:
        await _procesarConfirmacion(limpio);
        break;
      case PasoChat.fin:
        iniciar();
        break;
    }
  }

  /// Igual que [responder], para las pastillas de respuesta rápida.
  Future<void> elegirOpcion(String opcion) => responder(opcion);

  // ─────────────────────────── PASOS ───────────────────────────

  void _procesarTipo(String entrada) {
    final String t = entrada.toLowerCase();

    if (t.contains('ingreso') || t.contains('entró') || t.contains('entro')) {
      state = state.copiarCon(
        tipo: TipoMovimiento.ingreso,
        paso: PasoChat.descripcion,
      );
      _agregarApp('Perfecto, un ingreso. ¿Cuál es la descripción? '
          'Por ejemplo: "Pago del cliente" o "Venta de mi bici".');
      return;
    }

    if (t.contains('ahorr') || t.contains('meta') || t.contains('objetivo')) {
      final List<Objetivo> metas = _ref.read(objetivosProvider);
      if (metas.isEmpty) {
        _agregarApp(
          'Todavía no tienes objetivos creados. Créalos desde Inicio y luego me '
          'cuentas para abonarles. Mientras, dime: ¿fue un ingreso o un gasto?',
          opciones: <String>['Fue un ingreso', 'Fue un gasto'],
        );
        return;
      }
      state = state.copiarCon(paso: PasoChat.elegirObjetivo);
      _agregarApp(
        '¿A qué objetivo quieres abonar?',
        opciones: metas.map((Objetivo o) => o.nombre).toList(),
      );
      return;
    }

    // Por defecto se entiende que fue un gasto.
    state = state.copiarCon(
      tipo: TipoMovimiento.gasto,
      paso: PasoChat.descripcion,
    );
    _agregarApp('Entendido, un gasto. ¿En qué gastaste? Muy breve, por favor.');
  }

  void _procesarDescripcion(String entrada) {
    state = state.copiarCon(descripcion: entrada, paso: PasoChat.monto);
    _agregarApp('¿Cuánto fue? Escribe solo el número, por ejemplo 145,50');
  }

  void _procesarMonto(String entrada) {
    final double? monto = Validators.parsearMonto(entrada);
    final String? error = Validators.validarMonto(monto);

    if (error != null) {
      _agregarApp(error, esError: true);
      return;
    }

    state = state.copiarCon(monto: monto, paso: PasoChat.fecha);
    _agregarApp(
      'Muy bien: ${Formatters.moneda(monto!)}. ¿Qué fecha fue?',
      opciones: <String>[
        'Hoy',
        'Ayer',
        Formatters.fechaNumerica(
          DateTime.now().subtract(const Duration(days: 2)),
        ),
      ],
    );
  }

  Future<void> _procesarFecha(String entrada) async {
    final DateTime? fecha = Validators.parsearFecha(entrada);

    if (fecha == null) {
      _agregarApp(
        'No logré entender esa fecha. Prueba con "hoy", "ayer" o 12/03.',
        esError: true,
      );
      return;
    }

    // Regla dura: nada del futuro.
    if (Validators.esFechaFutura(fecha)) {
      _agregarApp(
        'Ojo: esa fecha todavía no llega. No puedo registrar movimientos del '
        'futuro. ¿Qué día fue realmente?',
        esError: true,
        opciones: <String>['Hoy', 'Ayer'],
      );
      return;
    }

    state = state.copiarCon(fecha: fecha, paso: PasoChat.confirmar);
    _preguntarConfirmacion();
  }

  void _procesarEleccionObjetivo(String entrada) {
    final List<Objetivo> metas = _ref.read(objetivosProvider);
    final String t = entrada.toLowerCase();

    Objetivo? elegida;
    for (final Objetivo o in metas) {
      final String nombre = o.nombre.toLowerCase();
      if (nombre == t || (t.length >= 3 && nombre.contains(t))) {
        elegida = o;
        break;
      }
    }
    if (elegida == null && metas.length == 1) elegida = metas.first;

    if (elegida == null) {
      _agregarApp(
        'No identifiqué el objetivo. Elige uno:',
        opciones: metas.map((Objetivo o) => o.nombre).toList(),
        esError: true,
      );
      return;
    }

    _irAAbonoDirecto(elegida);
  }

  void _irAAbonoDirecto(Objetivo meta) {
    state = state.copiarCon(
      tipo: TipoMovimiento.ahorro,
      objetivoId: meta.id,
      descripcion: meta.descripcionAhorro,
      paso: PasoChat.monto,
      ahorroRestante: meta.restante,
    );
    _agregarApp(
      'Vas por "${meta.nombre}". Te faltan ${Formatters.moneda(meta.restante)}. '
      '¿Cuánto quieres abonar ahora?',
    );
  }

  void _preguntarConfirmacion() {
    final double monto = state.monto ?? 0;
    final bool esAhorro = state.tipo == TipoMovimiento.ahorro;

    final String detalle = esAhorro
        ? '· ${state.descripcion}\n'
            '· ${Formatters.moneda(monto)}\n'
            '· ${Formatters.fechaNumerica(state.fecha!)}'
        : '· ${state.tipo!.etiqueta}: ${state.descripcion}\n'
            '· ${Formatters.moneda(monto)}\n'
            '· ${Formatters.fechaNumerica(state.fecha!)}';

    _agregarApp(
      'Voy a guardar esto:\n$detalle\n\n¿Lo registro?',
      opciones: <String>['Sí, guarda', 'No, cancelar'],
    );
  }

  Future<void> _procesarConfirmacion(String entrada) async {
    final String t = entrada.toLowerCase();

    if (t.startsWith('no') || t.contains('cancel')) {
      _agregarApp('Listo, no lo guardé. ¿Quieres contarme otra cosa?',
          opciones: opcionesContinuar);
      state = state.copiarCon(paso: PasoChat.fin);
      return;
    }

    final bool afirma = t.startsWith('sí') ||
        t.startsWith('si') ||
        t.contains('guard') ||
        t.contains('registr') ||
        t.contains('dale') ||
        t.contains('ok');

    if (!afirma) {
      _agregarApp('¿Lo registro? Responde "sí" o "no".',
          opciones: <String>['Sí, guarda', 'No, cancelar']);
      return;
    }

    await _guardar();
  }

  // ────────────────────────── GUARDADO ──────────────────────────

  Future<void> _guardar() async {
    try {
      if (state.tipo == TipoMovimiento.ahorro && state.objetivoId != null) {
        // Regla de negocio: abonar actualiza el monto de la meta Y genera un
        // movimiento de salida con la descripción 'Ahorro para el "Nombre"'.
        final Transaccion abono =
            await _ref.read(objetivosProvider.notifier).abonar(
                  objetivoId: state.objetivoId!,
                  monto: state.monto!,
                  fecha: state.fecha!,
                );

        final Objetivo? actualizada =
            _ref.read(objetivoPorIdProvider(abono.objetivoId!));

        _agregarApp(
          'Anotado: ${abono.descripcion} por ${Formatters.moneda(abono.monto)}.\n'
          '${actualizada?.completado ?? false ? '¡Completaste tu objetivo! 🎉' : 'Te faltan ${Formatters.moneda(actualizada?.restante ?? 0)} para lograrlo.'}',
          opciones: opcionesContinuar,
        );
      } else {
        await _ref.read(transaccionesProvider.notifier).registrar(
              tipo: state.tipo!,
              descripcion: state.descripcion!,
              monto: state.monto!,
              fecha: state.fecha!,
            );
        _agregarApp(
          'Guardado: ${state.tipo!.etiqueta.toLowerCase()} de '
          '${Formatters.moneda(state.monto!)} — "${state.descripcion}".',
          opciones: opcionesContinuar,
        );
      }

      _ref.read(objetivoSeleccionadoProvider.notifier).state = null;
      state = state.copiarCon(paso: PasoChat.fin);
    } catch (e) {
      _agregarApp(
        e.toString()
            .replaceFirst('Invalid argument(s): ', '')
            .replaceFirst('Bad state: ', ''),
        esError: true,
      );
    }
  }

  /// Entra directo al flujo de ahorro para una meta concreta (desde el Home).
  void arrancarAbono(String objetivoId) {
    final Objetivo? meta = _ref.read(objetivoPorIdProvider(objetivoId));
    if (meta == null) return;

    state = state.copiarCon(
      tipo: TipoMovimiento.ahorro,
      objetivoId: meta.id,
      descripcion: meta.descripcionAhorro,
      paso: PasoChat.monto,
      ahorroRestante: meta.restante,
    );
    _agregarApp(
      'Vamos con "${meta.nombre}". Te faltan ${Formatters.moneda(meta.restante)}. '
      '¿Cuánto quieres abonar hoy?',
      opciones: <String>[
        if (meta.restante > 0) Formatters.moneda(meta.restante),
      ],
    );
  }

  // ────────────────────────── AUXILIARES ──────────────────────────

  void _agregarApp(
    String texto, {
    List<String>? opciones,
    bool esError = false,
  }) {
    state = state.copiarCon(
      mensajes: <Mensaje>[
        ...state.mensajes,
        Mensaje(
          texto: texto,
          deApp: true,
          hora: DateTime.now(),
          opciones: opciones,
          esError: esError,
        ),
      ],
    );
  }

  void _agregarUsuario(String texto) {
    state = state.copiarCon(
      mensajes: <Mensaje>[
        ...state.mensajes,
        Mensaje(texto: texto, deApp: false, hora: DateTime.now()),
      ],
    );
  }
}

/// Proveedor del chat. Se mantiene vivo mientras la app esté abierta.
final StateNotifierProvider<ChatNotifier, EstadoChat> chatProvider =
    StateNotifierProvider<ChatNotifier, EstadoChat>(
  ChatNotifier.new,
  name: 'chatProvider',
);
