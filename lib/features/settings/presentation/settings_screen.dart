import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:project_atlas/core/design_system/components/feature_root_scaffold.dart';
import 'package:project_atlas/core/design_system/tokens/app_spacing.dart';
import 'package:project_atlas/core/repositories/repository_records.dart';
import 'package:project_atlas/features/adaptive_programming/presentation/availability_window_editor.dart';
import 'package:project_atlas/features/adaptive_programming/presentation/calibration_block_card.dart';
import 'package:project_atlas/features/adaptive_programming/presentation/generated_program_card.dart';
import 'package:project_atlas/features/adaptive_programming/presentation/missed_session_replacement_card.dart';
import 'package:project_atlas/features/onboarding/application/onboarding_controller.dart';
import 'package:project_atlas/l10n/generated/app_localizations.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  static const path = '/settings';
  static const routeName = 'settings';
  static const screenKey = Key('settings-screen');
  static const onboardingSectionKey = Key('settings-onboarding-section');
  static const goalDropdownKey = Key('settings-onboarding-goal-dropdown');
  static const experienceDropdownKey = Key(
    'settings-onboarding-experience-dropdown',
  );
  static const sessionLengthDropdownKey = Key(
    'settings-onboarding-session-length-dropdown',
  );
  static const saveOnboardingButtonKey = Key('settings-onboarding-save-button');
  static const savedSummaryKey = Key('settings-onboarding-saved-summary');

  static Key equipmentChipKey(EquipmentPreference equipment) =>
      Key('settings-onboarding-equipment-${equipment.name}');

  static Key weekdayChipKey(TrainingWeekday weekday) =>
      Key('settings-onboarding-weekday-${weekday.name}');

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final onboardingState = ref.watch(onboardingControllerProvider);

    return FeatureRootScaffold(
      key: screenKey,
      title: l10n.settingsNavigationLabel,
      icon: Icons.settings_outlined,
      child: onboardingState.when(
        data: (state) => _OnboardingPreferencesForm(
          key: ValueKey(
            state.preferences?.updatedAt.toIso8601String() ?? state.profileId,
          ),
          initialPreferences: state.preferences,
        ),
        error: (_, _) => _OnboardingLoadError(
          onRetry: () => ref.invalidate(onboardingControllerProvider),
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
      ),
    );
  }
}

class _OnboardingPreferencesForm extends ConsumerStatefulWidget {
  const _OnboardingPreferencesForm({
    required this.initialPreferences,
    super.key,
  });

  final OnboardingPreferencesRecord? initialPreferences;

  @override
  ConsumerState<_OnboardingPreferencesForm> createState() =>
      _OnboardingPreferencesFormState();
}

class _OnboardingPreferencesFormState
    extends ConsumerState<_OnboardingPreferencesForm> {
  static const _sessionLengthOptions = [30, 45, 60, 75, 90, 120];
  static const _defaultEquipment = [
    EquipmentPreference.bodyweight,
    EquipmentPreference.dumbbells,
  ];
  static const _defaultWeekdays = [
    TrainingWeekday.monday,
    TrainingWeekday.wednesday,
    TrainingWeekday.friday,
  ];

  late TrainingGoal _goal;
  late TrainingExperienceLevel _experienceLevel;
  late Set<EquipmentPreference> _equipment;
  late int _preferredSessionLengthMinutes;
  late Set<TrainingWeekday> _preferredWeekdays;
  var _isSaving = false;

  @override
  void initState() {
    super.initState();
    _readPreferences(widget.initialPreferences);
  }

  @override
  void didUpdateWidget(covariant _OnboardingPreferencesForm oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.initialPreferences != oldWidget.initialPreferences) {
      _readPreferences(widget.initialPreferences);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);

    return SingleChildScrollView(
      restorationId: 'settings-onboarding-scroll',
      keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Card(
        key: SettingsScreen.onboardingSectionKey,
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.tune_outlined, color: theme.colorScheme.primary),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: Semantics(
                      header: true,
                      child: Text(
                        l10n.onboardingTitle,
                        style: theme.textTheme.titleLarge,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(l10n.onboardingDescription),
              const SizedBox(height: AppSpacing.lg),
              _GoalField(
                value: _goal,
                onChanged: (value) => setState(() => _goal = value),
              ),
              const SizedBox(height: AppSpacing.md),
              _ExperienceField(
                value: _experienceLevel,
                onChanged: (value) {
                  setState(() => _experienceLevel = value);
                },
              ),
              const SizedBox(height: AppSpacing.md),
              Text(
                l10n.onboardingEquipmentLabel,
                style: theme.textTheme.titleSmall,
              ),
              const SizedBox(height: AppSpacing.xs),
              Wrap(
                spacing: AppSpacing.sm,
                runSpacing: AppSpacing.xs,
                children: [
                  for (final equipment in EquipmentPreference.values)
                    FilterChip(
                      key: SettingsScreen.equipmentChipKey(equipment),
                      label: Text(_equipmentLabel(l10n, equipment)),
                      selected: _equipment.contains(equipment),
                      onSelected: (selected) =>
                          _toggleEquipment(equipment, selected),
                    ),
                ],
              ),
              const SizedBox(height: AppSpacing.md),
              _SessionLengthField(
                value: _preferredSessionLengthMinutes,
                onChanged: (value) {
                  setState(() => _preferredSessionLengthMinutes = value);
                },
              ),
              const SizedBox(height: AppSpacing.md),
              Text(
                l10n.onboardingWeekdaysLabel,
                style: theme.textTheme.titleSmall,
              ),
              const SizedBox(height: AppSpacing.xs),
              Wrap(
                spacing: AppSpacing.sm,
                runSpacing: AppSpacing.xs,
                children: [
                  for (final weekday in TrainingWeekday.values)
                    FilterChip(
                      key: SettingsScreen.weekdayChipKey(weekday),
                      label: Text(_weekdayLabel(l10n, weekday)),
                      selected: _preferredWeekdays.contains(weekday),
                      onSelected: (selected) =>
                          _toggleWeekday(weekday, selected),
                    ),
                ],
              ),
              const SizedBox(height: AppSpacing.lg),
              FilledButton.icon(
                key: SettingsScreen.saveOnboardingButtonKey,
                onPressed: _isSaving ? null : _savePreferences,
                icon: _isSaving
                    ? const SizedBox.square(
                        dimension: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.save_outlined),
                label: Text(l10n.onboardingSaveButton),
              ),
              if (widget.initialPreferences != null) ...[
                const SizedBox(height: AppSpacing.md),
                _SavedOnboardingSummary(
                  preferences: widget.initialPreferences!,
                ),
                const SizedBox(height: AppSpacing.md),
                CalibrationBlockCard(preferences: widget.initialPreferences!),
                const SizedBox(height: AppSpacing.md),
                WeeklyAvailabilityEditor(
                  preferences: widget.initialPreferences!,
                ),
                const SizedBox(height: AppSpacing.md),
                GeneratedProgramCard(preferences: widget.initialPreferences!),
                const SizedBox(height: AppSpacing.md),
                MissedSessionReplacementCard(
                  preferences: widget.initialPreferences!,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _savePreferences() async {
    setState(() => _isSaving = true);
    final l10n = AppLocalizations.of(context);
    try {
      await ref
          .read(onboardingControllerProvider.notifier)
          .savePreferences(
            goal: _goal,
            experienceLevel: _experienceLevel,
            equipment: _equipment.toList(growable: false),
            preferredSessionLengthMinutes: _preferredSessionLengthMinutes,
            preferredWeekdays: _preferredWeekdays.toList(growable: false),
          );
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l10n.onboardingSavedMessage)));
    } catch (_) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l10n.onboardingSaveFailed)));
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  void _readPreferences(OnboardingPreferencesRecord? preferences) {
    _goal = preferences?.goal ?? TrainingGoal.generalFitness;
    _experienceLevel =
        preferences?.experienceLevel ?? TrainingExperienceLevel.beginner;
    _equipment = {...(preferences?.equipment ?? _defaultEquipment)};
    _preferredSessionLengthMinutes =
        preferences?.preferredSessionLengthMinutes ?? 60;
    _preferredWeekdays = {
      ...(preferences?.preferredWeekdays ?? _defaultWeekdays),
    };
  }

  void _toggleEquipment(EquipmentPreference equipment, bool selected) {
    setState(() {
      if (selected) {
        _equipment.add(equipment);
      } else if (_equipment.length > 1) {
        _equipment.remove(equipment);
      }
    });
  }

  void _toggleWeekday(TrainingWeekday weekday, bool selected) {
    setState(() {
      if (selected) {
        _preferredWeekdays.add(weekday);
      } else if (_preferredWeekdays.length > 1) {
        _preferredWeekdays.remove(weekday);
      }
    });
  }
}

class _GoalField extends StatelessWidget {
  const _GoalField({required this.value, required this.onChanged});

  final TrainingGoal value;
  final ValueChanged<TrainingGoal> onChanged;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return DropdownButtonFormField<TrainingGoal>(
      key: SettingsScreen.goalDropdownKey,
      initialValue: value,
      isExpanded: true,
      decoration: InputDecoration(labelText: l10n.onboardingGoalLabel),
      items: [
        for (final goal in TrainingGoal.values)
          DropdownMenuItem(
            value: goal,
            child: Text(
              _goalLabel(l10n, goal),
              overflow: TextOverflow.ellipsis,
            ),
          ),
      ],
      onChanged: (goal) {
        if (goal != null) {
          onChanged(goal);
        }
      },
    );
  }
}

class _ExperienceField extends StatelessWidget {
  const _ExperienceField({required this.value, required this.onChanged});

  final TrainingExperienceLevel value;
  final ValueChanged<TrainingExperienceLevel> onChanged;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return DropdownButtonFormField<TrainingExperienceLevel>(
      key: SettingsScreen.experienceDropdownKey,
      initialValue: value,
      isExpanded: true,
      decoration: InputDecoration(labelText: l10n.onboardingExperienceLabel),
      items: [
        for (final level in TrainingExperienceLevel.values)
          DropdownMenuItem(
            value: level,
            child: Text(
              _experienceLabel(l10n, level),
              overflow: TextOverflow.ellipsis,
            ),
          ),
      ],
      onChanged: (level) {
        if (level != null) {
          onChanged(level);
        }
      },
    );
  }
}

class _SessionLengthField extends StatelessWidget {
  const _SessionLengthField({required this.value, required this.onChanged});

  final int value;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return DropdownButtonFormField<int>(
      key: SettingsScreen.sessionLengthDropdownKey,
      initialValue: value,
      isExpanded: true,
      decoration: InputDecoration(labelText: l10n.onboardingSessionLengthLabel),
      items: [
        for (final minutes
            in _OnboardingPreferencesFormState._sessionLengthOptions)
          DropdownMenuItem(
            value: minutes,
            child: Text(l10n.onboardingSessionLengthValue(minutes)),
          ),
      ],
      onChanged: (minutes) {
        if (minutes != null) {
          onChanged(minutes);
        }
      },
    );
  }
}

class _SavedOnboardingSummary extends StatelessWidget {
  const _SavedOnboardingSummary({required this.preferences});

  final OnboardingPreferencesRecord preferences;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);

    final equipment = preferences.equipment
        .map((item) => _equipmentLabel(l10n, item))
        .join(', ');
    final weekdays = preferences.preferredWeekdays
        .map((item) => _weekdayLabel(l10n, item))
        .join(', ');

    return DecoratedBox(
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(AppSpacing.sm),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Text(
          l10n.onboardingSavedSummary(
            _goalLabel(l10n, preferences.goal),
            _experienceLabel(l10n, preferences.experienceLevel),
            preferences.preferredSessionLengthMinutes,
            weekdays,
            equipment,
          ),
          key: SettingsScreen.savedSummaryKey,
        ),
      ),
    );
  }
}

class _OnboardingLoadError extends StatelessWidget {
  const _OnboardingLoadError({required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(l10n.onboardingLoadError, textAlign: TextAlign.center),
            const SizedBox(height: AppSpacing.md),
            FilledButton(onPressed: onRetry, child: Text(l10n.todayRetry)),
          ],
        ),
      ),
    );
  }
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

String _experienceLabel(AppLocalizations l10n, TrainingExperienceLevel level) {
  return switch (level) {
    TrainingExperienceLevel.newToTraining =>
      l10n.onboardingExperienceNewToTraining,
    TrainingExperienceLevel.beginner => l10n.onboardingExperienceBeginner,
    TrainingExperienceLevel.intermediate =>
      l10n.onboardingExperienceIntermediate,
    TrainingExperienceLevel.advanced => l10n.onboardingExperienceAdvanced,
  };
}

String _equipmentLabel(AppLocalizations l10n, EquipmentPreference equipment) {
  return switch (equipment) {
    EquipmentPreference.bodyweight => l10n.onboardingEquipmentBodyweight,
    EquipmentPreference.dumbbells => l10n.onboardingEquipmentDumbbells,
    EquipmentPreference.barbell => l10n.onboardingEquipmentBarbell,
    EquipmentPreference.machines => l10n.onboardingEquipmentMachines,
    EquipmentPreference.cableStation => l10n.onboardingEquipmentCableStation,
    EquipmentPreference.kettlebell => l10n.onboardingEquipmentKettlebell,
    EquipmentPreference.resistanceBands =>
      l10n.onboardingEquipmentResistanceBands,
    EquipmentPreference.cardioEquipment => l10n.onboardingEquipmentCardio,
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
