import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:momentumfit/l10n/app_localizations.dart';

import '../../core/theme/app_theme.dart';
import '../../core/widgets/glassy_container.dart';

class MainShell extends ConsumerWidget {
  const MainShell({super.key, required this.child});

  final Widget child;

  int _indexForLocation(String location) {
    if (location.startsWith('/progress')) return 1;
    if (location.startsWith('/settings')) return 2;
    return 0;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final location = GoRouterState.of(context).matchedLocation;
    final index = _indexForLocation(location);
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      extendBody: true,
      body: child,
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          border: Border(
            top: BorderSide(
              color: Colors.white.withOpacity(0.3),
              width: 0.5,
            ),
          ),
        ),
        child: GlassyContainer(
          opacity: 0.8,
          blurStrength: 25.0,
          borderRadius: const BorderRadius.vertical(
            top: Radius.circular(20),
          ),
          border: Border(
            top: BorderSide(
              color: Colors.white.withOpacity(0.4),
              width: 1.0,
            ),
          ),
          child: NavigationBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            selectedIndex: index,
            onDestinationSelected: (i) {
              switch (i) {
                case 0:
                  context.go('/home');
                case 1:
                  context.go('/progress');
                case 2:
                  context.go('/settings');
              }
            },
            destinations: [
              NavigationDestination(
                icon: const Icon(Icons.today_outlined),
                selectedIcon: const Icon(Icons.today, color: AppColors.forest),
                label: l10n.navToday,
              ),
              NavigationDestination(
                icon: const Icon(Icons.insights_outlined),
                selectedIcon: const Icon(Icons.insights, color: AppColors.forest),
                label: l10n.progress,
              ),
              NavigationDestination(
                icon: const Icon(Icons.settings_outlined),
                selectedIcon: const Icon(Icons.settings, color: AppColors.forest),
                label: l10n.settings,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
