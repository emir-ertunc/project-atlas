import 'package:flutter/material.dart';
import 'package:project_atlas/core/design_system/tokens/app_color_tokens.dart';
import 'package:project_atlas/core/design_system/tokens/app_component_tokens.dart';
import 'package:project_atlas/core/design_system/tokens/app_spacing.dart';
import 'package:project_atlas/core/design_system/tokens/app_typography.dart';

abstract final class AppTheme {
  static ThemeData get light => _build(
    colorScheme: AppColorTokens.lightScheme,
    semanticColors: AppColorTokens.lightSemantic,
  );

  static ThemeData get dark => _build(
    colorScheme: AppColorTokens.darkScheme,
    semanticColors: AppColorTokens.darkSemantic,
  );

  static ThemeData _build({
    required ColorScheme colorScheme,
    required AppSemanticColors semanticColors,
  }) {
    final textTheme = AppTypography.textTheme(colorScheme.onSurface);
    final controlShape = RoundedRectangleBorder(borderRadius: AppRadii.medium);

    return ThemeData(
      useMaterial3: true,
      brightness: colorScheme.brightness,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: colorScheme.surface,
      textTheme: textTheme,
      visualDensity: VisualDensity.standard,
      materialTapTargetSize: MaterialTapTargetSize.padded,
      extensions: [semanticColors],
      appBarTheme: AppBarThemeData(
        elevation: AppElevation.none,
        scrolledUnderElevation: AppElevation.low,
        centerTitle: false,
        backgroundColor: colorScheme.surface,
        foregroundColor: colorScheme.onSurface,
        surfaceTintColor: Colors.transparent,
        titleTextStyle: textTheme.titleLarge,
      ),
      cardTheme: CardThemeData(
        elevation: AppElevation.none,
        color: colorScheme.surfaceContainerLow,
        surfaceTintColor: Colors.transparent,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: AppRadii.large,
          side: BorderSide(color: colorScheme.outlineVariant),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          minimumSize: const Size(
            AppComponentTokens.minimumTouchTarget,
            AppComponentTokens.controlHeight,
          ),
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
          shape: controlShape,
          textStyle: textTheme.labelLarge,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          minimumSize: const Size(
            AppComponentTokens.minimumTouchTarget,
            AppComponentTokens.controlHeight,
          ),
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
          shape: controlShape,
          side: BorderSide(color: colorScheme.outline),
          textStyle: textTheme.labelLarge,
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          minimumSize: const Size(
            AppComponentTokens.minimumTouchTarget,
            AppComponentTokens.minimumTouchTarget,
          ),
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
          shape: controlShape,
          textStyle: textTheme.labelLarge,
        ),
      ),
      iconButtonTheme: IconButtonThemeData(
        style: IconButton.styleFrom(
          minimumSize: const Size.square(AppComponentTokens.minimumTouchTarget),
          iconSize: AppComponentTokens.standardIcon,
        ),
      ),
      inputDecorationTheme: InputDecorationThemeData(
        filled: true,
        fillColor: colorScheme.surfaceContainerHighest,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.md,
        ),
        border: OutlineInputBorder(
          borderRadius: AppRadii.medium,
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: AppRadii.medium,
          borderSide: BorderSide(color: colorScheme.outlineVariant),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: AppRadii.medium,
          borderSide: BorderSide(
            color: colorScheme.primary,
            width: AppComponentTokens.selectedStroke,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: AppRadii.medium,
          borderSide: BorderSide(color: colorScheme.error),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: AppRadii.medium,
          borderSide: BorderSide(
            color: colorScheme.error,
            width: AppComponentTokens.selectedStroke,
          ),
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        height: AppComponentTokens.navigationBarHeight,
        elevation: AppElevation.none,
        backgroundColor: colorScheme.surfaceContainerLow,
        indicatorColor: colorScheme.primaryContainer,
        labelTextStyle: WidgetStatePropertyAll(textTheme.labelMedium),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          final selected = states.contains(WidgetState.selected);
          return IconThemeData(
            color: selected
                ? colorScheme.onPrimaryContainer
                : colorScheme.onSurfaceVariant,
            size: AppComponentTokens.standardIcon,
          );
        }),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: colorScheme.surfaceContainerLow,
        selectedColor: colorScheme.secondaryContainer,
        disabledColor: colorScheme.surfaceContainer,
        side: BorderSide(color: colorScheme.outlineVariant),
        shape: RoundedRectangleBorder(borderRadius: AppRadii.medium),
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.sm,
          vertical: AppSpacing.xs,
        ),
        labelStyle: textTheme.labelLarge,
        secondaryLabelStyle: textTheme.labelLarge?.copyWith(
          color: colorScheme.onSecondaryContainer,
        ),
      ),
      dividerTheme: DividerThemeData(
        color: colorScheme.outlineVariant,
        thickness: AppComponentTokens.hairline,
        space: AppSpacing.md,
      ),
    );
  }
}
