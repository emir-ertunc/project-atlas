import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:project_atlas/core/achievements/local_achievement_feedback.dart';
import 'package:project_atlas/core/repositories/repository_contracts.dart';
import 'package:project_atlas/core/repositories/repository_providers.dart';
import 'package:project_atlas/core/repositories/repository_records.dart';
import 'package:project_atlas/features/program/application/program_draft_persistence.dart';
import 'package:project_atlas/features/today/application/workout_status_calculator.dart';

final todayClockProvider = Provider<DateTime Function()>((ref) => DateTime.now);

final todayWorkoutControllerProvider =
    AsyncNotifierProvider<TodayWorkoutController, TodayWorkoutState>(
      TodayWorkoutController.new,
    );

final class TodayWorkoutState {
  const TodayWorkoutState({
    this.coachSummary = TodayCoachSummary.empty,
    this.activeProgramPlan,
    this.activeSession,
    this.selectedTrainingDayOrder,
  });

  final TodayCoachSummary coachSummary;
  final TodayProgramPlan? activeProgramPlan;
  final TodaySessionSummary? activeSession;
  final int? selectedTrainingDayOrder;

  TodayTrainingDayPlan? get selectedTrainingDay {
    final plan = activeProgramPlan;
    final selectedOrder = selectedTrainingDayOrder;
    if (plan == null || selectedOrder == null) {
      return null;
    }
    return plan.trainingDayByOrder(selectedOrder);
  }

  TodayWorkoutState copyWith({
    TodayCoachSummary? coachSummary,
    TodayProgramPlan? activeProgramPlan,
    TodaySessionSummary? activeSession,
    int? selectedTrainingDayOrder,
  }) {
    return TodayWorkoutState(
      coachSummary: coachSummary ?? this.coachSummary,
      activeProgramPlan: activeProgramPlan ?? this.activeProgramPlan,
      activeSession: activeSession ?? this.activeSession,
      selectedTrainingDayOrder:
          selectedTrainingDayOrder ?? this.selectedTrainingDayOrder,
    );
  }
}

final class TodayCoachSummary {
  const TodayCoachSummary({
    required this.currentStreakDays,
    required this.completedWorkoutsThisWeek,
    required this.weeklyWorkoutTarget,
  });

  static const empty = TodayCoachSummary(
    currentStreakDays: 0,
    completedWorkoutsThisWeek: 0,
    weeklyWorkoutTarget: 0,
  );

  final int currentStreakDays;
  final int completedWorkoutsThisWeek;
  final int weeklyWorkoutTarget;

  bool get hasWeeklyTarget => weeklyWorkoutTarget > 0;

  double get weeklyConsistencyRatio {
    if (!hasWeeklyTarget) {
      return 0;
    }
    return (completedWorkoutsThisWeek / weeklyWorkoutTarget)
        .clamp(0.0, 1.0)
        .toDouble();
  }

  int get weeklyConsistencyPercent => (weeklyConsistencyRatio * 100).round();
}

final class TodayProgramPlan {
  const TodayProgramPlan({
    required this.program,
    required this.version,
    required this.trainingDays,
  });

  final ProgramRecord program;
  final ProgramVersionRecord version;
  final List<TodayTrainingDayPlan> trainingDays;

  TodayTrainingDayPlan? trainingDayByOrder(int trainingDayOrder) {
    for (final day in trainingDays) {
      if (day.trainingDayOrder == trainingDayOrder) {
        return day;
      }
    }
    return null;
  }
}

final class TodayTrainingDayPlan {
  const TodayTrainingDayPlan({required this.day, required this.exercisePlans});

  final ProgramTrainingDayRecord day;
  final List<TodayExercisePlan> exercisePlans;

  int get trainingDayOrder => day.trainingDayOrder;

  List<PrescribedSetRecord> get prescribedSets => [
    for (final exercise in exercisePlans) ...exercise.prescribedSets,
  ];

  int get exerciseCount => exercisePlans.length;

  int get totalSetCount => exercisePlans.fold<int>(
    0,
    (total, exercise) => total + exercise.setCount,
  );

  bool get hasExercises => exercisePlans.isNotEmpty;
}

final class TodayExercisePlan {
  const TodayExercisePlan({
    required this.exerciseId,
    required this.exerciseOrder,
    required this.prescribedSets,
  });

  final String exerciseId;
  final int exerciseOrder;
  final List<PrescribedSetRecord> prescribedSets;

  int get setCount => prescribedSets.length;

  PrescribedSetRecord get firstSet => prescribedSets.first;
}

final class TodaySessionSummary {
  const TodaySessionSummary({
    required this.session,
    required this.exerciseSummaries,
    required this.restoredAfterProcessTermination,
  });

  final WorkoutSessionRecord session;
  final List<TodaySessionExerciseSummary> exerciseSummaries;
  final bool restoredAfterProcessTermination;

  int get exerciseCount => exerciseSummaries.length;

  int get totalSetCount => exerciseSummaries.fold<int>(
    0,
    (total, exercise) => total + exercise.setCount,
  );

  int get completedSetCount =>
      setSummaries.where((set) => set.isCompleted).length;

  TodaySessionStatus get status => calculateTodaySessionStatus(
    exerciseSummaries.map((exercise) => exercise.status),
  );

  List<TodaySessionSetSummary> get setSummaries => [
    for (final exercise in exerciseSummaries) ...exercise.setSummaries,
  ];

  int? get sourceTrainingDayOrder {
    final orders = {
      for (final summary in setSummaries)
        if (summary.prescribedSet != null)
          summary.prescribedSet!.trainingDayOrder,
    };
    return orders.length == 1 ? orders.single : null;
  }
}

final class TodaySessionExerciseSummary {
  const TodaySessionExerciseSummary({
    required this.exerciseId,
    required this.exerciseOrder,
    required this.setSummaries,
  });

  final String exerciseId;
  final int exerciseOrder;
  final List<TodaySessionSetSummary> setSummaries;

  int get setCount => setSummaries.length;

  TodayExerciseStatus get status => calculateTodayExerciseStatus(
    setSummaries.map((summary) => summary.status),
  );
}

final class TodaySessionSetSummary {
  const TodaySessionSetSummary({
    required this.sessionSet,
    this.prescribedSet,
    this.latestLog,
    this.previousPerformance,
  });

  final SessionSetRecord sessionSet;
  final PrescribedSetRecord? prescribedSet;
  final ActualSetLogRecord? latestLog;
  final ExerciseSetPerformanceRecord? previousPerformance;

  bool get isCompleted => sessionSet.lifecycle == SetLifecycle.completed;

  bool get isLogged => latestLog != null;

  int get setNumber => sessionSet.setOrder + 1;

  TodaySetStatus get status => calculateTodaySetStatus(
    lifecycle: sessionSet.lifecycle,
    prescribedSet: prescribedSet,
    latestLog: latestLog,
  );
}

class TodayWorkoutController extends AsyncNotifier<TodayWorkoutState> {
  var _idSerial = 0;
  int? _selectedTrainingDayOrder;
  final _sessionsStartedInProcess = <String>{};

  @override
  Future<TodayWorkoutState> build() => _loadState();

  void selectTrainingDay(int trainingDayOrder) {
    final current = state.asData?.value;
    final plan = current?.activeProgramPlan;
    if (current == null || plan?.trainingDayByOrder(trainingDayOrder) == null) {
      return;
    }

    _selectedTrainingDayOrder = trainingDayOrder;
    state = AsyncData(
      current.copyWith(selectedTrainingDayOrder: trainingDayOrder),
    );
  }

  Future<void> startSelectedSession() async {
    final current = state.asData?.value ?? await _loadState();
    final activeSession = current.activeSession;
    if (activeSession != null) {
      return;
    }

    final programPlan = current.activeProgramPlan;
    final selectedDay = current.selectedTrainingDay;
    if (programPlan == null || selectedDay == null) {
      throw StateError('No active training day is available.');
    }
    final prescribedSets = selectedDay.prescribedSets;
    if (prescribedSets.isEmpty) {
      throw StateError('The selected training day has no prescribed sets.');
    }

    state = const AsyncLoading<TodayWorkoutState>();
    try {
      final now = ref.read(todayClockProvider)().toUtc();
      final sessionId = _nextId('session', now);
      final session = WorkoutSessionRecord(
        id: sessionId,
        profileId: ref.read(localProgramProfileIdProvider),
        programId: programPlan.program.id,
        programVersionId: programPlan.version.id,
        lifecycle: WorkoutLifecycle.inProgress,
        scheduledAt: now,
        startedAt: now,
        notes: selectedDay.day.name,
        createdAt: now,
        updatedAt: now,
      );
      final sessionSets = prescribedSets
          .map(
            (set) => SessionSetRecord(
              id: _nextId('session_set', now),
              sessionId: sessionId,
              prescribedSetId: set.id,
              exerciseId: set.exerciseId,
              exerciseOrder: set.exerciseOrder,
              setOrder: set.setOrder,
              lifecycle: SetLifecycle.planned,
              createdAt: now,
              updatedAt: now,
            ),
          )
          .toList(growable: false);

      await ref
          .read(workoutRepositoryProvider)
          .saveSessionPlan(session, sessionSets);
      _sessionsStartedInProcess.add(sessionId);

      state = AsyncData(await _loadState());
    } catch (error, stackTrace) {
      state = AsyncError<TodayWorkoutState>(error, stackTrace);
      Error.throwWithStackTrace(error, stackTrace);
    }
  }

  Future<void> completeSessionSet({
    required String sessionSetId,
    required int? repetitions,
    required double? loadKilograms,
    required int? rir,
    required SetResult? result,
  }) async {
    if (repetitions != null && repetitions < 0) {
      throw ArgumentError.value(
        repetitions,
        'repetitions',
        'Repetitions cannot be negative.',
      );
    }
    if (loadKilograms != null && loadKilograms < 0) {
      throw ArgumentError.value(
        loadKilograms,
        'loadKilograms',
        'Load cannot be negative.',
      );
    }
    if (rir != null && (rir < 0 || rir > 10)) {
      throw ArgumentError.value(rir, 'rir', 'RIR must be between 0 and 10.');
    }
    if (repetitions == null &&
        loadKilograms == null &&
        rir == null &&
        result == null) {
      throw ArgumentError(
        'At least one actual value or outcome must be recorded.',
      );
    }

    final current = state.asData?.value ?? await _loadState();
    final activeSession = current.activeSession;
    if (activeSession == null) {
      throw StateError('No active workout session is available.');
    }
    final setSummary = _firstWhereOrNull(
      activeSession.setSummaries,
      (set) => set.sessionSet.id == sessionSetId,
    );
    if (setSummary == null) {
      throw StateError('Session set $sessionSetId was not found.');
    }
    if (setSummary.isCompleted) {
      return;
    }

    final previousState = state;
    try {
      final now = ref.read(todayClockProvider)().toUtc();
      final sessionSet = setSummary.sessionSet;
      final completedSet = SessionSetRecord(
        id: sessionSet.id,
        sessionId: sessionSet.sessionId,
        prescribedSetId: sessionSet.prescribedSetId,
        exerciseId: sessionSet.exerciseId,
        exerciseOrder: sessionSet.exerciseOrder,
        setOrder: sessionSet.setOrder,
        lifecycle: SetLifecycle.completed,
        createdAt: sessionSet.createdAt,
        updatedAt: now,
      );
      final log = ActualSetLogRecord(
        id: _actualSetLogId(
          sessionSetId: sessionSet.id,
          revision: (setSummary.latestLog?.revision ?? 0) + 1,
          recordedAt: now,
        ),
        sessionSetId: sessionSet.id,
        revision: (setSummary.latestLog?.revision ?? 0) + 1,
        repetitions: repetitions,
        loadKilograms: loadKilograms,
        rir: rir,
        result: result,
        recordedAt: now,
      );

      await ref
          .read(workoutRepositoryProvider)
          .completeSessionSet(completedSet, log);

      state = AsyncData(await _loadState());
    } catch (error) {
      state = previousState;
      rethrow;
    }
  }

  Future<TodayWorkoutState> _loadState() async {
    final profileId = ref.read(localProgramProfileIdProvider);
    final programRepository = ref.read(programRepositoryProvider);
    final workoutRepository = ref.read(workoutRepositoryProvider);
    final now = ref.read(todayClockProvider)().toUtc();

    final sessions = await workoutRepository.getSessions(profileId);
    final activeSession = _firstWhereOrNull(
      sessions,
      (session) => session.lifecycle == WorkoutLifecycle.inProgress,
    );
    final sessionPrescription = activeSession?.programVersionId == null
        ? const <PrescribedSetRecord>[]
        : await programRepository.getPrescription(
            activeSession!.programVersionId!,
          );
    final sessionSummary = activeSession == null
        ? null
        : await _loadSessionSummary(
            activeSession,
            workoutRepository,
            sessionPrescription,
            restoredAfterProcessTermination: !_sessionsStartedInProcess
                .contains(activeSession.id),
          );

    final programs = await programRepository.getPrograms(profileId);
    final activeProgram = _firstWhereOrNull(
      programs,
      (program) => program.lifecycle == ProgramLifecycle.active,
    );
    if (activeProgram == null) {
      _selectedTrainingDayOrder = null;
      return TodayWorkoutState(
        activeSession: sessionSummary,
        coachSummary: _buildCoachSummary(
          sessions: sessions,
          activeProgramPlan: null,
          now: now,
        ),
      );
    }

    final versions = await programRepository.getVersions(activeProgram.id);
    final activeVersion = _firstWhereOrNull(
      versions,
      (version) => version.lifecycle == ProgramVersionLifecycle.active,
    );
    if (activeVersion == null) {
      _selectedTrainingDayOrder = null;
      return TodayWorkoutState(
        activeSession: sessionSummary,
        coachSummary: _buildCoachSummary(
          sessions: sessions,
          activeProgramPlan: null,
          now: now,
        ),
      );
    }

    final trainingDays = await programRepository.getTrainingDays(
      activeVersion.id,
    );
    final prescription = await programRepository.getPrescription(
      activeVersion.id,
    );

    final plan = TodayProgramPlan(
      program: activeProgram,
      version: activeVersion,
      trainingDays: _buildTrainingDayPlans(trainingDays, prescription),
    );
    final selectedOrder = _resolveSelectedTrainingDayOrder(
      plan,
      preferredOrder:
          _selectedTrainingDayOrder ?? sessionSummary?.sourceTrainingDayOrder,
    );
    _selectedTrainingDayOrder = selectedOrder;

    return TodayWorkoutState(
      coachSummary: _buildCoachSummary(
        sessions: sessions,
        activeProgramPlan: plan,
        now: now,
      ),
      activeProgramPlan: plan,
      activeSession: sessionSummary,
      selectedTrainingDayOrder: selectedOrder,
    );
  }

  Future<TodaySessionSummary> _loadSessionSummary(
    WorkoutSessionRecord session,
    WorkoutRepository workoutRepository,
    List<PrescribedSetRecord> prescription, {
    required bool restoredAfterProcessTermination,
  }) async {
    final sessionSets = await workoutRepository.getSessionSets(session.id);
    final logsBySessionSetId = <String, List<ActualSetLogRecord>>{};
    await Future.wait([
      for (final set in sessionSets)
        workoutRepository
            .getActualSetLogs(set.id)
            .then((logs) => logsBySessionSetId[set.id] = logs),
    ]);
    final prescriptionById = {
      for (final prescribedSet in prescription) prescribedSet.id: prescribedSet,
    };
    final previousPerformanceByExerciseId =
        await _loadPreviousPerformanceByExercise(
          session: session,
          sessionSets: sessionSets,
          workoutRepository: workoutRepository,
        );
    final exerciseSummaries = <TodaySessionExerciseSummary>[];
    final grouped = <int, List<SessionSetRecord>>{};
    for (final set in sessionSets) {
      grouped
          .putIfAbsent(set.exerciseOrder, () => <SessionSetRecord>[])
          .add(set);
    }
    final orders = grouped.keys.toList(growable: false)..sort();
    for (final order in orders) {
      final sets = grouped[order]!
        ..sort((left, right) => left.setOrder.compareTo(right.setOrder));
      exerciseSummaries.add(
        TodaySessionExerciseSummary(
          exerciseId: sets.first.exerciseId,
          exerciseOrder: order,
          setSummaries: List.unmodifiable([
            for (final set in sets)
              TodaySessionSetSummary(
                sessionSet: set,
                prescribedSet: set.prescribedSetId == null
                    ? null
                    : prescriptionById[set.prescribedSetId],
                latestLog: _latestLog(logsBySessionSetId[set.id] ?? const []),
                previousPerformance: _previousPerformanceForSet(
                  previousPerformanceByExerciseId[set.exerciseId] ?? const [],
                  set.setOrder,
                ),
              ),
          ]),
        ),
      );
    }

    return TodaySessionSummary(
      session: session,
      exerciseSummaries: List.unmodifiable(exerciseSummaries),
      restoredAfterProcessTermination: restoredAfterProcessTermination,
    );
  }

  String _nextId(String prefix, DateTime now) {
    _idSerial += 1;
    return '${prefix}_${now.microsecondsSinceEpoch.toRadixString(36)}_'
        '${_idSerial.toRadixString(36)}';
  }

  String _actualSetLogId({
    required String sessionSetId,
    required int revision,
    required DateTime recordedAt,
  }) {
    return 'log_${recordedAt.microsecondsSinceEpoch.toRadixString(36)}_'
        '${_stableShortHash(sessionSetId)}_${revision.toRadixString(36)}';
  }

  Future<Map<String, List<ExerciseSetPerformanceRecord>>>
  _loadPreviousPerformanceByExercise({
    required WorkoutSessionRecord session,
    required List<SessionSetRecord> sessionSets,
    required WorkoutRepository workoutRepository,
  }) async {
    final exerciseIds = {for (final set in sessionSets) set.exerciseId};
    final result = <String, List<ExerciseSetPerformanceRecord>>{};
    await Future.wait([
      for (final exerciseId in exerciseIds)
        workoutRepository
            .getExercisePerformanceHistory(
              profileId: session.profileId,
              exerciseId: exerciseId,
              excludedSessionId: session.id,
            )
            .then((history) => result[exerciseId] = history),
    ]);
    return result;
  }
}

List<TodayTrainingDayPlan> _buildTrainingDayPlans(
  List<ProgramTrainingDayRecord> trainingDays,
  List<PrescribedSetRecord> prescription,
) {
  final sortedDays = List<ProgramTrainingDayRecord>.of(trainingDays)
    ..sort(
      (left, right) => left.trainingDayOrder.compareTo(right.trainingDayOrder),
    );

  return [
    for (final day in sortedDays)
      TodayTrainingDayPlan(
        day: day,
        exercisePlans: _buildExercisePlansForDay(
          trainingDayOrder: day.trainingDayOrder,
          prescription: prescription,
        ),
      ),
  ];
}

List<TodayExercisePlan> _buildExercisePlansForDay({
  required int trainingDayOrder,
  required List<PrescribedSetRecord> prescription,
}) {
  final grouped = <int, List<PrescribedSetRecord>>{};
  for (final set in prescription) {
    if (set.trainingDayOrder != trainingDayOrder) {
      continue;
    }
    grouped
        .putIfAbsent(set.exerciseOrder, () => <PrescribedSetRecord>[])
        .add(set);
  }

  final orders = grouped.keys.toList(growable: false)..sort();
  return [
    for (final order in orders)
      TodayExercisePlan(
        exerciseId: grouped[order]!.first.exerciseId,
        exerciseOrder: order,
        prescribedSets: List.unmodifiable(
          grouped[order]!
            ..sort((left, right) => left.setOrder.compareTo(right.setOrder)),
        ),
      ),
  ];
}

int? _resolveSelectedTrainingDayOrder(
  TodayProgramPlan plan, {
  required int? preferredOrder,
}) {
  if (plan.trainingDays.isEmpty) {
    return null;
  }
  if (preferredOrder != null &&
      plan.trainingDayByOrder(preferredOrder) != null) {
    return preferredOrder;
  }

  for (final day in plan.trainingDays) {
    if (day.hasExercises) {
      return day.trainingDayOrder;
    }
  }
  return plan.trainingDays.first.trainingDayOrder;
}

TodayCoachSummary _buildCoachSummary({
  required List<WorkoutSessionRecord> sessions,
  required TodayProgramPlan? activeProgramPlan,
  required DateTime now,
}) {
  final target =
      activeProgramPlan?.trainingDays.where((day) => day.hasExercises).length ??
      0;
  final achievementFeedback = buildLocalAchievementFeedback(
    sessions: sessions,
    now: now,
    weeklyWorkoutTarget: target,
  );

  return TodayCoachSummary(
    currentStreakDays: achievementFeedback.currentStreakDays,
    completedWorkoutsThisWeek: achievementFeedback.completedWorkoutDaysThisWeek,
    weeklyWorkoutTarget: target,
  );
}

ActualSetLogRecord? _latestLog(List<ActualSetLogRecord> logs) {
  if (logs.isEmpty) {
    return null;
  }

  var latest = logs.first;
  for (final log in logs.skip(1)) {
    if (log.revision > latest.revision) {
      latest = log;
    }
  }
  return latest;
}

ExerciseSetPerformanceRecord? _previousPerformanceForSet(
  List<ExerciseSetPerformanceRecord> history,
  int setOrder,
) {
  return _firstWhereOrNull(
    history,
    (performance) => performance.setOrder == setOrder,
  );
}

T? _firstWhereOrNull<T>(Iterable<T> items, bool Function(T item) test) {
  for (final item in items) {
    if (test(item)) {
      return item;
    }
  }
  return null;
}

String _stableShortHash(String value) {
  var hash = 0x811c9dc5;
  for (final unit in value.codeUnits) {
    hash ^= unit;
    hash = (hash * 0x01000193) & 0xffffffff;
  }
  return hash.toRadixString(36);
}
