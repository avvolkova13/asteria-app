import 'package:asteria_app/core/ui_kit/ui_kit.dart';
import 'package:asteria_app/features/home/presentation/models/day_status.dart';
import 'package:flutter/material.dart';

class MoonDesignTokens {
  const MoonDesignTokens._();

  static const Color pageBackground = AppColorsDark.homeCanvas;
  static const Color calendarSurface = Color(0x1A9A7DB8);
  static const Color cardSurface = Color(0xFF9A7DB8);
  static const Color chipOrange = Color(0xFFE6994D);
  static const Color chipOrangeLight = Color(0xFFF3B76A);
  static const Color selectedDay = Color(0xFFF0A54E);

  static const LinearGradient orangeGradient = LinearGradient(
    colors: [chipOrange, chipOrangeLight, chipOrange],
  );

  static LinearGradient selectedDayGradient(double opacity) {
    return LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [
        chipOrange.withValues(alpha: opacity),
        chipOrangeLight.withValues(alpha: opacity),
        chipOrange.withValues(alpha: opacity),
      ],
      stops: const [0, 0.5, 1],
    );
  }

  static RadialGradient selectedDayInnerGlow(double opacity) {
    return RadialGradient(
      colors: [
        const Color(0xFFFFD8A6).withValues(alpha: 0.58 * opacity),
        chipOrangeLight.withValues(alpha: 0.28 * opacity),
        chipOrangeLight.withValues(alpha: 0),
      ],
      stops: const [0, 0.42, 1],
    );
  }

  static Color statusColor(DayStatus status) {
    return switch (status) {
      DayStatus.favorable => AppColors.success,
      DayStatus.neutral => AppColors.warning,
      DayStatus.unfavorable => AppColors.error,
    };
  }
}
