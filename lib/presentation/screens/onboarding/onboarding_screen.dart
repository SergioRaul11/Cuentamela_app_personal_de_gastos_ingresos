import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/utils/validators.dart';
import '../../providers/usuario_provider.dart';
import '../../widgets/boton_principal.dart';
import '../../widgets/campo_texto.dart';

/// Onboarding: se muestra **solo la primera vez**.
///
/// Pide dos cosas y nada más: cómo te llamas y cuánto dinero tienes ahora.
/// Al terminar, el usuario queda guardado en `userBox` con
/// `onboardingCompletado = true`, así que en el siguiente arranque la app
/// entra directamente al Home sin volver a preguntar.
class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final PageController _paginas = PageController();
  final TextEditingController _nombre = TextEditingController();
  final TextEditingController _dinero = TextEditingController();

  int _paso = 0;
  bool _guardando = false;
  String? _errorNombre;
  String? _errorDinero;

  @override
  void dispose() {
    _paginas.dispose();
    _nombre.dispose();
    _dinero.dispose();
    super.dispose();
  }

  void _siguiente() {
    final String? error = Validators.validarTexto(
      _nombre.text,
      minimo: 2,
      mensaje: 'Escribe tu nombre ps porque no...',
    );
    setState(() => _errorNombre = error);
    if (error != null) return;

    setState(() => _paso = 1);
    _paginas.animateToPage(
      1,
      duration: const Duration(milliseconds: 420),
      curve: Curves.easeOutCubic,
    );
  }

  Future<void> _terminar() async {
    final double? monto = Validators.parsearMonto(_dinero.text);
    String? error;

    if (_dinero.text.trim().isEmpty) {
      error = 'Escribe cuánto dinero tienes ahora.';
    } else if (monto == null) {
      error = Validators.mensajeMontoInvalido;
    } else if (monto < 0) {
      error = 'El dinero disponible no puede ser negativo.';
    }

    setState(() => _errorDinero = error);
    if (error != null) return;

    setState(() => _guardando = true);
    await ref.read(usuarioProvider.notifier).completarOnboarding(
          nombre: _nombre.text,
          balanceInicial: monto!,
        );
    if (mounted) setState(() => _guardando = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppEspacios.l,
                AppEspacios.g,
                AppEspacios.l,
                0,
              ),
              child: Row(
                children: <Widget>[
                  _IndicadorPaso(activo: _paso >= 0),
                  const SizedBox(width: 6),
                  _IndicadorPaso(activo: _paso >= 1),
                  const Spacer(),
                  Text(
                    'Paso ${_paso + 1} de 2',
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: context.colorTextoSuave,
                        ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: PageView(
                controller: _paginas,
                physics: const NeverScrollableScrollPhysics(),
                children: <Widget>[
                  _PasoNombre(
                    controlador: _nombre,
                    error: _errorNombre,
                    onContinuar: _siguiente,
                  ),
                  _PasoDinero(
                    controlador: _dinero,
                    error: _errorDinero,
                    cargando: _guardando,
                    nombre: _nombre.text,
                    onVolver: () {
                      setState(() => _paso = 0);
                      _paginas.animateToPage(
                        0,
                        duration: const Duration(milliseconds: 380),
                        curve: Curves.easeOutCubic,
                      );
                    },
                    onTerminar: _terminar,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _IndicadorPaso extends StatelessWidget {
  const _IndicadorPaso({required this.activo});

  final bool activo;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 260),
      height: 5,
      width: activo ? 26 : 12,
      decoration: BoxDecoration(
        color: activo ? context.colorMarca : context.colorBorde,
        borderRadius: BorderRadius.circular(AppRadii.pastilla),
      ),
    );
  }
}

/// Cabecera visual compartida por los dos pasos.
class _Cabecera extends StatelessWidget {
  const _Cabecera({
    required this.icono,
    required this.titulo,
    required this.texto,
  });

  final IconData icono;
  final String titulo;
  final String texto;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Container(
          height: 58,
          width: 58,
          decoration: BoxDecoration(
            color:
                context.colorMarca.withOpacity(context.esOscuro ? 0.18 : 0.10),
            borderRadius: BorderRadius.circular(AppRadii.m),
          ),
          child: Icon(icono, size: 26, color: context.colorMarca),
        ),
        const SizedBox(height: AppEspacios.g),
        Text(titulo, style: Theme.of(context).textTheme.headlineMedium),
        const SizedBox(height: AppEspacios.s + 2),
        Text(
          texto,
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: context.colorTextoSuave,
              ),
        ),
      ],
    );
  }
}

class _PasoNombre extends StatelessWidget {
  const _PasoNombre({
    required this.controlador,
    required this.error,
    required this.onContinuar,
  });

  final TextEditingController controlador;
  final String? error;
  final VoidCallback onContinuar;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(AppEspacios.l),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          const Spacer(),
          const _Cabecera(
            icono: Icons.waving_hand_rounded,
            titulo: 'Hola, soy Cuéntamela',
            texto:
                'Lo llame Cuentamela para que puedas contarme tus gastos o ingresos.'
                'Empecemos por lo más simple: ¿cómo te llamas?',
          ),
          const SizedBox(height: AppEspacios.xl),
          CampoTexto(
            controller: controlador,
            etiqueta: 'Dime tu Nombre',
            hint: 'Por ejemplo, Mensa',
            icono: Icons.person_outline_rounded,
            error: error,
            formateadores: FiltrosEntrada.nombre,
            onSubmitted: (_) => onContinuar(),
          ),
          const Spacer(flex: 2),
          SizedBox(
            width: double.infinity,
            child: BotonPrincipal(
              texto: 'Continuar',
              icono: Icons.arrow_forward_rounded,
              onPressed: onContinuar,
            ),
          ),
          const SizedBox(height: AppEspacios.s),
          Center(
            child: Text(
              'Todo se guarda solo en tu teléfono. Nada sale de aquí.',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ),
        ],
      ),
    );
  }
}

class _PasoDinero extends StatelessWidget {
  const _PasoDinero({
    required this.controlador,
    required this.error,
    required this.cargando,
    required this.nombre,
    required this.onVolver,
    required this.onTerminar,
  });

  final TextEditingController controlador;
  final String? error;
  final bool cargando;
  final String nombre;
  final VoidCallback onVolver;
  final VoidCallback onTerminar;

  @override
  Widget build(BuildContext context) {
    final String primerNombre =
        nombre.trim().isEmpty ? 'amig@' : nombre.trim().split(' ').first;

    return Padding(
      padding: const EdgeInsets.all(AppEspacios.l),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          const Spacer(),
          _Cabecera(
            icono: Icons.account_balance_wallet_rounded,
            titulo: 'Un placer, $primerNombre',
            texto: '¿Cuánto dinero tienes disponible chokit@? '
                'Solo esta vez: de aquí en adelante me lo cuentas por chat.',
          ),
          const SizedBox(height: AppEspacios.xl),
          CampoTexto(
            controller: controlador,
            etiqueta: 'Dinero actual',
            hint: '0,00',
            tipoTeclado: const TextInputType.numberWithOptions(decimal: true),
            formateadores: FiltrosEntrada.monto,
            error: error,
            onSubmitted: (_) => onTerminar(),
            prefijo: Padding(
              padding: const EdgeInsets.only(left: AppEspacios.m),
              child: Text(
                r'Bs ',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: context.colorTextoSuave,
                      fontSize: 18,
                    ),
              ),
            ),
          ),
          const SizedBox(height: AppEspacios.s + 2),
          Row(
            children: <Widget>[
              Icon(Icons.lock_outline_rounded,
                  size: 14, color: context.colorTextoSuave),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  'Podrás editar tu balance cuando quieras desde el Perfil.',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ),
            ],
          ),
          const Spacer(flex: 2),
          SizedBox(
            width: double.infinity,
            child: BotonPrincipal(
              texto: 'Empezar a usarla',
              icono: Icons.check_rounded,
              cargando: cargando,
              onPressed: onTerminar,
            ),
          ),
          const SizedBox(height: AppEspacios.s),
          SizedBox(
            width: double.infinity,
            child: BotonPrincipal(
              texto: 'Atrás',
              secundario: true,
              alto: 48,
              onPressed: cargando ? null : onVolver,
            ),
          ),
        ],
      ),
    );
  }
}
