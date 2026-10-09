import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';

/// Tarjeta métrica pequeña (ingresos / gastos) para la fila de totales.
class TarjetaResumen extends StatelessWidget {
  const TarjetaResumen({
    super.key,
    required this.titulo,
    required this.valor,
    required this.icono,
    required this.color,
    this.pie,
    this.onTap,
  });

  final String titulo;
  final String valor;
  final IconData icono;
  final Color color;

  /// Línea secundaria, por ejemplo "3 movimientos".
  final String? pie;
  final VoidCallback? onTap;

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
            padding: const EdgeInsets.all(AppEspacios.m),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Row(
                  children: <Widget>[
                    Container(
                      height: 30,
                      width: 30,
                      decoration: BoxDecoration(
                        color: color.withOpacity(context.esOscuro ? 0.20 : 0.11),
                        borderRadius: BorderRadius.circular(AppRadii.xs),
                      ),
                      child: Icon(icono, size: 16, color: color),
                    ),
                    const SizedBox(width: AppEspacios.s),
                    Expanded(
                      child: Text(
                        titulo,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: context.colorTextoSuave,
                              fontSize: 12,
                            ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppEspacios.s + 2),
                FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: Text(
                    valor,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontSize: 19,
                          color: context.colorTexto,
                        ),
                  ),
                ),
                if (pie != null) ...<Widget>[
                  const SizedBox(height: 3),
                  Text(
                    pie!,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          fontSize: 11,
                          color: context.colorTextoSuave,
                        ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Fila de tres indicadores: dinero actual, ingresos y gastos.
class FilaTotales extends StatelessWidget {
  const FilaTotales({super.key, required this.hijos});

  final List<Widget> hijos;

  @override
  Widget build(BuildContext context) {
    final List<Widget> fila = <Widget>[];
    for (int i = 0; i < hijos.length; i++) {
      if (i > 0) fila.add(const SizedBox(width: AppEspacios.s + 2));
      fila.add(Expanded(child: hijos[i]));
    }
    // IntrinsicHeight permite que las tres tarjetas igualen su altura sin
    // depender de medidas fijas (un Row con `stretch` necesitaría altura
    // acotada, que aquí no existe).
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: fila,
      ),
    );
  }
}

/// Colores de marca para los indicadores.
class ColoresResumen {
  ColoresResumen._();
  static const Color actual = AppColors.menta;
  static const Color ingresos = AppColors.ingreso;
  static const Color gastos = AppColors.gasto;
  static const Color ahorro = AppColors.ahorro;
}
