import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:project_atlas/core/design_system/tokens/app_spacing.dart';
import 'package:project_atlas/core/repositories/repository_records.dart';
import 'package:project_atlas/features/adaptive_programming/application/availability_controller.dart';
import 'package:project_atlas/features/adaptive_programming/domain/program_generator.dart';
import 'package:project_atlas/features/exercise_catalog/application/exercise_catalog_provider.dart';
import 'package:project_atlas/features/exercise_catalog/domain/exercise_catalog.dart';
import 'package:project_atlas/features/program/application/program_builder_controller.dart';
import 'package:project_atlas/l10n/generated/app_localizations.dart';

class GeneratedProgramCard extends ConsumerWidget {
  const GeneratedProgramCard({required this.preferences, super.key});

  static const cardKey = Key('generated-program-card');
  static const summaryKey = Key('generated-program-summary');
  static const applyButtonKey = Key('generated-program-apply-button');

  static Key dayTileKey(String dayId) => Key('generated-program-day-$dayId');

  final OnboardingPreferencesRecord preferences;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final availabilityState = ref.watch(availabilityControllerProvider);

    return Card(
      key: cardKey,
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: availabilityState.when(
          data: (availability) {
            if (!availability.hasWindows) {
              return _GeneratedProgramShell(
                child: Text(l10n.generatedProgramAvailabilityRequired),
              );
            }

            return ref
                .watch(exerciseCatalogProvider)
                .when(
                  data: (catalog) => _GeneratedProgramContent(
                    preferences: preferences,
                    availabilityWindows: availability.windows,
                    catalog: catalog,
                  ),
                  error: (_, _) => _GeneratedProgramShell(
                    child: Text(l10n.generatedProgramCatalogLoadError),
                  ),
                  loading: () => _GeneratedProgramShell(
                    child: Text(l10n.exerciseCatalogLoading),
                  ),
                );
          },
          error: (_, _) =>
              _GeneratedProgramShell(child: Text(l10n.availabilityLoadError)),
          loading: () =>
              _GeneratedProgramShell(child: Text(l10n.availabilityLoading)),
        ),
      ),
    );
  }
}

class _GeneratedProgramShell extends StatelessWidget {
  const _GeneratedProgramShell({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.auto_awesome_motion, color: theme.colorScheme.primary),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Semantics(
                header: true,
                child: Text(
                  l10n.generatedProgramTitle,
                  style: theme.textTheme.titleMedium,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.xs),
        Text(l10n.generatedProgramDescription),
        const SizedBox(height: AppSpacing.md),
        child,
      ],
    );
  }
}

class _GeneratedProgramContent extends ConsumerWidget {
  const _GeneratedProgramContent({
    required this.preferences,
    required this.availabilityWindows,
    required this.catalog,
  });

  final OnboardingPreferencesRecord preferences;
  final List<AvailabilityWindowRecord> availabilityWindows;
  final ExerciseCatalog catalog;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final localeCode = Localizations.localeOf(context).languageCode;
    final plan = buildAdaptiveProgramPlan(
      preferences: preferences,
      availabilityWindows: availabilityWindows,
      catalog: catalog,
    );

    if (plan.days.isEmpty) {
      return _GeneratedProgramShell(child: Text(l10n.generatedProgramNoPlan));
    }

    return _GeneratedProgramShell(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.generatedProgramSummary(
              plan.sessionsPerWeek,
              plan.weeklySetTarget,
              plan.maxExercisesPerSession,
              plan.minimumRir,
            ),
            key: GeneratedProgramCard.summaryKey,
            style: Theme.of(context).textTheme.labelLarge,
          ),
          const SizedBox(height: AppSpacing.sm),
          for (final day in plan.days) ...[
            _GeneratedProgramDayTile(
              day: day,
              catalog: catalog,
              localeCode: localeCode,
            ),
            const SizedBox(height: AppSpacing.xs),
          ],
          const SizedBox(height: AppSpacing.sm),
          FilledButton.icon(
            key: GeneratedProgramCard.applyButtonKey,
            onPressed: () => _applyPlan(context, ref, plan),
            icon: const Icon(Icons.playlist_add_check),
            label: Text(l10n.generatedProgramApplyDraft),
          ),
        ],
      ),
    );
  }

  Future<void> _applyPlan(
    BuildContext context,
    WidgetRef ref,
    GeneratedProgramPlan plan,
  ) async {
    final l10n = AppLocalizations.of(context);
    final existingDraft = ref.read(programBuilderControllerProvider).draft;

    if (existingDraft != null) {
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (dialogContext) => AlertDialog(
          title: Text(l10n.generatedProgramReplaceDraftTitle),
          content: Text(l10n.generatedProgramReplaceDraftMessage),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: Text(l10n.generatedProgramReplaceDraftCancel),
            ),
            FilledButton(
              onPressed: () => Navigator.of(dialogContext).pop(true),
              child: Text(l10n.generatedProgramReplaceDraftConfirm),
            ),
          ],
        ),
      );

      if (confirmed != true) {
        return;
      }
    }

    if (!context.mounted) {
      return;
    }

    ref
        .read(programBuilderControllerProvider.notifier)
        .replaceDraft(
          plan.toProgramDraft(
            name: l10n.generatedProgramDraftName(_goalLabel(l10n, plan.goal)),
          ),
        );
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(l10n.generatedProgramAppliedMessage)),
    );
  }
}

class _GeneratedProgramDayTile extends StatelessWidget {
  const _GeneratedProgramDayTile({
    required this.day,
    required this.catalog,
    required this.localeCode,
  });

  final GeneratedTrainingDayPlan day;
  final ExerciseCatalog catalog;
  final String localeCode;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return ExpansionTile(
      key: GeneratedProgramCard.dayTileKey(day.id),
      tilePadding: EdgeInsets.zero,
      title: Text(_focusLabel(l10n, day.focus)),
      subtitle: Text(
        l10n.generatedProgramDaySummary(
          _weekdayLabel(l10n, day.weekday),
          _windowTypeLabel(l10n, day.windowType),
          _formatClockMinute(day.startMinute),
          _formatClockMinute(day.endMinute),
          day.prescriptions.length,
          day.setCount,
        ),
      ),
      children: [
        for (final prescription in day.prescriptions)
          ListTile(
            dense: true,
            contentPadding: EdgeInsets.zero,
            title: Text(
              catalog.exerciseById(prescription.exerciseId)?.name(localeCode) ??
                  humanizeCatalogIdentifier(prescription.exerciseId),
            ),
            subtitle: Text(
              l10n.generatedProgramExerciseSummary(
                prescription.setCount,
                prescription.minimumRepetitions,
                prescription.maximumRepetitions,
                prescription.targetRir ?? 0,
                prescription.restSeconds,
              ),
            ),
          ),
      ],
    );
  }
}

String _focusLabel(AppLocalizations l10n, GeneratedProgramDayFocus focus) {
  return switch (focus) {
    GeneratedProgramDayFocus.fullBody => l10n.generatedProgramFocusFullBody,
    GeneratedProgramDayFocus.upperEmphasis =>
      l10n.generatedProgramFocusUpperEmphasis,
    GeneratedProgramDayFocus.lowerEmphasis =>
      l10n.generatedProgramFocusLowerEmphasis,
    GeneratedProgramDayFocus.posteriorChain =>
      l10n.generatedProgramFocusPosteriorChain,
    GeneratedProgramDayFocus.conditioningSupport =>
      l10n.generatedProgramFocusConditioningSupport,
  };
}

String _goalLabel(AppLocalizations l10n, TrainingGoal goal) {
  return switch (goal) {
    TrainingGoal.generalFitness => l10n.onboardingGoalGeneralFitness,
    TrainingGoal.hypertrophy => l10n.onboardingGoalHypertrophy,
    TrainingGoal.maximumStrength => l10n.onboardingGoalMaximumStrength,
    TrainingGoal.bodyRecomposition => l10n.onboardingGoalBodyRecomposition,
    TrainingGoal.muscularEndurance => l10n.onboardingGoalMuscularEndurance,
    TrainingGoal.athleticPerformance => l10n.onboardingGoalAthleticPerformance,
    TrainingGoal.maintenance => l10n.onboardingGoalMaintenance,
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

String _windowTypeLabel(
  AppLocalizations l10n,
  AvailabilityWindowType windowType,
) {
  return switch (windowType) {
    AvailabilityWindowType.fixed => l10n.availabilityFixedPeriod,
    AvailabilityWindowType.flexible => l10n.availabilityFlexiblePeriod,
  };
}

String _formatClockMinute(int minuteOfDay) {
  final hours = minuteOfDay ~/ 60;
  final minutes = minuteOfDay % 60;
  return '${hours.toString().padLeft(2, '0')}:'
      '${minutes.toString().padLeft(2, '0')}';
}
