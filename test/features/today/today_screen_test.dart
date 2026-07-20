import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:project_atlas/app/project_atlas_app.dart';
import 'package:project_atlas/core/database/app_database.dart';
import 'package:project_atlas/core/database/database_providers.dart';
import 'package:project_atlas/core/database/tables/session_sets.dart';
import 'package:project_atlas/core/database/tables/workout_sessions.dart';
import 'package:project_atlas/core/localization/locale_provider.dart';
import 'package:project_atlas/core/repositories/repository_providers.dart';
import 'package:project_atlas/core/repositories/repository_records.dart';
import 'package:project_atlas/features/exercise_catalog/application/exercise_catalog_provider.dart';
import 'package:project_atlas/features/exercise_catalog/domain/exercise_catalog.dart';
import 'package:project_atlas/features/program/application/program_draft_persistence.dart';
import 'package:project_atlas/features/program/presentation/program_screen.dart';
import 'package:project_atlas/features/today/application/rest_timer_controller.dart';
import 'package:project_atlas/features/today/application/today_workout_controller.dart';
import 'package:project_atlas/features/today/platform/rest_notification_scheduler.dart';
import 'package:project_atlas/features/today/presentation/today_screen.dart';

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

  testWidgets('shows a local empty state when no active program exists', (
    tester,
  ) async {
    final database = await _pumpTodayApp(
      tester,
      catalog: testCatalog,
      now: now,
    );

    await _pumpUntilFound(tester, find.byKey(TodayScreen.emptyStateKey));

    expect(find.text('No active program yet'), findsOneWidget);

    await tester.tap(find.text('Open Program'));
    await tester.pumpAndSettle();

    expect(find.byKey(ProgramScreen.screenKey), findsOneWidget);
    expect(await database.select(database.workoutSessions).get(), isEmpty);
  });

  testWidgets(
    'starts a workout session from the selected active training day',
    (tester) async {
      final database = AppDatabase.forTesting(NativeDatabase.memory());
      addTearDown(database.close);
      await _seedActiveProgram(database, now);

      await _pumpTodayApp(
        tester,
        catalog: testCatalog,
        now: now,
        database: database,
        restNotificationScheduler: _FakeRestNotificationScheduler(),
      );
      await _pumpUntilFound(
        tester,
        find.byKey(TodayScreen.activeProgramCardKey),
      );

      expect(find.text('Strength Base'), findsOneWidget);
      expect(find.text('Upper A'), findsWidgets);
      expect(find.text('Lower A'), findsOneWidget);

      await tester.tap(find.byKey(TodayScreen.trainingDayChipKey(1)));
      await tester.pump();

      expect(
        find.byKey(TodayScreen.exercisePlanTileKey('barbell_back_squat')),
        findsOneWidget,
      );

      await tester.tap(find.byKey(TodayScreen.startSessionButtonKey));
      await tester.pump();
      await _pumpUntilFound(
        tester,
        find.byKey(TodayScreen.activeSessionCardKey),
      );

      final sessions = await database.select(database.workoutSessions).get();
      final sessionSets = await database.select(database.sessionSets).get();

      expect(sessions, hasLength(1));
      expect(sessions.single.status, WorkoutSessionStatus.inProgress);
      expect(sessions.single.profileId, localProgramProfileId);
      expect(sessions.single.programId, 'program-1');
      expect(sessions.single.programVersionId, 'version-1');
      expect(sessions.single.notes, 'Lower A');
      expect(sessions.single.startedAt?.toUtc(), now);

      expect(sessionSets, hasLength(2));
      expect(
        sessionSets.every(
          (set) =>
              set.status == SessionSetStatus.planned &&
              set.exerciseId == 'barbell_back_squat' &&
              set.prescribedSetId != null,
        ),
        isTrue,
      );

      final startButton = tester.widget<FilledButton>(
        find.byKey(TodayScreen.startSessionButtonKey),
      );
      expect(startButton.onPressed, isNull);

      final firstSetId = sessionSets.singleWhere((set) => set.setOrder == 0).id;
      await tester.ensureVisible(
        find.byKey(TodayScreen.actualRepetitionsFieldKey(firstSetId)),
      );
      await tester.pumpAndSettle();
      await tester.enterText(
        find.byKey(TodayScreen.actualRepetitionsFieldKey(firstSetId)),
        '7',
      );
      await tester.ensureVisible(
        find.byKey(TodayScreen.quickLoadIncreaseButtonKey(firstSetId)),
      );
      await tester.tap(
        find.byKey(TodayScreen.quickLoadIncreaseButtonKey(firstSetId)),
      );
      await tester.pump();
      expect(_loadFieldText(tester, firstSetId), '52.5');
      await tester.enterText(
        find.byKey(TodayScreen.actualRirFieldKey(firstSetId)),
        '1',
      );
      await tester.ensureVisible(
        find.byKey(TodayScreen.outcomeFieldKey(firstSetId)),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(TodayScreen.outcomeFieldKey(firstSetId)));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Technique limitation').last);
      await tester.pumpAndSettle();
      FocusManager.instance.primaryFocus?.unfocus();
      await tester.ensureVisible(
        find.byKey(TodayScreen.completeSetButtonKey(firstSetId)),
      );
      await tester.pumpAndSettle();
      await tester.tap(
        find.byKey(TodayScreen.completeSetButtonKey(firstSetId)),
      );
      await tester.pump();
      await _pumpUntilFound(
        tester,
        find.byKey(TodayScreen.completedSetStatusKey(firstSetId)),
      );
      await _pumpUntilFound(tester, find.byKey(TodayScreen.restTimerPanelKey));
      await _pumpUntilFound(tester, find.byKey(TodayScreen.sessionStatusKey));

      final refreshedSets = await database.select(database.sessionSets).get();
      final loggedSet = refreshedSets.singleWhere(
        (set) => set.id == firstSetId,
      );
      final logs = await database.select(database.actualSetLogs).get();

      expect(loggedSet.status, SessionSetStatus.completed);
      expect(loggedSet.updatedAt.toUtc(), now);
      expect(logs, hasLength(1));
      expect(logs.single.sessionSetId, firstSetId);
      expect(logs.single.revision, 1);
      expect(logs.single.repetitions, 7);
      expect(logs.single.loadKilograms, 52.5);
      expect(logs.single.rir, 1);
      expect(logs.single.outcome?.name, SetResult.techniqueLimitation.name);
      expect(find.text('Session status: Needs review'), findsOneWidget);
      expect(find.text('Exercise status: Needs review'), findsOneWidget);
      expect(find.text('Set status: Performance miss'), findsOneWidget);
      expect(find.text('Rest timer'), findsOneWidget);
      expect(find.textContaining('3:00'), findsOneWidget);
    },
  );

  testWidgets('shows a restored active workout from local storage', (
    tester,
  ) async {
    final database = AppDatabase.forTesting(NativeDatabase.memory());
    addTearDown(database.close);
    await _seedActiveProgram(database, now);
    await _seedRestorableActiveWorkout(database, now);

    await _pumpTodayApp(
      tester,
      catalog: testCatalog,
      now: now,
      database: database,
    );
    await _pumpUntilFound(
      tester,
      find.byKey(TodayScreen.restoredSessionMessageKey),
    );

    expect(find.byKey(TodayScreen.activeSessionCardKey), findsOneWidget);
    expect(
      find.text('This in-progress workout was restored from local storage.'),
      findsOneWidget,
    );
    expect(find.text('1 of 2 sets completed'), findsOneWidget);
    expect(find.text('Session status: Needs review'), findsOneWidget);
    expect(find.text('Exercise status: Needs review'), findsOneWidget);
    expect(
      tester
          .widget<ChoiceChip>(find.byKey(TodayScreen.trainingDayChipKey(0)))
          .selected,
      isFalse,
    );
    expect(
      tester
          .widget<ChoiceChip>(find.byKey(TodayScreen.trainingDayChipKey(1)))
          .selected,
      isTrue,
    );
    expect(
      tester
          .widget<FilledButton>(find.byKey(TodayScreen.startSessionButtonKey))
          .onPressed,
      isNull,
    );

    await tester.ensureVisible(
      find.byKey(TodayScreen.completedSetStatusKey('restored-set-0')),
    );
    await tester.pumpAndSettle();

    expect(
      find.byKey(TodayScreen.completedSetStatusKey('restored-set-0')),
      findsOneWidget,
    );
    expect(
      find.byKey(TodayScreen.setStatusKey('restored-set-0')),
      findsOneWidget,
    );
  });

  testWidgets('logs an interruption outcome without actual numeric values', (
    tester,
  ) async {
    final database = AppDatabase.forTesting(NativeDatabase.memory());
    addTearDown(database.close);
    await _seedActiveProgram(database, now);

    await _pumpTodayApp(
      tester,
      catalog: testCatalog,
      now: now,
      database: database,
    );
    await _pumpUntilFound(tester, find.byKey(TodayScreen.activeProgramCardKey));

    await tester.tap(find.byKey(TodayScreen.trainingDayChipKey(1)));
    await tester.pump();
    await tester.tap(find.byKey(TodayScreen.startSessionButtonKey));
    await tester.pump();
    await _pumpUntilFound(tester, find.byKey(TodayScreen.activeSessionCardKey));

    final firstSetId =
        (await database.select(database.sessionSets).get()).first.id;
    await tester.ensureVisible(
      find.byKey(TodayScreen.actualRepetitionsFieldKey(firstSetId)),
    );
    await tester.pumpAndSettle();
    await tester.enterText(
      find.byKey(TodayScreen.actualRepetitionsFieldKey(firstSetId)),
      '',
    );
    await tester.enterText(
      find.byKey(TodayScreen.actualLoadFieldKey(firstSetId)),
      '',
    );
    await tester.enterText(
      find.byKey(TodayScreen.actualRirFieldKey(firstSetId)),
      '',
    );
    await tester.ensureVisible(
      find.byKey(TodayScreen.outcomeFieldKey(firstSetId)),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(TodayScreen.outcomeFieldKey(firstSetId)));
    await tester.pumpAndSettle();
    await tester.tap(find.text('External interruption').last);
    await tester.pumpAndSettle();
    FocusManager.instance.primaryFocus?.unfocus();
    await tester.ensureVisible(
      find.byKey(TodayScreen.completeSetButtonKey(firstSetId)),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(TodayScreen.completeSetButtonKey(firstSetId)));
    await tester.pump();
    await _pumpUntilFound(
      tester,
      find.byKey(TodayScreen.completedSetStatusKey(firstSetId)),
    );

    final logs = await database.select(database.actualSetLogs).get();

    expect(logs, hasLength(1));
    expect(logs.single.repetitions, isNull);
    expect(logs.single.loadKilograms, isNull);
    expect(logs.single.rir, isNull);
    expect(logs.single.outcome?.name, SetResult.externalInterruption.name);
    expect(
      find.text(
        'Logged: reps not recorded · no load · RIR off · External interruption',
      ),
      findsOneWidget,
    );
  });

  testWidgets(
    'shows previous set performance beside the current prescription',
    (tester) async {
      final database = AppDatabase.forTesting(NativeDatabase.memory());
      addTearDown(database.close);
      await _seedActiveProgram(database, now);
      await _seedPreviousWorkoutPerformance(database, now);

      await _pumpTodayApp(
        tester,
        catalog: testCatalog,
        now: now,
        database: database,
      );
      await _pumpUntilFound(
        tester,
        find.byKey(TodayScreen.activeProgramCardKey),
      );

      await tester.tap(find.byKey(TodayScreen.trainingDayChipKey(1)));
      await tester.pump();
      await tester.tap(find.byKey(TodayScreen.startSessionButtonKey));
      await tester.pump();
      await _pumpUntilFound(
        tester,
        find.byKey(TodayScreen.activeSessionCardKey),
      );

      final currentSession =
          (await database.select(database.workoutSessions).get()).singleWhere(
            (session) => session.id != 'previous-session',
          );
      final currentSet = (await database.select(database.sessionSets).get())
          .singleWhere(
            (set) => set.sessionId == currentSession.id && set.setOrder == 0,
          );

      await tester.ensureVisible(
        find.byKey(TodayScreen.previousPerformanceKey(currentSet.id)),
      );
      await tester.pumpAndSettle();

      expect(find.text('Target: 6-8 reps · RIR 2 · 50 kg'), findsWidgets);
      expect(
        find.text('Previous: 8 reps · 55 kg · RIR 1 · No limitation'),
        findsOneWidget,
      );
    },
  );
}

Future<AppDatabase> _pumpTodayApp(
  WidgetTester tester, {
  required ExerciseCatalog catalog,
  required DateTime now,
  AppDatabase? database,
  RestNotificationScheduler? restNotificationScheduler,
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
        todayClockProvider.overrideWithValue(() => now),
        if (restNotificationScheduler != null)
          restNotificationSchedulerProvider.overrideWithValue(
            restNotificationScheduler,
          ),
      ],
      child: const ProjectAtlasApp(),
    ),
  );
  await tester.pump();

  return appDatabase;
}

Future<void> _seedActiveProgram(AppDatabase database, DateTime now) async {
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
          _trainingDay(now, order: 0, name: 'Upper A'),
          _trainingDay(now, order: 1, name: 'Lower A'),
        ],
        [
          for (var index = 0; index < 3; index += 1)
            _prescribedSet(
              now,
              id: 'upper-bench-$index',
              trainingDayOrder: 0,
              exerciseId: 'barbell_bench_press',
              exerciseOrder: 0,
              setOrder: index,
            ),
          for (var index = 0; index < 2; index += 1)
            _prescribedSet(
              now,
              id: 'lower-squat-$index',
              trainingDayOrder: 1,
              exerciseId: 'barbell_back_squat',
              exerciseOrder: 0,
              setOrder: index,
            ),
        ],
      );
}

Future<void> _seedPreviousWorkoutPerformance(
  AppDatabase database,
  DateTime now,
) async {
  final container = ProviderContainer(
    overrides: [appDatabaseProvider.overrideWithValue(database)],
  );
  addTearDown(container.dispose);

  final previousAt = now.subtract(const Duration(days: 7));
  final session = WorkoutSessionRecord(
    id: 'previous-session',
    profileId: localProgramProfileId,
    programId: 'program-1',
    programVersionId: 'version-1',
    lifecycle: WorkoutLifecycle.completed,
    scheduledAt: previousAt,
    startedAt: previousAt,
    endedAt: previousAt.add(const Duration(hours: 1)),
    notes: 'Lower A',
    createdAt: previousAt,
    updatedAt: previousAt.add(const Duration(hours: 1)),
  );
  final plannedSet = SessionSetRecord(
    id: 'previous-squat-set-0',
    sessionId: session.id,
    prescribedSetId: 'lower-squat-0',
    exerciseId: 'barbell_back_squat',
    exerciseOrder: 0,
    setOrder: 0,
    lifecycle: SetLifecycle.planned,
    createdAt: previousAt,
    updatedAt: previousAt,
  );

  final repository = container.read(workoutRepositoryProvider);
  await repository.saveSessionPlan(session, [plannedSet]);
  await repository.completeSessionSet(
    SessionSetRecord(
      id: plannedSet.id,
      sessionId: plannedSet.sessionId,
      prescribedSetId: plannedSet.prescribedSetId,
      exerciseId: plannedSet.exerciseId,
      exerciseOrder: plannedSet.exerciseOrder,
      setOrder: plannedSet.setOrder,
      lifecycle: SetLifecycle.completed,
      createdAt: plannedSet.createdAt,
      updatedAt: previousAt.add(const Duration(minutes: 5)),
    ),
    ActualSetLogRecord(
      id: 'previous-squat-log-0',
      sessionSetId: plannedSet.id,
      revision: 1,
      repetitions: 8,
      loadKilograms: 55,
      rir: 1,
      recordedAt: previousAt.add(const Duration(minutes: 5)),
    ),
  );
}

Future<void> _seedRestorableActiveWorkout(
  AppDatabase database,
  DateTime now,
) async {
  final container = ProviderContainer(
    overrides: [appDatabaseProvider.overrideWithValue(database)],
  );
  addTearDown(container.dispose);

  final session = WorkoutSessionRecord(
    id: 'restored-session',
    profileId: localProgramProfileId,
    programId: 'program-1',
    programVersionId: 'version-1',
    lifecycle: WorkoutLifecycle.inProgress,
    scheduledAt: now,
    startedAt: now,
    notes: 'Lower A',
    createdAt: now,
    updatedAt: now,
  );
  final firstSet = SessionSetRecord(
    id: 'restored-set-0',
    sessionId: session.id,
    prescribedSetId: 'lower-squat-0',
    exerciseId: 'barbell_back_squat',
    exerciseOrder: 0,
    setOrder: 0,
    lifecycle: SetLifecycle.planned,
    createdAt: now,
    updatedAt: now,
  );
  final secondSet = SessionSetRecord(
    id: 'restored-set-1',
    sessionId: session.id,
    prescribedSetId: 'lower-squat-1',
    exerciseId: 'barbell_back_squat',
    exerciseOrder: 0,
    setOrder: 1,
    lifecycle: SetLifecycle.planned,
    createdAt: now,
    updatedAt: now,
  );

  final repository = container.read(workoutRepositoryProvider);
  await repository.saveSessionPlan(session, [firstSet, secondSet]);
  await repository.completeSessionSet(
    SessionSetRecord(
      id: firstSet.id,
      sessionId: firstSet.sessionId,
      prescribedSetId: firstSet.prescribedSetId,
      exerciseId: firstSet.exerciseId,
      exerciseOrder: firstSet.exerciseOrder,
      setOrder: firstSet.setOrder,
      lifecycle: SetLifecycle.completed,
      createdAt: firstSet.createdAt,
      updatedAt: now.add(const Duration(minutes: 5)),
    ),
    ActualSetLogRecord(
      id: 'restored-log-0',
      sessionSetId: firstSet.id,
      revision: 1,
      repetitions: 7,
      loadKilograms: 52.5,
      rir: 1,
      result: SetResult.techniqueLimitation,
      recordedAt: now.add(const Duration(minutes: 5)),
    ),
  );
}

ProgramTrainingDayRecord _trainingDay(
  DateTime now, {
  required int order,
  required String name,
}) {
  return ProgramTrainingDayRecord(
    id: 'training-day-$order',
    programVersionId: 'version-1',
    trainingDayOrder: order,
    name: name,
    createdAt: now,
  );
}

PrescribedSetRecord _prescribedSet(
  DateTime now, {
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
    createdAt: now,
  );
}

Future<void> _pumpUntilFound(WidgetTester tester, Finder finder) async {
  for (var attempt = 0; attempt < 20; attempt += 1) {
    await tester.pump(const Duration(milliseconds: 100));
    if (finder.evaluate().isNotEmpty) {
      return;
    }
  }
  fail('Expected finder did not appear: $finder');
}

String _loadFieldText(WidgetTester tester, String sessionSetId) {
  final field = tester.widget<TextFormField>(
    find.descendant(
      of: find.byKey(TodayScreen.actualLoadFieldKey(sessionSetId)),
      matching: find.byType(TextFormField),
    ),
  );
  return field.controller?.text ?? '';
}

final class _FakeRestNotificationScheduler
    implements RestNotificationScheduler {
  @override
  Future<void> cancelRestTimerNotification() async {}

  @override
  Future<RestNotificationScheduleResult> scheduleRestTimerNotification({
    required DateTime endsAt,
    required String title,
    required String body,
  }) async {
    return const RestNotificationScheduleResult(
      RestNotificationScheduleStatus.scheduled,
    );
  }
}
