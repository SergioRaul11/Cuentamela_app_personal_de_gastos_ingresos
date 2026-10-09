import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/usuario.dart';
import 'database_provider.dart';

/// Estado global del usuario.
///
/// Es sincrónico porque las cajas de Hive ya están abiertas antes de `runApp`:
/// la app nunca muestra un spinner para leer el nombre o el dinero inicial.
/// Se suscribe al `watch()` de la caja para reaccionar a cambios externos.
class UsuarioNotifier extends StateNotifier<Usuario?> {
  UsuarioNotifier(this._ref) : super(_ref.read(databaseProvider).leerUsuario()) {
    _suscripcion = _ref
        .read(databaseProvider)
        .escuchaUsuario
        .listen((_) => _recargar());
  }

  final Ref _ref;
  StreamSubscription<dynamic>? _suscripcion;

  void _recargar() {
    if (!mounted) return;
    state = _ref.read(databaseProvider).leerUsuario();
  }

  /// ¿Hay que mostrar el onboarding? Se comprueba en cada arranque.
  bool get necesitaOnboarding => !_ref.read(databaseProvider).onboardingCompletado;

  /// Guarda nombre y dinero inicial (solo la primera vez) y marca el
  /// onboarding como completado.
  Future<void> completarOnboarding({
    required String nombre,
    required double balanceInicial,
  }) async {
    final Usuario usuario = Usuario(
      nombre: nombre.trim(),
      balanceInicial: balanceInicial,
      creadoEn: DateTime.now(),
      onboardingCompletado: true,
    );
    await _ref.read(databaseProvider).guardarUsuario(usuario);
    state = usuario;
  }

  Future<void> actualizarNombre(String nombre) async {
    await _ref.read(databaseProvider).actualizarNombre(nombre);
    _recargar();
  }

  Future<void> actualizarBalanceInicial(double balance) async {
    await _ref.read(databaseProvider).actualizarBalanceInicial(balance);
    _recargar();
  }

  Future<void> alternarTema() async {
    final bool nuevo = !(state?.temaOscuro ?? false);
    await _ref.read(databaseProvider).actualizarTemaOscuro(nuevo);
    _recargar();
  }

  /// Borra todo. Vuelve al onboarding.
  Future<void> reiniciar() async {
    await _ref.read(databaseProvider).reiniciarTodo();
    _recargar();
  }

  @override
  void dispose() {
    _suscripcion?.cancel();
    super.dispose();
  }
}

final StateNotifierProvider<UsuarioNotifier, Usuario?> usuarioProvider =
    StateNotifierProvider<UsuarioNotifier, Usuario?>(
  UsuarioNotifier.new,
  name: 'usuarioProvider',
);

/// Atajos de lectura para las pantallas.
final Provider<String> nombreUsuarioProvider = Provider<String>(
  (Ref ref) => ref.watch(usuarioProvider)?.nombre ?? '',
);

final Provider<bool> onboardingCompletadoProvider = Provider<bool>(
  (Ref ref) => ref.watch(usuarioProvider)?.onboardingCompletado ?? false,
);

/// Tema activo, derivado de la preferencia guardada en Hive.
///
/// Al ser un proveedor derivado, conmutar el tema solo exige llamar a
/// `usuarioProvider.notifier.alternarTema()`: la interfaz se reconstruye sola
/// y la elección sobrevive al reinicio del teléfono.
final Provider<ThemeMode> modoTemaProvider = Provider<ThemeMode>(
  (Ref ref) {
    final Usuario? u = ref.watch(usuarioProvider);
    return (u?.temaOscuro ?? false) ? ThemeMode.dark : ThemeMode.light;
  },
  name: 'modoTemaProvider',
);
