/// Entidad de negocio pura: el usuario de **Cuéntamela**.
///
/// No conoce Hive, ni Flutter, ni Riverpod. Solo describe al usuario.
class Usuario {
  const Usuario({
    required this.nombre,
    required this.balanceInicial,
    required this.creadoEn,
    this.moneda = r'Bs',
    this.onboardingCompletado = true,
    this.temaOscuro = false,
  });

  /// Nombre completo tal como lo escribió el usuario.
  final String nombre;

  /// Dinero que el usuario declaró al empezar. Es la base sobre la que se
  /// suman los ingresos y se restan los gastos y los ahorros.
  final double balanceInicial;

  /// Fecha en la que se hizo el onboarding.
  final DateTime creadoEn;

  /// Símbolo de moneda usado en toda la app.
  final String moneda;

  /// `true` cuando ya se pidió nombre y dinero inicial (solo la primera vez).
  final bool onboardingCompletado;

  /// Preferencia de tema guardada en Hive, para que sobreviva al reinicio.
  final bool temaOscuro;

  /// Primer nombre, para los saludos y el chat.
  String get primerNombre {
    final List<String> partes = nombre.trim().split(RegExp(r'\s+'));
    if (partes.isEmpty || partes.first.isEmpty) return 'amig@';
    return partes.first;
  }

  /// Inicial para el avatar.
  String get inicial {
    final String limpio = nombre.trim();
    if (limpio.isEmpty) return 'C';
    return limpio.substring(0, 1).toUpperCase();
  }

  Usuario copyWith({
    String? nombre,
    double? balanceInicial,
    DateTime? creadoEn,
    String? moneda,
    bool? onboardingCompletado,
    bool? temaOscuro,
  }) {
    return Usuario(
      nombre: nombre ?? this.nombre,
      balanceInicial: balanceInicial ?? this.balanceInicial,
      creadoEn: creadoEn ?? this.creadoEn,
      moneda: moneda ?? this.moneda,
      onboardingCompletado: onboardingCompletado ?? this.onboardingCompletado,
      temaOscuro: temaOscuro ?? this.temaOscuro,
    );
  }
}
