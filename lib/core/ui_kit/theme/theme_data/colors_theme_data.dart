import 'package:flutter/material.dart';

final class ColorsThemeData extends ThemeExtension<ColorsThemeData> {
  const ColorsThemeData({
    required this.primary,
    required this.secondary,
    required this.accent,
    required this.background,
    required this.surface,
    required this.cardBackground,
    required this.cardTinted,
    required this.textPrimary,
    required this.textSecondary,
    required this.textTertiary,
    required this.textInverse,
    required this.buttonBackground,
    required this.buttonBackgroundPressed,
    required this.buttonBackgroundDisabled,
    required this.buttonText,
    required this.outlinedButtonText,
    required this.containerBorder,
    required this.textFieldBackground,
    required this.textFieldBorderUnselected,
    required this.textFieldBorderSelected,
    required this.uiPrimary,
    required this.uiDisabled,
    required this.error,
    required this.success,
    required this.warning,
    required this.info,
    required this.overlay,
    required this.divider,
    required this.customButtonPrimaryBackground,
    required this.customButtonPrimaryText,
    required this.customButtonOutlineBorder,
    required this.customButtonOutlineText,
    required this.customButtonDisabledBackground,
    required this.customButtonDisabledText,
    required this.inputText,
  });

  final Color primary;
  final Color secondary;
  final Color accent;
  final Color background;
  final Color surface;
  final Color cardBackground;
  final Color cardTinted;
  final Color textPrimary;
  final Color textSecondary;
  final Color textTertiary;
  final Color textInverse;
  final Color buttonBackground;
  final Color buttonBackgroundPressed;
  final Color buttonBackgroundDisabled;
  final Color buttonText;
  final Color outlinedButtonText;
  final Color containerBorder;
  final Color textFieldBackground;
  final Color textFieldBorderUnselected;
  final Color textFieldBorderSelected;
  final Color uiPrimary;
  final Color uiDisabled;
  final Color error;
  final Color success;
  final Color warning;
  final Color info;
  final Color overlay;
  final Color divider;
  final Color customButtonPrimaryBackground;
  final Color customButtonPrimaryText;
  final Color customButtonOutlineBorder;
  final Color customButtonOutlineText;
  final Color customButtonDisabledBackground;
  final Color customButtonDisabledText;
  final Color inputText;

  @override
  ThemeExtension<ColorsThemeData> copyWith() {
    return ColorsThemeData(
      primary: primary,
      textInverse: textInverse,
      secondary: secondary,
      accent: accent,
      background: background,
      surface: surface,
      cardBackground: cardBackground,
      cardTinted: cardTinted,
      textPrimary: textPrimary,
      textSecondary: textSecondary,
      textTertiary: textTertiary,
      buttonBackground: buttonBackground,
      buttonBackgroundPressed: buttonBackgroundPressed,
      buttonBackgroundDisabled: buttonBackgroundDisabled,
      buttonText: buttonText,
      outlinedButtonText: outlinedButtonText,
      containerBorder: containerBorder,
      textFieldBackground: textFieldBackground,
      textFieldBorderUnselected: textFieldBorderUnselected,
      textFieldBorderSelected: textFieldBorderSelected,
      uiPrimary: uiPrimary,
      uiDisabled: uiDisabled,
      error: error,
      success: success,
      warning: warning,
      info: info,
      overlay: overlay,
      divider: divider,
      customButtonPrimaryBackground: customButtonPrimaryBackground,
      customButtonPrimaryText: customButtonPrimaryText,
      customButtonOutlineBorder: customButtonOutlineBorder,
      customButtonOutlineText: customButtonOutlineText,
      customButtonDisabledBackground: customButtonDisabledBackground,
      customButtonDisabledText: customButtonDisabledText,
      inputText: inputText,
    );
  }

  @override
  ThemeExtension<ColorsThemeData> lerp(
    covariant ThemeExtension<ColorsThemeData>? other,
    double t,
  ) {
    if (other is! ColorsThemeData) {
      return this;
    }
    return ColorsThemeData(
      primary: Color.lerp(primary, other.primary, t) ?? Colors.transparent,
      textInverse:
          Color.lerp(textInverse, other.textInverse, t) ?? Colors.transparent,
      secondary:
          Color.lerp(secondary, other.secondary, t) ?? Colors.transparent,
      accent: Color.lerp(accent, other.accent, t) ?? Colors.transparent,
      background:
          Color.lerp(background, other.background, t) ?? Colors.transparent,
      surface: Color.lerp(surface, other.surface, t) ?? Colors.transparent,
      cardBackground:
          Color.lerp(cardBackground, other.cardBackground, t) ??
          Colors.transparent,
      cardTinted:
          Color.lerp(cardTinted, other.cardTinted, t) ?? Colors.transparent,
      textPrimary:
          Color.lerp(textPrimary, other.textPrimary, t) ?? Colors.transparent,
      textSecondary:
          Color.lerp(textSecondary, other.textSecondary, t) ??
          Colors.transparent,
      textTertiary:
          Color.lerp(textTertiary, other.textTertiary, t) ?? Colors.transparent,
      buttonBackground:
          Color.lerp(buttonBackground, other.buttonBackground, t) ??
          Colors.transparent,
      buttonBackgroundPressed:
          Color.lerp(
            buttonBackgroundPressed,
            other.buttonBackgroundPressed,
            t,
          ) ??
          Colors.transparent,
      buttonBackgroundDisabled:
          Color.lerp(
            buttonBackgroundDisabled,
            other.buttonBackgroundDisabled,
            t,
          ) ??
          Colors.transparent,
      buttonText:
          Color.lerp(buttonText, other.buttonText, t) ?? Colors.transparent,
      outlinedButtonText:
          Color.lerp(outlinedButtonText, other.outlinedButtonText, t) ??
          Colors.transparent,
      containerBorder:
          Color.lerp(containerBorder, other.containerBorder, t) ??
          Colors.transparent,
      textFieldBackground:
          Color.lerp(textFieldBackground, other.textFieldBackground, t) ??
          Colors.transparent,
      textFieldBorderUnselected:
          Color.lerp(
            textFieldBorderUnselected,
            other.textFieldBorderUnselected,
            t,
          ) ??
          Colors.transparent,
      textFieldBorderSelected:
          Color.lerp(
            textFieldBorderSelected,
            other.textFieldBorderSelected,
            t,
          ) ??
          Colors.transparent,
      uiPrimary:
          Color.lerp(uiPrimary, other.uiPrimary, t) ?? Colors.transparent,
      uiDisabled:
          Color.lerp(uiDisabled, other.uiDisabled, t) ?? Colors.transparent,
      error: Color.lerp(error, other.error, t) ?? Colors.transparent,
      success: Color.lerp(success, other.success, t) ?? Colors.transparent,
      warning: Color.lerp(warning, other.warning, t) ?? Colors.transparent,
      info: Color.lerp(info, other.info, t) ?? Colors.transparent,
      overlay: Color.lerp(overlay, other.overlay, t) ?? Colors.transparent,
      divider: Color.lerp(divider, other.divider, t) ?? Colors.transparent,
      customButtonPrimaryBackground:
          Color.lerp(
            customButtonPrimaryBackground,
            other.customButtonPrimaryBackground,
            t,
          ) ??
          Colors.transparent,
      customButtonPrimaryText:
          Color.lerp(
            customButtonPrimaryText,
            other.customButtonPrimaryText,
            t,
          ) ??
          Colors.transparent,
      customButtonOutlineBorder:
          Color.lerp(
            customButtonOutlineBorder,
            other.customButtonOutlineBorder,
            t,
          ) ??
          Colors.transparent,
      customButtonOutlineText:
          Color.lerp(
            customButtonOutlineText,
            other.customButtonOutlineText,
            t,
          ) ??
          Colors.transparent,
      customButtonDisabledBackground:
          Color.lerp(
            customButtonDisabledBackground,
            other.customButtonDisabledBackground,
            t,
          ) ??
          Colors.transparent,
      customButtonDisabledText:
          Color.lerp(
            customButtonDisabledText,
            other.customButtonDisabledText,
            t,
          ) ??
          Colors.transparent,
      inputText:
          Color.lerp(inputText, other.inputText, t) ?? Colors.transparent,
    );
  }
}
