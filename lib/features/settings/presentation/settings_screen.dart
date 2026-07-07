import 'package:flutter/material.dart';
import 'package:project_atlas/core/design_system/components/feature_root_scaffold.dart';
import 'package:project_atlas/l10n/generated/app_localizations.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  static const path = '/settings';
  static const routeName = 'settings';
  static const screenKey = Key('settings-screen');

  @override
  Widget build(BuildContext context) {
    return FeatureRootScaffold(
      key: screenKey,
      title: AppLocalizations.of(context).settingsNavigationLabel,
      icon: Icons.settings_outlined,
    );
  }
}
