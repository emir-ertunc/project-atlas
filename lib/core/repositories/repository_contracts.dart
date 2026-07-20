import 'package:project_atlas/core/repositories/repository_records.dart';

abstract interface class ProfileRepository {
  Stream<ProfileRecord?> watchProfile(String profileId);

  Future<ProfileRecord?> getProfile(String profileId);

  Future<void> saveProfile(ProfileRecord profile);
}

abstract interface class ProgramRepository {
  Stream<List<ProgramRecord>> watchPrograms(String profileId);

  Future<List<ProgramRecord>> getPrograms(String profileId);

  Future<ProgramRecord?> getProgram(String programId);

  Stream<List<ProgramVersionRecord>> watchVersions(String programId);

  Future<List<ProgramVersionRecord>> getVersions(String programId);

  Stream<List<ProgramTrainingDayRecord>> watchTrainingDays(String versionId);

  Future<List<ProgramTrainingDayRecord>> getTrainingDays(String versionId);

  Stream<List<PrescribedSetRecord>> watchPrescription(String versionId);

  Future<List<PrescribedSetRecord>> getPrescription(String versionId);

  Future<void> saveProgram(ProgramRecord program);

  Future<void> saveProgramSnapshot(
    ProgramRecord program,
    ProgramVersionRecord version,
    List<ProgramTrainingDayRecord> trainingDays,
    List<PrescribedSetRecord> prescription, {
    bool retireActiveVersions = false,
  });

  Future<void> addVersion(
    ProgramVersionRecord version,
    List<ProgramTrainingDayRecord> trainingDays,
    List<PrescribedSetRecord> prescription,
  );
}

abstract interface class WorkoutRepository {
  Stream<List<WorkoutSessionRecord>> watchSessions(String profileId);

  Future<List<WorkoutSessionRecord>> getSessions(String profileId);

  Stream<List<SessionSetRecord>> watchSessionSets(String sessionId);

  Future<List<SessionSetRecord>> getSessionSets(String sessionId);

  Stream<List<ActualSetLogRecord>> watchActualSetLogs(String sessionSetId);

  Future<List<ActualSetLogRecord>> getActualSetLogs(String sessionSetId);

  Future<List<ExerciseSetPerformanceRecord>> getExercisePerformanceHistory({
    required String profileId,
    required String exerciseId,
    String? excludedSessionId,
    int limit = 50,
  });

  Future<void> saveSessionPlan(
    WorkoutSessionRecord session,
    List<SessionSetRecord> sets,
  );

  Future<void> completeSessionSet(
    SessionSetRecord completedSet,
    ActualSetLogRecord log,
  );

  Future<void> appendActualSetLog(ActualSetLogRecord log);
}

abstract interface class MeasurementRepository {
  Stream<List<MeasurementRecord>> watchMeasurements(String profileId);

  Future<void> addMeasurement(MeasurementRecord measurement);
}

abstract interface class ExerciseRepository {
  Stream<List<ExerciseRecord>> watchExercises();

  Future<ExerciseRecord?> getExercise(String exerciseId);

  Future<List<ExerciseRecord>> searchExercises(String query);
}
