import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:project_atlas/core/design_system/tokens/app_spacing.dart';
import 'package:project_atlas/core/repositories/repository_records.dart';
import 'package:project_atlas/features/adaptive_programming/application/availability_controller.dart';
import 'package:project_atlas/features/adaptive_programming/domain/missed_session_replacement.dart';
import 'package:project_atlas/features/adaptive_programming/domain/program_generator.dart';
import 'package:project_atlas/features/exercise_catalog/application/exercise_catalog_provider.dart';
import 'package:project_atlas/l10n/generated/app_localizations.dart';

class MissedSessionReplacementCard extends ConsumerWidget {
  const MissedSessionReplacementCard({required this.preferences, super.key});

  static const cardKey = Key('missed-session-replacement-card');
  static const missedDayDropdownKey = Key(
    'missed-session-replacement-day-dropdown',
  );
  static const proposalSummaryKey = Key(
    'missed-session-replacement-proposal-summary',
  );
  static const noSafeWindowKey = Key('missed-session-replacement-no-safe');

  final OnboardingPreferencesRecord preferences;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final availabilityState = ref.watch(availabilityControllerProvider);

    return Card(
      key: cardKey,
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: availabilityState.when(
          data: (availability) {
            if (!availability.hasWindows) {
              return _ReplacementShell(
                child: Text(l10n.missedSessionReplacementAvailabilityRequired),
              );
            }

            return ref
                .watch(exerciseCatalogProvider)
                .when(
                  data: (catalog) {
                    final plan = buildAdaptiveProgramPlan(
                      preferences: preferences,
                      availabilityWindows: availability.windows,
                      catalog: catalog,
                    );
                    if (plan.days.isEmpty) {
                      return _ReplacementShell(
                        child: Text(l10n.generatedProgramNoPlan),
                      );
                    }
                    return _ReplacementContent(
                      plan: plan,
                      availabilityWindows: availability.windows,
                    );
                  },
                  error: (_, _) => _ReplacementShell(
                    child: Text(l10n.generatedProgramCatalogLoadError),
                  ),
                  loading: () => _ReplacementShell(
                    child: Text(l10n.exerciseCatalogLoading),
                  ),
                );
          },
          error: (_, _) =>
              _ReplacementShell(child: Text(l10n.availabilityLoadError)),
          loading: () =>
              _ReplacementShell(child: Text(l10n.availabilityLoading)),
        ),
      ),
    );
  }
}

class _ReplacementShell extends StatelessWidget {
  const _ReplacementShell({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.event_repeat_outlined, color: theme.colorScheme.primary),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Semantics(
                header: true,
                child: Text(
                  l10n.missedSessionReplacementTitle,
                  style: theme.textTheme.titleMedium,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.xs),
        Text(l10n.missedSessionReplacementDescription),
        const SizedBox(height: AppSpacing.md),
        child,
      ],
    );
  }
}

class _ReplacementContent extends StatefulWidget {
  const _ReplacementContent({
    required this.plan,
    required this.availabilityWindows,
  });

  final GeneratedProgramPlan plan;
  final List<AvailabilityWindowRecord> availabilityWindows;

  @override
  State<_ReplacementContent> createState() => _ReplacementContentState();
}

class _ReplacementContentState extends State<_ReplacementContent> {
  late String _selectedDayId;

  @override
  void initState() {
    super.initState();
    _selectedDayId = widget.plan.days.first.id;
  }

  @override
  void didUpdateWidget(covariant _ReplacementContent oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!widget.plan.days.any((day) => day.id == _selectedDayId)) {
      _selectedDayId = widget.plan.days.first.id;
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final proposal = proposeMissedSessionReplacement(
      plan: widget.plan,
      missedDayId: _selectedDayId,
      availabilityWindows: widget.availabilityWindows,
    );

    return _ReplacementShell(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          DropdownButtonFormField<String>(
            key: MissedSessionReplacementCard.missedDayDropdownKey,
            initialValue: _selectedDayId,
            isExpanded: true,
            decoration: InputDecoration(
              labelText: l10n.missedSessionReplacementMissedDayLabel,
            ),
            items: [
              for (final day in widget.plan.days)
                DropdownMenuItem(
                  value: day.id,
                  child: Text(_dayLabel(l10n, day)),
                ),
            ],
            onChanged: (dayId) {
              if (dayId == null) {
                return;
              }
              setState(() => _selectedDayId = dayId);
            },
          ),
          const SizedBox(height: AppSpacing.md),
          if (proposal.hasReplacement)
            _ReplacementProposalSummary(proposal: proposal)
          else
            Text(
              _noSafeWindowText(l10n, proposal),
              key: MissedSessionReplacementCard.noSafeWindowKey,
            ),
        ],
      ),
    );
  }
}

class _ReplacementProposalSummary extends StatelessWidget {
  const _ReplacementProposalSummary({required this.proposal});

  final MissedSessionReplacementProposal proposal;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final window = proposal.window!;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(AppSpacing.sm),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Text(
          l10n.missedSessionReplacementProposalSummary(
            _weekdayLabel(l10n, window.weekday),
            _windowTypeLabel(l10n, window.windowType),
            _formatClockMinute(window.startMinute),
            _formatClockMinute(window.endMinute),
            window.dayOffset,
            proposal.minimumRecoveryMinutes ~/ 60,
          ),
          key: MissedSessionReplacementCard.proposalSummaryKey,
        ),
      ),
    );
  }
}

String _dayLabel(AppLocalizations l10n, GeneratedTrainingDayPlan day) {
  return l10n.missedSessionReplacementDayOption(
    day.name,
    _weekdayLabel(l10n, day.weekday),
  );
}

String _noSafeWindowText(
  AppLocalizations l10n,
  MissedSessionReplacementProposal proposal,
) {
  if (proposal.status == MissedSessionReplacementStatus.missedDayNotFound) {
    return l10n.missedSessionReplacementMissingDay;
  }
  if (proposal.blockers.contains(
    MissedSessionReplacementBlocker.insufficientWindowDuration,
  )) {
    return l10n.missedSessionReplacementNoSafeWindowWithDuration;
  }
  if (proposal.blockers.any(
    {
      MissedSessionReplacementBlocker.recoveryBeforeConflict,
      MissedSessionReplacementBlocker.recoveryAfterConflict,
    }.contains,
  )) {
    return l10n.missedSessionReplacementNoSafeWindowWithRecovery(
      proposal.minimumRecoveryMinutes ~/ 60,
    );
  }
  return l10n.missedSessionReplacementNoSafeWindow;
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

String _windowTypeLabel(
  AppLocalizations l10n,
  AvailabilityWindowType windowType,
) {
  return switch (windowType) {
    AvailabilityWindowType.fixed => l10n.availabilityFixedPeriod,
    AvailabilityWindowType.flexible => l10n.availabilityFlexiblePeriod,
  };
}

String _formatClockMinute(int minuteOfDay) {
  final hours = minuteOfDay ~/ 60;
  final minutes = minuteOfDay % 60;
  return '${hours.toString().padLeft(2, '0')}:'
      '${minutes.toString().padLeft(2, '0')}';
}
