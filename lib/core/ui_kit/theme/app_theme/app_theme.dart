import 'package:flutter/cupertino.dart'
    show CupertinoTextThemeData, NoDefaultCupertinoThemeData;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../app_typography.dart';
import '../../widgets/card_lens_decoration.dart';
import '../../widgets/modal_glass_surface.dart';
import '../theme_data/colors_theme_data.dart';
import '../theme_data/corners_theme_data.dart';
import '../theme_data/spacing_theme_data.dart';
import '../theme_data/text_theme_data.dart';

abstract class AppTheme {
  /// Предоставляет [ColorsThemeData] для темы
  ColorsThemeData getColorsThemeData(BuildContext context);

  /// Предоставляет [CornersThemeData] для темы
  CornersThemeData getCornersThemeData(BuildContext context) {
    return const CornersThemeData(
      extraSmall: BorderRadius.all(Radius.circular(4)),
      small: BorderRadius.all(Radius.circular(8)),
      medium: BorderRadius.all(Radius.circular(12)),
      large: BorderRadius.all(Radius.circular(16)),
      extraLarge: BorderRadius.all(Radius.circular(24)),
    );
  }

  /// Предоставляет [SpacingThemeData] для темы
  SpacingThemeData getSpacingThemeData(BuildContext context) {
    return const SpacingThemeData(
      extraSmall: 4,
      small: 8,
      medium: 16,
      mediumLarge: 24,
      large: 32,
      extraLarge: 64,
    );
  }

  /// Предоставляет [TextThemeData] для темы
  TextThemeData getTextTheme(
    BuildContext context, {
    required ColorsThemeData colorSchemeData,
  }) {
    // Older screens still address styles by size and contrast. Preserve those
    // color roles while sourcing type metrics from the same Figma styles.
    return TextThemeData(
      secondaryUrbanistRegular16: AppTypography.text1.copyWith(
        color: colorSchemeData.textSecondary,
      ),
      button: AppTypography.text1SemiBold.copyWith(
        color: colorSchemeData.buttonText,
      ),
      buttonOutline: AppTypography.text1SemiBold.copyWith(
        color: colorSchemeData.outlinedButtonText,
      ),
      appBarTitle: AppTypography.navTitle.copyWith(
        color: colorSchemeData.textPrimary,
      ),
      subtitle: AppTypography.text1.copyWith(
        color: colorSchemeData.textPrimary,
      ),
      subtitleInverse: AppTypography.text1.copyWith(
        color: colorSchemeData.textInverse,
      ),
      inputHint: AppTypography.placeholder.copyWith(
        color: colorSchemeData.textTertiary,
      ),
      inputText: AppTypography.placeholder.copyWith(
        color: colorSchemeData.inputText,
      ),
      inputErrorText: AppTypography.subtext.copyWith(
        color: colorSchemeData.error,
      ),
      codeInput: AppTypography.placeholderSemiBold.copyWith(
        color: colorSchemeData.inputText,
      ),
      playfairRegular12: AppTypography.h4.copyWith(
        fontSize: 12,
        fontWeight: FontWeight.w400,
        color: colorSchemeData.textPrimary,
      ),
      playfairRegular14: AppTypography.h4.copyWith(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        color: colorSchemeData.textPrimary,
      ),
      playfairRegular16: AppTypography.h4.copyWith(
        fontWeight: FontWeight.w400,
        color: colorSchemeData.textPrimary,
      ),
      playfairRegular17: AppTypography.navTitle.copyWith(
        fontWeight: FontWeight.w400,
        color: colorSchemeData.textPrimary,
      ),
      playfairRegular18: AppTypography.h3.copyWith(
        fontSize: 18,
        fontWeight: FontWeight.w400,
        color: colorSchemeData.textPrimary,
      ),
      playfairRegular20: AppTypography.h3.copyWith(
        fontWeight: FontWeight.w400,
        color: colorSchemeData.textPrimary,
      ),
      playfairRegular24: AppTypography.h2.copyWith(
        fontWeight: FontWeight.w400,
        color: colorSchemeData.textPrimary,
      ),
      playfairRegular32: AppTypography.h1.copyWith(
        fontWeight: FontWeight.w400,
        color: colorSchemeData.textPrimary,
      ),
      playfairMedium12: AppTypography.h4.copyWith(
        fontSize: 12,
        color: colorSchemeData.textPrimary,
      ),
      playfairMedium14: AppTypography.h4.copyWith(
        fontSize: 14,
        color: colorSchemeData.textPrimary,
      ),
      playfairMedium16: AppTypography.h4.copyWith(
        color: colorSchemeData.textPrimary,
      ),
      playfairMedium17: AppTypography.navTitle.copyWith(
        fontWeight: FontWeight.w500,
        color: colorSchemeData.textPrimary,
      ),
      playfairMedium18: AppTypography.h3.copyWith(
        fontSize: 18,
        color: colorSchemeData.textPrimary,
      ),
      playfairMedium20: AppTypography.h3.copyWith(
        color: colorSchemeData.textPrimary,
      ),
      playfairMedium24: AppTypography.h2.copyWith(
        fontWeight: FontWeight.w500,
        color: colorSchemeData.textPrimary,
      ),
      playfairMedium32: AppTypography.h1.copyWith(
        fontWeight: FontWeight.w500,
        color: colorSchemeData.textPrimary,
      ),
      playfairSemiBold12: AppTypography.h4.copyWith(
        fontSize: 12,
        fontWeight: FontWeight.w600,
        color: colorSchemeData.textPrimary,
      ),
      playfairSemiBold14: AppTypography.h4.copyWith(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: colorSchemeData.textPrimary,
      ),
      playfairSemiBold16: AppTypography.h4.copyWith(
        fontWeight: FontWeight.w600,
        color: colorSchemeData.textPrimary,
      ),
      playfairSemiBold17: AppTypography.navTitle.copyWith(
        color: colorSchemeData.textPrimary,
      ),
      playfairSemiBold18: AppTypography.h3.copyWith(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: colorSchemeData.textPrimary,
      ),
      playfairSemiBold20: AppTypography.h3.copyWith(
        fontWeight: FontWeight.w600,
        color: colorSchemeData.textPrimary,
      ),
      playfairSemiBold24: AppTypography.h2.copyWith(
        color: colorSchemeData.textPrimary,
      ),
      playfairSemiBold32: AppTypography.h1.copyWith(
        color: colorSchemeData.textPrimary,
      ),
      playfairBold12: AppTypography.h4.copyWith(
        fontSize: 12,
        fontWeight: FontWeight.w700,
        color: colorSchemeData.textPrimary,
      ),
      playfairBold14: AppTypography.h4.copyWith(
        fontSize: 14,
        fontWeight: FontWeight.w700,
        color: colorSchemeData.textPrimary,
      ),
      playfairBold16: AppTypography.h4.copyWith(
        fontWeight: FontWeight.w700,
        color: colorSchemeData.textPrimary,
      ),
      playfairBold17: AppTypography.navTitle.copyWith(
        fontWeight: FontWeight.w700,
        color: colorSchemeData.textPrimary,
      ),
      playfairBold18: AppTypography.h3.copyWith(
        fontSize: 18,
        fontWeight: FontWeight.w700,
        color: colorSchemeData.textPrimary,
      ),
      playfairBold20: AppTypography.h3.copyWith(
        fontWeight: FontWeight.w700,
        color: colorSchemeData.textPrimary,
      ),
      playfairBold24: AppTypography.h2.copyWith(
        fontWeight: FontWeight.w700,
        color: colorSchemeData.textPrimary,
      ),
      playfairBold32: AppTypography.h1.copyWith(
        fontWeight: FontWeight.w700,
        color: colorSchemeData.textPrimary,
      ),
      urbanistRegular12: AppTypography.subtext.copyWith(
        color: colorSchemeData.textPrimary,
      ),
      urbanistRegular14: AppTypography.body14.copyWith(
        color: colorSchemeData.textPrimary,
      ),
      urbanistRegular16: AppTypography.text1.copyWith(
        color: colorSchemeData.textPrimary,
      ),
      urbanistRegular17: AppTypography.placeholder.copyWith(
        color: colorSchemeData.textPrimary,
      ),
      urbanistRegular18: AppTypography.text1.copyWith(
        fontSize: 18,
        color: colorSchemeData.textPrimary,
      ),
      urbanistRegular20: AppTypography.text1.copyWith(
        fontSize: 20,
        color: colorSchemeData.textPrimary,
      ),
      urbanistRegular24: AppTypography.text1.copyWith(
        fontSize: 24,
        color: colorSchemeData.textPrimary,
      ),
      urbanistRegular32: AppTypography.text1.copyWith(
        fontSize: 32,
        color: colorSchemeData.textPrimary,
      ),
      urbanistMedium12: AppTypography.subtext.copyWith(
        fontWeight: FontWeight.w500,
        color: colorSchemeData.textPrimary,
      ),
      urbanistMedium14: AppTypography.label14.copyWith(
        color: colorSchemeData.textPrimary,
      ),
      urbanistMedium16: AppTypography.text1.copyWith(
        fontWeight: FontWeight.w500,
        color: colorSchemeData.textPrimary,
      ),
      urbanistMedium17: AppTypography.placeholder.copyWith(
        fontWeight: FontWeight.w500,
        color: colorSchemeData.textPrimary,
      ),
      urbanistMedium18: AppTypography.text1.copyWith(
        fontSize: 18,
        fontWeight: FontWeight.w500,
        color: colorSchemeData.textPrimary,
      ),
      urbanistMedium20: AppTypography.text1.copyWith(
        fontSize: 20,
        fontWeight: FontWeight.w500,
        color: colorSchemeData.textPrimary,
      ),
      urbanistMedium24: AppTypography.text1.copyWith(
        fontSize: 24,
        fontWeight: FontWeight.w500,
        color: colorSchemeData.textPrimary,
      ),
      urbanistMedium32: AppTypography.text1.copyWith(
        fontSize: 32,
        fontWeight: FontWeight.w500,
        color: colorSchemeData.textPrimary,
      ),
      urbanistSemiBold12: AppTypography.subtextSemiBold.copyWith(
        color: colorSchemeData.textPrimary,
      ),
      urbanistSemiBold14: AppTypography.body14.copyWith(
        fontWeight: FontWeight.w600,
        color: colorSchemeData.textPrimary,
      ),
      urbanistSemiBold16: AppTypography.text1SemiBold.copyWith(
        color: colorSchemeData.textPrimary,
      ),
      urbanistSemiBold17: AppTypography.placeholderSemiBold.copyWith(
        color: colorSchemeData.textPrimary,
      ),
      urbanistSemiBold18: AppTypography.text1SemiBold.copyWith(
        fontSize: 18,
        color: colorSchemeData.textPrimary,
      ),
      urbanistSemiBold20: AppTypography.text1SemiBold.copyWith(
        fontSize: 20,
        color: colorSchemeData.textPrimary,
      ),
      urbanistSemiBold24: AppTypography.text1SemiBold.copyWith(
        fontSize: 24,
        color: colorSchemeData.textPrimary,
      ),
      urbanistSemiBold32: AppTypography.text1SemiBold.copyWith(
        fontSize: 32,
        color: colorSchemeData.textPrimary,
      ),
      urbanistBold12: AppTypography.subtext.copyWith(
        fontWeight: FontWeight.w700,
        color: colorSchemeData.textPrimary,
      ),
      urbanistBold14: AppTypography.body14.copyWith(
        fontWeight: FontWeight.w700,
        color: colorSchemeData.textPrimary,
      ),
      urbanistBold16: AppTypography.text1.copyWith(
        fontWeight: FontWeight.w700,
        color: colorSchemeData.textPrimary,
      ),
      urbanistBold17: AppTypography.placeholder.copyWith(
        fontWeight: FontWeight.w700,
        color: colorSchemeData.textPrimary,
      ),
      urbanistBold18: AppTypography.text1.copyWith(
        fontSize: 18,
        fontWeight: FontWeight.w700,
        color: colorSchemeData.textPrimary,
      ),
      urbanistBold20: AppTypography.text1.copyWith(
        fontSize: 20,
        fontWeight: FontWeight.w700,
        color: colorSchemeData.textPrimary,
      ),
      urbanistBold24: AppTypography.text1.copyWith(
        fontSize: 24,
        fontWeight: FontWeight.w700,
        color: colorSchemeData.textPrimary,
      ),
      urbanistBold32: AppTypography.text1.copyWith(
        fontSize: 32,
        fontWeight: FontWeight.w700,
        color: colorSchemeData.textPrimary,
      ),
      inversePlayfairRegular12: AppTypography.h4.copyWith(
        fontSize: 12,
        fontWeight: FontWeight.w400,
        color: colorSchemeData.textInverse,
      ),
      inversePlayfairRegular14: AppTypography.h4.copyWith(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        color: colorSchemeData.textInverse,
      ),
      inversePlayfairRegular16: AppTypography.h4.copyWith(
        fontWeight: FontWeight.w400,
        color: colorSchemeData.textInverse,
      ),
      inversePlayfairRegular17: AppTypography.navTitle.copyWith(
        fontWeight: FontWeight.w400,
        color: colorSchemeData.textInverse,
      ),
      inversePlayfairRegular18: AppTypography.h3.copyWith(
        fontSize: 18,
        fontWeight: FontWeight.w400,
        color: colorSchemeData.textInverse,
      ),
      inversePlayfairRegular20: AppTypography.h3.copyWith(
        fontWeight: FontWeight.w400,
        color: colorSchemeData.textInverse,
      ),
      inversePlayfairRegular24: AppTypography.h2.copyWith(
        fontWeight: FontWeight.w400,
        color: colorSchemeData.textInverse,
      ),
      inversePlayfairRegular32: AppTypography.h1.copyWith(
        fontWeight: FontWeight.w400,
        color: colorSchemeData.textInverse,
      ),
      inversePlayfairMedium12: AppTypography.h4.copyWith(
        fontSize: 12,
        color: colorSchemeData.textInverse,
      ),
      inversePlayfairMedium14: AppTypography.h4.copyWith(
        fontSize: 14,
        color: colorSchemeData.textInverse,
      ),
      inversePlayfairMedium16: AppTypography.h4.copyWith(
        color: colorSchemeData.textInverse,
      ),
      inversePlayfairMedium17: AppTypography.navTitle.copyWith(
        fontWeight: FontWeight.w500,
        color: colorSchemeData.textInverse,
      ),
      inversePlayfairMedium18: AppTypography.h3.copyWith(
        fontSize: 18,
        color: colorSchemeData.textInverse,
      ),
      inversePlayfairMedium20: AppTypography.h3.copyWith(
        color: colorSchemeData.textInverse,
      ),
      inversePlayfairMedium24: AppTypography.h2.copyWith(
        fontWeight: FontWeight.w500,
        color: colorSchemeData.textInverse,
      ),
      inversePlayfairMedium32: AppTypography.h1.copyWith(
        fontWeight: FontWeight.w500,
        color: colorSchemeData.textInverse,
      ),
      inversePlayfairSemiBold12: AppTypography.h4.copyWith(
        fontSize: 12,
        fontWeight: FontWeight.w600,
        color: colorSchemeData.textInverse,
      ),
      inversePlayfairSemiBold14: AppTypography.h4.copyWith(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: colorSchemeData.textInverse,
      ),
      inversePlayfairSemiBold16: AppTypography.h4.copyWith(
        fontWeight: FontWeight.w600,
        color: colorSchemeData.textInverse,
      ),
      inversePlayfairSemiBold17: AppTypography.navTitle.copyWith(
        color: colorSchemeData.textInverse,
      ),
      inversePlayfairSemiBold18: AppTypography.h3.copyWith(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: colorSchemeData.textInverse,
      ),
      inversePlayfairSemiBold20: AppTypography.h3.copyWith(
        fontWeight: FontWeight.w600,
        color: colorSchemeData.textInverse,
      ),
      inversePlayfairSemiBold24: AppTypography.h2.copyWith(
        color: colorSchemeData.textInverse,
      ),
      inversePlayfairSemiBold32: AppTypography.h1.copyWith(
        color: colorSchemeData.textInverse,
      ),
      inversePlayfairBold12: AppTypography.h4.copyWith(
        fontSize: 12,
        fontWeight: FontWeight.w700,
        color: colorSchemeData.textInverse,
      ),
      inversePlayfairBold14: AppTypography.h4.copyWith(
        fontSize: 14,
        fontWeight: FontWeight.w700,
        color: colorSchemeData.textInverse,
      ),
      inversePlayfairBold16: AppTypography.h4.copyWith(
        fontWeight: FontWeight.w700,
        color: colorSchemeData.textInverse,
      ),
      inversePlayfairBold17: AppTypography.navTitle.copyWith(
        fontWeight: FontWeight.w700,
        color: colorSchemeData.textInverse,
      ),
      inversePlayfairBold18: AppTypography.h3.copyWith(
        fontSize: 18,
        fontWeight: FontWeight.w700,
        color: colorSchemeData.textInverse,
      ),
      inversePlayfairBold20: AppTypography.h3.copyWith(
        fontWeight: FontWeight.w700,
        color: colorSchemeData.textInverse,
      ),
      inversePlayfairBold24: AppTypography.h2.copyWith(
        fontWeight: FontWeight.w700,
        color: colorSchemeData.textInverse,
      ),
      inversePlayfairBold32: AppTypography.h1.copyWith(
        fontWeight: FontWeight.w700,
        color: colorSchemeData.textInverse,
      ),
      inverseUrbanistRegular12: AppTypography.subtext.copyWith(
        color: colorSchemeData.textInverse,
      ),
      inverseUrbanistRegular14: AppTypography.body14.copyWith(
        color: colorSchemeData.textInverse,
      ),
      inverseUrbanistRegular16: AppTypography.text1.copyWith(
        color: colorSchemeData.textInverse,
      ),
      inverseUrbanistRegular17: AppTypography.placeholder.copyWith(
        color: colorSchemeData.textInverse,
      ),
      inverseUrbanistRegular18: AppTypography.text1.copyWith(
        fontSize: 18,
        color: colorSchemeData.textInverse,
      ),
      inverseUrbanistRegular20: AppTypography.text1.copyWith(
        fontSize: 20,
        color: colorSchemeData.textInverse,
      ),
      inverseUrbanistRegular24: AppTypography.text1.copyWith(
        fontSize: 24,
        color: colorSchemeData.textInverse,
      ),
      inverseUrbanistRegular32: AppTypography.text1.copyWith(
        fontSize: 32,
        color: colorSchemeData.textInverse,
      ),
      inverseUrbanistMedium12: AppTypography.subtext.copyWith(
        fontWeight: FontWeight.w500,
        color: colorSchemeData.textInverse,
      ),
      inverseUrbanistMedium14: AppTypography.label14.copyWith(
        color: colorSchemeData.textInverse,
      ),
      inverseUrbanistMedium16: AppTypography.text1.copyWith(
        fontWeight: FontWeight.w500,
        color: colorSchemeData.textInverse,
      ),
      inverseUrbanistMedium17: AppTypography.placeholder.copyWith(
        fontWeight: FontWeight.w500,
        color: colorSchemeData.textInverse,
      ),
      inverseUrbanistMedium18: AppTypography.text1.copyWith(
        fontSize: 18,
        fontWeight: FontWeight.w500,
        color: colorSchemeData.textInverse,
      ),
      inverseUrbanistMedium20: AppTypography.text1.copyWith(
        fontSize: 20,
        fontWeight: FontWeight.w500,
        color: colorSchemeData.textInverse,
      ),
      inverseUrbanistMedium24: AppTypography.text1.copyWith(
        fontSize: 24,
        fontWeight: FontWeight.w500,
        color: colorSchemeData.textInverse,
      ),
      inverseUrbanistMedium32: AppTypography.text1.copyWith(
        fontSize: 32,
        fontWeight: FontWeight.w500,
        color: colorSchemeData.textInverse,
      ),
      inverseUrbanistSemiBold12: AppTypography.subtextSemiBold.copyWith(
        color: colorSchemeData.textInverse,
      ),
      inverseUrbanistSemiBold14: AppTypography.body14.copyWith(
        fontWeight: FontWeight.w600,
        color: colorSchemeData.textInverse,
      ),
      inverseUrbanistSemiBold16: AppTypography.text1SemiBold.copyWith(
        color: colorSchemeData.textInverse,
      ),
      inverseUrbanistSemiBold17: AppTypography.placeholderSemiBold.copyWith(
        color: colorSchemeData.textInverse,
      ),
      inverseUrbanistSemiBold18: AppTypography.text1SemiBold.copyWith(
        fontSize: 18,
        color: colorSchemeData.textInverse,
      ),
      inverseUrbanistSemiBold20: AppTypography.text1SemiBold.copyWith(
        fontSize: 20,
        color: colorSchemeData.textInverse,
      ),
      inverseUrbanistSemiBold24: AppTypography.text1SemiBold.copyWith(
        fontSize: 24,
        color: colorSchemeData.textInverse,
      ),
      inverseUrbanistSemiBold32: AppTypography.text1SemiBold.copyWith(
        fontSize: 32,
        color: colorSchemeData.textInverse,
      ),
      inverseUrbanistBold12: AppTypography.subtext.copyWith(
        fontWeight: FontWeight.w700,
        color: colorSchemeData.textInverse,
      ),
      inverseUrbanistBold14: AppTypography.body14.copyWith(
        fontWeight: FontWeight.w700,
        color: colorSchemeData.textInverse,
      ),
      inverseUrbanistBold16: AppTypography.text1.copyWith(
        fontWeight: FontWeight.w700,
        color: colorSchemeData.textInverse,
      ),
      inverseUrbanistBold17: AppTypography.placeholder.copyWith(
        fontWeight: FontWeight.w700,
        color: colorSchemeData.textInverse,
      ),
      inverseUrbanistBold18: AppTypography.text1.copyWith(
        fontSize: 18,
        fontWeight: FontWeight.w700,
        color: colorSchemeData.textInverse,
      ),
      inverseUrbanistBold20: AppTypography.text1.copyWith(
        fontSize: 20,
        fontWeight: FontWeight.w700,
        color: colorSchemeData.textInverse,
      ),
      inverseUrbanistBold24: AppTypography.text1.copyWith(
        fontSize: 24,
        fontWeight: FontWeight.w700,
        color: colorSchemeData.textInverse,
      ),
      inverseUrbanistBold32: AppTypography.text1.copyWith(
        fontSize: 32,
        fontWeight: FontWeight.w700,
        color: colorSchemeData.textInverse,
      ),
      tertiaryPlayfairRegular12: AppTypography.h4.copyWith(
        fontSize: 12,
        fontWeight: FontWeight.w400,
        color: colorSchemeData.textTertiary,
      ),
      tertiaryPlayfairRegular14: AppTypography.h4.copyWith(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        color: colorSchemeData.textTertiary,
      ),
      tertiaryPlayfairRegular16: AppTypography.h4.copyWith(
        fontWeight: FontWeight.w400,
        color: colorSchemeData.textTertiary,
      ),
      tertiaryPlayfairRegular17: AppTypography.navTitle.copyWith(
        fontWeight: FontWeight.w400,
        color: colorSchemeData.textTertiary,
      ),
      tertiaryPlayfairRegular18: AppTypography.h3.copyWith(
        fontSize: 18,
        fontWeight: FontWeight.w400,
        color: colorSchemeData.textTertiary,
      ),
      tertiaryPlayfairRegular20: AppTypography.h3.copyWith(
        fontWeight: FontWeight.w400,
        color: colorSchemeData.textTertiary,
      ),
      tertiaryPlayfairRegular24: AppTypography.h2.copyWith(
        fontWeight: FontWeight.w400,
        color: colorSchemeData.textTertiary,
      ),
      tertiaryPlayfairRegular32: AppTypography.h1.copyWith(
        fontWeight: FontWeight.w400,
        color: colorSchemeData.textTertiary,
      ),
      tertiaryPlayfairMedium12: AppTypography.h4.copyWith(
        fontSize: 12,
        color: colorSchemeData.textTertiary,
      ),
      tertiaryPlayfairMedium14: AppTypography.h4.copyWith(
        fontSize: 14,
        color: colorSchemeData.textTertiary,
      ),
      tertiaryPlayfairMedium16: AppTypography.h4.copyWith(
        color: colorSchemeData.textTertiary,
      ),
      tertiaryPlayfairMedium17: AppTypography.navTitle.copyWith(
        fontWeight: FontWeight.w500,
        color: colorSchemeData.textTertiary,
      ),
      tertiaryPlayfairMedium18: AppTypography.h3.copyWith(
        fontSize: 18,
        color: colorSchemeData.textTertiary,
      ),
      tertiaryPlayfairMedium20: AppTypography.h3.copyWith(
        color: colorSchemeData.textTertiary,
      ),
      tertiaryPlayfairMedium24: AppTypography.h2.copyWith(
        fontWeight: FontWeight.w500,
        color: colorSchemeData.textTertiary,
      ),
      tertiaryPlayfairMedium32: AppTypography.h1.copyWith(
        fontWeight: FontWeight.w500,
        color: colorSchemeData.textTertiary,
      ),
      tertiaryPlayfairSemiBold12: AppTypography.h4.copyWith(
        fontSize: 12,
        fontWeight: FontWeight.w600,
        color: colorSchemeData.textTertiary,
      ),
      tertiaryPlayfairSemiBold14: AppTypography.h4.copyWith(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: colorSchemeData.textTertiary,
      ),
      tertiaryPlayfairSemiBold16: AppTypography.h4.copyWith(
        fontWeight: FontWeight.w600,
        color: colorSchemeData.textTertiary,
      ),
      tertiaryPlayfairSemiBold17: AppTypography.navTitle.copyWith(
        color: colorSchemeData.textTertiary,
      ),
      tertiaryPlayfairSemiBold18: AppTypography.h3.copyWith(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: colorSchemeData.textTertiary,
      ),
      tertiaryPlayfairSemiBold20: AppTypography.h3.copyWith(
        fontWeight: FontWeight.w600,
        color: colorSchemeData.textTertiary,
      ),
      tertiaryPlayfairSemiBold24: AppTypography.h2.copyWith(
        color: colorSchemeData.textTertiary,
      ),
      tertiaryPlayfairSemiBold32: AppTypography.h1.copyWith(
        color: colorSchemeData.textTertiary,
      ),
      tertiaryPlayfairBold12: AppTypography.h4.copyWith(
        fontSize: 12,
        fontWeight: FontWeight.w700,
        color: colorSchemeData.textTertiary,
      ),
      tertiaryPlayfairBold14: AppTypography.h4.copyWith(
        fontSize: 14,
        fontWeight: FontWeight.w700,
        color: colorSchemeData.textTertiary,
      ),
      tertiaryPlayfairBold16: AppTypography.h4.copyWith(
        fontWeight: FontWeight.w700,
        color: colorSchemeData.textTertiary,
      ),
      tertiaryPlayfairBold17: AppTypography.navTitle.copyWith(
        fontWeight: FontWeight.w700,
        color: colorSchemeData.textTertiary,
      ),
      tertiaryPlayfairBold18: AppTypography.h3.copyWith(
        fontSize: 18,
        fontWeight: FontWeight.w700,
        color: colorSchemeData.textTertiary,
      ),
      tertiaryPlayfairBold20: AppTypography.h3.copyWith(
        fontWeight: FontWeight.w700,
        color: colorSchemeData.textTertiary,
      ),
      tertiaryPlayfairBold24: AppTypography.h2.copyWith(
        fontWeight: FontWeight.w700,
        color: colorSchemeData.textTertiary,
      ),
      tertiaryPlayfairBold32: AppTypography.h1.copyWith(
        fontWeight: FontWeight.w700,
        color: colorSchemeData.textTertiary,
      ),
      tertiaryUrbanistRegular12: AppTypography.subtext.copyWith(
        color: colorSchemeData.textTertiary,
      ),
      tertiaryUrbanistRegular14: AppTypography.body14.copyWith(
        color: colorSchemeData.textTertiary,
      ),
      tertiaryUrbanistRegular16: AppTypography.text1.copyWith(
        color: colorSchemeData.textTertiary,
      ),
      tertiaryUrbanistRegular17: AppTypography.placeholder.copyWith(
        color: colorSchemeData.textTertiary,
      ),
      tertiaryUrbanistRegular18: AppTypography.text1.copyWith(
        fontSize: 18,
        color: colorSchemeData.textTertiary,
      ),
      tertiaryUrbanistRegular20: AppTypography.text1.copyWith(
        fontSize: 20,
        color: colorSchemeData.textTertiary,
      ),
      tertiaryUrbanistRegular24: AppTypography.text1.copyWith(
        fontSize: 24,
        color: colorSchemeData.textTertiary,
      ),
      tertiaryUrbanistRegular32: AppTypography.text1.copyWith(
        fontSize: 32,
        color: colorSchemeData.textTertiary,
      ),
      tertiaryUrbanistMedium12: AppTypography.subtext.copyWith(
        fontWeight: FontWeight.w500,
        color: colorSchemeData.textTertiary,
      ),
      tertiaryUrbanistMedium14: AppTypography.label14.copyWith(
        color: colorSchemeData.textTertiary,
      ),
      tertiaryUrbanistMedium16: AppTypography.text1.copyWith(
        fontWeight: FontWeight.w500,
        color: colorSchemeData.textTertiary,
      ),
      tertiaryUrbanistMedium17: AppTypography.placeholder.copyWith(
        fontWeight: FontWeight.w500,
        color: colorSchemeData.textTertiary,
      ),
      tertiaryUrbanistMedium18: AppTypography.text1.copyWith(
        fontSize: 18,
        fontWeight: FontWeight.w500,
        color: colorSchemeData.textTertiary,
      ),
      tertiaryUrbanistMedium20: AppTypography.text1.copyWith(
        fontSize: 20,
        fontWeight: FontWeight.w500,
        color: colorSchemeData.textTertiary,
      ),
      tertiaryUrbanistMedium24: AppTypography.text1.copyWith(
        fontSize: 24,
        fontWeight: FontWeight.w500,
        color: colorSchemeData.textTertiary,
      ),
      tertiaryUrbanistMedium32: AppTypography.text1.copyWith(
        fontSize: 32,
        fontWeight: FontWeight.w500,
        color: colorSchemeData.textTertiary,
      ),
      tertiaryUrbanistSemiBold12: AppTypography.subtextSemiBold.copyWith(
        color: colorSchemeData.textTertiary,
      ),
      tertiaryUrbanistSemiBold14: AppTypography.body14.copyWith(
        fontWeight: FontWeight.w600,
        color: colorSchemeData.textTertiary,
      ),
      tertiaryUrbanistSemiBold16: AppTypography.text1SemiBold.copyWith(
        color: colorSchemeData.textTertiary,
      ),
      tertiaryUrbanistSemiBold17: AppTypography.placeholderSemiBold.copyWith(
        color: colorSchemeData.textTertiary,
      ),
      tertiaryUrbanistSemiBold18: AppTypography.text1SemiBold.copyWith(
        fontSize: 18,
        color: colorSchemeData.textTertiary,
      ),
      tertiaryUrbanistSemiBold20: AppTypography.text1SemiBold.copyWith(
        fontSize: 20,
        color: colorSchemeData.textTertiary,
      ),
      tertiaryUrbanistSemiBold24: AppTypography.text1SemiBold.copyWith(
        fontSize: 24,
        color: colorSchemeData.textTertiary,
      ),
      tertiaryUrbanistSemiBold32: AppTypography.text1SemiBold.copyWith(
        fontSize: 32,
        color: colorSchemeData.textTertiary,
      ),
      tertiaryUrbanistBold12: AppTypography.subtext.copyWith(
        fontWeight: FontWeight.w700,
        color: colorSchemeData.textTertiary,
      ),
      tertiaryUrbanistBold14: AppTypography.body14.copyWith(
        fontWeight: FontWeight.w700,
        color: colorSchemeData.textTertiary,
      ),
      tertiaryUrbanistBold16: AppTypography.text1.copyWith(
        fontWeight: FontWeight.w700,
        color: colorSchemeData.textTertiary,
      ),
      tertiaryUrbanistBold17: AppTypography.placeholder.copyWith(
        fontWeight: FontWeight.w700,
        color: colorSchemeData.textTertiary,
      ),
      tertiaryUrbanistBold18: AppTypography.text1.copyWith(
        fontSize: 18,
        fontWeight: FontWeight.w700,
        color: colorSchemeData.textTertiary,
      ),
      tertiaryUrbanistBold20: AppTypography.text1.copyWith(
        fontSize: 20,
        fontWeight: FontWeight.w700,
        color: colorSchemeData.textTertiary,
      ),
      tertiaryUrbanistBold24: AppTypography.text1.copyWith(
        fontSize: 24,
        fontWeight: FontWeight.w700,
        color: colorSchemeData.textTertiary,
      ),
      tertiaryUrbanistBold32: AppTypography.text1.copyWith(
        fontSize: 32,
        fontWeight: FontWeight.w700,
        color: colorSchemeData.textTertiary,
      ),
    );
  }

  /// Предоставляет базовые данные темы
  ThemeData getBaseThemeData(BuildContext context);

  /// Предоставляет полные данные темы
  ThemeData getThemeData(BuildContext context) {
    final colorSchemeData = getColorsThemeData(context);
    final cornersThemeData = getCornersThemeData(context);
    final spacingThemeData = getSpacingThemeData(context);
    final textThemeData = getTextTheme(
      context,
      colorSchemeData: colorSchemeData,
    );

    final base = getBaseThemeData(context);
    final cupertino = CupertinoTextThemeData(
      primaryColor: colorSchemeData.primary,
    );

    return base.copyWith(
      textTheme: base.textTheme.merge(AppTypography.material),
      primaryTextTheme: base.primaryTextTheme.merge(AppTypography.material),
      cupertinoOverrideTheme: NoDefaultCupertinoThemeData(
        textTheme: cupertino.copyWith(
          textStyle: cupertino.textStyle.merge(AppTypography.text1),
          actionTextStyle: cupertino.actionTextStyle.merge(
            AppTypography.text1SemiBold,
          ),
          actionSmallTextStyle: cupertino.actionSmallTextStyle.merge(
            AppTypography.text2,
          ),
          navTitleTextStyle: cupertino.navTitleTextStyle.merge(
            AppTypography.navTitle,
          ),
          navLargeTitleTextStyle: cupertino.navLargeTitleTextStyle.merge(
            AppTypography.navLargeTitle,
          ),
          navActionTextStyle: cupertino.navActionTextStyle.merge(
            AppTypography.text1,
          ),
          tabLabelTextStyle: cupertino.tabLabelTextStyle.merge(
            AppTypography.tabBar,
          ),
          pickerTextStyle: cupertino.pickerTextStyle.copyWith(
            fontFamily: AppTypography.bodyFamily,
          ),
          dateTimePickerTextStyle: cupertino.dateTimePickerTextStyle.copyWith(
            fontFamily: AppTypography.bodyFamily,
          ),
        ),
      ),
      canvasColor: colorSchemeData.background,
      scaffoldBackgroundColor: colorSchemeData.background,
      extensions: [
        colorSchemeData,
        cornersThemeData,
        spacingThemeData,
        textThemeData,
      ],
      colorScheme: ColorScheme(
        brightness: Theme.of(context).brightness,
        primary: colorSchemeData.primary,
        secondary: colorSchemeData.secondary,
        surface: colorSchemeData.surface,
        onPrimary: colorSchemeData.buttonText,
        onSecondary: colorSchemeData.textPrimary,
        onSurface: colorSchemeData.textPrimary,
        error: colorSchemeData.error,
        onError: colorSchemeData.buttonText,
      ),
      inputDecorationTheme: InputDecorationTheme(
        hintStyle: textThemeData.inputHint,
        contentPadding: EdgeInsets.symmetric(
          horizontal: spacingThemeData.medium,
          vertical: spacingThemeData.medium,
        ),
        hintFadeDuration: Duration.zero,
        isDense: true,
        filled: true,
        border: OutlineInputBorder(
          borderRadius: cornersThemeData.small,
          borderSide: BorderSide(
            color: colorSchemeData.textFieldBorderUnselected,
            width: 1,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: cornersThemeData.small,
          borderSide: BorderSide(
            color: colorSchemeData.textFieldBorderUnselected,
            width: 1,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: cornersThemeData.small,
          borderSide: BorderSide(
            color: colorSchemeData.textFieldBorderSelected,
            width: 1,
          ),
        ),
        fillColor: colorSchemeData.textFieldBackground,
        prefixIconColor: colorSchemeData.textSecondary,
        // errorStyle: textThemeData.bodySmall.copyWith(color: colorSchemeData.error),
        errorMaxLines: 3,
        suffixIconColor: colorSchemeData.textSecondary,
      ),
      textSelectionTheme: TextSelectionThemeData(
        cursorColor: colorSchemeData.primary,
        selectionHandleColor: colorSchemeData.primary,
      ),
      appBarTheme: AppBarTheme(
        systemOverlayStyle: SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.light,
          statusBarBrightness: Brightness.dark,
          systemNavigationBarColor: Colors.transparent,
          systemNavigationBarIconBrightness: Brightness.light,
        ),
        centerTitle: false,
        backgroundColor: colorSchemeData.surface,
        iconTheme: IconThemeData(color: colorSchemeData.textPrimary),
        actionsIconTheme: IconThemeData(color: colorSchemeData.textPrimary),
        titleTextStyle: textThemeData.appBarTitle,
        elevation: 0,
        titleSpacing: 0,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ButtonStyle(
          visualDensity: VisualDensity.compact,
          shape: WidgetStatePropertyAll(
            RoundedRectangleBorder(borderRadius: cornersThemeData.large),
          ),
          padding: WidgetStatePropertyAll(
            EdgeInsets.symmetric(
              horizontal: spacingThemeData.medium,
              vertical: spacingThemeData.medium,
            ),
          ),
          backgroundColor: WidgetStateProperty.resolveWith<Color?>((
            Set<WidgetState> states,
          ) {
            if (states.contains(WidgetState.disabled)) {
              return colorSchemeData.buttonBackgroundDisabled;
            }
            return colorSchemeData.buttonBackground;
          }),
          overlayColor: WidgetStateProperty.resolveWith<Color?>((
            Set<WidgetState> states,
          ) {
            if (states.contains(WidgetState.pressed)) {
              return colorSchemeData.buttonBackgroundPressed;
            }
            return Colors.transparent;
          }),
          foregroundColor: WidgetStatePropertyAll(colorSchemeData.buttonText),
          textStyle: WidgetStatePropertyAll(textThemeData.button),
          iconSize: const WidgetStatePropertyAll(20),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: ButtonStyle(
          visualDensity: VisualDensity.compact,
          shape: WidgetStatePropertyAll(
            RoundedRectangleBorder(borderRadius: cornersThemeData.large),
          ),
          side: WidgetStatePropertyAll(
            BorderSide(color: colorSchemeData.containerBorder),
          ),
          padding: WidgetStatePropertyAll(
            EdgeInsets.symmetric(
              horizontal: spacingThemeData.medium,
              vertical: spacingThemeData.medium,
            ),
          ),
          overlayColor: WidgetStateProperty.resolveWith<Color?>((
            Set<WidgetState> states,
          ) {
            if (states.contains(WidgetState.pressed)) {
              return colorSchemeData.outlinedButtonText.withValues(alpha: 0.1);
            }
            return Colors.transparent;
          }),
          foregroundColor: WidgetStatePropertyAll(
            colorSchemeData.outlinedButtonText,
          ),
          textStyle: WidgetStatePropertyAll(textThemeData.button),
          iconSize: const WidgetStatePropertyAll(20),
        ),
      ),
      cardTheme: CardThemeData(
        color: colorSchemeData.cardBackground,
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: cornersThemeData.medium),
        margin: EdgeInsets.all(spacingThemeData.small),
      ),
      iconButtonTheme: IconButtonThemeData(
        style: ButtonStyle(
          iconColor: WidgetStatePropertyAll(colorSchemeData.textPrimary),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: ButtonStyle(
          visualDensity: VisualDensity.compact,
          shape: WidgetStatePropertyAll(
            RoundedRectangleBorder(borderRadius: cornersThemeData.large),
          ),
          padding: WidgetStatePropertyAll(
            EdgeInsets.symmetric(
              horizontal: spacingThemeData.medium,
              vertical: spacingThemeData.medium,
            ),
          ),
          overlayColor: WidgetStateProperty.resolveWith<Color?>((
            Set<WidgetState> states,
          ) {
            if (states.contains(WidgetState.pressed)) {
              return colorSchemeData.primary.withValues(alpha: 0.1);
            }
            return Colors.transparent;
          }),
          foregroundColor: WidgetStatePropertyAll(colorSchemeData.primary),
          textStyle: WidgetStatePropertyAll(textThemeData.button),
          iconSize: const WidgetStatePropertyAll(20),
        ),
      ),
      dividerTheme: DividerThemeData(
        color: colorSchemeData.divider,
        thickness: 1,
        space: spacingThemeData.medium,
      ),
      tooltipTheme: TooltipThemeData(
        decoration: CardLensDecoration(
          borderRadius: BorderRadius.circular(16),
          color: colorSchemeData.surface.withValues(alpha: .94),
          intensity: .54,
        ),
        textStyle: textThemeData.urbanistRegular14.copyWith(
          color: colorSchemeData.textPrimary,
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: colorSchemeData.surface.withValues(alpha: .94),
        contentTextStyle: textThemeData.urbanistRegular16.copyWith(
          color: colorSchemeData.textPrimary,
        ),
        shape: const ModalLensBorder(),
      ),
    );
  }
}
