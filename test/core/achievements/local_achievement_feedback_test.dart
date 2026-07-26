import 'package:flutter_test/flutter_test.dart';
import 'package:project_atlas/core/achievements/local_achievement_feedback.dart';
import 'package:project_atlas/core/repositories/repository_records.dart';

void main() {
  test('builds local workout streaks from completed session days only', () {
    final now = DateTime.utc(2026, 7, 20, 10);
    final feedback = buildLocalAchievementFeedback(
      sessions: [
        _session(id: 'completed-1', at: DateTime.utc(2026, 7, 19, 9)),
        _session(id: 'completed-2', at: DateTime.utc(2026, 7, 18, 9)),
        _session(id: 'completed-3', at: DateTime.utc(2026, 7, 16, 9)),
        _session(
          id: 'planned-today',
          at: DateTime.utc(2026, 7, 20, 9),
          lifecycle: WorkoutLifecycle.planned,
        ),
        _session(id: 'future-completed', at: DateTime.utc(2026, 7, 21, 9)),
      ],
      now: now,
      weeklyWorkoutTarget: 3,
    );

    expect(feedback.ruleSetVersion, localAchievementFeedbackRuleSetVersion);
    expect(feedback.currentStreakDays, 2);
    expect(feedback.bestStreakDays, 2);
    expect(feedback.completedWorkoutDaysThisWeek, 3);
    expect(feedback.weeklyConsistencyPercent, 100);
    expect(feedback.feedbackKind, LocalAchievementFeedbackKind.weekOnTrack);
  });

  test('keeps stale completed workouts out of the current streak window', () {
    final now = DateTime.utc(2026, 7, 20, 10);
    final feedback = buildLocalAchievementFeedback(
      sessions: [
        _session(id: 'old-1', at: DateTime.utc(2026, 7, 10, 9)),
        _session(id: 'old-2', at: DateTime.utc(2026, 7, 9, 9)),
      ],
      now: now,
      weeklyWorkoutTarget: 4,
    );

    expect(feedback.currentStreakDays, 0);
    expect(feedback.bestStreakDays, 2);
    expect(feedback.completedWorkoutDaysThisWeek, 0);
    expect(feedback.weeklyConsistencyPercent, 0);
    expect(feedback.feedbackKind, LocalAchievementFeedbackKind.start);
  });

  test('marks local milestones from existing read models', () {
    final now = DateTime.utc(2026, 7, 20, 10);
    final feedback = buildLocalAchievementFeedback(
      sessions: [
        _session(id: 'today', at: DateTime.utc(2026, 7, 20, 8)),
        _session(id: 'yesterday', at: DateTime.utc(2026, 7, 19, 8)),
      ],
      now: now,
      hasPersonalRecord: true,
      hasMeasurementComparison: true,
    );

    expect(feedback.completedMilestoneCount, 4);
    expect(feedback.milestoneProgress, 1);
    expect(feedback.nextMilestone, isNull);
    expect(
      feedback.feedbackKind,
      LocalAchievementFeedbackKind.milestonesComplete,
    );
    expect(feedback.milestones.map((milestone) => milestone.kind), [
      LocalMilestoneKind.firstWorkout,
      LocalMilestoneKind.twoWorkoutDaysInWeek,
      LocalMilestoneKind.firstPersonalRecord,
      LocalMilestoneKind.bodyComparison,
    ]);
  });

  test('exposes the next incomplete local milestone', () {
    final now = DateTime.utc(2026, 7, 20, 10);
    final feedback = buildLocalAchievementFeedback(sessions: [], now: now);

    expect(feedback.completedMilestoneCount, 0);
    expect(feedback.nextMilestone?.kind, LocalMilestoneKind.firstWorkout);
    expect(feedback.feedbackKind, LocalAchievementFeedbackKind.start);
  });
}

WorkoutSessionRecord _session({
  required String id,
  required DateTime at,
  WorkoutLifecycle lifecycle = WorkoutLifecycle.completed,
}) {
  return WorkoutSessionRecord(
    id: id,
    profileId: 'profile-1',
    lifecycle: lifecycle,
    scheduledAt: at,
    startedAt: at,
    endedAt: at.add(const Duration(hours: 1)),
    createdAt: at,
    updatedAt: at.add(const Duration(hours: 1)),
  );
}
