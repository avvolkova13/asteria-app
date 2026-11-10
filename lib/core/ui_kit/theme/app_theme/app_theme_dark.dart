import 'package:flutter/material.dart';
import 'app_theme.dart';
import '../theme_data/colors_theme_data.dart';
import '../../app_colors/app_colors.dart';

final class AppThemeDark extends AppTheme {
  AppThemeDark._();

  static final AppThemeDark _instance = AppThemeDark._();

  static AppThemeDark get instance => _instance;

  @override
  ThemeData getBaseThemeData(BuildContext context) =>
      ThemeData.dark(useMaterial3: true);

  @override
  ColorsThemeData getColorsThemeData(BuildContext context) =>
      const ColorsThemeData(
        primary: AppColorsDark.primary,
        secondary: AppColorsDark.secondary,
        accent: AppColorsDark.accent,
        background: AppColorsDark.background,
        surface: AppColorsDark.surface,
        cardBackground: AppColorsDark.cardBackground,
        // TODO: add cardTinted
        cardTinted: Colors.red,
        textPrimary: AppColorsDark.textPrimary,
        textSecondary: AppColorsDark.textSecondary,
        textTertiary: AppColorsDark.textTertiary,
        textInverse: AppColorsDark.textPrimary,
        buttonBackground: AppColorsDark.primary,
        buttonBackgroundPressed: Color(0xFF5A52E8),
        buttonBackgroundDisabled: Color(0xFF756F86),
        buttonText: AppColorsDark.textPrimary,
        outlinedButtonText: AppColorsDark.textSecondary,
        customButtonPrimaryBackground: AppColorsDark.primary,
        customButtonPrimaryText: AppColorsDark.textPrimary,
        customButtonOutlineBorder: AppColorsDark.textSecondary,
        customButtonOutlineText: AppColorsDark.textSecondary,
        customButtonDisabledBackground: Color(0xFF756F86),
        customButtonDisabledText: Color(0xFF9E95A2),
        containerBorder: AppColorsDark.divider,
        textFieldBackground: AppColorsDark.cardBackground,
        textFieldBorderUnselected: AppColorsDark.textSecondary,
        textFieldBorderSelected: AppColorsDark.textPrimary,
        // TODO: add uiPrimary and uiDisabled
        uiPrimary: Colors.red,
        uiDisabled: Colors.red,
        error: Color(0xFFF44336),
        success: Color(0xFF4CAF50),
        warning: Color(0xFFFF9800),
        info: Color(0xFF2196F3),
        overlay: AppColorsDark.overlay,
        divider: AppColorsDark.divider,
        inputText: AppColorsDark.textPrimary,
      );
}
