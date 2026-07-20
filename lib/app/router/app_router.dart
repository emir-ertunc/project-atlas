import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:project_atlas/app/navigation/main_navigation_shell.dart';
import 'package:project_atlas/features/anatomy/presentation/anatomy_screen.dart';
import 'package:project_atlas/features/program/presentation/program_screen.dart';
import 'package:project_atlas/features/progress/presentation/progress_screen.dart';
import 'package:project_atlas/features/settings/presentation/settings_screen.dart';
import 'package:project_atlas/features/today/presentation/today_screen.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  final router = GoRouter(
    initialLocation: _resolvedInitialLocation(),
    restorationScopeId: 'app-router',
    routes: [
      GoRoute(path: '/', redirect: (context, state) => TodayScreen.path),
      StatefulShellRoute.indexedStack(
        restorationScopeId: 'main-navigation',
        builder: (context, state, navigationShell) =>
            MainNavigationShell(navigationShell: navigationShell),
        branches: [
          StatefulShellBranch(
            restorationScopeId: 'today-branch',
            routes: [
              GoRoute(
                path: TodayScreen.path,
                name: TodayScreen.routeName,
                builder: (context, state) => const TodayScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            restorationScopeId: 'program-branch',
            routes: [
              GoRoute(
                path: ProgramScreen.path,
                name: ProgramScreen.routeName,
                builder: (context, state) => const ProgramScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            restorationScopeId: 'anatomy-branch',
            routes: [
              GoRoute(
                path: AnatomyScreen.path,
                name: AnatomyScreen.routeName,
                builder: (context, state) => const AnatomyScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            restorationScopeId: 'progress-branch',
            routes: [
              GoRoute(
                path: ProgressScreen.path,
                name: ProgressScreen.routeName,
                builder: (context, state) => const ProgressScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            restorationScopeId: 'settings-branch',
            routes: [
              GoRoute(
                path: SettingsScreen.path,
                name: SettingsScreen.routeName,
                builder: (context, state) => const SettingsScreen(),
              ),
            ],
          ),
        ],
      ),
    ],
  );

  ref.onDispose(router.dispose);
  return router;
});

const _configuredInitialLocation = String.fromEnvironment(
  'PROJECT_ATLAS_INITIAL_LOCATION',
  defaultValue: TodayScreen.path,
);

String _resolvedInitialLocation() {
  return switch (_configuredInitialLocation) {
    TodayScreen.path => TodayScreen.path,
    ProgramScreen.path => ProgramScreen.path,
    AnatomyScreen.path => AnatomyScreen.path,
    ProgressScreen.path => ProgressScreen.path,
    SettingsScreen.path => SettingsScreen.path,
    _ => TodayScreen.path,
  };
}
