import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:project_atlas/app/navigation/main_navigation_shell.dart';
import 'package:project_atlas/features/anatomy/presentation/anatomy_screen.dart';
import 'package:project_atlas/features/exercise_catalog/presentation/exercise_catalog_screen.dart';
import 'package:project_atlas/features/exercise_catalog/presentation/exercise_detail_screen.dart';
import 'package:project_atlas/features/program/presentation/program_screen.dart';
import 'package:project_atlas/features/progress/presentation/progress_screen.dart';
import 'package:project_atlas/features/settings/presentation/settings_screen.dart';
import 'package:project_atlas/features/today/presentation/today_screen.dart';
import 'package:project_atlas/l10n/generated/app_localizations.dart';

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
                routes: [
                  GoRoute(
                    path: TodayWorkoutScreen.pathSegment,
                    name: TodayWorkoutScreen.routeName,
                    builder: (context, state) => const TodayWorkoutScreen(),
                  ),
                ],
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
                routes: [
                  GoRoute(
                    path: ProgramBuilderRouteScreen.pathSegment,
                    name: ProgramBuilderRouteScreen.routeName,
                    builder: (context, state) =>
                        const ProgramBuilderRouteScreen(),
                  ),
                  GoRoute(
                    path: ExerciseCatalogScreen.pathSegment,
                    name: ExerciseCatalogScreen.routeName,
                    builder: (context, state) => const ExerciseCatalogScreen(),
                  ),
                  GoRoute(
                    path: 'exercise/:${ExerciseDetailScreen.exerciseIdParam}',
                    name: ExerciseDetailScreen.routeName,
                    builder: (context, state) => ExerciseDetailScreen(
                      exerciseId:
                          state.pathParameters[ExerciseDetailScreen
                              .exerciseIdParam]!,
                    ),
                  ),
                  GoRoute(
                    path: ProgramRecommendationInboxScreen.pathSegment,
                    name: ProgramRecommendationInboxScreen.routeName,
                    builder: (context, state) =>
                        const ProgramRecommendationInboxScreen(),
                  ),
                ],
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
                routes: [
                  GoRoute(
                    path: AnatomyEstimateDetailsScreen.pathSegment,
                    name: AnatomyEstimateDetailsScreen.routeName,
                    builder: (context, state) =>
                        const AnatomyEstimateDetailsScreen(),
                  ),
                ],
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
                routes: [
                  GoRoute(
                    path: ProgressHistoryScreen.pathSegment,
                    name: ProgressHistoryScreen.routeName,
                    builder: (context, state) => const ProgressHistoryScreen(),
                  ),
                  GoRoute(
                    path: ProgressTrendsScreen.pathSegment,
                    name: ProgressTrendsScreen.routeName,
                    builder: (context, state) => const ProgressTrendsScreen(),
                  ),
                  GoRoute(
                    path: ProgressMeasurementReviewScreen.pathSegment,
                    name: ProgressMeasurementReviewScreen.routeName,
                    builder: (context, state) =>
                        const ProgressMeasurementReviewScreen(),
                  ),
                ],
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
                routes: [
                  GoRoute(
                    path: SettingsSetupScreen.pathSegment,
                    name: SettingsSetupScreen.routeName,
                    builder: (context, state) => const SettingsSetupScreen(),
                  ),
                  GoRoute(
                    path: SettingsPreferencePlaceholderScreen.unitsPathSegment,
                    name: SettingsPreferencePlaceholderScreen.unitsRouteName,
                    builder: (context, state) {
                      final l10n = AppLocalizations.of(context);
                      return SettingsPreferencePlaceholderScreen(
                        screenKey: const Key('settings-units-screen'),
                        title: l10n.onboardingSessionLengthLabel,
                        description: l10n.onboardingSessionLengthValue(60),
                        icon: Icons.straighten_outlined,
                      );
                    },
                  ),
                  GoRoute(
                    path:
                        SettingsPreferencePlaceholderScreen.privacyPathSegment,
                    name: SettingsPreferencePlaceholderScreen.privacyRouteName,
                    builder: (context, state) {
                      final l10n = AppLocalizations.of(context);
                      return SettingsPreferencePlaceholderScreen(
                        screenKey: const Key('settings-privacy-screen'),
                        title: l10n.progressMeasurementExportTitle,
                        description: l10n.progressMeasurementExportDescription,
                        icon: Icons.privacy_tip_outlined,
                      );
                    },
                  ),
                ],
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
