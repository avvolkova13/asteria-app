import 'dart:ui';
import 'package:flutter/material.dart';

final class SpacingThemeData extends ThemeExtension<SpacingThemeData> {
  const SpacingThemeData({
    required this.extraSmall,
    required this.small,
    required this.medium,
    required this.mediumLarge,
    required this.large,
    required this.extraLarge,
  });

  final double extraSmall;
  final double small;
  final double medium;
  final double mediumLarge;
  final double large;
  final double extraLarge;

  @override
  ThemeExtension<SpacingThemeData> copyWith() {
    return SpacingThemeData(
      extraSmall: extraSmall,
      small: small,
      medium: medium,
      mediumLarge: mediumLarge,
      large: large,
      extraLarge: extraLarge,
    );
  }

  @override
  ThemeExtension<SpacingThemeData> lerp(
    covariant ThemeExtension<SpacingThemeData>? other,
    double t,
  ) {
    if (other is! SpacingThemeData) {
      return this;
    }

    return SpacingThemeData(
      extraSmall: lerpDouble(extraSmall, other.extraSmall, t)!,
      small: lerpDouble(small, other.small, t)!,
      medium: lerpDouble(medium, other.medium, t)!,
      mediumLarge: lerpDouble(mediumLarge, other.mediumLarge, t)!,
      large: lerpDouble(large, other.large, t)!,
      extraLarge: lerpDouble(extraLarge, other.extraLarge, t)!,
    );
  }
}
