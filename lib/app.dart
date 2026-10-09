import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/theme/app_theme.dart';
import 'presentation/providers/usuario_provider.dart';
import 'presentation/screens/onboarding/onboarding_screen.dart';
import 'presentation/screens/root_shell.dart';

/// Raíz de **Cuéntamela**.
///
/// Decide la pantalla de arranque: onboarding (solo la primera vez) o la
/// aplicación con sus tres pestañas.
class CuentamelaApp extends ConsumerWidget {
  const CuentamelaApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ThemeMode modoTema = ref.watch(modoTemaProvider);

    return MaterialApp(
      title: 'Cuéntamela',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.claro,
      darkTheme: AppTheme.oscuro,
      themeMode: modoTema,
      locale: const Locale('es', 'ES'),
      supportedLocales: const <Locale>[
        Locale('es', 'ES'),
        Locale('es', 'MX'),
        Locale('en', 'US'),
      ],
      localizationsDelegates: const <LocalizationsDelegate<dynamic>>[
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      home: const PuertaDeEntrada(),
    );
  }
}

/// Puerta de arranque: lee Hive una sola vez y manda a onboarding o al Home.
class PuertaDeEntrada extends ConsumerWidget {
  const PuertaDeEntrada({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bool onboardingHecho = ref.watch(onboardingCompletadoProvider);

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 320),
      switchInCurve: Curves.easeOutCubic,
      switchOutCurve: Curves.easeInCubic,
      child: onboardingHecho
          ? const RootShell(key: ValueKey<String>('app'))
          : const OnboardingScreen(key: ValueKey<String>('onboarding')),
    );
  }
}
