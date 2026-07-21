import 'package:flutter_test/flutter_test.dart';
import 'package:project_atlas/core/repositories/repository_records.dart';
import 'package:project_atlas/features/adaptive_programming/domain/missed_session_replacement.dart';
import 'package:project_atlas/features/adaptive_programming/domain/program_generator.dart';

void main() {
  final now = DateTime.utc(2026, 7, 21, 12);

  test('proposes the earliest spare window that preserves recovery', () {
    final plan = _plan(goal: TrainingGoal.generalFitness);

    final proposal = proposeMissedSessionReplacement(
      plan: plan,
      missedDayId: 'day_1',
      availabilityWindows: [
        _window(now, TrainingWeekday.monday),
        _window(now, TrainingWeekday.tuesday),
        _window(now, TrainingWeekday.wednesday),
        _window(now, TrainingWeekday.friday),
      ],
    );

    expect(proposal.ruleSetVersion, missedSessionReplacementRuleSetVersion);
    expect(proposal.status, MissedSessionReplacementStatus.proposed);
    expect(proposal.blockers, isEmpty);
    expect(proposal.window?.weekday, TrainingWeekday.tuesday);
    expect(proposal.window?.startMinute, 18 * 60);
    expect(proposal.window?.endMinute, 19 * 60);
    expect(proposal.window?.dayOffset, 1);
    expect(proposal.minimumRecoveryMinutes, 24 * 60);
  });

  test('skips too-short availability and uses the next safe spare window', () {
    final plan = _plan(goal: TrainingGoal.generalFitness);

    final proposal = proposeMissedSessionReplacement(
      plan: plan,
      missedDayId: 'day_1',
      availabilityWindows: [
        _window(now, TrainingWeekday.monday),
        _window(now, TrainingWeekday.tuesday, endMinute: 18 * 60 + 30),
        _window(now, TrainingWeekday.wednesday),
        _window(now, TrainingWeekday.thursday),
        _window(now, TrainingWeekday.friday),
      ],
    );

    expect(proposal.status, MissedSessionReplacementStatus.proposed);
    expect(proposal.window?.weekday, TrainingWeekday.thursday);
    expect(proposal.window?.dayOffset, 3);
  });

  test('rejects windows that would violate strength recovery spacing', () {
    final plan = _plan(goal: TrainingGoal.maximumStrength);

    final proposal = proposeMissedSessionReplacement(
      plan: plan,
      missedDayId: 'day_1',
      availabilityWindows: [
        _window(now, TrainingWeekday.monday),
        _window(now, TrainingWeekday.tuesday),
        _window(now, TrainingWeekday.wednesday),
        _window(now, TrainingWeekday.thursday),
        _window(now, TrainingWeekday.friday),
      ],
    );

    expect(proposal.status, MissedSessionReplacementStatus.noSafeWindow);
    expect(
      proposal.blockers,
      contains(MissedSessionReplacementBlocker.recoveryAfterConflict),
    );
    expect(
      proposal.blockers,
      contains(MissedSessionReplacementBlocker.recoveryBeforeConflict),
    );
    expect(proposal.window, isNull);
  });

  test('reports a missing planned day instead of guessing a replacement', () {
    final proposal = proposeMissedSessionReplacement(
      plan: _plan(goal: TrainingGoal.generalFitness),
      missedDayId: 'day_99',
      availabilityWindows: [_window(now, TrainingWeekday.tuesday)],
    );

    expect(proposal.status, MissedSessionReplacementStatus.missedDayNotFound);
    expect(proposal.hasReplacement, isFalse);
  });
}

GeneratedProgramPlan _plan({required TrainingGoal goal}) {
  return GeneratedProgramPlan(
    ruleSetVersion: adaptiveProgramPlannerRuleSetVersion,
    name: 'Test plan',
    goal: goal,
    experienceLevel: TrainingExperienceLevel.beginner,
    sessionsPerWeek: 3,
    sessionLengthMinutes: 60,
    weeklySetTarget: 18,
    minimumRir: 3,
    maxExercisesPerSession: 4,
    availableEquipment: const [EquipmentPreference.bodyweight],
    days: [
      _day(
        id: 'day_1',
        weekday: TrainingWeekday.monday,
        focus: GeneratedProgramDayFocus.fullBody,
      ),
      _day(
        id: 'day_2',
        weekday: TrainingWeekday.wednesday,
        focus: GeneratedProgramDayFocus.upperEmphasis,
      ),
      _day(
        id: 'day_3',
        weekday: TrainingWeekday.friday,
        focus: GeneratedProgramDayFocus.lowerEmphasis,
      ),
    ],
  );
}

GeneratedTrainingDayPlan _day({
  required String id,
  required TrainingWeekday weekday,
  required GeneratedProgramDayFocus focus,
}) {
  return GeneratedTrainingDayPlan(
    id: id,
    name: id,
    weekday: weekday,
    windowType: AvailabilityWindowType.flexible,
    startMinute: 18 * 60,
    endMinute: 19 * 60,
    focus: focus,
    prescriptions: const [],
  );
}

AvailabilityWindowRecord _window(
  DateTime now,
  TrainingWeekday weekday, {
  int startMinute = 18 * 60,
  int endMinute = 19 * 60,
}) {
  return AvailabilityWindowRecord(
    id: 'availability-${weekday.name}-$startMinute-$endMinute',
    profileId: 'profile-1',
    weekday: weekday,
    windowType: AvailabilityWindowType.flexible,
    startMinute: startMinute,
    endMinute: endMinute,
    createdAt: now,
    updatedAt: now,
  );
}
