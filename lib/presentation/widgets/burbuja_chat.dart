import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';

/// Autor de un mensaje del chat.
enum AutorMensaje { app, usuario }

/// Burbuja del chat conversacional.
///
/// La app habla a la izquierda con fondo de superficie y el usuario a la
/// derecha con el color de marca. En modo claro la burbuja del usuario usa
/// menta con texto blanco; en oscuro se aclara para mantener contraste.
class BurbujaChat extends StatelessWidget {
  const BurbujaChat({
    super.key,
    required this.texto,
    required this.autor,
    this.hora,
    this.anchoMaximo = 300,
    this.widgetExtra,
  });

  final String texto;
  final AutorMensaje autor;
  final String? hora;
  final double anchoMaximo;

  /// Contenido adicional debajo del texto (tarjetas de confirmación, etc.).
  final Widget? widgetExtra;

  bool get esUsuario => autor == AutorMensaje.usuario;

  @override
  Widget build(BuildContext context) {
    final Color fondo =
        esUsuario ? context.colorMarca : context.colorSuperficie;
    final Color textoColor =
        esUsuario ? Colors.white : context.colorTexto;

    return Align(
      alignment: esUsuario ? Alignment.centerRight : Alignment.centerLeft,
      child: Padding(
        padding: const EdgeInsets.only(bottom: AppEspacios.s + 2),
        child: Row(
          mainAxisAlignment:
              esUsuario ? MainAxisAlignment.end : MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: <Widget>[
            if (!esUsuario) ...<Widget>[
              _avatar(context),
              const SizedBox(width: AppEspacios.s),
            ],
            Flexible(
              child: ConstrainedBox(
                constraints: BoxConstraints(maxWidth: anchoMaximo),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppEspacios.m,
                    vertical: AppEspacios.s + 4,
                  ),
                  decoration: BoxDecoration(
                    color: fondo,
                    borderRadius: BorderRadius.only(
                      topLeft: const Radius.circular(AppRadii.m),
                      topRight: const Radius.circular(AppRadii.m),
                      bottomLeft: Radius.circular(esUsuario ? AppRadii.m : 6),
                      bottomRight: Radius.circular(esUsuario ? 6 : AppRadii.m),
                    ),
                    border: esUsuario
                        ? null
                        : Border.all(color: context.colorBorde),
                    boxShadow: AppSombras.suave(context.esOscuro),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        texto,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: textoColor,
                              height: 1.4,
                            ),
                      ),
                      if (widgetExtra != null) ...<Widget>[
                        const SizedBox(height: AppEspacios.s + 2),
                        widgetExtra!,
                      ],
                      if (hora != null) ...<Widget>[
                        const SizedBox(height: 5),
                        Text(
                          hora!,
                          style: Theme.of(context)
                              .textTheme
                              .labelSmall
                              ?.copyWith(
                                fontSize: 10,
                                color: esUsuario
                                    ? Colors.white.withOpacity(0.75)
                                    : context.colorTextoSuave,
                              ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
            if (esUsuario) ...<Widget>[
              const SizedBox(width: AppEspacios.s),
              _avatar(context),
            ],
          ],
        ),
      ),
    );
  }

  Widget _avatar(BuildContext context) {
    return Container(
      height: 28,
      width: 28,
      decoration: BoxDecoration(
        color: esUsuario
            ? context.colorMarca.withOpacity(0.14)
            : context.colorBorde,
        shape: BoxShape.circle,
      ),
      child: Icon(
        esUsuario ? Icons.person_rounded : Icons.auto_awesome_rounded,
        size: 15,
        color: esUsuario ? context.colorMarca : context.colorTextoSuave,
      ),
    );
  }
}

/// Indicador de "Cuéntamela está escribiendo".
///
/// Los tres puntos son estáticos a propósito: una animación en bucle
/// impediría que la app se estabilice en reposo (y bloquearía las pruebas
/// de interfaz que esperan a que no queden animaciones).
class BurbujaEscribiendo extends StatelessWidget {
  const BurbujaEscribiendo({super.key});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Padding(
        padding: const EdgeInsets.only(bottom: AppEspacios.s + 2, left: 36),
        child: Container(
          padding: const EdgeInsets.symmetric(
              horizontal: AppEspacios.m, vertical: 12),
          decoration: BoxDecoration(
            color: context.colorSuperficie,
            borderRadius: BorderRadius.circular(AppRadii.m),
            border: Border.all(color: context.colorBorde),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: List<Widget>.generate(
              3,
              (int i) => Padding(
                padding: const EdgeInsets.symmetric(horizontal: 2.5),
                child: Container(
                  height: 7,
                  width: 7,
                  decoration: BoxDecoration(
                    color: context.colorTextoSuave
                        .withOpacity(0.6 - (i * 0.15)),
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Barra de opciones rápidas que aparecen bajo la pregunta de la app
/// (por ejemplo: "Hay ingreso" / "Gasté" / "Ahorré").
class OpcionesRapidas extends StatelessWidget {
  const OpcionesRapidas({
    super.key,
    required this.opciones,
    required this.onSeleccion,
    this.seleccionada,
  });

  final List<String> opciones;
  final ValueChanged<String> onSeleccion;

  /// Texto resaltado cuando ya hay una opción elegida.
  final String? seleccionada;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: AppEspacios.s,
      runSpacing: AppEspacios.s,
      children: opciones.map((String opcion) {
        final bool activa = seleccionada == opcion;
        return Material(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(AppRadii.pastilla),
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: () => onSeleccion(opcion),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 160),
              padding: const EdgeInsets.symmetric(
                  horizontal: AppEspacios.m, vertical: 11),
              decoration: BoxDecoration(
                color: activa
                    ? context.colorMarca.withOpacity(0.12)
                    : context.colorSuperficie,
                borderRadius: BorderRadius.circular(AppRadii.pastilla),
                border: Border.all(
                  color: activa ? context.colorMarca : context.colorBorde,
                  width: activa ? 1.3 : 1,
                ),
              ),
              child: Text(
                opcion,
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontSize: 13.5,
                      color: activa ? context.colorMarca : context.colorTexto,
                    ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}

/// Marca de error de validación dentro del chat (por ejemplo, fecha futura).
class AvisoChat extends StatelessWidget {
  const AvisoChat({
    super.key,
    required this.mensaje,
    this.color = AppColors.alerta,
    this.icono = Icons.warning_amber_rounded,
  });

  final String mensaje;
  final Color color;
  final IconData icono;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppEspacios.s + 4),
      decoration: BoxDecoration(
        color: color.withOpacity(context.esOscuro ? 0.14 : 0.08),
        borderRadius: BorderRadius.circular(AppRadii.xs),
        border: Border.all(color: color.withOpacity(0.35)),
      ),
      child: Row(
        children: <Widget>[
          Icon(icono, size: 16, color: color),
          const SizedBox(width: AppEspacios.s),
          Expanded(
            child: Text(
              mensaje,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: color,
                    height: 1.35,
                  ),
            ),
          ),
        ],
      ),
    );
  }
}
