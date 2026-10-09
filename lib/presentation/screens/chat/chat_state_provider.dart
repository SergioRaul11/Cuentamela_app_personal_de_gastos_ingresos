import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../domain/entities/objetivo.dart';
import '../../providers/objetivos_provider.dart';

/// Objetivo en el que el usuario quiere abonar ahora mismo.
///
/// El Home escribe aquí (y salta al chat) cuando se pulsa "Abonar" en una
/// tarjeta de meta: al abrir el chat, el flujo arranca directamente en el
/// paso de ahorro con esa meta ya elegida.
final StateProvider<String?> objetivoSeleccionadoProvider =
    StateProvider<String?>((Ref ref) => null, name: 'objetivoSeleccionadoProvider');

/// Meta elegida, resuelta a entidad para los mensajes del chat.
final Provider<Objetivo?> objetivoPendienteProvider =
    Provider<Objetivo?>((Ref ref) {
  final String? id = ref.watch(objetivoSeleccionadoProvider);
  if (id == null) return null;
  return ref.watch(objetivoPorIdProvider(id));
}, name: 'objetivoPendienteProvider');
