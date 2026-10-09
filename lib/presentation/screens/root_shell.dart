import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_colors.dart';
import '../providers/navegacion_provider.dart';
import 'chat/chat_screen.dart';
import 'home/home_screen.dart';
import 'profile/profile_screen.dart';

/// Contenedor de las tres pestañas: Inicio, Cuéntamela (chat) y Perfil.
///
/// Las tres se mantienen vivas con un `IndexedStack`: cambiar de pestaña no
/// pierde el estado del chat ni vuelve a construir el Home.
class RootShell extends ConsumerWidget {
  const RootShell({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final int actual = ref.watch(pestanaActualProvider);

    return Scaffold(
      body: IndexedStack(
        index: actual,
        children: const <Widget>[
          HomeScreen(),
          ChatScreen(),
          ProfileScreen(),
        ],
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: context.colorSuperficie,
          border: Border(top: BorderSide(color: context.colorBorde)),
        ),
        child: NavigationBar(
          selectedIndex: actual,
          onDestinationSelected: (int i) =>
              ref.read(pestanaActualProvider.notifier).state = i,
          backgroundColor: Colors.transparent,
          indicatorColor: context.colorMarca.withOpacity(0.14),
          labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
          destinations: const <NavigationDestination>[
            NavigationDestination(
              icon: Icon(Icons.pie_chart_outline_rounded),
              selectedIcon: Icon(Icons.pie_chart_rounded),
              label: 'Inicio',
            ),
            NavigationDestination(
              icon: Icon(Icons.chat_bubble_outline_rounded),
              selectedIcon: Icon(Icons.chat_bubble_rounded),
              label: 'Cuéntamela',
            ),
            NavigationDestination(
              icon: Icon(Icons.person_outline_rounded),
              selectedIcon: Icon(Icons.person_rounded),
              label: 'Perfil',
            ),
          ],
        ),
      ),
    );
  }
}
