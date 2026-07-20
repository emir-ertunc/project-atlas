import 'dart:io';

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
import 'package:project_atlas/features/today/application/rest_timer_controller.dart';
import 'package:project_atlas/features/today/application/today_workout_controller.dart';
import 'package:project_atlas/features/today/platform/rest_notification_scheduler.dart';
import 'package:project_atlas/features/today/presentation/today_screen.dart';

import '../support/test_exercise_catalog.dart';

void main() {
  late ExerciseCatalog testCatalog;
  late DateTime now;

  setUpAll(() {
    testCatalog = loadTestExerciseCatalog();
  });

  setUp(() {
    now = DateTime.utc(2026, 7, 20, 10);
  });

  testWidgets(
    'runs workout logging, history, and correction while network is blocked',
    (tester) async {
      await _withNetworkBlocked(() async {
        final database = AppDatabase.forTesting(NativeDatabase.memory());
        addTearDown(database.close);
        await _seedActiveProgram(database, now);

        await _pumpWorkoutApp(
          tester,
          catalog: testCatalog,
          database: database,
          now: now,
          correctionClock: () => now.add(const Duration(minutes: 30)),
        );

        await _pumpUntilFound(
          tester,
          find.byKey(TodayScreen.activeProgramCardKey),
        );
        await tester.tap(find.byKey(TodayScreen.startSessionButtonKey));
        await tester.pump();
        await _pumpUntilFound(
          tester,
          find.byKey(TodayScreen.activeSessionCardKey),
        );

        final sessionSet =
            (await database.select(database.sessionSets).get()).single;
        await tester.ensureVisible(
          find.byKey(TodayScreen.actualRepetitionsFieldKey(sessionSet.id)),
        );
        await tester.pumpAndSettle();
        await tester.enterText(
          find.byKey(TodayScreen.actualRepetitionsFieldKey(sessionSet.id)),
          '8',
        );
        await tester.enterText(
          find.byKey(TodayScreen.actualLoadFieldKey(sessionSet.id)),
          '55',
        );
        await tester.enterText(
          find.byKey(TodayScreen.actualRirFieldKey(sessionSet.id)),
          '1',
        );
        FocusManager.instance.primaryFocus?.unfocus();
        await tester.ensureVisible(
          find.byKey(TodayScreen.completeSetButtonKey(sessionSet.id)),
        );
        await tester.pumpAndSettle();
        await tester.tap(
          find.byKey(TodayScreen.completeSetButtonKey(sessionSet.id)),
        );
        await tester.pump();
        await _pumpUntilFound(
          tester,
          find.byKey(TodayScreen.completedSetStatusKey(sessionSet.id)),
        );

        var logs = await database.select(database.actualSetLogs).get();
        expect(logs, hasLength(1));
        expect(logs.single.revision, 1);
        expect(logs.single.repetitions, 8);

        await tester.tap(_navigationLabel('Progress'));
        await tester.pump();
        await _pumpUntilFound(
          tester,
          find.byKey(ProgressScreen.historySectionKey),
        );

        await tester.ensureVisible(
          find.byKey(
            ProgressScreen.correctionRepetitionsFieldKey(sessionSet.id),
          ),
        );
        await tester.pumpAndSettle();
        await tester.enterText(
          find.byKey(
            ProgressScreen.correctionRepetitionsFieldKey(sessionSet.id),
          ),
          '9',
        );
        await tester.enterText(
          find.byKey(ProgressScreen.correctionLoadFieldKey(sessionSet.id)),
          '60',
        );
        await tester.enterText(
          find.byKey(ProgressScreen.correctionRirFieldKey(sessionSet.id)),
          '0',
        );
        FocusManager.instance.primaryFocus?.unfocus();
        await tester.ensureVisible(
          find.byKey(ProgressScreen.correctionSaveButtonKey(sessionSet.id)),
        );
        await tester.pumpAndSettle();
        await tester.tap(
          find.byKey(ProgressScreen.correctionSaveButtonKey(sessionSet.id)),
        );
        await tester.pumpAndSettle();
        await _pumpUntilFound(tester, find.text('2 revisions'));

        logs = await database.select(database.actualSetLogs).get();
        expect(logs, hasLength(2));
        expect(logs.map((log) => log.revision), [1, 2]);
        expect(logs[0].repetitions, 8);
        expect(logs[1].repetitions, 9);
        expect(logs[1].loadKilograms, 60);
        expect(logs[1].rir, 0);
        expect(logs[1].supersedesLogId, logs[0].id);
        expect(find.text('Best load: 60 kg'), findsOneWidget);
        expect(find.text('Best reps: 9'), findsOneWidget);
      });
    },
  );

  test(
    'restores active workout and corrected history after database reopen',
    () async {
      final temporaryDirectory = await Directory.systemTemp.createTemp(
        'project_atlas_p4_10_recovery_',
      );
      addTearDown(() async {
        if (temporaryDirectory.existsSync()) {
          await temporaryDirectory.delete(recursive: true);
        }
      });
      final databaseFile = File(
        '${temporaryDirectory.path}/project_atlas.sqlite',
      );

      var database = AppDatabase.forTesting(NativeDatabase(databaseFile));
      var container = _container(database, now);
      await _seedActiveProgramWithContainer(container, now);

      var state = await container.read(todayWorkoutControllerProvider.future);
      expect(state.activeSession, isNull);

      await container
          .read(todayWorkoutControllerProvider.notifier)
          .startSelectedSession();
      state = container.read(todayWorkoutControllerProvider).value!;
      final sessionId = state.activeSession!.session.id;
      final setId = state.activeSession!.setSummaries.single.sessionSet.id;

      await container
          .read(todayWorkoutControllerProvider.notifier)
          .completeSessionSet(
            sessionSetId: setId,
            repetitions: 8,
            loadKilograms: 55,
            rir: 1,
            result: null,
          );

      container.dispose();
      await database.close();

      database = AppDatabase.forTesting(NativeDatabase(databaseFile));
      container = _container(
        database,
        now.add(const Duration(minutes: 5)),
        correctionClock: () => now.add(const Duration(minutes: 30)),
      );

      state = await container.read(todayWorkoutControllerProvider.future);
      expect(state.activeSession?.session.id, sessionId);
      expect(state.activeSession?.restoredAfterProcessTermination, isTrue);
      expect(state.activeSession?.completedSetCount, 1);
      expect(
        state.activeSession?.setSummaries.single.latestLog?.repetitions,
        8,
      );

      final history = await container.read(workoutHistoryProvider.future);
      final detail = history.setDetailById(setId);
      expect(detail?.latestLog?.revision, 1);

      await container
          .read(workoutHistoryCorrectionControllerProvider.notifier)
          .correctSet(
            detail: detail!,
            repetitions: 9,
            loadKilograms: 60,
            rir: 0,
            result: null,
          );

      var logs = await container
          .read(workoutRepositoryProvider)
          .getActualSetLogs(setId);
      expect(logs, hasLength(2));
      expect(logs[1].revision, 2);
      expect(logs[1].supersedesLogId, logs[0].id);

      container.dispose();
      await database.close();

      database = AppDatabase.forTesting(NativeDatabase(databaseFile));
      addTearDown(database.close);
      container = _container(database, now.add(const Duration(minutes: 45)));
      addTearDown(container.dispose);

      state = await container.read(todayWorkoutControllerProvider.future);
      expect(state.activeSession?.session.id, sessionId);
      expect(state.activeSession?.restoredAfterProcessTermination, isTrue);
      expect(state.activeSession?.setSummaries.single.latestLog?.revision, 2);

      final recoveredHistory = await container.read(
        workoutHistoryProvider.future,
      );
      final recoveredDetail = recoveredHistory.setDetailById(setId)!;
      logs = await container
          .read(workoutRepositoryProvider)
          .getActualSetLogs(setId);

      expect(recoveredDetail.logs, hasLength(2));
      expect(recoveredDetail.latestLog?.revision, 2);
      expect(recoveredDetail.latestLog?.repetitions, 9);
      expect(recoveredDetail.latestLog?.loadKilograms, 60);
      expect(logs[0].repetitions, 8);
      expect(logs[1].supersedesLogId, logs[0].id);

      final record = recoveredHistory.personalRecords.single;
      expect(record.bestLoad?.value, 60);
      expect(record.bestRepetitions?.value, 9);
      expect(record.bestVolume?.value, 540);
    },
  );
}

Future<T> _withNetworkBlocked<T>(Future<T> Function() body) {
  return HttpOverrides.runZoned(
    body,
    createHttpClient: (SecurityContext? _) {
      throw StateError(
        'Unexpected network client creation during workout airplane-mode verification.',
      );
    },
  );
}

Future<AppDatabase> _pumpWorkoutApp(
  WidgetTester tester, {
  required ExerciseCatalog catalog,
  required AppDatabase database,
  required DateTime now,
  DateTime Function()? correctionClock,
}) async {
  tester.view.physicalSize = const Size(430, 932);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);

  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        appDatabaseProvider.overrideWithValue(database),
        appLocaleProvider.overrideWithValue(const Locale('en')),
        exerciseCatalogProvider.overrideWith((ref) => catalog),
        todayClockProvider.overrideWithValue(() => now),
        restNotificationSchedulerProvider.overrideWithValue(
          _FakeRestNotificationScheduler(),
        ),
        if (correctionClock != null)
          workoutHistoryClockProvider.overrideWithValue(correctionClock),
      ],
      child: const ProjectAtlasApp(),
    ),
  );
  await tester.pump();

  return database;
}

ProviderContainer _container(
  AppDatabase database,
  DateTime now, {
  DateTime Function()? correctionClock,
}) {
  return ProviderContainer(
    overrides: [
      appDatabaseProvider.overrideWithValue(database),
      todayClockProvider.overrideWithValue(() => now),
      if (correctionClock != null)
        workoutHistoryClockProvider.overrideWithValue(correctionClock),
    ],
  );
}

Future<void> _seedActiveProgram(AppDatabase database, DateTime now) async {
  final container = ProviderContainer(
    overrides: [appDatabaseProvider.overrideWithValue(database)],
  );
  try {
    await _seedActiveProgramWithContainer(container, now);
  } finally {
    container.dispose();
  }
}

Future<void> _seedActiveProgramWithContainer(
  ProviderContainer container,
  DateTime now,
) async {
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
}

Finder _navigationLabel(String label) {
  return find.descendant(
    of: find.byKey(MainNavigationShell.navigationBarKey),
    matching: find.text(label),
  );
}

Future<void> _pumpUntilFound(WidgetTester tester, Finder finder) async {
  for (var attempt = 0; attempt < 80; attempt += 1) {
    await tester.pump(const Duration(milliseconds: 50));
    if (finder.evaluate().isNotEmpty) {
      return;
    }
  }
  fail('Expected widget was not found: $finder');
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
