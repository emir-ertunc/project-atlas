import 'package:drift/drift.dart';
import 'package:project_atlas/core/database/app_database.dart';
import 'package:project_atlas/core/database/tables/actual_set_logs.dart';
import 'package:project_atlas/core/database/tables/availability_windows.dart';
import 'package:project_atlas/core/database/tables/measurement_records.dart';
import 'package:project_atlas/core/database/tables/onboarding_preferences.dart';
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

final class DriftOnboardingRepository implements OnboardingRepository {
  DriftOnboardingRepository(this._database);

  final AppDatabase _database;

  @override
  Stream<OnboardingPreferencesRecord?> watchPreferences(String profileId) {
    final query = _database.select(_database.onboardingPreferences)
      ..where((row) => row.profileId.equals(profileId));
    return query.watchSingleOrNull().map(
      (row) => row == null ? null : _onboardingPreferencesFromRow(row),
    );
  }

  @override
  Future<OnboardingPreferencesRecord?> getPreferences(String profileId) async {
    final query = _database.select(_database.onboardingPreferences)
      ..where((row) => row.profileId.equals(profileId));
    final row = await query.getSingleOrNull();
    return row == null ? null : _onboardingPreferencesFromRow(row);
  }

  @override
  Future<void> savePreferences(OnboardingPreferencesRecord preferences) async {
    _validateOnboardingPreferences(preferences);
    await _database
        .into(_database.onboardingPreferences)
        .insertOnConflictUpdate(_onboardingPreferencesCompanion(preferences));
  }
}

final class DriftAvailabilityRepository implements AvailabilityRepository {
  DriftAvailabilityRepository(this._database);

  final AppDatabase _database;

  @override
  Stream<List<AvailabilityWindowRecord>> watchWindows(String profileId) {
    return _availabilityWindowsQuery(profileId).watch().map(
      (rows) => _sortAvailabilityWindows(
        rows.map(_availabilityWindowFromRow).toList(growable: false),
      ),
    );
  }

  @override
  Future<List<AvailabilityWindowRecord>> getWindows(String profileId) async {
    final rows = await _availabilityWindowsQuery(profileId).get();
    return _sortAvailabilityWindows(
      rows.map(_availabilityWindowFromRow).toList(growable: false),
    );
  }

  @override
  Future<void> replaceWindows(
    String profileId,
    List<AvailabilityWindowRecord> windows,
  ) async {
    _validateAvailabilityWindows(profileId, windows);
    await _database.transaction(() async {
      await (_database.delete(
        _database.availabilityWindows,
      )..where((row) => row.profileId.equals(profileId))).go();
      if (windows.isEmpty) {
        return;
      }
      await _database.batch((batch) {
        batch.insertAll(
          _database.availabilityWindows,
          windows.map(_availabilityWindowCompanion).toList(growable: false),
        );
      });
    });
  }

  SimpleSelectStatement<$AvailabilityWindowsTable, AvailabilityWindowRow>
  _availabilityWindowsQuery(String profileId) {
    return _database.select(_database.availabilityWindows)
      ..where((row) => row.profileId.equals(profileId))
      ..orderBy([
        (row) => OrderingTerm.asc(row.startMinute),
        (row) => OrderingTerm.asc(row.windowType),
      ]);
  }
}

final class DriftProgramRepository implements ProgramRepository {
  DriftProgramRepository(this._database);

  final AppDatabase _database;

  @override
  Stream<List<ProgramRecord>> watchPrograms(String profileId) {
    return _programsQuery(
      profileId,
    ).watch().map((rows) => rows.map(_programFromRow).toList(growable: false));
  }

  @override
  Future<List<ProgramRecord>> getPrograms(String profileId) async {
    final rows = await _programsQuery(profileId).get();
    return rows.map(_programFromRow).toList(growable: false);
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
    return _versionsQuery(programId).watch().map(
      (rows) => rows.map(_programVersionFromRow).toList(growable: false),
    );
  }

  @override
  Future<List<ProgramVersionRecord>> getVersions(String programId) async {
    final rows = await _versionsQuery(programId).get();
    return rows.map(_programVersionFromRow).toList(growable: false);
  }

  @override
  Stream<List<ProgramTrainingDayRecord>> watchTrainingDays(String versionId) {
    return _trainingDaysQuery(versionId).watch().map(
      (rows) => rows.map(_programTrainingDayFromRow).toList(growable: false),
    );
  }

  @override
  Future<List<ProgramTrainingDayRecord>> getTrainingDays(
    String versionId,
  ) async {
    final rows = await _trainingDaysQuery(versionId).get();
    return rows.map(_programTrainingDayFromRow).toList(growable: false);
  }

  @override
  Stream<List<PrescribedSetRecord>> watchPrescription(String versionId) {
    return _prescriptionQuery(versionId).watch().map(
      (rows) => rows.map(_prescribedSetFromRow).toList(growable: false),
    );
  }

  @override
  Future<List<PrescribedSetRecord>> getPrescription(String versionId) async {
    final rows = await _prescriptionQuery(versionId).get();
    return rows.map(_prescribedSetFromRow).toList(growable: false);
  }

  @override
  Future<void> saveProgram(ProgramRecord program) async {
    await _database
        .into(_database.programs)
        .insertOnConflictUpdate(_programCompanion(program));
  }

  @override
  Future<void> saveProgramSnapshot(
    ProgramRecord program,
    ProgramVersionRecord version,
    List<ProgramTrainingDayRecord> trainingDays,
    List<PrescribedSetRecord> prescription, {
    bool retireActiveVersions = false,
  }) async {
    _validateVersionGraph(version, trainingDays, prescription);

    await _database.transaction(() async {
      await _database
          .into(_database.programs)
          .insertOnConflictUpdate(_programCompanion(program));
      if (retireActiveVersions) {
        await (_database.update(_database.programVersions)..where(
              (row) =>
                  row.programId.equals(version.programId) &
                  row.status.equals(ProgramVersionStatus.active.name),
            ))
            .write(
              const ProgramVersionsCompanion(
                status: Value(ProgramVersionStatus.retired),
              ),
            );
      }
      await _insertVersionGraph(version, trainingDays, prescription);
    });
  }

  @override
  Future<void> addVersion(
    ProgramVersionRecord version,
    List<ProgramTrainingDayRecord> trainingDays,
    List<PrescribedSetRecord> prescription,
  ) async {
    _validateVersionGraph(version, trainingDays, prescription);

    await _database.transaction(() async {
      await _insertVersionGraph(version, trainingDays, prescription);
    });
  }

  void _validateVersionGraph(
    ProgramVersionRecord version,
    List<ProgramTrainingDayRecord> trainingDays,
    List<PrescribedSetRecord> prescription,
  ) {
    if (trainingDays.any((day) => day.programVersionId != version.id)) {
      throw ArgumentError.value(
        trainingDays,
        'trainingDays',
        'Every training day must belong to the version being added.',
      );
    }
    if (prescription.any((set) => set.programVersionId != version.id)) {
      throw ArgumentError.value(
        prescription,
        'prescription',
        'Every set must belong to the version being added.',
      );
    }
  }

  Future<void> _insertVersionGraph(
    ProgramVersionRecord version,
    List<ProgramTrainingDayRecord> trainingDays,
    List<PrescribedSetRecord> prescription,
  ) async {
    await _database
        .into(_database.programVersions)
        .insert(
          ProgramVersionsCompanion.insert(
            id: version.id,
            programId: version.programId,
            versionNumber: version.versionNumber,
            status: _enumByName(ProgramVersionStatus.values, version.lifecycle),
            label: Value(version.label),
            createdAt: Value(_asUtc(version.createdAt)),
            activatedAt: Value(_nullableUtc(version.activatedAt)),
          ),
        );
    if (trainingDays.isNotEmpty) {
      await _database.batch((batch) {
        batch.insertAll(
          _database.programVersionTrainingDays,
          trainingDays
              .map(_programTrainingDayCompanion)
              .toList(growable: false),
        );
      });
    }
    if (prescription.isNotEmpty) {
      await _database.batch((batch) {
        batch.insertAll(
          _database.prescribedSets,
          prescription.map(_prescribedSetCompanion).toList(growable: false),
        );
      });
    }
  }

  SimpleSelectStatement<$ProgramsTable, ProgramRow> _programsQuery(
    String profileId,
  ) {
    return _database.select(_database.programs)
      ..where((row) => row.profileId.equals(profileId))
      ..orderBy([(row) => OrderingTerm.desc(row.updatedAt)]);
  }

  SimpleSelectStatement<$ProgramVersionsTable, ProgramVersionRow>
  _versionsQuery(String programId) {
    return _database.select(_database.programVersions)
      ..where((row) => row.programId.equals(programId))
      ..orderBy([(row) => OrderingTerm.desc(row.versionNumber)]);
  }

  SimpleSelectStatement<
    $ProgramVersionTrainingDaysTable,
    ProgramVersionTrainingDayRow
  >
  _trainingDaysQuery(String versionId) {
    return _database.select(_database.programVersionTrainingDays)
      ..where((row) => row.programVersionId.equals(versionId))
      ..orderBy([(row) => OrderingTerm.asc(row.trainingDayOrder)]);
  }

  SimpleSelectStatement<$PrescribedSetsTable, PrescribedSetRow>
  _prescriptionQuery(String versionId) {
    return _database.select(_database.prescribedSets)
      ..where((row) => row.programVersionId.equals(versionId))
      ..orderBy([
        (row) => OrderingTerm.asc(row.trainingDayOrder),
        (row) => OrderingTerm.asc(row.exerciseOrder),
        (row) => OrderingTerm.asc(row.setOrder),
      ]);
  }
}

final class DriftWorkoutRepository implements WorkoutRepository {
  DriftWorkoutRepository(this._database);

  final AppDatabase _database;

  @override
  Stream<List<WorkoutSessionRecord>> watchSessions(String profileId) {
    return _sessionsQuery(profileId).watch().map(
      (rows) => rows.map(_workoutSessionFromRow).toList(growable: false),
    );
  }

  @override
  Future<List<WorkoutSessionRecord>> getSessions(String profileId) async {
    final rows = await _sessionsQuery(profileId).get();
    return rows.map(_workoutSessionFromRow).toList(growable: false);
  }

  @override
  Stream<List<SessionSetRecord>> watchSessionSets(String sessionId) {
    return _sessionSetsQuery(sessionId).watch().map(
      (rows) => rows.map(_sessionSetFromRow).toList(growable: false),
    );
  }

  @override
  Future<List<SessionSetRecord>> getSessionSets(String sessionId) async {
    final rows = await _sessionSetsQuery(sessionId).get();
    return rows.map(_sessionSetFromRow).toList(growable: false);
  }

  @override
  Stream<List<ActualSetLogRecord>> watchActualSetLogs(String sessionSetId) {
    return _actualSetLogsQuery(sessionSetId).watch().map(
      (rows) => rows.map(_actualSetLogFromRow).toList(growable: false),
    );
  }

  @override
  Future<List<ActualSetLogRecord>> getActualSetLogs(String sessionSetId) async {
    final rows = await _actualSetLogsQuery(sessionSetId).get();
    return rows.map(_actualSetLogFromRow).toList(growable: false);
  }

  @override
  Future<List<ExerciseSetPerformanceRecord>> getExercisePerformanceHistory({
    required String profileId,
    required String exerciseId,
    String? excludedSessionId,
    int limit = 50,
  }) async {
    if (limit <= 0) {
      return const [];
    }

    final sessions = await getSessions(profileId);
    final history = <ExerciseSetPerformanceRecord>[];
    for (final session in sessions) {
      if (session.id == excludedSessionId) {
        continue;
      }

      final sets = await getSessionSets(session.id);
      for (final set in sets) {
        if (set.exerciseId != exerciseId) {
          continue;
        }

        final latestLog = _latestActualSetLog(await getActualSetLogs(set.id));
        if (latestLog == null) {
          continue;
        }

        history.add(
          ExerciseSetPerformanceRecord(
            sessionId: session.id,
            sessionSetId: set.id,
            exerciseId: set.exerciseId,
            setOrder: set.setOrder,
            sessionLifecycle: session.lifecycle,
            sessionCreatedAt: session.createdAt,
            sessionScheduledAt: session.scheduledAt,
            sessionStartedAt: session.startedAt,
            log: latestLog,
          ),
        );
      }
    }

    history.sort(_comparePerformanceDescending);
    return List.unmodifiable(history.take(limit));
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
  Future<void> completeSessionSet(
    SessionSetRecord completedSet,
    ActualSetLogRecord log,
  ) async {
    if (completedSet.id != log.sessionSetId) {
      throw ArgumentError.value(
        log,
        'log',
        'The actual set log must belong to the completed session set.',
      );
    }
    if (completedSet.lifecycle != SetLifecycle.completed) {
      throw ArgumentError.value(
        completedSet,
        'completedSet',
        'The session set must be marked completed before it is saved.',
      );
    }

    await _database.transaction(() async {
      final updatedRows =
          await (_database.update(
            _database.sessionSets,
          )..where((row) => row.id.equals(completedSet.id))).write(
            SessionSetsCompanion(
              status: Value(
                _enumByName(SessionSetStatus.values, completedSet.lifecycle),
              ),
              updatedAt: Value(_asUtc(completedSet.updatedAt)),
            ),
          );
      if (updatedRows != 1) {
        throw StateError('Session set ${completedSet.id} was not found.');
      }

      await _insertActualSetLog(log);
    });
  }

  @override
  Future<void> appendActualSetLog(ActualSetLogRecord log) async {
    await _insertActualSetLog(log);
  }

  Future<void> _insertActualSetLog(ActualSetLogRecord log) async {
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

  SimpleSelectStatement<$ActualSetLogsTable, ActualSetLogRow>
  _actualSetLogsQuery(String sessionSetId) {
    return _database.select(_database.actualSetLogs)
      ..where((row) => row.sessionSetId.equals(sessionSetId))
      ..orderBy([(row) => OrderingTerm.asc(row.revision)]);
  }

  SimpleSelectStatement<$WorkoutSessionsTable, WorkoutSessionRow>
  _sessionsQuery(String profileId) {
    return _database.select(_database.workoutSessions)
      ..where((row) => row.profileId.equals(profileId))
      ..orderBy([
        (row) => OrderingTerm.desc(row.scheduledAt),
        (row) => OrderingTerm.desc(row.createdAt),
      ]);
  }

  SimpleSelectStatement<$SessionSetsTable, SessionSetRow> _sessionSetsQuery(
    String sessionId,
  ) {
    return _database.select(_database.sessionSets)
      ..where((row) => row.sessionId.equals(sessionId))
      ..orderBy([
        (row) => OrderingTerm.asc(row.exerciseOrder),
        (row) => OrderingTerm.asc(row.setOrder),
      ]);
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

OnboardingPreferencesRecord _onboardingPreferencesFromRow(
  OnboardingPreferenceRow row,
) => OnboardingPreferencesRecord(
  profileId: row.profileId,
  goal: _enumByName(TrainingGoal.values, row.goal),
  experienceLevel: _enumByName(
    TrainingExperienceLevel.values,
    row.experienceLevel,
  ),
  equipment: List.unmodifiable(
    _decodeEnumCsv(EquipmentPreference.values, row.equipmentIds),
  ),
  preferredSessionLengthMinutes: row.preferredSessionLengthMinutes,
  preferredWeekdays: List.unmodifiable(
    _decodeEnumCsv(TrainingWeekday.values, row.preferredWeekdays),
  ),
  createdAt: _asUtc(row.createdAt),
  updatedAt: _asUtc(row.updatedAt),
);

OnboardingPreferencesCompanion _onboardingPreferencesCompanion(
  OnboardingPreferencesRecord preferences,
) => OnboardingPreferencesCompanion.insert(
  profileId: preferences.profileId,
  goal: _enumByName(StoredTrainingGoal.values, preferences.goal),
  experienceLevel: _enumByName(
    StoredTrainingExperienceLevel.values,
    preferences.experienceLevel,
  ),
  equipmentIds: _encodeEnumCsv(
    preferences.equipment,
    EquipmentPreference.values,
    'equipment',
  ),
  preferredSessionLengthMinutes: preferences.preferredSessionLengthMinutes,
  preferredWeekdays: _encodeEnumCsv(
    preferences.preferredWeekdays,
    TrainingWeekday.values,
    'preferredWeekdays',
  ),
  createdAt: Value(_asUtc(preferences.createdAt)),
  updatedAt: Value(_asUtc(preferences.updatedAt)),
);

AvailabilityWindowRecord _availabilityWindowFromRow(
  AvailabilityWindowRow row,
) => AvailabilityWindowRecord(
  id: row.id,
  profileId: row.profileId,
  weekday: _enumByName(TrainingWeekday.values, row.weekday),
  windowType: _enumByName(AvailabilityWindowType.values, row.windowType),
  startMinute: row.startMinute,
  endMinute: row.endMinute,
  createdAt: _asUtc(row.createdAt),
  updatedAt: _asUtc(row.updatedAt),
);

AvailabilityWindowsCompanion _availabilityWindowCompanion(
  AvailabilityWindowRecord window,
) => AvailabilityWindowsCompanion.insert(
  id: window.id,
  profileId: window.profileId,
  weekday: _enumByName(StoredTrainingWeekday.values, window.weekday),
  windowType: _enumByName(
    StoredAvailabilityWindowType.values,
    window.windowType,
  ),
  startMinute: window.startMinute,
  endMinute: window.endMinute,
  createdAt: Value(_asUtc(window.createdAt)),
  updatedAt: Value(_asUtc(window.updatedAt)),
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

ProgramsCompanion _programCompanion(ProgramRecord program) =>
    ProgramsCompanion.insert(
      id: program.id,
      profileId: program.profileId,
      name: program.name,
      status: _enumByName(ProgramStatus.values, program.lifecycle),
      createdAt: Value(_asUtc(program.createdAt)),
      updatedAt: Value(_asUtc(program.updatedAt)),
      archivedAt: Value(_nullableUtc(program.archivedAt)),
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

ProgramTrainingDayRecord _programTrainingDayFromRow(
  ProgramVersionTrainingDayRow row,
) => ProgramTrainingDayRecord(
  id: row.id,
  programVersionId: row.programVersionId,
  trainingDayOrder: row.trainingDayOrder,
  name: row.name,
  createdAt: _asUtc(row.createdAt),
);

ProgramVersionTrainingDaysCompanion _programTrainingDayCompanion(
  ProgramTrainingDayRecord day,
) => ProgramVersionTrainingDaysCompanion.insert(
  id: day.id,
  programVersionId: day.programVersionId,
  trainingDayOrder: day.trainingDayOrder,
  name: day.name,
  createdAt: Value(_asUtc(day.createdAt)),
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

ActualSetLogRecord? _latestActualSetLog(List<ActualSetLogRecord> logs) {
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

int _comparePerformanceDescending(
  ExerciseSetPerformanceRecord left,
  ExerciseSetPerformanceRecord right,
) {
  final sessionComparison = _sessionPerformanceTime(
    right,
  ).compareTo(_sessionPerformanceTime(left));
  if (sessionComparison != 0) {
    return sessionComparison;
  }

  final recordedComparison = right.performedAt.compareTo(left.performedAt);
  if (recordedComparison != 0) {
    return recordedComparison;
  }

  return left.setOrder.compareTo(right.setOrder);
}

DateTime _sessionPerformanceTime(ExerciseSetPerformanceRecord performance) {
  return performance.sessionStartedAt ??
      performance.sessionScheduledAt ??
      performance.sessionCreatedAt;
}

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

List<T> _decodeEnumCsv<T extends Enum>(List<T> values, String csv) {
  if (csv.trim().isEmpty) {
    return const [];
  }
  return [
    for (final token in csv.split(','))
      values.firstWhere((value) => value.name == token),
  ];
}

String _encodeEnumCsv<T extends Enum>(
  List<T> values,
  List<T> canonicalValues,
  String fieldName,
) {
  _validateNonEmptyUnique(values, fieldName);
  final canonicalIndexes = {
    for (final (index, value) in canonicalValues.indexed) value: index,
  };
  final sorted = values.toSet().toList(growable: false)
    ..sort(
      (left, right) =>
          canonicalIndexes[left]!.compareTo(canonicalIndexes[right]!),
    );
  return sorted.map((value) => value.name).join(',');
}

void _validateOnboardingPreferences(OnboardingPreferencesRecord preferences) {
  if (preferences.profileId.trim().isEmpty) {
    throw ArgumentError.value(
      preferences.profileId,
      'profileId',
      'Profile id is required.',
    );
  }
  if (preferences.preferredSessionLengthMinutes < 20 ||
      preferences.preferredSessionLengthMinutes > 180) {
    throw ArgumentError.value(
      preferences.preferredSessionLengthMinutes,
      'preferredSessionLengthMinutes',
      'Session length must be between 20 and 180 minutes.',
    );
  }
  _validateNonEmptyUnique(preferences.equipment, 'equipment');
  _validateNonEmptyUnique(preferences.preferredWeekdays, 'preferredWeekdays');
}

void _validateAvailabilityWindows(
  String profileId,
  List<AvailabilityWindowRecord> windows,
) {
  if (profileId.trim().isEmpty) {
    throw ArgumentError.value(
      profileId,
      'profileId',
      'Profile id is required.',
    );
  }

  final ids = <String>{};
  final exactWindows = <String>{};
  for (final window in windows) {
    if (window.id.trim().isEmpty) {
      throw ArgumentError.value(window.id, 'id', 'Window id is required.');
    }
    if (window.profileId != profileId) {
      throw ArgumentError.value(
        window.profileId,
        'profileId',
        'Every availability window must belong to the replaced profile.',
      );
    }
    if (window.startMinute < 0 || window.startMinute > 1439) {
      throw ArgumentError.value(
        window.startMinute,
        'startMinute',
        'Start minute must be between 0 and 1439.',
      );
    }
    if (window.endMinute < 1 || window.endMinute > 1440) {
      throw ArgumentError.value(
        window.endMinute,
        'endMinute',
        'End minute must be between 1 and 1440.',
      );
    }
    if (window.endMinute <= window.startMinute) {
      throw ArgumentError.value(
        window.endMinute,
        'endMinute',
        'End minute must be after start minute.',
      );
    }

    if (!ids.add(window.id)) {
      throw ArgumentError.value(window.id, 'id', 'Window ids must be unique.');
    }
    final exactKey = [
      window.profileId,
      window.weekday.name,
      window.windowType.name,
      window.startMinute,
      window.endMinute,
    ].join('|');
    if (!exactWindows.add(exactKey)) {
      throw ArgumentError.value(
        window,
        'windows',
        'Duplicate availability windows are not allowed.',
      );
    }
  }
}

void _validateNonEmptyUnique<T extends Enum>(List<T> values, String fieldName) {
  if (values.isEmpty) {
    throw ArgumentError.value(
      values,
      fieldName,
      'At least one value required.',
    );
  }
  if (values.toSet().length != values.length) {
    throw ArgumentError.value(values, fieldName, 'Values must be unique.');
  }
}

List<AvailabilityWindowRecord> _sortAvailabilityWindows(
  List<AvailabilityWindowRecord> windows,
) {
  final weekdayIndexes = {
    for (final (index, weekday) in TrainingWeekday.values.indexed)
      weekday: index,
  };
  final windowTypeIndexes = {
    for (final (index, type) in AvailabilityWindowType.values.indexed)
      type: index,
  };
  return List.unmodifiable(
    windows..sort((left, right) {
      final weekdayComparison = weekdayIndexes[left.weekday]!.compareTo(
        weekdayIndexes[right.weekday]!,
      );
      if (weekdayComparison != 0) {
        return weekdayComparison;
      }
      final startComparison = left.startMinute.compareTo(right.startMinute);
      if (startComparison != 0) {
        return startComparison;
      }
      return windowTypeIndexes[left.windowType]!.compareTo(
        windowTypeIndexes[right.windowType]!,
      );
    }),
  );
}

DateTime _asUtc(DateTime value) => value.toUtc();

DateTime? _nullableUtc(DateTime? value) => value?.toUtc();
