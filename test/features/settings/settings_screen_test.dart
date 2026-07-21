import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:project_atlas/core/database/app_database.dart';
import 'package:project_atlas/core/database/database_providers.dart';
import 'package:project_atlas/core/database/tables/availability_windows.dart';
import 'package:project_atlas/core/database/tables/onboarding_preferences.dart';
import 'package:project_atlas/core/repositories/repository_records.dart';
import 'package:project_atlas/features/adaptive_programming/application/availability_controller.dart';
import 'package:project_atlas/features/adaptive_programming/presentation/availability_window_editor.dart';
import 'package:project_atlas/features/adaptive_programming/presentation/calibration_block_card.dart';
import 'package:project_atlas/features/adaptive_programming/presentation/generated_program_card.dart';
import 'package:project_atlas/features/adaptive_programming/presentation/missed_session_replacement_card.dart';
import 'package:project_atlas/features/exercise_catalog/application/exercise_catalog_provider.dart';
import 'package:project_atlas/features/exercise_catalog/domain/exercise_catalog.dart';
import 'package:project_atlas/features/onboarding/application/onboarding_controller.dart';
import 'package:project_atlas/features/settings/presentation/settings_screen.dart';
import 'package:project_atlas/l10n/generated/app_localizations.dart';

import '../../support/test_exercise_catalog.dart';

void main() {
  late AppDatabase database;
  late ExerciseCatalog testCatalog;
  late DateTime now;

  setUpAll(() {
    testCatalog = loadTestExerciseCatalog();
  });

  setUp(() {
    database = AppDatabase.forTesting(NativeDatabase.memory());
    now = DateTime.utc(2026, 7, 21, 10);
  });

  tearDown(() async {
    await database.close();
  });

  testWidgets('saves goal, experience, equipment, length, and day choices', (
    tester,
  ) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          appDatabaseProvider.overrideWithValue(database),
          onboardingClockProvider.overrideWithValue(() => now),
          availabilityClockProvider.overrideWithValue(() => now),
          exerciseCatalogProvider.overrideWith((ref) => testCatalog),
        ],
        child: const MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: SettingsScreen(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byKey(SettingsScreen.onboardingSectionKey), findsOneWidget);

    await tester.tap(find.byKey(SettingsScreen.goalDropdownKey));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Hypertrophy').last);
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(SettingsScreen.experienceDropdownKey));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Advanced').last);
    await tester.pumpAndSettle();

    await tester.tap(
      find.byKey(SettingsScreen.equipmentChipKey(EquipmentPreference.barbell)),
    );
    await tester.pumpAndSettle();

    await tester.ensureVisible(
      find.byKey(SettingsScreen.sessionLengthDropdownKey),
    );
    await tester.tap(find.byKey(SettingsScreen.sessionLengthDropdownKey));
    await tester.pumpAndSettle();
    await tester.tap(find.text('90 minutes').last);
    await tester.pumpAndSettle();

    await tester.ensureVisible(
      find.byKey(SettingsScreen.weekdayChipKey(TrainingWeekday.sunday)),
    );
    await tester.tap(
      find.byKey(SettingsScreen.weekdayChipKey(TrainingWeekday.sunday)),
    );
    await tester.pumpAndSettle();

    await tester.ensureVisible(
      find.byKey(SettingsScreen.saveOnboardingButtonKey),
    );
    await tester.tap(find.byKey(SettingsScreen.saveOnboardingButtonKey));
    await tester.pumpAndSettle();

    final preferences = await database
        .select(database.onboardingPreferences)
        .getSingle();

    expect(preferences.goal, StoredTrainingGoal.hypertrophy);
    expect(preferences.experienceLevel, StoredTrainingExperienceLevel.advanced);
    expect(preferences.equipmentIds, 'bodyweight,dumbbells,barbell');
    expect(preferences.preferredSessionLengthMinutes, 90);
    expect(preferences.preferredWeekdays, 'monday,wednesday,friday,sunday');
    expect(find.text('Onboarding preferences saved.'), findsOneWidget);
    expect(find.byKey(SettingsScreen.savedSummaryKey), findsOneWidget);
    expect(find.byKey(CalibrationBlockCard.cardKey), findsOneWidget);
    expect(
      find.text('2 weeks - 4 sessions/week - keep at least RIR 2'),
      findsOneWidget,
    );
    expect(
      find.text(
        'No load increases during calibration; collect clean set evidence first.',
      ),
      findsOneWidget,
    );
    expect(find.byKey(WeeklyAvailabilityEditor.cardKey), findsOneWidget);

    await tester.ensureVisible(
      find.byKey(WeeklyAvailabilityEditor.fixedPeriodKey(0)),
    );
    await tester.tap(find.byKey(WeeklyAvailabilityEditor.fixedPeriodKey(0)));
    await tester.pumpAndSettle();

    await tester.ensureVisible(
      find.byKey(WeeklyAvailabilityEditor.saveButtonKey),
    );
    await tester.tap(find.byKey(WeeklyAvailabilityEditor.saveButtonKey));
    await tester.pumpAndSettle();

    final availabilityWindows = await database
        .select(database.availabilityWindows)
        .get();
    final mondayWindow = availabilityWindows.firstWhere(
      (window) => window.weekday == StoredTrainingWeekday.monday,
    );
    expect(availabilityWindows, hasLength(4));
    expect(mondayWindow.windowType, StoredAvailabilityWindowType.fixed);
    expect(mondayWindow.startMinute, 18 * 60);
    expect(mondayWindow.endMinute, 19 * 60 + 30);
    expect(
      availabilityWindows.where(
        (window) => window.windowType == StoredAvailabilityWindowType.flexible,
      ),
      hasLength(3),
    );
    expect(availabilityWindows.map((window) => window.weekday).toSet(), {
      StoredTrainingWeekday.monday,
      StoredTrainingWeekday.wednesday,
      StoredTrainingWeekday.friday,
      StoredTrainingWeekday.sunday,
    });
    expect(
      availabilityWindows.every(
        (window) => window.startMinute == 18 * 60 && window.endMinute == 1170,
      ),
      isTrue,
    );
    expect(find.byKey(GeneratedProgramCard.cardKey), findsOneWidget);
    expect(find.byKey(GeneratedProgramCard.summaryKey), findsOneWidget);
    expect(find.byKey(GeneratedProgramCard.applyButtonKey), findsOneWidget);
    expect(find.byKey(MissedSessionReplacementCard.cardKey), findsOneWidget);
    expect(
      find.byKey(MissedSessionReplacementCard.missedDayDropdownKey),
      findsOneWidget,
    );
  });
}
