import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';
import '../../core/theme/iconos_meta.dart';
import '../../core/utils/formatters.dart';
import '../../domain/entities/objetivo.dart';

/// Barra de progreso de una meta.
///
/// Se dibuja a mano (no `LinearProgressIndicator`) para controlar el grosor,
/// el redondeo y el color por meta.
class BarraProgresoMeta extends StatelessWidget {
  const BarraProgresoMeta({
    super.key,
    required this.progreso,
    required this.color,
    this.alto = 9,
  });

  /// 0.0 – 1.0
  final double progreso;
  final Color color;
  final double alto;

  @override
  Widget build(BuildContext context) {
    final double p = progreso.isFinite ? progreso.clamp(0.0, 1.0) : 0.0;

    return ClipRRect(
      borderRadius: BorderRadius.circular(AppRadii.pastilla),
      child: Stack(
        children: <Widget>[
          Container(
            height: alto,
            // `double.infinity` es necesario: en un Stack las restricciones
            // son laxas y, sin ancho explícito, la pista mediría 0.
            width: double.infinity,
            color: context.esOscuro
                ? Colors.white.withOpacity(0.08)
                : const Color(0xFFEDF0F4),
          ),
          AnimatedFractionallySizedBox(
            duration: const Duration(milliseconds: 600),
            curve: Curves.easeOutCubic,
            alignment: Alignment.centerLeft,
            widthFactor: p <= 0 ? 0.0001 : p,
            child: Container(
              height: alto,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: <Color>[color, color.withOpacity(0.72)],
                ),
                borderRadius: BorderRadius.circular(AppRadii.pastilla),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Tarjeta de un objetivo de compra en el Home.
class TarjetaObjetivo extends StatelessWidget {
  const TarjetaObjetivo({
    super.key,
    required this.objetivo,
    this.onAbonar,
    this.onTap,
    this.compacta = false,
  });

  final Objetivo objetivo;

  /// Abre el flujo de abono (chat o hoja modal).
  final VoidCallback? onAbonar;
  final VoidCallback? onTap;
  final bool compacta;

  @override
  Widget build(BuildContext context) {
    final Color color = Color(objetivo.colorValor);
    final bool completa = objetivo.completado;

    return Container(
      width: compacta ? 250 : double.infinity,
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
                      height: 36,
                      width: 36,
                      decoration: BoxDecoration(
                        color: color.withOpacity(context.esOscuro ? 0.22 : 0.12),
                        borderRadius: BorderRadius.circular(AppRadii.xs),
                      ),
                      child: Icon(
                        IconosMeta.icono(objetivo.iconoIndex),
                        size: 19,
                        color: color,
                      ),
                    ),
                    const SizedBox(width: AppEspacios.s + 2),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            objetivo.nombre,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: Theme.of(context).textTheme.titleSmall,
                          ),
                          const SizedBox(height: 2),
                          Text(
                            completa
                                ? 'Objetivo completado'
                                : 'Faltan ${Formatters.moneda(objetivo.restante)}',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style:
                                Theme.of(context).textTheme.bodySmall?.copyWith(
                                      fontSize: 11.5,
                                      color: completa ? color : null,
                                    ),
                          ),
                        ],
                      ),
                    ),
                    if (onAbonar != null)
                      Material(
                        color: color.withOpacity(context.esOscuro ? 0.20 : 0.10),
                        borderRadius: BorderRadius.circular(AppRadii.xs),
                        clipBehavior: Clip.antiAlias,
                        child: InkWell(
                          onTap: onAbonar,
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 8),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: <Widget>[
                                Icon(Icons.add_rounded, size: 15, color: color),
                                const SizedBox(width: 3),
                                Text(
                                  'Abonar',
                                  style: Theme.of(context)
                                      .textTheme
                                      .labelSmall
                                      ?.copyWith(
                                        color: color,
                                        fontSize: 11.5,
                                      ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: AppEspacios.m),
                BarraProgresoMeta(progreso: objetivo.progreso, color: color),
                const SizedBox(height: AppEspacios.s + 2),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Text(
                      Formatters.moneda(objetivo.montoAhorrado),
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            color: color,
                            fontSize: 13.5,
                          ),
                    ),
                    Text(
                      'de ${Formatters.moneda(objetivo.montoObjetivo, compacto: true)}',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            fontSize: 11.5,
                          ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: color.withOpacity(context.esOscuro ? 0.20 : 0.10),
                        borderRadius: BorderRadius.circular(AppRadii.pastilla),
                      ),
                      child: Text(
                        Formatters.porcentaje(objetivo.progreso),
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                              color: color,
                              fontSize: 10.5,
                            ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Estado vacío para la sección de objetivos (aún no hay metas).
class ObjetivoVacio extends StatelessWidget {
  const ObjetivoVacio({super.key, this.onCrear});

  final VoidCallback? onCrear;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppEspacios.g),
      decoration: BoxDecoration(
        color: context.colorSuperficie,
        borderRadius: AppRadii.tarjeta,
        border: Border.all(
          color: context.colorBorde,
          style: BorderStyle.solid,
        ),
      ),
      child: Column(
        children: <Widget>[
          Container(
            height: 44,
            width: 44,
            decoration: BoxDecoration(
              color: AppColors.ahorro.withOpacity(context.esOscuro ? 0.20 : 0.10),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.savings_outlined,
                size: 21, color: AppColors.ahorro),
          ),
          const SizedBox(height: AppEspacios.s + 2),
          Text(
            'Todavía no tienes objetivos',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.titleSmall,
          ),
          const SizedBox(height: 4),
          Text(
            'Crea hasta 3 metas de compra y ve abonando poco a poco.',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodySmall,
          ),
          if (onCrear != null) ...<Widget>[
            const SizedBox(height: AppEspacios.m),
            Material(
              color: AppColors.ahorro.withOpacity(context.esOscuro ? 0.20 : 0.10),
              borderRadius: BorderRadius.circular(AppRadii.s),
              clipBehavior: Clip.antiAlias,
              child: InkWell(
                onTap: onCrear,
                child: const Padding(
                  padding: EdgeInsets.symmetric(
                      horizontal: AppEspacios.g, vertical: 12),
                  child: Text(
                    'Crear mi primer objetivo',
                    style: TextStyle(
                      color: AppColors.ahorro,
                      fontWeight: FontWeight.w600,
                      fontSize: 13.5,
                    ),
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
