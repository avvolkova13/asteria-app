import 'dart:math' as math;

import 'package:flutter/material.dart';

/// Preserves whole heading words when enlarged text exceeds a compact measure.
class ResponsiveHeading extends StatelessWidget {
  const ResponsiveHeading(
    this.text, {
    super.key,
    required this.style,
    this.textAlign,
  });
  final String text;
  final TextStyle style;
  final TextAlign? textAlign;

  @override
  Widget build(BuildContext context) {
    final baseSize = style.fontSize ?? 24;
    final scaler = MediaQuery.textScalerOf(context);
    if (scaler.scale(baseSize) <= baseSize * 1.25) {
      return Text(text, style: style, textAlign: textAlign);
    }
    return LayoutBuilder(
      builder: (context, constraints) {
        var resolvedStyle = style;
        if (constraints.hasBoundedWidth) {
          var longestWord = 0.0;
          for (final word in text.split(RegExp(r'\s+'))) {
            final measurement = TextPainter(
              text: TextSpan(text: word, style: style),
              textDirection: Directionality.of(context),
              textScaler: scaler,
            )..layout();
            longestWord = math.max(longestWord, measurement.width);
            measurement.dispose();
          }
          if (longestWord > constraints.maxWidth) {
            resolvedStyle = style.copyWith(
              fontSize: math.max(
                18,
                baseSize * (constraints.maxWidth - 1) / longestWord,
              ),
            );
          }
        }
        return Text(text, style: resolvedStyle, textAlign: textAlign);
      },
    );
  }
}
