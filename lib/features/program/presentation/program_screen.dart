import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:project_atlas/core/design_system/components/app_dashboard_card.dart';
import 'package:project_atlas/core/design_system/components/app_status_chip.dart';
import 'package:project_atlas/core/design_system/components/feature_root_scaffold.dart';
import 'package:project_atlas/core/design_system/tokens/app_spacing.dart';
import 'package:project_atlas/core/repositories/repository_contracts.dart';
import 'package:project_atlas/core/repositories/repository_providers.dart';
import 'package:project_atlas/core/repositories/repository_records.dart';
import 'package:project_atlas/features/exercise_catalog/application/exercise_catalog_provider.dart';
import 'package:project_atlas/features/exercise_catalog/domain/exercise_catalog.dart';
import 'package:project_atlas/features/exercise_catalog/presentation/exercise_catalog_screen.dart';
import 'package:project_atlas/features/program/application/program_draft_persistence.dart';
import 'package:project_atlas/features/program/presentation/program_builder_screen.dart';
import 'package:project_atlas/l10n/generated/app_localizations.dart';

final _programHubStateProvider = StreamProvider.autoDispose<_ProgramHubState>((
  ref,
) async* {
  final profileId = ref.watch(localProgramProfileIdProvider);
  final repository = ref.watch(programRepositoryProvider);

  await for (final programs in repository.watchPrograms(profileId)) {
    yield await _buildProgramHubState(repository, programs);
  }
});

class ProgramScreen extends ConsumerWidget {
  const ProgramScreen({super.key});

  static const path = '/program';
  static const routeName = 'program';
  static const screenKey = Key('program-screen');
  static const activePlanOverviewKey = Key('program-active-plan-overview');
  static const emptyStateKey = Key('program-empty-state');
  static const builderTabKey = Key('program-builder-tab');
  static const catalogTabKey = Key('program-catalog-tab');
  static const recommendationInboxRouteCardKey = Key(
    'program-recommendation-inbox-route-card',
  );
  static const trainingDaysSectionKey = Key('program-training-days-section');

  static Key trainingDayCardKey(int trainingDayOrder) =>
      Key('program-training-day-card-$trainingDayOrder');

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final hubState = ref.watch(_programHubStateProvider);
    final catalog = ref
        .watch(exerciseCatalogProvider)
        .maybeWhen(data: (catalog) => catalog, orElse: () => null);

    return FeatureRootScaffold(
      key: screenKey,
      title: l10n.programNavigationLabel,
      icon: Icons.calendar_view_week_outlined,
      child: hubState.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stackTrace) => _ProgramHubErrorState(
          onRetry: () => ref.invalidate(_programHubStateProvider),
        ),
        data: (state) => _ProgramHubContent(state: state, catalog: catalog),
      ),
    );
  }
}

class _ProgramHubContent extends StatelessWidget {
  const _ProgramHubContent({required this.state, required this.catalog});

  final _ProgramHubState state;
  final ExerciseCatalog? catalog;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final activePlan = state.activePlan;

    return ListView(
      restorationId: 'program-hub-scroll',
      padding: const EdgeInsets.all(AppSpacing.md),
      children: [
        Semantics(
          header: true,
          child: Text(
            l10n.programNavigationLabel,
            key: FeatureRootScaffold.placeholderTitleKey,
            style: theme.textTheme.headlineSmall,
          ),
        ),
        const SizedBox(height: AppSpacing.xs),
        Text(
          l10n.programHubSubtitle,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        if (activePlan == null)
          const _ProgramEmptyStateCard()
        else
          _ActivePlanOverviewCard(activePlan: activePlan),
        const SizedBox(height: AppSpacing.sm),
        const _ProgramHubRouteCards(),
        if (activePlan != null) ...[
          const SizedBox(height: AppSpacing.md),
          _TrainingDayCards(activePlan: activePlan, catalog: catalog),
        ],
      ],
    );
  }
}

class _ProgramEmptyStateCard extends StatelessWidget {
  const _ProgramEmptyStateCard();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return AppDashboardCard(
      key: ProgramScreen.emptyStateKey,
      title: l10n.programHubNoActiveProgramTitle,
      subtitle: l10n.programHubNoActiveProgramMessage,
      leadingIcon: Icons.add_task_outlined,
      isProminent: true,
      child: FilledButton.icon(
        onPressed: () => context.go(ProgramBuilderRouteScreen.path),
        icon: const Icon(Icons.add),
        label: Text(l10n.programHubCreateDraft),
      ),
    );
  }
}

class _ActivePlanOverviewCard extends StatelessWidget {
  const _ActivePlanOverviewCard({required this.activePlan});

  final _ProgramHubActivePlan activePlan;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return AppDashboardCard(
      key: ProgramScreen.activePlanOverviewKey,
      title: activePlan.program.name,
      subtitle: l10n.programHubActiveVersionSummary(
        activePlan.version.versionNumber,
        activePlan.dayCount,
      ),
      leadingIcon: Icons.assignment_turned_in_outlined,
      metric: l10n.programHubPlanMetric(
        activePlan.dayCount,
        activePlan.setCount,
      ),
      trend: l10n.programBuilderSummary(
        activePlan.dayCount,
        activePlan.exerciseCount,
      ),
      isProminent: true,
      child: Wrap(
        spacing: AppSpacing.xs,
        runSpacing: AppSpacing.xs,
        children: [
          AppStatusChip(
            label: l10n.programHubActiveStatus,
            tone: AppStatusTone.success,
            icon: Icons.check,
          ),
          AppStatusChip(
            label: l10n.programHubRecommendationClearCount,
            tone: AppStatusTone.neutral,
            icon: Icons.inbox_outlined,
          ),
        ],
      ),
    );
  }
}

class _ProgramHubRouteCards extends StatelessWidget {
  const _ProgramHubRouteCards();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Column(
      children: [
        AppDashboardCard(
          key: ProgramScreen.builderTabKey,
          title: l10n.programWorkspaceBuilderTab,
          subtitle: l10n.programHubBuilderDescription,
          leadingIcon: Icons.view_week_outlined,
          trailing: const Icon(Icons.chevron_right),
          onTap: () => context.go(ProgramBuilderRouteScreen.path),
        ),
        const SizedBox(height: AppSpacing.sm),
        AppDashboardCard(
          key: ProgramScreen.catalogTabKey,
          title: l10n.programWorkspaceCatalogTab,
          subtitle: l10n.programHubCatalogDescription,
          leadingIcon: Icons.fitness_center_outlined,
          trailing: const Icon(Icons.chevron_right),
          onTap: () => context.go(ExerciseCatalogScreen.path),
        ),
        const SizedBox(height: AppSpacing.sm),
        AppDashboardCard(
          key: ProgramScreen.recommendationInboxRouteCardKey,
          title: l10n.programHubRecommendationInboxTitle,
          subtitle: l10n.programHubRecommendationClearDescription,
          leadingIcon: Icons.pending_actions_outlined,
          metric: l10n.programHubRecommendationClearCount,
          trend: l10n.programHubRecommendationClearStatus,
          trailing: const Icon(Icons.chevron_right),
          onTap: () => context.go(ProgramRecommendationInboxScreen.path),
        ),
      ],
    );
  }
}

class _TrainingDayCards extends StatelessWidget {
  const _TrainingDayCards({required this.activePlan, required this.catalog});

  final _ProgramHubActivePlan activePlan;
  final ExerciseCatalog? catalog;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);

    return Column(
      key: ProgramScreen.trainingDaysSectionKey,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.programHubTrainingDaysTitle,
          style: theme.textTheme.titleMedium,
        ),
        const SizedBox(height: AppSpacing.xs),
        Text(
          l10n.programHubTrainingDaysDescription,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        for (final day in activePlan.trainingDays) ...[
          _TrainingDayCard(day: day, catalog: catalog),
          const SizedBox(height: AppSpacing.sm),
        ],
      ],
    );
  }
}

class _TrainingDayCard extends StatelessWidget {
  const _TrainingDayCard({required this.day, required this.catalog});

  final _ProgramHubTrainingDaySummary day;
  final ExerciseCatalog? catalog;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return AppDashboardCard(
      key: ProgramScreen.trainingDayCardKey(day.day.trainingDayOrder),
      title: day.day.name,
      subtitle: l10n.programHubTrainingDaySummary(
        day.exerciseCount,
        day.setCount,
      ),
      leadingIcon: Icons.calendar_today_outlined,
      trailing: const Icon(Icons.edit_outlined),
      onTap: () => context.go(ProgramBuilderRouteScreen.path),
      child: Wrap(
        spacing: AppSpacing.xs,
        runSpacing: AppSpacing.xs,
        children: [
          for (final exercise in day.previewExercises)
            AppStatusChip(
              label: _exerciseName(context, catalog, exercise.exerciseId),
              tone: AppStatusTone.information,
            ),
          if (day.hiddenExerciseCount > 0)
            AppStatusChip(
              label: l10n.programHubMoreExercises(day.hiddenExerciseCount),
              tone: AppStatusTone.neutral,
            ),
        ],
      ),
    );
  }
}

class _ProgramHubErrorState extends StatelessWidget {
  const _ProgramHubErrorState({required this.onRetry});

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
            const Icon(Icons.error_outline, size: 48),
            const SizedBox(height: AppSpacing.md),
            Text(l10n.programHubLoadError, textAlign: TextAlign.center),
            const SizedBox(height: AppSpacing.md),
            FilledButton(onPressed: onRetry, child: Text(l10n.todayRetry)),
          ],
        ),
      ),
    );
  }
}

class ProgramBuilderRouteScreen extends StatelessWidget {
  const ProgramBuilderRouteScreen({super.key});

  static const pathSegment = 'builder';
  static const path = '${ProgramScreen.path}/$pathSegment';
  static const routeName = 'program-builder';
  static const screenKey = Key('program-builder-route-screen');

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return FeatureRootScaffold(
      key: screenKey,
      title: l10n.programWorkspaceBuilderTab,
      icon: Icons.view_week_outlined,
      child: const ProgramBuilderScreen(),
    );
  }
}

class ProgramRecommendationInboxScreen extends StatelessWidget {
  const ProgramRecommendationInboxScreen({super.key});

  static const pathSegment = 'recommendations';
  static const path = '${ProgramScreen.path}/$pathSegment';
  static const routeName = 'program-recommendations';
  static const screenKey = Key('program-recommendations-screen');

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return FeatureRootScaffold(
      key: screenKey,
      title: l10n.programHubRecommendationInboxTitle,
      icon: Icons.pending_actions_outlined,
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: AppDashboardCard(
            title: l10n.programHubRecommendationInboxTitle,
            subtitle: l10n.programHubRecommendationClearDescription,
            leadingIcon: Icons.pending_actions_outlined,
            metric: l10n.programHubRecommendationClearCount,
            trend: l10n.programHubRecommendationClearStatus,
          ),
        ),
      ),
    );
  }
}

final class _ProgramHubState {
  const _ProgramHubState({required this.activePlan});

  final _ProgramHubActivePlan? activePlan;
}

final class _ProgramHubActivePlan {
  const _ProgramHubActivePlan({
    required this.program,
    required this.version,
    required this.trainingDays,
  });

  final ProgramRecord program;
  final ProgramVersionRecord version;
  final List<_ProgramHubTrainingDaySummary> trainingDays;

  int get dayCount => trainingDays.length;

  int get exerciseCount =>
      trainingDays.fold<int>(0, (total, day) => total + day.exerciseCount);

  int get setCount =>
      trainingDays.fold<int>(0, (total, day) => total + day.setCount);
}

final class _ProgramHubTrainingDaySummary {
  const _ProgramHubTrainingDaySummary({
    required this.day,
    required this.exercises,
  });

  final ProgramTrainingDayRecord day;
  final List<_ProgramHubExerciseSummary> exercises;

  int get exerciseCount => exercises.length;

  int get setCount =>
      exercises.fold<int>(0, (total, exercise) => total + exercise.setCount);

  List<_ProgramHubExerciseSummary> get previewExercises =>
      exercises.take(3).toList(growable: false);

  int get hiddenExerciseCount => (exercises.length - previewExercises.length)
      .clamp(0, exercises.length)
      .toInt();
}

final class _ProgramHubExerciseSummary {
  const _ProgramHubExerciseSummary({
    required this.exerciseId,
    required this.exerciseOrder,
    required this.setCount,
  });

  final String exerciseId;
  final int exerciseOrder;
  final int setCount;
}

Future<_ProgramHubState> _buildProgramHubState(
  ProgramRepository repository,
  List<ProgramRecord> programs,
) async {
  final activeProgram = _firstWhereOrNull(
    programs,
    (program) => program.lifecycle == ProgramLifecycle.active,
  );
  if (activeProgram == null) {
    return const _ProgramHubState(activePlan: null);
  }

  final versions = await repository.getVersions(activeProgram.id);
  final activeVersion = _firstWhereOrNull(
    versions,
    (version) => version.lifecycle == ProgramVersionLifecycle.active,
  );
  if (activeVersion == null) {
    return const _ProgramHubState(activePlan: null);
  }

  final trainingDays = await repository.getTrainingDays(activeVersion.id);
  final prescription = await repository.getPrescription(activeVersion.id);

  return _ProgramHubState(
    activePlan: _ProgramHubActivePlan(
      program: activeProgram,
      version: activeVersion,
      trainingDays: _buildTrainingDaySummaries(trainingDays, prescription),
    ),
  );
}

List<_ProgramHubTrainingDaySummary> _buildTrainingDaySummaries(
  List<ProgramTrainingDayRecord> trainingDays,
  List<PrescribedSetRecord> prescription,
) {
  final sortedDays = List<ProgramTrainingDayRecord>.of(trainingDays)
    ..sort(
      (left, right) => left.trainingDayOrder.compareTo(right.trainingDayOrder),
    );

  return [
    for (final day in sortedDays)
      _ProgramHubTrainingDaySummary(
        day: day,
        exercises: _buildExerciseSummaries(
          trainingDayOrder: day.trainingDayOrder,
          prescription: prescription,
        ),
      ),
  ];
}

List<_ProgramHubExerciseSummary> _buildExerciseSummaries({
  required int trainingDayOrder,
  required List<PrescribedSetRecord> prescription,
}) {
  final grouped = <int, List<PrescribedSetRecord>>{};
  for (final set in prescription) {
    if (set.trainingDayOrder != trainingDayOrder) {
      continue;
    }
    grouped
        .putIfAbsent(set.exerciseOrder, () => <PrescribedSetRecord>[])
        .add(set);
  }

  final orders = grouped.keys.toList(growable: false)..sort();
  return [
    for (final order in orders)
      _ProgramHubExerciseSummary(
        exerciseId: grouped[order]!.first.exerciseId,
        exerciseOrder: order,
        setCount: grouped[order]!.length,
      ),
  ];
}

T? _firstWhereOrNull<T>(Iterable<T> values, bool Function(T value) test) {
  for (final value in values) {
    if (test(value)) {
      return value;
    }
  }
  return null;
}

String _exerciseName(
  BuildContext context,
  ExerciseCatalog? catalog,
  String exerciseId,
) {
  final localeCode = Localizations.localeOf(context).languageCode;
  return catalog?.exerciseById(exerciseId)?.name(localeCode) ??
      humanizeCatalogIdentifier(exerciseId);
}
