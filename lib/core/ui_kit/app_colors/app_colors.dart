import 'package:flutter/material.dart';

class AppColors {
  static const Color primary = Color(0xFF8A6CAF);
  static const Color secondary = Color(0xFFD75087);
  static const Color accent = Color(0xFF00D4FF);

  static const Color background = Color(0xFFEEEAFD);
  static const Color surface = Color(0xFFEEEAFD);
  static const Color cardBackground = Color(0xFFFFFFFF);
  static const Color cardTinted = Color(0xFFE4E0F3);
  static const Color modal = Color(0xFFF1ECFE);

  static const Color textPrimary = Color(0xFF140C15);
  static const Color textSecondary = Color(0xFF9E95A2);
  static const Color textTertiary = Color(0xFFA89CAA);
  static const Color textInputActive = Color(0xFF140C15);
  static const Color textInputDefault = Color(0xFF9E95A2);
  static const Color textInverse = Color(0xFFFFFFFF);

  static const Color uiPrimary = Color(0xFF140C15);
  static const Color uiSecondary = Color(0xFFE9E9EA);
  static const Color uiInverse = Color(0xFFFFFFFF);
  static const Color uiDisabled = Color(0xFFD7CADF);
  static const Color uiPressed = Color(0xFF775A9D);
  static const Color uiDisabledText = Color(0xFFA89CAA);

  static const Color white = Color(0xFFFFFFFF);

  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF8A6CAF), Color(0xFFD75087)],
  );

  static const LinearGradient backgroundGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFFEEEAFD), Color(0xFFF1ECFE)],
  );

  static const Color success = Color(0xFF5FA88F);
  static const Color warning = Color(0xFFE2A542);
  static const Color error = Color(0xFFDB4C4C);
  static const Color info = Color(0xFF7D9FE6);

  static const Color overlay = Color(0x80000000);
  static const Color divider = Color(0x40140C15);

  static const Color deepPurple = Color(0xFF1D1347);
}

class AppColorsDark {
  static const Color primary = Color(0xFF6C63FF);
  static const Color secondary = Color(0xFF2C2C2C);
  static const Color accent = Color(0xFF00D4FF);

  static const Color background = Color(0xFF1A1A1A);
  static const Color surface = Color(0xFF2A2A2A);
  static const Color cardBackground = Color(0xFF2A2A2A);

  static const Color textPrimary = Color(0xFFFFFFFF);
  static const Color textSecondary = Color(0xFFB0B0B0);
  static const Color textTertiary = Color(0xFF808080);

  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF6C63FF), Color(0xFF00D4FF)],
  );

  static const LinearGradient backgroundGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFF1A1A1A), Color(0xFF2A2A2A)],
  );

  static const Color overlay = Color(0x80000000);
  static const Color divider = Color(0x40FFFFFF);
}
