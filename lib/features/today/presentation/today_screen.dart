import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:project_atlas/core/design_system/components/app_dashboard_card.dart';
import 'package:project_atlas/core/design_system/components/app_progress_ring.dart';
import 'package:project_atlas/core/design_system/components/app_status_chip.dart';
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
  static const workoutRouteCardKey = Key('today-workout-route-card');
  static const coachHeroCardKey = Key('today-coach-hero-card');
  static const quickStartButtonKey = Key('today-quick-start-button');
  static const streakCardKey = Key('today-streak-card');
  static const weeklyConsistencyCardKey = Key('today-weekly-consistency-card');
  static const pendingRecommendationCardKey = Key(
    'today-pending-recommendation-card',
  );
  static const activeWorkoutQueueCardKey = Key(
    'today-active-workout-queue-card',
  );

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
        data: (state) => _TodayDashboard(state: state),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stackTrace) => _TodayErrorState(
          onRetry: () => ref.invalidate(todayWorkoutControllerProvider),
        ),
      ),
    );
  }
}

class TodayWorkoutScreen extends ConsumerWidget {
  const TodayWorkoutScreen({super.key});

  static const pathSegment = 'workout';
  static const path = '${TodayScreen.path}/$pathSegment';
  static const routeName = 'today-workout';
  static const screenKey = Key('today-workout-screen');

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

class _TodayDashboard extends ConsumerWidget {
  const _TodayDashboard({required this.state});

  final TodayWorkoutState state;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final activeSession = state.activeSession;
    final activeProgramPlan = state.activeProgramPlan;
    final selectedDay = state.selectedTrainingDay;
    final canStartSelectedDay =
        activeSession == null &&
        activeProgramPlan != null &&
        selectedDay != null &&
        selectedDay.hasExercises;

    return ListView(
      restorationId: 'today-dashboard-scroll',
      padding: const EdgeInsets.all(AppSpacing.md),
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
          l10n.todayCoachDashboardSubtitle,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        AppDashboardCard(
          key: TodayScreen.coachHeroCardKey,
          title: _missionTitle(l10n, state),
          subtitle: _missionSubtitle(l10n, state),
          leadingIcon: activeSession == null
              ? Icons.flag_outlined
              : Icons.play_circle_outline,
          metric: activeSession != null
              ? l10n.todaySetProgressSummary(
                  activeSession.completedSetCount,
                  activeSession.totalSetCount,
                )
              : selectedDay != null
              ? l10n.todayTrainingDaySummary(
                  selectedDay.exerciseCount,
                  selectedDay.totalSetCount,
                )
              : null,
          trend: _missionTrend(l10n, state),
          isProminent: true,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _MissionStatusChips(
                state: state,
                isEmptyState: activeProgramPlan == null,
              ),
              const SizedBox(height: AppSpacing.md),
              FilledButton.icon(
                key: TodayScreen.quickStartButtonKey,
                onPressed: () => _handlePrimaryAction(
                  context,
                  ref,
                  canStartSelectedDay: canStartSelectedDay,
                ),
                icon: Icon(
                  activeSession != null
                      ? Icons.play_arrow
                      : activeProgramPlan == null
                      ? Icons.add
                      : Icons.flash_on_outlined,
                ),
                label: Text(_primaryActionLabel(l10n, state)),
              ),
              if (activeProgramPlan != null || activeSession != null) ...[
                const SizedBox(height: AppSpacing.xs),
                TextButton.icon(
                  key: TodayScreen.workoutRouteCardKey,
                  onPressed: () => context.go(TodayWorkoutScreen.path),
                  icon: const Icon(Icons.view_agenda_outlined),
                  label: Text(l10n.todayOpenWorkoutDetails),
                ),
              ],
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        _CoachMetricGrid(summary: state.coachSummary),
        const SizedBox(height: AppSpacing.sm),
        _PendingRecommendationCard(state: state),
      ],
    );
  }

  Future<void> _handlePrimaryAction(
    BuildContext context,
    WidgetRef ref, {
    required bool canStartSelectedDay,
  }) async {
    if (state.activeSession != null) {
      context.go(TodayWorkoutScreen.path);
      return;
    }

    if (state.activeProgramPlan == null) {
      context.go(ProgramScreen.path);
      return;
    }

    if (!canStartSelectedDay) {
      context.go(TodayWorkoutScreen.path);
      return;
    }

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
      context.go(TodayWorkoutScreen.path);
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

class _MissionStatusChips extends StatelessWidget {
  const _MissionStatusChips({required this.state, required this.isEmptyState});

  final TodayWorkoutState state;
  final bool isEmptyState;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final activeSession = state.activeSession;
    final chips = Wrap(
      spacing: AppSpacing.xs,
      runSpacing: AppSpacing.xs,
      children: [
        AppStatusChip(
          label: _missionStatusLabel(l10n, state),
          tone: _missionStatusTone(state),
        ),
        if (activeSession?.restoredAfterProcessTermination ?? false)
          AppStatusChip(
            label: l10n.todaySessionRestoredStatus,
            tone: AppStatusTone.warning,
            icon: Icons.restore_outlined,
          ),
      ],
    );

    return isEmptyState
        ? KeyedSubtree(key: TodayScreen.emptyStateKey, child: chips)
        : chips;
  }
}

class _CoachMetricGrid extends StatelessWidget {
  const _CoachMetricGrid({required this.summary});

  final TodayCoachSummary summary;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final cards = [
          Expanded(child: _StreakCard(summary: summary)),
          const SizedBox(width: AppSpacing.sm),
          Expanded(child: _WeeklyConsistencyCard(summary: summary)),
        ];

        if (constraints.maxWidth < 340) {
          return Column(
            children: [
              _StreakCard(summary: summary),
              const SizedBox(height: AppSpacing.sm),
              _WeeklyConsistencyCard(summary: summary),
            ],
          );
        }

        return Row(children: cards);
      },
    );
  }
}

class _StreakCard extends StatelessWidget {
  const _StreakCard({required this.summary});

  final TodayCoachSummary summary;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return AppDashboardCard(
      key: TodayScreen.streakCardKey,
      title: l10n.todayStreakTitle,
      subtitle: summary.currentStreakDays == 0
          ? l10n.todayStreakEmptyDescription
          : l10n.todayStreakActiveDescription,
      leadingIcon: Icons.local_fire_department_outlined,
      metric: l10n.todayStreakValue(summary.currentStreakDays),
    );
  }
}

class _WeeklyConsistencyCard extends StatelessWidget {
  const _WeeklyConsistencyCard({required this.summary});

  final TodayCoachSummary summary;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final percent = summary.weeklyConsistencyPercent;

    return AppDashboardCard(
      key: TodayScreen.weeklyConsistencyCardKey,
      title: l10n.todayWeeklyConsistencyTitle,
      subtitle: summary.hasWeeklyTarget
          ? l10n.todayWeeklyConsistencyValue(
              summary.completedWorkoutsThisWeek,
              summary.weeklyWorkoutTarget,
            )
          : l10n.todayWeeklyConsistencyNoTarget,
      leadingIcon: Icons.insights_outlined,
      metric: summary.hasWeeklyTarget
          ? l10n.todayWeeklyConsistencyPercent(percent)
          : null,
      trailing: AppProgressRing(
        progress: summary.weeklyConsistencyRatio,
        size: 56,
        semanticLabel: l10n.todayWeeklyConsistencyTitle,
        center: Text(summary.hasWeeklyTarget ? '$percent%' : '0%'),
      ),
    );
  }
}

class _PendingRecommendationCard extends StatelessWidget {
  const _PendingRecommendationCard({required this.state});

  final TodayWorkoutState state;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final review = _pendingReviewState(l10n, state);

    return AppDashboardCard(
      key: TodayScreen.pendingRecommendationCardKey,
      title: review.title,
      subtitle: review.subtitle,
      leadingIcon: review.icon,
      metric: review.metric,
      trailing: const Icon(Icons.chevron_right),
      onTap: () => context.go(review.destinationPath),
      child: AppStatusChip(
        label: review.statusLabel,
        tone: review.tone,
        icon: review.statusIcon,
      ),
    );
  }
}

final class _PendingReviewState {
  const _PendingReviewState({
    required this.title,
    required this.subtitle,
    required this.metric,
    required this.statusLabel,
    required this.tone,
    required this.icon,
    required this.destinationPath,
    this.statusIcon,
  });

  final String title;
  final String subtitle;
  final String metric;
  final String statusLabel;
  final AppStatusTone tone;
  final IconData icon;
  final String destinationPath;
  final IconData? statusIcon;
}

String _missionTitle(AppLocalizations l10n, TodayWorkoutState state) {
  if (state.activeSession != null) {
    return l10n.todayCoachResumeTitle;
  }
  final selectedDay = state.selectedTrainingDay;
  if (selectedDay != null) {
    return l10n.todayCoachNextWorkoutTitle(selectedDay.day.name);
  }
  return l10n.todayNoActiveProgramTitle;
}

String _missionSubtitle(AppLocalizations l10n, TodayWorkoutState state) {
  final activeSession = state.activeSession;
  if (activeSession != null) {
    return l10n.todaySessionInProgressSummary(
      activeSession.exerciseCount,
      activeSession.totalSetCount,
    );
  }

  final selectedDay = state.selectedTrainingDay;
  if (selectedDay != null && selectedDay.hasExercises) {
    return l10n.todayCoachNextWorkoutDescription;
  }
  if (selectedDay != null) {
    return l10n.todayNoExercisesMessage;
  }
  return l10n.todayNoActiveProgramMessage;
}

String? _missionTrend(AppLocalizations l10n, TodayWorkoutState state) {
  final activeSession = state.activeSession;
  if (activeSession != null) {
    return _sessionStatusText(l10n, activeSession.status);
  }
  final plan = state.activeProgramPlan;
  if (plan != null) {
    return l10n.todayActiveProgramSummary(
      plan.version.versionNumber,
      plan.trainingDays.length,
    );
  }
  return l10n.todayCoachNoProgramTrend;
}

String _missionStatusLabel(AppLocalizations l10n, TodayWorkoutState state) {
  final activeSession = state.activeSession;
  if (activeSession != null) {
    return _sessionStatusText(l10n, activeSession.status);
  }
  if (state.activeProgramPlan != null) {
    return l10n.todayCoachReadyStatus;
  }
  return l10n.todayCoachSetupStatus;
}

AppStatusTone _missionStatusTone(TodayWorkoutState state) {
  final activeSession = state.activeSession;
  if (activeSession != null) {
    return _sessionStatusTone(activeSession.status);
  }
  if (state.activeProgramPlan != null) {
    return AppStatusTone.success;
  }
  return AppStatusTone.warning;
}

String _primaryActionLabel(AppLocalizations l10n, TodayWorkoutState state) {
  if (state.activeSession != null) {
    return l10n.todayResumeWorkout;
  }
  if (state.activeProgramPlan == null) {
    return l10n.todayCreateProgram;
  }
  if (state.selectedTrainingDay?.hasExercises ?? false) {
    return l10n.todayQuickStartWorkout;
  }
  return l10n.todayOpenWorkoutDetails;
}

_PendingReviewState _pendingReviewState(
  AppLocalizations l10n,
  TodayWorkoutState state,
) {
  final activeSession = state.activeSession;
  if (activeSession != null && _sessionNeedsReview(activeSession.status)) {
    return _PendingReviewState(
      title: l10n.todayPendingRecommendationTitle,
      subtitle: l10n.todayPendingRecommendationActiveDescription,
      metric: l10n.todayPendingRecommendationPendingCount(1),
      statusLabel: _sessionStatusText(l10n, activeSession.status),
      tone: _sessionStatusTone(activeSession.status),
      icon: Icons.pending_actions_outlined,
      statusIcon: Icons.priority_high_outlined,
      destinationPath: ProgramRecommendationInboxScreen.path,
    );
  }

  if (state.activeProgramPlan == null) {
    return _PendingReviewState(
      title: l10n.todayPendingRecommendationTitle,
      subtitle: l10n.todayPendingRecommendationNoProgramDescription,
      metric: l10n.todayPendingRecommendationClearCount,
      statusLabel: l10n.todayCoachSetupStatus,
      tone: AppStatusTone.neutral,
      icon: Icons.rule_folder_outlined,
      destinationPath: ProgramScreen.path,
    );
  }

  return _PendingReviewState(
    title: l10n.todayPendingRecommendationTitle,
    subtitle: l10n.todayPendingRecommendationClearDescription,
    metric: l10n.todayPendingRecommendationClearCount,
    statusLabel: l10n.todayPendingRecommendationClearStatus,
    tone: AppStatusTone.success,
    icon: Icons.task_alt_outlined,
    statusIcon: Icons.check,
    destinationPath: ProgramRecommendationInboxScreen.path,
  );
}

bool _sessionNeedsReview(TodaySessionStatus status) {
  return switch (status) {
    TodaySessionStatus.needsReview ||
    TodaySessionStatus.interrupted ||
    TodaySessionStatus.painReported ||
    TodaySessionStatus.notComparable => true,
    TodaySessionStatus.notStarted ||
    TodaySessionStatus.inProgress ||
    TodaySessionStatus.successful => false,
  };
}

AppStatusTone _sessionStatusTone(TodaySessionStatus status) {
  return switch (status) {
    TodaySessionStatus.successful => AppStatusTone.success,
    TodaySessionStatus.needsReview => AppStatusTone.warning,
    TodaySessionStatus.interrupted => AppStatusTone.warning,
    TodaySessionStatus.painReported => AppStatusTone.danger,
    TodaySessionStatus.notComparable => AppStatusTone.information,
    TodaySessionStatus.notStarted => AppStatusTone.neutral,
    TodaySessionStatus.inProgress => AppStatusTone.information,
  };
}

AppStatusTone _exerciseStatusTone(TodayExerciseStatus status) {
  return switch (status) {
    TodayExerciseStatus.successful => AppStatusTone.success,
    TodayExerciseStatus.needsReview => AppStatusTone.warning,
    TodayExerciseStatus.interrupted => AppStatusTone.warning,
    TodayExerciseStatus.painReported => AppStatusTone.danger,
    TodayExerciseStatus.notComparable => AppStatusTone.information,
    TodayExerciseStatus.notStarted => AppStatusTone.neutral,
    TodayExerciseStatus.inProgress => AppStatusTone.information,
  };
}

AppStatusTone _setStatusTone(TodaySetStatus status) {
  return switch (status) {
    TodaySetStatus.targetMet => AppStatusTone.success,
    TodaySetStatus.performanceMiss => AppStatusTone.warning,
    TodaySetStatus.interrupted => AppStatusTone.warning,
    TodaySetStatus.painReported => AppStatusTone.danger,
    TodaySetStatus.notComparable => AppStatusTone.information,
    TodaySetStatus.pending => AppStatusTone.neutral,
  };
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
            state.activeSession == null
                ? l10n.todayScreenSubtitle
                : l10n.todayActiveWorkoutSubtitle,
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
          ] else if (state.activeProgramPlan == null)
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
    final restState = ref.watch(restTimerControllerProvider);
    final focusedSet = _focusedSetSummary(session, restState);
    final focusedExercise = focusedSet == null
        ? null
        : _exerciseForSet(session, focusedSet.sessionSet.id);
    final exerciseName = focusedExercise == null
        ? null
        : _exerciseName(context, catalog, focusedExercise.exerciseId);
    final lastSetId = session.setSummaries.isEmpty
        ? null
        : session.setSummaries.last.sessionSet.id;

    return AppDashboardCard(
      key: TodayScreen.activeSessionCardKey,
      title: l10n.todaySessionInProgressTitle,
      subtitle: l10n.todaySessionInProgressSummary(
        session.exerciseCount,
        session.totalSetCount,
      ),
      leadingIcon: Icons.fitness_center,
      metric: l10n.todaySetProgressSummary(
        session.completedSetCount,
        session.totalSetCount,
      ),
      isProminent: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Wrap(
            spacing: AppSpacing.xs,
            runSpacing: AppSpacing.xs,
            children: [
              AppStatusChip(
                key: TodayScreen.sessionStatusKey,
                label: l10n.todaySessionStatusLabel(
                  _sessionStatusText(l10n, session.status),
                ),
                tone: _sessionStatusTone(session.status),
              ),
              if (focusedExercise != null)
                AppStatusChip(
                  key: TodayScreen.exerciseStatusKey(
                    focusedExercise.exerciseOrder,
                  ),
                  label: l10n.todayExerciseStatusLabel(
                    _exerciseStatusText(l10n, focusedExercise.status),
                  ),
                  tone: _exerciseStatusTone(focusedExercise.status),
                ),
            ],
          ),
          if (session.restoredAfterProcessTermination) ...[
            const SizedBox(height: AppSpacing.sm),
            Text(
              key: TodayScreen.restoredSessionMessageKey,
              l10n.todaySessionRestoredMessage,
            ),
          ],
          if (restState.hasTimer) ...[
            const SizedBox(height: AppSpacing.md),
            _RestTimerPanel(state: restState),
          ],
          const SizedBox(height: AppSpacing.md),
          if (focusedSet == null || exerciseName == null)
            _ActiveWorkoutCompleteCard(session: session)
          else
            _FocusedSessionSetCard(
              summary: focusedSet,
              exerciseName: exerciseName,
              formatter: formatter,
              unitSystem: unitSystem,
              shouldStartRestTimer: focusedSet.sessionSet.id != lastSetId,
              onCompleteSet: onCompleteSet,
              onStartRestTimer: ref
                  .read(restTimerControllerProvider.notifier)
                  .startRestTimer,
            ),
          const SizedBox(height: AppSpacing.sm),
          _ActiveWorkoutQueueCard(
            session: session,
            catalog: catalog,
            focusedSessionSetId: focusedSet?.sessionSet.id,
          ),
        ],
      ),
    );
  }
}

class _FocusedSessionSetCard extends StatelessWidget {
  const _FocusedSessionSetCard({
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
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return AppDashboardCard(
      title: l10n.todayCurrentSetTitle,
      subtitle: l10n.todayCurrentSetSubtitle(exerciseName, summary.setNumber),
      leadingIcon: summary.isCompleted
          ? Icons.check_circle_outline
          : Icons.radio_button_checked,
      child: _SessionSetLogger(
        summary: summary,
        exerciseName: exerciseName,
        formatter: formatter,
        unitSystem: unitSystem,
        shouldStartRestTimer: shouldStartRestTimer,
        onCompleteSet: onCompleteSet,
        onStartRestTimer: onStartRestTimer,
      ),
    );
  }
}

class _ActiveWorkoutQueueCard extends StatelessWidget {
  const _ActiveWorkoutQueueCard({
    required this.session,
    required this.catalog,
    required this.focusedSessionSetId,
  });

  final TodaySessionSummary session;
  final ExerciseCatalog? catalog;
  final String? focusedSessionSetId;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final entries = _queueEntries(context);

    if (entries.isEmpty) {
      return _ActiveWorkoutCompleteCard(session: session);
    }

    return AppDashboardCard(
      key: TodayScreen.activeWorkoutQueueCardKey,
      title: l10n.todayWorkoutQueueTitle,
      subtitle: l10n.todaySetProgressSummary(
        session.completedSetCount,
        session.totalSetCount,
      ),
      leadingIcon: Icons.format_list_bulleted,
      child: Wrap(
        spacing: AppSpacing.xs,
        runSpacing: AppSpacing.xs,
        children: [
          for (final entry in entries)
            AppStatusChip(
              key: TodayScreen.setStatusKey(entry.set.sessionSet.id),
              label: l10n.todayWorkoutQueueSetLabel(
                entry.exerciseName,
                entry.set.setNumber,
                _setStatusText(l10n, entry.set.status),
              ),
              tone: _setStatusTone(entry.set.status),
            ),
        ],
      ),
    );
  }

  List<_WorkoutQueueEntry> _queueEntries(BuildContext context) {
    final entries = <_WorkoutQueueEntry>[];
    for (final exercise in session.exerciseSummaries) {
      final exerciseName = _exerciseName(context, catalog, exercise.exerciseId);
      for (final set in exercise.setSummaries) {
        if (set.sessionSet.id == focusedSessionSetId) {
          continue;
        }
        entries.add(_WorkoutQueueEntry(exerciseName: exerciseName, set: set));
      }
    }
    return entries;
  }
}

class _ActiveWorkoutCompleteCard extends StatelessWidget {
  const _ActiveWorkoutCompleteCard({required this.session});

  final TodaySessionSummary session;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return AppDashboardCard(
      title: l10n.todayWorkoutCompleteTitle,
      subtitle: l10n.todayWorkoutCompleteMessage,
      leadingIcon: Icons.done_all,
      metric: l10n.todaySetProgressSummary(
        session.completedSetCount,
        session.totalSetCount,
      ),
    );
  }
}

final class _WorkoutQueueEntry {
  const _WorkoutQueueEntry({required this.exerciseName, required this.set});

  final String exerciseName;
  final TodaySessionSetSummary set;
}

TodaySessionSetSummary? _focusedSetSummary(
  TodaySessionSummary session,
  RestTimerState restState,
) {
  final restSourceSessionSetId = restState.timer?.sourceSessionSetId;
  if (restState.hasTimer && restSourceSessionSetId != null) {
    final restSourceSet = _setById(session, restSourceSessionSetId);
    if (restSourceSet != null) {
      return restSourceSet;
    }
  }

  for (final set in session.setSummaries) {
    if (!set.isCompleted) {
      return set;
    }
  }

  return session.setSummaries.isEmpty ? null : session.setSummaries.last;
}

TodaySessionSetSummary? _setById(
  TodaySessionSummary session,
  String sessionSetId,
) {
  for (final set in session.setSummaries) {
    if (set.sessionSet.id == sessionSetId) {
      return set;
    }
  }
  return null;
}

TodaySessionExerciseSummary? _exerciseForSet(
  TodaySessionSummary session,
  String sessionSetId,
) {
  for (final exercise in session.exerciseSummaries) {
    for (final set in exercise.setSummaries) {
      if (set.sessionSet.id == sessionSetId) {
        return exercise;
      }
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
