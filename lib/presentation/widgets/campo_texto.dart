import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/theme/app_theme.dart';

/// Campo de texto del sistema: etiqueta pequeña arriba, borde suave, foco
/// menta y mensaje de error integrado.
class CampoTexto extends StatelessWidget {
  const CampoTexto({
    super.key,
    required this.controller,
    required this.etiqueta,
    this.hint,
    this.icono,
    this.tipoTeclado = TextInputType.text,
    this.formateadores,
    this.error,
    this.onChanged,
    this.onSubmitted,
    this.prefijo,
    this.sufijo,
    this.autofocus = false,
    this.maxLineas = 1,
    this.textCapitalization = TextCapitalization.sentences,
  });

  final TextEditingController controller;
  final String etiqueta;
  final String? hint;
  final IconData? icono;
  final TextInputType tipoTeclado;
  final List<TextInputFormatter>? formateadores;
  final String? error;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final Widget? prefijo;
  final Widget? sufijo;
  final bool autofocus;
  final int maxLineas;
  final TextCapitalization textCapitalization;

  @override
  Widget build(BuildContext context) {
    final bool hayError = error != null && error!.isNotEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 7),
          child: Text(
            etiqueta.toUpperCase(),
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: context.colorTextoSuave,
                ),
          ),
        ),
        AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          decoration: BoxDecoration(
            color: context.colorSuperficie,
            borderRadius: BorderRadius.circular(AppRadii.s),
            border: Border.all(
              color: hayError ? AppColors.gasto : context.colorBorde,
              width: hayError ? 1.4 : 1,
            ),
          ),
          child: TextField(
            controller: controller,
            keyboardType: tipoTeclado,
            inputFormatters: formateadores,
            autofocus: autofocus,
            maxLines: maxLineas,
            textCapitalization: textCapitalization,
            onChanged: onChanged,
            onSubmitted: onSubmitted,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontSize: 16.5),
            cursorColor: context.colorMarca,
            cursorRadius: const Radius.circular(2),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: Theme.of(context)
                  .textTheme
                  .bodyMedium
                  ?.copyWith(color: context.colorTextoSuave.withOpacity(0.75)),
              prefixIcon: icono == null
                  ? null
                  : Icon(icono, size: 20, color: context.colorTextoSuave),
              prefix: prefijo,
              suffixIcon: sufijo,
              border: InputBorder.none,
              isDense: true,
              contentPadding: EdgeInsets.symmetric(
                horizontal: AppEspacios.m,
                vertical: maxLineas > 1 ? AppEspacios.m : 16,
              ),
            ),
          ),
        ),
        AnimatedSize(
          duration: const Duration(milliseconds: 180),
          curve: Curves.easeOut,
          child: hayError
              ? Padding(
                  padding: const EdgeInsets.only(left: 4, top: 7),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      const Icon(Icons.info_outline_rounded,
                          size: 14, color: AppColors.gasto),
                      const SizedBox(width: 5),
                      Expanded(
                        child: Text(
                          error!,
                          style: Theme.of(context)
                              .textTheme
                              .bodySmall
                              ?.copyWith(color: AppColors.gasto, height: 1.3),
                        ),
                      ),
                    ],
                  ),
                )
              : const SizedBox(width: double.infinity),
        ),
      ],
    );
  }
}

/// Reglas de entrada listas para usar en los campos de monto.
class FiltrosEntrada {
  FiltrosEntrada._();

  /// Dígitos, un separador decimal y el símbolo de moneda.
  static final List<TextInputFormatter> monto = <TextInputFormatter>[
    FilteringTextInputFormatter.allow(RegExp(r'[0-9.,$]')),
    LengthLimitingTextInputFormatter(14),
  ];

  static final List<TextInputFormatter> nombre = <TextInputFormatter>[
    LengthLimitingTextInputFormatter(40),
  ];

  static final List<TextInputFormatter> descripcion = <TextInputFormatter>[
    LengthLimitingTextInputFormatter(80),
  ];
}
