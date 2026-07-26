import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:project_atlas/features/exercise_catalog/domain/exercise_catalog.dart';
import 'package:project_atlas/features/program/application/program_builder_controller.dart';
import 'package:project_atlas/l10n/generated/app_localizations.dart';

void addExerciseToProgramDraft({
  required BuildContext context,
  required WidgetRef ref,
  required ExerciseCatalogEntry exercise,
  required String localeCode,
}) {
  final l10n = AppLocalizations.of(context);
  final controller = ref.read(programBuilderControllerProvider.notifier);
  var state = ref.read(programBuilderControllerProvider);
  var createdDraft = false;

  if (!state.hasDraft || (state.draft?.isArchived ?? false)) {
    controller.createProgram(
      programName: l10n.programBuilderDefaultProgramName,
      firstDayName: l10n.programBuilderDefaultDayName(1),
    );
    state = ref.read(programBuilderControllerProvider);
    createdDraft = true;
  }

  final selectedDay = state.draft?.selectedDay;
  if (selectedDay == null) {
    return;
  }

  final exerciseName = exercise.name(localeCode);
  if (selectedDay.exerciseIds.contains(exercise.id)) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          l10n.exerciseCatalogAlreadyInProgram(exerciseName, selectedDay.name),
        ),
      ),
    );
    return;
  }

  controller.addExerciseToSelectedDay(exercise.id);
  final updatedDay =
      ref.read(programBuilderControllerProvider).draft?.selectedDay ??
      selectedDay;
  final message = createdDraft
      ? l10n.exerciseCatalogCreatedDraftAndAdded(exerciseName, updatedDay.name)
      : l10n.exerciseCatalogAddedToProgram(exerciseName, updatedDay.name);

  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
}
