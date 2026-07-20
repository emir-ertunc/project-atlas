import 'package:flutter/material.dart';
import 'package:project_atlas/core/design_system/components/feature_root_scaffold.dart';
import 'package:project_atlas/features/exercise_catalog/presentation/exercise_catalog_screen.dart';
import 'package:project_atlas/features/program/presentation/program_builder_screen.dart';
import 'package:project_atlas/l10n/generated/app_localizations.dart';

class ProgramScreen extends StatelessWidget {
  const ProgramScreen({super.key});

  static const path = '/program';
  static const routeName = 'program';
  static const screenKey = Key('program-screen');
  static const builderTabKey = Key('program-builder-tab');
  static const catalogTabKey = Key('program-catalog-tab');

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return FeatureRootScaffold(
      key: screenKey,
      title: l10n.programNavigationLabel,
      icon: Icons.calendar_view_week_outlined,
      child: DefaultTabController(
        length: 2,
        child: Column(
          children: [
            TabBar(
              tabs: [
                Tab(
                  key: builderTabKey,
                  text: l10n.programWorkspaceBuilderTab,
                  icon: const Icon(Icons.view_week_outlined),
                ),
                Tab(
                  key: catalogTabKey,
                  text: l10n.programWorkspaceCatalogTab,
                  icon: const Icon(Icons.fitness_center_outlined),
                ),
              ],
            ),
            const Expanded(
              child: TabBarView(
                children: [
                  ProgramBuilderScreen(),
                  ExerciseCatalogScreen(useScaffold: false),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
