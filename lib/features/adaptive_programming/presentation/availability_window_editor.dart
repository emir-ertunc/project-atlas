import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:project_atlas/core/design_system/tokens/app_spacing.dart';
import 'package:project_atlas/core/repositories/repository_records.dart';
import 'package:project_atlas/features/adaptive_programming/application/availability_controller.dart';
import 'package:project_atlas/l10n/generated/app_localizations.dart';

class WeeklyAvailabilityEditor extends ConsumerWidget {
  const WeeklyAvailabilityEditor({required this.preferences, super.key});

  static const cardKey = Key('weekly-availability-card');
  static const saveButtonKey = Key('weekly-availability-save-button');

  static Key fixedPeriodKey(int index) =>
      Key('weekly-availability-fixed-$index');

  static Key flexiblePeriodKey(int index) =>
      Key('weekly-availability-flexible-$index');

  static Key startDropdownKey(int index) =>
      Key('weekly-availability-start-$index');

  static Key endDropdownKey(int index) => Key('weekly-availability-end-$index');

  final OnboardingPreferencesRecord preferences;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(availabilityControllerProvider);

    return state.when(
      data: (state) => _AvailabilityWindowForm(
        key: ValueKey(
          '${preferences.updatedAt.toIso8601String()}-'
          '${state.windows.map((window) => window.updatedAt.toIso8601String()).join('|')}',
        ),
        preferences: preferences,
        savedWindows: state.windows,
      ),
      error: (_, _) => _AvailabilityLoadError(
        onRetry: () => ref.invalidate(availabilityControllerProvider),
      ),
      loading: () => const Center(child: CircularProgressIndicator()),
    );
  }
}

class _AvailabilityWindowForm extends ConsumerStatefulWidget {
  const _AvailabilityWindowForm({
    required this.preferences,
    required this.savedWindows,
    super.key,
  });

  final OnboardingPreferencesRecord preferences;
  final List<AvailabilityWindowRecord> savedWindows;

  @override
  ConsumerState<_AvailabilityWindowForm> createState() =>
      _AvailabilityWindowFormState();
}

class _AvailabilityWindowFormState
    extends ConsumerState<_AvailabilityWindowForm> {
  static const _defaultStartMinute = 18 * 60;
  static const _timeStepMinutes = 30;

  late List<_AvailabilityWindowDraft> _drafts;
  var _isSaving = false;

  @override
  void initState() {
    super.initState();
    _drafts = _initialDrafts();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);

    return Card(
      key: WeeklyAvailabilityEditor.cardKey,
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.event_available_outlined,
                  color: theme.colorScheme.primary,
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Semantics(
                    header: true,
                    child: Text(
                      l10n.availabilityTitle,
                      style: theme.textTheme.titleMedium,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(l10n.availabilityDescription),
            const SizedBox(height: AppSpacing.md),
            for (final (index, draft) in _drafts.indexed) ...[
              _AvailabilityWindowRow(
                index: index,
                draft: draft,
                onTypeChanged: (windowType) {
                  setState(() {
                    _drafts[index] = draft.copyWith(windowType: windowType);
                  });
                },
                onStartChanged: (startMinute) {
                  setState(() {
                    final endMinute = draft.endMinute <= startMinute
                        ? _nextEndMinute(startMinute)
                        : draft.endMinute;
                    _drafts[index] = draft.copyWith(
                      startMinute: startMinute,
                      endMinute: endMinute,
                    );
                  });
                },
                onEndChanged: (endMinute) {
                  setState(() {
                    _drafts[index] = draft.copyWith(endMinute: endMinute);
                  });
                },
              ),
              if (index != _drafts.length - 1)
                const Divider(height: AppSpacing.lg),
            ],
            const SizedBox(height: AppSpacing.md),
            FilledButton.icon(
              key: WeeklyAvailabilityEditor.saveButtonKey,
              onPressed: _isSaving ? null : _saveWindows,
              icon: _isSaving
                  ? const SizedBox.square(
                      dimension: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.save_outlined),
              label: Text(l10n.availabilitySaveButton),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _saveWindows() async {
    setState(() => _isSaving = true);
    final l10n = AppLocalizations.of(context);
    try {
      await ref
          .read(availabilityControllerProvider.notifier)
          .saveWindows(
            _drafts
                .map(
                  (draft) => AvailabilityWindowInput(
                    id: draft.id,
                    weekday: draft.weekday,
                    windowType: draft.windowType,
                    startMinute: draft.startMinute,
                    endMinute: draft.endMinute,
                    createdAt: draft.createdAt,
                  ),
                )
                .toList(growable: false),
          );
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l10n.availabilitySavedMessage)));
    } catch (_) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l10n.availabilitySaveFailed)));
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  List<_AvailabilityWindowDraft> _initialDrafts() {
    if (widget.savedWindows.isNotEmpty) {
      return [
        for (final window in widget.savedWindows)
          _AvailabilityWindowDraft.fromRecord(window),
      ];
    }

    return [
      for (final weekday in _orderedWeekdays(
        widget.preferences.preferredWeekdays,
      ))
        _AvailabilityWindowDraft(
          weekday: weekday,
          windowType: AvailabilityWindowType.flexible,
          startMinute: _defaultStartMinute,
          endMinute:
              _defaultStartMinute +
              widget.preferences.preferredSessionLengthMinutes,
        ),
    ];
  }

  int _nextEndMinute(int startMinute) {
    return (startMinute + _timeStepMinutes).clamp(_timeStepMinutes, 24 * 60);
  }
}

class _AvailabilityWindowRow extends StatelessWidget {
  const _AvailabilityWindowRow({
    required this.index,
    required this.draft,
    required this.onTypeChanged,
    required this.onStartChanged,
    required this.onEndChanged,
  });

  final int index;
  final _AvailabilityWindowDraft draft;
  final ValueChanged<AvailabilityWindowType> onTypeChanged;
  final ValueChanged<int> onStartChanged;
  final ValueChanged<int> onEndChanged;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final validEndOptions = _timeOptions.where(
      (minute) => minute > draft.startMinute,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          _weekdayLabel(l10n, draft.weekday),
          style: theme.textTheme.titleSmall,
        ),
        const SizedBox(height: AppSpacing.xs),
        SegmentedButton<AvailabilityWindowType>(
          segments: [
            ButtonSegment(
              value: AvailabilityWindowType.fixed,
              label: Text(
                l10n.availabilityFixedPeriod,
                key: WeeklyAvailabilityEditor.fixedPeriodKey(index),
              ),
            ),
            ButtonSegment(
              value: AvailabilityWindowType.flexible,
              label: Text(
                l10n.availabilityFlexiblePeriod,
                key: WeeklyAvailabilityEditor.flexiblePeriodKey(index),
              ),
            ),
          ],
          selected: {draft.windowType},
          onSelectionChanged: (selection) => onTypeChanged(selection.single),
        ),
        const SizedBox(height: AppSpacing.sm),
        Wrap(
          spacing: AppSpacing.sm,
          runSpacing: AppSpacing.sm,
          children: [
            SizedBox(
              width: 156,
              child: DropdownButtonFormField<int>(
                key: WeeklyAvailabilityEditor.startDropdownKey(index),
                initialValue: draft.startMinute,
                decoration: InputDecoration(
                  labelText: l10n.availabilityStartTimeLabel,
                ),
                items: [
                  for (final minute in _timeOptions.where(
                    (minute) => minute < 24 * 60,
                  ))
                    DropdownMenuItem(
                      value: minute,
                      child: Text(_formatClockMinute(minute)),
                    ),
                ],
                onChanged: (value) {
                  if (value != null) {
                    onStartChanged(value);
                  }
                },
              ),
            ),
            SizedBox(
              width: 156,
              child: DropdownButtonFormField<int>(
                key: WeeklyAvailabilityEditor.endDropdownKey(index),
                initialValue: draft.endMinute,
                decoration: InputDecoration(
                  labelText: l10n.availabilityEndTimeLabel,
                ),
                items: [
                  for (final minute in validEndOptions)
                    DropdownMenuItem(
                      value: minute,
                      child: Text(_formatClockMinute(minute)),
                    ),
                ],
                onChanged: (value) {
                  if (value != null) {
                    onEndChanged(value);
                  }
                },
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.xs),
        Text(
          l10n.availabilityWindowSummary(
            _availabilityWindowTypeLabel(l10n, draft.windowType),
            _formatClockMinute(draft.startMinute),
            _formatClockMinute(draft.endMinute),
          ),
          style: theme.textTheme.bodySmall,
        ),
      ],
    );
  }
}

class _AvailabilityLoadError extends StatelessWidget {
  const _AvailabilityLoadError({required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          children: [
            Text(l10n.availabilityLoadError, textAlign: TextAlign.center),
            const SizedBox(height: AppSpacing.md),
            FilledButton(onPressed: onRetry, child: Text(l10n.todayRetry)),
          ],
        ),
      ),
    );
  }
}

final class _AvailabilityWindowDraft {
  const _AvailabilityWindowDraft({
    required this.weekday,
    required this.windowType,
    required this.startMinute,
    required this.endMinute,
    this.id,
    this.createdAt,
  });

  _AvailabilityWindowDraft.fromRecord(AvailabilityWindowRecord record)
    : id = record.id,
      weekday = record.weekday,
      windowType = record.windowType,
      startMinute = record.startMinute,
      endMinute = record.endMinute,
      createdAt = record.createdAt;

  final String? id;
  final TrainingWeekday weekday;
  final AvailabilityWindowType windowType;
  final int startMinute;
  final int endMinute;
  final DateTime? createdAt;

  _AvailabilityWindowDraft copyWith({
    AvailabilityWindowType? windowType,
    int? startMinute,
    int? endMinute,
  }) {
    return _AvailabilityWindowDraft(
      id: id,
      weekday: weekday,
      windowType: windowType ?? this.windowType,
      startMinute: startMinute ?? this.startMinute,
      endMinute: endMinute ?? this.endMinute,
      createdAt: createdAt,
    );
  }
}

List<int> get _timeOptions => [
  for (var minute = 0; minute <= 24 * 60; minute += 30) minute,
];

List<TrainingWeekday> _orderedWeekdays(List<TrainingWeekday> weekdays) {
  final weekdayIndexes = {
    for (final (index, weekday) in TrainingWeekday.values.indexed)
      weekday: index,
  };
  return weekdays.toSet().toList(growable: false)..sort(
    (left, right) => weekdayIndexes[left]!.compareTo(weekdayIndexes[right]!),
  );
}

String _availabilityWindowTypeLabel(
  AppLocalizations l10n,
  AvailabilityWindowType type,
) {
  return switch (type) {
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
