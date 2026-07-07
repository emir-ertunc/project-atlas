import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:project_atlas/core/design_system/app_theme.dart';
import 'package:project_atlas/core/design_system/tokens/app_color_tokens.dart';

void main() {
  group('AppColorTokens', () {
    test('light color roles meet WCAG AA normal-text contrast', () {
      _expectSchemeContrast(AppColorTokens.lightScheme);
      _expectSemanticContrast(AppColorTokens.lightSemantic);
    });

    test('dark color roles meet WCAG AA normal-text contrast', () {
      _expectSchemeContrast(AppColorTokens.darkScheme);
      _expectSemanticContrast(AppColorTokens.darkSemantic);
    });

    test('semantic colors are installed in both themes', () {
      expect(
        AppTheme.light.extension<AppSemanticColors>(),
        AppColorTokens.lightSemantic,
      );
      expect(
        AppTheme.dark.extension<AppSemanticColors>(),
        AppColorTokens.darkSemantic,
      );
    });
  });
}

void _expectSchemeContrast(ColorScheme scheme) {
  final pairs = <(String, Color, Color)>[
    ('primary', scheme.onPrimary, scheme.primary),
    ('primaryContainer', scheme.onPrimaryContainer, scheme.primaryContainer),
    ('secondary', scheme.onSecondary, scheme.secondary),
    (
      'secondaryContainer',
      scheme.onSecondaryContainer,
      scheme.secondaryContainer,
    ),
    ('tertiary', scheme.onTertiary, scheme.tertiary),
    ('tertiaryContainer', scheme.onTertiaryContainer, scheme.tertiaryContainer),
    ('error', scheme.onError, scheme.error),
    ('errorContainer', scheme.onErrorContainer, scheme.errorContainer),
    ('surface', scheme.onSurface, scheme.surface),
    ('surfaceVariant', scheme.onSurfaceVariant, scheme.surfaceContainer),
    ('inverseSurface', scheme.onInverseSurface, scheme.inverseSurface),
  ];

  for (final (name, foreground, background) in pairs) {
    expect(
      _contrastRatio(foreground, background),
      greaterThanOrEqualTo(4.5),
      reason: '$name must support normal-size text',
    );
  }
}

void _expectSemanticContrast(AppSemanticColors colors) {
  final pairs = <(String, Color, Color)>[
    ('success', colors.onSuccess, colors.success),
    ('successContainer', colors.onSuccessContainer, colors.successContainer),
    ('warning', colors.onWarning, colors.warning),
    ('warningContainer', colors.onWarningContainer, colors.warningContainer),
    ('information', colors.onInformation, colors.information),
    (
      'informationContainer',
      colors.onInformationContainer,
      colors.informationContainer,
    ),
  ];

  for (final (name, foreground, background) in pairs) {
    expect(
      _contrastRatio(foreground, background),
      greaterThanOrEqualTo(4.5),
      reason: '$name must support normal-size text',
    );
  }
}

double _contrastRatio(Color foreground, Color background) {
  final foregroundLuminance = foreground.computeLuminance();
  final backgroundLuminance = background.computeLuminance();
  final lighter = foregroundLuminance > backgroundLuminance
      ? foregroundLuminance
      : backgroundLuminance;
  final darker = foregroundLuminance > backgroundLuminance
      ? backgroundLuminance
      : foregroundLuminance;

  return (lighter + 0.05) / (darker + 0.05);
}
