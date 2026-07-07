import 'package:flutter/material.dart';

abstract final class AppTypography {
  static TextTheme textTheme(Color color) {
    return TextTheme(
      displayLarge: TextStyle(
        color: color,
        fontSize: 48,
        fontWeight: FontWeight.w700,
        height: 1.08,
        letterSpacing: -0.8,
      ),
      displayMedium: TextStyle(
        color: color,
        fontSize: 40,
        fontWeight: FontWeight.w700,
        height: 1.1,
        letterSpacing: -0.6,
      ),
      displaySmall: TextStyle(
        color: color,
        fontSize: 34,
        fontWeight: FontWeight.w700,
        height: 1.12,
        letterSpacing: -0.4,
      ),
      headlineLarge: TextStyle(
        color: color,
        fontSize: 32,
        fontWeight: FontWeight.w700,
        height: 1.18,
        letterSpacing: -0.3,
      ),
      headlineMedium: TextStyle(
        color: color,
        fontSize: 28,
        fontWeight: FontWeight.w700,
        height: 1.2,
        letterSpacing: -0.2,
      ),
      headlineSmall: TextStyle(
        color: color,
        fontSize: 24,
        fontWeight: FontWeight.w700,
        height: 1.25,
      ),
      titleLarge: TextStyle(
        color: color,
        fontSize: 22,
        fontWeight: FontWeight.w700,
        height: 1.27,
      ),
      titleMedium: TextStyle(
        color: color,
        fontSize: 16,
        fontWeight: FontWeight.w600,
        height: 1.35,
        letterSpacing: 0.1,
      ),
      titleSmall: TextStyle(
        color: color,
        fontSize: 14,
        fontWeight: FontWeight.w600,
        height: 1.4,
        letterSpacing: 0.1,
      ),
      bodyLarge: TextStyle(
        color: color,
        fontSize: 16,
        fontWeight: FontWeight.w400,
        height: 1.5,
        letterSpacing: 0.15,
      ),
      bodyMedium: TextStyle(
        color: color,
        fontSize: 14,
        fontWeight: FontWeight.w400,
        height: 1.45,
        letterSpacing: 0.2,
      ),
      bodySmall: TextStyle(
        color: color,
        fontSize: 12,
        fontWeight: FontWeight.w400,
        height: 1.4,
        letterSpacing: 0.3,
      ),
      labelLarge: TextStyle(
        color: color,
        fontSize: 14,
        fontWeight: FontWeight.w600,
        height: 1.3,
        letterSpacing: 0.2,
      ),
      labelMedium: TextStyle(
        color: color,
        fontSize: 12,
        fontWeight: FontWeight.w600,
        height: 1.3,
        letterSpacing: 0.4,
      ),
      labelSmall: TextStyle(
        color: color,
        fontSize: 11,
        fontWeight: FontWeight.w600,
        height: 1.3,
        letterSpacing: 0.5,
      ),
    );
  }
}
