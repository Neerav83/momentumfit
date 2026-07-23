import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:glassy_blob_nav/glassy_blob_nav.dart';
import 'package:go_router/go_router.dart';
import 'package:momentumfit/l10n/app_localizations.dart';

import '../../core/theme/app_theme.dart';

/// Hosts tab content with [GlassyBlobNav] floating over the page (liquid glass).
class MainShell extends ConsumerWidget {
  const MainShell({super.key, required this.child});

  final Widget child;

  /// Space so list content can scroll under the floating glass pill.
  static const bottomContentInset = 120.0;

  int _indexForLocation(String location) {
    if (location.startsWith('/progress')) return 1;
    if (location.startsWith('/settings')) return 2;
    return 0;
  }

  void _go(BuildContext context, int index) {
    switch (index) {
      case 0:
        context.go('/home');
      case 1:
        context.go('/progress');
      case 2:
        context.go('/settings');
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final location = GoRouterState.of(context).matchedLocation;
    final index = _indexForLocation(location);
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: AppColors.sand,
      body: Stack(
        fit: StackFit.expand,
        children: [
          child,
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: GlassyBlobNav(
              currentIndex: index,
              enableScrollShrink: true,
              onTap: (i) => _go(context, i),
              style: GlassyBlobStyle(
                enableGlass: true,
                blurSigma: 10,
                glassSheen: true,
                activeIconColor: AppColors.forest,
                inactiveIconColor: AppColors.muted.withValues(alpha: 0.75),
                containerColor: Colors.white.withValues(alpha: 0.55),
                blobColor: Colors.white.withValues(alpha: 0.78),
                margin: const EdgeInsets.fromLTRB(16, 0, 16, 4),
              ),
              items: [
                GlassyBlobItem(
                  label: l10n.navToday,
                  icon: (context, color, size) => Icon(
                    CupertinoIcons.calendar,
                    color: color,
                    size: size,
                  ),
                  activeIcon: (context, color, size) => Icon(
                    CupertinoIcons.calendar_today,
                    color: color,
                    size: size,
                  ),
                ),
                GlassyBlobItem(
                  label: l10n.progress,
                  icon: (context, color, size) => Icon(
                    CupertinoIcons.chart_bar,
                    color: color,
                    size: size,
                  ),
                  activeIcon: (context, color, size) => Icon(
                    CupertinoIcons.chart_bar_fill,
                    color: color,
                    size: size,
                  ),
                ),
                GlassyBlobItem(
                  label: l10n.settings,
                  icon: (context, color, size) => Icon(
                    CupertinoIcons.gear,
                    color: color,
                    size: size,
                  ),
                  activeIcon: (context, color, size) => Icon(
                    CupertinoIcons.gear_alt_fill,
                    color: color,
                    size: size,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
