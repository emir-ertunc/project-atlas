import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:project_atlas/core/design_system/tokens/app_spacing.dart';
import 'package:project_atlas/core/units/measurement_units.dart';
import 'package:project_atlas/core/units/unit_system_provider.dart';
import 'package:project_atlas/features/exercise_catalog/application/exercise_catalog_provider.dart';
import 'package:project_atlas/features/exercise_catalog/domain/exercise_catalog.dart';
import 'package:project_atlas/features/program/application/program_builder_controller.dart';
import 'package:project_atlas/features/program/domain/program_builder.dart';
import 'package:project_atlas/l10n/generated/app_localizations.dart';

class ProgramBuilderScreen extends ConsumerWidget {
  const ProgramBuilderScreen({super.key});

  static const screenKey = Key('program-builder-screen');
  static const createProgramButtonKey = Key(
    'program-builder-create-program-button',
  );
  static const programNameFieldKey = Key('program-builder-program-name-field');
  static const summaryKey = Key('program-builder-summary');
  static const lifecycleStatusKey = Key('program-builder-lifecycle-status');
  static const saveDraftButtonKey = Key('program-builder-save-draft-button');
  static const publishVersionButtonKey = Key(
    'program-builder-publish-version-button',
  );
  static const copyProgramButtonKey = Key(
    'program-builder-copy-program-button',
  );
  static const archiveProgramButtonKey = Key(
    'program-builder-archive-program-button',
  );
  static const addTrainingDayButtonKey = Key(
    'program-builder-add-training-day-button',
  );
  static const selectedDayNameKey = Key('program-builder-selected-day-name');
  static const renameSelectedDayButtonKey = Key(
    'program-builder-rename-selected-day-button',
  );
  static const deleteSelectedDayButtonKey = Key(
    'program-builder-delete-selected-day-button',
  );
  static const renameDayFieldKey = Key('program-builder-rename-day-field');
  static const addExerciseButtonKey = Key(
    'program-builder-add-exercise-button',
  );
  static const exercisePickerSearchFieldKey = Key(
    'program-builder-exercise-picker-search-field',
  );
  static const emptyDayKey = Key('program-builder-empty-day');

  static Key trainingDayChipKey(String dayId) =>
      Key('program-builder-training-day-$dayId');

  static Key exerciseRowKey(String exerciseId) =>
      Key('program-builder-exercise-row-$exerciseId');

  static Key exercisePickerOptionKey(String exerciseId) =>
      Key('program-builder-exercise-picker-option-$exerciseId');

  static Key moveExerciseUpButtonKey(String exerciseId) =>
      Key('program-builder-move-up-$exerciseId');

  static Key moveExerciseDownButtonKey(String exerciseId) =>
      Key('program-builder-move-down-$exerciseId');

  static Key removeExerciseButtonKey(String exerciseId) =>
      Key('program-builder-remove-$exerciseId');

  static Key prescriptionSummaryKey(String exerciseId) =>
      Key('program-builder-prescription-summary-$exerciseId');

  static Key setCountFieldKey(String exerciseId) =>
      Key('program-builder-set-count-$exerciseId');

  static Key fixedRepetitionModeKey(String exerciseId) =>
      Key('program-builder-fixed-repetition-mode-$exerciseId');

  static Key rangeRepetitionModeKey(String exerciseId) =>
      Key('program-builder-range-repetition-mode-$exerciseId');

  static Key fixedRepsFieldKey(String exerciseId) =>
      Key('program-builder-fixed-reps-$exerciseId');

  static Key minimumRepsFieldKey(String exerciseId) =>
      Key('program-builder-minimum-reps-$exerciseId');

  static Key maximumRepsFieldKey(String exerciseId) =>
      Key('program-builder-maximum-reps-$exerciseId');

  static Key targetRirSwitchKey(String exerciseId) =>
      Key('program-builder-target-rir-switch-$exerciseId');

  static Key targetRirFieldKey(String exerciseId) =>
      Key('program-builder-target-rir-$exerciseId');

  static Key loadFieldKey(String exerciseId) =>
      Key('program-builder-load-$exerciseId');

  static Key restSecondsFieldKey(String exerciseId) =>
      Key('program-builder-rest-seconds-$exerciseId');

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final state = ref.watch(programBuilderControllerProvider);
    final controller = ref.read(programBuilderControllerProvider.notifier);

    if (!state.hasDraft) {
      return _BuilderEmptyState(
        onCreate: () => controller.createProgram(
          programName: l10n.programBuilderDefaultProgramName,
          firstDayName: l10n.programBuilderDefaultDayName(1),
        ),
      );
    }

    final draft = state.draft!;
    final selectedDay = draft.selectedDay!;
    final catalogState = ref.watch(exerciseCatalogProvider);
    final catalog = catalogState.maybeWhen(
      data: (catalog) => catalog,
      orElse: () => null,
    );
    final localeCode = Localizations.localeOf(context).languageCode;

    return SingleChildScrollView(
      key: screenKey,
      restorationId: 'program-builder-scroll',
      keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _ScopeCard(draft: draft),
          const SizedBox(height: AppSpacing.md),
          _ProgramLifecycleActions(
            draft: draft,
            onSaveDraft: () => _runLifecycleAction(
              context: context,
              action: controller.saveDraftSnapshot,
              successMessage: l10n.programBuilderDraftSaved,
            ),
            onPublishVersion: () => _runLifecycleAction(
              context: context,
              action: controller.publishImmutableVersion,
              successMessage: l10n.programBuilderVersionPublished,
            ),
            onCopyProgram: () {
              controller.copyDraft(
                l10n.programBuilderCopiedProgramName(draft.name),
              );
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(l10n.programBuilderProgramCopied)),
              );
            },
            onArchiveProgram: draft.isPersisted && !draft.isArchived
                ? () => _runLifecycleAction(
                    context: context,
                    action: controller.archiveProgram,
                    successMessage: l10n.programBuilderProgramArchived,
                  )
                : null,
          ),
          const SizedBox(height: AppSpacing.md),
          TextFormField(
            key: programNameFieldKey,
            initialValue: draft.name,
            decoration: InputDecoration(
              labelText: l10n.programBuilderProgramNameLabel,
              prefixIcon: const Icon(Icons.edit_outlined),
            ),
            textInputAction: TextInputAction.done,
            onChanged: controller.renameProgram,
          ),
          const SizedBox(height: AppSpacing.lg),
          _TrainingDayEditor(
            state: state,
            draft: draft,
            selectedDay: selectedDay,
            onAddDay: () => controller.addTrainingDay(
              l10n.programBuilderDefaultDayName(state.nextDayNumber),
            ),
            onSelectDay: controller.selectTrainingDay,
            onRenameDay: () => _showRenameDayDialog(
              context: context,
              ref: ref,
              day: selectedDay,
            ),
            onDeleteDay: draft.trainingDays.length <= 1
                ? null
                : () => controller.deleteTrainingDay(selectedDay.id),
          ),
          const SizedBox(height: AppSpacing.lg),
          _SelectedDayExercises(
            catalog: catalog,
            selectedDay: selectedDay,
            localeCode: localeCode,
            onAddExercise: catalog == null
                ? null
                : () => _showExercisePicker(
                    context: context,
                    ref: ref,
                    catalog: catalog,
                    selectedDay: selectedDay,
                    localeCode: localeCode,
                  ),
          ),
        ],
      ),
    );
  }

  Future<void> _showRenameDayDialog({
    required BuildContext context,
    required WidgetRef ref,
    required ProgramTrainingDay day,
  }) async {
    final l10n = AppLocalizations.of(context);
    var dayName = day.name;

    await showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(l10n.programBuilderRenameDayTitle),
        content: TextFormField(
          key: renameDayFieldKey,
          initialValue: day.name,
          autofocus: true,
          decoration: InputDecoration(
            labelText: l10n.programBuilderDayNameLabel,
          ),
          textInputAction: TextInputAction.done,
          onChanged: (value) => dayName = value,
          onFieldSubmitted: (_) {
            ref
                .read(programBuilderControllerProvider.notifier)
                .renameTrainingDay(day.id, dayName);
            Navigator.of(dialogContext).pop();
          },
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: Text(l10n.programBuilderCancel),
          ),
          FilledButton(
            onPressed: () {
              ref
                  .read(programBuilderControllerProvider.notifier)
                  .renameTrainingDay(day.id, dayName);
              Navigator.of(dialogContext).pop();
            },
            child: Text(l10n.programBuilderSave),
          ),
        ],
      ),
    );
  }

  Future<void> _showExercisePicker({
    required BuildContext context,
    required WidgetRef ref,
    required ExerciseCatalog catalog,
    required ProgramTrainingDay selectedDay,
    required String localeCode,
  }) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (sheetContext) => _ExercisePickerSheet(
        catalog: catalog,
        alreadyAddedExerciseIds: selectedDay.exerciseIds.toSet(),
        localeCode: localeCode,
        onSelected: (exerciseId) {
          ref
              .read(programBuilderControllerProvider.notifier)
              .addExerciseToSelectedDay(exerciseId);
          Navigator.of(sheetContext).pop();
        },
      ),
    );
  }

  Future<void> _runLifecycleAction({
    required BuildContext context,
    required Future<void> Function() action,
    required String successMessage,
  }) async {
    final l10n = AppLocalizations.of(context);

    try {
      await action();
      if (!context.mounted) {
        return;
      }
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(successMessage)));
    } catch (_) {
      if (!context.mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.programBuilderPersistenceFailed)),
      );
    }
  }
}

class _BuilderEmptyState extends StatelessWidget {
  const _BuilderEmptyState({required this.onCreate});

  final VoidCallback onCreate;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);

    return LayoutBuilder(
      builder: (context, constraints) => SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: ConstrainedBox(
          constraints: BoxConstraints(minHeight: constraints.maxHeight),
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.view_week_outlined,
                  color: theme.colorScheme.primary,
                  size: 56,
                ),
                const SizedBox(height: AppSpacing.md),
                Text(
                  l10n.programBuilderEmptyTitle,
                  style: theme.textTheme.headlineSmall,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  l10n.programBuilderEmptyMessage,
                  style: theme.textTheme.bodyMedium,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: AppSpacing.lg),
                FilledButton.icon(
                  key: ProgramBuilderScreen.createProgramButtonKey,
                  onPressed: onCreate,
                  icon: const Icon(Icons.add),
                  label: Text(l10n.programBuilderCreateProgram),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ScopeCard extends StatelessWidget {
  const _ScopeCard({required this.draft});

  final ProgramDraft draft;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.edit_calendar_outlined,
                  color: theme.colorScheme.primary,
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Text(
                    l10n.programBuilderLocalDraftLabel,
                    style: theme.textTheme.titleMedium,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              l10n.programBuilderSummary(
                draft.trainingDays.length,
                draft.exerciseCount,
              ),
              key: ProgramBuilderScreen.summaryKey,
              style: theme.textTheme.labelLarge,
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              _lifecycleStatus(l10n, draft),
              key: ProgramBuilderScreen.lifecycleStatusKey,
              style: theme.textTheme.labelMedium,
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(l10n.programBuilderScopeNote),
          ],
        ),
      ),
    );
  }
}

class _ProgramLifecycleActions extends StatelessWidget {
  const _ProgramLifecycleActions({
    required this.draft,
    required this.onSaveDraft,
    required this.onPublishVersion,
    required this.onCopyProgram,
    required this.onArchiveProgram,
  });

  final ProgramDraft draft;
  final VoidCallback onSaveDraft;
  final VoidCallback onPublishVersion;
  final VoidCallback onCopyProgram;
  final VoidCallback? onArchiveProgram;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final isArchived = draft.isArchived;

    return Wrap(
      spacing: AppSpacing.sm,
      runSpacing: AppSpacing.sm,
      children: [
        FilledButton.icon(
          key: ProgramBuilderScreen.saveDraftButtonKey,
          onPressed: isArchived ? null : onSaveDraft,
          icon: const Icon(Icons.save_outlined),
          label: Text(l10n.programBuilderSaveDraft),
        ),
        FilledButton.tonalIcon(
          key: ProgramBuilderScreen.publishVersionButtonKey,
          onPressed: isArchived ? null : onPublishVersion,
          icon: const Icon(Icons.verified_outlined),
          label: Text(l10n.programBuilderPublishVersion),
        ),
        OutlinedButton.icon(
          key: ProgramBuilderScreen.copyProgramButtonKey,
          onPressed: onCopyProgram,
          icon: const Icon(Icons.copy_outlined),
          label: Text(l10n.programBuilderCopyProgram),
        ),
        OutlinedButton.icon(
          key: ProgramBuilderScreen.archiveProgramButtonKey,
          onPressed: onArchiveProgram,
          icon: const Icon(Icons.archive_outlined),
          label: Text(l10n.programBuilderArchiveProgram),
        ),
      ],
    );
  }
}

String _lifecycleStatus(AppLocalizations l10n, ProgramDraft draft) {
  return switch (draft.lifecycle) {
    ProgramDraftLifecycle.local => l10n.programBuilderLifecycleStatusLocal,
    ProgramDraftLifecycle.savedDraft => l10n.programBuilderLifecycleStatusSaved(
      draft.latestVersionNumber,
    ),
    ProgramDraftLifecycle.published =>
      l10n.programBuilderLifecycleStatusPublished(draft.latestVersionNumber),
    ProgramDraftLifecycle.archived =>
      l10n.programBuilderLifecycleStatusArchived(draft.latestVersionNumber),
  };
}

class _TrainingDayEditor extends StatelessWidget {
  const _TrainingDayEditor({
    required this.state,
    required this.draft,
    required this.selectedDay,
    required this.onAddDay,
    required this.onSelectDay,
    required this.onRenameDay,
    required this.onDeleteDay,
  });

  final ProgramBuilderState state;
  final ProgramDraft draft;
  final ProgramTrainingDay selectedDay;
  final VoidCallback onAddDay;
  final ValueChanged<String> onSelectDay;
  final VoidCallback onRenameDay;
  final VoidCallback? onDeleteDay;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Semantics(
                    header: true,
                    child: Text(
                      l10n.programBuilderTrainingDays,
                      style: theme.textTheme.titleMedium,
                    ),
                  ),
                ),
                TextButton.icon(
                  key: ProgramBuilderScreen.addTrainingDayButtonKey,
                  onPressed: onAddDay,
                  icon: const Icon(Icons.add),
                  label: Text(l10n.programBuilderAddTrainingDay),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  for (final day in draft.trainingDays) ...[
                    ChoiceChip(
                      key: ProgramBuilderScreen.trainingDayChipKey(day.id),
                      label: Text(day.name),
                      selected: day.id == selectedDay.id,
                      onSelected: (_) => onSelectDay(day.id),
                    ),
                    const SizedBox(width: AppSpacing.xs),
                  ],
                ],
              ),
            ),
            const Divider(),
            Text(
              l10n.programBuilderSelectedDay,
              style: theme.textTheme.labelLarge,
            ),
            const SizedBox(height: AppSpacing.xs),
            Row(
              children: [
                Expanded(
                  child: Text(
                    selectedDay.name,
                    key: ProgramBuilderScreen.selectedDayNameKey,
                    style: theme.textTheme.titleLarge,
                  ),
                ),
                IconButton(
                  key: ProgramBuilderScreen.renameSelectedDayButtonKey,
                  tooltip: l10n.programBuilderRenameDay,
                  onPressed: onRenameDay,
                  icon: const Icon(Icons.edit_outlined),
                ),
                IconButton(
                  key: ProgramBuilderScreen.deleteSelectedDayButtonKey,
                  tooltip: l10n.programBuilderDeleteDay,
                  onPressed: onDeleteDay,
                  icon: const Icon(Icons.delete_outline),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _SelectedDayExercises extends ConsumerWidget {
  const _SelectedDayExercises({
    required this.catalog,
    required this.selectedDay,
    required this.localeCode,
    required this.onAddExercise,
  });

  final ExerciseCatalog? catalog;
  final ProgramTrainingDay selectedDay;
  final String localeCode;
  final VoidCallback? onAddExercise;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final controller = ref.read(programBuilderControllerProvider.notifier);
    final unitSystem = ref.watch(unitSystemProvider);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Semantics(
                    header: true,
                    child: Text(
                      selectedDay.name,
                      style: theme.textTheme.titleMedium,
                    ),
                  ),
                ),
                FilledButton.icon(
                  key: ProgramBuilderScreen.addExerciseButtonKey,
                  onPressed: onAddExercise,
                  icon: const Icon(Icons.add),
                  label: Text(l10n.programBuilderAddExercise),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            if (selectedDay.exerciseIds.isEmpty)
              _EmptyDayState()
            else
              ReorderableListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                buildDefaultDragHandles: false,
                onReorderItem: (oldIndex, newIndex) {
                  controller.moveExercise(
                    dayId: selectedDay.id,
                    fromIndex: oldIndex,
                    toIndex: newIndex,
                  );
                },
                itemBuilder: (context, index) {
                  final prescription = selectedDay.exercisePrescriptions[index];
                  final exerciseId = prescription.exerciseId;
                  final exercise = catalog?.exerciseById(exerciseId);
                  return _ExerciseOrderTile(
                    key: ValueKey('${selectedDay.id}-$exerciseId'),
                    dayId: selectedDay.id,
                    exerciseId: exerciseId,
                    exercise: exercise,
                    prescription: prescription,
                    unitSystem: unitSystem,
                    localeCode: localeCode,
                    index: index,
                    totalCount: selectedDay.exerciseIds.length,
                    onMoveUp: index == 0
                        ? null
                        : () => controller.moveExercise(
                            dayId: selectedDay.id,
                            fromIndex: index,
                            toIndex: index - 1,
                          ),
                    onMoveDown: index == selectedDay.exerciseIds.length - 1
                        ? null
                        : () => controller.moveExercise(
                            dayId: selectedDay.id,
                            fromIndex: index,
                            toIndex: index + 1,
                          ),
                    onRemove: () =>
                        controller.removeExercise(selectedDay.id, exerciseId),
                  );
                },
                itemCount: selectedDay.exerciseIds.length,
              ),
          ],
        ),
      ),
    );
  }
}

class _EmptyDayState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);

    return Container(
      key: ProgramBuilderScreen.emptyDayKey,
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerLow,
        borderRadius: AppRadii.large,
      ),
      child: Column(
        children: [
          Icon(
            Icons.playlist_add,
            color: theme.colorScheme.onSurfaceVariant,
            size: 48,
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            l10n.programBuilderEmptyDayTitle,
            style: theme.textTheme.titleMedium,
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(l10n.programBuilderEmptyDayMessage, textAlign: TextAlign.center),
        ],
      ),
    );
  }
}

class _ExerciseOrderTile extends ConsumerWidget {
  const _ExerciseOrderTile({
    required this.dayId,
    required this.exerciseId,
    required this.exercise,
    required this.prescription,
    required this.unitSystem,
    required this.localeCode,
    required this.index,
    required this.totalCount,
    required this.onMoveUp,
    required this.onMoveDown,
    required this.onRemove,
    super.key,
  });

  final String dayId;
  final String exerciseId;
  final ExerciseCatalogEntry? exercise;
  final ProgramExercisePrescription prescription;
  final UnitSystem unitSystem;
  final String localeCode;
  final int index;
  final int totalCount;
  final VoidCallback? onMoveUp;
  final VoidCallback? onMoveDown;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final controller = ref.read(programBuilderControllerProvider.notifier);
    final title =
        exercise?.name(localeCode) ?? humanizeCatalogIdentifier(exerciseId);
    final subtitle = exercise == null
        ? exerciseId
        : exercise!.movementPattern.name(localeCode);
    final loadUnit = unitSystem.massUnit;

    return Padding(
      key: ProgramBuilderScreen.exerciseRowKey(exerciseId),
      padding: EdgeInsets.only(
        bottom: index == totalCount - 1 ? AppSpacing.none : AppSpacing.sm,
      ),
      child: Card(
        child: Column(
          children: [
            ListTile(
              leading: ReorderableDragStartListener(
                index: index,
                child: const Icon(Icons.drag_indicator),
              ),
              title: Text(title),
              subtitle: Text(subtitle),
              trailing: Wrap(
                spacing: AppSpacing.xxs,
                children: [
                  IconButton(
                    key: ProgramBuilderScreen.moveExerciseUpButtonKey(
                      exerciseId,
                    ),
                    tooltip: l10n.programBuilderMoveExerciseUp,
                    onPressed: onMoveUp,
                    icon: const Icon(Icons.keyboard_arrow_up),
                  ),
                  IconButton(
                    key: ProgramBuilderScreen.moveExerciseDownButtonKey(
                      exerciseId,
                    ),
                    tooltip: l10n.programBuilderMoveExerciseDown,
                    onPressed: onMoveDown,
                    icon: const Icon(Icons.keyboard_arrow_down),
                  ),
                  IconButton(
                    key: ProgramBuilderScreen.removeExerciseButtonKey(
                      exerciseId,
                    ),
                    tooltip: l10n.programBuilderRemoveExercise,
                    onPressed: onRemove,
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.md,
                AppSpacing.none,
                AppSpacing.md,
                AppSpacing.md,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _prescriptionSummary(
                      l10n: l10n,
                      prescription: prescription,
                      massUnit: loadUnit,
                    ),
                    key: ProgramBuilderScreen.prescriptionSummaryKey(
                      exerciseId,
                    ),
                    style: theme.textTheme.labelLarge,
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Wrap(
                    spacing: AppSpacing.sm,
                    runSpacing: AppSpacing.sm,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      _NumberField(
                        key: ProgramBuilderScreen.setCountFieldKey(exerciseId),
                        initialValue: prescription.setCount.toString(),
                        label: l10n.programBuilderSetCountLabel,
                        onChanged: (value) {
                          final parsed = int.tryParse(value);
                          if (parsed == null) {
                            return;
                          }
                          controller.updateSetCount(
                            dayId: dayId,
                            exerciseId: exerciseId,
                            setCount: parsed,
                          );
                        },
                      ),
                      SegmentedButton<ProgramRepetitionMode>(
                        segments: [
                          ButtonSegment(
                            value: ProgramRepetitionMode.fixed,
                            label: Text(
                              l10n.programBuilderFixedRepetitionMode,
                              key: ProgramBuilderScreen.fixedRepetitionModeKey(
                                exerciseId,
                              ),
                            ),
                          ),
                          ButtonSegment(
                            value: ProgramRepetitionMode.range,
                            label: Text(
                              l10n.programBuilderRangeRepetitionMode,
                              key: ProgramBuilderScreen.rangeRepetitionModeKey(
                                exerciseId,
                              ),
                            ),
                          ),
                        ],
                        selected: {prescription.repetitionMode},
                        onSelectionChanged: (selection) {
                          controller.setRepetitionMode(
                            dayId: dayId,
                            exerciseId: exerciseId,
                            mode: selection.single,
                          );
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Wrap(
                    spacing: AppSpacing.sm,
                    runSpacing: AppSpacing.sm,
                    children: [
                      if (prescription.repetitionMode ==
                          ProgramRepetitionMode.fixed)
                        _NumberField(
                          key: ProgramBuilderScreen.fixedRepsFieldKey(
                            exerciseId,
                          ),
                          initialValue: prescription.minimumRepetitions
                              .toString(),
                          label: l10n.programBuilderFixedRepsLabel,
                          onChanged: (value) {
                            final parsed = int.tryParse(value);
                            if (parsed == null) {
                              return;
                            }
                            controller.updateFixedRepetitions(
                              dayId: dayId,
                              exerciseId: exerciseId,
                              repetitions: parsed,
                            );
                          },
                        )
                      else ...[
                        _NumberField(
                          key: ProgramBuilderScreen.minimumRepsFieldKey(
                            exerciseId,
                          ),
                          initialValue: prescription.minimumRepetitions
                              .toString(),
                          label: l10n.programBuilderMinimumRepsLabel,
                          onChanged: (value) {
                            final parsed = int.tryParse(value);
                            if (parsed == null) {
                              return;
                            }
                            controller.updateMinimumRepetitions(
                              dayId: dayId,
                              exerciseId: exerciseId,
                              minimumRepetitions: parsed,
                            );
                          },
                        ),
                        _NumberField(
                          key: ProgramBuilderScreen.maximumRepsFieldKey(
                            exerciseId,
                          ),
                          initialValue: prescription.maximumRepetitions
                              .toString(),
                          label: l10n.programBuilderMaximumRepsLabel,
                          onChanged: (value) {
                            final parsed = int.tryParse(value);
                            if (parsed == null) {
                              return;
                            }
                            controller.updateMaximumRepetitions(
                              dayId: dayId,
                              exerciseId: exerciseId,
                              maximumRepetitions: parsed,
                            );
                          },
                        ),
                      ],
                      _NumberField(
                        key: ProgramBuilderScreen.loadFieldKey(exerciseId),
                        initialValue: _formatLoadInput(
                          prescription.loadKilograms,
                          loadUnit,
                        ),
                        label: l10n.programBuilderLoadLabel,
                        suffixText: loadUnit.symbol,
                        allowDecimal: true,
                        onChanged: (value) {
                          controller.updateLoadKilograms(
                            dayId: dayId,
                            exerciseId: exerciseId,
                            loadKilograms: _parseLoadKilograms(value, loadUnit),
                          );
                        },
                      ),
                      _NumberField(
                        key: ProgramBuilderScreen.restSecondsFieldKey(
                          exerciseId,
                        ),
                        initialValue: prescription.restSeconds.toString(),
                        label: l10n.programBuilderRestSecondsLabel,
                        suffixText: l10n.programBuilderSecondsSuffix,
                        onChanged: (value) {
                          final parsed = int.tryParse(value);
                          if (parsed == null) {
                            return;
                          }
                          controller.updateRestSeconds(
                            dayId: dayId,
                            exerciseId: exerciseId,
                            restSeconds: parsed,
                          );
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  SwitchListTile(
                    key: ProgramBuilderScreen.targetRirSwitchKey(exerciseId),
                    contentPadding: EdgeInsets.zero,
                    title: Text(l10n.programBuilderTargetRirEnabled),
                    subtitle: Text(l10n.programBuilderTargetRirDescription),
                    value: prescription.hasTargetRir,
                    onChanged: (enabled) {
                      controller.updateTargetRirEnabled(
                        dayId: dayId,
                        exerciseId: exerciseId,
                        enabled: enabled,
                      );
                    },
                  ),
                  if (prescription.hasTargetRir)
                    _NumberField(
                      key: ProgramBuilderScreen.targetRirFieldKey(exerciseId),
                      initialValue: prescription.targetRir.toString(),
                      label: l10n.programBuilderTargetRirLabel,
                      onChanged: (value) {
                        final parsed = int.tryParse(value);
                        if (parsed == null) {
                          return;
                        }
                        controller.updateTargetRir(
                          dayId: dayId,
                          exerciseId: exerciseId,
                          targetRir: parsed,
                        );
                      },
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _NumberField extends StatelessWidget {
  const _NumberField({
    required this.initialValue,
    required this.label,
    required this.onChanged,
    this.suffixText,
    this.allowDecimal = false,
    super.key,
  });

  final String initialValue;
  final String label;
  final String? suffixText;
  final bool allowDecimal;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 128,
      child: TextFormField(
        initialValue: initialValue,
        decoration: InputDecoration(labelText: label, suffixText: suffixText),
        keyboardType: TextInputType.numberWithOptions(decimal: allowDecimal),
        textInputAction: TextInputAction.done,
        onChanged: onChanged,
      ),
    );
  }
}

String _prescriptionSummary({
  required AppLocalizations l10n,
  required ProgramExercisePrescription prescription,
  required MassUnit massUnit,
}) {
  final repetitionTarget =
      prescription.repetitionMode == ProgramRepetitionMode.fixed
      ? l10n.programBuilderFixedRepsSummary(prescription.minimumRepetitions)
      : l10n.programBuilderRangeRepsSummary(
          prescription.minimumRepetitions,
          prescription.maximumRepetitions,
        );
  final rirTarget = prescription.targetRir == null
      ? l10n.programBuilderRirOff
      : l10n.programBuilderRirSummary(prescription.targetRir!);
  final loadTarget = prescription.loadKilograms == null
      ? l10n.programBuilderLoadUnset
      : '${_formatLoadInput(prescription.loadKilograms, massUnit)} '
            '${massUnit.symbol}';

  return l10n.programBuilderPrescriptionSummary(
    prescription.setCount,
    repetitionTarget,
    rirTarget,
    loadTarget,
    prescription.restSeconds,
  );
}

String _formatLoadInput(double? loadKilograms, MassUnit massUnit) {
  if (loadKilograms == null) {
    return '';
  }

  final displayValue = Mass.kilograms(loadKilograms).inUnit(massUnit);
  final fixed = displayValue.toStringAsFixed(1);
  return fixed.endsWith('.0') ? displayValue.toStringAsFixed(0) : fixed;
}

double? _parseLoadKilograms(String value, MassUnit massUnit) {
  final trimmed = value.trim();
  if (trimmed.isEmpty) {
    return null;
  }

  final parsed = double.tryParse(trimmed.replaceAll(',', '.'));
  if (parsed == null) {
    return null;
  }
  final nonNegative = parsed < 0 ? 0.0 : parsed;

  return switch (massUnit) {
    MassUnit.kilogram => nonNegative,
    MassUnit.pound => nonNegative * Mass.kilogramsPerPound,
  };
}

class _ExercisePickerSheet extends StatefulWidget {
  const _ExercisePickerSheet({
    required this.catalog,
    required this.alreadyAddedExerciseIds,
    required this.localeCode,
    required this.onSelected,
  });

  final ExerciseCatalog catalog;
  final Set<String> alreadyAddedExerciseIds;
  final String localeCode;
  final ValueChanged<String> onSelected;

  @override
  State<_ExercisePickerSheet> createState() => _ExercisePickerSheetState();
}

class _ExercisePickerSheetState extends State<_ExercisePickerSheet> {
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final results = widget.catalog.query(
      localeCode: widget.localeCode,
      searchTerm: _searchController.text,
    );

    return SizedBox(
      height: MediaQuery.sizeOf(context).height * 0.86,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.programBuilderExercisePickerTitle,
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: AppSpacing.md),
                TextField(
                  key: ProgramBuilderScreen.exercisePickerSearchFieldKey,
                  controller: _searchController,
                  autofocus: true,
                  decoration: InputDecoration(
                    labelText: l10n.programBuilderExercisePickerSearchLabel,
                    hintText: l10n.programBuilderExercisePickerSearchHint,
                    prefixIcon: const Icon(Icons.search),
                  ),
                  onChanged: (_) => setState(() {}),
                ),
              ],
            ),
          ),
          const Divider(height: AppSpacing.none),
          Expanded(
            child: results.isEmpty
                ? Center(child: Text(l10n.programBuilderExercisePickerEmpty))
                : ListView.separated(
                    itemBuilder: (context, index) {
                      final exercise = results[index];
                      final isAdded = widget.alreadyAddedExerciseIds.contains(
                        exercise.id,
                      );
                      return ListTile(
                        key: ProgramBuilderScreen.exercisePickerOptionKey(
                          exercise.id,
                        ),
                        title: Text(exercise.name(widget.localeCode)),
                        subtitle: Text(
                          exercise.movementPattern.name(widget.localeCode),
                        ),
                        trailing: isAdded
                            ? Text(l10n.programBuilderExerciseAlreadyAdded)
                            : const Icon(Icons.add),
                        enabled: !isAdded,
                        onTap: isAdded
                            ? null
                            : () => widget.onSelected(exercise.id),
                      );
                    },
                    separatorBuilder: (context, index) => const Divider(
                      height: AppSpacing.none,
                      indent: AppSpacing.md,
                      endIndent: AppSpacing.md,
                    ),
                    itemCount: results.length,
                  ),
          ),
        ],
      ),
    );
  }
}
