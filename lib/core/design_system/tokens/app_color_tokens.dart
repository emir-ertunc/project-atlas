import 'package:flutter/material.dart';

abstract final class AppColorTokens {
  static const lightScheme = ColorScheme(
    brightness: Brightness.light,
    primary: Color(0xFF006A67),
    onPrimary: Color(0xFFFFFFFF),
    primaryContainer: Color(0xFF9CF2ED),
    onPrimaryContainer: Color(0xFF00201F),
    secondary: Color(0xFF4A6361),
    onSecondary: Color(0xFFFFFFFF),
    secondaryContainer: Color(0xFFCCE8E5),
    onSecondaryContainer: Color(0xFF061F1E),
    tertiary: Color(0xFF49617A),
    onTertiary: Color(0xFFFFFFFF),
    tertiaryContainer: Color(0xFFD0E5FF),
    onTertiaryContainer: Color(0xFF001D33),
    error: Color(0xFFBA1A1A),
    onError: Color(0xFFFFFFFF),
    errorContainer: Color(0xFFFFDAD6),
    onErrorContainer: Color(0xFF410002),
    surface: Color(0xFFF4FBF9),
    onSurface: Color(0xFF161D1C),
    surfaceContainerLowest: Color(0xFFFFFFFF),
    surfaceContainerLow: Color(0xFFEEF5F3),
    surfaceContainer: Color(0xFFE8EFED),
    surfaceContainerHigh: Color(0xFFE2E9E7),
    surfaceContainerHighest: Color(0xFFDCE4E2),
    onSurfaceVariant: Color(0xFF3F4947),
    outline: Color(0xFF6F7977),
    outlineVariant: Color(0xFFBEC9C6),
    shadow: Color(0xFF000000),
    scrim: Color(0xFF000000),
    inverseSurface: Color(0xFF2B3231),
    onInverseSurface: Color(0xFFECF2F0),
    inversePrimary: Color(0xFF80D5D0),
  );

  static const darkScheme = ColorScheme(
    brightness: Brightness.dark,
    primary: Color(0xFF80D5D0),
    onPrimary: Color(0xFF003735),
    primaryContainer: Color(0xFF00504D),
    onPrimaryContainer: Color(0xFF9CF2ED),
    secondary: Color(0xFFB0CCC9),
    onSecondary: Color(0xFF1B3533),
    secondaryContainer: Color(0xFF324B49),
    onSecondaryContainer: Color(0xFFCCE8E5),
    tertiary: Color(0xFFB1C9E7),
    onTertiary: Color(0xFF1B324A),
    tertiaryContainer: Color(0xFF324961),
    onTertiaryContainer: Color(0xFFD0E5FF),
    error: Color(0xFFFFB4AB),
    onError: Color(0xFF690005),
    errorContainer: Color(0xFF93000A),
    onErrorContainer: Color(0xFFFFDAD6),
    surface: Color(0xFF0E1514),
    onSurface: Color(0xFFDEE4E2),
    surfaceContainerLowest: Color(0xFF090F0E),
    surfaceContainerLow: Color(0xFF161D1C),
    surfaceContainer: Color(0xFF1A2120),
    surfaceContainerHigh: Color(0xFF252B2A),
    surfaceContainerHighest: Color(0xFF303635),
    onSurfaceVariant: Color(0xFFBEC9C6),
    outline: Color(0xFF899391),
    outlineVariant: Color(0xFF3F4947),
    shadow: Color(0xFF000000),
    scrim: Color(0xFF000000),
    inverseSurface: Color(0xFFDEE4E2),
    onInverseSurface: Color(0xFF2B3231),
    inversePrimary: Color(0xFF006A67),
  );

  static const lightSemantic = AppSemanticColors(
    success: Color(0xFF1D6B42),
    onSuccess: Color(0xFFFFFFFF),
    successContainer: Color(0xFFA7F2C0),
    onSuccessContainer: Color(0xFF00210E),
    warning: Color(0xFF765B00),
    onWarning: Color(0xFFFFFFFF),
    warningContainer: Color(0xFFFFE082),
    onWarningContainer: Color(0xFF241A00),
    information: Color(0xFF1D5F9E),
    onInformation: Color(0xFFFFFFFF),
    informationContainer: Color(0xFFD2E4FF),
    onInformationContainer: Color(0xFF001C38),
  );

  static const darkSemantic = AppSemanticColors(
    success: Color(0xFF8BD5A4),
    onSuccess: Color(0xFF00391C),
    successContainer: Color(0xFF00522B),
    onSuccessContainer: Color(0xFFA7F2C0),
    warning: Color(0xFFEAC248),
    onWarning: Color(0xFF3D2E00),
    warningContainer: Color(0xFF574500),
    onWarningContainer: Color(0xFFFFE082),
    information: Color(0xFFA4C9FF),
    onInformation: Color(0xFF00315C),
    informationContainer: Color(0xFF004880),
    onInformationContainer: Color(0xFFD2E4FF),
  );
}

@immutable
class AppSemanticColors extends ThemeExtension<AppSemanticColors> {
  const AppSemanticColors({
    required this.success,
    required this.onSuccess,
    required this.successContainer,
    required this.onSuccessContainer,
    required this.warning,
    required this.onWarning,
    required this.warningContainer,
    required this.onWarningContainer,
    required this.information,
    required this.onInformation,
    required this.informationContainer,
    required this.onInformationContainer,
  });

  final Color success;
  final Color onSuccess;
  final Color successContainer;
  final Color onSuccessContainer;
  final Color warning;
  final Color onWarning;
  final Color warningContainer;
  final Color onWarningContainer;
  final Color information;
  final Color onInformation;
  final Color informationContainer;
  final Color onInformationContainer;

  @override
  AppSemanticColors copyWith({
    Color? success,
    Color? onSuccess,
    Color? successContainer,
    Color? onSuccessContainer,
    Color? warning,
    Color? onWarning,
    Color? warningContainer,
    Color? onWarningContainer,
    Color? information,
    Color? onInformation,
    Color? informationContainer,
    Color? onInformationContainer,
  }) {
    return AppSemanticColors(
      success: success ?? this.success,
      onSuccess: onSuccess ?? this.onSuccess,
      successContainer: successContainer ?? this.successContainer,
      onSuccessContainer: onSuccessContainer ?? this.onSuccessContainer,
      warning: warning ?? this.warning,
      onWarning: onWarning ?? this.onWarning,
      warningContainer: warningContainer ?? this.warningContainer,
      onWarningContainer: onWarningContainer ?? this.onWarningContainer,
      information: information ?? this.information,
      onInformation: onInformation ?? this.onInformation,
      informationContainer: informationContainer ?? this.informationContainer,
      onInformationContainer:
          onInformationContainer ?? this.onInformationContainer,
    );
  }

  @override
  AppSemanticColors lerp(covariant AppSemanticColors? other, double t) {
    if (other == null) {
      return this;
    }

    return AppSemanticColors(
      success: Color.lerp(success, other.success, t)!,
      onSuccess: Color.lerp(onSuccess, other.onSuccess, t)!,
      successContainer: Color.lerp(
        successContainer,
        other.successContainer,
        t,
      )!,
      onSuccessContainer: Color.lerp(
        onSuccessContainer,
        other.onSuccessContainer,
        t,
      )!,
      warning: Color.lerp(warning, other.warning, t)!,
      onWarning: Color.lerp(onWarning, other.onWarning, t)!,
      warningContainer: Color.lerp(
        warningContainer,
        other.warningContainer,
        t,
      )!,
      onWarningContainer: Color.lerp(
        onWarningContainer,
        other.onWarningContainer,
        t,
      )!,
      information: Color.lerp(information, other.information, t)!,
      onInformation: Color.lerp(onInformation, other.onInformation, t)!,
      informationContainer: Color.lerp(
        informationContainer,
        other.informationContainer,
        t,
      )!,
      onInformationContainer: Color.lerp(
        onInformationContainer,
        other.onInformationContainer,
        t,
      )!,
    );
  }
}

extension AppSemanticColorsBuildContext on BuildContext {
  AppSemanticColors get semanticColors =>
      Theme.of(this).extension<AppSemanticColors>()!;
}
