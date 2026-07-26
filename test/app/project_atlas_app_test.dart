import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:project_atlas/app/navigation/main_navigation_shell.dart';
import 'package:project_atlas/app/project_atlas_app.dart';
import 'package:project_atlas/core/database/app_database.dart';
import 'package:project_atlas/core/database/database_providers.dart';
import 'package:project_atlas/core/design_system/tokens/app_color_tokens.dart';
import 'package:project_atlas/core/localization/locale_provider.dart';
import 'package:project_atlas/core/repositories/repository_records.dart';
import 'package:project_atlas/features/anatomy/application/anatomy_training_heatmap_controller.dart';
import 'package:project_atlas/features/anatomy/domain/anatomy_training_heatmaps.dart';
import 'package:project_atlas/features/anatomy/presentation/anatomy_screen.dart';
import 'package:project_atlas/features/exercise_catalog/application/exercise_catalog_provider.dart';
import 'package:project_atlas/features/exercise_catalog/domain/exercise_catalog.dart';
import 'package:project_atlas/features/exercise_catalog/presentation/exercise_catalog_screen.dart';
import 'package:project_atlas/features/program/presentation/program_builder_screen.dart';
import 'package:project_atlas/features/program/presentation/program_screen.dart';
import 'package:project_atlas/features/progress/presentation/progress_screen.dart';
import 'package:project_atlas/features/settings/presentation/settings_screen.dart';
import 'package:project_atlas/features/today/presentation/today_screen.dart';

import '../support/test_exercise_catalog.dart';

void main() {
  late ExerciseCatalog testCatalog;

  setUpAll(() {
    testCatalog = loadTestExerciseCatalog();
  });

  Future<void> pumpApp(WidgetTester tester, Locale locale) async {
    final database = AppDatabase.forTesting(NativeDatabase.memory());
    addTearDown(database.close);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          appDatabaseProvider.overrideWithValue(database),
          appLocaleProvider.overrideWithValue(locale),
          exerciseCatalogProvider.overrideWith((ref) => testCatalog),
          anatomyMeasurementRecordsProvider.overrideWith(
            (ref) => Stream.value(const <MeasurementRecord>[]),
          ),
          anatomyTrainingHeatmapsProvider.overrideWith(
            (ref) async => _emptyTrainingHeatmapSet(),
          ),
        ],
        child: const ProjectAtlasApp(),
      ),
    );
    await _pumpRouteFrame(tester);
  }

  testWidgets('renders English primary navigation on the Today route', (
    tester,
  ) async {
    await pumpApp(tester, const Locale('en'));

    expect(find.byKey(TodayScreen.screenKey), findsOneWidget);
    expect(find.text('Today'), findsWidgets);
    expect(find.text('Program'), findsOneWidget);
    expect(find.text('Anatomy'), findsOneWidget);
    expect(find.text('Progress'), findsOneWidget);
    expect(find.text('Profile'), findsOneWidget);
    expect(_navigationBar(tester).selectedIndex, 0);
  });

  testWidgets('renders Turkish primary navigation labels', (tester) async {
    tester.view.physicalSize = const Size(320, 640);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await pumpApp(tester, const Locale('tr'));

    expect(find.byKey(TodayScreen.screenKey), findsOneWidget);
    expect(find.text('Bugün'), findsWidgets);
    expect(find.text('Program'), findsOneWidget);
    expect(find.text('Anatomi'), findsOneWidget);
    expect(find.text('İlerleme'), findsOneWidget);
    expect(find.text('Profil'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('switches branches and keeps visited branches mounted', (
    tester,
  ) async {
    await pumpApp(tester, const Locale('en'));

    final destinations = <(String, Key, String, int)>[
      ('Program', ProgramScreen.screenKey, ProgramScreen.path, 1),
      ('Anatomy', AnatomyScreen.screenKey, AnatomyScreen.path, 2),
      ('Progress', ProgressScreen.screenKey, ProgressScreen.path, 3),
      ('Profile', SettingsScreen.screenKey, SettingsScreen.path, 4),
    ];

    for (final (label, screenKey, path, index) in destinations) {
      await tester.tap(_navigationLabel(label));
      await _pumpRouteFrame(tester);

      expect(find.byKey(screenKey), findsOneWidget);
      expect(_navigationBar(tester).selectedIndex, index);
      expect(
        _router(tester, screenKey).routeInformationProvider.value.uri.path,
        path,
      );
    }

    expect(
      find.byKey(ProgramScreen.screenKey, skipOffstage: false),
      findsOneWidget,
    );
    expect(
      find.byKey(AnatomyScreen.screenKey, skipOffstage: false),
      findsOneWidget,
    );
  });

  testWidgets('supports deep links and redirects the legacy root', (
    tester,
  ) async {
    await pumpApp(tester, const Locale('en'));

    final router = _router(tester, TodayScreen.screenKey);
    router.go(AnatomyScreen.path);
    await _pumpRouteFrame(tester);

    expect(find.byKey(AnatomyScreen.screenKey), findsOneWidget);
    expect(_navigationBar(tester).selectedIndex, 2);

    router.go('/');
    await _pumpRouteFrame(tester);

    expect(find.byKey(TodayScreen.screenKey), findsOneWidget);
    expect(_navigationBar(tester).selectedIndex, 0);
  });

  testWidgets('opens complex tasks from dashboard roots through child routes', (
    tester,
  ) async {
    await pumpApp(tester, const Locale('en'));

    await tester.tap(_navigationLabel('Program'));
    await _pumpRouteFrame(tester);

    expect(find.byKey(ProgramScreen.screenKey), findsOneWidget);
    expect(find.byKey(ProgramScreen.builderTabKey), findsOneWidget);
    expect(
      find.byKey(ProgramBuilderScreen.createProgramButtonKey),
      findsNothing,
    );

    await tester.tap(find.byKey(ProgramScreen.builderTabKey));
    await _pumpRouteFrame(tester);

    expect(find.byKey(ProgramBuilderRouteScreen.screenKey), findsOneWidget);
    expect(
      _router(
        tester,
        ProgramBuilderRouteScreen.screenKey,
      ).routeInformationProvider.value.uri.path,
      ProgramBuilderRouteScreen.path,
    );
    expect(_navigationBar(tester).selectedIndex, 1);

    _router(tester, ProgramBuilderRouteScreen.screenKey).go(ProgramScreen.path);
    await _pumpRouteFrame(tester);
    await tester.ensureVisible(find.byKey(ProgramScreen.catalogTabKey));
    await _pumpRouteFrame(tester);
    await tester.tap(find.byKey(ProgramScreen.catalogTabKey));
    await _pumpRouteFrame(tester);

    expect(find.byKey(ExerciseCatalogScreen.searchFieldKey), findsOneWidget);
    expect(
      _router(
        tester,
        ExerciseCatalogScreen.screenKey,
      ).routeInformationProvider.value.uri.path,
      ExerciseCatalogScreen.path,
    );

    _router(tester, ExerciseCatalogScreen.screenKey).go(SettingsScreen.path);
    await _pumpRouteFrame(tester);

    expect(find.byKey(SettingsScreen.screenKey), findsOneWidget);
    expect(find.byKey(SettingsScreen.setupRouteCardKey), findsOneWidget);
    expect(find.byKey(SettingsScreen.goalDropdownKey), findsNothing);

    await tester.tap(find.byKey(SettingsScreen.setupRouteCardKey));
    await _pumpRouteFrame(tester);

    expect(find.byKey(SettingsSetupScreen.screenKey), findsOneWidget);
    expect(find.byKey(SettingsScreen.goalDropdownKey), findsOneWidget);
    expect(
      _router(
        tester,
        SettingsSetupScreen.screenKey,
      ).routeInformationProvider.value.uri.path,
      SettingsSetupScreen.path,
    );

    _router(tester, SettingsSetupScreen.screenKey).go(ProgressScreen.path);
    await _pumpRouteFrame(tester);

    expect(find.byKey(ProgressScreen.screenKey), findsOneWidget);
    expect(find.byKey(ProgressScreen.historyRouteCardKey), findsOneWidget);
    expect(find.byKey(ProgressScreen.historySectionKey), findsNothing);

    await tester.tap(find.byKey(ProgressScreen.historyRouteCardKey));
    await _pumpRouteFrame(tester);

    expect(find.byKey(ProgressHistoryScreen.screenKey), findsOneWidget);
    expect(
      _router(
        tester,
        ProgressHistoryScreen.screenKey,
      ).routeInformationProvider.value.uri.path,
      ProgressHistoryScreen.path,
    );

    _router(tester, ProgressHistoryScreen.screenKey).go(TodayScreen.path);
    await _pumpRouteFrame(tester);

    expect(find.byKey(TodayScreen.screenKey), findsOneWidget);
    expect(find.byKey(TodayScreen.coachHeroCardKey), findsOneWidget);
    expect(find.byKey(TodayScreen.quickStartButtonKey), findsOneWidget);
    expect(find.byKey(TodayScreen.emptyStateKey), findsOneWidget);
    expect(find.byKey(TodayScreen.workoutRouteCardKey), findsNothing);

    _router(tester, TodayScreen.screenKey).go(TodayWorkoutScreen.path);
    await _pumpRouteFrame(tester);

    expect(find.byKey(TodayWorkoutScreen.screenKey), findsOneWidget);
    expect(find.byKey(TodayScreen.emptyStateKey), findsAtLeastNWidgets(1));
  });

  testWidgets('installs semantic light and dark application themes', (
    tester,
  ) async {
    await pumpApp(tester, const Locale('en'));

    final app = tester.widget<MaterialApp>(find.byType(MaterialApp));

    expect(app.themeMode, ThemeMode.system);
    expect(app.theme?.colorScheme, AppColorTokens.lightScheme);
    expect(app.darkTheme?.colorScheme, AppColorTokens.darkScheme);
  });
}

NavigationBar _navigationBar(WidgetTester tester) {
  return tester.widget<NavigationBar>(
    find.byKey(MainNavigationShell.navigationBarKey),
  );
}

Finder _navigationLabel(String label) {
  return find.descendant(
    of: find.byKey(MainNavigationShell.navigationBarKey),
    matching: find.text(label),
  );
}

GoRouter _router(WidgetTester tester, Key screenKey) {
  return GoRouter.of(tester.element(find.byKey(screenKey)));
}

Future<void> _pumpRouteFrame(WidgetTester tester) async {
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 300));
}

AnatomyTrainingHeatmapSet _emptyTrainingHeatmapSet() {
  final now = DateTime.utc(2026, 7, 26, 12);
  return AnatomyTrainingHeatmapSet(
    ruleSetVersion: anatomyTrainingHeatmapRuleSetVersion,
    generatedAt: now,
    windowStart: now.subtract(defaultAnatomyTrainingHeatmapWindow),
    windowEnd: now,
    evidenceSetCount: 0,
    heatmaps: {
      for (final kind in AnatomyTrainingHeatmapKind.values)
        kind: AnatomyTrainingHeatmap(kind: kind, entries: const []),
    },
  );
}
