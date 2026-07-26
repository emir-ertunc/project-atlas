import 'package:project_atlas/core/repositories/repository_records.dart';

const localAchievementFeedbackRuleSetVersion = 'local_achievement_feedback.v1';

enum LocalAchievementFeedbackKind {
  start,
  streakActive,
  weekOnTrack,
  milestonesComplete,
}

enum LocalMilestoneKind {
  firstWorkout,
  twoWorkoutDaysInWeek,
  firstPersonalRecord,
  bodyComparison,
}

final class LocalAchievementFeedback {
  const LocalAchievementFeedback({
    required this.ruleSetVersion,
    required this.generatedAt,
    required this.currentStreakDays,
    required this.bestStreakDays,
    required this.completedWorkoutDaysThisWeek,
    required this.weeklyWorkoutTarget,
    required this.milestones,
  });

  final String ruleSetVersion;
  final DateTime generatedAt;
  final int currentStreakDays;
  final int bestStreakDays;
  final int completedWorkoutDaysThisWeek;
  final int weeklyWorkoutTarget;
  final List<LocalMilestone> milestones;

  bool get hasWeeklyTarget => weeklyWorkoutTarget > 0;

  double get weeklyConsistencyRatio {
    if (!hasWeeklyTarget) {
      return 0;
    }
    return (completedWorkoutDaysThisWeek / weeklyWorkoutTarget)
        .clamp(0.0, 1.0)
        .toDouble();
  }

  int get weeklyConsistencyPercent => (weeklyConsistencyRatio * 100).round();

  int get completedMilestoneCount =>
      milestones.where((milestone) => milestone.isComplete).length;

  double get milestoneProgress =>
      milestones.isEmpty ? 0 : completedMilestoneCount / milestones.length;

  LocalMilestone? get nextMilestone {
    for (final milestone in milestones) {
      if (!milestone.isComplete) {
        return milestone;
      }
    }
    return null;
  }

  LocalAchievementFeedbackKind get feedbackKind {
    if (milestones.isNotEmpty && completedMilestoneCount == milestones.length) {
      return LocalAchievementFeedbackKind.milestonesComplete;
    }
    if (completedWorkoutDaysThisWeek >= 2) {
      return LocalAchievementFeedbackKind.weekOnTrack;
    }
    if (currentStreakDays > 0) {
      return LocalAchievementFeedbackKind.streakActive;
    }
    return LocalAchievementFeedbackKind.start;
  }
}

final class LocalMilestone {
  const LocalMilestone({required this.kind, required this.isComplete});

  final LocalMilestoneKind kind;
  final bool isComplete;
}

LocalAchievementFeedback buildLocalAchievementFeedback({
  required Iterable<WorkoutSessionRecord> sessions,
  required DateTime now,
  int weeklyWorkoutTarget = 0,
  bool hasPersonalRecord = false,
  bool hasMeasurementComparison = false,
}) {
  final generatedAt = now.toUtc();
  final today = _utcDateOnly(generatedAt);
  final completedDates = _completedWorkoutDates(sessions, today);
  final completedWorkoutDaysThisWeek = _completedWorkoutDaysThisWeek(
    completedDates: completedDates,
    today: today,
  );

  return LocalAchievementFeedback(
    ruleSetVersion: localAchievementFeedbackRuleSetVersion,
    generatedAt: generatedAt,
    currentStreakDays: _currentWorkoutStreakDays(
      completedDates: completedDates,
      today: today,
    ),
    bestStreakDays: _bestWorkoutStreakDays(completedDates),
    completedWorkoutDaysThisWeek: completedWorkoutDaysThisWeek,
    weeklyWorkoutTarget: weeklyWorkoutTarget < 0 ? 0 : weeklyWorkoutTarget,
    milestones: [
      LocalMilestone(
        kind: LocalMilestoneKind.firstWorkout,
        isComplete: completedDates.isNotEmpty,
      ),
      LocalMilestone(
        kind: LocalMilestoneKind.twoWorkoutDaysInWeek,
        isComplete: completedWorkoutDaysThisWeek >= 2,
      ),
      LocalMilestone(
        kind: LocalMilestoneKind.firstPersonalRecord,
        isComplete: hasPersonalRecord,
      ),
      LocalMilestone(
        kind: LocalMilestoneKind.bodyComparison,
        isComplete: hasMeasurementComparison,
      ),
    ],
  );
}

Set<DateTime> _completedWorkoutDates(
  Iterable<WorkoutSessionRecord> sessions,
  DateTime today,
) {
  return {
    for (final session in sessions)
      if (_sessionCompletedAt(session) case final completedAt?)
        if (!_utcDateOnly(completedAt).isAfter(today))
          _utcDateOnly(completedAt),
  };
}

DateTime? _sessionCompletedAt(WorkoutSessionRecord session) {
  if (session.lifecycle != WorkoutLifecycle.completed) {
    return null;
  }
  return (session.endedAt ?? session.startedAt ?? session.scheduledAt)?.toUtc();
}

int _completedWorkoutDaysThisWeek({
  required Set<DateTime> completedDates,
  required DateTime today,
}) {
  final weekStart = today.subtract(const Duration(days: 6));
  return completedDates
      .where((date) => !date.isBefore(weekStart) && !date.isAfter(today))
      .length;
}

int _currentWorkoutStreakDays({
  required Set<DateTime> completedDates,
  required DateTime today,
}) {
  if (completedDates.isEmpty) {
    return 0;
  }
  final sortedDates = completedDates.toList(growable: false)..sort();
  final latestCompletedDate = sortedDates.last;
  if (latestCompletedDate.isBefore(today.subtract(const Duration(days: 6)))) {
    return 0;
  }

  var streak = 0;
  var cursor = latestCompletedDate;
  while (completedDates.contains(cursor)) {
    streak += 1;
    cursor = cursor.subtract(const Duration(days: 1));
  }
  return streak;
}

int _bestWorkoutStreakDays(Set<DateTime> completedDates) {
  if (completedDates.isEmpty) {
    return 0;
  }

  final sortedDates = completedDates.toList(growable: false)..sort();
  var best = 1;
  var current = 1;

  for (var index = 1; index < sortedDates.length; index += 1) {
    final previous = sortedDates[index - 1];
    final currentDate = sortedDates[index];
    if (currentDate.difference(previous).inDays == 1) {
      current += 1;
    } else {
      current = 1;
    }
    if (current > best) {
      best = current;
    }
  }

  return best;
}

DateTime _utcDateOnly(DateTime value) {
  final utc = value.toUtc();
  return DateTime.utc(utc.year, utc.month, utc.day);
}
