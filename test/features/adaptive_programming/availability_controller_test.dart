import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:project_atlas/core/database/app_database.dart';
import 'package:project_atlas/core/database/database_providers.dart';
import 'package:project_atlas/core/repositories/repository_providers.dart';
import 'package:project_atlas/core/repositories/repository_records.dart';
import 'package:project_atlas/features/adaptive_programming/application/availability_controller.dart';
import 'package:project_atlas/features/program/application/program_draft_persistence.dart';

void main() {
  late AppDatabase database;
  late ProviderContainer container;
  late DateTime now;

  setUp(() {
    database = AppDatabase.forTesting(NativeDatabase.memory());
    now = DateTime.utc(2026, 7, 21, 11);
    container = ProviderContainer(
      overrides: [
        appDatabaseProvider.overrideWithValue(database),
        availabilityClockProvider.overrideWithValue(() => now),
      ],
    );
  });

  tearDown(() async {
    container.dispose();
    await database.close();
  });

  test(
    'saving weekly windows creates the local profile and persists them',
    () async {
      await container.read(availabilityControllerProvider.future);

      await container
          .read(availabilityControllerProvider.notifier)
          .saveWindows([
            const AvailabilityWindowInput(
              weekday: TrainingWeekday.monday,
              windowType: AvailabilityWindowType.fixed,
              startMinute: 18 * 60,
              endMinute: 19 * 60,
            ),
            const AvailabilityWindowInput(
              weekday: TrainingWeekday.wednesday,
              windowType: AvailabilityWindowType.flexible,
              startMinute: 17 * 60,
              endMinute: 21 * 60,
            ),
          ]);

      final profile = await container
          .read(profileRepositoryProvider)
          .getProfile(localProgramProfileId);
      final windows = await container
          .read(availabilityRepositoryProvider)
          .getWindows(localProgramProfileId);
      final state = await container.read(availabilityControllerProvider.future);

      expect(profile?.unitPreference, UnitPreference.metric);
      expect(windows, hasLength(2));
      expect(windows.first.windowType, AvailabilityWindowType.fixed);
      expect(windows.last.windowType, AvailabilityWindowType.flexible);
      expect(windows.first.createdAt, now);
      expect(windows.first.updatedAt, now);
      expect(state.hasWindows, isTrue);
    },
  );
}
