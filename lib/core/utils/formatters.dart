/// Formateadores de presentación.
///
/// Se escriben a mano (sin `intl`) para que el formato sea **idéntico** en
/// cualquier versión de Flutter y en cualquier dispositivo, y para no añadir
/// dependencias: la app solo necesita pesos, `dd/mm/aaaa` y horas.
library;

class Formatters {
  Formatters._();

  static const String simboloMoneda = r'Bs';

  static const List<String> mesesCortos = <String>[
    'ene',
    'feb',
    'mar',
    'abr',
    'may',
    'jun',
    'jul',
    'ago',
    'sep',
    'oct',
    'nov',
    'dic',
  ];

  static const List<String> mesesLargos = <String>[
    'enero',
    'febrero',
    'marzo',
    'abril',
    'mayo',
    'junio',
    'julio',
    'agosto',
    'septiembre',
    'octubre',
    'noviembre',
    'diciembre',
  ];

  static const List<String> diasLargos = <String>[
    'lunes',
    'martes',
    'miércoles',
    'jueves',
    'viernes',
    'sábado',
    'domingo',
  ];

  // ────────────────────────────── DINERO ──────────────────────────────

  /// `1234.5` → `$1.234,50`
  ///
  /// Convención: punto para miles, coma para decimales (es-ES / es-MX).
  static String moneda(
    double valor, {
    bool conSigno = false,
    bool compacto = false,
    String simbolo = simboloMoneda,
  }) {
    final bool negativo = valor < 0;
    final double absoluto = valor.abs();

    if (compacto && absoluto >= 1000000) {
      final double millones = absoluto / 1000000;
      final String n = millones >= 10
          ? millones.toStringAsFixed(0)
          : millones.toStringAsFixed(1).replaceAll('.', ',');
      return '${negativo ? '-' : (conSigno ? '+' : '')}$simbolo${n}M';
    }
    if (compacto && absoluto >= 10000) {
      final double miles = absoluto / 1000;
      final String n = miles >= 100
          ? miles.toStringAsFixed(0)
          : miles.toStringAsFixed(1).replaceAll('.', ',');
      return '${negativo ? '-' : (conSigno ? '+' : '')}$simbolo${n}k';
    }

    final List<String> partes = absoluto.toStringAsFixed(2).split('.');
    final String entero = _miles(partes.first);
    final String centavos = partes.length > 1 ? partes[1] : '00';
    final String signo = negativo ? '−' : (conSigno ? '+' : '');
    return '$signo$simbolo$entero,$centavos';
  }

  /// `1234567` → `1.234.567`
  static String _miles(String digitos) {
    final StringBuffer salida = StringBuffer();
    for (int i = 0; i < digitos.length; i++) {
      final int restantes = digitos.length - i;
      salida.write(digitos[i]);
      if (restantes > 1 && restantes % 3 == 1) salida.write('.');
    }
    return salida.toString();
  }

  /// `0.4231` → `42 %`
  static String porcentaje(double fraccion, {int decimales = 0}) {
    final double valor = (fraccion.isFinite ? fraccion : 0) * 100;
    return '${valor.clamp(0, 999).toStringAsFixed(decimales).replaceAll('.', ',')} %';
  }

  // ────────────────────────────── FECHAS ──────────────────────────────

  static bool mismoDia(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  static DateTime soloFecha(DateTime d) => DateTime(d.year, d.month, d.day);

  /// `Hoy`, `Ayer`, `12 mar` o `12 mar 2025` si es de otro año.
  static String fechaCorta(DateTime fecha, {DateTime? hoy}) {
    final DateTime base = hoy ?? DateTime.now();
    if (mismoDia(fecha, base)) return 'Hoy';
    if (mismoDia(fecha, base.subtract(const Duration(days: 1)))) return 'Ayer';
    final String dia = '${fecha.day} ${mesesCortos[fecha.month - 1]}';
    return fecha.year == base.year ? dia : '$dia ${fecha.year}';
  }

  /// `martes, 12 de marzo de 2026`
  static String fechaLarga(DateTime fecha) =>
      '${diasLargos[fecha.weekday - 1]}, ${fecha.day} de '
      '${mesesLargos[fecha.month - 1]} de ${fecha.year}';

  /// `12/03/2026`
  static String fechaNumerica(DateTime f) =>
      '${_dos(f.day)}/${_dos(f.month)}/${f.year}';

  /// `14:05`
  static String hora(DateTime f) => '${_dos(f.hour)}:${_dos(f.minute)}';

  static String _dos(int n) => n.toString().padLeft(2, '0');

  /// Saludo según la hora del dispositivo. Se usa en Home.
  static String saludo({DateTime? ahora}) {
    final int h = (ahora ?? DateTime.now()).hour;
    if (h < 12) return 'Buenos días';
    if (h < 20) return 'Buenas tardes';
    return 'Buenas noches';
  }

  /// Devuelve el número de mes (1-12) a partir de un nombre, aceptando
  /// abreviaturas (`ene`, `sept`, `sep`) y acentos ausentes.
  static int? mesDesdeNombre(String nombre) {
    final String n = nombre
        .toLowerCase()
        .replaceAll('á', 'a')
        .replaceAll('é', 'e')
        .replaceAll('í', 'i')
        .replaceAll('ó', 'o')
        .replaceAll('ú', 'u')
        .trim();
    if (n.length < 3) return null;
    final String prefijo = n.substring(0, 3);
    for (int i = 0; i < mesesLargos.length; i++) {
      final String candidato = mesesLargos[i]
          .replaceAll('á', 'a')
          .replaceAll('é', 'e')
          .replaceAll('í', 'i')
          .replaceAll('ó', 'o')
          .replaceAll('ú', 'u');
      if (candidato.startsWith(prefijo)) return i + 1;
    }
    return null;
  }
}
