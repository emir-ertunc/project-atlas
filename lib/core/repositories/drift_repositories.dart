import 'package:drift/drift.dart';
import 'package:project_atlas/core/database/app_database.dart';
import 'package:project_atlas/core/database/tables/actual_set_logs.dart';
import 'package:project_atlas/core/database/tables/measurement_records.dart';
import 'package:project_atlas/core/database/tables/prescribed_sets.dart';
import 'package:project_atlas/core/database/tables/profiles.dart';
import 'package:project_atlas/core/database/tables/program_versions.dart';
import 'package:project_atlas/core/database/tables/programs.dart';
import 'package:project_atlas/core/database/tables/session_sets.dart';
import 'package:project_atlas/core/database/tables/workout_sessions.dart';
import 'package:project_atlas/core/repositories/repository_contracts.dart';
import 'package:project_atlas/core/repositories/repository_records.dart';

final class DriftProfileRepository implements ProfileRepository {
  DriftProfileRepository(this._database);

  final AppDatabase _database;

  @override
  Stream<ProfileRecord?> watchProfile(String profileId) {
    final query = _database.select(_database.profiles)
      ..where((row) => row.id.equals(profileId));
    return query.watchSingleOrNull().map(
      (row) => row == null ? null : _profileFromRow(row),
    );
  }

  @override
  Future<ProfileRecord?> getProfile(String profileId) async {
    final query = _database.select(_database.profiles)
      ..where((row) => row.id.equals(profileId));
    final row = await query.getSingleOrNull();
    return row == null ? null : _profileFromRow(row);
  }

  @override
  Future<void> saveProfile(ProfileRecord profile) async {
    await _database
        .into(_database.profiles)
        .insertOnConflictUpdate(
          ProfilesCompanion.insert(
            id: profile.id,
            displayName: Value(profile.displayName),
            preferredLocale: Value(profile.preferredLocale),
            unitSystem: _enumByName(
              UnitSystemPreference.values,
              profile.unitPreference,
            ),
            createdAt: Value(_asUtc(profile.createdAt)),
            updatedAt: Value(_asUtc(profile.updatedAt)),
          ),
        );
  }
}

final class DriftProgramRepository implements ProgramRepository {
  DriftProgramRepository(this._database);

  final AppDatabase _database;

  @override
  Stream<List<ProgramRecord>> watchPrograms(String profileId) {
    final query = _database.select(_database.programs)
      ..where((row) => row.profileId.equals(profileId))
      ..orderBy([(row) => OrderingTerm.desc(row.updatedAt)]);
    return query.watch().map(
      (rows) => rows.map(_programFromRow).toList(growable: false),
    );
  }

  @override
  Future<ProgramRecord?> getProgram(String programId) async {
    final query = _database.select(_database.programs)
      ..where((row) => row.id.equals(programId));
    final row = await query.getSingleOrNull();
    return row == null ? null : _programFromRow(row);
  }

  @override
  Stream<List<ProgramVersionRecord>> watchVersions(String programId) {
    final query = _database.select(_database.programVersions)
      ..where((row) => row.programId.equals(programId))
      ..orderBy([(row) => OrderingTerm.desc(row.versionNumber)]);
    return query.watch().map(
      (rows) => rows.map(_programVersionFromRow).toList(growable: false),
    );
  }

  @override
  Stream<List<PrescribedSetRecord>> watchPrescription(String versionId) {
    final query = _database.select(_database.prescribedSets)
      ..where((row) => row.programVersionId.equals(versionId))
      ..orderBy([
        (row) => OrderingTerm.asc(row.trainingDayOrder),
        (row) => OrderingTerm.asc(row.exerciseOrder),
        (row) => OrderingTerm.asc(row.setOrder),
      ]);
    return query.watch().map(
      (rows) => rows.map(_prescribedSetFromRow).toList(growable: false),
    );
  }

  @override
  Future<void> saveProgram(ProgramRecord program) async {
    await _database
        .into(_database.programs)
        .insertOnConflictUpdate(
          ProgramsCompanion.insert(
            id: program.id,
            profileId: program.profileId,
            name: program.name,
            status: _enumByName(ProgramStatus.values, program.lifecycle),
            createdAt: Value(_asUtc(program.createdAt)),
            updatedAt: Value(_asUtc(program.updatedAt)),
            archivedAt: Value(_nullableUtc(program.archivedAt)),
          ),
        );
  }

  @override
  Future<void> addVersion(
    ProgramVersionRecord version,
    List<PrescribedSetRecord> prescription,
  ) async {
    if (prescription.any((set) => set.programVersionId != version.id)) {
      throw ArgumentError.value(
        prescription,
        'prescription',
        'Every set must belong to the version being added.',
      );
    }

    await _database.transaction(() async {
      await _database
          .into(_database.programVersions)
          .insert(
            ProgramVersionsCompanion.insert(
              id: version.id,
              programId: version.programId,
              versionNumber: version.versionNumber,
              status: _enumByName(
                ProgramVersionStatus.values,
                version.lifecycle,
              ),
              label: Value(version.label),
              createdAt: Value(_asUtc(version.createdAt)),
              activatedAt: Value(_nullableUtc(version.activatedAt)),
            ),
          );
      await _database.batch((batch) {
        batch.insertAll(
          _database.prescribedSets,
          prescription.map(_prescribedSetCompanion).toList(growable: false),
        );
      });
    });
  }
}

final class DriftWorkoutRepository implements WorkoutRepository {
  DriftWorkoutRepository(this._database);

  final AppDatabase _database;

  @override
  Stream<List<WorkoutSessionRecord>> watchSessions(String profileId) {
    final query = _database.select(_database.workoutSessions)
      ..where((row) => row.profileId.equals(profileId))
      ..orderBy([
        (row) => OrderingTerm.desc(row.scheduledAt),
        (row) => OrderingTerm.desc(row.createdAt),
      ]);
    return query.watch().map(
      (rows) => rows.map(_workoutSessionFromRow).toList(growable: false),
    );
  }

  @override
  Stream<List<SessionSetRecord>> watchSessionSets(String sessionId) {
    final query = _database.select(_database.sessionSets)
      ..where((row) => row.sessionId.equals(sessionId))
      ..orderBy([
        (row) => OrderingTerm.asc(row.exerciseOrder),
        (row) => OrderingTerm.asc(row.setOrder),
      ]);
    return query.watch().map(
      (rows) => rows.map(_sessionSetFromRow).toList(growable: false),
    );
  }

  @override
  Stream<List<ActualSetLogRecord>> watchActualSetLogs(String sessionSetId) {
    final query = _database.select(_database.actualSetLogs)
      ..where((row) => row.sessionSetId.equals(sessionSetId))
      ..orderBy([(row) => OrderingTerm.asc(row.revision)]);
    return query.watch().map(
      (rows) => rows.map(_actualSetLogFromRow).toList(growable: false),
    );
  }

  @override
  Future<void> saveSessionPlan(
    WorkoutSessionRecord session,
    List<SessionSetRecord> sets,
  ) async {
    if (sets.any((set) => set.sessionId != session.id)) {
      throw ArgumentError.value(
        sets,
        'sets',
        'Every set must belong to the session being saved.',
      );
    }

    await _database.transaction(() async {
      await _database
          .into(_database.workoutSessions)
          .insertOnConflictUpdate(
            WorkoutSessionsCompanion.insert(
              id: session.id,
              profileId: session.profileId,
              programId: Value(session.programId),
              programVersionId: Value(session.programVersionId),
              status: _enumByName(
                WorkoutSessionStatus.values,
                session.lifecycle,
              ),
              scheduledAt: Value(_nullableUtc(session.scheduledAt)),
              startedAt: Value(_nullableUtc(session.startedAt)),
              endedAt: Value(_nullableUtc(session.endedAt)),
              notes: Value(session.notes),
              createdAt: Value(_asUtc(session.createdAt)),
              updatedAt: Value(_asUtc(session.updatedAt)),
            ),
          );
      await _database.batch((batch) {
        batch.insertAllOnConflictUpdate(
          _database.sessionSets,
          sets.map(_sessionSetCompanion).toList(growable: false),
        );
      });
    });
  }

  @override
  Future<void> appendActualSetLog(ActualSetLogRecord log) async {
    await _database
        .into(_database.actualSetLogs)
        .insert(
          ActualSetLogsCompanion.insert(
            id: log.id,
            sessionSetId: log.sessionSetId,
            revision: log.revision,
            repetitions: Value(log.repetitions),
            loadKilograms: Value(log.loadKilograms),
            rir: Value(log.rir),
            outcome: Value(
              log.result == null
                  ? null
                  : _enumByName(SetOutcome.values, log.result!),
            ),
            notes: Value(log.notes),
            supersedesLogId: Value(log.supersedesLogId),
            recordedAt: Value(_asUtc(log.recordedAt)),
          ),
        );
  }
}

final class DriftMeasurementRepository implements MeasurementRepository {
  DriftMeasurementRepository(this._database);

  final AppDatabase _database;

  @override
  Stream<List<MeasurementRecord>> watchMeasurements(String profileId) {
    final query = _database.select(_database.measurementRecords)
      ..where((row) => row.profileId.equals(profileId))
      ..orderBy([(row) => OrderingTerm.desc(row.measuredAt)]);
    return query.watch().map(
      (rows) => rows.map(_measurementFromRow).toList(growable: false),
    );
  }

  @override
  Future<void> addMeasurement(MeasurementRecord measurement) async {
    await _database
        .into(_database.measurementRecords)
        .insert(
          MeasurementRecordsCompanion.insert(
            id: measurement.id,
            profileId: measurement.profileId,
            measuredAt: _asUtc(measurement.measuredAt),
            source: _enumByName(MeasurementSource.values, measurement.origin),
            notes: Value(measurement.notes),
            createdAt: Value(_asUtc(measurement.createdAt)),
          ),
        );
  }
}

ProfileRecord _profileFromRow(ProfileRow row) => ProfileRecord(
  id: row.id,
  displayName: row.displayName,
  preferredLocale: row.preferredLocale,
  unitPreference: _enumByName(UnitPreference.values, row.unitSystem),
  createdAt: _asUtc(row.createdAt),
  updatedAt: _asUtc(row.updatedAt),
);

ProgramRecord _programFromRow(ProgramRow row) => ProgramRecord(
  id: row.id,
  profileId: row.profileId,
  name: row.name,
  lifecycle: _enumByName(ProgramLifecycle.values, row.status),
  createdAt: _asUtc(row.createdAt),
  updatedAt: _asUtc(row.updatedAt),
  archivedAt: _nullableUtc(row.archivedAt),
);

ProgramVersionRecord _programVersionFromRow(ProgramVersionRow row) =>
    ProgramVersionRecord(
      id: row.id,
      programId: row.programId,
      versionNumber: row.versionNumber,
      lifecycle: _enumByName(ProgramVersionLifecycle.values, row.status),
      label: row.label,
      createdAt: _asUtc(row.createdAt),
      activatedAt: _nullableUtc(row.activatedAt),
    );

PrescribedSetRecord _prescribedSetFromRow(PrescribedSetRow row) =>
    PrescribedSetRecord(
      id: row.id,
      programVersionId: row.programVersionId,
      trainingDayOrder: row.trainingDayOrder,
      exerciseId: row.exerciseId,
      exerciseOrder: row.exerciseOrder,
      setOrder: row.setOrder,
      minimumRepetitions: row.minimumRepetitions,
      maximumRepetitions: row.maximumRepetitions,
      targetRir: row.targetRir,
      loadKilograms: row.loadKilograms,
      restSeconds: row.restSeconds,
      progressionStrategy: _enumByName(
        ProgressionStrategy.values,
        row.progressionMode,
      ),
      createdAt: _asUtc(row.createdAt),
    );

PrescribedSetsCompanion _prescribedSetCompanion(PrescribedSetRecord set) =>
    PrescribedSetsCompanion.insert(
      id: set.id,
      programVersionId: set.programVersionId,
      trainingDayOrder: set.trainingDayOrder,
      exerciseId: set.exerciseId,
      exerciseOrder: set.exerciseOrder,
      setOrder: set.setOrder,
      minimumRepetitions: set.minimumRepetitions,
      maximumRepetitions: set.maximumRepetitions,
      targetRir: Value(set.targetRir),
      loadKilograms: Value(set.loadKilograms),
      restSeconds: set.restSeconds,
      progressionMode: _enumByName(
        ProgressionMode.values,
        set.progressionStrategy,
      ),
      createdAt: Value(_asUtc(set.createdAt)),
    );

WorkoutSessionRecord _workoutSessionFromRow(WorkoutSessionRow row) =>
    WorkoutSessionRecord(
      id: row.id,
      profileId: row.profileId,
      programId: row.programId,
      programVersionId: row.programVersionId,
      lifecycle: _enumByName(WorkoutLifecycle.values, row.status),
      scheduledAt: _nullableUtc(row.scheduledAt),
      startedAt: _nullableUtc(row.startedAt),
      endedAt: _nullableUtc(row.endedAt),
      notes: row.notes,
      createdAt: _asUtc(row.createdAt),
      updatedAt: _asUtc(row.updatedAt),
    );

SessionSetRecord _sessionSetFromRow(SessionSetRow row) => SessionSetRecord(
  id: row.id,
  sessionId: row.sessionId,
  prescribedSetId: row.prescribedSetId,
  exerciseId: row.exerciseId,
  exerciseOrder: row.exerciseOrder,
  setOrder: row.setOrder,
  lifecycle: _enumByName(SetLifecycle.values, row.status),
  createdAt: _asUtc(row.createdAt),
  updatedAt: _asUtc(row.updatedAt),
);

SessionSetsCompanion _sessionSetCompanion(SessionSetRecord set) =>
    SessionSetsCompanion.insert(
      id: set.id,
      sessionId: set.sessionId,
      prescribedSetId: Value(set.prescribedSetId),
      exerciseId: set.exerciseId,
      exerciseOrder: set.exerciseOrder,
      setOrder: set.setOrder,
      status: _enumByName(SessionSetStatus.values, set.lifecycle),
      createdAt: Value(_asUtc(set.createdAt)),
      updatedAt: Value(_asUtc(set.updatedAt)),
    );

ActualSetLogRecord _actualSetLogFromRow(ActualSetLogRow row) =>
    ActualSetLogRecord(
      id: row.id,
      sessionSetId: row.sessionSetId,
      revision: row.revision,
      repetitions: row.repetitions,
      loadKilograms: row.loadKilograms,
      rir: row.rir,
      result: row.outcome == null
          ? null
          : _enumByName(SetResult.values, row.outcome!),
      notes: row.notes,
      supersedesLogId: row.supersedesLogId,
      recordedAt: _asUtc(row.recordedAt),
    );

MeasurementRecord _measurementFromRow(MeasurementRecordRow row) =>
    MeasurementRecord(
      id: row.id,
      profileId: row.profileId,
      measuredAt: _asUtc(row.measuredAt),
      origin: _enumByName(MeasurementOrigin.values, row.source),
      notes: row.notes,
      createdAt: _asUtc(row.createdAt),
    );

T _enumByName<T extends Enum>(List<T> values, Enum source) =>
    values.firstWhere((value) => value.name == source.name);

DateTime _asUtc(DateTime value) => value.toUtc();

DateTime? _nullableUtc(DateTime? value) => value?.toUtc();
