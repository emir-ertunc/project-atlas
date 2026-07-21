import 'package:flutter_test/flutter_test.dart';
import 'package:project_atlas/features/adaptive_programming/domain/bounded_progression.dart';
import 'package:project_atlas/features/program/domain/program_builder.dart';

void main() {
  const policy = BoundedProgressionPolicy(loadIncrementKilograms: 2.5);

  test('rounds an increase request to the available load increment', () {
    final decision = proposeBoundedLoadProgression(
      prescription: _prescription(loadKilograms: 80),
      direction: BoundedProgressionDirection.increase,
      policy: policy,
      requestedChangeKilograms: 0.5,
    );

    expect(decision.ruleSetVersion, boundedProgressionRuleSetVersion);
    expect(decision.status, BoundedProgressionStatus.proposed);
    expect(decision.previousLoadKilograms, 80);
    expect(decision.proposedLoadKilograms, 82.5);
    expect(decision.appliedChangeKilograms, 2.5);
    expect(
      decision.limits,
      contains(BoundedProgressionLimit.roundedToLoadIncrement),
    );
    expect(decision.requiresUserConfirmation, isTrue);
  });

  test('caps an aggressive increase by the maximum increase percentage', () {
    final decision = proposeBoundedLoadProgression(
      prescription: _prescription(loadKilograms: 100),
      direction: BoundedProgressionDirection.increase,
      policy: const BoundedProgressionPolicy(
        loadIncrementKilograms: 2.5,
        maximumIncreasePercent: 5,
      ),
      requestedChangeKilograms: 12.5,
    );

    expect(decision.status, BoundedProgressionStatus.proposed);
    expect(decision.proposedLoadKilograms, 105);
    expect(decision.appliedChangeKilograms, 5);
    expect(
      decision.limits,
      contains(BoundedProgressionLimit.increaseCappedByPercent),
    );
  });

  test('returns a hold decision without changing the prescription', () {
    final prescription = _prescription(loadKilograms: 60);
    final decision = proposeBoundedLoadProgression(
      prescription: prescription,
      direction: BoundedProgressionDirection.hold,
      policy: policy,
    );

    expect(decision.status, BoundedProgressionStatus.held);
    expect(decision.proposedLoadKilograms, 60);
    expect(decision.appliedChangeKilograms, 0);
    expect(decision.requiresUserConfirmation, isFalse);
    expect(identical(decision.applyTo(prescription), prescription), isTrue);
  });

  test('caps an aggressive decrease by the maximum decrease percentage', () {
    final decision = proposeBoundedLoadProgression(
      prescription: _prescription(loadKilograms: 100),
      direction: BoundedProgressionDirection.decrease,
      policy: const BoundedProgressionPolicy(
        loadIncrementKilograms: 2.5,
        maximumDecreasePercent: 10,
      ),
      requestedChangeKilograms: -25,
    );

    expect(decision.status, BoundedProgressionStatus.proposed);
    expect(decision.proposedLoadKilograms, 90);
    expect(decision.appliedChangeKilograms, -10);
    expect(
      decision.limits,
      contains(BoundedProgressionLimit.decreaseCappedByPercent),
    );
  });

  test('does not decrease below the configured minimum load floor', () {
    final decision = proposeBoundedLoadProgression(
      prescription: _prescription(loadKilograms: 5),
      direction: BoundedProgressionDirection.decrease,
      policy: const BoundedProgressionPolicy(
        loadIncrementKilograms: 2.5,
        minimumLoadKilograms: 4,
        maximumDecreasePercent: 50,
      ),
      requestedChangeKilograms: -5,
    );

    expect(decision.status, BoundedProgressionStatus.proposed);
    expect(decision.proposedLoadKilograms, 4);
    expect(decision.appliedChangeKilograms, -1);
    expect(decision.limits, contains(BoundedProgressionLimit.minimumLoadFloor));
  });

  test('reports missing current load when a load change is requested', () {
    final decision = proposeBoundedLoadProgression(
      prescription: _prescription(loadKilograms: null),
      direction: BoundedProgressionDirection.increase,
      policy: policy,
    );

    expect(decision.status, BoundedProgressionStatus.notComparable);
    expect(
      decision.blockers,
      contains(BoundedProgressionBlocker.missingCurrentLoad),
    );
    expect(decision.requiresUserConfirmation, isFalse);
  });
}

ProgramExercisePrescription _prescription({required double? loadKilograms}) {
  return ProgramExercisePrescription(
    exerciseId: 'barbell_bench_press',
    setCount: 3,
    minimumRepetitions: 6,
    maximumRepetitions: 8,
    targetRir: 2,
    loadKilograms: loadKilograms,
    restSeconds: 120,
  );
}
