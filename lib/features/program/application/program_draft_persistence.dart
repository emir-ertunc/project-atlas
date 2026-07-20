import 'dart:math' as math;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:project_atlas/core/repositories/repository_contracts.dart';
import 'package:project_atlas/core/repositories/repository_providers.dart';
import 'package:project_atlas/core/repositories/repository_records.dart';
import 'package:project_atlas/features/program/domain/program_builder.dart';

const localProgramProfileId = 'local_profile';

final localProgramProfileIdProvider = Provider<String>(
  (ref) => localProgramProfileId,
);

final programDraftPersistenceProvider =
    Provider<ProgramDraftPersistenceService>(
      (ref) => ProgramDraftPersistenceService(
        profileRepository: ref.watch(profileRepositoryProvider),
        programRepository: ref.watch(programRepositoryProvider),
        profileId: ref.watch(localProgramProfileIdProvider),
      ),
    );

final class ProgramDraftPersistenceResult {
  const ProgramDraftPersistenceResult({
    required this.programId,
    required this.versionId,
    required this.versionNumber,
    required this.lifecycle,
    required this.persistedAt,
  });

  final String programId;
  final String versionId;
  final int versionNumber;
  final ProgramDraftLifecycle lifecycle;
  final DateTime persistedAt;
}

final class ProgramDraftPersistenceService {
  ProgramDraftPersistenceService({
    required this._profileRepository,
    required this._programRepository,
    required this._profileId,
    DateTime Function()? now,
  }) : _now = now ?? DateTime.now;

  final ProfileRepository _profileRepository;
  final ProgramRepository _programRepository;
  final String _profileId;
  final DateTime Function() _now;

  var _idSerial = 0;

  Future<ProgramDraftPersistenceResult> saveDraftSnapshot(ProgramDraft draft) {
    return _saveSnapshot(
      draft: draft,
      programLifecycle: ProgramLifecycle.draft,
      versionLifecycle: ProgramVersionLifecycle.draft,
      draftLifecycle: ProgramDraftLifecycle.savedDraft,
      retireActiveVersions: false,
    );
  }

  Future<ProgramDraftPersistenceResult> publishImmutableVersion(
    ProgramDraft draft,
  ) {
    return _saveSnapshot(
      draft: draft,
      programLifecycle: ProgramLifecycle.active,
      versionLifecycle: ProgramVersionLifecycle.active,
      draftLifecycle: ProgramDraftLifecycle.published,
      retireActiveVersions: true,
    );
  }

  Future<DateTime> archiveProgram(ProgramDraft draft) async {
    final programId = draft.programId;
    if (programId == null) {
      throw StateError('Only persisted programs can be archived.');
    }

    final existingProgram = await _programRepository.getProgram(programId);
    if (existingProgram == null) {
      throw StateError('The program no longer exists in local storage.');
    }

    final archivedAt = _now().toUtc();
    await _programRepository.saveProgram(
      ProgramRecord(
        id: existingProgram.id,
        profileId: existingProgram.profileId,
        name: _cleanName(draft.name, fallback: existingProgram.name),
        lifecycle: ProgramLifecycle.archived,
        createdAt: existingProgram.createdAt,
        updatedAt: archivedAt,
        archivedAt: archivedAt,
      ),
    );
    return archivedAt;
  }

  Future<ProgramDraftPersistenceResult> _saveSnapshot({
    required ProgramDraft draft,
    required ProgramLifecycle programLifecycle,
    required ProgramVersionLifecycle versionLifecycle,
    required ProgramDraftLifecycle draftLifecycle,
    required bool retireActiveVersions,
  }) async {
    if (draft.trainingDays.isEmpty) {
      throw StateError(
        'A program snapshot requires at least one training day.',
      );
    }

    final now = _now().toUtc();
    await _ensureProfile(now);

    final programId = draft.programId ?? _nextId('program', now);
    final existingProgram = await _programRepository.getProgram(programId);
    final versionNumber = await _nextVersionNumber(programId);
    final versionId = _nextId('version', now);
    final program = ProgramRecord(
      id: programId,
      profileId: _profileId,
      name: _cleanName(draft.name, fallback: 'New program'),
      lifecycle: programLifecycle,
      createdAt: existingProgram?.createdAt ?? now,
      updatedAt: now,
    );
    final version = ProgramVersionRecord(
      id: versionId,
      programId: programId,
      versionNumber: versionNumber,
      lifecycle: versionLifecycle,
      label: versionLifecycle == ProgramVersionLifecycle.draft
          ? 'Draft v$versionNumber'
          : 'Version $versionNumber',
      createdAt: now,
      activatedAt: versionLifecycle == ProgramVersionLifecycle.active
          ? now
          : null,
    );
    final graph = _buildSnapshotGraph(
      draft: draft,
      versionId: versionId,
      createdAt: now,
    );

    await _programRepository.saveProgramSnapshot(
      program,
      version,
      graph.trainingDays,
      graph.prescription,
      retireActiveVersions: retireActiveVersions,
    );

    return ProgramDraftPersistenceResult(
      programId: programId,
      versionId: versionId,
      versionNumber: versionNumber,
      lifecycle: draftLifecycle,
      persistedAt: now,
    );
  }

  Future<void> _ensureProfile(DateTime now) async {
    final profile = await _profileRepository.getProfile(_profileId);
    if (profile != null) {
      return;
    }

    await _profileRepository.saveProfile(
      ProfileRecord(
        id: _profileId,
        unitPreference: UnitPreference.metric,
        createdAt: now,
        updatedAt: now,
      ),
    );
  }

  Future<int> _nextVersionNumber(String programId) async {
    final versions = await _programRepository.watchVersions(programId).first;
    if (versions.isEmpty) {
      return 1;
    }
    return versions.map((version) => version.versionNumber).reduce(math.max) +
        1;
  }

  _VersionGraph _buildSnapshotGraph({
    required ProgramDraft draft,
    required String versionId,
    required DateTime createdAt,
  }) {
    final trainingDays = <ProgramTrainingDayRecord>[];
    final prescription = <PrescribedSetRecord>[];

    for (final (dayIndex, day) in draft.trainingDays.indexed) {
      trainingDays.add(
        ProgramTrainingDayRecord(
          id: _nextId('pday', createdAt),
          programVersionId: versionId,
          trainingDayOrder: dayIndex,
          name: _cleanName(day.name, fallback: 'Day ${dayIndex + 1}'),
          createdAt: createdAt,
        ),
      );

      for (final (exerciseIndex, exercise)
          in day.exercisePrescriptions.indexed) {
        final setCount = _clampInt(
          exercise.setCount,
          ProgramExercisePrescription.minimumSetCount,
          ProgramExercisePrescription.maximumSetCount,
        );
        final minimumRepetitions = _clampInt(
          exercise.minimumRepetitions,
          ProgramExercisePrescription.minimumRepetitionsLimit,
          ProgramExercisePrescription.maximumRepetitionsLimit,
        );
        final maximumRepetitions = math.max(
          minimumRepetitions,
          _clampInt(
            exercise.maximumRepetitions,
            ProgramExercisePrescription.minimumRepetitionsLimit,
            ProgramExercisePrescription.maximumRepetitionsLimit,
          ),
        );
        final targetRir = exercise.targetRir == null
            ? null
            : _clampInt(
                exercise.targetRir!,
                ProgramExercisePrescription.minimumRir,
                ProgramExercisePrescription.maximumRir,
              );
        final loadKilograms = exercise.loadKilograms == null
            ? null
            : math.max(0.0, exercise.loadKilograms!);
        final restSeconds = _clampInt(
          exercise.restSeconds,
          0,
          ProgramExercisePrescription.maximumRestSeconds,
        );

        for (var setIndex = 0; setIndex < setCount; setIndex += 1) {
          prescription.add(
            PrescribedSetRecord(
              id: _nextId('pset', createdAt),
              programVersionId: versionId,
              trainingDayOrder: dayIndex,
              exerciseId: exercise.exerciseId,
              exerciseOrder: exerciseIndex,
              setOrder: setIndex,
              minimumRepetitions: minimumRepetitions,
              maximumRepetitions: maximumRepetitions,
              targetRir: targetRir,
              loadKilograms: loadKilograms,
              restSeconds: restSeconds,
              progressionStrategy: ProgressionStrategy.manual,
              createdAt: createdAt,
            ),
          );
        }
      }
    }

    return _VersionGraph(
      trainingDays: trainingDays,
      prescription: prescription,
    );
  }

  String _nextId(String prefix, DateTime now) {
    _idSerial += 1;
    return '${prefix}_${now.microsecondsSinceEpoch.toRadixString(36)}_'
        '${_idSerial.toRadixString(36)}';
  }
}

final class _VersionGraph {
  const _VersionGraph({required this.trainingDays, required this.prescription});

  final List<ProgramTrainingDayRecord> trainingDays;
  final List<PrescribedSetRecord> prescription;
}

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
