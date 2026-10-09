import 'package:hive/hive.dart';

import '../../domain/entities/usuario.dart';

part 'usuario_model.g.dart';

/// Modelo de persistencia del usuario.
///
/// Hive guarda la caja `userBox` con **un solo registro** bajo la clave
/// [UsuarioModel.claveUnica].
@HiveType(typeId: 0)
class UsuarioModel {
  const UsuarioModel({
    required this.nombre,
    required this.balanceInicial,
    required this.creadoEn,
    required this.moneda,
    required this.onboardingCompletado,
    required this.temaOscuro,
  });

  /// Clave fija: siempre hay un único usuario en el dispositivo.
  static const String claveUnica = 'usuario_actual';

  @HiveField(0)
  final String nombre;

  @HiveField(1)
  final double balanceInicial;

  @HiveField(2)
  final DateTime creadoEn;

  @HiveField(3)
  final String moneda;

  @HiveField(4)
  final bool onboardingCompletado;

  @HiveField(5)
  final bool temaOscuro;

  // ─────────────────── Mapeo modelo ⇄ entidad ───────────────────

  factory UsuarioModel.desdeEntidad(Usuario u) => UsuarioModel(
        nombre: u.nombre,
        balanceInicial: u.balanceInicial,
        creadoEn: u.creadoEn,
        moneda: u.moneda,
        onboardingCompletado: u.onboardingCompletado,
        temaOscuro: u.temaOscuro,
      );

  Usuario aEntidad() => Usuario(
        nombre: nombre,
        balanceInicial: balanceInicial,
        creadoEn: creadoEn,
        moneda: moneda,
        onboardingCompletado: onboardingCompletado,
        temaOscuro: temaOscuro,
      );
}
