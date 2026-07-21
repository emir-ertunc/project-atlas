import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:project_atlas/core/database/app_database.dart';
import 'package:project_atlas/core/database/database_providers.dart';
import 'package:project_atlas/core/repositories/repository_providers.dart';
import 'package:project_atlas/core/repositories/repository_records.dart';
import 'package:project_atlas/features/onboarding/application/onboarding_controller.dart';
import 'package:project_atlas/features/program/application/program_draft_persistence.dart';

void main() {
  late AppDatabase database;
  late ProviderContainer container;
  late DateTime now;

  setUp(() {
    database = AppDatabase.forTesting(NativeDatabase.memory());
    now = DateTime.utc(2026, 7, 21, 9);
    container = ProviderContainer(
      overrides: [
        appDatabaseProvider.overrideWithValue(database),
        onboardingClockProvider.overrideWithValue(() => now),
      ],
    );
  });

  tearDown(() async {
    container.dispose();
    await database.close();
  });

  test(
    'saving preferences creates the local profile and persists onboarding',
    () async {
      await container.read(onboardingControllerProvider.future);

      await container
          .read(onboardingControllerProvider.notifier)
          .savePreferences(
            goal: TrainingGoal.bodyRecomposition,
            experienceLevel: TrainingExperienceLevel.beginner,
            equipment: const [
              EquipmentPreference.dumbbells,
              EquipmentPreference.bodyweight,
            ],
            preferredSessionLengthMinutes: 45,
            preferredWeekdays: const [
              TrainingWeekday.tuesday,
              TrainingWeekday.thursday,
            ],
          );

      final profile = await container
          .read(profileRepositoryProvider)
          .getProfile(localProgramProfileId);
      final preferences = await container
          .read(onboardingRepositoryProvider)
          .getPreferences(localProgramProfileId);
      final state = await container.read(onboardingControllerProvider.future);

      expect(profile?.unitPreference, UnitPreference.metric);
      expect(preferences?.goal, TrainingGoal.bodyRecomposition);
      expect(preferences?.experienceLevel, TrainingExperienceLevel.beginner);
      expect(preferences?.equipment, [
        EquipmentPreference.bodyweight,
        EquipmentPreference.dumbbells,
      ]);
      expect(preferences?.preferredSessionLengthMinutes, 45);
      expect(preferences?.preferredWeekdays, [
        TrainingWeekday.tuesday,
        TrainingWeekday.thursday,
      ]);
      expect(preferences?.createdAt, now);
      expect(preferences?.updatedAt, now);
      expect(state.isComplete, isTrue);
    },
  );
}
