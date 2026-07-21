import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:project_atlas/core/repositories/repository_providers.dart';
import 'package:project_atlas/core/repositories/repository_records.dart';
import 'package:project_atlas/features/program/application/program_draft_persistence.dart';

final onboardingClockProvider = Provider<DateTime Function()>(
  (ref) => DateTime.now,
);

final onboardingControllerProvider =
    AsyncNotifierProvider<OnboardingController, OnboardingState>(
      OnboardingController.new,
    );

final class OnboardingState {
  const OnboardingState({required this.profileId, this.preferences});

  final String profileId;
  final OnboardingPreferencesRecord? preferences;

  bool get isComplete => preferences != null;
}

class OnboardingController extends AsyncNotifier<OnboardingState> {
  @override
  Future<OnboardingState> build() async {
    final profileId = ref.read(localProgramProfileIdProvider);
    final preferences = await ref
        .read(onboardingRepositoryProvider)
        .getPreferences(profileId);
    return OnboardingState(profileId: profileId, preferences: preferences);
  }

  Future<void> savePreferences({
    required TrainingGoal goal,
    required TrainingExperienceLevel experienceLevel,
    required List<EquipmentPreference> equipment,
    required int preferredSessionLengthMinutes,
    required List<TrainingWeekday> preferredWeekdays,
  }) async {
    final current = state.asData?.value ?? await build();
    final previousPreferences = current.preferences;
    final now = ref.read(onboardingClockProvider)().toUtc();
    final preferences = OnboardingPreferencesRecord(
      profileId: current.profileId,
      goal: goal,
      experienceLevel: experienceLevel,
      equipment: List.unmodifiable(equipment),
      preferredSessionLengthMinutes: preferredSessionLengthMinutes,
      preferredWeekdays: List.unmodifiable(preferredWeekdays),
      createdAt: previousPreferences?.createdAt ?? now,
      updatedAt: now,
    );

    try {
      await _ensureProfile(profileId: current.profileId, now: now);
      await ref.read(onboardingRepositoryProvider).savePreferences(preferences);
      state = AsyncData(
        OnboardingState(profileId: current.profileId, preferences: preferences),
      );
    } catch (error, stackTrace) {
      Error.throwWithStackTrace(error, stackTrace);
    }
  }

  Future<void> _ensureProfile({
    required String profileId,
    required DateTime now,
  }) async {
    final profileRepository = ref.read(profileRepositoryProvider);
    final existingProfile = await profileRepository.getProfile(profileId);
    if (existingProfile != null) {
      return;
    }

    await profileRepository.saveProfile(
      ProfileRecord(
        id: profileId,
        unitPreference: UnitPreference.metric,
        createdAt: now,
        updatedAt: now,
      ),
    );
  }
}
