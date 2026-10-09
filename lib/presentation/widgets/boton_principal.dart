import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';

/// Botón principal de la app.
///
/// Un solo estilo de acción primaria (relleno) y uno secundario (borde). El
/// estado de carga reemplaza el contenido por un indicador del mismo tamaño,
/// así el layout no salta.
class BotonPrincipal extends StatelessWidget {
  const BotonPrincipal({
    super.key,
    required this.texto,
    this.onPressed,
    this.icono,
    this.cargando = false,
    this.secundario = false,
    this.expandido = true,
    this.alto = 54,
  });

  final String texto;
  final VoidCallback? onPressed;
  final IconData? icono;
  final bool cargando;
  final bool secundario;
  final bool expandido;
  final double alto;

  @override
  Widget build(BuildContext context) {
    final bool habilitado = onPressed != null && !cargando;
    final Color marca = context.colorMarca;

    final Widget contenido = cargando
        ? SizedBox(
            height: 20,
            width: 20,
            child: CircularProgressIndicator(
              strokeWidth: 2.2,
              valueColor: AlwaysStoppedAnimation<Color>(
                secundario ? marca : Colors.white,
              ),
            ),
          )
        : Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              if (icono != null) ...<Widget>[
                Icon(icono, size: 19, color: secundario ? marca : Colors.white),
                const SizedBox(width: AppEspacios.s),
              ],
              Flexible(
                child: Text(
                  texto,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                        color: secundario ? marca : Colors.white,
                        fontSize: 15.5,
                      ),
                ),
              ),
            ],
          );

    return Opacity(
      opacity: habilitado ? 1 : 0.55,
      child: SizedBox(
        height: alto,
        width: expandido ? double.infinity : null,
        child: Material(
          color: secundario ? Colors.transparent : marca,
          borderRadius: BorderRadius.circular(AppRadii.s),
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: habilitado ? onPressed : null,
            borderRadius: BorderRadius.circular(AppRadii.s),
            splashColor: (secundario ? marca : Colors.white).withOpacity(0.10),
            child: Container(
              alignment: Alignment.center,
              padding: const EdgeInsets.symmetric(horizontal: AppEspacios.g),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(AppRadii.s),
                border: secundario ? Border.all(color: context.colorBorde) : null,
                boxShadow: secundario || !habilitado ? null : AppSombras.suave(context.esOscuro),
              ),
              child: contenido,
            ),
          ),
        ),
      ),
    );
  }
}
