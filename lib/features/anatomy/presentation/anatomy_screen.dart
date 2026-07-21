import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:project_atlas/core/design_system/components/feature_root_scaffold.dart';
import 'package:project_atlas/features/anatomy/application/anatomy_training_heatmap_controller.dart';
import 'package:project_atlas/features/anatomy/presentation/anatomy_renderer_panel.dart';
import 'package:project_atlas/l10n/generated/app_localizations.dart';

class AnatomyScreen extends ConsumerWidget {
  const AnatomyScreen({super.key});

  static const path = '/anatomy';
  static const routeName = 'anatomy';
  static const screenKey = Key('anatomy-screen');

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return FeatureRootScaffold(
      key: screenKey,
      title: AppLocalizations.of(context).anatomyNavigationLabel,
      icon: Icons.accessibility_new_outlined,
      child: AnatomyRendererPanel(
        trainingHeatmaps: ref.watch(anatomyTrainingHeatmapsProvider),
      ),
    );
  }
}
