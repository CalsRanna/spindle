import 'package:flutter/widgets.dart';

/// Responsive breakpoints
class Breakpoints {
  static const double mobile = 600;
  static const double tablet = 900;
  static const double desktop = 1200;
}

/// Check if current screen is desktop size
bool isDesktop(BuildContext context) {
  return MediaQuery.of(context).size.width > Breakpoints.tablet;
}

/// Check if current screen is tablet size
bool isTablet(BuildContext context) {
  final width = MediaQuery.of(context).size.width;
  return width > Breakpoints.mobile && width <= Breakpoints.tablet;
}

/// Check if current screen is mobile size
bool isMobile(BuildContext context) {
  return MediaQuery.of(context).size.width <= Breakpoints.mobile;
}

/// Get responsive value based on screen size
T responsive<T>(
  BuildContext context, {
  required T mobile,
  T? tablet,
  T? desktop,
}) {
  if (isDesktop(context)) {
    return desktop ?? tablet ?? mobile;
  }
  if (isTablet(context)) {
    return tablet ?? mobile;
  }
  return mobile;
}
