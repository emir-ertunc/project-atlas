import 'package:flutter/material.dart';
import 'package:project_atlas/core/design_system/tokens/app_component_tokens.dart';
import 'package:project_atlas/core/design_system/tokens/app_spacing.dart';

class AppDashboardCard extends StatelessWidget {
  const AppDashboardCard({
    required this.title,
    this.subtitle,
    this.leadingIcon,
    this.metric,
    this.trend,
    this.trailing,
    this.child,
    this.onTap,
    this.isProminent = false,
    super.key,
  });

  final String title;
  final String? subtitle;
  final IconData? leadingIcon;
  final String? metric;
  final String? trend;
  final Widget? trailing;
  final Widget? child;
  final VoidCallback? onTap;
  final bool isProminent;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final cardColor = isProminent
        ? colorScheme.primaryContainer
        : colorScheme.surfaceContainerLow;
    final foregroundColor = isProminent
        ? colorScheme.onPrimaryContainer
        : colorScheme.onSurface;

    final content = ConstrainedBox(
      constraints: const BoxConstraints(
        minHeight: AppComponentTokens.dashboardCardMinHeight,
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (leadingIcon != null) ...[
                  _DashboardIcon(
                    icon: leadingIcon!,
                    color: foregroundColor,
                    isProminent: isProminent,
                  ),
                  const SizedBox(width: AppSpacing.sm),
                ],
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        title,
                        style: theme.textTheme.titleMedium?.copyWith(
                          color: foregroundColor,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (subtitle != null) ...[
                        const SizedBox(height: AppSpacing.xxs),
                        Text(
                          subtitle!,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: isProminent
                                ? foregroundColor
                                : colorScheme.onSurfaceVariant,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ],
                  ),
                ),
                if (trailing != null) ...[
                  const SizedBox(width: AppSpacing.sm),
                  trailing!,
                ],
              ],
            ),
            if (metric != null || trend != null) ...[
              const SizedBox(height: AppSpacing.md),
              Wrap(
                spacing: AppSpacing.sm,
                runSpacing: AppSpacing.xs,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  if (metric != null)
                    Text(
                      metric!,
                      style: theme.textTheme.headlineMedium?.copyWith(
                        color: foregroundColor,
                      ),
                    ),
                  if (trend != null)
                    Text(
                      trend!,
                      style: theme.textTheme.labelMedium?.copyWith(
                        color: isProminent
                            ? foregroundColor
                            : colorScheme.onSurfaceVariant,
                      ),
                    ),
                ],
              ),
            ],
            if (child != null) ...[
              const SizedBox(height: AppSpacing.md),
              child!,
            ],
          ],
        ),
      ),
    );

    return Card(
      color: cardColor,
      clipBehavior: Clip.antiAlias,
      child: onTap == null ? content : InkWell(onTap: onTap, child: content),
    );
  }
}

class _DashboardIcon extends StatelessWidget {
  const _DashboardIcon({
    required this.icon,
    required this.color,
    required this.isProminent,
  });

  final IconData icon;
  final Color color;
  final bool isProminent;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      width: AppComponentTokens.minimumTouchTarget,
      height: AppComponentTokens.minimumTouchTarget,
      decoration: BoxDecoration(
        color: isProminent
            ? color.withValues(alpha: 0.12)
            : colorScheme.surfaceContainerHighest,
        borderRadius: AppRadii.medium,
      ),
      child: Icon(icon, color: color, size: AppComponentTokens.compactIcon),
    );
  }
}
