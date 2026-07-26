import 'package:flutter/material.dart';
import 'package:project_atlas/core/design_system/tokens/app_color_tokens.dart';
import 'package:project_atlas/core/design_system/tokens/app_component_tokens.dart';
import 'package:project_atlas/core/design_system/tokens/app_spacing.dart';

enum AppStatusTone { neutral, success, warning, information, danger }

class AppStatusChip extends StatelessWidget {
  const AppStatusChip({
    required this.label,
    this.icon,
    this.tone = AppStatusTone.neutral,
    this.onTap,
    super.key,
  });

  final String label;
  final IconData? icon;
  final AppStatusTone tone;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = _StatusChipColors.resolve(context, tone);
    final minHeight = onTap == null
        ? AppComponentTokens.statusChipHeight
        : AppComponentTokens.interactiveStatusChipHeight;

    final content = ConstrainedBox(
      constraints: BoxConstraints(minHeight: minHeight),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.sm,
          vertical: AppSpacing.xxs,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(
                icon,
                size: AppComponentTokens.compactIcon,
                color: colors.foreground,
              ),
              const SizedBox(width: AppSpacing.xs),
            ],
            Flexible(
              child: Text(
                label,
                style: theme.textTheme.labelMedium?.copyWith(
                  color: colors.foreground,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );

    return Semantics(
      button: onTap != null,
      child: Material(
        color: colors.background,
        shape: StadiumBorder(side: BorderSide(color: colors.outline)),
        clipBehavior: Clip.antiAlias,
        child: onTap == null ? content : InkWell(onTap: onTap, child: content),
      ),
    );
  }
}

class _StatusChipColors {
  const _StatusChipColors({
    required this.background,
    required this.foreground,
    required this.outline,
  });

  final Color background;
  final Color foreground;
  final Color outline;

  static _StatusChipColors resolve(BuildContext context, AppStatusTone tone) {
    final colorScheme = Theme.of(context).colorScheme;
    final semantic = context.semanticColors;

    return switch (tone) {
      AppStatusTone.neutral => _StatusChipColors(
        background: colorScheme.surfaceContainerHighest,
        foreground: colorScheme.onSurfaceVariant,
        outline: colorScheme.outlineVariant,
      ),
      AppStatusTone.success => _StatusChipColors(
        background: semantic.successContainer,
        foreground: semantic.onSuccessContainer,
        outline: semantic.success,
      ),
      AppStatusTone.warning => _StatusChipColors(
        background: semantic.warningContainer,
        foreground: semantic.onWarningContainer,
        outline: semantic.warning,
      ),
      AppStatusTone.information => _StatusChipColors(
        background: semantic.informationContainer,
        foreground: semantic.onInformationContainer,
        outline: semantic.information,
      ),
      AppStatusTone.danger => _StatusChipColors(
        background: colorScheme.errorContainer,
        foreground: colorScheme.onErrorContainer,
        outline: colorScheme.error,
      ),
    };
  }
}
