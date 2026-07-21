import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:project_atlas/core/design_system/components/feature_root_scaffold.dart';
import 'package:project_atlas/core/design_system/tokens/app_spacing.dart';
import 'package:project_atlas/core/measurements/measurement_guidance.dart';
import 'package:project_atlas/core/repositories/repository_records.dart';
import 'package:project_atlas/core/units/measurement_units.dart';
import 'package:project_atlas/core/units/unit_formatter.dart';
import 'package:project_atlas/core/units/unit_system_provider.dart';
import 'package:project_atlas/features/exercise_catalog/application/exercise_catalog_provider.dart';
import 'package:project_atlas/features/exercise_catalog/domain/exercise_catalog.dart';
import 'package:project_atlas/features/progress/application/workout_history_controller.dart';
import 'package:project_atlas/features/progress/domain/measurement_history_export.dart';
import 'package:project_atlas/features/progress/domain/progress_trends.dart';
import 'package:project_atlas/features/today/application/workout_status_calculator.dart';
import 'package:project_atlas/l10n/generated/app_localizations.dart';

class ProgressScreen extends ConsumerStatefulWidget {
  const ProgressScreen({super.key});

  static const path = '/progress';
  static const routeName = 'progress';
  static const screenKey = Key('progress-screen');
  static const emptyStateKey = Key('progress-empty-state');
  static const historySectionKey = Key('progress-history-section');
  static const trendsSectionKey = Key('progress-trends-section');
  static const measurementTrendsSectionKey = Key(
    'progress-measurement-trends-section',
  );
  static const trainingTrendsSectionKey = Key(
    'progress-training-trends-section',
  );
  static const measurementHistorySectionKey = Key(
    'progress-measurement-history-section',
  );
  static const measurementHistoryComparisonSectionKey = Key(
    'progress-measurement-history-comparison-section',
  );
  static const measurementHistorySideComparisonSectionKey = Key(
    'progress-measurement-history-side-comparison-section',
  );
  static const measurementHistoryExportCsvButtonKey = Key(
    'progress-measurement-history-export-csv',
  );
  static const measurementHistoryExportJsonButtonKey = Key(
    'progress-measurement-history-export-json',
  );
  static const setDetailsSectionKey = Key('progress-set-details-section');
  static const personalRecordsSectionKey = Key(
    'progress-personal-records-section',
  );
  static const retryButtonKey = Key('progress-retry-button');

  static Key historySessionCardKey(String sessionId) =>
      Key('progress-history-session-$sessionId');

  static Key historySetButtonKey(String sessionSetId) =>
      Key('progress-history-set-$sessionSetId');

  static Key measurementTrendRowKey(MeasurementTrendMetric metric) =>
      Key('progress-measurement-trend-${metric.name}');

  static Key measurementHistoryComparisonRowKey(BodyMeasurementField field) =>
      Key('progress-measurement-history-comparison-${field.name}');

  static Key measurementHistorySideComparisonRowKey(String pairKey) =>
      Key('progress-measurement-history-side-comparison-$pairKey');

  static Key trainingTrendCardKey(String exerciseId) =>
      Key('progress-training-trend-$exerciseId');

  static Key trainingTrendRowKey(
    String exerciseId,
    TrainingTrendMetric metric,
  ) => Key('progress-training-trend-$exerciseId-${metric.name}');

  static Key personalRecordCardKey(String exerciseId) =>
      Key('progress-personal-record-$exerciseId');

  static Key correctionRepetitionsFieldKey(String sessionSetId) =>
      Key('progress-correction-repetitions-$sessionSetId');

  static Key correctionLoadFieldKey(String sessionSetId) =>
      Key('progress-correction-load-$sessionSetId');

  static Key correctionRirFieldKey(String sessionSetId) =>
      Key('progress-correction-rir-$sessionSetId');

  static Key correctionOutcomeFieldKey(String sessionSetId) =>
      Key('progress-correction-outcome-$sessionSetId');

  static Key correctionSaveButtonKey(String sessionSetId) =>
      Key('progress-correction-save-$sessionSetId');

  static Key revisionHistoryKey(String sessionSetId) =>
      Key('progress-revision-history-$sessionSetId');

  static Key revisionRowKey(String logId) => Key('progress-revision-$logId');

  @override
  ConsumerState<ProgressScreen> createState() => _ProgressScreenState();
}

class _ProgressScreenState extends ConsumerState<ProgressScreen> {
  String? _selectedSessionSetId;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final historyState = ref.watch(workoutHistoryProvider);

    return FeatureRootScaffold(
      key: ProgressScreen.screenKey,
      title: l10n.progressNavigationLabel,
      icon: Icons.insights_outlined,
      child: historyState.when(
        data: (state) => _ProgressContent(
          state: state,
          selectedSessionSetId: _selectedSessionSetId,
          onSelectSet: (sessionSetId) {
            setState(() {
              _selectedSessionSetId = sessionSetId;
            });
          },
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stackTrace) => _ProgressErrorState(
          onRetry: () => ref.invalidate(workoutHistoryProvider),
        ),
      ),
    );
  }
}

class _ProgressContent extends ConsumerWidget {
  const _ProgressContent({
    required this.state,
    required this.selectedSessionSetId,
    required this.onSelectSet,
  });

  final WorkoutHistoryState state;
  final String? selectedSessionSetId;
  final ValueChanged<String> onSelectSet;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final catalog = ref
        .watch(exerciseCatalogProvider)
        .maybeWhen(data: (catalog) => catalog, orElse: () => null);
    final unitSystem = ref.watch(unitSystemProvider);
    final formatter = UnitFormatter(
      locale: Localizations.localeOf(context),
      unitSystem: unitSystem,
    );
    final selectedSet =
        state.setDetailById(selectedSessionSetId) ?? state.firstSetDetail;

    return SingleChildScrollView(
      restorationId: 'progress-scroll',
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Semantics(
            header: true,
            child: Text(
              l10n.progressNavigationLabel,
              key: FeatureRootScaffold.placeholderTitleKey,
              style: theme.textTheme.headlineSmall,
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            l10n.progressScreenSubtitle,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          if (!state.trends.isEmpty) ...[
            _ProgressTrendsSection(
              trends: state.trends,
              catalog: catalog,
              formatter: formatter,
            ),
            const SizedBox(height: AppSpacing.md),
          ],
          if (!state.measurementHistory.isEmpty) ...[
            _MeasurementHistorySection(
              history: state.measurementHistory,
              formatter: formatter,
            ),
            const SizedBox(height: AppSpacing.md),
          ],
          if (state.isEmpty)
            const _ProgressEmptyState()
          else ...[
            _WorkoutHistorySection(
              state: state,
              catalog: catalog,
              formatter: formatter,
              selectedSessionSetId: selectedSet?.sessionSet.id,
              onSelectSet: onSelectSet,
            ),
            const SizedBox(height: AppSpacing.md),
            _SetDetailsSection(
              detail: selectedSet,
              catalog: catalog,
              formatter: formatter,
            ),
            const SizedBox(height: AppSpacing.md),
            _PersonalRecordsSection(
              records: state.personalRecords,
              catalog: catalog,
              formatter: formatter,
            ),
          ],
        ],
      ),
    );
  }
}

class _ProgressEmptyState extends StatelessWidget {
  const _ProgressEmptyState();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Card(
      key: ProgressScreen.emptyStateKey,
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.progressHistoryEmptyTitle,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(l10n.progressHistoryEmptyMessage),
          ],
        ),
      ),
    );
  }
}

class _ProgressErrorState extends StatelessWidget {
  const _ProgressErrorState({required this.onRetry});

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
            Text(l10n.progressHistoryLoadError, textAlign: TextAlign.center),
            const SizedBox(height: AppSpacing.md),
            FilledButton(
              key: ProgressScreen.retryButtonKey,
              onPressed: onRetry,
              child: Text(l10n.todayRetry),
            ),
          ],
        ),
      ),
    );
  }
}

class _ProgressTrendsSection extends StatelessWidget {
  const _ProgressTrendsSection({
    required this.trends,
    required this.catalog,
    required this.formatter,
  });

  final ProgressTrendSet trends;
  final ExerciseCatalog? catalog;
  final UnitFormatter formatter;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);

    return Column(
      key: ProgressScreen.trendsSectionKey,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(l10n.progressTrendsTitle, style: theme.textTheme.titleLarge),
        const SizedBox(height: AppSpacing.xs),
        Text(
          l10n.progressTrendsDescription,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        if (trends.measurementTrends.isNotEmpty) ...[
          const SizedBox(height: AppSpacing.sm),
          _MeasurementTrendsCard(
            trends: trends.measurementTrends,
            formatter: formatter,
          ),
        ],
        if (trends.trainingTrends.isNotEmpty) ...[
          const SizedBox(height: AppSpacing.sm),
          _TrainingTrendsCard(
            trends: trends.trainingTrends,
            catalog: catalog,
            formatter: formatter,
          ),
        ],
      ],
    );
  }
}

class _MeasurementTrendsCard extends StatelessWidget {
  const _MeasurementTrendsCard({required this.trends, required this.formatter});

  final List<MeasurementProgressTrend> trends;
  final UnitFormatter formatter;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);

    return Card(
      key: ProgressScreen.measurementTrendsSectionKey,
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.progressMeasurementTrendsTitle,
              style: theme.textTheme.titleMedium,
            ),
            const SizedBox(height: AppSpacing.xs),
            for (final trend in trends.take(8))
              Padding(
                key: ProgressScreen.measurementTrendRowKey(trend.metric),
                padding: const EdgeInsets.only(bottom: AppSpacing.xs),
                child: Text(
                  _trendLine(
                    context: context,
                    metricLabel: _measurementTrendLabel(l10n, trend.metric),
                    unit: trend.unit,
                    latestValue: trend.latestPoint.value,
                    delta: trend.delta,
                    pointCount: trend.points.length,
                    formatter: formatter,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _TrainingTrendsCard extends StatelessWidget {
  const _TrainingTrendsCard({
    required this.trends,
    required this.catalog,
    required this.formatter,
  });

  final List<ExerciseProgressTrend> trends;
  final ExerciseCatalog? catalog;
  final UnitFormatter formatter;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);

    return Card(
      key: ProgressScreen.trainingTrendsSectionKey,
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.progressTrainingTrendsTitle,
              style: theme.textTheme.titleMedium,
            ),
            const SizedBox(height: AppSpacing.sm),
            for (final exerciseTrend in trends.take(6))
              Padding(
                key: ProgressScreen.trainingTrendCardKey(
                  exerciseTrend.exerciseId,
                ),
                padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _exerciseName(context, catalog, exerciseTrend.exerciseId),
                      style: theme.textTheme.titleSmall,
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    for (final trend in exerciseTrend.metricTrends)
                      Padding(
                        key: ProgressScreen.trainingTrendRowKey(
                          exerciseTrend.exerciseId,
                          trend.metric,
                        ),
                        padding: const EdgeInsets.only(bottom: AppSpacing.xs),
                        child: Text(
                          _trendLine(
                            context: context,
                            metricLabel: _trainingTrendLabel(
                              l10n,
                              trend.metric,
                            ),
                            unit: trend.unit,
                            latestValue: trend.latestPoint.value,
                            delta: trend.delta,
                            pointCount: trend.points.length,
                            formatter: formatter,
                          ),
                        ),
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

class _MeasurementHistorySection extends StatelessWidget {
  const _MeasurementHistorySection({
    required this.history,
    required this.formatter,
  });

  final MeasurementHistoryReadModel history;
  final UnitFormatter formatter;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);

    return Card(
      key: ProgressScreen.measurementHistorySectionKey,
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.progressMeasurementHistoryTitle,
              style: theme.textTheme.titleLarge,
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              l10n.progressMeasurementHistoryDescription,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            if (history.comparisons.isNotEmpty) ...[
              const SizedBox(height: AppSpacing.sm),
              _MeasurementHistoryComparisons(
                comparisons: history.comparisons,
                formatter: formatter,
              ),
            ],
            if (history.sideComparisons.isNotEmpty) ...[
              const SizedBox(height: AppSpacing.sm),
              _MeasurementHistorySideComparisons(
                comparisons: history.sideComparisons,
                formatter: formatter,
              ),
            ],
            const SizedBox(height: AppSpacing.sm),
            Text(
              l10n.progressMeasurementExportTitle,
              style: theme.textTheme.titleMedium,
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              l10n.progressMeasurementExportDescription,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(l10n.progressMeasurementExportCount(history.records.length)),
            const SizedBox(height: AppSpacing.sm),
            Wrap(
              spacing: AppSpacing.sm,
              runSpacing: AppSpacing.sm,
              children: [
                OutlinedButton.icon(
                  key: ProgressScreen.measurementHistoryExportCsvButtonKey,
                  onPressed: () async {
                    await Clipboard.setData(
                      ClipboardData(text: history.toCsv()),
                    );
                    if (!context.mounted) {
                      return;
                    }
                    _showSnackBar(
                      context,
                      l10n.progressMeasurementExportCopiedCsv,
                    );
                  },
                  icon: const Icon(Icons.table_chart_outlined),
                  label: Text(l10n.progressMeasurementExportCopyCsv),
                ),
                OutlinedButton.icon(
                  key: ProgressScreen.measurementHistoryExportJsonButtonKey,
                  onPressed: () async {
                    await Clipboard.setData(
                      ClipboardData(text: history.toJson()),
                    );
                    if (!context.mounted) {
                      return;
                    }
                    _showSnackBar(
                      context,
                      l10n.progressMeasurementExportCopiedJson,
                    );
                  },
                  icon: const Icon(Icons.data_object_outlined),
                  label: Text(l10n.progressMeasurementExportCopyJson),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _MeasurementHistoryComparisons extends StatelessWidget {
  const _MeasurementHistoryComparisons({
    required this.comparisons,
    required this.formatter,
  });

  final List<MeasurementHistoryComparison> comparisons;
  final UnitFormatter formatter;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);

    return Column(
      key: ProgressScreen.measurementHistoryComparisonSectionKey,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.progressMeasurementComparisonTitle,
          style: theme.textTheme.titleMedium,
        ),
        const SizedBox(height: AppSpacing.xs),
        for (final comparison in comparisons.take(10))
          Padding(
            key: ProgressScreen.measurementHistoryComparisonRowKey(
              comparison.field,
            ),
            padding: const EdgeInsets.only(bottom: AppSpacing.xs),
            child: Text(
              _measurementComparisonLine(
                context: context,
                comparison: comparison,
                formatter: formatter,
              ),
            ),
          ),
      ],
    );
  }
}

class _MeasurementHistorySideComparisons extends StatelessWidget {
  const _MeasurementHistorySideComparisons({
    required this.comparisons,
    required this.formatter,
  });

  final List<MeasurementHistorySideComparison> comparisons;
  final UnitFormatter formatter;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);

    return Column(
      key: ProgressScreen.measurementHistorySideComparisonSectionKey,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.progressMeasurementSideComparisonTitle,
          style: theme.textTheme.titleMedium,
        ),
        const SizedBox(height: AppSpacing.xs),
        for (final comparison in comparisons)
          Padding(
            key: ProgressScreen.measurementHistorySideComparisonRowKey(
              comparison.pairKey,
            ),
            padding: const EdgeInsets.only(bottom: AppSpacing.xs),
            child: Text(
              _measurementSideComparisonLine(
                context: context,
                comparison: comparison,
                formatter: formatter,
              ),
            ),
          ),
      ],
    );
  }
}

class _WorkoutHistorySection extends StatelessWidget {
  const _WorkoutHistorySection({
    required this.state,
    required this.catalog,
    required this.formatter,
    required this.selectedSessionSetId,
    required this.onSelectSet,
  });

  final WorkoutHistoryState state;
  final ExerciseCatalog? catalog;
  final UnitFormatter formatter;
  final String? selectedSessionSetId;
  final ValueChanged<String> onSelectSet;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);

    return Column(
      key: ProgressScreen.historySectionKey,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(l10n.progressHistoryTitle, style: theme.textTheme.titleLarge),
        const SizedBox(height: AppSpacing.sm),
        for (final session in state.sessions)
          _WorkoutHistorySessionCard(
            summary: session,
            catalog: catalog,
            formatter: formatter,
            selectedSessionSetId: selectedSessionSetId,
            onSelectSet: onSelectSet,
          ),
      ],
    );
  }
}

class _WorkoutHistorySessionCard extends StatelessWidget {
  const _WorkoutHistorySessionCard({
    required this.summary,
    required this.catalog,
    required this.formatter,
    required this.selectedSessionSetId,
    required this.onSelectSet,
  });

  final WorkoutHistorySessionSummary summary;
  final ExerciseCatalog? catalog;
  final UnitFormatter formatter;
  final String? selectedSessionSetId;
  final ValueChanged<String> onSelectSet;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);

    return Card(
      key: ProgressScreen.historySessionCardKey(summary.session.id),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.history),
              title: Text(summary.session.notes ?? l10n.progressUnnamedSession),
              subtitle: Text(_formatDateTime(context, summary.occurredAt)),
            ),
            Text(
              l10n.progressSessionSummary(
                _sessionStatusText(l10n, summary.status),
                summary.completedSetCount,
                summary.setCount,
              ),
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Wrap(
              spacing: AppSpacing.sm,
              runSpacing: AppSpacing.xs,
              children: [
                for (final detail in summary.setDetails)
                  OutlinedButton(
                    key: ProgressScreen.historySetButtonKey(
                      detail.sessionSet.id,
                    ),
                    onPressed: () => onSelectSet(detail.sessionSet.id),
                    style: detail.sessionSet.id == selectedSessionSetId
                        ? OutlinedButton.styleFrom(
                            backgroundColor:
                                theme.colorScheme.secondaryContainer,
                          )
                        : null,
                    child: Text(
                      l10n.progressSetButtonLabel(
                        _exerciseName(
                          context,
                          catalog,
                          detail.sessionSet.exerciseId,
                        ),
                        detail.sessionSet.setOrder + 1,
                      ),
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _SetDetailsSection extends StatelessWidget {
  const _SetDetailsSection({
    required this.detail,
    required this.catalog,
    required this.formatter,
  });

  final WorkoutHistorySetDetail? detail;
  final ExerciseCatalog? catalog;
  final UnitFormatter formatter;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final current = detail;

    return Card(
      key: ProgressScreen.setDetailsSectionKey,
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.progressSetDetailsTitle,
              style: theme.textTheme.titleLarge,
            ),
            const SizedBox(height: AppSpacing.sm),
            if (current == null)
              Text(l10n.progressSetDetailsEmpty)
            else ...[
              Text(
                _exerciseName(context, catalog, current.sessionSet.exerciseId),
                style: theme.textTheme.titleMedium,
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                l10n.progressSetDetailSession(
                  current.session.notes ?? l10n.progressUnnamedSession,
                  _formatDateTime(
                    context,
                    current.session.startedAt ?? current.session.createdAt,
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                l10n.progressSetDetailStatus(
                  _setStatusText(l10n, current.status),
                ),
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                l10n.progressSetDetailTarget(
                  _prescriptionSummary(l10n, formatter, current.prescribedSet),
                ),
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                l10n.progressSetDetailLatest(
                  _actualSummary(l10n, formatter, current.latestLog),
                ),
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(l10n.progressSetDetailRevisionCount(current.logs.length)),
              const SizedBox(height: AppSpacing.md),
              _RevisionHistory(detail: current, formatter: formatter),
              const SizedBox(height: AppSpacing.md),
              _CorrectionForm(detail: current, formatter: formatter),
            ],
          ],
        ),
      ),
    );
  }
}

class _RevisionHistory extends StatelessWidget {
  const _RevisionHistory({required this.detail, required this.formatter});

  final WorkoutHistorySetDetail detail;
  final UnitFormatter formatter;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final logs = List<ActualSetLogRecord>.of(detail.logs)
      ..sort((left, right) => right.revision.compareTo(left.revision));

    return Column(
      key: ProgressScreen.revisionHistoryKey(detail.sessionSet.id),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.progressRevisionHistoryTitle,
          style: theme.textTheme.titleMedium,
        ),
        const SizedBox(height: AppSpacing.xs),
        if (logs.isEmpty)
          Text(l10n.progressNoActualLog)
        else
          for (final log in logs)
            Padding(
              key: ProgressScreen.revisionRowKey(log.id),
              padding: const EdgeInsets.only(bottom: AppSpacing.xs),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.progressRevisionRow(
                      log.revision,
                      _actualSummary(l10n, formatter, log),
                    ),
                  ),
                  if (log.supersedesLogId != null)
                    Text(
                      l10n.progressRevisionSupersedes(log.supersedesLogId!),
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                ],
              ),
            ),
      ],
    );
  }
}

class _CorrectionForm extends ConsumerStatefulWidget {
  const _CorrectionForm({required this.detail, required this.formatter});

  final WorkoutHistorySetDetail detail;
  final UnitFormatter formatter;

  @override
  ConsumerState<_CorrectionForm> createState() => _CorrectionFormState();
}

class _CorrectionFormState extends ConsumerState<_CorrectionForm> {
  final _repetitionsController = TextEditingController();
  final _loadController = TextEditingController();
  final _rirController = TextEditingController();
  String _inputSeed = '';
  SetResult? _selectedResult;

  @override
  void initState() {
    super.initState();
    _resetInputs();
  }

  @override
  void didUpdateWidget(covariant _CorrectionForm oldWidget) {
    super.didUpdateWidget(oldWidget);
    final nextSeed = _seedFor(widget);
    if (nextSeed != _inputSeed) {
      _resetInputs();
    }
  }

  @override
  void dispose() {
    _repetitionsController.dispose();
    _loadController.dispose();
    _rirController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final correctionState = ref.watch(
      workoutHistoryCorrectionControllerProvider,
    );
    final latestLog = widget.detail.latestLog;
    final canCorrect = widget.detail.isCompleted && latestLog != null;
    final enabled = canCorrect && !correctionState.isLoading;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(l10n.progressCorrectionTitle, style: theme.textTheme.titleMedium),
        const SizedBox(height: AppSpacing.xs),
        Text(
          l10n.progressCorrectionDescription,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        if (!canCorrect)
          Text(l10n.progressCorrectionUnavailable)
        else
          Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.sm,
            crossAxisAlignment: WrapCrossAlignment.end,
            children: [
              _CorrectionNumberField(
                key: ProgressScreen.correctionRepetitionsFieldKey(
                  widget.detail.sessionSet.id,
                ),
                controller: _repetitionsController,
                label: l10n.progressCorrectionRepetitionsLabel,
                enabled: enabled,
              ),
              _CorrectionNumberField(
                key: ProgressScreen.correctionLoadFieldKey(
                  widget.detail.sessionSet.id,
                ),
                controller: _loadController,
                label: l10n.progressCorrectionLoadLabel,
                suffixText: widget.formatter.unitSystem.massUnit.symbol,
                allowDecimal: true,
                enabled: enabled,
              ),
              _CorrectionNumberField(
                key: ProgressScreen.correctionRirFieldKey(
                  widget.detail.sessionSet.id,
                ),
                controller: _rirController,
                label: l10n.progressCorrectionRirLabel,
                enabled: enabled,
              ),
              _CorrectionOutcomeField(
                key: ProgressScreen.correctionOutcomeFieldKey(
                  widget.detail.sessionSet.id,
                ),
                value: _selectedResult,
                enabled: enabled,
                onChanged: (value) {
                  setState(() {
                    _selectedResult = value;
                  });
                },
              ),
              FilledButton.icon(
                key: ProgressScreen.correctionSaveButtonKey(
                  widget.detail.sessionSet.id,
                ),
                onPressed: enabled ? () => _saveCorrection(context) : null,
                icon: const Icon(Icons.history_toggle_off),
                label: Text(l10n.progressCorrectionSave),
              ),
            ],
          ),
      ],
    );
  }

  Future<void> _saveCorrection(BuildContext context) async {
    final l10n = AppLocalizations.of(context);
    final repetitionText = _repetitionsController.text.trim();
    final repetitions = repetitionText.isEmpty
        ? null
        : int.tryParse(repetitionText);
    if (repetitionText.isNotEmpty && (repetitions == null || repetitions < 0)) {
      _showSnackBar(context, l10n.progressCorrectionInvalid);
      return;
    }

    final loadText = _loadController.text.trim();
    final loadKilograms = _parseLoadKilograms(
      loadText,
      widget.formatter.unitSystem.massUnit,
    );
    if (loadText.isNotEmpty && loadKilograms == null) {
      _showSnackBar(context, l10n.progressCorrectionInvalid);
      return;
    }

    final rirText = _rirController.text.trim();
    final rir = rirText.isEmpty ? null : int.tryParse(rirText);
    if (rirText.isNotEmpty && (rir == null || rir < 0 || rir > 10)) {
      _showSnackBar(context, l10n.progressCorrectionInvalid);
      return;
    }
    if (repetitions == null &&
        loadKilograms == null &&
        rir == null &&
        _selectedResult == null) {
      _showSnackBar(context, l10n.progressCorrectionInvalid);
      return;
    }

    try {
      await ref
          .read(workoutHistoryCorrectionControllerProvider.notifier)
          .correctSet(
            detail: widget.detail,
            repetitions: repetitions,
            loadKilograms: loadKilograms,
            rir: rir,
            result: _selectedResult,
          );
      if (!context.mounted) {
        return;
      }
      _showSnackBar(context, l10n.progressCorrectionSaved);
    } catch (_) {
      if (!context.mounted) {
        return;
      }
      _showSnackBar(context, l10n.progressCorrectionFailed);
    }
  }

  void _resetInputs() {
    final log = widget.detail.latestLog;
    _inputSeed = _seedFor(widget);
    _repetitionsController.text = log?.repetitions?.toString() ?? '';
    _loadController.text = _formatLoadInput(
      log?.loadKilograms,
      widget.formatter.unitSystem.massUnit,
    );
    _rirController.text = log?.rir?.toString() ?? '';
    _selectedResult = log?.result;
  }

  String _seedFor(_CorrectionForm widget) {
    final log = widget.detail.latestLog;
    return [
      widget.detail.sessionSet.id,
      log?.id ?? '',
      log?.revision.toString() ?? '',
      widget.formatter.unitSystem.massUnit.name,
    ].join(':');
  }
}

class _CorrectionOutcomeField extends StatelessWidget {
  const _CorrectionOutcomeField({
    required this.value,
    required this.enabled,
    required this.onChanged,
    super.key,
  });

  static const _noOutcomeValue = 'none';

  final SetResult? value;
  final bool enabled;
  final ValueChanged<SetResult?> onChanged;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return SizedBox(
      width: 220,
      child: DropdownButtonFormField<String>(
        initialValue: value?.name ?? _noOutcomeValue,
        isExpanded: true,
        decoration: InputDecoration(
          labelText: l10n.progressCorrectionOutcomeLabel,
        ),
        items: [
          DropdownMenuItem(
            value: _noOutcomeValue,
            child: Text(l10n.todayOutcomeNone, overflow: TextOverflow.ellipsis),
          ),
          for (final result in SetResult.values)
            DropdownMenuItem(
              value: result.name,
              child: Text(
                _setResultLabel(l10n, result),
                overflow: TextOverflow.ellipsis,
              ),
            ),
        ],
        onChanged: enabled
            ? (selectedValue) => onChanged(_setResultFromValue(selectedValue))
            : null,
      ),
    );
  }
}

class _CorrectionNumberField extends StatelessWidget {
  const _CorrectionNumberField({
    required this.controller,
    required this.label,
    required this.enabled,
    this.suffixText,
    this.allowDecimal = false,
    super.key,
  });

  final TextEditingController controller;
  final String label;
  final String? suffixText;
  final bool enabled;
  final bool allowDecimal;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 140,
      child: TextFormField(
        controller: controller,
        enabled: enabled,
        decoration: InputDecoration(labelText: label, suffixText: suffixText),
        keyboardType: TextInputType.numberWithOptions(decimal: allowDecimal),
        textInputAction: TextInputAction.done,
      ),
    );
  }
}

class _PersonalRecordsSection extends StatelessWidget {
  const _PersonalRecordsSection({
    required this.records,
    required this.catalog,
    required this.formatter,
  });

  final List<PersonalRecordSummary> records;
  final ExerciseCatalog? catalog;
  final UnitFormatter formatter;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);

    return Column(
      key: ProgressScreen.personalRecordsSectionKey,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.progressPersonalRecordsTitle,
          style: theme.textTheme.titleLarge,
        ),
        const SizedBox(height: AppSpacing.sm),
        if (records.isEmpty)
          Card(
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Text(l10n.progressPersonalRecordsEmpty),
            ),
          )
        else
          for (final record in records)
            Card(
              key: ProgressScreen.personalRecordCardKey(record.exerciseId),
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.md),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _exerciseName(context, catalog, record.exerciseId),
                      style: theme.textTheme.titleMedium,
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    if (record.bestLoad != null)
                      Text(
                        l10n.progressBestLoad(
                          _formatMassValue(formatter, record.bestLoad!.value),
                        ),
                      ),
                    if (record.bestRepetitions != null)
                      Text(
                        l10n.progressBestRepetitions(
                          record.bestRepetitions!.value.round(),
                        ),
                      ),
                    if (record.bestVolume != null)
                      Text(
                        l10n.progressBestVolume(
                          _formatVolumeValue(
                            context,
                            formatter,
                            record.bestVolume!,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
      ],
    );
  }
}

String _measurementComparisonLine({
  required BuildContext context,
  required MeasurementHistoryComparison comparison,
  required UnitFormatter formatter,
}) {
  final l10n = AppLocalizations.of(context);
  return l10n.progressMeasurementComparisonLine(
    _measurementFieldLabel(l10n, comparison.field),
    _formatMeasurementHistoryValue(
      context,
      formatter,
      comparison.valueKind,
      comparison.baselineValue,
    ),
    _formatMeasurementHistoryValue(
      context,
      formatter,
      comparison.valueKind,
      comparison.latestValue,
    ),
    _formatMeasurementHistoryDelta(
      context,
      formatter,
      comparison.valueKind,
      comparison.delta,
    ),
  );
}

String _measurementSideComparisonLine({
  required BuildContext context,
  required MeasurementHistorySideComparison comparison,
  required UnitFormatter formatter,
}) {
  final l10n = AppLocalizations.of(context);
  return l10n.progressMeasurementSideComparisonLine(
    _measurementPairLabel(l10n, comparison.pairKey),
    _formatLengthValue(formatter, comparison.leftValue),
    _formatLengthValue(formatter, comparison.rightValue),
    _formatMeasurementHistoryDelta(
      context,
      formatter,
      MeasurementValueKind.lengthCentimeters,
      comparison.delta,
    ),
    _formatDecimal(context, comparison.absoluteDeltaPercent, 1),
  );
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

String _formatDateTime(BuildContext context, DateTime value) {
  final local = value.toLocal();
  final material = MaterialLocalizations.of(context);
  return '${material.formatShortDate(local)} '
      '${material.formatTimeOfDay(TimeOfDay.fromDateTime(local))}';
}

String _formatMeasurementHistoryValue(
  BuildContext context,
  UnitFormatter formatter,
  MeasurementValueKind valueKind,
  double value,
) {
  return switch (valueKind) {
    MeasurementValueKind.lengthCentimeters => _formatLengthValue(
      formatter,
      value,
    ),
    MeasurementValueKind.massKilograms => _formatMassValue(formatter, value),
    MeasurementValueKind.percentage =>
      '${_formatDecimal(context, value, _fractionDigits(value))}%',
  };
}

String _formatMeasurementHistoryDelta(
  BuildContext context,
  UnitFormatter formatter,
  MeasurementValueKind valueKind,
  double delta,
) {
  if (delta.abs() < 0.0001) {
    return AppLocalizations.of(context).progressTrendNoChange;
  }

  final sign = delta > 0 ? '+' : '-';
  return '$sign${_formatMeasurementHistoryValue(context, formatter, valueKind, delta.abs())}';
}

String _prescriptionSummary(
  AppLocalizations l10n,
  UnitFormatter formatter,
  PrescribedSetRecord? prescribedSet,
) {
  if (prescribedSet == null) {
    return l10n.todaySetPrescriptionUnavailable;
  }

  final reps =
      prescribedSet.minimumRepetitions == prescribedSet.maximumRepetitions
      ? l10n.todayFixedRepetitions(prescribedSet.minimumRepetitions)
      : l10n.todayRangeRepetitions(
          prescribedSet.minimumRepetitions,
          prescribedSet.maximumRepetitions,
        );
  final rir = prescribedSet.targetRir == null
      ? l10n.programBuilderRirOff
      : l10n.programBuilderRirSummary(prescribedSet.targetRir!);
  final load = prescribedSet.loadKilograms == null
      ? l10n.programBuilderLoadUnset
      : _formatMassValue(formatter, prescribedSet.loadKilograms!);

  return l10n.todaySetPrescriptionSummary(reps, rir, load);
}

String _actualSummary(
  AppLocalizations l10n,
  UnitFormatter formatter,
  ActualSetLogRecord? log,
) {
  if (log == null) {
    return l10n.progressNoActualLog;
  }

  final reps = log.repetitions == null
      ? l10n.todayRepetitionsNotRecorded
      : l10n.todayFixedRepetitions(log.repetitions!);
  final load = log.loadKilograms == null
      ? l10n.programBuilderLoadUnset
      : _formatMassValue(formatter, log.loadKilograms!);
  final rir = log.rir == null
      ? l10n.programBuilderRirOff
      : l10n.programBuilderRirSummary(log.rir!);
  final outcome = log.result == null
      ? l10n.todayOutcomeNone
      : _setResultLabel(l10n, log.result!);

  return l10n.todaySetActualSummary(reps, load, rir, outcome);
}

String _formatMassValue(UnitFormatter formatter, double kilograms) {
  return formatter.formatMass(
    Mass.kilograms(kilograms),
    fractionDigits: _massFractionDigits(formatter, kilograms),
  );
}

String _formatVolumeValue(
  BuildContext context,
  UnitFormatter formatter,
  PersonalRecordMark mark,
) {
  final log = mark.setDetail.latestLog;
  final repetitions = log?.repetitions;
  final loadKilograms = log?.loadKilograms;
  if (repetitions == null || loadKilograms == null) {
    return NumberFormat.decimalPattern(
      Localizations.localeOf(context).toLanguageTag(),
    ).format(mark.value);
  }

  final unit = formatter.unitSystem.massUnit;
  final volume = Mass.kilograms(loadKilograms).inUnit(unit) * repetitions;
  final formatted = NumberFormat.decimalPatternDigits(
    locale: Localizations.localeOf(context).toLanguageTag(),
    decimalDigits: volume == volume.roundToDouble() ? 0 : 1,
  ).format(volume);
  return '$formatted ${unit.symbol} reps';
}

String _trendLine({
  required BuildContext context,
  required String metricLabel,
  required ProgressTrendValueUnit unit,
  required double latestValue,
  required double delta,
  required int pointCount,
  required UnitFormatter formatter,
}) {
  final l10n = AppLocalizations.of(context);
  return l10n.progressTrendLine(
    metricLabel,
    _formatTrendValue(context, formatter, unit, latestValue),
    _formatTrendDelta(context, formatter, unit, delta),
    pointCount,
  );
}

String _formatTrendDelta(
  BuildContext context,
  UnitFormatter formatter,
  ProgressTrendValueUnit unit,
  double delta,
) {
  if (delta.abs() < 0.0001) {
    return AppLocalizations.of(context).progressTrendNoChange;
  }

  final sign = delta > 0 ? '+' : '-';
  return '$sign${_formatTrendValue(context, formatter, unit, delta.abs())}';
}

String _formatTrendValue(
  BuildContext context,
  UnitFormatter formatter,
  ProgressTrendValueUnit unit,
  double value,
) {
  return switch (unit) {
    ProgressTrendValueUnit.kilograms => _formatMassValue(formatter, value),
    ProgressTrendValueUnit.centimeters => _formatLengthValue(formatter, value),
    ProgressTrendValueUnit.percentage =>
      '${_formatDecimal(context, value, _fractionDigits(value))}%',
    ProgressTrendValueUnit.repetitions => AppLocalizations.of(
      context,
    ).todayFixedRepetitions(value.round()),
    ProgressTrendValueUnit.kilogramRepetitions => _formatKilogramRepetitions(
      context,
      formatter,
      value,
    ),
  };
}

String _formatLengthValue(UnitFormatter formatter, double centimeters) {
  return formatter.formatLength(
    Length.centimeters(centimeters),
    fractionDigits: _lengthFractionDigits(formatter, centimeters),
  );
}

String _formatKilogramRepetitions(
  BuildContext context,
  UnitFormatter formatter,
  double kilogramRepetitions,
) {
  final unit = formatter.unitSystem.massUnit;
  final displayValue = switch (unit) {
    MassUnit.kilogram => kilogramRepetitions,
    MassUnit.pound => kilogramRepetitions / Mass.kilogramsPerPound,
  };
  return '${_formatDecimal(context, displayValue, _fractionDigits(displayValue))} '
      '${unit.symbol} reps';
}

String _formatDecimal(BuildContext context, double value, int fractionDigits) {
  return NumberFormat.decimalPatternDigits(
    locale: Localizations.localeOf(context).toLanguageTag(),
    decimalDigits: fractionDigits,
  ).format(value);
}

int _massFractionDigits(UnitFormatter formatter, double kilograms) {
  final displayValue = Mass.kilograms(
    kilograms,
  ).inUnit(formatter.unitSystem.massUnit);
  return displayValue == displayValue.roundToDouble() ? 0 : 1;
}

int _lengthFractionDigits(UnitFormatter formatter, double centimeters) {
  final displayValue = Length.centimeters(
    centimeters,
  ).inUnit(formatter.unitSystem.lengthUnit);
  return _fractionDigits(displayValue);
}

int _fractionDigits(double value) {
  return value == value.roundToDouble() ? 0 : 1;
}

String _measurementTrendLabel(
  AppLocalizations l10n,
  MeasurementTrendMetric metric,
) {
  return switch (metric) {
    MeasurementTrendMetric.height => l10n.progressTrendHeight,
    MeasurementTrendMetric.weight => l10n.progressTrendWeight,
    MeasurementTrendMetric.torsoLength => l10n.progressTrendTorsoLength,
    MeasurementTrendMetric.chest => l10n.progressTrendChest,
    MeasurementTrendMetric.waist => l10n.progressTrendWaist,
    MeasurementTrendMetric.hips => l10n.progressTrendHips,
    MeasurementTrendMetric.leftUpperArm => l10n.progressTrendLeftUpperArm,
    MeasurementTrendMetric.rightUpperArm => l10n.progressTrendRightUpperArm,
    MeasurementTrendMetric.leftForearm => l10n.progressTrendLeftForearm,
    MeasurementTrendMetric.rightForearm => l10n.progressTrendRightForearm,
    MeasurementTrendMetric.leftThigh => l10n.progressTrendLeftThigh,
    MeasurementTrendMetric.rightThigh => l10n.progressTrendRightThigh,
    MeasurementTrendMetric.leftCalf => l10n.progressTrendLeftCalf,
    MeasurementTrendMetric.rightCalf => l10n.progressTrendRightCalf,
    MeasurementTrendMetric.bodyFat => l10n.progressTrendBodyFat,
  };
}

String _measurementFieldLabel(
  AppLocalizations l10n,
  BodyMeasurementField field,
) {
  return switch (field) {
    BodyMeasurementField.heightCentimeters => l10n.progressTrendHeight,
    BodyMeasurementField.weightKilograms => l10n.progressTrendWeight,
    BodyMeasurementField.torsoLengthCentimeters =>
      l10n.progressTrendTorsoLength,
    BodyMeasurementField.chestCircumferenceCentimeters =>
      l10n.progressTrendChest,
    BodyMeasurementField.waistCircumferenceCentimeters =>
      l10n.progressTrendWaist,
    BodyMeasurementField.hipCircumferenceCentimeters => l10n.progressTrendHips,
    BodyMeasurementField.leftUpperArmCircumferenceCentimeters =>
      l10n.progressTrendLeftUpperArm,
    BodyMeasurementField.rightUpperArmCircumferenceCentimeters =>
      l10n.progressTrendRightUpperArm,
    BodyMeasurementField.leftForearmCircumferenceCentimeters =>
      l10n.progressTrendLeftForearm,
    BodyMeasurementField.rightForearmCircumferenceCentimeters =>
      l10n.progressTrendRightForearm,
    BodyMeasurementField.leftThighCircumferenceCentimeters =>
      l10n.progressTrendLeftThigh,
    BodyMeasurementField.rightThighCircumferenceCentimeters =>
      l10n.progressTrendRightThigh,
    BodyMeasurementField.leftCalfCircumferenceCentimeters =>
      l10n.progressTrendLeftCalf,
    BodyMeasurementField.rightCalfCircumferenceCentimeters =>
      l10n.progressTrendRightCalf,
    BodyMeasurementField.bodyFatPercentage => l10n.progressTrendBodyFat,
  };
}

String _measurementPairLabel(AppLocalizations l10n, String pairKey) {
  return switch (pairKey) {
    'upper_arm' => l10n.progressMeasurementPairUpperArm,
    'forearm' => l10n.progressMeasurementPairForearm,
    'thigh' => l10n.progressMeasurementPairThigh,
    'calf' => l10n.progressMeasurementPairCalf,
    _ => humanizeCatalogIdentifier(pairKey),
  };
}

String _trainingTrendLabel(AppLocalizations l10n, TrainingTrendMetric metric) {
  return switch (metric) {
    TrainingTrendMetric.volume => l10n.progressTrendVolume,
    TrainingTrendMetric.load => l10n.progressTrendLoad,
    TrainingTrendMetric.repetitions => l10n.progressTrendRepetitions,
    TrainingTrendMetric.estimatedStrength =>
      l10n.progressTrendEstimatedStrength,
  };
}

String _setStatusText(AppLocalizations l10n, TodaySetStatus status) {
  return switch (status) {
    TodaySetStatus.pending => l10n.todayStatusPending,
    TodaySetStatus.targetMet => l10n.todayStatusTargetMet,
    TodaySetStatus.performanceMiss => l10n.todayStatusPerformanceMiss,
    TodaySetStatus.interrupted => l10n.todayStatusInterrupted,
    TodaySetStatus.painReported => l10n.todayStatusPainReported,
    TodaySetStatus.notComparable => l10n.todayStatusNotComparable,
  };
}

String _sessionStatusText(AppLocalizations l10n, TodaySessionStatus status) {
  return switch (status) {
    TodaySessionStatus.notStarted => l10n.todayStatusNotStarted,
    TodaySessionStatus.inProgress => l10n.todayStatusInProgress,
    TodaySessionStatus.successful => l10n.todayStatusSuccessful,
    TodaySessionStatus.needsReview => l10n.todayStatusNeedsReview,
    TodaySessionStatus.interrupted => l10n.todayStatusInterrupted,
    TodaySessionStatus.painReported => l10n.todayStatusPainReported,
    TodaySessionStatus.notComparable => l10n.todayStatusNotComparable,
  };
}

SetResult? _setResultFromValue(String? value) {
  if (value == null || value == _CorrectionOutcomeField._noOutcomeValue) {
    return null;
  }

  return SetResult.values.firstWhere((result) => result.name == value);
}

String _setResultLabel(AppLocalizations l10n, SetResult result) {
  return switch (result) {
    SetResult.strengthLimitation => l10n.todayOutcomeStrengthLimitation,
    SetResult.techniqueLimitation => l10n.todayOutcomeTechniqueLimitation,
    SetResult.pain => l10n.todayOutcomePain,
    SetResult.timeLimitation => l10n.todayOutcomeTimeLimitation,
    SetResult.equipmentLimitation => l10n.todayOutcomeEquipmentLimitation,
    SetResult.externalInterruption => l10n.todayOutcomeExternalInterruption,
  };
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

void _showSnackBar(BuildContext context, String message) {
  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
}
