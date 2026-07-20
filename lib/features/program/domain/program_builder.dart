class ProgramBuilderState {
  const ProgramBuilderState({required this.draft, required this.nextDayNumber});

  const ProgramBuilderState.initial() : draft = null, nextDayNumber = 1;

  final ProgramDraft? draft;
  final int nextDayNumber;

  bool get hasDraft => draft != null;

  ProgramBuilderState copyWith({
    ProgramDraft? draft,
    bool clearDraft = false,
    int? nextDayNumber,
  }) {
    return ProgramBuilderState(
      draft: clearDraft ? null : draft ?? this.draft,
      nextDayNumber: nextDayNumber ?? this.nextDayNumber,
    );
  }
}

class ProgramDraft {
  const ProgramDraft({
    required this.name,
    required this.trainingDays,
    required this.selectedDayId,
    this.lifecycle = ProgramDraftLifecycle.local,
    this.programId,
    this.latestVersionId,
    this.latestVersionNumber = 0,
    this.lastPersistedAt,
  });

  final String name;
  final List<ProgramTrainingDay> trainingDays;
  final String selectedDayId;
  final ProgramDraftLifecycle lifecycle;
  final String? programId;
  final String? latestVersionId;
  final int latestVersionNumber;
  final DateTime? lastPersistedAt;

  bool get isPersisted => programId != null;

  bool get isArchived => lifecycle == ProgramDraftLifecycle.archived;

  ProgramTrainingDay? get selectedDay {
    for (final day in trainingDays) {
      if (day.id == selectedDayId) {
        return day;
      }
    }
    return trainingDays.isEmpty ? null : trainingDays.first;
  }

  int get exerciseCount =>
      trainingDays.fold(0, (total, day) => total + day.exerciseIds.length);

  int get setCount => trainingDays.fold(
    0,
    (total, day) =>
        total +
        day.exercisePrescriptions.fold(
          0,
          (dayTotal, prescription) => dayTotal + prescription.setCount,
        ),
  );

  ProgramDraft copyWith({
    String? name,
    List<ProgramTrainingDay>? trainingDays,
    String? selectedDayId,
    ProgramDraftLifecycle? lifecycle,
    String? programId,
    bool clearProgramId = false,
    String? latestVersionId,
    bool clearLatestVersionId = false,
    int? latestVersionNumber,
    DateTime? lastPersistedAt,
    bool clearLastPersistedAt = false,
  }) {
    return ProgramDraft(
      name: name ?? this.name,
      trainingDays: List.unmodifiable(trainingDays ?? this.trainingDays),
      selectedDayId: selectedDayId ?? this.selectedDayId,
      lifecycle: lifecycle ?? this.lifecycle,
      programId: clearProgramId ? null : programId ?? this.programId,
      latestVersionId: clearLatestVersionId
          ? null
          : latestVersionId ?? this.latestVersionId,
      latestVersionNumber: latestVersionNumber ?? this.latestVersionNumber,
      lastPersistedAt: clearLastPersistedAt
          ? null
          : lastPersistedAt ?? this.lastPersistedAt,
    );
  }
}

enum ProgramDraftLifecycle { local, savedDraft, published, archived }

class ProgramTrainingDay {
  const ProgramTrainingDay({
    required this.id,
    required this.name,
    required this.exercisePrescriptions,
  });

  final String id;
  final String name;
  final List<ProgramExercisePrescription> exercisePrescriptions;

  List<String> get exerciseIds => [
    for (final prescription in exercisePrescriptions) prescription.exerciseId,
  ];

  ProgramExercisePrescription? prescriptionFor(String exerciseId) {
    for (final prescription in exercisePrescriptions) {
      if (prescription.exerciseId == exerciseId) {
        return prescription;
      }
    }
    return null;
  }

  ProgramTrainingDay copyWith({
    String? name,
    List<ProgramExercisePrescription>? exercisePrescriptions,
  }) {
    return ProgramTrainingDay(
      id: id,
      name: name ?? this.name,
      exercisePrescriptions: List.unmodifiable(
        exercisePrescriptions ?? this.exercisePrescriptions,
      ),
    );
  }
}

enum ProgramRepetitionMode { fixed, range }

class ProgramExercisePrescription {
  const ProgramExercisePrescription({
    required this.exerciseId,
    required this.setCount,
    required this.minimumRepetitions,
    required this.maximumRepetitions,
    required this.targetRir,
    required this.loadKilograms,
    required this.restSeconds,
  });

  factory ProgramExercisePrescription.defaults(String exerciseId) {
    return ProgramExercisePrescription(
      exerciseId: exerciseId,
      setCount: defaultSetCount,
      minimumRepetitions: defaultMinimumRepetitions,
      maximumRepetitions: defaultMaximumRepetitions,
      targetRir: defaultTargetRir,
      loadKilograms: null,
      restSeconds: defaultRestSeconds,
    );
  }

  static const defaultSetCount = 3;
  static const minimumSetCount = 1;
  static const maximumSetCount = 20;
  static const defaultMinimumRepetitions = 8;
  static const defaultMaximumRepetitions = 10;
  static const minimumRepetitionsLimit = 1;
  static const maximumRepetitionsLimit = 100;
  static const defaultTargetRir = 2;
  static const minimumRir = 0;
  static const maximumRir = 10;
  static const defaultRestSeconds = 120;
  static const maximumRestSeconds = 1200;

  final String exerciseId;
  final int setCount;
  final int minimumRepetitions;
  final int maximumRepetitions;
  final int? targetRir;
  final double? loadKilograms;
  final int restSeconds;

  ProgramRepetitionMode get repetitionMode =>
      minimumRepetitions == maximumRepetitions
      ? ProgramRepetitionMode.fixed
      : ProgramRepetitionMode.range;

  bool get hasTargetRir => targetRir != null;

  ProgramExercisePrescription copyWith({
    int? setCount,
    int? minimumRepetitions,
    int? maximumRepetitions,
    int? targetRir,
    bool clearTargetRir = false,
    double? loadKilograms,
    bool clearLoadKilograms = false,
    int? restSeconds,
  }) {
    final nextMinimumRepetitions =
        minimumRepetitions ?? this.minimumRepetitions;
    final nextMaximumRepetitions =
        maximumRepetitions ?? this.maximumRepetitions;

    return ProgramExercisePrescription(
      exerciseId: exerciseId,
      setCount: setCount ?? this.setCount,
      minimumRepetitions: nextMinimumRepetitions,
      maximumRepetitions: nextMaximumRepetitions < nextMinimumRepetitions
          ? nextMinimumRepetitions
          : nextMaximumRepetitions,
      targetRir: clearTargetRir ? null : targetRir ?? this.targetRir,
      loadKilograms: clearLoadKilograms
          ? null
          : loadKilograms ?? this.loadKilograms,
      restSeconds: restSeconds ?? this.restSeconds,
    );
  }
}
