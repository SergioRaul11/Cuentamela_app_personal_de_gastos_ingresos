import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';

/// Cabecera de una sección con icono y título (se usa en el Perfil).
class EncabezadoSeccion extends StatelessWidget {
  const EncabezadoSeccion({
    super.key,
    required this.titulo,
    this.icono,
    this.descripcion,
  });

  final String titulo;
  final IconData? icono;
  final String? descripcion;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppEspacios.s + 2),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              if (icono != null) ...<Widget>[
                Icon(icono, size: 16, color: context.colorMarca),
                const SizedBox(width: 7),
              ],
              Text(titulo, style: Theme.of(context).textTheme.titleMedium),
            ],
          ),
          if (descripcion != null) ...<Widget>[
            const SizedBox(height: 3),
            Text(descripcion!, style: Theme.of(context).textTheme.bodySmall),
          ],
        ],
      ),
    );
  }
}
