import 'package:flutter/material.dart';
import 'app_theme.dart';
import '../theme_data/colors_theme_data.dart';
import '../../app_colors/app_colors.dart';

final class AppThemeLight extends AppTheme {
  AppThemeLight._();

  static final AppThemeLight _instance = AppThemeLight._();

  static AppThemeLight get instance => _instance;

  @override
  ThemeData getBaseThemeData(BuildContext context) => ThemeData.light(useMaterial3: true);

  @override
  ColorsThemeData getColorsThemeData(BuildContext context) => const ColorsThemeData(
    primary: AppColors.textInverse,
    secondary: AppColors.secondary,
    accent: AppColors.accent,
    background: AppColors.background,
    surface: AppColors.surface,
    cardBackground: AppColors.cardBackground,
    cardTinted: AppColors.cardTinted,
    textPrimary: AppColors.textPrimary,
    textSecondary: AppColors.textSecondary,
    textTertiary: AppColors.textTertiary,
    textInverse: AppColors.textInverse,
    buttonBackground: AppColors.primary,
    buttonBackgroundPressed: AppColors.uiPressed,
    buttonBackgroundDisabled: AppColors.uiDisabled,
    buttonText: AppColors.textInverse,
    outlinedButtonText: AppColors.primary,
    customButtonPrimaryBackground: AppColors.primary,
    customButtonPrimaryText: AppColors.textInverse,
    customButtonOutlineBorder: AppColors.primary,
    customButtonOutlineText: AppColors.primary,
    customButtonDisabledBackground: AppColors.uiDisabled,
    customButtonDisabledText: AppColors.uiDisabledText,
    containerBorder: AppColors.divider,
    textFieldBackground: AppColors.surface,
    textFieldBorderUnselected: AppColors.textInputDefault,
    textFieldBorderSelected: AppColors.textInputActive,
    uiPrimary: AppColors.uiPrimary,
    uiDisabled: AppColors.uiDisabled,
    error: AppColors.error,
    success: AppColors.success,
    warning: AppColors.warning,
    info: AppColors.info,
    overlay: AppColors.overlay,
    divider: AppColors.divider,
    inputText: AppColors.textInputActive,
  );
}
