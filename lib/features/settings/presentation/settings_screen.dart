import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:project_atlas/core/design_system/components/app_dashboard_card.dart';
import 'package:project_atlas/core/design_system/components/app_dense_form.dart';
import 'package:project_atlas/core/design_system/components/app_progress_ring.dart';
import 'package:project_atlas/core/design_system/components/app_status_chip.dart';
import 'package:project_atlas/core/design_system/components/feature_root_scaffold.dart';
import 'package:project_atlas/core/design_system/tokens/app_component_tokens.dart';
import 'package:project_atlas/core/design_system/tokens/app_spacing.dart';
import 'package:project_atlas/core/repositories/repository_records.dart';
import 'package:project_atlas/features/adaptive_programming/application/availability_controller.dart';
import 'package:project_atlas/features/onboarding/application/onboarding_controller.dart';
import 'package:project_atlas/l10n/generated/app_localizations.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  static const path = '/settings';
  static const routeName = 'settings';
  static const screenKey = Key('settings-screen');
  static const setupRouteCardKey = Key('settings-setup-route-card');
  static const availabilityRouteCardKey = Key(
    'settings-availability-route-card',
  );
  static const unitsRouteCardKey = Key('settings-units-route-card');
  static const privacyRouteCardKey = Key('settings-privacy-route-card');
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
  static const setupWizardKey = Key('settings-setup-wizard');
  static const setupStepBackButtonKey = Key('settings-setup-step-back');
  static const setupStepNextButtonKey = Key('settings-setup-step-next');
  static const setupStepReviewButtonKey = Key('settings-setup-step-review');

  static Key equipmentChipKey(EquipmentPreference equipment) =>
      Key('settings-onboarding-equipment-${equipment.name}');

  static Key weekdayChipKey(TrainingWeekday weekday) =>
      Key('settings-onboarding-weekday-${weekday.name}');

  static Key availabilityFixedPeriodKey(int index) =>
      Key('settings-setup-availability-fixed-$index');

  static Key availabilityFlexiblePeriodKey(int index) =>
      Key('settings-setup-availability-flexible-$index');

  static Key availabilityStartDropdownKey(int index) =>
      Key('settings-setup-availability-start-$index');

  static Key availabilityEndDropdownKey(int index) =>
      Key('settings-setup-availability-end-$index');

  static Key measurementPreferenceChipKey(String preference) =>
      Key('settings-setup-measurement-$preference');

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return FeatureRootScaffold(
      key: screenKey,
      title: l10n.settingsNavigationLabel,
      icon: Icons.settings_outlined,
      child: ListView(
        restorationId: 'settings-hub-scroll',
        padding: const EdgeInsets.all(AppSpacing.md),
        children: [
          Semantics(
            header: true,
            child: Text(
              l10n.settingsNavigationLabel,
              key: FeatureRootScaffold.placeholderTitleKey,
              style: Theme.of(context).textTheme.headlineSmall,
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            l10n.onboardingDescription,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          AppDashboardCard(
            key: setupRouteCardKey,
            title: l10n.onboardingTitle,
            subtitle: l10n.onboardingDescription,
            leadingIcon: Icons.tune_outlined,
            trailing: const Icon(Icons.chevron_right),
            onTap: () => context.go(SettingsSetupScreen.path),
          ),
          const SizedBox(height: AppSpacing.sm),
          AppDashboardCard(
            key: availabilityRouteCardKey,
            title: l10n.availabilityTitle,
            subtitle: l10n.availabilityDescription,
            leadingIcon: Icons.event_available_outlined,
            trailing: const Icon(Icons.chevron_right),
            onTap: () => context.go(SettingsSetupScreen.path),
          ),
          const SizedBox(height: AppSpacing.sm),
          AppDashboardCard(
            key: unitsRouteCardKey,
            title: l10n.onboardingSessionLengthLabel,
            subtitle: l10n.onboardingSessionLengthValue(60),
            leadingIcon: Icons.straighten_outlined,
            trailing: const Icon(Icons.chevron_right),
            onTap: () =>
                context.go(SettingsPreferencePlaceholderScreen.unitsPath),
          ),
          const SizedBox(height: AppSpacing.sm),
          AppDashboardCard(
            key: privacyRouteCardKey,
            title: l10n.progressMeasurementExportTitle,
            subtitle: l10n.progressMeasurementExportDescription,
            leadingIcon: Icons.privacy_tip_outlined,
            trailing: const Icon(Icons.chevron_right),
            onTap: () =>
                context.go(SettingsPreferencePlaceholderScreen.privacyPath),
          ),
        ],
      ),
    );
  }
}

class SettingsSetupScreen extends ConsumerWidget {
  const SettingsSetupScreen({super.key});

  static const pathSegment = 'setup';
  static const path = '${SettingsScreen.path}/$pathSegment';
  static const routeName = 'settings-setup';
  static const screenKey = Key('settings-setup-screen');

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final onboardingState = ref.watch(onboardingControllerProvider);
    final availabilityState = ref.watch(availabilityControllerProvider);

    return FeatureRootScaffold(
      key: screenKey,
      title: l10n.onboardingTitle,
      icon: Icons.tune_outlined,
      child: onboardingState.when(
        data: (onboarding) => availabilityState.when(
          data: (availability) => _SetupWizard(
            initialPreferences: onboarding.preferences,
            savedWindows: availability.windows,
          ),
          error: (_, _) => _OnboardingLoadError(
            message: l10n.availabilityLoadError,
            onRetry: () => ref.invalidate(availabilityControllerProvider),
          ),
          loading: () => Center(child: Text(l10n.availabilityLoading)),
        ),
        error: (_, _) => _OnboardingLoadError(
          onRetry: () => ref.invalidate(onboardingControllerProvider),
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
      ),
    );
  }
}

class SettingsPreferencePlaceholderScreen extends StatelessWidget {
  const SettingsPreferencePlaceholderScreen({
    required this.title,
    required this.description,
    required this.icon,
    required this.screenKey,
    super.key,
  });

  static const unitsPathSegment = 'units';
  static const unitsPath = '${SettingsScreen.path}/$unitsPathSegment';
  static const unitsRouteName = 'settings-units';
  static const privacyPathSegment = 'privacy';
  static const privacyPath = '${SettingsScreen.path}/$privacyPathSegment';
  static const privacyRouteName = 'settings-privacy';

  final String title;
  final String description;
  final IconData icon;
  final Key screenKey;

  @override
  Widget build(BuildContext context) {
    return FeatureRootScaffold(
      key: screenKey,
      title: title,
      icon: icon,
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: AppDashboardCard(
            title: title,
            subtitle: description,
            leadingIcon: icon,
          ),
        ),
      ),
    );
  }
}

const _sessionLengthOptions = [30, 45, 60, 75, 90, 120];
const _defaultStartMinute = 18 * 60;
const _timeStepMinutes = 30;
const _minutesPerDay = 24 * 60;

enum _SetupStep {
  goal,
  experience,
  equipment,
  availability,
  measurements,
  review,
}

enum _MeasurementPreference { guided, essentials, later }

class _SetupWizard extends ConsumerStatefulWidget {
  const _SetupWizard({
    required this.initialPreferences,
    required this.savedWindows,
  });

  final OnboardingPreferencesRecord? initialPreferences;
  final List<AvailabilityWindowRecord> savedWindows;

  @override
  ConsumerState<_SetupWizard> createState() => _SetupWizardState();
}

class _SetupWizardState extends ConsumerState<_SetupWizard> {
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
  late List<_AvailabilityWindowDraft> _availabilityDrafts;
  var _measurementPreference = _MeasurementPreference.guided;
  var _stepIndex = 0;
  var _isSaving = false;
  var _showSavedSummary = false;
  OnboardingPreferencesRecord? _lastSavedPreferences;

  _SetupStep get _currentStep => _SetupStep.values[_stepIndex];

  @override
  void initState() {
    super.initState();
    _readInitialSetup();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return SingleChildScrollView(
      key: SettingsScreen.setupWizardKey,
      restorationId: 'settings-setup-wizard-scroll',
      keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _WizardHeader(stepIndex: _stepIndex),
          const SizedBox(height: AppSpacing.md),
          AnimatedSwitcher(
            duration: AppMotion.fast,
            child: KeyedSubtree(
              key: ValueKey(_currentStep),
              child: _buildStepContent(context),
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          _buildFooter(l10n),
          if (_showSavedSummary && _lastSavedPreferences != null) ...[
            const SizedBox(height: AppSpacing.md),
            AppDashboardCard(
              title: l10n.setupWizardSavedStatus,
              subtitle: l10n.setupWizardSavedDescription,
              leadingIcon: Icons.check_circle_outline,
              child: _SavedOnboardingSummary(
                preferences: _lastSavedPreferences!,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildStepContent(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);

    return switch (_currentStep) {
      _SetupStep.goal => AppDenseFormSection(
        key: SettingsScreen.onboardingSectionKey,
        title: l10n.setupWizardGoalStepTitle,
        subtitle: l10n.setupWizardGoalStepDescription,
        trailing: AppStatusChip(
          label: l10n.setupWizardStepCounter(
            _stepIndex + 1,
            _SetupStep.values.length,
          ),
          tone: AppStatusTone.information,
        ),
        children: [
          _GoalField(
            value: _goal,
            onChanged: (value) => setState(() => _goal = value),
          ),
        ],
      ),
      _SetupStep.experience => AppDenseFormSection(
        title: l10n.setupWizardExperienceStepTitle,
        subtitle: l10n.setupWizardExperienceStepDescription,
        children: [
          _ExperienceField(
            value: _experienceLevel,
            onChanged: (value) {
              setState(() => _experienceLevel = value);
            },
          ),
        ],
      ),
      _SetupStep.equipment => AppDenseFormSection(
        title: l10n.setupWizardEquipmentStepTitle,
        subtitle: l10n.setupWizardEquipmentStepDescription,
        children: [
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
        ],
      ),
      _SetupStep.availability => AppDenseFormSection(
        title: l10n.setupWizardAvailabilityStepTitle,
        subtitle: l10n.setupWizardAvailabilityStepDescription,
        children: [
          _SessionLengthField(
            value: _preferredSessionLengthMinutes,
            onChanged: _setSessionLength,
          ),
          Text(l10n.onboardingWeekdaysLabel, style: theme.textTheme.titleSmall),
          Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.xs,
            children: [
              for (final weekday in TrainingWeekday.values)
                FilterChip(
                  key: SettingsScreen.weekdayChipKey(weekday),
                  label: Text(_weekdayLabel(l10n, weekday)),
                  selected: _preferredWeekdays.contains(weekday),
                  onSelected: (selected) => _toggleWeekday(weekday, selected),
                ),
            ],
          ),
          for (final (index, draft) in _availabilityDrafts.indexed)
            _AvailabilityWindowDraftRow(
              index: index,
              draft: draft,
              onTypeChanged: (windowType) {
                setState(() {
                  _availabilityDrafts[index] = draft.copyWith(
                    windowType: windowType,
                  );
                });
              },
              onStartChanged: (startMinute) {
                setState(() {
                  _availabilityDrafts[index] = draft.copyWith(
                    startMinute: startMinute,
                    endMinute: _clampedEndMinute(
                      startMinute + draft.durationMinutes,
                      startMinute,
                    ),
                  );
                });
              },
              onEndChanged: (endMinute) {
                setState(() {
                  _availabilityDrafts[index] = draft.copyWith(
                    endMinute: endMinute,
                  );
                });
              },
            ),
        ],
      ),
      _SetupStep.measurements => AppDenseFormSection(
        title: l10n.setupWizardMeasurementsStepTitle,
        subtitle: l10n.setupWizardMeasurementsStepDescription,
        children: [
          for (final preference in _MeasurementPreference.values)
            _MeasurementPreferenceCard(
              preference: preference,
              selected: _measurementPreference == preference,
              onTap: () {
                setState(() => _measurementPreference = preference);
              },
            ),
          AppStatusChip(
            label: l10n.setupWizardMeasurementPrivacyNote,
            icon: Icons.lock_outline,
            tone: AppStatusTone.information,
          ),
        ],
      ),
      _SetupStep.review => AppDenseFormSection(
        title: l10n.setupWizardReviewStepTitle,
        subtitle: l10n.setupWizardReviewStepDescription,
        children: [
          _ReviewLine(
            label: l10n.onboardingGoalLabel,
            value: _goalLabel(l10n, _goal),
          ),
          _ReviewLine(
            label: l10n.onboardingExperienceLabel,
            value: _experienceLabel(l10n, _experienceLevel),
          ),
          _ReviewLine(
            label: l10n.onboardingEquipmentLabel,
            value: _orderedEquipment(
              _equipment,
            ).map((item) => _equipmentLabel(l10n, item)).join(', '),
          ),
          _ReviewLine(
            label: l10n.availabilityTitle,
            value: l10n.setupWizardAvailabilityReview(
              _preferredWeekdays.length,
              _preferredSessionLengthMinutes,
            ),
          ),
          _ReviewLine(
            label: l10n.progressMeasurementTrendsTitle,
            value: _measurementPreferenceLabel(l10n, _measurementPreference),
          ),
        ],
      ),
    };
  }

  Widget _buildFooter(AppLocalizations l10n) {
    final isReviewStep = _currentStep == _SetupStep.review;
    final isMeasurementStep = _currentStep == _SetupStep.measurements;

    return Row(
      children: [
        if (_stepIndex > 0) ...[
          Expanded(
            child: OutlinedButton.icon(
              key: SettingsScreen.setupStepBackButtonKey,
              onPressed: _isSaving ? null : _goBack,
              icon: const Icon(Icons.arrow_back),
              label: Text(l10n.setupWizardBackButton),
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
        ],
        Expanded(
          child: FilledButton.icon(
            key: isReviewStep
                ? SettingsScreen.saveOnboardingButtonKey
                : isMeasurementStep
                ? SettingsScreen.setupStepReviewButtonKey
                : SettingsScreen.setupStepNextButtonKey,
            onPressed: _isSaving
                ? null
                : isReviewStep
                ? _saveSetup
                : _goNext,
            icon: _isSaving
                ? const SizedBox.square(
                    dimension: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : Icon(
                    isReviewStep
                        ? Icons.save_outlined
                        : Icons.arrow_forward_rounded,
                  ),
            label: Text(
              isReviewStep
                  ? l10n.setupWizardSaveButton
                  : isMeasurementStep
                  ? l10n.setupWizardReviewButton
                  : l10n.setupWizardNextButton,
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _saveSetup() async {
    setState(() => _isSaving = true);
    final l10n = AppLocalizations.of(context);
    try {
      final orderedWeekdays = _orderedWeekdays(_preferredWeekdays);
      await ref
          .read(onboardingControllerProvider.notifier)
          .savePreferences(
            goal: _goal,
            experienceLevel: _experienceLevel,
            equipment: _orderedEquipment(_equipment),
            preferredSessionLengthMinutes: _preferredSessionLengthMinutes,
            preferredWeekdays: orderedWeekdays,
          );
      await ref
          .read(availabilityControllerProvider.notifier)
          .saveWindows(
            _availabilityDrafts
                .map(
                  (draft) => AvailabilityWindowInput(
                    id: draft.id,
                    weekday: draft.weekday,
                    windowType: draft.windowType,
                    startMinute: draft.startMinute,
                    endMinute: draft.endMinute,
                    createdAt: draft.createdAt,
                  ),
                )
                .toList(growable: false),
          );
      final savedPreferences = ref
          .read(onboardingControllerProvider)
          .asData
          ?.value
          .preferences;
      if (!mounted) {
        return;
      }
      setState(() {
        _lastSavedPreferences = savedPreferences;
        _showSavedSummary = savedPreferences != null;
      });
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l10n.setupWizardSavedMessage)));
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

  void _goNext() {
    setState(() {
      _stepIndex = (_stepIndex + 1)
          .clamp(0, _SetupStep.values.length - 1)
          .toInt();
    });
  }

  void _goBack() {
    setState(() {
      _stepIndex = (_stepIndex - 1)
          .clamp(0, _SetupStep.values.length - 1)
          .toInt();
    });
  }

  void _readInitialSetup() {
    final preferences = widget.initialPreferences;
    _goal = preferences?.goal ?? TrainingGoal.generalFitness;
    _experienceLevel =
        preferences?.experienceLevel ?? TrainingExperienceLevel.beginner;
    _equipment = {...(preferences?.equipment ?? _defaultEquipment)};
    _preferredSessionLengthMinutes =
        preferences?.preferredSessionLengthMinutes ?? 60;
    final savedWindowWeekdays = widget.savedWindows
        .map((window) => window.weekday)
        .toSet();
    final initialWeekdays = savedWindowWeekdays.isNotEmpty
        ? savedWindowWeekdays
        : preferences?.preferredWeekdays ?? _defaultWeekdays;
    _preferredWeekdays = {...initialWeekdays};
    _availabilityDrafts = _initialAvailabilityDrafts();
    _lastSavedPreferences = preferences;
  }

  List<_AvailabilityWindowDraft> _initialAvailabilityDrafts() {
    final savedByWeekday = {
      for (final window in widget.savedWindows) window.weekday: window,
    };

    return [
      for (final weekday in _orderedWeekdays(_preferredWeekdays))
        if (savedByWeekday[weekday] case final savedWindow?)
          _AvailabilityWindowDraft.fromRecord(savedWindow)
        else
          _defaultAvailabilityDraft(weekday),
    ];
  }

  _AvailabilityWindowDraft _defaultAvailabilityDraft(TrainingWeekday weekday) {
    return _AvailabilityWindowDraft(
      weekday: weekday,
      windowType: AvailabilityWindowType.flexible,
      startMinute: _defaultStartMinute,
      endMinute: _clampedEndMinute(
        _defaultStartMinute + _preferredSessionLengthMinutes,
        _defaultStartMinute,
      ),
    );
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

  void _setSessionLength(int minutes) {
    final previousSessionLength = _preferredSessionLengthMinutes;
    setState(() {
      _preferredSessionLengthMinutes = minutes;
      _availabilityDrafts = [
        for (final draft in _availabilityDrafts)
          draft.durationMinutes == previousSessionLength
              ? draft.copyWith(
                  endMinute: _clampedEndMinute(
                    draft.startMinute + minutes,
                    draft.startMinute,
                  ),
                )
              : draft,
      ];
    });
  }

  void _toggleWeekday(TrainingWeekday weekday, bool selected) {
    setState(() {
      if (selected) {
        _preferredWeekdays.add(weekday);
      } else if (_preferredWeekdays.length > 1) {
        _preferredWeekdays.remove(weekday);
      }
      _syncAvailabilityDraftsWithWeekdays();
    });
  }

  void _syncAvailabilityDraftsWithWeekdays() {
    final existingByWeekday = {
      for (final draft in _availabilityDrafts) draft.weekday: draft,
    };
    _availabilityDrafts = [
      for (final weekday in _orderedWeekdays(_preferredWeekdays))
        existingByWeekday[weekday] ?? _defaultAvailabilityDraft(weekday),
    ];
  }
}

class _WizardHeader extends StatelessWidget {
  const _WizardHeader({required this.stepIndex});

  final int stepIndex;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final stepCount = _SetupStep.values.length;
    final progress = (stepIndex + 1) / stepCount;

    return AppDashboardCard(
      isProminent: true,
      title: l10n.setupWizardTitle,
      subtitle: l10n.setupWizardDescription,
      leadingIcon: Icons.tune_outlined,
      trailing: AppProgressRing(
        progress: progress,
        size: 56,
        semanticLabel: l10n.setupWizardStepCounter(stepIndex + 1, stepCount),
        center: Text(
          '${stepIndex + 1}/$stepCount',
          style: theme.textTheme.labelMedium,
        ),
      ),
      child: Wrap(
        spacing: AppSpacing.xs,
        runSpacing: AppSpacing.xs,
        children: [
          for (final (index, step) in _SetupStep.values.indexed)
            AppStatusChip(
              label: _setupStepShortLabel(l10n, step),
              icon: index < stepIndex ? Icons.check : null,
              tone: index == stepIndex
                  ? AppStatusTone.information
                  : index < stepIndex
                  ? AppStatusTone.success
                  : AppStatusTone.neutral,
            ),
        ],
      ),
    );
  }
}

class _AvailabilityWindowDraftRow extends StatelessWidget {
  const _AvailabilityWindowDraftRow({
    required this.index,
    required this.draft,
    required this.onTypeChanged,
    required this.onStartChanged,
    required this.onEndChanged,
  });

  final int index;
  final _AvailabilityWindowDraft draft;
  final ValueChanged<AvailabilityWindowType> onTypeChanged;
  final ValueChanged<int> onStartChanged;
  final ValueChanged<int> onEndChanged;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final validEndOptions = _timeOptions.where(
      (minute) => minute > draft.startMinute,
    );

    return AppDashboardCard(
      title: _weekdayLabel(l10n, draft.weekday),
      subtitle: l10n.availabilityWindowSummary(
        _availabilityWindowTypeLabel(l10n, draft.windowType),
        _formatClockMinute(draft.startMinute),
        _formatClockMinute(draft.endMinute),
      ),
      leadingIcon: Icons.schedule_outlined,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Align(
            alignment: AlignmentDirectional.centerStart,
            child: SegmentedButton<AvailabilityWindowType>(
              segments: [
                ButtonSegment(
                  value: AvailabilityWindowType.fixed,
                  label: Text(
                    l10n.availabilityFixedPeriod,
                    key: SettingsScreen.availabilityFixedPeriodKey(index),
                  ),
                ),
                ButtonSegment(
                  value: AvailabilityWindowType.flexible,
                  label: Text(
                    l10n.availabilityFlexiblePeriod,
                    key: SettingsScreen.availabilityFlexiblePeriodKey(index),
                  ),
                ),
              ],
              selected: {draft.windowType},
              onSelectionChanged: (selection) =>
                  onTypeChanged(selection.single),
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.sm,
            children: [
              SizedBox(
                width: 156,
                child: DropdownButtonFormField<int>(
                  key: SettingsScreen.availabilityStartDropdownKey(index),
                  initialValue: draft.startMinute,
                  isExpanded: true,
                  decoration: InputDecoration(
                    labelText: l10n.availabilityStartTimeLabel,
                    isDense: true,
                  ),
                  items: [
                    for (final minute in _timeOptions.where(
                      (minute) => minute < _minutesPerDay,
                    ))
                      DropdownMenuItem(
                        value: minute,
                        child: Text(_formatClockMinute(minute)),
                      ),
                  ],
                  onChanged: (value) {
                    if (value != null) {
                      onStartChanged(value);
                    }
                  },
                ),
              ),
              SizedBox(
                width: 156,
                child: DropdownButtonFormField<int>(
                  key: SettingsScreen.availabilityEndDropdownKey(index),
                  initialValue: draft.endMinute,
                  isExpanded: true,
                  decoration: InputDecoration(
                    labelText: l10n.availabilityEndTimeLabel,
                    isDense: true,
                  ),
                  items: [
                    for (final minute in validEndOptions)
                      DropdownMenuItem(
                        value: minute,
                        child: Text(_formatClockMinute(minute)),
                      ),
                  ],
                  onChanged: (value) {
                    if (value != null) {
                      onEndChanged(value);
                    }
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            l10n.setupWizardAvailabilityWindowHint,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}

class _MeasurementPreferenceCard extends StatelessWidget {
  const _MeasurementPreferenceCard({
    required this.preference,
    required this.selected,
    required this.onTap,
  });

  final _MeasurementPreference preference;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return AppDashboardCard(
      key: SettingsScreen.measurementPreferenceChipKey(preference.name),
      title: _measurementPreferenceLabel(l10n, preference),
      subtitle: _measurementPreferenceDescription(l10n, preference),
      leadingIcon: selected
          ? Icons.radio_button_checked
          : Icons.radio_button_unchecked,
      trailing: selected
          ? AppStatusChip(
              label: l10n.setupWizardSelectedStatus,
              tone: AppStatusTone.success,
              icon: Icons.check,
            )
          : null,
      onTap: onTap,
    );
  }
}

class _ReviewLine extends StatelessWidget {
  const _ReviewLine({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return DecoratedBox(
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(AppSpacing.sm),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.sm),
        child: Row(
          children: [
            Expanded(
              child: Text(
                label,
                style: theme.textTheme.labelLarge?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            Flexible(
              child: Text(
                value,
                textAlign: TextAlign.end,
                style: theme.textTheme.bodyMedium,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

final class _AvailabilityWindowDraft {
  const _AvailabilityWindowDraft({
    required this.weekday,
    required this.windowType,
    required this.startMinute,
    required this.endMinute,
    this.id,
    this.createdAt,
  });

  _AvailabilityWindowDraft.fromRecord(AvailabilityWindowRecord record)
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

  int get durationMinutes => endMinute - startMinute;

  _AvailabilityWindowDraft copyWith({
    AvailabilityWindowType? windowType,
    int? startMinute,
    int? endMinute,
  }) {
    return _AvailabilityWindowDraft(
      id: id,
      weekday: weekday,
      windowType: windowType ?? this.windowType,
      startMinute: startMinute ?? this.startMinute,
      endMinute: endMinute ?? this.endMinute,
      createdAt: createdAt,
    );
  }
}

List<int> get _timeOptions => [
  for (var minute = 0; minute <= _minutesPerDay; minute += _timeStepMinutes)
    minute,
];

List<TrainingWeekday> _orderedWeekdays(Iterable<TrainingWeekday> weekdays) {
  final weekdayIndexes = {
    for (final (index, weekday) in TrainingWeekday.values.indexed)
      weekday: index,
  };
  return weekdays.toSet().toList(growable: false)..sort(
    (left, right) => weekdayIndexes[left]!.compareTo(weekdayIndexes[right]!),
  );
}

List<EquipmentPreference> _orderedEquipment(
  Iterable<EquipmentPreference> equipment,
) {
  final equipmentIndexes = {
    for (final (index, item) in EquipmentPreference.values.indexed) item: index,
  };
  return equipment.toSet().toList(growable: false)..sort(
    (left, right) =>
        equipmentIndexes[left]!.compareTo(equipmentIndexes[right]!),
  );
}

int _clampedEndMinute(int requestedEndMinute, int startMinute) {
  return requestedEndMinute
      .clamp(startMinute + _timeStepMinutes, _minutesPerDay)
      .toInt();
}

String _formatClockMinute(int minuteOfDay) {
  final hours = minuteOfDay ~/ 60;
  final minutes = minuteOfDay % 60;
  return '${hours.toString().padLeft(2, '0')}:'
      '${minutes.toString().padLeft(2, '0')}';
}

String _availabilityWindowTypeLabel(
  AppLocalizations l10n,
  AvailabilityWindowType type,
) {
  return switch (type) {
    AvailabilityWindowType.fixed => l10n.availabilityFixedPeriod,
    AvailabilityWindowType.flexible => l10n.availabilityFlexiblePeriod,
  };
}

String _setupStepShortLabel(AppLocalizations l10n, _SetupStep step) {
  return switch (step) {
    _SetupStep.goal => l10n.setupWizardGoalStepShort,
    _SetupStep.experience => l10n.setupWizardExperienceStepShort,
    _SetupStep.equipment => l10n.setupWizardEquipmentStepShort,
    _SetupStep.availability => l10n.setupWizardAvailabilityStepShort,
    _SetupStep.measurements => l10n.setupWizardMeasurementsStepShort,
    _SetupStep.review => l10n.setupWizardReviewStepShort,
  };
}

String _measurementPreferenceLabel(
  AppLocalizations l10n,
  _MeasurementPreference preference,
) {
  return switch (preference) {
    _MeasurementPreference.guided => l10n.setupWizardMeasurementGuidedTitle,
    _MeasurementPreference.essentials =>
      l10n.setupWizardMeasurementEssentialsTitle,
    _MeasurementPreference.later => l10n.setupWizardMeasurementLaterTitle,
  };
}

String _measurementPreferenceDescription(
  AppLocalizations l10n,
  _MeasurementPreference preference,
) {
  return switch (preference) {
    _MeasurementPreference.guided =>
      l10n.setupWizardMeasurementGuidedDescription,
    _MeasurementPreference.essentials =>
      l10n.setupWizardMeasurementEssentialsDescription,
    _MeasurementPreference.later => l10n.setupWizardMeasurementLaterDescription,
  };
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
        for (final minutes in _sessionLengthOptions)
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
  const _OnboardingLoadError({required this.onRetry, this.message});

  final VoidCallback onRetry;
  final String? message;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              message ?? l10n.onboardingLoadError,
              textAlign: TextAlign.center,
            ),
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
