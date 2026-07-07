import 'package:flutter/material.dart';
import 'package:project_atlas/core/design_system/components/feature_root_scaffold.dart';
import 'package:project_atlas/l10n/generated/app_localizations.dart';

class TodayScreen extends StatelessWidget {
  const TodayScreen({super.key});

  static const path = '/today';
  static const routeName = 'today';
  static const screenKey = Key('today-screen');

  @override
  Widget build(BuildContext context) {
    return FeatureRootScaffold(
      key: screenKey,
      title: AppLocalizations.of(context).todayNavigationLabel,
      icon: Icons.today_outlined,
    );
  }
}
