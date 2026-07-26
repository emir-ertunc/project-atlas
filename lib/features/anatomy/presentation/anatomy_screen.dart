import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:project_atlas/core/design_system/components/app_dashboard_card.dart';
import 'package:project_atlas/core/design_system/components/feature_root_scaffold.dart';
import 'package:project_atlas/core/design_system/tokens/app_spacing.dart';
import 'package:project_atlas/core/repositories/repository_providers.dart';
import 'package:project_atlas/core/repositories/repository_records.dart';
import 'package:project_atlas/features/anatomy/application/anatomy_training_heatmap_controller.dart';
import 'package:project_atlas/features/anatomy/presentation/anatomy_renderer_panel.dart';
import 'package:project_atlas/features/program/application/program_draft_persistence.dart';
import 'package:project_atlas/l10n/generated/app_localizations.dart';

final anatomyMeasurementRecordsProvider =
    StreamProvider<List<MeasurementRecord>>((ref) {
      final repository = ref.watch(measurementRepositoryProvider);
      final profileId = ref.watch(localProgramProfileIdProvider);
      return repository.watchMeasurements(profileId);
    });

class AnatomyScreen extends ConsumerWidget {
  const AnatomyScreen({super.key});

  static const path = '/anatomy';
  static const routeName = 'anatomy';
  static const screenKey = Key('anatomy-screen');
  static const measurementPromptKey = Key('anatomy-measurement-prompt');
  static const measurementPromptButtonKey = Key(
    'anatomy-measurement-prompt-button',
  );

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final measurementRecords = ref.watch(anatomyMeasurementRecordsProvider);
    final compactMeasurementPrompt = measurementRecords.maybeWhen<Widget?>(
      data: (records) => records.any(_hasUsableMeasurementData)
          ? null
          : const _CompactMeasurementPrompt(),
      orElse: () => null,
    );

    return FeatureRootScaffold(
      key: screenKey,
      title: l10n.anatomyNavigationLabel,
      icon: Icons.accessibility_new_outlined,
      child: AnatomyRendererPanel(
        trainingHeatmaps: ref.watch(anatomyTrainingHeatmapsProvider),
        compactMeasurementPrompt: compactMeasurementPrompt,
      ),
    );
  }
}

bool _hasUsableMeasurementData(MeasurementRecord record) {
  return [
    record.heightCentimeters,
    record.weightKilograms,
    record.torsoLengthCentimeters,
    record.chestCircumferenceCentimeters,
    record.waistCircumferenceCentimeters,
    record.hipCircumferenceCentimeters,
    record.leftUpperArmCircumferenceCentimeters,
    record.rightUpperArmCircumferenceCentimeters,
    record.leftForearmCircumferenceCentimeters,
    record.rightForearmCircumferenceCentimeters,
    record.leftThighCircumferenceCentimeters,
    record.rightThighCircumferenceCentimeters,
    record.leftCalfCircumferenceCentimeters,
    record.rightCalfCircumferenceCentimeters,
    record.bodyFatPercentage,
  ].any((value) => value != null && value > 0);
}

class _CompactMeasurementPrompt extends StatelessWidget {
  const _CompactMeasurementPrompt();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return AppDashboardCard(
      key: AnatomyScreen.measurementPromptKey,
      title: l10n.anatomyMeasurementPromptTitle,
      subtitle: l10n.anatomyMeasurementPromptDescription,
      leadingIcon: Icons.straighten_outlined,
      trailing: FilledButton.tonalIcon(
        key: AnatomyScreen.measurementPromptButtonKey,
        onPressed: () => context.go(AnatomyEstimateDetailsScreen.path),
        icon: const Icon(Icons.arrow_forward),
        label: Text(l10n.anatomyMeasurementPromptAction),
      ),
    );
  }
}

class AnatomyEstimateDetailsScreen extends StatelessWidget {
  const AnatomyEstimateDetailsScreen({super.key});

  static const pathSegment = 'estimate';
  static const path = '${AnatomyScreen.path}/$pathSegment';
  static const routeName = 'anatomy-estimate';
  static const screenKey = Key('anatomy-estimate-screen');

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return FeatureRootScaffold(
      key: screenKey,
      title: l10n.anatomyVisualEstimateLabel,
      icon: Icons.info_outline,
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: AppDashboardCard(
            title: l10n.anatomyVisualEstimateLabel,
            subtitle: l10n.anatomyVisualEstimateDescription,
            leadingIcon: Icons.info_outline,
          ),
        ),
      ),
    );
  }
}
