import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:project_atlas/app/navigation/main_navigation_shell.dart';
import 'package:project_atlas/app/project_atlas_app.dart';
import 'package:project_atlas/app/router/app_router.dart';
import 'package:project_atlas/core/database/app_database.dart';
import 'package:project_atlas/core/database/database_providers.dart';
import 'package:project_atlas/core/design_system/app_theme.dart';
import 'package:project_atlas/core/design_system/components/feature_root_scaffold.dart';
import 'package:project_atlas/core/design_system/tokens/app_component_tokens.dart';
import 'package:project_atlas/core/localization/locale_provider.dart';
import 'package:project_atlas/core/repositories/repository_records.dart';
import 'package:project_atlas/features/anatomy/application/anatomy_training_heatmap_controller.dart';
import 'package:project_atlas/features/anatomy/domain/anatomy_training_heatmaps.dart';
import 'package:project_atlas/features/anatomy/presentation/anatomy_renderer_panel.dart';
import 'package:project_atlas/features/anatomy/presentation/anatomy_screen.dart';
import 'package:project_atlas/features/exercise_catalog/application/exercise_catalog_provider.dart';
import 'package:project_atlas/features/exercise_catalog/domain/exercise_catalog.dart';
import 'package:project_atlas/features/program/presentation/program_screen.dart';
import 'package:project_atlas/features/progress/presentation/progress_screen.dart';
import 'package:project_atlas/features/settings/presentation/settings_screen.dart';
import 'package:project_atlas/features/today/presentation/today_screen.dart';
import 'package:project_atlas/l10n/generated/app_localizations.dart';

import '../support/test_exercise_catalog.dart';

void main() {
  late ExerciseCatalog testCatalog;

  setUpAll(() {
    testCatalog = loadTestExerciseCatalog();
  });

  Future<void> pumpApp(
    WidgetTester tester, {
    double textScaleFactor = 1,
  }) async {
    final database = AppDatabase.forTesting(NativeDatabase.memory());
    addTearDown(database.close);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          appDatabaseProvider.overrideWithValue(database),
          appLocaleProvider.overrideWithValue(const Locale('en')),
          exerciseCatalogProvider.overrideWith((ref) => testCatalog),
          anatomyMeasurementRecordsProvider.overrideWith(
            (ref) => Stream.value(const <MeasurementRecord>[]),
          ),
          anatomyTrainingHeatmapsProvider.overrideWith(
            (ref) async => _emptyTrainingHeatmapSet(),
          ),
        ],
        child: textScaleFactor == 1
            ? const ProjectAtlasApp()
            : _TextScaleProjectAtlasApp(textScaleFactor: textScaleFactor),
      ),
    );
    await _pumpRouteFrame(tester);
  }

  testWidgets('primary shell keeps labels, semantics, and tap targets', (
    tester,
  ) async {
    final semantics = tester.ensureSemantics();

    try {
      tester.view.physicalSize = const Size(360, 800);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await pumpApp(tester);

      final navigationBarRect = tester.getRect(
        find.byKey(MainNavigationShell.navigationBarKey),
      );
      expect(
        navigationBarRect.height,
        greaterThanOrEqualTo(AppComponentTokens.navigationBarHeight),
      );
      expect(
        navigationBarRect.width / 5,
        greaterThanOrEqualTo(AppComponentTokens.minimumTouchTarget),
      );

      for (final label in const [
        'Today',
        'Program',
        'Anatomy',
        'Progress',
        'Profile',
      ]) {
        expect(_navigationLabel(label), findsOneWidget);
      }

      final headerNode = tester.getSemantics(
        find.byKey(FeatureRootScaffold.placeholderTitleKey),
      );
      expect(headerNode.label, 'Today');
      expect(headerNode.flagsCollection.isHeader, isTrue);
    } finally {
      semantics.dispose();
    }
  });

  testWidgets('complete phase-one screens tolerate large text scaling', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await pumpApp(tester, textScaleFactor: 2);
    expect(tester.takeException(), isNull);

    final router = GoRouter.of(
      tester.element(find.byKey(TodayScreen.screenKey)),
    );
    final routes = <String, ({String path, Key screenKey})>{
      'Program': (path: ProgramScreen.path, screenKey: ProgramScreen.screenKey),
      'Anatomy': (path: AnatomyScreen.path, screenKey: AnatomyScreen.screenKey),
      'Progress': (
        path: ProgressScreen.path,
        screenKey: ProgressScreen.screenKey,
      ),
      'Profile': (
        path: SettingsScreen.path,
        screenKey: SettingsScreen.screenKey,
      ),
    };

    for (final MapEntry(key: label, value: route) in routes.entries) {
      router.go(route.path);
      await _pumpRouteFrame(tester);
      expect(
        tester.takeException(),
        isNull,
        reason: 'Large text overflow on $label',
      );
      expect(find.byKey(route.screenKey), findsOneWidget);
    }

    router.go(TodayScreen.path);
    await _pumpRouteFrame(tester);
    expect(tester.takeException(), isNull);
    expect(find.byKey(TodayScreen.screenKey), findsOneWidget);
  });

  testWidgets('anatomy controls preserve accessible touch targets', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await pumpApp(tester);
    GoRouter.of(
      tester.element(find.byKey(TodayScreen.screenKey)),
    ).go(AnatomyScreen.path);
    await _pumpRouteFrame(tester);

    for (final key in const [
      AnatomyRendererPanel.resetCameraButtonKey,
      AnatomyRendererPanel.heatmapPreviewButtonKey,
    ]) {
      final size = tester.getSize(find.byKey(key));
      expect(size.height, greaterThanOrEqualTo(48));
      expect(size.width, greaterThanOrEqualTo(48));
    }
  });

  testWidgets('redesigned primary actions preserve touch targets', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await pumpApp(tester);
    final router = GoRouter.of(
      tester.element(find.byKey(TodayScreen.screenKey)),
    );

    await _expectMinimumTouchTarget(tester, TodayScreen.quickStartButtonKey);

    router.go(ProgramScreen.path);
    await _pumpRouteFrame(tester);
    for (final key in const [
      ProgramScreen.builderTabKey,
      ProgramScreen.catalogTabKey,
      ProgramScreen.recommendationInboxRouteCardKey,
    ]) {
      await _expectMinimumTouchTarget(tester, key);
    }

    router.go(AnatomyScreen.path);
    await _pumpRouteFrame(tester);
    for (final key in const [
      AnatomyRendererPanel.resetCameraButtonKey,
      AnatomyRendererPanel.heatmapPreviewButtonKey,
      AnatomyScreen.measurementPromptButtonKey,
    ]) {
      await _expectMinimumTouchTarget(tester, key);
    }

    router.go(ProgressScreen.path);
    await _pumpRouteFrame(tester);
    for (final key in const [
      ProgressScreen.historyRouteCardKey,
      ProgressScreen.trendsRouteCardKey,
      ProgressScreen.measurementRouteCardKey,
    ]) {
      await _expectMinimumTouchTarget(tester, key);
    }

    router.go(SettingsScreen.path);
    await _pumpRouteFrame(tester);
    for (final key in const [
      SettingsScreen.setupRouteCardKey,
      SettingsScreen.unitsRouteCardKey,
      SettingsScreen.privacyRouteCardKey,
    ]) {
      await _expectMinimumTouchTarget(tester, key);
    }
  });
}

Finder _navigationLabel(String label) {
  return find.descendant(
    of: find.byKey(MainNavigationShell.navigationBarKey),
    matching: find.text(label),
  );
}

Future<void> _pumpRouteFrame(WidgetTester tester) async {
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 300));
}

Future<void> _expectMinimumTouchTarget(WidgetTester tester, Key key) async {
  final finder = find.byKey(key);
  await tester.ensureVisible(finder);
  await tester.pump();

  final size = tester.getSize(finder);
  expect(size.height, greaterThanOrEqualTo(48), reason: '$key height');
  expect(size.width, greaterThanOrEqualTo(48), reason: '$key width');
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

class _TextScaleProjectAtlasApp extends ConsumerWidget {
  const _TextScaleProjectAtlasApp({required this.textScaleFactor});

  final double textScaleFactor;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(appRouterProvider);
    final locale = ref.watch(appLocaleProvider);

    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      restorationScopeId: 'project-atlas-large-text-test-app',
      onGenerateTitle: (context) => AppLocalizations.of(context).appTitle,
      locale: locale,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: ThemeMode.system,
      routerConfig: router,
      builder: (context, child) {
        final mediaQuery = MediaQuery.of(context);
        return MediaQuery(
          data: mediaQuery.copyWith(
            textScaler: TextScaler.linear(textScaleFactor),
          ),
          child: child ?? const SizedBox.shrink(),
        );
      },
    );
  }
}
