import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../features/assessment/assessment_screen.dart';
import '../features/home/home_screen.dart';
import '../features/onboarding/onboarding_screen.dart';
import '../features/progress/progress_screen.dart';
import '../features/settings/settings_screen.dart';
import '../features/shell/main_shell.dart';
import '../features/workout_planner/workout_planner_screen.dart';
import '../providers/app_providers.dart';

final _rootNavigatorKey = GlobalKey<NavigatorState>();
final _shellNavigatorKey = GlobalKey<NavigatorState>();

final routerProvider = Provider<GoRouter>((ref) {
  final refresh = _RouterRefresh(ref);
  ref.onDispose(refresh.dispose);

  return GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: '/home',
    refreshListenable: refresh,
    redirect: (context, state) {
      final profile = ref.read(profileProvider);
      final loc = state.matchedLocation;
      final onboarding = loc.startsWith('/onboarding');
      final assessment = loc.startsWith('/assessment');

      if (profile == null || !profile.onboardingCompleted) {
        return onboarding ? null : '/onboarding';
      }

      if (!profile.assessmentCompleted) {
        if (assessment) return null;
        return '/assessment';
      }

      // Assessment done — leave onboarding/assessment flows.
      if (onboarding || assessment) return '/home';

      return null;
    },
    routes: [
      GoRoute(
        path: '/onboarding',
        builder: (context, state) => const OnboardingScreen(),
      ),
      GoRoute(
        path: '/assessment',
        builder: (context, state) => const AssessmentScreen(),
      ),
      GoRoute(
        path: '/workout-planner',
        builder: (context, state) => const WorkoutPlannerScreen(),
      ),
      ShellRoute(
        navigatorKey: _shellNavigatorKey,
        builder: (context, state, child) => MainShell(child: child),
        routes: [
          GoRoute(
            path: '/home',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: HomeScreen(),
            ),
          ),
          GoRoute(
            path: '/progress',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: ProgressScreen(),
            ),
          ),
          GoRoute(
            path: '/settings',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: SettingsScreen(),
            ),
          ),
        ],
      ),
    ],
  );
});

class _RouterRefresh extends ChangeNotifier {
  _RouterRefresh(this._ref) {
    _subscription = _ref.listen(profileProvider, (previous, next) {
      // Defer so we don't rebuild routes while profileProvider is notifying.
      Future.microtask(notifyListeners);
    });
  }

  final Ref _ref;
  late final ProviderSubscription<dynamic> _subscription;

  @override
  void dispose() {
    _subscription.close();
    super.dispose();
  }
}
