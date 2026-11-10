import 'dart:ui' as ui;

import 'package:flutter/material.dart';

abstract final class BalanceHistoryStyle {
  static const background = Color(0xFF0F0A1A);
  static const card = Color(0x339A7DB8);
  static const modal = Color(0xFF110628);
  static const selected = Color(0xFF151028);
  static const border = Color(0xFF31296D);
  static const muted = Color(0xFFB5AAB8);
  static const credit = Color(0xFF72B7A0);
  static const debit = Color(0xFFE36A6A);
  static const accent = LinearGradient(
    colors: [Color(0xFFE6994D), Color(0xFFF3B76A), Color(0xFFE6994D)],
  );
  static const body = TextStyle(
    fontFamily: 'Onest',
    fontWeight: FontWeight.w400,
    fontSize: 16,
    height: 1.2,
    letterSpacing: -0.408,
    color: Colors.white,
  );
  static const title = TextStyle(
    fontFamily: 'Lora',
    fontWeight: FontWeight.w600,
    fontVariations: [ui.FontVariation('wght', 600)],
    fontSize: 17,
    height: 1.2,
    letterSpacing: -0.408,
    color: Colors.white,
  );
  static const emptyTitle = TextStyle(
    fontFamily: 'Lora',
    fontWeight: FontWeight.w600,
    fontVariations: [ui.FontVariation('wght', 600)],
    fontSize: 24,
    height: 1,
    letterSpacing: 0,
    color: Colors.white,
  );

  // Figma 4825:51019/51031: keep image, fades and glass sampling aligned.
  static void paintBackground(Canvas canvas, Size size, ui.Image image) {
    canvas.drawColor(background, BlendMode.src);
    canvas.save();
    canvas.scale(size.width / 390, size.height / 844);
    canvas.drawImageRect(
      image,
      Rect.fromLTWH(0, 0, image.width.toDouble(), image.height.toDouble()),
      const Rect.fromLTWH(0, -22, 390, 780),
      Paint()
        ..color = Colors.white.withValues(alpha: 0.25)
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
