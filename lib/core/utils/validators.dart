import 'formatters.dart';

/// Validadores de entrada.
///
/// Regla dura de la app: **no se registran fechas futuras**. La fecha del
/// movimiento nunca puede ser posterior al día actual del dispositivo.
class Validators {
  Validators._();

  static const String mensajeFechaObligatoria = 'Selecciona una fecha.';
  static const String mensajeFechaFutura =
      'Esa fecha todavía no ha pasado. Elige hoy o un día anterior.';
  static const String mensajeMontoInvalido =
      'Necesito un monto mayor que cero. Por ejemplo: 25,50';
  static const String mensajeMontoObligatorio = 'Escribe el monto.';
  static const String mensajeTextoObligatorio = 'Este campo no puede quedar vacío.';

  // ───────────────────────────── FECHAS ──────────────────────────────

  /// Última fecha permitida: hoy a medianoche (hora local del dispositivo).
  static DateTime fechaMaxima({DateTime? hoy}) =>
      Formatters.soloFecha(hoy ?? DateTime.now());

  /// Primera fecha razonable para el selector: hace 10 años.
  static DateTime fechaMinima({DateTime? hoy}) =>
      Formatters.soloFecha((hoy ?? DateTime.now())
          .subtract(const Duration(days: 365 * 10)));

  /// `true` si la fecha es posterior a hoy (comparando solo día, mes y año).
  static bool esFechaFutura(DateTime fecha, {DateTime? hoy}) {
    return Formatters.soloFecha(fecha)
        .isAfter(Formatters.soloFecha(hoy ?? DateTime.now()));
  }

  /// `null` si la fecha es válida; si no, el mensaje de error para la UI.
  static String? validarFecha(DateTime? fecha, {DateTime? hoy}) {
    if (fecha == null) return mensajeFechaObligatoria;
    if (esFechaFutura(fecha, hoy: hoy)) return mensajeFechaFutura;
    return null;
  }

  // ───────────────────────────── MONTOS ──────────────────────────────

  /// Acepta `1.234,56`, `1234.56`, `$1,234.56`, `25`, `25,5`.
  static double? parsearMonto(String entrada) {
    final String original = entrada.trim();
    final bool negativo = original.startsWith('-');

    // Se queda solo con dígitos y separadores.
    String t = original.replaceAll(RegExp(r'[^0-9.,]'), '');
    if (t.isEmpty) return null;

    final bool tieneComa = t.contains(',');
    final bool tienePunto = t.contains('.');

    if (tieneComa && tienePunto) {
      // El último separador que aparece es el decimal.
      t = t.lastIndexOf(',') > t.lastIndexOf('.')
          ? t.replaceAll('.', '').replaceAll(',', '.')
          : t.replaceAll(',', '');
    } else if (tieneComa) {
      final List<String> partes = t.split(',');
      t = partes.length > 2
          ? t.replaceAll(',', '') // 1,234,567 → miles
          : t.replaceAll(',', '.'); // 25,5 → decimal (convención es)
    } else if (tienePunto) {
      final List<String> partes = t.split('.');
      final bool pareceMiles = partes.length == 2 &&
          partes[1].length == 3 &&
          partes[0].isNotEmpty &&
          partes[0].length <= 3;
      if (partes.length > 2 || pareceMiles) {
        t = t.replaceAll('.', ''); // 1.500 → 1500
      }
    }

    final double? valor = double.tryParse(t);
    if (valor == null || !valor.isFinite) return null;
    return negativo ? -valor : valor;
  }

  static String? validarMonto(double? monto) {
    if (monto == null) return mensajeMontoObligatorio;
    if (monto <= 0) return mensajeMontoInvalido;
    return null;
  }

  // ───────────────────────────── TEXTO ───────────────────────────────

  static String? validarTexto(String? texto, {int minimo = 1, String? mensaje}) {
    final String limpio = (texto ?? '').trim();
    if (limpio.length < minimo) return mensaje ?? mensajeTextoObligatorio;
    return null;
  }

  // ──────────────────── FECHAS ESCRITAS A MANO ───────────────────────

  /// Entiende `hoy`, `ayer`, `anteayer`, `12/03/2026`, `12-3-26`, `12/03`,
  /// `2026-03-12` y `12 de marzo` / `12 de marzo de 2026`.
  ///
  /// Devuelve `null` si no logra interpretar la fecha (o si es imposible,
  /// como el 31 de febrero).
  static DateTime? parsearFecha(String entrada, {DateTime? hoy}) {
    final String t = entrada.trim().toLowerCase();
    if (t.isEmpty) return null;
    final DateTime base = hoy ?? DateTime.now();

    if (t.startsWith('hoy') || t == 'ahora' || t == 'today') {
      return Formatters.soloFecha(base);
    }
    if (t.startsWith('ayer')) {
      return Formatters.soloFecha(base.subtract(const Duration(days: 1)));
    }
    if (t.startsWith('anteayer') || t.startsWith('antes de ayer')) {
      return Formatters.soloFecha(base.subtract(const Duration(days: 2)));
    }

    // 2026-03-12
    final RegExpMatch? iso = RegExp(r'^(\d{4})-(\d{1,2})-(\d{1,2})$').firstMatch(t);
    if (iso != null) {
      return _construir(int.parse(iso[3]!), int.parse(iso[2]!), int.parse(iso[1]!));
    }

    // 12/03/2026 · 12-3-26 · 12.03.2026 · 12/03
    final RegExpMatch? numerica =
        RegExp(r'^(\d{1,2})[/\-.](\d{1,2})(?:[/\-.](\d{2,4}))?$').firstMatch(t);
    if (numerica != null) {
      int anio = base.year;
      final String? grupoAnio = numerica[3];
      if (grupoAnio != null) {
        anio = int.parse(grupoAnio);
        if (anio < 100) anio += 2000;
      }
      return _construir(
        int.parse(numerica[1]!),
        int.parse(numerica[2]!),
        anio,
      );
    }

    // 12 de marzo [de 2026]
    final RegExpMatch? textual = RegExp(
      r'^(\d{1,2})\s*(?:de\s*)?([a-záéíóúñ]+)(?:\s*(?:de\s*)?(\d{4}))?$',
    ).firstMatch(t);
    if (textual != null) {
      final int? mes = Formatters.mesDesdeNombre(textual[2]!);
      if (mes == null) return null;
      final String? grupoAnio = textual[3];
      return _construir(
        int.parse(textual[1]!),
        mes,
        grupoAnio != null ? int.parse(grupoAnio) : base.year,
      );
    }

    return null;
  }

  /// Construye la fecha y descarta días inexistentes (31/02 → null).
  static DateTime? _construir(int dia, int mes, int anio) {
    if (mes < 1 || mes > 12 || dia < 1 || dia > 31) return null;
    if (anio < 1900 || anio > 2200) return null;
    final DateTime fecha = DateTime(anio, mes, dia);
    if (fecha.day != dia || fecha.month != mes || fecha.year != anio) return null;
    return fecha;
  }
}
