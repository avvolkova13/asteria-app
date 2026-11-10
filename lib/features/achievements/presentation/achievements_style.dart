import 'dart:ui' as ui;
import 'package:flutter/material.dart';

/// Figma 4825:50893. These tokens are local to the achievements screen.
abstract final class AchievementsStyle {
  static const background = Color(0xFF0F0A1A);
  static const card = Color(0x339A7DB8);
  static const imageBackground = Color(0x8021183D);
  static const accent = LinearGradient(
    colors: [Color(0xFFE6994D), Color(0xFFF3B76A), Color(0xFFE6994D)],
  );
  static const title = TextStyle(
    fontFamily: 'Lora',
    fontSize: 20,
    fontWeight: FontWeight.w500,
    fontVariations: [ui.FontVariation('wght', 500)],
    height: 1.1,
    letterSpacing: 0,
    color: Colors.white,
  );
  static const progress = TextStyle(
    fontFamily: 'Onest',
    fontSize: 13,
    fontWeight: FontWeight.w600,
    fontVariations: [ui.FontVariation('wght', 600)],
    height: 1.2,
    letterSpacing: -0.08,
    color: Colors.white,
  );

  static void paintBackground(Canvas canvas, Size size, ui.Image image) {
    canvas.drawColor(background, BlendMode.src);
    canvas.save();
    canvas.scale(size.width / 390, size.height / 844);
    canvas.drawImageRect(
      image,
      Rect.fromLTWH(0, 0, image.width.toDouble(), image.height.toDouble()),
      const Rect.fromLTWH(0, -22, 390, 780),
      // Both the image fill and its layer have 50% opacity in Figma.
      Paint()
        ..color = const Color(0x40FFFFFF)
        ..filterQuality = FilterQuality.medium,
    );
    const top = Rect.fromLTWH(0, 0, 390, 273);
    canvas.drawRect(
      top,
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [background, Color(0x000F0A1A)],
        ).createShader(top),
    );
    const bottom = Rect.fromLTWH(0, 734, 390, 110);
    canvas.drawRect(
      bottom,
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.bottomCenter,
          end: Alignment.topCenter,
          colors: [Color(0x00160C2B), Color(0xFF160C2B), Color(0x00160C2B)],
          stops: [0, 0.77, 1],
        ).createShader(bottom),
    );
    canvas.restore();
  }
}
