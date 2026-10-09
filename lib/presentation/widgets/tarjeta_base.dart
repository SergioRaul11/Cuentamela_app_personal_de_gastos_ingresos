import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';

/// Tarjeta base del sistema visual.
///
/// Todas las superficies de Cuéntamela son esto: fondo sólido, radio generoso,
/// borde de 1 px y sombra muy tenue. Opcionalmente con degradado (cuando se
/// pasa [degradado]) o con onTap (se añade una onda de tinta suave).
class TarjetaBase extends StatelessWidget {
  const TarjetaBase({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(AppEspacios.m),
    this.onTap,
    this.color,
    this.degradado,
    this.borde = true,
    this.sombra = true,
    this.radio,
    this.ancho,
    this.altura,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final VoidCallback? onTap;
  final Color? color;
  final List<Color>? degradado;
  final bool borde;
  final bool sombra;
  final BorderRadius? radio;
  final double? ancho;
  final double? altura;

  @override
  Widget build(BuildContext context) {
    final BorderRadius r = radio ?? AppRadii.tarjeta;

    return Container(
      width: ancho,
      height: altura,
      decoration: BoxDecoration(
        color: degradado == null ? (color ?? context.colorSuperficie) : null,
        gradient: degradado == null
            ? null
            : LinearGradient(
                colors: degradado!,
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
        borderRadius: r,
        border: borde && degradado == null
            ? Border.all(color: context.colorBorde)
            : null,
        boxShadow: sombra ? AppSombras.suave(context.esOscuro) : null,
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: r,
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          borderRadius: r,
          splashColor: context.colorMarca.withOpacity(0.06),
          highlightColor: context.colorMarca.withOpacity(0.03),
          child: Padding(padding: padding, child: child),
        ),
      ),
    );
  }
}
