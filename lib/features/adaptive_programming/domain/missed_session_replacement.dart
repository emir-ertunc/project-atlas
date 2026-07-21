import 'dart:math' as math;

import 'package:project_atlas/core/repositories/repository_records.dart';
import 'package:project_atlas/features/adaptive_programming/domain/program_generator.dart';

const missedSessionReplacementRuleSetVersion = 'missed_session_replacement.v1';

enum MissedSessionReplacementStatus {
  proposed,
  noSafeWindow,
  missedDayNotFound,
}

enum MissedSessionReplacementBlocker {
  noAvailabilityAfterMiss,
  insufficientWindowDuration,
  alreadyPlannedWindow,
  recoveryBeforeConflict,
  recoveryAfterConflict,
}

final class MissedSessionReplacementProposal {
  const MissedSessionReplacementProposal({
    required this.ruleSetVersion,
    required this.status,
    required this.missedDayId,
    required this.minimumRecoveryMinutes,
    required this.blockers,
    this.window,
  });

  final String ruleSetVersion;
  final MissedSessionReplacementStatus status;
  final String missedDayId;
  final int minimumRecoveryMinutes;
  final List<MissedSessionReplacementBlocker> blockers;
  final MissedSessionReplacementWindow? window;

  bool get hasReplacement =>
      status == MissedSessionReplacementStatus.proposed && window != null;
}

final class MissedSessionReplacementWindow {
  const MissedSessionReplacementWindow({
    required this.sourceWindowId,
    required this.weekday,
    required this.windowType,
    required this.startMinute,
    required this.endMinute,
    required this.dayOffset,
  });

  final String sourceWindowId;
  final TrainingWeekday weekday;
  final AvailabilityWindowType windowType;
  final int startMinute;
  final int endMinute;
  final int dayOffset;

  int get durationMinutes => endMinute - startMinute;
}

MissedSessionReplacementProposal proposeMissedSessionReplacement({
  required GeneratedProgramPlan plan,
  required String missedDayId,
  required List<AvailabilityWindowRecord> availabilityWindows,
}) {
  final missedDay = _findMissedDay(plan, missedDayId);
  final minimumRecoveryMinutes = _minimumRecoveryMinutes(plan.goal);

  if (missedDay == null) {
    return MissedSessionReplacementProposal(
      ruleSetVersion: missedSessionReplacementRuleSetVersion,
      status: MissedSessionReplacementStatus.missedDayNotFound,
      missedDayId: missedDayId,
      minimumRecoveryMinutes: minimumRecoveryMinutes,
      blockers: const [],
    );
  }

  final sessionLengthMinutes = math.max(30, plan.sessionLengthMinutes);
  final missedStart = _weekMinute(missedDay.weekday, missedDay.startMinute);
  final plannedWindowKeys = {
    for (final day in plan.days)
      _WindowKey(
        weekday: day.weekday,
        windowType: day.windowType,
        startMinute: day.startMinute,
        endMinute: day.endMinute,
      ),
  };
  final remainingStarts = _remainingTrainingStarts(
    plan: plan,
    missedDayId: missedDayId,
  );
  final blockers = <MissedSessionReplacementBlocker>{};
  final candidates = <_CandidateReplacement>[];

  for (final window in availabilityWindows.where(_isValidWindow)) {
    if (window.durationMinutes < sessionLengthMinutes) {
      blockers.add(MissedSessionReplacementBlocker.insufficientWindowDuration);
      continue;
    }

    final windowKey = _WindowKey(
      weekday: window.weekday,
      windowType: window.windowType,
      startMinute: window.startMinute,
      endMinute: window.endMinute,
    );
    if (plannedWindowKeys.contains(windowKey)) {
      blockers.add(MissedSessionReplacementBlocker.alreadyPlannedWindow);
      continue;
    }

    final candidateStart = _candidateStartAfterMiss(
      window: window,
      missedStart: missedStart,
    );
    if (candidateStart == null) {
      blockers.add(MissedSessionReplacementBlocker.noAvailabilityAfterMiss);
      continue;
    }

    final previousGap = _previousTrainingGap(
      candidateStart: candidateStart,
      remainingStarts: remainingStarts,
    );
    if (previousGap != null && previousGap < minimumRecoveryMinutes) {
      blockers.add(MissedSessionReplacementBlocker.recoveryBeforeConflict);
      continue;
    }

    final nextGap = _nextTrainingGap(
      candidateStart: candidateStart,
      remainingStarts: remainingStarts,
    );
    if (nextGap != null && nextGap < minimumRecoveryMinutes) {
      blockers.add(MissedSessionReplacementBlocker.recoveryAfterConflict);
      continue;
    }

    candidates.add(
      _CandidateReplacement(
        candidateStart: candidateStart,
        window: MissedSessionReplacementWindow(
          sourceWindowId: window.id,
          weekday: window.weekday,
          windowType: window.windowType,
          startMinute: window.startMinute,
          endMinute: window.startMinute + sessionLengthMinutes,
          dayOffset: _dayOffsetAfterMiss(
            missedStart: missedStart,
            candidateStart: candidateStart,
          ),
        ),
      ),
    );
  }

  if (candidates.isEmpty) {
    return MissedSessionReplacementProposal(
      ruleSetVersion: missedSessionReplacementRuleSetVersion,
      status: MissedSessionReplacementStatus.noSafeWindow,
      missedDayId: missedDayId,
      minimumRecoveryMinutes: minimumRecoveryMinutes,
      blockers: List.unmodifiable(
        blockers.isEmpty
            ? {MissedSessionReplacementBlocker.noAvailabilityAfterMiss}
            : blockers,
      ),
    );
  }

  candidates.sort((left, right) {
    final startComparison = left.candidateStart.compareTo(right.candidateStart);
    if (startComparison != 0) {
      return startComparison;
    }
    return left.window.windowType.index.compareTo(
      right.window.windowType.index,
    );
  });

  return MissedSessionReplacementProposal(
    ruleSetVersion: missedSessionReplacementRuleSetVersion,
    status: MissedSessionReplacementStatus.proposed,
    missedDayId: missedDayId,
    minimumRecoveryMinutes: minimumRecoveryMinutes,
    blockers: const [],
    window: candidates.first.window,
  );
}

GeneratedTrainingDayPlan? _findMissedDay(
  GeneratedProgramPlan plan,
  String missedDayId,
) {
  for (final day in plan.days) {
    if (day.id == missedDayId) {
      return day;
    }
  }
  return null;
}

int _minimumRecoveryMinutes(TrainingGoal goal) {
  return switch (goal) {
    TrainingGoal.maximumStrength => 48 * _minutesPerHour,
    TrainingGoal.hypertrophy ||
    TrainingGoal.bodyRecomposition ||
    TrainingGoal.athleticPerformance => 36 * _minutesPerHour,
    TrainingGoal.generalFitness ||
    TrainingGoal.muscularEndurance ||
    TrainingGoal.maintenance => 24 * _minutesPerHour,
  };
}

List<int> _remainingTrainingStarts({
  required GeneratedProgramPlan plan,
  required String missedDayId,
}) {
  final starts = <int>[];
  for (final day in plan.days) {
    if (day.id == missedDayId) {
      continue;
    }

    final start = _weekMinute(day.weekday, day.startMinute);
    starts
      ..add(start - _minutesPerWeek)
      ..add(start)
      ..add(start + _minutesPerWeek)
      ..add(start + (_minutesPerWeek * 2));
  }
  starts.sort();
  return List.unmodifiable(starts);
}

int? _candidateStartAfterMiss({
  required AvailabilityWindowRecord window,
  required int missedStart,
}) {
  var candidateStart = _weekMinute(window.weekday, window.startMinute);
  while (candidateStart <= missedStart) {
    candidateStart += _minutesPerWeek;
  }

  if (candidateStart > missedStart + _minutesPerWeek) {
    return null;
  }
  return candidateStart;
}

int? _previousTrainingGap({
  required int candidateStart,
  required List<int> remainingStarts,
}) {
  int? previousStart;
  for (final start in remainingStarts) {
    if (start < candidateStart) {
      previousStart = start;
    } else {
      break;
    }
  }

  return previousStart == null ? null : candidateStart - previousStart;
}

int? _nextTrainingGap({
  required int candidateStart,
  required List<int> remainingStarts,
}) {
  for (final start in remainingStarts) {
    if (start > candidateStart) {
      return start - candidateStart;
    }
  }
  return null;
}

bool _isValidWindow(AvailabilityWindowRecord window) {
  return window.durationMinutes > 0 &&
      window.startMinute >= 0 &&
      window.endMinute <= _minutesPerDay;
}

int _weekMinute(TrainingWeekday weekday, int minuteOfDay) {
  return TrainingWeekday.values.indexOf(weekday) * _minutesPerDay + minuteOfDay;
}

int _dayOffsetAfterMiss({
  required int missedStart,
  required int candidateStart,
}) {
  return (candidateStart ~/ _minutesPerDay) - (missedStart ~/ _minutesPerDay);
}

const _minutesPerHour = 60;
const _minutesPerDay = 24 * _minutesPerHour;
const _minutesPerWeek = 7 * _minutesPerDay;

final class _CandidateReplacement {
  const _CandidateReplacement({
    required this.candidateStart,
    required this.window,
  });

  final int candidateStart;
  final MissedSessionReplacementWindow window;
}

final class _WindowKey {
  const _WindowKey({
    required this.weekday,
    required this.windowType,
    required this.startMinute,
    required this.endMinute,
  });

  final TrainingWeekday weekday;
  final AvailabilityWindowType windowType;
  final int startMinute;
  final int endMinute;

  @override
  bool operator ==(Object other) {
    return other is _WindowKey &&
        other.weekday == weekday &&
        other.windowType == windowType &&
        other.startMinute == startMinute &&
        other.endMinute == endMinute;
  }

  @override
  int get hashCode => Object.hash(weekday, windowType, startMinute, endMinute);
}
