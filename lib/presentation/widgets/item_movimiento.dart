import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';
import '../../core/utils/formatters.dart';
import '../../domain/entities/transaccion.dart';

/// Colores e iconos por tipo de movimiento. Un único punto de verdad para que
/// la lista, las tarjetas y el chat usen exactamente el mismo lenguaje.
class EstiloMovimiento {
  EstiloMovimiento._();

  static Color color(TipoMovimiento tipo) {
    switch (tipo) {
      case TipoMovimiento.ingreso:
        return AppColors.ingreso;
      case TipoMovimiento.gasto:
        return AppColors.gasto;
      case TipoMovimiento.ahorro:
        return AppColors.ahorro;
    }
  }

  static IconData icono(TipoMovimiento tipo) {
    switch (tipo) {
      case TipoMovimiento.ingreso:
        return Icons.arrow_downward_rounded;
      case TipoMovimiento.gasto:
        return Icons.arrow_upward_rounded;
      case TipoMovimiento.ahorro:
        return Icons.savings_rounded;
    }
  }

  static String signo(TipoMovimiento tipo) => tipo.esEntrada ? '+' : '−';
}

/// Fila de un movimiento en la lista cronológica del Home.
class ItemMovimiento extends StatelessWidget {
  const ItemMovimiento({
    super.key,
    required this.transaccion,
    this.onTap,
    this.onEliminar,
    this.ocultarFecha = false,
  });

  final Transaccion transaccion;
  final VoidCallback? onTap;
  final VoidCallback? onEliminar;
  final bool ocultarFecha;

  @override
  Widget build(BuildContext context) {
    final Color color = EstiloMovimiento.color(transaccion.tipo);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        onLongPress: onEliminar,
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppEspacios.m,
            vertical: AppEspacios.s + 4,
          ),
          child: Row(
            children: <Widget>[
              Container(
                height: 40,
                width: 40,
                decoration: BoxDecoration(
                  color: color.withOpacity(context.esOscuro ? 0.20 : 0.10),
                  borderRadius: BorderRadius.circular(AppRadii.xs + 2),
                ),
                child: Icon(
                  EstiloMovimiento.icono(transaccion.tipo),
                  size: 19,
                  color: color,
                ),
              ),
              const SizedBox(width: AppEspacios.s + 4),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      transaccion.descripcion,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            fontSize: 14.5,
                          ),
                    ),
                    const SizedBox(height: 2),
                    Row(
                      children: <Widget>[
                        Text(
                          transaccion.tipo.etiqueta,
                          style:
                              Theme.of(context).textTheme.bodySmall?.copyWith(
                                    fontSize: 11.5,
                                    color: color,
                                  ),
                        ),
                        if (!ocultarFecha) ...<Widget>[
                          Text(
                            '  ·  ',
                            style:
                                Theme.of(context).textTheme.bodySmall?.copyWith(
                                      fontSize: 11.5,
                                    ),
                          ),
                          Text(
                            Formatters.fechaCorta(transaccion.fecha),
                            style:
                                Theme.of(context).textTheme.bodySmall?.copyWith(
                                      fontSize: 11.5,
                                    ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: AppEspacios.s),
              Text(
                '${EstiloMovimiento.signo(transaccion.tipo)}'
                '${Formatters.moneda(transaccion.monto)}',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      color: color,
                      fontSize: 14.5,
                    ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Cabecera de grupo por día: "Hoy", "Ayer", "12 mar".
class CabeceraDia extends StatelessWidget {
  const CabeceraDia({super.key, required this.fecha, this.totalDelDia});

  final DateTime fecha;

  /// Suma neta de ese día (positiva o negativa), opcional.
  final double? totalDelDia;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(
        left: AppEspacios.m,
        right: AppEspacios.m,
        top: AppEspacios.m,
        bottom: AppEspacios.s,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Text(
            Formatters.fechaCorta(fecha).toUpperCase(),
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: context.colorTextoSuave,
                  letterSpacing: 0.6,
                ),
          ),
          if (totalDelDia != null)
            Text(
              '${totalDelDia! >= 0 ? '+' : '−'}'
              '${Formatters.moneda(totalDelDia!.abs())}',
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: totalDelDia! >= 0
                        ? AppColors.ingreso
                        : context.colorTextoSuave,
                    fontSize: 11,
                  ),
            ),
        ],
      ),
    );
  }
}

/// Estado vacío de la lista de movimientos.
class ListaVacia extends StatelessWidget {
  const ListaVacia({super.key, this.onIrAlChat});

  final VoidCallback? onIrAlChat;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppEspacios.m,
        vertical: AppEspacios.xl,
      ),
      child: Column(
        children: <Widget>[
          Container(
            height: 56,
            width: 56,
            decoration: BoxDecoration(
              color: context.colorMarca.withOpacity(context.esOscuro ? 0.18 : 0.09),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.receipt_long_rounded,
                size: 25, color: context.colorMarca),
          ),
          const SizedBox(height: AppEspacios.m),
          Text(
            'Aún no hay movimientos',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 6),
          Text(
            'Cuéntame tu primer ingreso o gasto en el chat y aparecerá aquí.',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodySmall,
          ),
          if (onIrAlChat != null) ...<Widget>[
            const SizedBox(height: AppEspacios.m),
            Material(
              color: context.colorMarca.withOpacity(context.esOscuro ? 0.18 : 0.09),
              borderRadius: BorderRadius.circular(AppRadii.s),
              clipBehavior: Clip.antiAlias,
              child: InkWell(
                onTap: onIrAlChat,
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: AppEspacios.g, vertical: 12),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      Icon(Icons.chat_bubble_rounded,
                          size: 16, color: context.colorMarca),
                      const SizedBox(width: 6),
                      Text(
                        'Abrir el chat',
                        style: TextStyle(
                          color: context.colorMarca,
                          fontWeight: FontWeight.w600,
                          fontSize: 13.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// Título de sección con acción opcional a la derecha.
class TituloSeccion extends StatelessWidget {
  const TituloSeccion({
    super.key,
    required this.titulo,
    this.accion,
    this.onAccion,
  });

  final String titulo;
  final String? accion;
  final VoidCallback? onAccion;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppEspacios.s + 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Text(titulo, style: Theme.of(context).textTheme.titleMedium),
          if (accion != null && onAccion != null)
            Material(
              color: Colors.transparent,
              borderRadius: BorderRadius.circular(AppRadii.pastilla),
              clipBehavior: Clip.antiAlias,
              child: InkWell(
                onTap: onAccion,
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: AppEspacios.s + 2, vertical: 5),
                  child: Text(
                    accion!,
                    style: Theme.of(context).textTheme.labelMedium?.copyWith(
                          color: context.colorMarca,
                        ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
