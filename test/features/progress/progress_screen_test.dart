import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:project_atlas/app/navigation/main_navigation_shell.dart';
import 'package:project_atlas/app/project_atlas_app.dart';
import 'package:project_atlas/core/database/app_database.dart';
import 'package:project_atlas/core/database/database_providers.dart';
import 'package:project_atlas/core/localization/locale_provider.dart';
import 'package:project_atlas/core/repositories/repository_providers.dart';
import 'package:project_atlas/core/repositories/repository_records.dart';
import 'package:project_atlas/features/exercise_catalog/application/exercise_catalog_provider.dart';
import 'package:project_atlas/features/exercise_catalog/domain/exercise_catalog.dart';
import 'package:project_atlas/features/program/application/program_draft_persistence.dart';
import 'package:project_atlas/features/progress/application/workout_history_controller.dart';
import 'package:project_atlas/features/progress/presentation/progress_screen.dart';

import '../../support/test_exercise_catalog.dart';

void main() {
  late ExerciseCatalog testCatalog;
  late DateTime now;

  setUpAll(() {
    testCatalog = loadTestExerciseCatalog();
  });

  setUp(() {
    now = DateTime.utc(2026, 7, 20, 10);
  });

  testWidgets('shows a local empty state when no workout history exists', (
    tester,
  ) async {
    await _pumpProgressApp(tester, catalog: testCatalog);

    await tester.tap(_navigationLabel('Progress'));
    await tester.pump();
    await _pumpUntilFound(tester, find.byKey(ProgressScreen.emptyStateKey));

    expect(find.text('No workout history yet'), findsOneWidget);
    expect(
      find.textContaining('Complete sets from the Today tab'),
      findsOneWidget,
    );
  });

  testWidgets('shows workout history, set details, and personal records', (
    tester,
  ) async {
    final database = AppDatabase.forTesting(NativeDatabase.memory());
    addTearDown(database.close);
    await _seedProgramAndHistory(database, now);

    await _pumpProgressApp(tester, catalog: testCatalog, database: database);

    await tester.tap(_navigationLabel('Progress'));
    await tester.pump();
    await _pumpUntilFound(tester, find.byKey(ProgressScreen.historySectionKey));

    expect(
      find.byKey(ProgressScreen.historySessionCardKey('recent-session')),
      findsOneWidget,
    );
    expect(find.text('Workout history'), findsOneWidget);
    expect(find.text('Upper A'), findsWidgets);
    expect(find.textContaining('1 of 1 sets logged'), findsOneWidget);

    await tester.ensureVisible(find.byKey(ProgressScreen.setDetailsSectionKey));
    await tester.pumpAndSettle();

    expect(find.text('Set details'), findsOneWidget);
    expect(find.text('Barbell bench press'), findsWidgets);
    expect(find.textContaining('Target: 6-8 reps'), findsOneWidget);
    expect(find.textContaining('Logged: 8 reps'), findsWidgets);
    expect(find.text('2 revisions'), findsOneWidget);

    await tester.ensureVisible(
      find.byKey(ProgressScreen.personalRecordsSectionKey),
    );
    await tester.pumpAndSettle();

    expect(find.text('Personal records'), findsOneWidget);
    expect(
      find.byKey(ProgressScreen.personalRecordCardKey('barbell_bench_press')),
      findsOneWidget,
    );
    expect(find.text('Best load: 55 kg'), findsOneWidget);
    expect(find.text('Best reps: 8'), findsOneWidget);
    expect(find.text('Best volume: 440 kg reps'), findsOneWidget);
  });

  testWidgets('saves historical corrections as append-only revisions', (
    tester,
  ) async {
    final database = AppDatabase.forTesting(NativeDatabase.memory());
    addTearDown(database.close);
    await _seedProgramAndHistory(database, now);

    await _pumpProgressApp(
      tester,
      catalog: testCatalog,
      database: database,
      clock: () => now.add(const Duration(minutes: 30)),
    );

    await tester.tap(_navigationLabel('Progress'));
    await tester.pump();
    await _pumpUntilFound(
      tester,
      find.byKey(
        ProgressScreen.correctionRepetitionsFieldKey('recent-bench-set-0'),
      ),
    );

    await tester.ensureVisible(
      find.byKey(
        ProgressScreen.correctionRepetitionsFieldKey('recent-bench-set-0'),
      ),
    );
    await tester.pumpAndSettle();
    await tester.enterText(
      find.byKey(
        ProgressScreen.correctionRepetitionsFieldKey('recent-bench-set-0'),
      ),
      '9',
    );
    await tester.enterText(
      find.byKey(ProgressScreen.correctionLoadFieldKey('recent-bench-set-0')),
      '60',
    );
    await tester.enterText(
      find.byKey(ProgressScreen.correctionRirFieldKey('recent-bench-set-0')),
      '0',
    );
    FocusManager.instance.primaryFocus?.unfocus();
    await tester.ensureVisible(
      find.byKey(ProgressScreen.correctionSaveButtonKey('recent-bench-set-0')),
    );
    await tester.pumpAndSettle();
    await tester.tap(
      find.byKey(ProgressScreen.correctionSaveButtonKey('recent-bench-set-0')),
    );
    await tester.pumpAndSettle();
    await _pumpUntilFound(tester, find.text('3 revisions'));

    final logs = await database.select(database.actualSetLogs).get();
    expect(logs, hasLength(3));
    expect(logs.map((log) => log.revision), [1, 2, 3]);
    expect(logs[0].repetitions, 6);
    expect(logs[1].repetitions, 8);
    expect(logs[2].supersedesLogId, 'recent-bench-log-2');
    expect(logs[2].repetitions, 9);
    expect(logs[2].loadKilograms, 60);
    expect(logs[2].rir, 0);

    expect(find.textContaining('Logged: 9 reps'), findsWidgets);
    expect(find.text('Best load: 60 kg'), findsOneWidget);
    expect(find.text('Best reps: 9'), findsOneWidget);
    expect(find.text('Best volume: 540 kg reps'), findsOneWidget);
    expect(
      find.byKey(ProgressScreen.revisionRowKey(logs[0].id)),
      findsOneWidget,
    );
    expect(
      find.byKey(ProgressScreen.revisionRowKey(logs[1].id)),
      findsOneWidget,
    );
    expect(
      find.byKey(ProgressScreen.revisionRowKey(logs[2].id)),
      findsOneWidget,
    );
  });
}

Future<AppDatabase> _pumpProgressApp(
  WidgetTester tester, {
  required ExerciseCatalog catalog,
  AppDatabase? database,
  DateTime Function()? clock,
}) async {
  final appDatabase =
      database ?? AppDatabase.forTesting(NativeDatabase.memory());
  if (database == null) {
    addTearDown(appDatabase.close);
  }

  tester.view.physicalSize = const Size(430, 932);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);

  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        appDatabaseProvider.overrideWithValue(appDatabase),
        appLocaleProvider.overrideWithValue(const Locale('en')),
        exerciseCatalogProvider.overrideWith((ref) => catalog),
        if (clock != null) workoutHistoryClockProvider.overrideWithValue(clock),
      ],
      child: const ProjectAtlasApp(),
    ),
  );
  await tester.pumpAndSettle();

  return appDatabase;
}

Future<void> _seedProgramAndHistory(AppDatabase database, DateTime now) async {
  final container = ProviderContainer(
    overrides: [appDatabaseProvider.overrideWithValue(database)],
  );
  addTearDown(container.dispose);

  await container
      .read(profileRepositoryProvider)
      .saveProfile(
        ProfileRecord(
          id: localProgramProfileId,
          unitPreference: UnitPreference.metric,
          createdAt: now,
          updatedAt: now,
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
          createdAt: now,
          updatedAt: now,
        ),
        ProgramVersionRecord(
          id: 'version-1',
          programId: 'program-1',
          versionNumber: 1,
          lifecycle: ProgramVersionLifecycle.active,
          createdAt: now,
          activatedAt: now,
        ),
        [
          ProgramTrainingDayRecord(
            id: 'training-day-0',
            programVersionId: 'version-1',
            trainingDayOrder: 0,
            name: 'Upper A',
            createdAt: now,
          ),
        ],
        [
          PrescribedSetRecord(
            id: 'upper-bench-0',
            programVersionId: 'version-1',
            trainingDayOrder: 0,
            exerciseId: 'barbell_bench_press',
            exerciseOrder: 0,
            setOrder: 0,
            minimumRepetitions: 6,
            maximumRepetitions: 8,
            targetRir: 2,
            loadKilograms: 50,
            restSeconds: 180,
            progressionStrategy: ProgressionStrategy.doubleProgression,
            createdAt: now,
          ),
        ],
      );

  final repository = container.read(workoutRepositoryProvider);
  final performedAt = now.subtract(const Duration(days: 1));
  final session = WorkoutSessionRecord(
    id: 'recent-session',
    profileId: localProgramProfileId,
    programId: 'program-1',
    programVersionId: 'version-1',
    lifecycle: WorkoutLifecycle.completed,
    scheduledAt: performedAt,
    startedAt: performedAt,
    endedAt: performedAt.add(const Duration(hours: 1)),
    notes: 'Upper A',
    createdAt: performedAt,
    updatedAt: performedAt.add(const Duration(hours: 1)),
  );
  final set = SessionSetRecord(
    id: 'recent-bench-set-0',
    sessionId: session.id,
    prescribedSetId: 'upper-bench-0',
    exerciseId: 'barbell_bench_press',
    exerciseOrder: 0,
    setOrder: 0,
    lifecycle: SetLifecycle.planned,
    createdAt: performedAt,
    updatedAt: performedAt,
  );

  await repository.saveSessionPlan(session, [set]);
  await repository.completeSessionSet(
    SessionSetRecord(
      id: set.id,
      sessionId: set.sessionId,
      prescribedSetId: set.prescribedSetId,
      exerciseId: set.exerciseId,
      exerciseOrder: set.exerciseOrder,
      setOrder: set.setOrder,
      lifecycle: SetLifecycle.completed,
      createdAt: set.createdAt,
      updatedAt: performedAt.add(const Duration(minutes: 5)),
    ),
    ActualSetLogRecord(
      id: 'recent-bench-log-1',
      sessionSetId: set.id,
      revision: 1,
      repetitions: 6,
      loadKilograms: 50,
      rir: 2,
      recordedAt: performedAt.add(const Duration(minutes: 5)),
    ),
  );
  await repository.appendActualSetLog(
    ActualSetLogRecord(
      id: 'recent-bench-log-2',
      sessionSetId: set.id,
      revision: 2,
      repetitions: 8,
      loadKilograms: 55,
      rir: 1,
      supersedesLogId: 'recent-bench-log-1',
      recordedAt: performedAt.add(const Duration(minutes: 8)),
    ),
  );
}

Finder _navigationLabel(String label) {
  return find.descendant(
    of: find.byKey(MainNavigationShell.navigationBarKey),
    matching: find.text(label),
  );
}

Future<void> _pumpUntilFound(WidgetTester tester, Finder finder) async {
  for (var attempt = 0; attempt < 40; attempt += 1) {
    await tester.pump(const Duration(milliseconds: 50));
    if (finder.evaluate().isNotEmpty) {
      return;
    }
  }
  fail('Expected widget was not found: $finder');
}
