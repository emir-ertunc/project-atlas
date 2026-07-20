import 'package:flutter/material.dart';
import 'package:project_atlas/core/design_system/tokens/app_component_tokens.dart';
import 'package:project_atlas/core/design_system/tokens/app_spacing.dart';

class FeatureRootScaffold extends StatelessWidget {
  const FeatureRootScaffold({
    required this.title,
    required this.icon,
    this.child,
    super.key,
  });

  final String title;
  final IconData icon;
  final Widget? child;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: SafeArea(
        child: child ?? _FeaturePlaceholder(icon: icon, title: title),
      ),
    );
  }
}

class _FeaturePlaceholder extends StatelessWidget {
  const _FeaturePlaceholder({required this.icon, required this.title});

  final IconData icon;
  final String title;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
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
    );
  }
}
