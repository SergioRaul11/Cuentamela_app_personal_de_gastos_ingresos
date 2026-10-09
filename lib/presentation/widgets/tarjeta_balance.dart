import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';
import '../../core/utils/formatters.dart';

/// Tarjeta protagonista del Home: el dinero disponible.
///
/// Es la única superficie con degradado de la app, para que la mirada caiga
/// ahí primero. Toda la jerarquía interna se resuelve con opacidades sobre
/// blanco, no con más colores.
class TarjetaBalance extends StatelessWidget {
  const TarjetaBalance({
    super.key,
    required this.balance,
    required this.etiqueta,
    required this.nombre,
    this.subtitulo,
    this.compacto = false,
  });

  final double balance;
  final String etiqueta;

  /// Saludo y nombre: "Buenas tardes, Ana".
  final String nombre;
  final String? subtitulo;
  final bool compacto;

  @override
  Widget build(BuildContext context) {
    final bool negativo = balance < 0;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(compacto ? AppEspacios.g : AppEspacios.l),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: negativo
              ? const <Color>[Color(0xFFF04438), Color(0xFFF97066)]
              : const <Color>[
                  Color(0xFF00A97F),
                  Color(0xFF0FB98D),
                  Color(0xFF4FD9B1),
                ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: AppRadii.tarjetaGrande,
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: (negativo ? const Color(0xFFF04438) : const Color(0xFF00A97F))
                .withOpacity(0.28),
            blurRadius: 30,
            offset: const Offset(0, 16),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              Expanded(
                child: Text(
                  nombre,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        color: Colors.white.withOpacity(0.95),
                      ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.16),
                  borderRadius: BorderRadius.circular(AppRadii.pastilla),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    const Icon(Icons.account_balance_wallet_rounded,
                        size: 13, color: Colors.white),
                    const SizedBox(width: 5),
                    Text(
                      'Disponible',
                      style: Theme.of(context)
                          .textTheme
                          .labelSmall
                          ?.copyWith(color: Colors.white, fontSize: 10.5),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppEspacios.s),
          Text(
            etiqueta,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.white.withOpacity(0.80),
                ),
          ),
          const SizedBox(height: 6),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              Formatters.moneda(balance),
              style: Theme.of(context).textTheme.displaySmall?.copyWith(
                    color: Colors.white,
                    fontSize: compacto ? 32 : 38,
                  ),
            ),
          ),
          if (subtitulo != null) ...<Widget>[
            const SizedBox(height: AppEspacios.m),
            Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: AppEspacios.s + 4, vertical: 9),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.14),
                borderRadius: BorderRadius.circular(AppRadii.xs + 4),
              ),
              child: Row(
                children: <Widget>[
                  Icon(
                    subtitulo!.toLowerCase().contains('meta')
                        ? Icons.savings_rounded
                        : Icons.trending_up_rounded,
                    size: 15,
                    color: Colors.white,
                  ),
                  const SizedBox(width: 7),
                  Expanded(
                    child: Text(
                      subtitulo!,
                      maxLines: 2,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Colors.white.withOpacity(0.92),
                          ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}
