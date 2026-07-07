import 'package:flutter/material.dart';
import 'package:project_atlas/core/design_system/tokens/app_component_tokens.dart';
import 'package:project_atlas/core/design_system/tokens/app_spacing.dart';

class FeatureRootScaffold extends StatelessWidget {
  const FeatureRootScaffold({
    required this.title,
    required this.icon,
    super.key,
  });

  final String title;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                size: AppComponentTokens.heroIcon,
                color: theme.colorScheme.primary,
              ),
              const SizedBox(height: AppSpacing.md),
              Text(title, style: theme.textTheme.headlineSmall),
            ],
          ),
        ),
      ),
    );
  }
}
