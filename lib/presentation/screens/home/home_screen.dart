import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/utils/formatters.dart';
import '../../../domain/entities/objetivo.dart';
import '../../../domain/entities/resumen_financiero.dart';
import '../../../domain/entities/transaccion.dart';
import '../../../domain/entities/usuario.dart';
import '../../providers/navegacion_provider.dart';
import '../../providers/objetivos_provider.dart';
import '../../providers/resumen_provider.dart';
import '../../providers/transacciones_provider.dart';
import '../../providers/usuario_provider.dart';
import '../../widgets/item_movimiento.dart';
import '../../widgets/tarjeta_balance.dart';
import '../../widgets/tarjeta_objetivo.dart';
import '../../widgets/tarjeta_resumen.dart';
import '../chat/chat_state_provider.dart';
import 'crear_objetivo_sheet.dart';

/// Pantalla principal.
///
/// De arriba abajo: saludo + dinero disponible, fila de totales (ingresos,
/// gastos y ahorrado), objetivos con su barra de progreso y la lista
/// cronológica de movimientos.
class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final Usuario? usuario = ref.watch(usuarioProvider);
    final ResumenFinanciero resumen = ref.watch(resumenProvider);
    final List<Objetivo> objetivos = ref.watch(objetivosProvider);
    final List<Transaccion> movimientos = ref.watch(transaccionesProvider);
    final Map<String, List<Transaccion>> agrupados =
        ref.watch(movimientosAgrupadosProvider);

    void irAlChat() =>
        ref.read(pestanaActualProvider.notifier).state = Pestanas.chat;

    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: RefreshIndicator(
          color: context.colorMarca,
          onRefresh: () async {
            await Future<void>.delayed(const Duration(milliseconds: 350));
          },
          child: CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: <Widget>[
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(
                  AppEspacios.m,
                  AppEspacios.s,
                  AppEspacios.m,
                  0,
                ),
                sliver: SliverToBoxAdapter(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      // ──────────────── Saludo ────────────────
                      Row(
                        children: <Widget>[
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Text(
                                  Formatters.saludo(),
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodySmall
                                      ?.copyWith(fontSize: 12.5),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  usuario?.primerNombre ?? 'amig@',
                                  style:
                                      Theme.of(context).textTheme.headlineSmall,
                                ),
                              ],
                            ),
                          ),
                          const BotonTema(),
                        ],
                      ),
                      const SizedBox(height: AppEspacios.m),

                      // ──────────── Dinero disponible ────────────
                      TarjetaBalance(
                        balance: resumen.balanceActual,
                        etiqueta: 'Tu dinero disponible',
                        nombre: Formatters.fechaLarga(DateTime.now()),
                        subtitulo: resumen.totalEnMetas > 0
                            ? 'Tienes ${Formatters.moneda(resumen.totalEnMetas)} '
                                'guardados en tus objetivos'
                            : 'Cuéntame tu primer movimiento en el chat',
                      ),
                      const SizedBox(height: AppEspacios.m),

                      // ────────────── Totales ──────────────
                      FilaTotales(
                        hijos: <Widget>[
                          TarjetaResumen(
                            titulo: 'Ingresos',
                            valor: Formatters.moneda(
                              resumen.totalIngresos,
                              compacto: true,
                            ),
                            icono: Icons.arrow_downward_rounded,
                            color: ColoresResumen.ingresos,
                            pie:
                                '${ref.watch(ingresosProvider).length} registros',
                          ),
                          TarjetaResumen(
                            titulo: 'Gastos',
                            valor: Formatters.moneda(
                              resumen.totalGastos,
                              compacto: true,
                            ),
                            icono: Icons.arrow_upward_rounded,
                            color: ColoresResumen.gastos,
                            pie: '${ref.watch(gastosProvider).length} registros',
                          ),
                          TarjetaResumen(
                            titulo: 'Ahorrado',
                            valor: Formatters.moneda(
                              resumen.totalAhorrado,
                              compacto: true,
                            ),
                            icono: Icons.savings_rounded,
                            color: ColoresResumen.ahorro,
                            pie: '${ref.watch(ahorrosProvider).length} abonos',
                          ),
                        ],
                      ),
                      const SizedBox(height: AppEspacios.g),

                      // ────────────── Objetivos ──────────────
                      TituloSeccion(
                        titulo: 'Tus objetivos',
                        accion:
                            ref.watch(cuposObjetivoProvider) > 0 ? 'Agregar' : null,
                        onAccion: () => mostrarHojaCrearObjetivo(context, ref),
                      ),
                      if (objetivos.isEmpty)
                        ObjetivoVacio(
                          onCrear: () => mostrarHojaCrearObjetivo(context, ref),
                        )
                      else
                        ...objetivos.map(
                          (Objetivo o) => Padding(
                            padding:
                                const EdgeInsets.only(bottom: AppEspacios.s),
                            child: TarjetaObjetivo(
                              objetivo: o,
                              onAbonar: () => _abonar(context, ref, o),
                            ),
                          ),
                        ),
                      const SizedBox(height: AppEspacios.m),

                      // ─────────────── Lista ───────────────
                      TituloSeccion(
                        titulo: 'Movimientos',
                        accion: movimientos.isEmpty ? null : 'Ver chat',
                        onAccion: irAlChat,
                      ),
                    ],
                  ),
                ),
              ),

              if (movimientos.isEmpty)
                SliverToBoxAdapter(child: ListaVacia(onIrAlChat: irAlChat))
              else
                SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (BuildContext context, int indice) {
                      final MapEntry<String, List<Transaccion>> grupo =
                          agrupados.entries.elementAt(indice);
                      final List<Transaccion> delDia = grupo.value;
                      final double netoDelDia = delDia.fold<double>(
                        0,
                        (double a, Transaccion t) => a + t.impacto,
                      );

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          CabeceraDia(
                            fecha: DateTime.parse(grupo.key),
                            totalDelDia: netoDelDia,
                          ),
                          Container(
                            margin: const EdgeInsets.symmetric(
                              horizontal: AppEspacios.m,
                            ),
                            decoration: BoxDecoration(
                              color: context.colorSuperficie,
                              borderRadius: AppRadii.tarjeta,
                              border: Border.all(color: context.colorBorde),
                            ),
                            child: Column(
                              children: <Widget>[
                                for (int i = 0; i < delDia.length; i++) ...<Widget>[
                                  ItemMovimiento(
                                    transaccion: delDia[i],
                                    ocultarFecha: true,
                                    onEliminar: () =>
                                        _confirmarBorrado(context, ref, delDia[i]),
                                  ),
                                  if (i != delDia.length - 1)
                                    Divider(
                                      height: 1,
                                      thickness: 1,
                                      indent: 58,
                                      color: context.colorBorde,
                                    ),
                                ],
                              ],
                            ),
                          ),
                          if (indice == agrupados.length - 1)
                            const SizedBox(height: AppEspacios.xl),
                        ],
                      );
                    },
                    childCount: agrupados.length,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  /// Abonar desde el Home: fija la meta y salta al chat, que arranca
  /// directamente en el paso de ahorro.
  void _abonar(BuildContext context, WidgetRef ref, Objetivo objetivo) {
    ref.read(objetivoSeleccionadoProvider.notifier).state = objetivo.id;
    ref.read(pestanaActualProvider.notifier).state = Pestanas.chat;
  }

  Future<void> _confirmarBorrado(
    BuildContext context,
    WidgetRef ref,
    Transaccion t,
  ) async {
    final bool? borrar = await showDialog<bool>(
      context: context,
      builder: (BuildContext ctx) => AlertDialog(
        backgroundColor: ctx.colorSuperficie,
        shape: RoundedRectangleBorder(borderRadius: AppRadii.tarjeta),
        title: const Text('¿Eliminar movimiento?'),
        content: Text(
          'Se quitará "${t.descripcion}" de tu lista.'
          '${t.tipo == TipoMovimiento.ahorro ? ' El abono se devolverá a tu objetivo.' : ''}',
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text(
              'Eliminar',
              style: TextStyle(color: AppColors.gasto),
            ),
          ),
        ],
      ),
    );

    if (borrar == true) {
      await ref.read(transaccionesProvider.notifier).eliminar(t.id);
    }
  }
}

/// Botón de modo claro / oscuro, persistido en Hive.
class BotonTema extends ConsumerWidget {
  const BotonTema({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bool oscuro = context.esOscuro;

    return Material(
      color: context.colorSuperficie,
      shape: CircleBorder(side: BorderSide(color: context.colorBorde)),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () async {
          await ref.read(usuarioProvider.notifier).alternarTema();
        },
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Icon(
            oscuro ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
            size: 18,
            color: context.colorTextoSuave,
          ),
        ),
      ),
    );
  }
}
