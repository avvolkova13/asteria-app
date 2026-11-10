import 'package:flutter/material.dart';
import 'app_theme/app_theme.dart';
import 'app_theme/app_theme_dark.dart';
import 'app_theme/app_theme_light.dart';

class ThemeManager {
  static final ThemeManager _instance = ThemeManager._internal();
  factory ThemeManager() => _instance;
  ThemeManager._internal();

  static ThemeManager get instance => _instance;

  AppTheme getTheme(ThemeMode mode) {
    switch (mode) {
      case ThemeMode.light:
        return AppThemeLight.instance;
      case ThemeMode.dark:
        return AppThemeDark.instance;
      case ThemeMode.system:
        final brightness =
            WidgetsBinding.instance.platformDispatcher.platformBrightness;
        return brightness == Brightness.light
            ? AppThemeLight.instance
            : AppThemeDark.instance;
    }
  }

  ThemeData getThemeData(BuildContext context, ThemeMode mode) {
    return getTheme(mode).getThemeData(context);
  }

  ThemeData getLightThemeData(BuildContext context) {
    return AppThemeLight.instance.getThemeData(context);
  }

  ThemeData getDarkThemeData(BuildContext context) {
    return AppThemeDark.instance.getThemeData(context);
  }
}
