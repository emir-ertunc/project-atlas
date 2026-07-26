import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:project_atlas/core/design_system/app_theme.dart';
import 'package:project_atlas/core/design_system/tokens/app_component_tokens.dart';
import 'package:project_atlas/core/design_system/tokens/app_spacing.dart';
import 'package:project_atlas/core/design_system/tokens/app_typography.dart';

void main() {
  group('design token invariants', () {
    test('spacing scale is ordered and based on four logical pixels', () {
      const scale = [
        AppSpacing.xxs,
        AppSpacing.xs,
        AppSpacing.sm,
        AppSpacing.md,
        AppSpacing.lg,
        AppSpacing.xl,
        AppSpacing.xxl,
        AppSpacing.xxxl,
      ];

      for (var index = 0; index < scale.length; index++) {
        expect(scale[index] % 4, 0);
        if (index > 0) {
          expect(scale[index], greaterThan(scale[index - 1]));
        }
      }
    });

    test('component sizes retain accessible touch targets', () {
      expect(AppComponentTokens.minimumTouchTarget, greaterThanOrEqualTo(48));
      expect(
        AppComponentTokens.controlHeight,
        greaterThanOrEqualTo(AppComponentTokens.minimumTouchTarget),
      );
      expect(
        AppComponentTokens.denseControlHeight,
        greaterThanOrEqualTo(AppComponentTokens.minimumTouchTarget),
      );
      expect(
        AppComponentTokens.interactiveStatusChipHeight,
        greaterThanOrEqualTo(AppComponentTokens.minimumTouchTarget),
      );
      expect(
        AppComponentTokens.dashboardCardMinHeight,
        greaterThan(AppComponentTokens.denseControlHeight),
      );
      expect(
        AppComponentTokens.standardProgressRingSize,
        greaterThan(AppComponentTokens.compactProgressRingSize),
      );

      final filledButtonSize = AppTheme
          .light
          .filledButtonTheme
          .style
          ?.minimumSize
          ?.resolve(<WidgetState>{});
      final iconButtonSize = AppTheme.light.iconButtonTheme.style?.minimumSize
          ?.resolve(<WidgetState>{});

      expect(filledButtonSize?.height, greaterThanOrEqualTo(48));
      expect(filledButtonSize?.width, greaterThanOrEqualTo(48));
      expect(iconButtonSize?.height, greaterThanOrEqualTo(48));
      expect(iconButtonSize?.width, greaterThanOrEqualTo(48));
    });

    test('light and dark themes share the same typography scale', () {
      final light = AppTheme.light;
      final dark = AppTheme.dark;

      expect(light.useMaterial3, isTrue);
      expect(dark.useMaterial3, isTrue);
      expect(light.brightness, Brightness.light);
      expect(dark.brightness, Brightness.dark);
      expect(light.textTheme.bodyLarge?.fontSize, 16);
      expect(light.textTheme.headlineMedium?.fontSize, 28);
      expect(
        dark.textTheme.bodyLarge?.fontSize,
        light.textTheme.bodyLarge?.fontSize,
      );
      expect(
        dark.textTheme.headlineMedium?.fontWeight,
        light.textTheme.headlineMedium?.fontWeight,
      );
      expect(
        dark.textTheme.bodyLarge?.fontFamily,
        light.textTheme.bodyLarge?.fontFamily,
      );
      expect(
        AppTypography.textTheme(Colors.black).bodyLarge?.fontFamily,
        isNull,
      );
    });

    test('shape and motion scales are internally ordered', () {
      expect(AppRadii.xs, lessThan(AppRadii.sm));
      expect(AppRadii.sm, lessThan(AppRadii.md));
      expect(AppRadii.md, lessThan(AppRadii.lg));
      expect(AppRadii.lg, lessThan(AppRadii.xl));
      expect(AppMotion.fast, lessThan(AppMotion.standard));
      expect(AppMotion.standard, lessThan(AppMotion.emphasized));
      expect(AppMotion.route, greaterThanOrEqualTo(AppMotion.standard));
      expect(AppMotion.completion, greaterThan(AppMotion.route));
      expect(AppElevation.none, lessThan(AppElevation.low));
      expect(AppElevation.low, lessThan(AppElevation.medium));
      expect(AppElevation.medium, lessThan(AppElevation.high));
    });
  });
}
