import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:project_atlas/core/design_system/components/app_dashboard_card.dart';
import 'package:project_atlas/core/design_system/components/app_status_chip.dart';
import 'package:project_atlas/core/design_system/components/feature_root_scaffold.dart';
import 'package:project_atlas/core/design_system/tokens/app_spacing.dart';
import 'package:project_atlas/features/exercise_catalog/application/exercise_catalog_provider.dart';
import 'package:project_atlas/features/exercise_catalog/domain/exercise_catalog.dart';
import 'package:project_atlas/features/exercise_catalog/presentation/exercise_add_to_program_action.dart';
import 'package:project_atlas/features/exercise_catalog/presentation/exercise_detail_screen.dart';
import 'package:project_atlas/features/exercise_catalog/presentation/exercise_thumbnail.dart';
import 'package:project_atlas/l10n/generated/app_localizations.dart';

class ExerciseCatalogScreen extends ConsumerStatefulWidget {
  const ExerciseCatalogScreen({this.useScaffold = true, super.key});

  static const pathSegment = 'catalog';
  static const path = '/program/$pathSegment';
  static const routeName = 'exercise-catalog';
  static const screenKey = Key('exercise-catalog-screen');
  static const searchFieldKey = Key('exercise-catalog-search-field');
  static const resultsSummaryKey = Key('exercise-catalog-results-summary');
  static const filterSheetButtonKey = Key(
    'exercise-catalog-filter-sheet-button',
  );
  static const compactFilterBarKey = Key('exercise-catalog-compact-filter-bar');

  final bool useScaffold;

  static Key exerciseCardKey(String exerciseId) =>
      Key('exercise-catalog-card-$exerciseId');

  static Key thumbnailKey(String exerciseId) =>
      ExerciseThumbnail.thumbnailKey(exerciseId);

  static Key animationBadgeKey(String exerciseId) =>
      ExerciseThumbnail.animationBadgeKey(exerciseId);

  static Key addToProgramButtonKey(String exerciseId) =>
      Key('exercise-catalog-add-to-program-$exerciseId');

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
        onOpenFilters: () => _showFilterSheet(catalog),
        onClear: () {
          setState(() {
            _searchController.clear();
            _filters = const ExerciseCatalogFilters();
          });
        },
        onAddToProgram: (exercise, localeCode) => addExerciseToProgramDraft(
          context: context,
          ref: ref,
          exercise: exercise,
          localeCode: localeCode,
        ),
      ),
    );

    if (!widget.useScaffold) {
      return child;
    }

    return FeatureRootScaffold(
      key: ExerciseCatalogScreen.screenKey,
      title: l10n.exerciseCatalogTitle,
      icon: Icons.fitness_center_outlined,
      child: child,
    );
  }

  Future<void> _showFilterSheet(ExerciseCatalog catalog) {
    final localeCode = Localizations.localeOf(context).languageCode;
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (sheetContext) => StatefulBuilder(
        builder: (context, setSheetState) => _FilterSheet(
          catalog: catalog,
          filters: _filters,
          localeCode: localeCode,
          onToggle: (facet, id) {
            setState(() => _filters = _filters.toggle(facet, id));
            setSheetState(() {});
          },
          onClear: () {
            setState(() => _filters = const ExerciseCatalogFilters());
            setSheetState(() {});
          },
        ),
      ),
    );
  }
}

class _CatalogContent extends StatelessWidget {
  const _CatalogContent({
    required this.catalog,
    required this.searchController,
    required this.filters,
    required this.onSearchChanged,
    required this.onOpenFilters,
    required this.onClear,
    required this.onAddToProgram,
  });

  final ExerciseCatalog catalog;
  final TextEditingController searchController;
  final ExerciseCatalogFilters filters;
  final ValueChanged<String> onSearchChanged;
  final VoidCallback onOpenFilters;
  final VoidCallback onClear;
  final void Function(ExerciseCatalogEntry exercise, String localeCode)
  onAddToProgram;

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
    final activeFilterLabels = _selectedFilterLabels(
      catalog: catalog,
      filters: filters,
      localeCode: localeCode,
    );

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
                AppDashboardCard(
                  title: l10n.exerciseCatalogTitle,
                  subtitle: l10n.exerciseCatalogSubtitle,
                  leadingIcon: Icons.manage_search_outlined,
                  metric: results.length.toString(),
                  trend: l10n.exerciseCatalogResultsTrend(
                    catalog.exercises.length,
                  ),
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
                      const SizedBox(height: AppSpacing.sm),
                      _CompactFilterBar(
                        activeFilterLabels: activeFilterLabels,
                        canClear: canClear,
                        onOpenFilters: onOpenFilters,
                        onClear: onClear,
                      ),
                    ],
                  ),
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
                  onAddToProgram: () => onAddToProgram(exercise, localeCode),
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

class _CompactFilterBar extends StatelessWidget {
  const _CompactFilterBar({
    required this.activeFilterLabels,
    required this.canClear,
    required this.onOpenFilters,
    required this.onClear,
  });

  final List<String> activeFilterLabels;
  final bool canClear;
  final VoidCallback onOpenFilters;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Column(
      key: ExerciseCatalogScreen.compactFilterBarKey,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: FilledButton.tonalIcon(
                key: ExerciseCatalogScreen.filterSheetButtonKey,
                onPressed: onOpenFilters,
                icon: const Icon(Icons.tune_outlined),
                label: Text(
                  activeFilterLabels.isEmpty
                      ? l10n.exerciseCatalogFilterButton
                      : l10n.exerciseCatalogActiveFilterCount(
                          activeFilterLabels.length,
                        ),
                ),
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            TextButton(
              onPressed: canClear ? onClear : null,
              child: Text(l10n.exerciseCatalogClearFilters),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.xs),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: activeFilterLabels.isEmpty
                ? [
                    AppStatusChip(
                      label: l10n.exerciseCatalogNoActiveFilters,
                      icon: Icons.filter_alt_off_outlined,
                      tone: AppStatusTone.neutral,
                    ),
                  ]
                : [
                    for (final label in activeFilterLabels) ...[
                      AppStatusChip(
                        label: label,
                        icon: Icons.check,
                        tone: AppStatusTone.information,
                      ),
                      const SizedBox(width: AppSpacing.xs),
                    ],
                  ],
          ),
        ),
      ],
    );
  }
}

class _FilterSheet extends StatelessWidget {
  const _FilterSheet({
    required this.catalog,
    required this.filters,
    required this.localeCode,
    required this.onToggle,
    required this.onClear,
  });

  final ExerciseCatalog catalog;
  final ExerciseCatalogFilters filters;
  final String localeCode;
  final void Function(ExerciseCatalogFacet facet, String id) onToggle;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.86,
      minChildSize: 0.48,
      maxChildSize: 0.94,
      builder: (context, scrollController) => ListView(
        controller: scrollController,
        padding: const EdgeInsets.all(AppSpacing.md),
        children: [
          Row(
            children: [
              Expanded(
                child: Semantics(
                  header: true,
                  child: Text(
                    l10n.exerciseCatalogFilterSheetTitle,
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                ),
              ),
              TextButton(
                onPressed: filters.isEmpty ? null : onClear,
                child: Text(l10n.exerciseCatalogClearFilters),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          _FilterSection(
            label: l10n.exerciseCatalogMovementFilter,
            facet: ExerciseCatalogFacet.movementPattern,
            options: catalog.movementPatterns,
            filters: filters,
            localeCode: localeCode,
            onToggle: onToggle,
          ),
          _FilterSection(
            label: l10n.exerciseCatalogMuscleFilter,
            facet: ExerciseCatalogFacet.muscleRegion,
            options: catalog.muscleRegionCategories,
            filters: filters,
            localeCode: localeCode,
            onToggle: onToggle,
          ),
          _FilterSection(
            label: l10n.exerciseCatalogEquipmentFilter,
            facet: ExerciseCatalogFacet.equipment,
            options: catalog.equipment,
            filters: filters,
            localeCode: localeCode,
            onToggle: onToggle,
          ),
          _FilterSection(
            label: l10n.exerciseCatalogLevelFilter,
            facet: ExerciseCatalogFacet.level,
            options: catalog.levels,
            filters: filters,
            localeCode: localeCode,
            onToggle: onToggle,
          ),
          _FilterSection(
            label: l10n.exerciseCatalogLateralityFilter,
            facet: ExerciseCatalogFacet.laterality,
            options: catalog.lateralities,
            filters: filters,
            localeCode: localeCode,
            onToggle: onToggle,
          ),
          _FilterSection(
            label: l10n.exerciseCatalogTypeFilter,
            facet: ExerciseCatalogFacet.exerciseType,
            options: catalog.exerciseTypes,
            filters: filters,
            localeCode: localeCode,
            onToggle: onToggle,
          ),
          const SizedBox(height: AppSpacing.md),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(l10n.exerciseCatalogApplyFilters),
          ),
        ],
      ),
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

List<String> _selectedFilterLabels({
  required ExerciseCatalog catalog,
  required ExerciseCatalogFilters filters,
  required String localeCode,
}) {
  Iterable<String> namesFor(
    Iterable<CatalogOption> options,
    Set<String> selectedIds,
  ) {
    return options
        .where((option) => selectedIds.contains(option.id))
        .map((option) => option.name(localeCode));
  }

  return [
    ...namesFor(catalog.movementPatterns, filters.movementPatternIds),
    ...namesFor(
      catalog.muscleRegionCategories,
      filters.muscleRegionCategoryIds,
    ),
    ...namesFor(catalog.equipment, filters.equipmentIds),
    ...namesFor(catalog.levels, filters.levelIds),
    ...namesFor(catalog.lateralities, filters.lateralityIds),
    ...namesFor(catalog.exerciseTypes, filters.exerciseTypeIds),
  ];
}

class _ExerciseCard extends StatelessWidget {
  const _ExerciseCard({
    required this.exercise,
    required this.localeCode,
    required this.onAddToProgram,
  });

  final ExerciseCatalogEntry exercise;
  final String localeCode;
  final VoidCallback onAddToProgram;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final muscleNames = exercise.muscleRegionCategories
        .map((option) => option.name(localeCode))
        .join(', ');
    final equipmentNames = exercise.equipment
        .map((option) => option.name(localeCode))
        .join(', ');

    return Card(
      key: ExerciseCatalogScreen.exerciseCardKey(exercise.id),
      child: ListTile(
        leading: ExerciseThumbnail(
          exercise: exercise,
          localeCode: localeCode,
          size: 88,
        ),
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
        trailing: IconButton(
          key: ExerciseCatalogScreen.addToProgramButtonKey(exercise.id),
          tooltip: l10n.exerciseCatalogAddToProgram,
          onPressed: onAddToProgram,
          icon: const Icon(Icons.playlist_add_outlined),
        ),
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
