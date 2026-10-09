import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/objetivo.dart';
import '../../domain/entities/resumen_financiero.dart';
import '../../domain/entities/transaccion.dart';
import '../../domain/entities/usuario.dart';
import 'objetivos_provider.dart';
import 'transacciones_provider.dart';
import 'usuario_provider.dart';

/// Totales de la pantalla principal.
///
/// Se recalcula solo cuando cambia el usuario, la lista de movimientos o las
/// metas: al ser un `Provider` derivado, cualquier escritura en Hive ya
/// dispara la reconstrucción de las tarjetas.
final Provider<ResumenFinanciero> resumenProvider = Provider<ResumenFinanciero>(
  (Ref ref) {
    final Usuario? usuario = ref.watch(usuarioProvider);
    final List<Transaccion> transacciones = ref.watch(transaccionesProvider);
    final List<Objetivo> objetivos = ref.watch(objetivosProvider);

    return ResumenFinanciero.calcular(
      usuario: usuario,
      transacciones: transacciones,
      objetivos: objetivos,
    );
  },
  name: 'resumenProvider',
);

/// Agrupa los movimientos por día para la lista cronológica del Home.
/// El mapa conserva el orden de inserción: más reciente primero.
final Provider<Map<String, List<Transaccion>>> movimientosAgrupadosProvider =
    Provider<Map<String, List<Transaccion>>>(
  (Ref ref) {
    final List<Transaccion> todas = ref.watch(transaccionesProvider);
    final Map<String, List<Transaccion>> agrupado =
        <String, List<Transaccion>>{};

    for (final Transaccion t in todas) {
      // Clave con mes y día de dos cifras para poder reconstruir la fecha
      // con DateTime.parse sin sorpresas ('2026-10-07').
      final String clave = '${t.fecha.year}-'
          '${t.fecha.month.toString().padLeft(2, '0')}-'
          '${t.fecha.day.toString().padLeft(2, '0')}';
      agrupado.putIfAbsent(clave, () => <Transaccion>[]).add(t);
    }
    return agrupado;
  },
  name: 'movimientosAgrupadosProvider',
);
