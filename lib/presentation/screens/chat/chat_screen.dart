import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/utils/formatters.dart';
import '../../../domain/entities/resumen_financiero.dart';
import '../../providers/resumen_provider.dart';
import '../../widgets/burbuja_chat.dart';
import 'chat_controller.dart';

/// Pestaña **Cuéntamela**: el registro conversacional.
///
/// La app lleva la conversación paso a paso (tipo → descripción → monto →
/// fecha → confirmación) y avisa dentro del propio chat cuando la fecha es
/// futura, sin dejar registrar el movimiento.
class ChatScreen extends ConsumerStatefulWidget {
  const ChatScreen({super.key});

  @override
  ConsumerState<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends ConsumerState<ChatScreen> {
  final TextEditingController _entrada = TextEditingController();
  final ScrollController _scroll = ScrollController();
  final FocusNode _foco = FocusNode();

  @override
  void initState() {
    super.initState();
    // El chat se inicializa una sola vez: el IndexedStack conserva su estado.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (ref.read(chatProvider).mensajes.isEmpty) {
        ref.read(chatProvider.notifier).iniciar();
      }
    });
  }

  @override
  void dispose() {
    _entrada.dispose();
    _scroll.dispose();
    _foco.dispose();
    super.dispose();
  }

  void _bajar() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scroll.hasClients) return;
      _scroll.animateTo(
        _scroll.position.maxScrollExtent + 120,
        duration: const Duration(milliseconds: 260),
        curve: Curves.easeOut,
      );
    });
  }

  Future<void> _enviar(String texto) async {
    if (texto.trim().isEmpty) return;
    _entrada.clear();
    await ref.read(chatProvider.notifier).responder(texto);
    _bajar();
  }

  @override
  Widget build(BuildContext context) {
    final EstadoChat estado = ref.watch(chatProvider);
    final ResumenFinanciero resumen = ref.watch(resumenProvider);

    // Última tanda de opciones rápidas ofrecidas por la app.
    List<String>? opciones;
    for (int i = estado.mensajes.length - 1; i >= 0; i--) {
      final Mensaje m = estado.mensajes[i];
      if (m.deApp && m.opciones != null && m.opciones!.isNotEmpty) {
        opciones = m.opciones;
        break;
      }
    }

    return Scaffold(
      appBar: AppBar(
        titleSpacing: AppEspacios.m,
        title: Row(
          children: <Widget>[
            Container(
              height: 38,
              width: 38,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: <Color>[Color(0xFF00A97F), Color(0xFF4FD9B1)],
                ),
                borderRadius: BorderRadius.circular(AppRadii.xs + 2),
              ),
              child: const Icon(
                Icons.auto_awesome_rounded,
                size: 19,
                color: Colors.white,
              ),
            ),
            const SizedBox(width: AppEspacios.s + 2),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Text(
                    'Cuéntamela',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  Text(
                    'Disponible: '
                    '${Formatters.moneda(resumen.balanceActual, compacto: true)}',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          fontSize: 11.5,
                          color: context.colorTextoSuave,
                        ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      body: Column(
        children: <Widget>[
          Expanded(
            child: ListView(
              controller: _scroll,
              padding: const EdgeInsets.fromLTRB(
                AppEspacios.m,
                AppEspacios.m,
                AppEspacios.m,
                AppEspacios.s,
              ),
              children: <Widget>[
                if (estado.mensajes.isEmpty)
                  const Padding(
                    padding: EdgeInsets.only(top: 40),
                    child: BurbujaEscribiendo(),
                  ),
                for (final Mensaje m in estado.mensajes)
                  BurbujaChat(
                    texto: m.texto,
                    autor: m.deApp ? AutorMensaje.app : AutorMensaje.usuario,
                    hora: Formatters.hora(m.hora),
                    widgetExtra: m.esError
                        ? const AvisoChat(
                            mensaje: 'Revisa este dato antes de seguir.',
                          )
                        : null,
                  ),
              ],
            ),
          ),

          // Respuestas rápidas del paso actual.
          if (opciones != null)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(
                AppEspacios.m,
                AppEspacios.s,
                AppEspacios.m,
                AppEspacios.s,
              ),
              child: OpcionesRapidas(
                opciones: opciones,
                onSeleccion: (String opcion) {
                  ref.read(chatProvider.notifier).elegirOpcion(opcion);
                  _bajar();
                },
              ),
            ),

          _BarraEscritura(
            controller: _entrada,
            foco: _foco,
            placeholder: estado.placeholder,
            onEnviar: _enviar,
          ),
        ],
      ),
    );
  }
}

/// Campo de escritura con botón de envío.
class _BarraEscritura extends StatelessWidget {
  const _BarraEscritura({
    required this.controller,
    required this.foco,
    required this.placeholder,
    required this.onEnviar,
  });

  final TextEditingController controller;
  final FocusNode foco;
  final String placeholder;
  final ValueChanged<String> onEnviar;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(
        AppEspacios.m,
        AppEspacios.s,
        AppEspacios.m,
        AppEspacios.s,
      ),
      decoration: BoxDecoration(
        color: context.colorSuperficie,
        border: Border(top: BorderSide(color: context.colorBorde)),
      ),
      child: SafeArea(
        top: false,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: <Widget>[
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: context.esOscuro
                      ? Colors.white.withOpacity(0.05)
                      : const Color(0xFFF3F5F8),
                  borderRadius: BorderRadius.circular(AppRadii.m),
                  border: Border.all(color: context.colorBorde),
                ),
                child: TextField(
                  controller: controller,
                  focusNode: foco,
                  maxLines: 4,
                  minLines: 1,
                  textCapitalization: TextCapitalization.sentences,
                  textInputAction: TextInputAction.send,
                  onSubmitted: onEnviar,
                  cursorColor: context.colorMarca,
                  style: Theme.of(context)
                      .textTheme
                      .bodyLarge
                      ?.copyWith(fontSize: 15.5),
                  decoration: InputDecoration(
                    hintText: placeholder,
                    hintStyle:
                        Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: context.colorTextoSuave.withOpacity(0.8),
                              fontSize: 14.5,
                            ),
                    border: InputBorder.none,
                    isDense: true,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: AppEspacios.m,
                      vertical: 14,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: AppEspacios.s),
            ValueListenableBuilder<TextEditingValue>(
              valueListenable: controller,
              builder: (
                BuildContext context,
                TextEditingValue valor,
                Widget? _,
              ) {
                final bool activo = valor.text.trim().isNotEmpty;
                return SizedBox(
                  height: 48,
                  width: 48,
                  child: Material(
                    color: activo ? context.colorMarca : context.colorBorde,
                    borderRadius: BorderRadius.circular(AppRadii.m),
                    clipBehavior: Clip.antiAlias,
                    child: InkWell(
                      onTap: activo ? () => onEnviar(controller.text) : null,
                      child: Icon(
                        Icons.send_rounded,
                        size: 20,
                        color: activo ? Colors.white : context.colorTextoSuave,
                      ),
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
