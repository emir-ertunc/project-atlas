import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:project_atlas/core/repositories/repository_providers.dart';
import 'package:project_atlas/core/repositories/repository_records.dart';
import 'package:project_atlas/features/program/application/program_draft_persistence.dart';

final availabilityClockProvider = Provider<DateTime Function()>(
  (ref) => DateTime.now,
);

final availabilityControllerProvider =
    AsyncNotifierProvider<AvailabilityController, AvailabilityState>(
      AvailabilityController.new,
    );

final class AvailabilityState {
  const AvailabilityState({required this.profileId, required this.windows});

  final String profileId;
  final List<AvailabilityWindowRecord> windows;

  bool get hasWindows => windows.isNotEmpty;
}

final class AvailabilityWindowInput {
  const AvailabilityWindowInput({
    required this.weekday,
    required this.windowType,
    required this.startMinute,
    required this.endMinute,
    this.id,
    this.createdAt,
  });

  AvailabilityWindowInput.fromRecord(AvailabilityWindowRecord record)
    : id = record.id,
      weekday = record.weekday,
      windowType = record.windowType,
      startMinute = record.startMinute,
      endMinute = record.endMinute,
      createdAt = record.createdAt;

  final String? id;
  final TrainingWeekday weekday;
  final AvailabilityWindowType windowType;
  final int startMinute;
  final int endMinute;
  final DateTime? createdAt;
}

class AvailabilityController extends AsyncNotifier<AvailabilityState> {
  @override
  Future<AvailabilityState> build() async {
    final profileId = ref.read(localProgramProfileIdProvider);
    final windows = await ref
        .read(availabilityRepositoryProvider)
        .getWindows(profileId);
    return AvailabilityState(
      profileId: profileId,
      windows: List.unmodifiable(windows),
    );
  }

  Future<void> saveWindows(List<AvailabilityWindowInput> inputs) async {
    if (inputs.isEmpty) {
      throw ArgumentError.value(
        inputs,
        'inputs',
        'At least one window needed.',
      );
    }

    final current = state.asData?.value ?? await build();
    final now = ref.read(availabilityClockProvider)().toUtc();
    final windows = [
      for (final (index, input) in inputs.indexed)
        AvailabilityWindowRecord(
          id: input.id ?? _windowId(now: now, index: index),
          profileId: current.profileId,
          weekday: input.weekday,
          windowType: input.windowType,
          startMinute: input.startMinute,
          endMinute: input.endMinute,
          createdAt: input.createdAt ?? now,
          updatedAt: now,
        ),
    ];

    await _ensureProfile(profileId: current.profileId, now: now);
    await ref
        .read(availabilityRepositoryProvider)
        .replaceWindows(current.profileId, windows);
    state = AsyncData(
      AvailabilityState(
        profileId: current.profileId,
        windows: List.unmodifiable(windows),
      ),
    );
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

  String _windowId({required DateTime now, required int index}) {
    return 'availability_${now.microsecondsSinceEpoch.toRadixString(36)}_'
        '${index.toRadixString(36)}';
  }
}
