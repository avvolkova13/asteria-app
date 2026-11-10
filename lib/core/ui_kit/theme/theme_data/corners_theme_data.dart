import 'package:flutter/material.dart';

final class CornersThemeData extends ThemeExtension<CornersThemeData> {
  const CornersThemeData({
    required this.extraSmall,
    required this.small,
    required this.medium,
    required this.large,
    required this.extraLarge,
  });

  final BorderRadius extraSmall;
  final BorderRadius small;
  final BorderRadius medium;
  final BorderRadius large;
  final BorderRadius extraLarge;

  @override
  ThemeExtension<CornersThemeData> copyWith() {
    return CornersThemeData(
      extraSmall: extraSmall,
      small: small,
      medium: medium,
      large: large,
      extraLarge: extraLarge,
    );
  }

  @override
  ThemeExtension<CornersThemeData> lerp(
    covariant ThemeExtension<CornersThemeData>? other,
    double t,
  ) {
    if (other is! CornersThemeData) {
      return this;
    }

    return CornersThemeData(
      extraSmall: BorderRadius.lerp(extraSmall, other.extraSmall, t)!,
      small: BorderRadius.lerp(small, other.small, t)!,
      medium: BorderRadius.lerp(medium, other.medium, t)!,
      large: BorderRadius.lerp(large, other.large, t)!,
      extraLarge: BorderRadius.lerp(extraLarge, other.extraLarge, t)!,
    );
  }
}
