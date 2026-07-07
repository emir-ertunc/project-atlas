abstract final class AppComponentTokens {
  static const double minimumTouchTarget = 48;
  static const double controlHeight = 48;
  static const double largeControlHeight = 56;
  static const double navigationBarHeight = 80;
  static const double compactIcon = 20;
  static const double standardIcon = 24;
  static const double largeIcon = 32;
  static const double heroIcon = 64;
  static const double hairline = 1;
  static const double selectedStroke = 2;
}

abstract final class AppElevation {
  static const double none = 0;
  static const double low = 1;
  static const double medium = 3;
  static const double high = 6;
}

abstract final class AppMotion {
  static const Duration fast = Duration(milliseconds: 150);
  static const Duration standard = Duration(milliseconds: 250);
  static const Duration emphasized = Duration(milliseconds: 400);
}
