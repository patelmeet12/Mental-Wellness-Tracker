import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../features/onboarding/presentation/screens/onboarding_screen.dart';
import '../../features/onboarding/presentation/providers/onboarding_provider.dart';
import '../../features/dashboard/presentation/screens/dashboard_screen.dart';
import '../../features/journal/presentation/screens/journal_entry_screen.dart';
import '../../features/analytics/presentation/screens/analytics_screen.dart';
import '../../features/coach/presentation/screens/coach_screen.dart';
import '../../features/mindfulness/presentation/screens/mindfulness_screen.dart';
import '../widgets/main_layout.dart';

final appRouterHelperProvider = Provider<GoRouter>((ref) {
  // Watch the onboarding state to trigger router redirects when state changes
  final onboardingState = ref.watch(onboardingProvider);

  return GoRouter(
    initialLocation: '/',
    redirect: (context, state) {
      final profile = onboardingState.valueOrNull;
      final isOnboarding = state.matchedLocation == '/onboarding';

      if (profile == null) {
        if (!isOnboarding) {
          return '/onboarding';
        }
      } else {
        if (isOnboarding || state.matchedLocation == '/') {
          return '/dashboard';
        }
      }
      return null;
    },
    routes: [
      GoRoute(
        path: '/onboarding',
        builder: (context, state) => const OnboardingScreen(),
      ),
      ShellRoute(
        builder: (context, state, child) {
          return MainLayout(
            currentRoute: state.matchedLocation,
            child: child,
          );
        },
        routes: [
          GoRoute(
            path: '/dashboard',
            builder: (context, state) => const DashboardScreen(),
          ),
          GoRoute(
            path: '/journal',
            builder: (context, state) => const JournalEntryScreen(),
          ),
          GoRoute(
            path: '/analytics',
            builder: (context, state) => const AnalyticsScreen(),
          ),
          GoRoute(
            path: '/coach',
            builder: (context, state) => const CoachScreen(),
          ),
          GoRoute(
            path: '/mindfulness',
            builder: (context, state) => const MindfulnessScreen(),
          ),
        ],
      ),
    ],
  );
});
