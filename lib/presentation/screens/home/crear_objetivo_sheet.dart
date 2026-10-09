import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/theme/iconos_meta.dart';
import '../../../core/utils/validators.dart';
import '../../providers/objetivos_provider.dart';
import '../../widgets/boton_principal.dart';
import '../../widgets/campo_texto.dart';

/// Abre la hoja de creación de una meta. Devuelve el id creado, o `null`.
Future<String?> mostrarHojaCrearObjetivo(BuildContext context, WidgetRef ref) {
  return showModalBottomSheet<String>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (BuildContext ctx) => const _HojaCrearObjetivo(),
  );
}

class _HojaCrearObjetivo extends ConsumerStatefulWidget {
  const _HojaCrearObjetivo();

  @override
  ConsumerState<_HojaCrearObjetivo> createState() => _HojaCrearObjetivoState();
}

class _HojaCrearObjetivoState extends ConsumerState<_HojaCrearObjetivo> {
  final TextEditingController _nombre = TextEditingController();
  final TextEditingController _monto = TextEditingController();
  int _icono = 0;
  int _color = 0;
  String? _errorNombre;
  String? _errorMonto;
  bool _guardando = false;

  @override
  void dispose() {
    _nombre.dispose();
    _monto.dispose();
    super.dispose();
  }

  Future<void> _guardar() async {
    final String? errNombre = Validators.validarTexto(
      _nombre.text,
      minimo: 2,
      mensaje: 'Ponle un nombre a tu objetivo.',
    );
    final double? monto = Validators.parsearMonto(_monto.text);
    final String? errMonto = Validators.validarMonto(monto);

    setState(() {
      _errorNombre = errNombre;
      _errorMonto = errMonto;
    });
    if (errNombre != null || errMonto != null) return;

    setState(() => _guardando = true);
    try {
      final String id = (await ref.read(objetivosProvider.notifier).crear(
                nombre: _nombre.text,
                montoObjetivo: monto!,
                iconoIndex: _icono,
                colorValor: IconosMeta.color(_color),
              ))
          .id;
      if (mounted) Navigator.pop(context, id);
    } catch (e) {
      if (mounted) {
        setState(() {
          _guardando = false;
          _errorMonto = e.toString().replaceFirst('Bad state: ', '');
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final double alturaTeclado = MediaQuery.viewInsetsOf(context).bottom;

    return Padding(
      padding: EdgeInsets.only(bottom: alturaTeclado),
      child: Container(
        decoration: BoxDecoration(
          color: context.colorFondo,
          borderRadius: AppRadii.hoja,
        ),
        child: SafeArea(
          top: false,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(AppEspacios.l),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Center(
                  child: Container(
                    height: 4,
                    width: 40,
                    decoration: BoxDecoration(
                      color: context.colorBorde,
                      borderRadius: BorderRadius.circular(AppRadii.pastilla),
                    ),
                  ),
                ),
                const SizedBox(height: AppEspacios.g),
                Text(
                  'Nuevo objetivo',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 4),
                Text(
                  '¿Qué quieres comprar y cuánto cuesta?',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: context.colorTextoSuave,
                      ),
                ),
                const SizedBox(height: AppEspacios.g),
                CampoTexto(
                  controller: _nombre,
                  etiqueta: 'Nombre del objetivo',
                  hint: 'Por ejemplo, Computadora nueva',
                  icono: Icons.flag_outlined,
                  error: _errorNombre,
                  formateadores: FiltrosEntrada.nombre,
                ),
                const SizedBox(height: AppEspacios.m),
                CampoTexto(
                  controller: _monto,
                  etiqueta: 'Precio objetivo',
                  hint: '0,00',
                  tipoTeclado:
                      const TextInputType.numberWithOptions(decimal: true),
                  formateadores: FiltrosEntrada.monto,
                  error: _errorMonto,
                  prefijo: Padding(
                    padding: const EdgeInsets.only(left: AppEspacios.m),
                    child: Text(
                      r'$',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: context.colorTextoSuave,
                          ),
                    ),
                  ),
                ),
                const SizedBox(height: AppEspacios.g),
                Text(
                  'ICONO',
                  style: Theme.of(context)
                      .textTheme
                      .labelSmall
                      ?.copyWith(color: context.colorTextoSuave),
                ),
                const SizedBox(height: AppEspacios.s),
                Wrap(
                  spacing: AppEspacios.s,
                  runSpacing: AppEspacios.s,
                  children: List<Widget>.generate(
                    IconosMeta.catalogo.length,
                    (int i) {
                      final bool activo = _icono == i;
                      final Color c = Color(IconosMeta.color(_color));
                      return GestureDetector(
                        onTap: () => setState(() => _icono = i),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 160),
                          height: 44,
                          width: 44,
                          decoration: BoxDecoration(
                            color: activo
                                ? c.withOpacity(0.14)
                                : context.colorSuperficie,
                            borderRadius: BorderRadius.circular(AppRadii.xs),
                            border: Border.all(
                              color: activo ? c : context.colorBorde,
                              width: activo ? 1.4 : 1,
                            ),
                          ),
                          child: Icon(
                            IconosMeta.icono(i),
                            size: 20,
                            color: activo ? c : context.colorTextoSuave,
                          ),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: AppEspacios.g),
                Text(
                  'COLOR',
                  style: Theme.of(context)
                      .textTheme
                      .labelSmall
                      ?.copyWith(color: context.colorTextoSuave),
                ),
                const SizedBox(height: AppEspacios.s),
                Row(
                  children: List<Widget>.generate(
                    IconosMeta.colores.length,
                    (int i) {
                      final Color c = Color(IconosMeta.color(i));
                      final bool activo = _color == i;
                      return Padding(
                        padding:
                            const EdgeInsets.only(right: AppEspacios.s + 2),
                        child: GestureDetector(
                          onTap: () => setState(() => _color = i),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 160),
                            height: 30,
                            width: 30,
                            decoration: BoxDecoration(
                              color: c,
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: activo
                                    ? context.colorTexto
                                    : Colors.transparent,
                                width: 2,
                              ),
                            ),
                            child: activo
                                ? const Icon(Icons.check_rounded,
                                    size: 15, color: Colors.white)
                                : null,
                          ),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: AppEspacios.l),
                BotonPrincipal(
                  texto: 'Crear objetivo',
                  icono: Icons.add_rounded,
                  cargando: _guardando,
                  onPressed: _guardar,
                ),
                const SizedBox(height: AppEspacios.s),
                BotonPrincipal(
                  texto: 'Cancelar',
                  secundario: true,
                  alto: 48,
                  onPressed: _guardando ? null : () => Navigator.pop(context),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
