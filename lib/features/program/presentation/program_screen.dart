import 'package:flutter/material.dart';
import 'package:project_atlas/core/design_system/components/feature_root_scaffold.dart';
import 'package:project_atlas/l10n/generated/app_localizations.dart';

class ProgramScreen extends StatelessWidget {
  const ProgramScreen({super.key});

  static const path = '/program';
  static const routeName = 'program';
  static const screenKey = Key('program-screen');

  @override
  Widget build(BuildContext context) {
    return FeatureRootScaffold(
      key: screenKey,
      title: AppLocalizations.of(context).programNavigationLabel,
      icon: Icons.calendar_view_week_outlined,
    );
  }
}
