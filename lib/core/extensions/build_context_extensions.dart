import 'package:flutter/material.dart';
import '../localization/generated/l10n.dart';
import '../ui_kit/theme/theme_data/text_theme_data.dart';
import '../ui_kit/theme/theme_data/corners_theme_data.dart';
import '../ui_kit/theme/theme_data/colors_theme_data.dart';
import '../ui_kit/theme/theme_data/spacing_theme_data.dart';

extension BuildContextExtensions on BuildContext {
  AppLocalizations get l10n => AppLocalizations.of(this);

  ThemeData get theme => Theme.of(this);

  TextThemeData get textTheme => Theme.of(this).extension<TextThemeData>()!;

  CornersThemeData get corners => Theme.of(this).extension<CornersThemeData>()!;

  ColorsThemeData get colors => Theme.of(this).extension<ColorsThemeData>()!;

  SpacingThemeData get spacing => Theme.of(this).extension<SpacingThemeData>()!;

  bool get isDarkTheme => Theme.of(this).brightness == Brightness.dark;

  bool get isLightTheme => Theme.of(this).brightness == Brightness.light;
}
