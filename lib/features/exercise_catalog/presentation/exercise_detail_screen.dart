import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:project_atlas/core/design_system/tokens/app_spacing.dart';
import 'package:project_atlas/features/exercise_catalog/application/exercise_catalog_provider.dart';
import 'package:project_atlas/features/exercise_catalog/domain/exercise_catalog.dart';
import 'package:project_atlas/features/exercise_catalog/presentation/exercise_thumbnail.dart';
import 'package:project_atlas/l10n/generated/app_localizations.dart';

class ExerciseDetailScreen extends ConsumerWidget {
  const ExerciseDetailScreen({required this.exerciseId, super.key});

  static const routeName = 'exercise-detail';
  static const exerciseIdParam = 'exerciseId';
  static const screenKey = Key('exercise-detail-screen');

  static Key sectionKey(String id) => Key('exercise-detail-section-$id');

  final String exerciseId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final catalogState = ref.watch(exerciseCatalogProvider);

    return catalogState.when(
      loading: () => _DetailScaffold(
        title: l10n.exerciseDetailTitle,
        child: _CenteredMessage(message: l10n.exerciseCatalogLoading),
      ),
      error: (error, stackTrace) => _DetailScaffold(
        title: l10n.exerciseDetailTitle,
        child: _CenteredMessage(message: l10n.exerciseCatalogLoadError),
      ),
      data: (catalog) {
        final exercise = catalog.exerciseById(exerciseId);
        if (exercise == null) {
          return _DetailScaffold(
            title: l10n.exerciseDetailNotFoundTitle,
            child: _NotFoundState(
              title: l10n.exerciseDetailNotFoundTitle,
              message: l10n.exerciseDetailNotFoundMessage,
            ),
          );
        }

        final localeCode = Localizations.localeOf(context).languageCode;
        return _DetailScaffold(
          title: exercise.name(localeCode),
          child: _ExerciseDetailContent(
            catalog: catalog,
            exercise: exercise,
            localeCode: localeCode,
          ),
        );
      },
    );
  }
}

class _DetailScaffold extends StatelessWidget {
  const _DetailScaffold({required this.title, required this.child});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: ExerciseDetailScreen.screenKey,
      appBar: AppBar(title: Text(title)),
      body: SafeArea(child: child),
    );
  }
}

class _ExerciseDetailContent extends StatelessWidget {
  const _ExerciseDetailContent({
    required this.catalog,
    required this.exercise,
    required this.localeCode,
  });

  final ExerciseCatalog catalog;
  final ExerciseCatalogEntry exercise;
  final String localeCode;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final substitutions = catalog.resolveExercises(
      exercise.content.substitutionIds,
    );
    final regressions = catalog.resolveExercises(
      exercise.content.regressionIds,
    );

    return ListView(
      restorationId: 'exercise-detail-scroll-${exercise.id}',
      padding: const EdgeInsets.all(AppSpacing.md),
      children: [
        Semantics(
          header: true,
          child: Text(
            exercise.name(localeCode),
            style: Theme.of(context).textTheme.headlineSmall,
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        Align(
          alignment: Alignment.centerLeft,
          child: ExerciseThumbnail(
            exercise: exercise,
            localeCode: localeCode,
            size: 96,
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        _MetadataCard(exercise: exercise, localeCode: localeCode),
        const SizedBox(height: AppSpacing.md),
        _TextSection(
          id: 'setup',
          title: l10n.exerciseDetailSetup,
          body: exercise.content.setup.resolve(localeCode),
        ),
        _TextSection(
          id: 'execution',
          title: l10n.exerciseDetailExecution,
          body: exercise.content.execution.resolve(localeCode),
        ),
        _BulletSection(
          id: 'form-cues',
          title: l10n.exerciseDetailFormCues,
          items: exercise.content.formCues.resolve(localeCode),
        ),
        _BulletSection(
          id: 'common-errors',
          title: l10n.exerciseDetailCommonErrors,
          items: exercise.content.commonErrors.resolve(localeCode),
        ),
        _ExerciseLinkSection(
          title: l10n.exerciseDetailSubstitutions,
          exercises: substitutions,
          localeCode: localeCode,
        ),
        _ExerciseLinkSection(
          title: l10n.exerciseDetailRegressions,
          exercises: regressions,
          localeCode: localeCode,
        ),
        _MuscleSection(
          title: l10n.exerciseDetailPrimaryMuscles,
          regionIds: exercise.muscleMapping.primaryRegionIds,
          catalog: catalog,
          localeCode: localeCode,
        ),
        _MuscleSection(
          title: l10n.exerciseDetailSecondaryMuscles,
          regionIds: exercise.muscleMapping.secondaryRegionIds,
          catalog: catalog,
          localeCode: localeCode,
        ),
        _MuscleSection(
          title: l10n.exerciseDetailStabilizerMuscles,
          regionIds: exercise.muscleMapping.stabilizerRegionIds,
          catalog: catalog,
          localeCode: localeCode,
        ),
      ],
    );
  }
}

class _MetadataCard extends StatelessWidget {
  const _MetadataCard({required this.exercise, required this.localeCode});

  final ExerciseCatalogEntry exercise;
  final String localeCode;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final movementAndMuscles = [
      exercise.movementPattern,
      ...exercise.muscleRegionCategories,
    ];

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Wrap(
              spacing: AppSpacing.xs,
              runSpacing: AppSpacing.xs,
              children: [
                for (final option in movementAndMuscles)
                  Chip(label: Text(option.name(localeCode))),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            _MetadataRow(
              label: l10n.exerciseDetailEquipment,
              value: exercise.equipment
                  .map((option) => option.name(localeCode))
                  .join(', '),
            ),
            _MetadataRow(
              label: l10n.exerciseDetailLevel,
              value: exercise.level.name(localeCode),
            ),
            _MetadataRow(
              label: l10n.exerciseDetailLaterality,
              value: exercise.laterality.name(localeCode),
            ),
            _MetadataRow(
              label: l10n.exerciseDetailType,
              value: exercise.exerciseType.name(localeCode),
            ),
          ],
        ),
      ),
    );
  }
}

class _MetadataRow extends StatelessWidget {
  const _MetadataRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.xs),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 104,
            child: Text(label, style: theme.textTheme.labelLarge),
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }
}

class _TextSection extends StatelessWidget {
  const _TextSection({
    required this.id,
    required this.title,
    required this.body,
  });

  final String id;
  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    return _DetailSection(
      key: ExerciseDetailScreen.sectionKey(id),
      title: title,
      child: Text(body),
    );
  }
}

class _BulletSection extends StatelessWidget {
  const _BulletSection({
    required this.id,
    required this.title,
    required this.items,
  });

  final String id;
  final String title;
  final List<String> items;

  @override
  Widget build(BuildContext context) {
    return _DetailSection(
      key: ExerciseDetailScreen.sectionKey(id),
      title: title,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (final item in items)
            Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.xs),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('•'),
                  const SizedBox(width: AppSpacing.xs),
                  Expanded(child: Text(item)),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class _ExerciseLinkSection extends StatelessWidget {
  const _ExerciseLinkSection({
    required this.title,
    required this.exercises,
    required this.localeCode,
  });

  final String title;
  final List<ExerciseCatalogEntry> exercises;
  final String localeCode;

  @override
  Widget build(BuildContext context) {
    return _DetailSection(
      title: title,
      child: Wrap(
        spacing: AppSpacing.xs,
        runSpacing: AppSpacing.xs,
        children: [
          for (final exercise in exercises)
            ActionChip(
              label: Text(exercise.name(localeCode)),
              onPressed: () => context.goNamed(
                ExerciseDetailScreen.routeName,
                pathParameters: {
                  ExerciseDetailScreen.exerciseIdParam: exercise.id,
                },
              ),
            ),
        ],
      ),
    );
  }
}

class _MuscleSection extends StatelessWidget {
  const _MuscleSection({
    required this.title,
    required this.regionIds,
    required this.catalog,
    required this.localeCode,
  });

  final String title;
  final List<String> regionIds;
  final ExerciseCatalog catalog;
  final String localeCode;

  @override
  Widget build(BuildContext context) {
    return _DetailSection(
      title: title,
      child: Wrap(
        spacing: AppSpacing.xs,
        runSpacing: AppSpacing.xs,
        children: [
          for (final regionId in regionIds)
            Chip(label: Text(catalog.muscleRegionName(regionId, localeCode))),
        ],
      ),
    );
  }
}

class _DetailSection extends StatelessWidget {
  const _DetailSection({required this.title, required this.child, super.key});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Semantics(
                header: true,
                child: Text(
                  title,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              child,
            ],
          ),
        ),
      ),
    );
  }
}

class _CenteredMessage extends StatelessWidget {
  const _CenteredMessage({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Text(message, textAlign: TextAlign.center),
      ),
    );
  }
}

class _NotFoundState extends StatelessWidget {
  const _NotFoundState({required this.title, required this.message});

  final String title;
  final String message;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.error_outline, color: theme.colorScheme.error, size: 48),
            const SizedBox(height: AppSpacing.md),
            Text(title, style: theme.textTheme.titleMedium),
            const SizedBox(height: AppSpacing.xs),
            Text(message, textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}
