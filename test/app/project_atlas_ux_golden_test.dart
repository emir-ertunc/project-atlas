import 'dart:typed_data';

import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:project_atlas/app/router/app_router.dart';
import 'package:project_atlas/core/database/app_database.dart';
import 'package:project_atlas/core/database/database_providers.dart';
import 'package:project_atlas/core/design_system/app_theme.dart';
import 'package:project_atlas/core/localization/locale_provider.dart';
import 'package:project_atlas/core/repositories/repository_providers.dart';
import 'package:project_atlas/core/repositories/repository_records.dart';
import 'package:project_atlas/features/anatomy/application/anatomy_training_heatmap_controller.dart';
import 'package:project_atlas/features/anatomy/domain/anatomy_training_heatmaps.dart';
import 'package:project_atlas/features/anatomy/presentation/anatomy_screen.dart';
import 'package:project_atlas/features/exercise_catalog/application/exercise_catalog_provider.dart';
import 'package:project_atlas/features/exercise_catalog/domain/exercise_catalog.dart';
import 'package:project_atlas/features/program/application/program_draft_persistence.dart';
import 'package:project_atlas/features/program/presentation/program_screen.dart';
import 'package:project_atlas/features/progress/presentation/progress_screen.dart';
import 'package:project_atlas/features/settings/presentation/settings_screen.dart';
import 'package:project_atlas/features/today/application/today_workout_controller.dart';
import 'package:project_atlas/features/today/presentation/today_screen.dart';
import 'package:project_atlas/l10n/generated/app_localizations.dart';

import '../support/test_exercise_catalog.dart';

const _goldenRootKey = Key('project-atlas-ux-golden-root');
final _goldenNow = DateTime.utc(2026, 7, 26, 9);
const _goldenSize = Size(390, 844);
const _goldenPrecisionTolerance = 0.01;

void main() {
  late ExerciseCatalog testCatalog;
  late GoldenFileComparator defaultGoldenFileComparator;

  setUpAll(() {
    testCatalog = loadTestExerciseCatalog();
    defaultGoldenFileComparator = goldenFileComparator;
    goldenFileComparator = _TolerantGoldenFileComparator(
      Uri.parse('test/app/project_atlas_ux_golden_test.dart'),
      precisionTolerance: _goldenPrecisionTolerance,
    );
  });

  tearDownAll(() {
    goldenFileComparator = defaultGoldenFileComparator;
  });

  for (final scenario in _goldenScenarios) {
    testWidgets('P7 UX golden ${scenario.name}', (tester) async {
      debugDisableShadows = true;
      addTearDown(() {
        debugDisableShadows = false;
      });

      tester.view.physicalSize = _goldenSize;
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      final database = AppDatabase.forTesting(NativeDatabase.memory());
      addTearDown(database.close);
      await scenario.seed?.call(database);

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            appDatabaseProvider.overrideWithValue(database),
            appLocaleProvider.overrideWithValue(scenario.locale),
            exerciseCatalogProvider.overrideWith((ref) => testCatalog),
            todayClockProvider.overrideWithValue(() => _goldenNow),
            anatomyMeasurementRecordsProvider.overrideWith(
              (ref) => Stream.value(const <MeasurementRecord>[]),
            ),
            anatomyTrainingHeatmapsProvider.overrideWith(
              (ref) async => _emptyTrainingHeatmapSet(),
            ),
          ],
          child: RepaintBoundary(
            key: _goldenRootKey,
            child: _GoldenProjectAtlasApp(
              themeMode: scenario.themeMode,
              textScaleFactor: scenario.textScaleFactor,
            ),
          ),
        ),
      );
      await _pumpGoldenFrame(tester);

      final router = GoRouter.of(
        tester.element(find.byKey(TodayScreen.screenKey)),
      );
      if (scenario.path != TodayScreen.path) {
        router.go(scenario.path);
        await _pumpGoldenFrame(tester);
      }

      expect(tester.takeException(), isNull);
      await expectLater(
        find.byKey(_goldenRootKey),
        matchesGoldenFile('goldens/p7/${scenario.fileName}.png'),
      );
    });
  }
}

final class _TolerantGoldenFileComparator extends LocalFileComparator {
  _TolerantGoldenFileComparator(
    super.testFile, {
    required double precisionTolerance,
  }) : assert(
         0 <= precisionTolerance && precisionTolerance <= 1,
         'precisionTolerance must be between 0 and 1',
       ),
       _precisionTolerance = precisionTolerance;

  final double _precisionTolerance;

  @override
  Future<bool> compare(Uint8List imageBytes, Uri golden) async {
    final result = await GoldenFileComparator.compareLists(
      imageBytes,
      await getGoldenBytes(golden),
    );

    final passed = result.passed || result.diffPercent <= _precisionTolerance;
    if (passed) {
      result.dispose();
      return true;
    }

    final error = await generateFailureOutput(result, golden, basedir);
    result.dispose();
    throw FlutterError(error);
  }
}

typedef _GoldenSeed = Future<void> Function(AppDatabase database);

final class _GoldenScenario {
  const _GoldenScenario({
    required this.name,
    required this.fileName,
    required this.path,
    required this.locale,
    required this.themeMode,
    required this.textScaleFactor,
    this.seed,
  });

  final String name;
  final String fileName;
  final String path;
  final Locale locale;
  final ThemeMode themeMode;
  final double textScaleFactor;
  final _GoldenSeed? seed;
}

final _goldenScenarios = <_GoldenScenario>[
  _GoldenScenario(
    name: 'today empty English light',
    fileName: 'today_empty.en.light.1x',
    path: TodayScreen.path,
    locale: const Locale('en'),
    themeMode: ThemeMode.light,
    textScaleFactor: 1,
  ),
  _GoldenScenario(
    name: 'today active Turkish light',
    fileName: 'today_active.tr.light.1x',
    path: TodayScreen.path,
    locale: const Locale('tr'),
    themeMode: ThemeMode.light,
    textScaleFactor: 1,
    seed: _seedActiveProgramWithStreak,
  ),
  _GoldenScenario(
    name: 'today pending English dark large text',
    fileName: 'today_pending.en.dark.2x',
    path: TodayScreen.path,
    locale: const Locale('en'),
    themeMode: ThemeMode.dark,
    textScaleFactor: 2,
    seed: _seedPendingWorkout,
  ),
  _GoldenScenario(
    name: 'active workout Turkish dark',
    fileName: 'active_workout.tr.dark.1x',
    path: TodayWorkoutScreen.path,
    locale: const Locale('tr'),
    themeMode: ThemeMode.dark,
    textScaleFactor: 1,
    seed: _seedPendingWorkout,
  ),
  _GoldenScenario(
    name: 'program empty Turkish light large text',
    fileName: 'program_empty.tr.light.2x',
    path: ProgramScreen.path,
    locale: const Locale('tr'),
    themeMode: ThemeMode.light,
    textScaleFactor: 2,
  ),
  _GoldenScenario(
    name: 'program active English dark',
    fileName: 'program_active.en.dark.1x',
    path: ProgramScreen.path,
    locale: const Locale('en'),
    themeMode: ThemeMode.dark,
    textScaleFactor: 1,
    seed: _seedActiveProgramWithStreak,
  ),
  _GoldenScenario(
    name: 'anatomy missing measurement English dark large text',
    fileName: 'anatomy_missing.en.dark.2x',
    path: AnatomyScreen.path,
    locale: const Locale('en'),
    themeMode: ThemeMode.dark,
    textScaleFactor: 2,
  ),
  _GoldenScenario(
    name: 'progress overview Turkish light',
    fileName: 'progress_overview.tr.light.1x',
    path: ProgressScreen.path,
    locale: const Locale('tr'),
    themeMode: ThemeMode.light,
    textScaleFactor: 1,
  ),
  _GoldenScenario(
    name: 'profile hub English dark',
    fileName: 'profile_hub.en.dark.1x',
    path: SettingsScreen.path,
    locale: const Locale('en'),
    themeMode: ThemeMode.dark,
    textScaleFactor: 1,
  ),
  _GoldenScenario(
    name: 'profile setup Turkish light large text',
    fileName: 'profile_setup.tr.light.2x',
    path: SettingsSetupScreen.path,
    locale: const Locale('tr'),
    themeMode: ThemeMode.light,
    textScaleFactor: 2,
  ),
];

class _GoldenProjectAtlasApp extends ConsumerWidget {
  const _GoldenProjectAtlasApp({
    required this.themeMode,
    required this.textScaleFactor,
  });

  final ThemeMode themeMode;
  final double textScaleFactor;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(appRouterProvider);
    final locale = ref.watch(appLocaleProvider);

    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      restorationScopeId: 'project-atlas-ux-golden-app',
      onGenerateTitle: (context) => AppLocalizations.of(context).appTitle,
      locale: locale,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: themeMode,
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

Future<void> _pumpGoldenFrame(WidgetTester tester) async {
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 900));
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

Future<void> _seedActiveProgramWithStreak(AppDatabase database) async {
  await _seedActiveProgram(database);
  await _seedCompletedSession(
    database,
    _goldenNow,
    id: 'completed-today',
    notes: 'Upper A',
  );
  await _seedCompletedSession(
    database,
    _goldenNow.subtract(const Duration(days: 1)),
    id: 'completed-yesterday',
    notes: 'Lower A',
  );
}

Future<void> _seedPendingWorkout(AppDatabase database) async {
  await _seedActiveProgram(database);

  final container = ProviderContainer(
    overrides: [appDatabaseProvider.overrideWithValue(database)],
  );
  try {
    final session = WorkoutSessionRecord(
      id: 'active-session',
      profileId: localProgramProfileId,
      programId: 'program-1',
      programVersionId: 'version-1',
      lifecycle: WorkoutLifecycle.inProgress,
      scheduledAt: _goldenNow,
      startedAt: _goldenNow,
      notes: 'Upper A',
      createdAt: _goldenNow,
      updatedAt: _goldenNow,
    );
    final firstSet = SessionSetRecord(
      id: 'active-set-0',
      sessionId: session.id,
      prescribedSetId: 'upper-bench-0',
      exerciseId: 'barbell_bench_press',
      exerciseOrder: 0,
      setOrder: 0,
      lifecycle: SetLifecycle.completed,
      createdAt: _goldenNow,
      updatedAt: _goldenNow.add(const Duration(minutes: 5)),
    );
    final secondSet = SessionSetRecord(
      id: 'active-set-1',
      sessionId: session.id,
      prescribedSetId: 'upper-bench-1',
      exerciseId: 'barbell_bench_press',
      exerciseOrder: 0,
      setOrder: 1,
      lifecycle: SetLifecycle.planned,
      createdAt: _goldenNow,
      updatedAt: _goldenNow,
    );

    final repository = container.read(workoutRepositoryProvider);
    await repository.saveSessionPlan(session, [firstSet, secondSet]);
    await repository.completeSessionSet(
      firstSet,
      ActualSetLogRecord(
        id: 'active-log-0',
        sessionSetId: firstSet.id,
        revision: 1,
        repetitions: 6,
        loadKilograms: 50,
        rir: 2,
        recordedAt: _goldenNow.add(const Duration(minutes: 5)),
      ),
    );
  } finally {
    container.dispose();
  }
}

Future<void> _seedActiveProgram(AppDatabase database) async {
  final container = ProviderContainer(
    overrides: [appDatabaseProvider.overrideWithValue(database)],
  );
  try {
    await container
        .read(profileRepositoryProvider)
        .saveProfile(
          ProfileRecord(
            id: localProgramProfileId,
            unitPreference: UnitPreference.metric,
            createdAt: _goldenNow,
            updatedAt: _goldenNow,
          ),
        );
    await container
        .read(programRepositoryProvider)
        .saveProgramSnapshot(
          ProgramRecord(
            id: 'program-1',
            profileId: localProgramProfileId,
            name: 'Strength Base',
            lifecycle: ProgramLifecycle.active,
            createdAt: _goldenNow,
            updatedAt: _goldenNow,
          ),
          ProgramVersionRecord(
            id: 'version-1',
            programId: 'program-1',
            versionNumber: 1,
            lifecycle: ProgramVersionLifecycle.active,
            createdAt: _goldenNow,
            activatedAt: _goldenNow,
          ),
          [
            _trainingDay(order: 0, name: 'Upper A'),
            _trainingDay(order: 1, name: 'Lower A'),
          ],
          [
            for (var index = 0; index < 3; index += 1)
              _prescribedSet(
                id: 'upper-bench-$index',
                trainingDayOrder: 0,
                exerciseId: 'barbell_bench_press',
                exerciseOrder: 0,
                setOrder: index,
              ),
            for (var index = 0; index < 2; index += 1)
              _prescribedSet(
                id: 'lower-squat-$index',
                trainingDayOrder: 1,
                exerciseId: 'barbell_back_squat',
                exerciseOrder: 0,
                setOrder: index,
              ),
          ],
          retireActiveVersions: true,
        );
  } finally {
    container.dispose();
  }
}

Future<void> _seedCompletedSession(
  AppDatabase database,
  DateTime completedAt, {
  required String id,
  required String notes,
}) async {
  final container = ProviderContainer(
    overrides: [appDatabaseProvider.overrideWithValue(database)],
  );
  try {
    await container
        .read(workoutRepositoryProvider)
        .saveSessionPlan(
          WorkoutSessionRecord(
            id: id,
            profileId: localProgramProfileId,
            programId: 'program-1',
            programVersionId: 'version-1',
            lifecycle: WorkoutLifecycle.completed,
            scheduledAt: completedAt,
            startedAt: completedAt,
            endedAt: completedAt.add(const Duration(hours: 1)),
            notes: notes,
            createdAt: completedAt,
            updatedAt: completedAt.add(const Duration(hours: 1)),
          ),
          const [],
        );
  } finally {
    container.dispose();
  }
}

ProgramTrainingDayRecord _trainingDay({
  required int order,
  required String name,
}) {
  return ProgramTrainingDayRecord(
    id: 'training-day-$order',
    programVersionId: 'version-1',
    trainingDayOrder: order,
    name: name,
    createdAt: _goldenNow,
  );
}

PrescribedSetRecord _prescribedSet({
  required String id,
  required int trainingDayOrder,
  required String exerciseId,
  required int exerciseOrder,
  required int setOrder,
}) {
  return PrescribedSetRecord(
    id: id,
    programVersionId: 'version-1',
    trainingDayOrder: trainingDayOrder,
    exerciseId: exerciseId,
    exerciseOrder: exerciseOrder,
    setOrder: setOrder,
    minimumRepetitions: 6,
    maximumRepetitions: 8,
    targetRir: 2,
    loadKilograms: 50,
    restSeconds: 180,
    progressionStrategy: ProgressionStrategy.doubleProgression,
    createdAt: _goldenNow,
  );
}
