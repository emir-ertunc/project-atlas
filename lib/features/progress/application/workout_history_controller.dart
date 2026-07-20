import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:project_atlas/core/repositories/repository_contracts.dart';
import 'package:project_atlas/core/repositories/repository_providers.dart';
import 'package:project_atlas/core/repositories/repository_records.dart';
import 'package:project_atlas/features/program/application/program_draft_persistence.dart';
import 'package:project_atlas/features/today/application/workout_status_calculator.dart';

final workoutHistoryClockProvider = Provider<DateTime Function()>(
  (ref) => DateTime.now,
);

final workoutHistoryProvider = FutureProvider<WorkoutHistoryState>((ref) async {
  final profileId = ref.read(localProgramProfileIdProvider);
  final programRepository = ref.read(programRepositoryProvider);
  final workoutRepository = ref.read(workoutRepositoryProvider);
  final sessions = await workoutRepository.getSessions(profileId);
  final prescriptionCache = <String, List<PrescribedSetRecord>>{};
  final summaries = <WorkoutHistorySessionSummary>[];

  for (final session in sessions) {
    final prescription = await _prescriptionForSession(
      session,
      programRepository,
      prescriptionCache,
    );
    summaries.add(
      await _buildSessionSummary(
        session: session,
        workoutRepository: workoutRepository,
        prescription: prescription,
      ),
    );
  }

  return WorkoutHistoryState(
    sessions: List.unmodifiable(summaries),
    personalRecords: _buildPersonalRecords(summaries),
  );
});

final workoutHistoryCorrectionControllerProvider =
    AsyncNotifierProvider<WorkoutHistoryCorrectionController, void>(
      WorkoutHistoryCorrectionController.new,
    );

class WorkoutHistoryCorrectionController extends AsyncNotifier<void> {
  @override
  FutureOr<void> build() {}

  Future<void> correctSet({
    required WorkoutHistorySetDetail detail,
    required int? repetitions,
    required double? loadKilograms,
    required int? rir,
    required SetResult? result,
  }) async {
    _validateCorrectionInputs(
      detail: detail,
      repetitions: repetitions,
      loadKilograms: loadKilograms,
      rir: rir,
      result: result,
    );

    final latestLog = detail.latestLog;
    if (latestLog == null ||
        detail.sessionSet.lifecycle != SetLifecycle.completed) {
      throw StateError(
        'Only completed sets with an existing log can be corrected.',
      );
    }

    final previousState = state;
    state = const AsyncLoading<void>();
    try {
      final now = ref.read(workoutHistoryClockProvider)().toUtc();
      final nextRevision = latestLog.revision + 1;
      final correction = ActualSetLogRecord(
        id: _actualSetLogId(
          sessionSetId: detail.sessionSet.id,
          revision: nextRevision,
          recordedAt: now,
        ),
        sessionSetId: detail.sessionSet.id,
        revision: nextRevision,
        repetitions: repetitions,
        loadKilograms: loadKilograms,
        rir: rir,
        result: result,
        supersedesLogId: latestLog.id,
        recordedAt: now,
      );

      await ref.read(workoutRepositoryProvider).appendActualSetLog(correction);
      ref.invalidate(workoutHistoryProvider);
      state = const AsyncData<void>(null);
    } catch (error, stackTrace) {
      state = AsyncError<void>(error, stackTrace);
      if (previousState.hasValue) {
        state = previousState;
      }
      Error.throwWithStackTrace(error, stackTrace);
    }
  }
}

final class WorkoutHistoryState {
  const WorkoutHistoryState({
    required this.sessions,
    required this.personalRecords,
  });

  final List<WorkoutHistorySessionSummary> sessions;
  final List<PersonalRecordSummary> personalRecords;

  bool get isEmpty => sessions.isEmpty;

  List<WorkoutHistorySetDetail> get setDetails => [
    for (final session in sessions) ...session.setDetails,
  ];

  WorkoutHistorySetDetail? get firstSetDetail =>
      setDetails.isEmpty ? null : setDetails.first;

  WorkoutHistorySetDetail? setDetailById(String? sessionSetId) {
    if (sessionSetId == null) {
      return null;
    }
    for (final detail in setDetails) {
      if (detail.sessionSet.id == sessionSetId) {
        return detail;
      }
    }
    return null;
  }
}

final class WorkoutHistorySessionSummary {
  const WorkoutHistorySessionSummary({
    required this.session,
    required this.exerciseSummaries,
  });

  final WorkoutSessionRecord session;
  final List<WorkoutHistoryExerciseSummary> exerciseSummaries;

  DateTime get occurredAt =>
      session.startedAt ?? session.scheduledAt ?? session.createdAt;

  int get exerciseCount => exerciseSummaries.length;

  int get setCount => exerciseSummaries.fold<int>(
    0,
    (total, exercise) => total + exercise.setDetails.length,
  );

  int get completedSetCount =>
      setDetails.where((detail) => detail.isCompleted).length;

  List<WorkoutHistorySetDetail> get setDetails => [
    for (final exercise in exerciseSummaries) ...exercise.setDetails,
  ];

  TodaySessionStatus get status => calculateTodaySessionStatus(
    exerciseSummaries.map((exercise) => exercise.status),
  );
}

final class WorkoutHistoryExerciseSummary {
  const WorkoutHistoryExerciseSummary({
    required this.exerciseId,
    required this.exerciseOrder,
    required this.setDetails,
  });

  final String exerciseId;
  final int exerciseOrder;
  final List<WorkoutHistorySetDetail> setDetails;

  TodayExerciseStatus get status =>
      calculateTodayExerciseStatus(setDetails.map((detail) => detail.status));
}

final class WorkoutHistorySetDetail {
  const WorkoutHistorySetDetail({
    required this.session,
    required this.sessionSet,
    required this.logs,
    this.prescribedSet,
  });

  final WorkoutSessionRecord session;
  final SessionSetRecord sessionSet;
  final PrescribedSetRecord? prescribedSet;
  final List<ActualSetLogRecord> logs;

  bool get isCompleted => sessionSet.lifecycle == SetLifecycle.completed;

  ActualSetLogRecord? get latestLog => _latestLog(logs);

  TodaySetStatus get status => calculateTodaySetStatus(
    lifecycle: sessionSet.lifecycle,
    prescribedSet: prescribedSet,
    latestLog: latestLog,
  );
}

final class PersonalRecordSummary {
  const PersonalRecordSummary({
    required this.exerciseId,
    this.bestLoad,
    this.bestRepetitions,
    this.bestVolume,
  });

  final String exerciseId;
  final PersonalRecordMark? bestLoad;
  final PersonalRecordMark? bestRepetitions;
  final PersonalRecordMark? bestVolume;

  bool get hasAnyRecord =>
      bestLoad != null || bestRepetitions != null || bestVolume != null;
}

final class PersonalRecordMark {
  const PersonalRecordMark({required this.setDetail, required this.value});

  final WorkoutHistorySetDetail setDetail;
  final double value;
}

Future<List<PrescribedSetRecord>> _prescriptionForSession(
  WorkoutSessionRecord session,
  ProgramRepository programRepository,
  Map<String, List<PrescribedSetRecord>> cache,
) async {
  final versionId = session.programVersionId;
  if (versionId == null) {
    return const [];
  }
  return cache[versionId] ??= await programRepository.getPrescription(
    versionId,
  );
}

Future<WorkoutHistorySessionSummary> _buildSessionSummary({
  required WorkoutSessionRecord session,
  required WorkoutRepository workoutRepository,
  required List<PrescribedSetRecord> prescription,
}) async {
  final prescriptionById = {
    for (final prescribedSet in prescription) prescribedSet.id: prescribedSet,
  };
  final sessionSets = await workoutRepository.getSessionSets(session.id);
  final logsBySetId = <String, List<ActualSetLogRecord>>{};
  await Future.wait([
    for (final set in sessionSets)
      workoutRepository
          .getActualSetLogs(set.id)
          .then((logs) => logsBySetId[set.id] = logs),
  ]);

  final grouped = <int, List<WorkoutHistorySetDetail>>{};
  for (final set in sessionSets) {
    final detail = WorkoutHistorySetDetail(
      session: session,
      sessionSet: set,
      prescribedSet: set.prescribedSetId == null
          ? null
          : prescriptionById[set.prescribedSetId],
      logs: List.unmodifiable(logsBySetId[set.id] ?? const []),
    );
    grouped.putIfAbsent(set.exerciseOrder, () => []).add(detail);
  }

  final exerciseOrders = grouped.keys.toList(growable: false)..sort();
  return WorkoutHistorySessionSummary(
    session: session,
    exerciseSummaries: List.unmodifiable([
      for (final order in exerciseOrders)
        WorkoutHistoryExerciseSummary(
          exerciseId: grouped[order]!.first.sessionSet.exerciseId,
          exerciseOrder: order,
          setDetails: List.unmodifiable(
            grouped[order]!..sort(
              (left, right) =>
                  left.sessionSet.setOrder.compareTo(right.sessionSet.setOrder),
            ),
          ),
        ),
    ]),
  );
}

List<PersonalRecordSummary> _buildPersonalRecords(
  List<WorkoutHistorySessionSummary> sessions,
) {
  final recordsByExerciseId = <String, _PersonalRecordBuilder>{};
  for (final session in sessions) {
    for (final detail in session.setDetails) {
      final log = detail.latestLog;
      if (!_qualifiesForPersonalRecord(log)) {
        continue;
      }
      final builder = recordsByExerciseId.putIfAbsent(
        detail.sessionSet.exerciseId,
        () => _PersonalRecordBuilder(detail.sessionSet.exerciseId),
      );
      builder.add(detail, log!);
    }
  }

  final records =
      recordsByExerciseId.values
          .map((builder) => builder.build())
          .where((record) => record.hasAnyRecord)
          .toList(growable: false)
        ..sort((left, right) => left.exerciseId.compareTo(right.exerciseId));
  return List.unmodifiable(records);
}

bool _qualifiesForPersonalRecord(ActualSetLogRecord? log) {
  if (log == null || log.result != null) {
    return false;
  }
  return log.repetitions != null || log.loadKilograms != null;
}

final class _PersonalRecordBuilder {
  _PersonalRecordBuilder(this.exerciseId);

  final String exerciseId;
  PersonalRecordMark? _bestLoad;
  PersonalRecordMark? _bestRepetitions;
  PersonalRecordMark? _bestVolume;

  void add(WorkoutHistorySetDetail detail, ActualSetLogRecord log) {
    final load = log.loadKilograms;
    if (load != null) {
      _bestLoad = _maxMark(
        current: _bestLoad,
        candidate: PersonalRecordMark(setDetail: detail, value: load),
      );
    }

    final repetitions = log.repetitions;
    if (repetitions != null) {
      _bestRepetitions = _maxMark(
        current: _bestRepetitions,
        candidate: PersonalRecordMark(
          setDetail: detail,
          value: repetitions.toDouble(),
        ),
      );
    }

    if (load != null && repetitions != null) {
      _bestVolume = _maxMark(
        current: _bestVolume,
        candidate: PersonalRecordMark(
          setDetail: detail,
          value: load * repetitions,
        ),
      );
    }
  }

  PersonalRecordSummary build() {
    return PersonalRecordSummary(
      exerciseId: exerciseId,
      bestLoad: _bestLoad,
      bestRepetitions: _bestRepetitions,
      bestVolume: _bestVolume,
    );
  }
}

PersonalRecordMark _maxMark({
  required PersonalRecordMark? current,
  required PersonalRecordMark candidate,
}) {
  if (current == null || candidate.value > current.value) {
    return candidate;
  }
  if (candidate.value == current.value &&
      candidate.setDetail.latestLog!.recordedAt.isAfter(
        current.setDetail.latestLog!.recordedAt,
      )) {
    return candidate;
  }
  return current;
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

void _validateCorrectionInputs({
  required WorkoutHistorySetDetail detail,
  required int? repetitions,
  required double? loadKilograms,
  required int? rir,
  required SetResult? result,
}) {
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
  if (detail.sessionSet.sessionId != detail.session.id) {
    throw ArgumentError.value(
      detail,
      'detail',
      'The selected set does not belong to its session.',
    );
  }
  if (repetitions == null &&
      loadKilograms == null &&
      rir == null &&
      result == null) {
    throw ArgumentError(
      'At least one corrected actual value or outcome must be recorded.',
    );
  }
}

String _actualSetLogId({
  required String sessionSetId,
  required int revision,
  required DateTime recordedAt,
}) {
  return 'correction_${recordedAt.microsecondsSinceEpoch.toRadixString(36)}_'
      '${_stableShortHash(sessionSetId)}_${revision.toRadixString(36)}';
}

String _stableShortHash(String value) {
  var hash = 0x811c9dc5;
  for (final unit in value.codeUnits) {
    hash ^= unit;
    hash = (hash * 0x01000193) & 0xffffffff;
  }
  return hash.toRadixString(36);
}
