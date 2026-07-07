import 'package:flutter/material.dart';
import 'package:project_atlas/core/design_system/components/feature_root_scaffold.dart';
import 'package:project_atlas/l10n/generated/app_localizations.dart';

class ProgressScreen extends StatelessWidget {
  const ProgressScreen({super.key});

  static const path = '/progress';
  static const routeName = 'progress';
  static const screenKey = Key('progress-screen');

  @override
  Widget build(BuildContext context) {
    return FeatureRootScaffold(
      key: screenKey,
      title: AppLocalizations.of(context).progressNavigationLabel,
      icon: Icons.insights_outlined,
    );
  }
}
