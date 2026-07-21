import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:project_atlas/core/database/database_providers.dart';
import 'package:project_atlas/core/repositories/drift_repositories.dart';
import 'package:project_atlas/core/repositories/repository_contracts.dart';

final profileRepositoryProvider = Provider<ProfileRepository>(
  (ref) => DriftProfileRepository(ref.watch(appDatabaseProvider)),
);

final onboardingRepositoryProvider = Provider<OnboardingRepository>(
  (ref) => DriftOnboardingRepository(ref.watch(appDatabaseProvider)),
);

final availabilityRepositoryProvider = Provider<AvailabilityRepository>(
  (ref) => DriftAvailabilityRepository(ref.watch(appDatabaseProvider)),
);

final programRepositoryProvider = Provider<ProgramRepository>(
  (ref) => DriftProgramRepository(ref.watch(appDatabaseProvider)),
);

final workoutRepositoryProvider = Provider<WorkoutRepository>(
  (ref) => DriftWorkoutRepository(ref.watch(appDatabaseProvider)),
);

final measurementRepositoryProvider = Provider<MeasurementRepository>(
  (ref) => DriftMeasurementRepository(ref.watch(appDatabaseProvider)),
);
