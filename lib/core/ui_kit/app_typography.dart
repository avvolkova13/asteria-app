import 'package:flutter/material.dart';

/// Text styles from Asteria’s Figma Fonts frame (848:26802) and local library.
/// Colors come from the surface or component that renders the text.
abstract final class AppTypography {
  static const headingFamily = 'Lora';
  static const bodyFamily = 'Onest';
  static const _caseForms = [FontFeature.caseSensitiveForms()];

  static const h1 = TextStyle(
    fontFamily: headingFamily,
    fontSize: 32,
    fontWeight: FontWeight.w600,
    height: 1.2,
    letterSpacing: 0,
  );
  static const h2 = TextStyle(
    fontFamily: headingFamily,
    fontSize: 24,
    fontWeight: FontWeight.w600,
    height: 1,
    letterSpacing: 0,
  );
  static const h3 = TextStyle(
    fontFamily: headingFamily,
    fontSize: 20,
    fontWeight: FontWeight.w500,
    height: 1.1,
    letterSpacing: 0,
  );
  static const h4 = TextStyle(
    fontFamily: headingFamily,
    fontSize: 16,
    fontWeight: FontWeight.w500,
    height: 1.1,
    letterSpacing: 0,
  );
  static const text1 = TextStyle(
    fontFamily: bodyFamily,
    fontSize: 16,
    fontWeight: FontWeight.w400,
    height: 1.2,
    letterSpacing: -0.408,
    fontFeatures: _caseForms,
  );
  static const text1SemiBold = TextStyle(
    fontFamily: bodyFamily,
    fontSize: 16,
    fontWeight: FontWeight.w600,
    height: 1.2,
    letterSpacing: -0.408,
    fontFeatures: _caseForms,
  );
  static const text2 = TextStyle(
    fontFamily: bodyFamily,
    fontSize: 13,
    fontWeight: FontWeight.w400,
    height: 1.2,
    letterSpacing: -0.08,
  );
  static const text2SemiBold = TextStyle(
    fontFamily: bodyFamily,
    fontSize: 13,
    fontWeight: FontWeight.w600,
    height: 1.2,
    letterSpacing: -0.08,
  );
  static const placeholder = TextStyle(
    fontFamily: bodyFamily,
    fontSize: 17,
    fontWeight: FontWeight.w400,
    height: 1.2,
    letterSpacing: -0.408,
    fontFeatures: _caseForms,
  );
  static const placeholderSemiBold = TextStyle(
    fontFamily: bodyFamily,
    fontSize: 17,
    fontWeight: FontWeight.w600,
    height: 1.2,
    letterSpacing: -0.408,
    fontFeatures: _caseForms,
  );
  static const navTitle = TextStyle(
    fontFamily: headingFamily,
    fontSize: 17,
    fontWeight: FontWeight.w600,
    height: 1.2,
    letterSpacing: -0.408,
    fontFeatures: _caseForms,
  );
  static const navLargeTitle = TextStyle(
    fontFamily: headingFamily,
    fontSize: 34,
    fontWeight: FontWeight.w700,
    height: 1.2,
    letterSpacing: 0.374,
  );
  static const link = TextStyle(
    fontFamily: bodyFamily,
    fontSize: 16,
    fontWeight: FontWeight.w600,
    height: 1.2,
    letterSpacing: -0.408,
    fontFeatures: _caseForms,
    decoration: TextDecoration.underline,
  );
  static const caption = TextStyle(
    fontFamily: headingFamily,
    fontSize: 48,
    fontWeight: FontWeight.w600,
    height: 0.95,
    letterSpacing: 0,
  );
  static const subtext = TextStyle(
    fontFamily: bodyFamily,
    fontSize: 12,
    fontWeight: FontWeight.w400,
    height: 1.2,
    letterSpacing: -0.408,
    fontFeatures: _caseForms,
  );
  static const subtextSemiBold = TextStyle(
    fontFamily: bodyFamily,
    fontSize: 12,
    fontWeight: FontWeight.w600,
    height: 1.2,
    letterSpacing: -0.408,
    fontFeatures: _caseForms,
  );
  static const label14 = TextStyle(
    fontFamily: bodyFamily,
    fontSize: 14,
    fontWeight: FontWeight.w500,
    height: 0.9,
    letterSpacing: -0.41,
  );
  static const body14 = TextStyle(
    fontFamily: bodyFamily,
    fontSize: 14,
    fontWeight: FontWeight.w400,
    height: 1.2,
    letterSpacing: -0.08,
  );
  static const tabBar = TextStyle(
    fontFamily: bodyFamily,
    fontSize: 10,
    fontWeight: FontWeight.w400,
    height: 1.2,
    letterSpacing: -0.1,
  );
  static const tabBarSemiBold = TextStyle(
    fontFamily: bodyFamily,
    fontSize: 10,
    fontWeight: FontWeight.w600,
    height: 1.2,
    letterSpacing: -0.1,
  );

  static const material = TextTheme(
    displayLarge: caption,
    displayMedium: navLargeTitle,
    displaySmall: h1,
    headlineLarge: h1,
    headlineMedium: h2,
    headlineSmall: h3,
    titleLarge: h3,
    titleMedium: h4,
    titleSmall: h4,
    bodyLarge: text1,
    bodyMedium: body14,
    bodySmall: subtext,
    labelLarge: text1SemiBold,
    labelMedium: text2SemiBold,
    labelSmall: tabBar,
  );
}
