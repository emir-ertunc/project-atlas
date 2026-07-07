import 'package:project_atlas/core/repositories/repository_records.dart';

abstract interface class ProfileRepository {
  Stream<ProfileRecord?> watchProfile(String profileId);

  Future<ProfileRecord?> getProfile(String profileId);

  Future<void> saveProfile(ProfileRecord profile);
}

abstract interface class ProgramRepository {
  Stream<List<ProgramRecord>> watchPrograms(String profileId);

  Future<ProgramRecord?> getProgram(String programId);

  Stream<List<ProgramVersionRecord>> watchVersions(String programId);

  Stream<List<PrescribedSetRecord>> watchPrescription(String versionId);

  Future<void> saveProgram(ProgramRecord program);

  Future<void> addVersion(
    ProgramVersionRecord version,
    List<PrescribedSetRecord> prescription,
  );
}

abstract interface class WorkoutRepository {
  Stream<List<WorkoutSessionRecord>> watchSessions(String profileId);

  Stream<List<SessionSetRecord>> watchSessionSets(String sessionId);

  Stream<List<ActualSetLogRecord>> watchActualSetLogs(String sessionSetId);

  Future<void> saveSessionPlan(
    WorkoutSessionRecord session,
    List<SessionSetRecord> sets,
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
