import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/theme/iconos_meta.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/utils/validators.dart';
import '../../../domain/entities/objetivo.dart';
import '../../../domain/entities/usuario.dart';
import '../../providers/objetivos_provider.dart';
import '../../providers/resumen_provider.dart';
import '../../providers/usuario_provider.dart';
import '../../widgets/boton_principal.dart';
import '../../widgets/campo_texto.dart';
import '../../widgets/encabezado_seccion.dart';
import '../../widgets/tarjeta_objetivo.dart';
import '../home/crear_objetivo_sheet.dart';

/// Pestaña **Perfil**.
///
/// Editar nombre, editar el balance actual, gestionar los objetivos de compra
/// (crear hasta 3, editar precio y eliminar) y preferencias de tema.
class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final Usuario? usuario = ref.watch(usuarioProvider);
    final List<Objetivo> objetivos = ref.watch(objetivosProvider);
    final int cupos = ref.watch(cuposObjetivoProvider);

    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(
            AppEspacios.m,
            AppEspacios.m,
            AppEspacios.m,
            AppEspacios.xl,
          ),
          children: <Widget>[
            _CabeceraPerfil(usuario: usuario),
            const SizedBox(height: AppEspacios.g),

            // ──────────────────── Cuenta ────────────────────
            const EncabezadoSeccion(
              titulo: 'Tu cuenta',
              icono: Icons.badge_outlined,
            ),
            _FilaAjuste(
              icono: Icons.person_outline_rounded,
              titulo: 'Nombre',
              valor: usuario?.nombre ?? '—',
              onTap: () => _editarNombre(context, ref, usuario),
            ),
            const SizedBox(height: AppEspacios.s),
            _FilaAjuste(
              icono: Icons.account_balance_wallet_outlined,
              titulo: 'Balance actual',
              valor: Formatters.moneda(
                ref.watch(resumenProvider).balanceActual,
              ),
              onTap: () => _editarBalance(context, ref),
            ),
            const SizedBox(height: AppEspacios.s),
            _FilaAjuste(
              icono: Icons.event_available_rounded,
              titulo: 'Conmigo desde',
              valor: usuario == null
                  ? '—'
                  : Formatters.fechaLarga(usuario.creadoEn),
            ),

            const SizedBox(height: AppEspacios.g),

            // ─────────────────── Objetivos ───────────────────
            EncabezadoSeccion(
              titulo: 'Objetivos de compra',
              icono: Icons.savings_outlined,
              descripcion: objetivos.isEmpty
                  ? 'Puedes tener hasta 3 metas de ahorro.'
                  : 'Tienes ${objetivos.length} de 3 metas activas.',
            ),
            if (objetivos.isEmpty)
              ObjetivoVacio(
                onCrear: () => mostrarHojaCrearObjetivo(context, ref),
              )
            else
              ...objetivos.map(
                (Objetivo o) => Padding(
                  padding: const EdgeInsets.only(bottom: AppEspacios.s),
                  child: TarjetaObjetivo(
                    objetivo: o,
                    onTap: () => _opcionesObjetivo(context, ref, o),
                  ),
                ),
              ),
            if (cupos > 0) ...<Widget>[
              const SizedBox(height: AppEspacios.s),
              BotonPrincipal(
                texto: 'Agregar objetivo (te quedan $cupos)',
                icono: Icons.add_rounded,
                secundario: true,
                alto: 50,
                onPressed: () => mostrarHojaCrearObjetivo(context, ref),
              ),
            ],

            const SizedBox(height: AppEspacios.g),

            // ─────────────────── Ajustes ────────────────────
            const EncabezadoSeccion(
              titulo: 'Ajustes',
              icono: Icons.tune_rounded,
            ),
            _FilaAjuste(
              icono: context.esOscuro
                  ? Icons.light_mode_outlined
                  : Icons.dark_mode_outlined,
              titulo: 'Modo oscuro',
              valor: context.esOscuro ? 'Activado' : 'Desactivado',
              onTap: () async {
                await ref.read(usuarioProvider.notifier).alternarTema();
              },
            ),
            const SizedBox(height: AppEspacios.s),
            _FilaAjuste(
              icono: Icons.restart_alt_rounded,
              titulo: 'Empezar de cero',
              valor: 'Borra tus movimientos y metas',
              colorValor: AppColors.gasto,
              onTap: () => _confirmarReinicio(context, ref),
            ),
            const SizedBox(height: AppEspacios.l),
            Center(
              child: Text(
                'Cuéntamela · tus datos se guardan solo en tu teléfono solo ahi',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      fontSize: 11.5,
                    ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─────────────────────────── EDICIÓN ───────────────────────────

  Future<void> _editarNombre(
    BuildContext context,
    WidgetRef ref,
    Usuario? usuario,
  ) async {
    final TextEditingController controlador =
        TextEditingController(text: usuario?.nombre ?? '');
    String? error;

    await showDialog<void>(
      context: context,
      builder: (BuildContext ctx) => StatefulBuilder(
        builder: (BuildContext ctx, StateSetter setEstado) {
          return AlertDialog(
            backgroundColor: ctx.colorSuperficie,
            shape: RoundedRectangleBorder(borderRadius: AppRadii.tarjeta),
            title: const Text('Tu nombre'),
            content: CampoTexto(
              controller: controlador,
              etiqueta: 'Nombre',
              error: error,
              autofocus: true,
              formateadores: FiltrosEntrada.nombre,
            ),
            actions: <Widget>[
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('Cancelar'),
              ),
              TextButton(
                onPressed: () async {
                  final String? err = Validators.validarTexto(
                    controlador.text,
                    minimo: 2,
                    mensaje: 'Escribe al menos 2 letras.',
                  );
                  if (err != null) {
                    setEstado(() => error = err);
                    return;
                  }
                  await ref
                      .read(usuarioProvider.notifier)
                      .actualizarNombre(controlador.text);
                  if (ctx.mounted) Navigator.pop(ctx);
                },
                child: const Text('Guardar'),
              ),
            ],
          );
        },
      ),
    );
    controlador.dispose();
  }

  Future<void> _editarBalance(BuildContext context, WidgetRef ref) async {
    final ResumenActual resumen = ResumenActual(
      valor: ref.read(resumenProvider).balanceActual,
    );
    final TextEditingController controlador = TextEditingController(
      text: resumen.valor.toStringAsFixed(2).replaceAll('.', ','),
    );
    String? error;

    await showDialog<void>(
      context: context,
      builder: (BuildContext ctx) => StatefulBuilder(
        builder: (BuildContext ctx, StateSetter setEstado) {
          return AlertDialog(
            backgroundColor: ctx.colorSuperficie,
            shape: RoundedRectangleBorder(borderRadius: AppRadii.tarjeta),
            title: const Text('Balance actual'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  'Ajusta cuánto dinero tienes disponible hoy. Sirve para '
                  'corregir el punto de partida; no borra tus movimientos.',
                  style: Theme.of(ctx).textTheme.bodySmall,
                ),
                const SizedBox(height: AppEspacios.m),
                CampoTexto(
                  controller: controlador,
                  etiqueta: 'Dinero disponible',
                  hint: '0,00',
                  tipoTeclado:
                      const TextInputType.numberWithOptions(decimal: true),
                  formateadores: FiltrosEntrada.monto,
                  error: error,
                  autofocus: true,
                ),
              ],
            ),
            actions: <Widget>[
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('Cancelar'),
              ),
              TextButton(
                onPressed: () async {
                  final double? monto =
                      Validators.parsearMonto(controlador.text);
                  if (monto == null) {
                    setEstado(() => error = Validators.mensajeMontoInvalido);
                    return;
                  }
                  // El balance inicial se recalcula para que el total mostrado
                  // sea exactamente el que escribió el usuario.
                  final double movimientos =
                      ref.read(resumenProvider).totalIngresos -
                          ref.read(resumenProvider).totalSalidas;
                  await ref
                      .read(usuarioProvider.notifier)
                      .actualizarBalanceInicial(monto - movimientos);
                  if (ctx.mounted) Navigator.pop(ctx);
                },
                child: const Text('Guardar'),
              ),
            ],
          );
        },
      ),
    );
    controlador.dispose();
  }

  Future<void> _opcionesObjetivo(
    BuildContext context,
    WidgetRef ref,
    Objetivo objetivo,
  ) async {
    await showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (BuildContext ctx) => Container(
        decoration: BoxDecoration(
          color: ctx.colorFondo,
          borderRadius: AppRadii.hoja,
        ),
        child: SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.all(AppEspacios.m),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Container(
                  height: 4,
                  width: 40,
                  decoration: BoxDecoration(
                    color: ctx.colorBorde,
                    borderRadius: BorderRadius.circular(AppRadii.pastilla),
                  ),
                ),
                const SizedBox(height: AppEspacios.g),
                Text(objetivo.nombre,
                    style: Theme.of(ctx).textTheme.titleLarge),
                const SizedBox(height: 4),
                Text(
                  '${Formatters.moneda(objetivo.montoAhorrado)} de '
                  '${Formatters.moneda(objetivo.montoObjetivo)}',
                  style: Theme.of(ctx).textTheme.bodySmall,
                ),
                const SizedBox(height: AppEspacios.m),
                _FilaAjuste(
                  icono: Icons.edit_outlined,
                  titulo: 'Cambiar nombre',
                  valor: 'Cómo se llama tu meta',
                  onTap: () async {
                    Navigator.pop(ctx);
                    await _editarNombreObjetivo(context, ref, objetivo);
                  },
                ),
                const SizedBox(height: AppEspacios.s),
                _FilaAjuste(
                  icono: Icons.attach_money_rounded,
                  titulo: 'Cambiar precio objetivo',
                  valor: Formatters.moneda(objetivo.montoObjetivo),
                  onTap: () async {
                    Navigator.pop(ctx);
                    await _editarPrecioObjetivo(context, ref, objetivo);
                  },
                ),
                const SizedBox(height: AppEspacios.s),
                _FilaAjuste(
                  icono: Icons.delete_outline_rounded,
                  titulo: 'Eliminar objetivo',
                  valor: 'Los abonos ya registrados se conservan',
                  colorValor: AppColors.gasto,
                  onTap: () async {
                    Navigator.pop(ctx);
                    await ref
                        .read(objetivosProvider.notifier)
                        .eliminar(objetivo.id);
                  },
                ),
                const SizedBox(height: AppEspacios.s),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _editarNombreObjetivo(
    BuildContext context,
    WidgetRef ref,
    Objetivo objetivo,
  ) async {
    final TextEditingController controlador =
        TextEditingController(text: objetivo.nombre);

    await showDialog<void>(
      context: context,
      builder: (BuildContext ctx) => AlertDialog(
        backgroundColor: ctx.colorSuperficie,
        shape: RoundedRectangleBorder(borderRadius: AppRadii.tarjeta),
        title: const Text('Nombre del objetivo'),
        content: CampoTexto(
          controller: controlador,
          etiqueta: 'Nombre',
          autofocus: true,
          formateadores: FiltrosEntrada.nombre,
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () async {
              final String? err = Validators.validarTexto(
                controlador.text,
                minimo: 2,
                mensaje: 'Escribe al menos 2 letras.',
              );
              if (err != null) return;
              await ref
                  .read(objetivosProvider.notifier)
                  .renombrar(objetivo.id, controlador.text);
              if (ctx.mounted) Navigator.pop(ctx);
            },
            child: const Text('Guardar'),
          ),
        ],
      ),
    );
    controlador.dispose();
  }

  Future<void> _editarPrecioObjetivo(
    BuildContext context,
    WidgetRef ref,
    Objetivo objetivo,
  ) async {
    final TextEditingController controlador = TextEditingController(
      text: objetivo.montoObjetivo.toStringAsFixed(2).replaceAll('.', ','),
    );

    await showDialog<void>(
      context: context,
      builder: (BuildContext ctx) => AlertDialog(
        backgroundColor: ctx.colorSuperficie,
        shape: RoundedRectangleBorder(borderRadius: AppRadii.tarjeta),
        title: const Text('Precio objetivo'),
        content: CampoTexto(
          controller: controlador,
          etiqueta: 'Cuánto cuesta',
          tipoTeclado: const TextInputType.numberWithOptions(decimal: true),
          formateadores: FiltrosEntrada.monto,
          autofocus: true,
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () async {
              final double? monto = Validators.parsearMonto(controlador.text);
              if (monto == null || monto <= 0) return;
              await ref
                  .read(objetivosProvider.notifier)
                  .cambiarMontoObjetivo(objetivo.id, monto);
              if (ctx.mounted) Navigator.pop(ctx);
            },
            child: const Text('Guardar'),
          ),
        ],
      ),
    );
    controlador.dispose();
  }

  Future<void> _confirmarReinicio(BuildContext context, WidgetRef ref) async {
    final bool? borrar = await showDialog<bool>(
      context: context,
      builder: (BuildContext ctx) => AlertDialog(
        backgroundColor: ctx.colorSuperficie,
        shape: RoundedRectangleBorder(borderRadius: AppRadii.tarjeta),
        title: const Text('¿Empezar de cero?'),
        content: const Text(
          'Se borrarán tu nombre, tu balance y todos tus movimientos y metas. '
          'Esta acción no se puede deshacer.',
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text(
              'Borrar todo',
              style: TextStyle(color: AppColors.gasto),
            ),
          ),
        ],
      ),
    );

    if (borrar == true) {
      await ref.read(usuarioProvider.notifier).reiniciar();
    }
  }
}

/// Cabecera con avatar, nombre y balance.
class _CabeceraPerfil extends StatelessWidget {
  const _CabeceraPerfil({required this.usuario});

  final Usuario? usuario;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppEspacios.l),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: AppColors.degradadoPerfil,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: AppRadii.tarjetaGrande,
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: AppColors.ahorro.withOpacity(0.26),
            blurRadius: 28,
            offset: const Offset(0, 14),
          ),
        ],
      ),
      child: Row(
        children: <Widget>[
          Container(
            height: 58,
            width: 58,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.20),
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white.withOpacity(0.35)),
            ),
            child: Center(
              child: Text(
                usuario?.inicial ?? 'C',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      color: Colors.white,
                    ),
              ),
            ),
          ),
          const SizedBox(width: AppEspacios.m),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  usuario?.nombre ?? 'Sin nombre',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: Colors.white,
                      ),
                ),
                const SizedBox(height: 3),
                Text(
                  'Tu perfil en Cuéntamela',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.white.withOpacity(0.85),
                      ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Fila de ajuste reutilizable (icono + título + valor + acción).
class _FilaAjuste extends StatelessWidget {
  const _FilaAjuste({
    required this.icono,
    required this.titulo,
    required this.valor,
    this.onTap,
    this.colorValor,
  });

  final IconData icono;
  final String titulo;
  final String valor;
  final VoidCallback? onTap;
  final Color? colorValor;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: context.colorSuperficie,
        borderRadius: AppRadii.tarjeta,
        border: Border.all(color: context.colorBorde),
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: AppRadii.tarjeta,
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppEspacios.m,
              vertical: AppEspacios.s + 6,
            ),
            child: Row(
              children: <Widget>[
                Container(
                  height: 36,
                  width: 36,
                  decoration: BoxDecoration(
                    color: (colorValor ?? context.colorMarca)
                        .withOpacity(context.esOscuro ? 0.18 : 0.10),
                    borderRadius: BorderRadius.circular(AppRadii.xs),
                  ),
                  child: Icon(icono,
                      size: 17, color: colorValor ?? context.colorMarca),
                ),
                const SizedBox(width: AppEspacios.s + 4),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(titulo,
                          style: Theme.of(context).textTheme.titleSmall),
                      const SizedBox(height: 2),
                      Text(
                        valor,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              fontSize: 11.5,
                              color: colorValor ?? context.colorTextoSuave,
                            ),
                      ),
                    ],
                  ),
                ),
                if (onTap != null)
                  Icon(Icons.chevron_right_rounded,
                      size: 20, color: context.colorTextoSuave),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Pequeña envoltura para leer el balance sin complicar el diálogo.
class ResumenActual {
  const ResumenActual({required this.valor});
  final double valor;
}

/// Utilidad expuesta para mantener el icono de metas disponible en el archivo.
// ignore: unused_element
IconData _iconoMeta(int indice) => IconosMeta.icono(indice);
