import 'dart:math' as math;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:project_atlas/features/program/application/program_draft_persistence.dart';
import 'package:project_atlas/features/program/domain/program_builder.dart';

final programBuilderControllerProvider =
    NotifierProvider<ProgramBuilderController, ProgramBuilderState>(
      ProgramBuilderController.new,
    );

class ProgramBuilderController extends Notifier<ProgramBuilderState> {
  @override
  ProgramBuilderState build() => const ProgramBuilderState.initial();

  void createProgram({
    required String programName,
    required String firstDayName,
  }) {
    final firstDay = ProgramTrainingDay(
      id: _dayId(1),
      name: _cleanName(firstDayName, fallback: 'Day 1'),
      exercisePrescriptions: const <ProgramExercisePrescription>[],
    );
    state = ProgramBuilderState(
      draft: ProgramDraft(
        name: _cleanName(programName, fallback: 'New program'),
        trainingDays: <ProgramTrainingDay>[firstDay],
        selectedDayId: firstDay.id,
      ),
      nextDayNumber: 2,
    );
  }

  void replaceDraft(ProgramDraft draft) {
    if (draft.trainingDays.isEmpty) {
      return;
    }

    final selectedDayId = _hasDay(draft, draft.selectedDayId)
        ? draft.selectedDayId
        : draft.trainingDays.first.id;

    state = ProgramBuilderState(
      draft: draft.copyWith(
        selectedDayId: selectedDayId,
        lifecycle: ProgramDraftLifecycle.local,
        clearProgramId: true,
        clearLatestVersionId: true,
        latestVersionNumber: 0,
        clearLastPersistedAt: true,
      ),
      nextDayNumber: _nextDayNumberAfter(draft),
    );
  }

  void renameProgram(String name) {
    final draft = state.draft;
    if (draft == null || draft.isArchived) {
      return;
    }

    state = state.copyWith(
      draft: draft.copyWith(name: _cleanName(name, fallback: draft.name)),
    );
  }

  void addTrainingDay(String dayName) {
    final draft = state.draft;
    if (draft == null || draft.isArchived) {
      return;
    }

    final dayNumber = state.nextDayNumber;
    final day = ProgramTrainingDay(
      id: _dayId(dayNumber),
      name: _cleanName(dayName, fallback: 'Day $dayNumber'),
      exercisePrescriptions: const <ProgramExercisePrescription>[],
    );

    state = state.copyWith(
      draft: draft.copyWith(
        trainingDays: <ProgramTrainingDay>[...draft.trainingDays, day],
        selectedDayId: day.id,
      ),
      nextDayNumber: dayNumber + 1,
    );
  }

  void selectTrainingDay(String dayId) {
    final draft = state.draft;
    if (draft == null || !_hasDay(draft, dayId)) {
      return;
    }

    state = state.copyWith(draft: draft.copyWith(selectedDayId: dayId));
  }

  void renameTrainingDay(String dayId, String name) {
    final draft = state.draft;
    if (draft == null || draft.isArchived) {
      return;
    }

    state = state.copyWith(
      draft: draft.copyWith(
        trainingDays: [
          for (final day in draft.trainingDays)
            day.id == dayId
                ? day.copyWith(name: _cleanName(name, fallback: day.name))
                : day,
        ],
      ),
    );
  }

  void deleteTrainingDay(String dayId) {
    final draft = state.draft;
    if (draft == null || draft.isArchived || draft.trainingDays.length <= 1) {
      return;
    }

    final remainingDays = draft.trainingDays
        .where((day) => day.id != dayId)
        .toList(growable: false);
    if (remainingDays.length == draft.trainingDays.length) {
      return;
    }

    final selectedDayId = draft.selectedDayId == dayId
        ? remainingDays.first.id
        : draft.selectedDayId;

    state = state.copyWith(
      draft: draft.copyWith(
        trainingDays: remainingDays,
        selectedDayId: selectedDayId,
      ),
    );
  }

  void addExerciseToSelectedDay(String exerciseId) {
    final draft = state.draft;
    final selectedDay = draft?.selectedDay;
    if (draft == null ||
        draft.isArchived ||
        selectedDay == null ||
        exerciseId.trim().isEmpty) {
      return;
    }

    if (selectedDay.exerciseIds.contains(exerciseId)) {
      return;
    }

    _updateDay(
      selectedDay.id,
      (day) => day.copyWith(
        exercisePrescriptions: <ProgramExercisePrescription>[
          ...day.exercisePrescriptions,
          ProgramExercisePrescription.defaults(exerciseId),
        ],
      ),
    );
  }

  void removeExercise(String dayId, String exerciseId) {
    if (state.draft?.isArchived ?? false) {
      return;
    }

    _updateDay(
      dayId,
      (day) => day.copyWith(
        exercisePrescriptions: day.exercisePrescriptions
            .where((prescription) => prescription.exerciseId != exerciseId)
            .toList(growable: false),
      ),
    );
  }

  void moveExercise({
    required String dayId,
    required int fromIndex,
    required int toIndex,
  }) {
    if (state.draft?.isArchived ?? false) {
      return;
    }

    _updateDay(dayId, (day) {
      final prescriptions = day.exercisePrescriptions;
      if (fromIndex < 0 ||
          fromIndex >= prescriptions.length ||
          toIndex < 0 ||
          toIndex >= prescriptions.length ||
          fromIndex == toIndex) {
        return day;
      }

      final reordered = List<ProgramExercisePrescription>.of(prescriptions);
      final prescription = reordered.removeAt(fromIndex);
      reordered.insert(toIndex, prescription);
      return day.copyWith(exercisePrescriptions: reordered);
    });
  }

  void updateSetCount({
    required String dayId,
    required String exerciseId,
    required int setCount,
  }) {
    if (state.draft?.isArchived ?? false) {
      return;
    }

    _updatePrescription(
      dayId: dayId,
      exerciseId: exerciseId,
      transform: (prescription) => prescription.copyWith(
        setCount: _clampInt(
          setCount,
          ProgramExercisePrescription.minimumSetCount,
          ProgramExercisePrescription.maximumSetCount,
        ),
      ),
    );
  }

  void setRepetitionMode({
    required String dayId,
    required String exerciseId,
    required ProgramRepetitionMode mode,
  }) {
    if (state.draft?.isArchived ?? false) {
      return;
    }

    _updatePrescription(
      dayId: dayId,
      exerciseId: exerciseId,
      transform: (prescription) {
        if (mode == ProgramRepetitionMode.fixed) {
          return prescription.copyWith(
            maximumRepetitions: prescription.minimumRepetitions,
          );
        }

        if (prescription.repetitionMode == ProgramRepetitionMode.range) {
          return prescription;
        }

        final maximumRepetitions = _clampInt(
          prescription.minimumRepetitions + 2,
          ProgramExercisePrescription.minimumRepetitionsLimit,
          ProgramExercisePrescription.maximumRepetitionsLimit,
        );

        return prescription.copyWith(maximumRepetitions: maximumRepetitions);
      },
    );
  }

  void updateFixedRepetitions({
    required String dayId,
    required String exerciseId,
    required int repetitions,
  }) {
    if (state.draft?.isArchived ?? false) {
      return;
    }

    final normalized = _clampInt(
      repetitions,
      ProgramExercisePrescription.minimumRepetitionsLimit,
      ProgramExercisePrescription.maximumRepetitionsLimit,
    );

    _updatePrescription(
      dayId: dayId,
      exerciseId: exerciseId,
      transform: (prescription) => prescription.copyWith(
        minimumRepetitions: normalized,
        maximumRepetitions: normalized,
      ),
    );
  }

  void updateMinimumRepetitions({
    required String dayId,
    required String exerciseId,
    required int minimumRepetitions,
  }) {
    if (state.draft?.isArchived ?? false) {
      return;
    }

    final normalized = _clampInt(
      minimumRepetitions,
      ProgramExercisePrescription.minimumRepetitionsLimit,
      ProgramExercisePrescription.maximumRepetitionsLimit,
    );

    _updatePrescription(
      dayId: dayId,
      exerciseId: exerciseId,
      transform: (prescription) {
        final maximumRepetitions = prescription.maximumRepetitions < normalized
            ? normalized
            : prescription.maximumRepetitions;

        return prescription.copyWith(
          minimumRepetitions: normalized,
          maximumRepetitions: maximumRepetitions,
        );
      },
    );
  }

  void updateMaximumRepetitions({
    required String dayId,
    required String exerciseId,
    required int maximumRepetitions,
  }) {
    if (state.draft?.isArchived ?? false) {
      return;
    }

    final normalized = _clampInt(
      maximumRepetitions,
      ProgramExercisePrescription.minimumRepetitionsLimit,
      ProgramExercisePrescription.maximumRepetitionsLimit,
    );

    _updatePrescription(
      dayId: dayId,
      exerciseId: exerciseId,
      transform: (prescription) => prescription.copyWith(
        maximumRepetitions: normalized < prescription.minimumRepetitions
            ? prescription.minimumRepetitions
            : normalized,
      ),
    );
  }

  void updateTargetRirEnabled({
    required String dayId,
    required String exerciseId,
    required bool enabled,
  }) {
    if (state.draft?.isArchived ?? false) {
      return;
    }

    _updatePrescription(
      dayId: dayId,
      exerciseId: exerciseId,
      transform: (prescription) => enabled
          ? prescription.copyWith(
              targetRir:
                  prescription.targetRir ??
                  ProgramExercisePrescription.defaultTargetRir,
            )
          : prescription.copyWith(clearTargetRir: true),
    );
  }

  void updateTargetRir({
    required String dayId,
    required String exerciseId,
    required int targetRir,
  }) {
    if (state.draft?.isArchived ?? false) {
      return;
    }

    _updatePrescription(
      dayId: dayId,
      exerciseId: exerciseId,
      transform: (prescription) => prescription.copyWith(
        targetRir: _clampInt(
          targetRir,
          ProgramExercisePrescription.minimumRir,
          ProgramExercisePrescription.maximumRir,
        ),
      ),
    );
  }

  void updateLoadKilograms({
    required String dayId,
    required String exerciseId,
    required double? loadKilograms,
  }) {
    if (state.draft?.isArchived ?? false) {
      return;
    }

    _updatePrescription(
      dayId: dayId,
      exerciseId: exerciseId,
      transform: (prescription) {
        final normalized = loadKilograms == null
            ? null
            : loadKilograms < 0
            ? 0.0
            : loadKilograms;

        return normalized == null
            ? prescription.copyWith(clearLoadKilograms: true)
            : prescription.copyWith(loadKilograms: normalized);
      },
    );
  }

  void updateRestSeconds({
    required String dayId,
    required String exerciseId,
    required int restSeconds,
  }) {
    if (state.draft?.isArchived ?? false) {
      return;
    }

    _updatePrescription(
      dayId: dayId,
      exerciseId: exerciseId,
      transform: (prescription) => prescription.copyWith(
        restSeconds: _clampInt(
          restSeconds,
          0,
          ProgramExercisePrescription.maximumRestSeconds,
        ),
      ),
    );
  }

  Future<void> saveDraftSnapshot() async {
    final draft = state.draft;
    if (draft == null || draft.isArchived) {
      return;
    }

    final result = await ref
        .read(programDraftPersistenceProvider)
        .saveDraftSnapshot(draft);
    _markPersisted(result);
  }

  Future<void> publishImmutableVersion() async {
    final draft = state.draft;
    if (draft == null || draft.isArchived) {
      return;
    }

    final result = await ref
        .read(programDraftPersistenceProvider)
        .publishImmutableVersion(draft);
    _markPersisted(result);
  }

  Future<void> archiveProgram() async {
    final draft = state.draft;
    if (draft == null || !draft.isPersisted || draft.isArchived) {
      return;
    }

    final archivedAt = await ref
        .read(programDraftPersistenceProvider)
        .archiveProgram(draft);
    final current = state.draft;
    if (current == null) {
      return;
    }

    state = state.copyWith(
      draft: current.copyWith(
        lifecycle: ProgramDraftLifecycle.archived,
        lastPersistedAt: archivedAt,
      ),
    );
  }

  void copyDraft(String name) {
    final draft = state.draft;
    if (draft == null) {
      return;
    }

    state = state.copyWith(
      draft: draft.copyWith(
        name: _cleanName(name, fallback: '${draft.name} copy'),
        lifecycle: ProgramDraftLifecycle.local,
        clearProgramId: true,
        clearLatestVersionId: true,
        latestVersionNumber: 0,
        clearLastPersistedAt: true,
      ),
    );
  }

  void _updateDay(
    String dayId,
    ProgramTrainingDay Function(ProgramTrainingDay day) transform,
  ) {
    final draft = state.draft;
    if (draft == null || !_hasDay(draft, dayId)) {
      return;
    }

    state = state.copyWith(
      draft: draft.copyWith(
        trainingDays: [
          for (final day in draft.trainingDays)
            day.id == dayId ? transform(day) : day,
        ],
      ),
    );
  }

  void _markPersisted(ProgramDraftPersistenceResult result) {
    final draft = state.draft;
    if (draft == null) {
      return;
    }

    state = state.copyWith(
      draft: draft.copyWith(
        lifecycle: result.lifecycle,
        programId: result.programId,
        latestVersionId: result.versionId,
        latestVersionNumber: result.versionNumber,
        lastPersistedAt: result.persistedAt,
      ),
    );
  }

  void _updatePrescription({
    required String dayId,
    required String exerciseId,
    required ProgramExercisePrescription Function(
      ProgramExercisePrescription prescription,
    )
    transform,
  }) {
    _updateDay(
      dayId,
      (day) => day.copyWith(
        exercisePrescriptions: [
          for (final prescription in day.exercisePrescriptions)
            prescription.exerciseId == exerciseId
                ? transform(prescription)
                : prescription,
        ],
      ),
    );
  }
}

bool _hasDay(ProgramDraft draft, String dayId) {
  return draft.trainingDays.any((day) => day.id == dayId);
}

String _dayId(int number) => 'day_$number';

String _cleanName(String value, {required String fallback}) {
  final trimmed = value.trim();
  return trimmed.isEmpty ? fallback : trimmed;
}

int _clampInt(int value, int minimum, int maximum) {
  if (value < minimum) {
    return minimum;
  }
  if (value > maximum) {
    return maximum;
  }
  return value;
}

int _nextDayNumberAfter(ProgramDraft draft) {
  var highestDayNumber = 0;
  for (final day in draft.trainingDays) {
    final match = RegExp(r'^day_(\d+)$').firstMatch(day.id);
    final parsed = match == null ? null : int.tryParse(match.group(1)!);
    if (parsed != null && parsed > highestDayNumber) {
      highestDayNumber = parsed;
    }
  }

  return math.max(highestDayNumber + 1, draft.trainingDays.length + 1);
}
