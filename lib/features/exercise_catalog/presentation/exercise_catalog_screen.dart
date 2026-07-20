import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:project_atlas/core/design_system/components/feature_root_scaffold.dart';
import 'package:project_atlas/core/design_system/tokens/app_spacing.dart';
import 'package:project_atlas/features/exercise_catalog/application/exercise_catalog_provider.dart';
import 'package:project_atlas/features/exercise_catalog/domain/exercise_catalog.dart';
import 'package:project_atlas/features/exercise_catalog/presentation/exercise_detail_screen.dart';
import 'package:project_atlas/features/exercise_catalog/presentation/exercise_thumbnail.dart';
import 'package:project_atlas/l10n/generated/app_localizations.dart';

class ExerciseCatalogScreen extends ConsumerStatefulWidget {
  const ExerciseCatalogScreen({this.useScaffold = true, super.key});

  static const searchFieldKey = Key('exercise-catalog-search-field');
  static const resultsSummaryKey = Key('exercise-catalog-results-summary');

  final bool useScaffold;

  static Key exerciseCardKey(String exerciseId) =>
      Key('exercise-catalog-card-$exerciseId');

  static Key thumbnailKey(String exerciseId) =>
      ExerciseThumbnail.thumbnailKey(exerciseId);

  static Key animationBadgeKey(String exerciseId) =>
      ExerciseThumbnail.animationBadgeKey(exerciseId);

  static Key filterChipKey(ExerciseCatalogFacet facet, String id) =>
      Key('exercise-catalog-filter-${facet.name}-$id');

  @override
  ConsumerState<ExerciseCatalogScreen> createState() =>
      _ExerciseCatalogScreenState();
}

class _ExerciseCatalogScreenState extends ConsumerState<ExerciseCatalogScreen> {
  final _searchController = TextEditingController();
  var _filters = const ExerciseCatalogFilters();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final catalogState = ref.watch(exerciseCatalogProvider);
    final child = catalogState.when(
      loading: () => _LoadingState(message: l10n.exerciseCatalogLoading),
      error: (error, stackTrace) =>
          _ErrorState(message: l10n.exerciseCatalogLoadError),
      data: (catalog) => _CatalogContent(
        catalog: catalog,
        searchController: _searchController,
        filters: _filters,
        onSearchChanged: (_) => setState(() {}),
        onToggleFilter: (facet, id) {
          setState(() => _filters = _filters.toggle(facet, id));
        },
        onClear: () {
          setState(() {
            _searchController.clear();
            _filters = const ExerciseCatalogFilters();
          });
        },
      ),
    );

    if (!widget.useScaffold) {
      return child;
    }

    return FeatureRootScaffold(
      title: l10n.exerciseCatalogTitle,
      icon: Icons.fitness_center_outlined,
      child: child,
    );
  }
}

class _CatalogContent extends StatelessWidget {
  const _CatalogContent({
    required this.catalog,
    required this.searchController,
    required this.filters,
    required this.onSearchChanged,
    required this.onToggleFilter,
    required this.onClear,
  });

  final ExerciseCatalog catalog;
  final TextEditingController searchController;
  final ExerciseCatalogFilters filters;
  final ValueChanged<String> onSearchChanged;
  final void Function(ExerciseCatalogFacet facet, String id) onToggleFilter;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final localeCode = Localizations.localeOf(context).languageCode;
    final results = catalog.query(
      localeCode: localeCode,
      searchTerm: searchController.text,
      filters: filters,
    );
    final canClear = searchController.text.isNotEmpty || !filters.isEmpty;

    return CustomScrollView(
      restorationId: 'exercise-catalog-scroll',
      keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
      slivers: [
        SliverPadding(
          padding: const EdgeInsets.all(AppSpacing.md),
          sliver: SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextField(
                  key: ExerciseCatalogScreen.searchFieldKey,
                  controller: searchController,
                  textInputAction: TextInputAction.search,
                  decoration: InputDecoration(
                    labelText: l10n.exerciseCatalogSearchLabel,
                    hintText: l10n.exerciseCatalogSearchHint,
                    prefixIcon: const Icon(Icons.search),
                  ),
                  onChanged: onSearchChanged,
                ),
                const SizedBox(height: AppSpacing.md),
                _FilterHeader(canClear: canClear, onClear: onClear),
                const SizedBox(height: AppSpacing.sm),
                _FilterSection(
                  label: l10n.exerciseCatalogMovementFilter,
                  facet: ExerciseCatalogFacet.movementPattern,
                  options: catalog.movementPatterns,
                  filters: filters,
                  localeCode: localeCode,
                  onToggle: onToggleFilter,
                ),
                _FilterSection(
                  label: l10n.exerciseCatalogMuscleFilter,
                  facet: ExerciseCatalogFacet.muscleRegion,
                  options: catalog.muscleRegionCategories,
                  filters: filters,
                  localeCode: localeCode,
                  onToggle: onToggleFilter,
                ),
                _FilterSection(
                  label: l10n.exerciseCatalogEquipmentFilter,
                  facet: ExerciseCatalogFacet.equipment,
                  options: catalog.equipment,
                  filters: filters,
                  localeCode: localeCode,
                  onToggle: onToggleFilter,
                ),
                _FilterSection(
                  label: l10n.exerciseCatalogLevelFilter,
                  facet: ExerciseCatalogFacet.level,
                  options: catalog.levels,
                  filters: filters,
                  localeCode: localeCode,
                  onToggle: onToggleFilter,
                ),
                _FilterSection(
                  label: l10n.exerciseCatalogLateralityFilter,
                  facet: ExerciseCatalogFacet.laterality,
                  options: catalog.lateralities,
                  filters: filters,
                  localeCode: localeCode,
                  onToggle: onToggleFilter,
                ),
                _FilterSection(
                  label: l10n.exerciseCatalogTypeFilter,
                  facet: ExerciseCatalogFacet.exerciseType,
                  options: catalog.exerciseTypes,
                  filters: filters,
                  localeCode: localeCode,
                  onToggle: onToggleFilter,
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  l10n.exerciseCatalogResultsSummary(
                    results.length,
                    catalog.exercises.length,
                  ),
                  key: ExerciseCatalogScreen.resultsSummaryKey,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ],
            ),
          ),
        ),
        if (results.isEmpty)
          SliverFillRemaining(
            hasScrollBody: false,
            child: _EmptyState(
              title: l10n.exerciseCatalogEmptyTitle,
              message: l10n.exerciseCatalogEmptyMessage,
            ),
          )
        else
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.md,
              AppSpacing.none,
              AppSpacing.md,
              AppSpacing.md,
            ),
            sliver: SliverList.separated(
              itemBuilder: (context, index) {
                final exercise = results[index];
                return _ExerciseCard(
                  exercise: exercise,
                  localeCode: localeCode,
                );
              },
              separatorBuilder: (context, index) =>
                  const SizedBox(height: AppSpacing.sm),
              itemCount: results.length,
            ),
          ),
      ],
    );
  }
}

class _FilterHeader extends StatelessWidget {
  const _FilterHeader({required this.canClear, required this.onClear});

  final bool canClear;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Row(
      children: [
        Expanded(
          child: Semantics(
            header: true,
            child: Text(
              l10n.exerciseCatalogFiltersTitle,
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ),
        ),
        TextButton(
          onPressed: canClear ? onClear : null,
          child: Text(l10n.exerciseCatalogClearFilters),
        ),
      ],
    );
  }
}

class _FilterSection extends StatelessWidget {
  const _FilterSection({
    required this.label,
    required this.facet,
    required this.options,
    required this.filters,
    required this.localeCode,
    required this.onToggle,
  });

  final String label;
  final ExerciseCatalogFacet facet;
  final List<CatalogOption> options;
  final ExerciseCatalogFilters filters;
  final String localeCode;
  final void Function(ExerciseCatalogFacet facet, String id) onToggle;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: Theme.of(context).textTheme.labelLarge),
          const SizedBox(height: AppSpacing.xs),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                for (final option in options) ...[
                  FilterChip(
                    key: ExerciseCatalogScreen.filterChipKey(facet, option.id),
                    label: Text(option.name(localeCode)),
                    selected: filters.contains(facet, option.id),
                    onSelected: (_) => onToggle(facet, option.id),
                  ),
                  const SizedBox(width: AppSpacing.xs),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ExerciseCard extends StatelessWidget {
  const _ExerciseCard({required this.exercise, required this.localeCode});

  final ExerciseCatalogEntry exercise;
  final String localeCode;

  @override
  Widget build(BuildContext context) {
    final muscleNames = exercise.muscleRegionCategories
        .map((option) => option.name(localeCode))
        .join(', ');
    final equipmentNames = exercise.equipment
        .map((option) => option.name(localeCode))
        .join(', ');

    return Card(
      key: ExerciseCatalogScreen.exerciseCardKey(exercise.id),
      child: ListTile(
        leading: ExerciseThumbnail(exercise: exercise, localeCode: localeCode),
        title: Text(exercise.name(localeCode)),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: AppSpacing.xs),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${exercise.movementPattern.name(localeCode)} • $muscleNames',
              ),
              const SizedBox(height: AppSpacing.xxs),
              Text('$equipmentNames • ${exercise.level.name(localeCode)}'),
            ],
          ),
        ),
        trailing: const Icon(Icons.chevron_right),
        onTap: () => context.goNamed(
          ExerciseDetailScreen.routeName,
          pathParameters: {ExerciseDetailScreen.exerciseIdParam: exercise.id},
        ),
      ),
    );
  }
}

class _LoadingState extends StatelessWidget {
  const _LoadingState({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const CircularProgressIndicator(),
          const SizedBox(height: AppSpacing.md),
          Text(message),
        ],
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  const _ErrorState({required this.message});

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

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.title, required this.message});

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
            Icon(
              Icons.search_off,
              color: theme.colorScheme.onSurfaceVariant,
              size: 48,
            ),
            const SizedBox(height: AppSpacing.md),
            Text(title, style: theme.textTheme.titleMedium),
            const SizedBox(height: AppSpacing.xs),
            Text(
              message,
              style: theme.textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
