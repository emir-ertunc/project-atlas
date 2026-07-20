import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:project_atlas/core/design_system/components/feature_root_scaffold.dart';
import 'package:project_atlas/core/design_system/tokens/app_spacing.dart';
import 'package:project_atlas/core/repositories/repository_records.dart';
import 'package:project_atlas/core/units/measurement_units.dart';
import 'package:project_atlas/core/units/unit_formatter.dart';
import 'package:project_atlas/core/units/unit_system_provider.dart';
import 'package:project_atlas/features/exercise_catalog/application/exercise_catalog_provider.dart';
import 'package:project_atlas/features/exercise_catalog/domain/exercise_catalog.dart';
import 'package:project_atlas/features/program/presentation/program_screen.dart';
import 'package:project_atlas/features/today/application/rest_timer_controller.dart';
import 'package:project_atlas/features/today/application/today_workout_controller.dart';
import 'package:project_atlas/features/today/application/workout_status_calculator.dart';
import 'package:project_atlas/features/today/platform/rest_notification_scheduler.dart';
import 'package:project_atlas/l10n/generated/app_localizations.dart';

typedef _CompleteSessionSet =
    Future<void> Function({
      required String sessionSetId,
      required int? repetitions,
      required double? loadKilograms,
      required int? rir,
      required SetResult? result,
    });

typedef _StartRestTimer =
    Future<void> Function({
      required String sourceSessionSetId,
      required String exerciseName,
      required int setNumber,
      required int durationSeconds,
      required String notificationTitle,
      required String notificationBody,
    });

class TodayScreen extends ConsumerWidget {
  const TodayScreen({super.key});

  static const path = '/today';
  static const routeName = 'today';
  static const screenKey = Key('today-screen');
  static const emptyStateKey = Key('today-empty-state');
  static const activeProgramCardKey = Key('today-active-program-card');
  static const activeSessionCardKey = Key('today-active-session-card');
  static const restoredSessionMessageKey = Key(
    'today-restored-session-message',
  );
  static const sessionStatusKey = Key('today-session-status');
  static const startSessionButtonKey = Key('today-start-session-button');
  static const retryButtonKey = Key('today-retry-button');

  static Key exerciseStatusKey(int exerciseOrder) =>
      Key('today-exercise-status-$exerciseOrder');

  static Key sessionSetTileKey(String sessionSetId) =>
      Key('today-session-set-$sessionSetId');

  static Key setStatusKey(String sessionSetId) =>
      Key('today-set-status-$sessionSetId');

  static Key actualRepetitionsFieldKey(String sessionSetId) =>
      Key('today-session-set-reps-$sessionSetId');

  static Key actualLoadFieldKey(String sessionSetId) =>
      Key('today-session-set-load-$sessionSetId');

  static Key actualRirFieldKey(String sessionSetId) =>
      Key('today-session-set-rir-$sessionSetId');

  static Key outcomeFieldKey(String sessionSetId) =>
      Key('today-session-set-outcome-$sessionSetId');

  static Key quickLoadDecreaseButtonKey(String sessionSetId) =>
      Key('today-session-set-load-decrease-$sessionSetId');

  static Key quickLoadIncreaseButtonKey(String sessionSetId) =>
      Key('today-session-set-load-increase-$sessionSetId');

  static Key completeSetButtonKey(String sessionSetId) =>
      Key('today-complete-set-$sessionSetId');

  static Key completedSetStatusKey(String sessionSetId) =>
      Key('today-completed-set-$sessionSetId');

  static const restTimerPanelKey = Key('today-rest-timer-panel');
  static const restTimerDismissButtonKey = Key('today-rest-timer-dismiss');

  static Key previousPerformanceKey(String sessionSetId) =>
      Key('today-previous-performance-$sessionSetId');

  static Key trainingDayChipKey(int trainingDayOrder) =>
      Key('today-training-day-$trainingDayOrder');

  static Key exercisePlanTileKey(String exerciseId) =>
      Key('today-exercise-plan-$exerciseId');

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final todayState = ref.watch(todayWorkoutControllerProvider);

    return FeatureRootScaffold(
      key: screenKey,
      title: l10n.todayNavigationLabel,
      icon: Icons.today_outlined,
      child: todayState.when(
        data: (state) => _TodayContent(state: state),
        loading: () => Center(
          child: Semantics(
            liveRegion: true,
            child: const CircularProgressIndicator(),
          ),
        ),
        error: (error, stackTrace) => _TodayErrorState(
          onRetry: () => ref.invalidate(todayWorkoutControllerProvider),
        ),
      ),
    );
  }
}

class _TodayContent extends ConsumerWidget {
  const _TodayContent({required this.state});

  final TodayWorkoutState state;

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
    final selectedDay = state.selectedTrainingDay;

    return SingleChildScrollView(
      restorationId: 'today-scroll',
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Semantics(
            header: true,
            child: Text(
              l10n.todayNavigationLabel,
              key: FeatureRootScaffold.placeholderTitleKey,
              style: theme.textTheme.headlineSmall,
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            l10n.todayScreenSubtitle,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          if (state.activeSession != null) ...[
            _ActiveSessionCard(
              session: state.activeSession!,
              catalog: catalog,
              formatter: formatter,
              unitSystem: unitSystem,
              onCompleteSet: ref
                  .read(todayWorkoutControllerProvider.notifier)
                  .completeSessionSet,
            ),
            const SizedBox(height: AppSpacing.md),
          ],
          if (state.activeProgramPlan == null)
            _NoProgramCard(onOpenProgram: () => context.go(ProgramScreen.path))
          else ...[
            _ActiveProgramCard(plan: state.activeProgramPlan!),
            const SizedBox(height: AppSpacing.md),
            _TrainingDaySelector(
              plan: state.activeProgramPlan!,
              selectedTrainingDayOrder: state.selectedTrainingDayOrder,
              onSelected: (trainingDayOrder) => ref
                  .read(todayWorkoutControllerProvider.notifier)
                  .selectTrainingDay(trainingDayOrder),
            ),
            const SizedBox(height: AppSpacing.md),
            if (selectedDay == null || !selectedDay.hasExercises)
              _NoExercisesCard()
            else
              _TrainingDayPlanCard(
                day: selectedDay,
                catalog: catalog,
                formatter: formatter,
              ),
            const SizedBox(height: AppSpacing.md),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                key: TodayScreen.startSessionButtonKey,
                onPressed:
                    selectedDay == null ||
                        !selectedDay.hasExercises ||
                        state.activeSession != null
                    ? null
                    : () => _startSession(context, ref),
                icon: const Icon(Icons.play_arrow),
                label: Text(l10n.todayStartWorkout),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Future<void> _startSession(BuildContext context, WidgetRef ref) async {
    final l10n = AppLocalizations.of(context);
    try {
      await ref
          .read(todayWorkoutControllerProvider.notifier)
          .startSelectedSession();
      if (!context.mounted) {
        return;
      }
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l10n.todaySessionStarted)));
    } catch (_) {
      if (!context.mounted) {
        return;
      }
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l10n.todaySessionStartFailed)));
    }
  }
}

class _TodayErrorState extends StatelessWidget {
  const _TodayErrorState({required this.onRetry});

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
            Text(l10n.todayLoadError, textAlign: TextAlign.center),
            const SizedBox(height: AppSpacing.md),
            FilledButton(
              key: TodayScreen.retryButtonKey,
              onPressed: onRetry,
              child: Text(l10n.todayRetry),
            ),
          ],
        ),
      ),
    );
  }
}

class _NoProgramCard extends StatelessWidget {
  const _NoProgramCard({required this.onOpenProgram});

  final VoidCallback onOpenProgram;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Card(
      key: TodayScreen.emptyStateKey,
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.todayNoActiveProgramTitle,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(l10n.todayNoActiveProgramMessage),
            const SizedBox(height: AppSpacing.md),
            OutlinedButton.icon(
              onPressed: onOpenProgram,
              icon: const Icon(Icons.calendar_view_week_outlined),
              label: Text(l10n.todayOpenProgramBuilder),
            ),
          ],
        ),
      ),
    );
  }
}

class _ActiveProgramCard extends StatelessWidget {
  const _ActiveProgramCard({required this.plan});

  final TodayProgramPlan plan;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Card(
      key: TodayScreen.activeProgramCardKey,
      child: ListTile(
        leading: const Icon(Icons.assignment_turned_in_outlined),
        title: Text(plan.program.name),
        subtitle: Text(
          l10n.todayActiveProgramSummary(
            plan.version.versionNumber,
            plan.trainingDays.length,
          ),
        ),
      ),
    );
  }
}

class _TrainingDaySelector extends StatelessWidget {
  const _TrainingDaySelector({
    required this.plan,
    required this.selectedTrainingDayOrder,
    required this.onSelected,
  });

  final TodayProgramPlan plan;
  final int? selectedTrainingDayOrder;
  final ValueChanged<int> onSelected;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.todayChooseTrainingDay,
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: AppSpacing.sm),
        Wrap(
          spacing: AppSpacing.sm,
          runSpacing: AppSpacing.xs,
          children: [
            for (final day in plan.trainingDays)
              ChoiceChip(
                key: TodayScreen.trainingDayChipKey(day.trainingDayOrder),
                label: Text(day.day.name),
                selected: day.trainingDayOrder == selectedTrainingDayOrder,
                onSelected: (_) => onSelected(day.trainingDayOrder),
              ),
          ],
        ),
      ],
    );
  }
}

class _TrainingDayPlanCard extends StatelessWidget {
  const _TrainingDayPlanCard({
    required this.day,
    required this.catalog,
    required this.formatter,
  });

  final TodayTrainingDayPlan day;
  final ExerciseCatalog? catalog;
  final UnitFormatter formatter;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(day.day.name, style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: AppSpacing.xs),
            Text(
              l10n.todayTrainingDaySummary(
                day.exerciseCount,
                day.totalSetCount,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            for (final exercise in day.exercisePlans)
              _ExercisePlanTile(
                exercise: exercise,
                catalog: catalog,
                formatter: formatter,
              ),
          ],
        ),
      ),
    );
  }
}

class _ExercisePlanTile extends StatelessWidget {
  const _ExercisePlanTile({
    required this.exercise,
    required this.catalog,
    required this.formatter,
  });

  final TodayExercisePlan exercise;
  final ExerciseCatalog? catalog;
  final UnitFormatter formatter;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final localeCode = Localizations.localeOf(context).languageCode;
    final entry = catalog?.exerciseById(exercise.exerciseId);

    return ListTile(
      key: TodayScreen.exercisePlanTileKey(exercise.exerciseId),
      contentPadding: EdgeInsets.zero,
      title: Text(
        entry?.name(localeCode) ??
            humanizeCatalogIdentifier(exercise.exerciseId),
      ),
      subtitle: Text(_summary(l10n, formatter, exercise)),
    );
  }

  String _summary(
    AppLocalizations l10n,
    UnitFormatter formatter,
    TodayExercisePlan exercise,
  ) {
    final firstSet = exercise.firstSet;
    final repetitions =
        firstSet.minimumRepetitions == firstSet.maximumRepetitions
        ? l10n.todayFixedRepetitions(firstSet.minimumRepetitions)
        : l10n.todayRangeRepetitions(
            firstSet.minimumRepetitions,
            firstSet.maximumRepetitions,
          );
    final rir = firstSet.targetRir == null
        ? l10n.programBuilderRirOff
        : l10n.programBuilderRirSummary(firstSet.targetRir!);
    final load = firstSet.loadKilograms == null
        ? l10n.programBuilderLoadUnset
        : formatter.formatMass(
            Mass.kilograms(firstSet.loadKilograms!),
            fractionDigits: firstSet.loadKilograms! % 1 == 0 ? 0 : 1,
          );

    return l10n.todayExercisePrescriptionSummary(
      exercise.setCount,
      repetitions,
      rir,
      load,
      firstSet.restSeconds,
    );
  }
}

class _NoExercisesCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.todayNoExercisesTitle,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(l10n.todayNoExercisesMessage),
          ],
        ),
      ),
    );
  }
}

class _ActiveSessionCard extends ConsumerWidget {
  const _ActiveSessionCard({
    required this.session,
    required this.catalog,
    required this.formatter,
    required this.unitSystem,
    required this.onCompleteSet,
  });

  final TodaySessionSummary session;
  final ExerciseCatalog? catalog;
  final UnitFormatter formatter;
  final UnitSystem unitSystem;
  final _CompleteSessionSet onCompleteSet;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final restTimerState = ref.watch(restTimerControllerProvider);
    final lastSetId = session.setSummaries.isEmpty
        ? null
        : session.setSummaries.last.sessionSet.id;

    return Card(
      key: TodayScreen.activeSessionCardKey,
      color: Theme.of(context).colorScheme.primaryContainer,
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.fitness_center),
              title: Text(l10n.todaySessionInProgressTitle),
              subtitle: Text(
                l10n.todaySessionInProgressSummary(
                  session.exerciseCount,
                  session.totalSetCount,
                ),
              ),
            ),
            Text(l10n.todaySessionInProgressMessage),
            if (session.restoredAfterProcessTermination) ...[
              const SizedBox(height: AppSpacing.xxs),
              Text(
                key: TodayScreen.restoredSessionMessageKey,
                l10n.todaySessionRestoredMessage,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.onPrimaryContainer,
                ),
              ),
            ],
            const SizedBox(height: AppSpacing.xs),
            Text(
              l10n.todaySetProgressSummary(
                session.completedSetCount,
                session.totalSetCount,
              ),
            ),
            const SizedBox(height: AppSpacing.xxs),
            Text(
              key: TodayScreen.sessionStatusKey,
              l10n.todaySessionStatusLabel(
                _sessionStatusText(l10n, session.status),
              ),
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.onPrimaryContainer,
              ),
            ),
            if (restTimerState.hasTimer) ...[
              const SizedBox(height: AppSpacing.sm),
              _RestTimerPanel(state: restTimerState),
            ],
            if (session.exerciseSummaries.isNotEmpty) ...[
              const SizedBox(height: AppSpacing.md),
              for (final exercise in session.exerciseSummaries)
                _ActiveSessionExerciseSection(
                  exercise: exercise,
                  catalog: catalog,
                  formatter: formatter,
                  unitSystem: unitSystem,
                  lastSessionSetId: lastSetId,
                  onCompleteSet: onCompleteSet,
                  onStartRestTimer: ref
                      .read(restTimerControllerProvider.notifier)
                      .startRestTimer,
                ),
            ],
          ],
        ),
      ),
    );
  }
}

class _ActiveSessionExerciseSection extends StatelessWidget {
  const _ActiveSessionExerciseSection({
    required this.exercise,
    required this.catalog,
    required this.formatter,
    required this.unitSystem,
    required this.lastSessionSetId,
    required this.onCompleteSet,
    required this.onStartRestTimer,
  });

  final TodaySessionExerciseSummary exercise;
  final ExerciseCatalog? catalog;
  final UnitFormatter formatter;
  final UnitSystem unitSystem;
  final String? lastSessionSetId;
  final _CompleteSessionSet onCompleteSet;
  final _StartRestTimer onStartRestTimer;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);
    final exerciseName = _exerciseName(context, exercise.exerciseId);

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(exerciseName, style: theme.textTheme.titleMedium),
          const SizedBox(height: AppSpacing.xs),
          Text(
            l10n.todayExerciseActiveSetSummary(exercise.setCount),
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onPrimaryContainer,
            ),
          ),
          const SizedBox(height: AppSpacing.xxs),
          Text(
            key: TodayScreen.exerciseStatusKey(exercise.exerciseOrder),
            l10n.todayExerciseStatusLabel(
              _exerciseStatusText(l10n, exercise.status),
            ),
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onPrimaryContainer,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          for (final set in exercise.setSummaries)
            _SessionSetLogger(
              summary: set,
              exerciseName: exerciseName,
              formatter: formatter,
              unitSystem: unitSystem,
              shouldStartRestTimer: set.sessionSet.id != lastSessionSetId,
              onCompleteSet: onCompleteSet,
              onStartRestTimer: onStartRestTimer,
            ),
        ],
      ),
    );
  }

  String _exerciseName(BuildContext context, String exerciseId) {
    final localeCode = Localizations.localeOf(context).languageCode;
    return catalog?.exerciseById(exerciseId)?.name(localeCode) ??
        humanizeCatalogIdentifier(exerciseId);
  }
}

class _RestTimerPanel extends ConsumerStatefulWidget {
  const _RestTimerPanel({required this.state});

  final RestTimerState state;

  @override
  ConsumerState<_RestTimerPanel> createState() => _RestTimerPanelState();
}

class _RestTimerPanelState extends ConsumerState<_RestTimerPanel> {
  Timer? _ticker;

  @override
  void initState() {
    super.initState();
    _syncTicker();
  }

  @override
  void didUpdateWidget(covariant _RestTimerPanel oldWidget) {
    super.didUpdateWidget(oldWidget);
    _syncTicker();
  }

  @override
  void dispose() {
    _ticker?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final timer = widget.state.timer;
    if (timer == null) {
      return const SizedBox.shrink();
    }

    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final remainingSeconds = timer.remainingSeconds(DateTime.now().toUtc());
    final isComplete =
        widget.state.phase == RestTimerPhase.completed || remainingSeconds == 0;

    return Container(
      key: TodayScreen.restTimerPanelKey,
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.sm),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: theme.colorScheme.primary),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            isComplete ? Icons.notifications_active : Icons.timer_outlined,
            color: theme.colorScheme.primary,
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.todayRestTimerTitle,
                  style: theme.textTheme.labelLarge,
                ),
                const SizedBox(height: AppSpacing.xxs),
                Text(
                  isComplete
                      ? l10n.todayRestTimerComplete
                      : l10n.todayRestTimerRunning(
                          timer.exerciseName,
                          timer.setNumber,
                          _formatRestDuration(remainingSeconds),
                        ),
                ),
                if (widget.state.notificationResult != null) ...[
                  const SizedBox(height: AppSpacing.xxs),
                  Text(
                    _notificationStatusText(
                      l10n,
                      widget.state.notificationResult!.status,
                    ),
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ],
            ),
          ),
          TextButton(
            key: TodayScreen.restTimerDismissButtonKey,
            onPressed: () => ref
                .read(restTimerControllerProvider.notifier)
                .cancelRestTimer(),
            child: Text(l10n.todayRestTimerDismiss),
          ),
        ],
      ),
    );
  }

  void _syncTicker() {
    final shouldTick =
        widget.state.timer != null &&
        widget.state.phase == RestTimerPhase.running;
    if (!shouldTick) {
      _ticker?.cancel();
      _ticker = null;
      return;
    }
    if (_ticker != null) {
      return;
    }

    _ticker = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) {
        return;
      }
      ref.read(restTimerControllerProvider.notifier).markRestTimerCompleted();
      setState(() {});
    });
  }
}

final class _RestTimerRequest {
  const _RestTimerRequest({
    required this.sourceSessionSetId,
    required this.exerciseName,
    required this.setNumber,
    required this.durationSeconds,
    required this.notificationTitle,
    required this.notificationBody,
  });

  final String sourceSessionSetId;
  final String exerciseName;
  final int setNumber;
  final int durationSeconds;
  final String notificationTitle;
  final String notificationBody;
}

class _SessionSetLogger extends StatefulWidget {
  const _SessionSetLogger({
    required this.summary,
    required this.exerciseName,
    required this.formatter,
    required this.unitSystem,
    required this.shouldStartRestTimer,
    required this.onCompleteSet,
    required this.onStartRestTimer,
  });

  final TodaySessionSetSummary summary;
  final String exerciseName;
  final UnitFormatter formatter;
  final UnitSystem unitSystem;
  final bool shouldStartRestTimer;
  final _CompleteSessionSet onCompleteSet;
  final _StartRestTimer onStartRestTimer;

  @override
  State<_SessionSetLogger> createState() => _SessionSetLoggerState();
}

class _SessionSetLoggerState extends State<_SessionSetLogger> {
  late final TextEditingController _repetitionsController;
  late final TextEditingController _loadController;
  late final TextEditingController _rirController;
  SetResult? _selectedResult;

  @override
  void initState() {
    super.initState();
    _repetitionsController = TextEditingController(
      text: _initialRepetitionsText(),
    );
    _loadController = TextEditingController(text: _initialLoadText());
    _rirController = TextEditingController(text: _initialRirText());
    _selectedResult = widget.summary.latestLog?.result;
  }

  @override
  void didUpdateWidget(covariant _SessionSetLogger oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (_inputSeed(oldWidget) == _inputSeed(widget)) {
      return;
    }

    _repetitionsController.text = _initialRepetitionsText();
    _loadController.text = _initialLoadText();
    _rirController.text = _initialRirText();
    _selectedResult = widget.summary.latestLog?.result;
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
    final isCompleted = widget.summary.isCompleted;

    return Container(
      key: TodayScreen.sessionSetTileKey(widget.summary.sessionSet.id),
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      padding: const EdgeInsets.all(AppSpacing.sm),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: theme.colorScheme.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.todaySessionSetLabel(widget.summary.setNumber),
            style: theme.textTheme.labelLarge,
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            key: TodayScreen.setStatusKey(widget.summary.sessionSet.id),
            l10n.todaySetStatusLabel(
              _setStatusText(l10n, widget.summary.status),
            ),
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: AppSpacing.xxs),
          Text(
            _setPrescriptionSummary(l10n, widget.formatter, widget.summary),
            style: theme.textTheme.bodySmall,
          ),
          const SizedBox(height: AppSpacing.xxs),
          Text(
            key: TodayScreen.previousPerformanceKey(
              widget.summary.sessionSet.id,
            ),
            _previousPerformanceSummary(
              l10n,
              widget.formatter,
              widget.summary.previousPerformance,
            ),
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.sm,
            crossAxisAlignment: WrapCrossAlignment.end,
            children: [
              _SessionNumberField(
                key: TodayScreen.actualRepetitionsFieldKey(
                  widget.summary.sessionSet.id,
                ),
                controller: _repetitionsController,
                label: l10n.todayActualRepetitionsLabel,
                enabled: !isCompleted,
              ),
              _SessionLoadEditor(
                fieldKey: TodayScreen.actualLoadFieldKey(
                  widget.summary.sessionSet.id,
                ),
                decreaseKey: TodayScreen.quickLoadDecreaseButtonKey(
                  widget.summary.sessionSet.id,
                ),
                increaseKey: TodayScreen.quickLoadIncreaseButtonKey(
                  widget.summary.sessionSet.id,
                ),
                controller: _loadController,
                label: l10n.todayActualLoadLabel,
                unitSystem: widget.unitSystem,
                enabled: !isCompleted,
                onAdjust: _adjustLoad,
              ),
              _SessionNumberField(
                key: TodayScreen.actualRirFieldKey(
                  widget.summary.sessionSet.id,
                ),
                controller: _rirController,
                label: l10n.todayActualRirLabel,
                enabled: !isCompleted,
              ),
              _SessionOutcomeField(
                key: TodayScreen.outcomeFieldKey(widget.summary.sessionSet.id),
                value: _selectedResult,
                enabled: !isCompleted,
                onChanged: (value) {
                  setState(() {
                    _selectedResult = value;
                  });
                },
              ),
              FilledButton.icon(
                key: TodayScreen.completeSetButtonKey(
                  widget.summary.sessionSet.id,
                ),
                onPressed: isCompleted ? null : () => _completeSet(context),
                icon: const Icon(Icons.check),
                label: Text(l10n.todayCompleteSet),
              ),
            ],
          ),
          if (isCompleted && widget.summary.latestLog != null) ...[
            const SizedBox(height: AppSpacing.sm),
            Text(
              key: TodayScreen.completedSetStatusKey(
                widget.summary.sessionSet.id,
              ),
              _actualSummary(l10n, widget.formatter, widget.summary.latestLog!),
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.primary,
              ),
            ),
          ],
        ],
      ),
    );
  }

  String _initialRepetitionsText() {
    if (widget.summary.latestLog != null) {
      return widget.summary.latestLog!.repetitions?.toString() ?? '';
    }

    final repetitions = widget.summary.prescribedSet?.minimumRepetitions;
    return repetitions?.toString() ?? '';
  }

  String _initialLoadText() {
    if (widget.summary.latestLog != null) {
      return _formatLoadInput(
        widget.summary.latestLog!.loadKilograms,
        widget.unitSystem.massUnit,
      );
    }

    final loadKilograms = widget.summary.prescribedSet?.loadKilograms;
    return _formatLoadInput(loadKilograms, widget.unitSystem.massUnit);
  }

  String _initialRirText() {
    if (widget.summary.latestLog != null) {
      return widget.summary.latestLog!.rir?.toString() ?? '';
    }

    final rir = widget.summary.prescribedSet?.targetRir;
    return rir?.toString() ?? '';
  }

  String _inputSeed(_SessionSetLogger widget) {
    final log = widget.summary.latestLog;
    return [
      widget.summary.sessionSet.id,
      widget.summary.sessionSet.lifecycle.name,
      log?.id ?? '',
      widget.unitSystem.massUnit.name,
    ].join(':');
  }

  Future<void> _completeSet(BuildContext context) async {
    final l10n = AppLocalizations.of(context);
    final repetitionText = _repetitionsController.text.trim();
    final repetitions = repetitionText.isEmpty
        ? null
        : int.tryParse(repetitionText);
    if (repetitionText.isNotEmpty && (repetitions == null || repetitions < 0)) {
      _showSnackBar(context, l10n.todaySetLogInvalid);
      return;
    }

    final loadText = _loadController.text.trim();
    final loadKilograms = _parseLoadKilograms(
      loadText,
      widget.unitSystem.massUnit,
    );
    if (loadText.isNotEmpty && loadKilograms == null) {
      _showSnackBar(context, l10n.todaySetLogInvalid);
      return;
    }

    final rirText = _rirController.text.trim();
    final rir = rirText.isEmpty ? null : int.tryParse(rirText);
    if (rirText.isNotEmpty && (rir == null || rir < 0 || rir > 10)) {
      _showSnackBar(context, l10n.todaySetLogInvalid);
      return;
    }
    if (repetitions == null &&
        loadKilograms == null &&
        rir == null &&
        _selectedResult == null) {
      _showSnackBar(context, l10n.todaySetLogInvalid);
      return;
    }
    final restTimerRequest = _restTimerRequest(l10n);

    try {
      await widget.onCompleteSet(
        sessionSetId: widget.summary.sessionSet.id,
        repetitions: repetitions,
        loadKilograms: loadKilograms,
        rir: rir,
        result: _selectedResult,
      );
      if (restTimerRequest != null) {
        await widget.onStartRestTimer(
          sourceSessionSetId: restTimerRequest.sourceSessionSetId,
          exerciseName: restTimerRequest.exerciseName,
          setNumber: restTimerRequest.setNumber,
          durationSeconds: restTimerRequest.durationSeconds,
          notificationTitle: restTimerRequest.notificationTitle,
          notificationBody: restTimerRequest.notificationBody,
        );
      }
      if (!context.mounted) {
        return;
      }
      _showSnackBar(context, l10n.todaySetLogSaved);
    } catch (_) {
      if (!context.mounted) {
        return;
      }
      _showSnackBar(context, l10n.todaySetLogFailed);
    }
  }

  _RestTimerRequest? _restTimerRequest(AppLocalizations l10n) {
    final prescribedSet = widget.summary.prescribedSet;
    if (!widget.shouldStartRestTimer ||
        prescribedSet == null ||
        prescribedSet.restSeconds <= 0) {
      return null;
    }

    return _RestTimerRequest(
      sourceSessionSetId: widget.summary.sessionSet.id,
      exerciseName: widget.exerciseName,
      setNumber: widget.summary.setNumber,
      durationSeconds: prescribedSet.restSeconds,
      notificationTitle: l10n.todayRestTimerNotificationTitle,
      notificationBody: l10n.todayRestTimerNotificationBody,
    );
  }

  void _adjustLoad(double displayDelta) {
    if (widget.summary.isCompleted) {
      return;
    }

    final massUnit = widget.unitSystem.massUnit;
    final parsedKilograms = _parseLoadKilograms(_loadController.text, massUnit);
    final fallbackKilograms =
        widget.summary.latestLog?.loadKilograms ??
        widget.summary.prescribedSet?.loadKilograms ??
        0;
    final currentDisplayValue = Mass.kilograms(
      parsedKilograms ?? fallbackKilograms,
    ).inUnit(massUnit);
    final nextDisplayValue = (currentDisplayValue + displayDelta)
        .clamp(0.0, double.infinity)
        .toDouble();
    final nextKilograms = switch (massUnit) {
      MassUnit.kilogram => nextDisplayValue,
      MassUnit.pound => Mass.pounds(nextDisplayValue).kilograms,
    };

    _loadController.text = _formatLoadInput(nextKilograms, massUnit);
  }
}

class _SessionOutcomeField extends StatelessWidget {
  const _SessionOutcomeField({
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
        decoration: InputDecoration(labelText: l10n.todayOutcomeLabel),
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

class _SessionLoadEditor extends StatelessWidget {
  const _SessionLoadEditor({
    required this.fieldKey,
    required this.decreaseKey,
    required this.increaseKey,
    required this.controller,
    required this.label,
    required this.unitSystem,
    required this.enabled,
    required this.onAdjust,
  });

  final Key fieldKey;
  final Key decreaseKey;
  final Key increaseKey;
  final TextEditingController controller;
  final String label;
  final UnitSystem unitSystem;
  final bool enabled;
  final ValueChanged<double> onAdjust;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final step = _quickLoadStep(unitSystem.massUnit);

    return SizedBox(
      width: 260,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          IconButton(
            key: decreaseKey,
            tooltip: l10n.todayQuickLoadDecrease,
            onPressed: enabled ? () => onAdjust(-step) : null,
            icon: const Icon(Icons.remove),
          ),
          Expanded(
            child: _SessionNumberField(
              key: fieldKey,
              controller: controller,
              label: label,
              suffixText: unitSystem.massUnit.symbol,
              enabled: enabled,
              allowDecimal: true,
              width: double.infinity,
            ),
          ),
          IconButton(
            key: increaseKey,
            tooltip: l10n.todayQuickLoadIncrease,
            onPressed: enabled ? () => onAdjust(step) : null,
            icon: const Icon(Icons.add),
          ),
        ],
      ),
    );
  }
}

class _SessionNumberField extends StatelessWidget {
  const _SessionNumberField({
    required this.controller,
    required this.label,
    required this.enabled,
    this.suffixText,
    this.allowDecimal = false,
    this.width = 116,
    super.key,
  });

  final TextEditingController controller;
  final String label;
  final String? suffixText;
  final bool enabled;
  final bool allowDecimal;
  final double width;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
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

String _setPrescriptionSummary(
  AppLocalizations l10n,
  UnitFormatter formatter,
  TodaySessionSetSummary summary,
) {
  final prescribedSet = summary.prescribedSet;
  if (prescribedSet == null) {
    return l10n.todaySetPrescriptionUnavailable;
  }

  final repetitionTarget =
      prescribedSet.minimumRepetitions == prescribedSet.maximumRepetitions
      ? l10n.todayFixedRepetitions(prescribedSet.minimumRepetitions)
      : l10n.todayRangeRepetitions(
          prescribedSet.minimumRepetitions,
          prescribedSet.maximumRepetitions,
        );
  final rirTarget = prescribedSet.targetRir == null
      ? l10n.programBuilderRirOff
      : l10n.programBuilderRirSummary(prescribedSet.targetRir!);
  final loadTarget = prescribedSet.loadKilograms == null
      ? l10n.programBuilderLoadUnset
      : formatter.formatMass(
          Mass.kilograms(prescribedSet.loadKilograms!),
          fractionDigits: _loadFractionDigits(
            prescribedSet.loadKilograms!,
            formatter.unitSystem.massUnit,
          ),
        );

  return l10n.todaySetPrescriptionSummary(
    repetitionTarget,
    rirTarget,
    loadTarget,
  );
}

String _previousPerformanceSummary(
  AppLocalizations l10n,
  UnitFormatter formatter,
  ExerciseSetPerformanceRecord? performance,
) {
  if (performance == null) {
    return l10n.todayPreviousPerformanceUnavailable;
  }

  final log = performance.log;
  final repetitionTarget = log.repetitions == null
      ? l10n.todayRepetitionsNotRecorded
      : l10n.todayFixedRepetitions(log.repetitions!);
  final loadTarget = log.loadKilograms == null
      ? l10n.programBuilderLoadUnset
      : formatter.formatMass(
          Mass.kilograms(log.loadKilograms!),
          fractionDigits: _loadFractionDigits(
            log.loadKilograms!,
            formatter.unitSystem.massUnit,
          ),
        );
  final rirTarget = log.rir == null
      ? l10n.programBuilderRirOff
      : l10n.programBuilderRirSummary(log.rir!);
  final outcomeTarget = log.result == null
      ? l10n.todayOutcomeNone
      : _setResultLabel(l10n, log.result!);

  return l10n.todayPreviousPerformanceSummary(
    repetitionTarget,
    loadTarget,
    rirTarget,
    outcomeTarget,
  );
}

String _actualSummary(
  AppLocalizations l10n,
  UnitFormatter formatter,
  ActualSetLogRecord log,
) {
  final loadTarget = log.loadKilograms == null
      ? l10n.programBuilderLoadUnset
      : formatter.formatMass(
          Mass.kilograms(log.loadKilograms!),
          fractionDigits: _loadFractionDigits(
            log.loadKilograms!,
            formatter.unitSystem.massUnit,
          ),
        );
  final rirTarget = log.rir == null
      ? l10n.programBuilderRirOff
      : l10n.programBuilderRirSummary(log.rir!);
  final repetitionTarget = log.repetitions == null
      ? l10n.todayRepetitionsNotRecorded
      : l10n.todayFixedRepetitions(log.repetitions!);
  final outcomeTarget = log.result == null
      ? l10n.todayOutcomeNone
      : _setResultLabel(l10n, log.result!);

  return l10n.todaySetActualSummary(
    repetitionTarget,
    loadTarget,
    rirTarget,
    outcomeTarget,
  );
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

String _exerciseStatusText(AppLocalizations l10n, TodayExerciseStatus status) {
  return switch (status) {
    TodayExerciseStatus.notStarted => l10n.todayStatusNotStarted,
    TodayExerciseStatus.inProgress => l10n.todayStatusInProgress,
    TodayExerciseStatus.successful => l10n.todayStatusSuccessful,
    TodayExerciseStatus.needsReview => l10n.todayStatusNeedsReview,
    TodayExerciseStatus.interrupted => l10n.todayStatusInterrupted,
    TodayExerciseStatus.painReported => l10n.todayStatusPainReported,
    TodayExerciseStatus.notComparable => l10n.todayStatusNotComparable,
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
  if (value == null || value == _SessionOutcomeField._noOutcomeValue) {
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

double _quickLoadStep(MassUnit massUnit) {
  return switch (massUnit) {
    MassUnit.kilogram => 2.5,
    MassUnit.pound => 5,
  };
}

String _formatRestDuration(int totalSeconds) {
  final minutes = totalSeconds ~/ Duration.secondsPerMinute;
  final seconds = totalSeconds.remainder(Duration.secondsPerMinute);
  return '$minutes:${seconds.toString().padLeft(2, '0')}';
}

String _notificationStatusText(
  AppLocalizations l10n,
  RestNotificationScheduleStatus status,
) {
  return switch (status) {
    RestNotificationScheduleStatus.scheduled =>
      l10n.todayRestTimerNotificationScheduled,
    RestNotificationScheduleStatus.permissionDenied =>
      l10n.todayRestTimerNotificationPermissionDenied,
    RestNotificationScheduleStatus.unsupported =>
      l10n.todayRestTimerNotificationUnsupported,
    RestNotificationScheduleStatus.failed =>
      l10n.todayRestTimerNotificationFailed,
    RestNotificationScheduleStatus.skipped =>
      l10n.todayRestTimerNotificationSkipped,
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

int _loadFractionDigits(double loadKilograms, MassUnit massUnit) {
  final displayValue = Mass.kilograms(loadKilograms).inUnit(massUnit);
  return displayValue == displayValue.roundToDouble() ? 0 : 1;
}

void _showSnackBar(BuildContext context, String message) {
  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
}
