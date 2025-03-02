class AppConstants {
  // Double constants
  static const double appBarFontScale = 0.05;
  static const double minZoom = 10.0;
  static const double defaultZoom = 15.0;
  static const double logoScale = 0.3;
  static const double inputHeightScale = 0.07;
  static const double fontScale = 0.04;
  static const double paddingScale = 0.05;
  static const double buttonHeightScale = 0.07;
  static const double spacingScale = 0.02;
  static const double iconScale = 0.06;
  static const double headerFontScale = 0.05;
  static const double listItemFontScale = 0.04;
  static const double headerHeightScale = 0.15;
  static const double searchFieldHeightScale = 0.06;
  static const double cardPaddingScale = 0.03;

  // Integer constants
  static const int smallScreenBreakpoint = 400;
  static const int largeScreenBreakpoint = 600;
  static const int sessionTimeoutHours = 2;

  // Duration constants
  static const Duration locationUpdateInterval = Duration(seconds: 10);
  static const Duration sessionTimeout = Duration(hours: sessionTimeoutHours);

  // String constants
  static const String tileUrl =
      'https://tile.openstreetmap.org/{z}/{x}/{y}.png';
}
