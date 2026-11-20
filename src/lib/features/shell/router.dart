import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../providers.dart';
import '../../services/app_lock_state.dart';
import '../activity/activity_screen.dart';
import '../family/family_screen.dart';
import '../home/home_screen.dart';
import '../lock/lock_screen.dart';
import '../member/member_screen.dart';
import '../occasion_detail/occasion_screen.dart';
import '../planner/planner_screen.dart';
import '../reports/reports_screen.dart';
import '../settings/backup_screen.dart';
import '../settings/categories_screen.dart';
import '../settings/notifications_screen.dart';
import '../settings/security_screen.dart';
import '../settings/settings_screen.dart';
import '../settings/sync_screen.dart';
import '../setup/setup_flow.dart';
import 'app_shell.dart';

final _rootKey = GlobalKey<NavigatorState>();

/// Routes from contracts/screens-and-routes.md.
final routerProvider = Provider<GoRouter>((ref) {
  final refresh = ValueNotifier(0);
  ref.listen(setupProvider, (_, _) => refresh.value++);
  ref.listen(appLockProvider, (_, _) => refresh.value++);
  ref.onDispose(refresh.dispose);

  return GoRouter(
    navigatorKey: _rootKey,
    initialLocation: '/',
    refreshListenable: refresh,
    redirect: (context, state) {
      final loc = state.matchedLocation;
      if (ref.read(appLockProvider).locked) {
        return loc == '/lock' ? null : '/lock';
      }
      if (loc == '/lock') return '/';
      final setupDone = ref.read(setupProvider).completed;
      if (!setupDone && !loc.startsWith('/setup')) return '/setup/language';
      if (setupDone && loc.startsWith('/setup')) return '/';
      return null;
    },
    routes: [
      StatefulShellRoute.indexedStack(
        builder: (context, state, shell) => AppShell(shell: shell),
        branches: [
          StatefulShellBranch(routes: [
            GoRoute(path: '/', builder: (_, _) => const HomeScreen()),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(
              path: '/activity',
              builder: (_, s) => ActivityScreen(
                initialType: s.uri.queryParameters['type'],
                initialMember: s.uri.queryParameters['member'],
                initialQuery: s.uri.queryParameters['q'],
              ),
            ),
          ]),
          StatefulShellBranch(
            initialLocation: '/planner/recurring',
            routes: [
              GoRoute(
                path: '/planner/:tab',
                builder: (_, s) =>
                    PlannerScreen(tab: s.pathParameters['tab'] ?? 'recurring'),
              ),
            ],
          ),
          StatefulShellBranch(routes: [
            GoRoute(path: '/reports', builder: (_, _) => const ReportsScreen()),
          ]),
        ],
      ),
      GoRoute(
        path: '/settings',
        parentNavigatorKey: _rootKey,
        builder: (_, _) => const SettingsScreen(),
        routes: [
          GoRoute(
            path: 'categories',
            builder: (_, s) => CategoriesScreen(
                type: s.uri.queryParameters['type'] ?? 'expense'),
          ),
          GoRoute(path: 'backup', builder: (_, _) => const BackupScreen()),
          GoRoute(
              path: 'notifications',
              builder: (_, _) => const NotificationsScreen()),
          GoRoute(path: 'security', builder: (_, _) => const SecurityScreen()),
          GoRoute(path: 'sync', builder: (_, _) => const SyncScreen()),
        ],
      ),
      GoRoute(
        path: '/family',
        parentNavigatorKey: _rootKey,
        builder: (_, _) => const FamilyScreen(),
        routes: [
          GoRoute(
            path: ':memberId',
            builder: (_, s) =>
                MemberScreen(memberId: s.pathParameters['memberId']!),
          ),
        ],
      ),
      GoRoute(
        path: '/occasions/:key',
        parentNavigatorKey: _rootKey,
        builder: (_, s) => OccasionScreen(occasionKey: s.pathParameters['key']!),
      ),
      GoRoute(
        path: '/setup/:step',
        parentNavigatorKey: _rootKey,
        builder: (_, s) => SetupFlow(step: s.pathParameters['step']!),
      ),
      GoRoute(
        path: '/lock',
        parentNavigatorKey: _rootKey,
        builder: (_, _) => const LockScreen(),
      ),
    ],
  );
});
