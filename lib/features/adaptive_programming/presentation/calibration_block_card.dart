import 'package:flutter/material.dart';
import 'package:project_atlas/core/design_system/tokens/app_spacing.dart';
import 'package:project_atlas/core/repositories/repository_records.dart';
import 'package:project_atlas/features/adaptive_programming/domain/calibration_block.dart';
import 'package:project_atlas/l10n/generated/app_localizations.dart';

class CalibrationBlockCard extends StatelessWidget {
  const CalibrationBlockCard({required this.preferences, super.key});

  static const cardKey = Key('calibration-block-card');
  static const summaryKey = Key('calibration-block-summary');
  static const policyKey = Key('calibration-block-policy');
  static const exitRequirementsKey = Key('calibration-block-exit-requirements');

  static Key weekRowKey(int weekNumber) =>
      Key('calibration-block-week-$weekNumber');

  final OnboardingPreferencesRecord preferences;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final plan = buildConservativeCalibrationBlock(preferences);
    final weekdayNames = plan.recommendedWeekdays
        .map((weekday) => _weekdayLabel(l10n, weekday))
        .join(', ');

    return DecoratedBox(
      key: cardKey,
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerLow,
        borderRadius: AppRadii.large,
        border: Border.all(color: theme.colorScheme.outlineVariant),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.speed_outlined, color: theme.colorScheme.primary),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Semantics(
                    header: true,
                    child: Text(
                      l10n.calibrationBlockTitle,
                      style: theme.textTheme.titleMedium,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(l10n.calibrationBlockDescription),
            const SizedBox(height: AppSpacing.md),
            Text(
              l10n.calibrationBlockSummary(
                plan.durationWeeks,
                plan.sessionsPerWeek,
                plan.minimumRir,
              ),
              key: summaryKey,
              style: theme.textTheme.labelLarge,
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              l10n.calibrationBlockSessionTarget(
                plan.sessionLengthMinutes,
                weekdayNames,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              l10n.calibrationBlockNoProgression,
              key: policyKey,
              style: theme.textTheme.bodySmall,
            ),
            const SizedBox(height: AppSpacing.md),
            for (final week in plan.weeks)
              Padding(
                key: weekRowKey(week.weekNumber),
                padding: const EdgeInsets.only(bottom: AppSpacing.xs),
                child: Text(
                  l10n.calibrationWeekSummary(
                    week.weekNumber,
                    _focusLabel(l10n, week.focus),
                    week.plannedVolumePercent,
                    week.minimumRir,
                  ),
                ),
              ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              l10n.calibrationExitRequirements(
                plan.exitRequirements
                    .map(
                      (requirement) => _exitRequirementLabel(l10n, requirement),
                    )
                    .join(', '),
              ),
              key: exitRequirementsKey,
              style: theme.textTheme.bodySmall,
            ),
          ],
        ),
      ),
    );
  }
}

String _focusLabel(AppLocalizations l10n, CalibrationWeekFocus focus) {
  return switch (focus) {
    CalibrationWeekFocus.techniqueBaseline =>
      l10n.calibrationFocusTechniqueBaseline,
    CalibrationWeekFocus.repeatableExecution =>
      l10n.calibrationFocusRepeatableExecution,
    CalibrationWeekFocus.stableExposure => l10n.calibrationFocusStableExposure,
    CalibrationWeekFocus.prescriptionPreview =>
      l10n.calibrationFocusPrescriptionPreview,
  };
}

String _exitRequirementLabel(
  AppLocalizations l10n,
  CalibrationExitRequirement requirement,
) {
  return switch (requirement) {
    CalibrationExitRequirement.plannedWeeksCompleted =>
      l10n.calibrationExitPlannedWeeksCompleted,
    CalibrationExitRequirement.noPainReports =>
      l10n.calibrationExitNoPainReports,
    CalibrationExitRequirement.noRepeatedPerformanceMisses =>
      l10n.calibrationExitNoRepeatedPerformanceMisses,
    CalibrationExitRequirement.stableRirEvidence =>
      l10n.calibrationExitStableRirEvidence,
  };
}

String _weekdayLabel(AppLocalizations l10n, TrainingWeekday weekday) {
  return switch (weekday) {
    TrainingWeekday.monday => l10n.onboardingWeekdayMonday,
    TrainingWeekday.tuesday => l10n.onboardingWeekdayTuesday,
    TrainingWeekday.wednesday => l10n.onboardingWeekdayWednesday,
    TrainingWeekday.thursday => l10n.onboardingWeekdayThursday,
    TrainingWeekday.friday => l10n.onboardingWeekdayFriday,
    TrainingWeekday.saturday => l10n.onboardingWeekdaySaturday,
    TrainingWeekday.sunday => l10n.onboardingWeekdaySunday,
  };
}
