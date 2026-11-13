import 'dart:math' as math;
import 'package:flutter/material.dart';

/// The navigation lens expressed as a stationary surface. The original fill,
/// art, shadows and selection border remain underneath the optical finish.
class CardLensDecoration extends BoxDecoration {
  const CardLensDecoration({
    required BorderRadiusGeometry borderRadius,
    this.intensity = 1,
    super.color,
    super.image,
    super.gradient,
    super.border,
    super.boxShadow,
  }) : super(borderRadius: borderRadius);

  /// A lower, softer lip on controls, with subdued relief when unavailable.
  const CardLensDecoration.button({
    required BorderRadiusGeometry borderRadius,
    bool enabled = true,
    super.color,
    super.gradient,
    super.border,
    super.boxShadow,
  }) : intensity = enabled ? .92 : .18,
       super(borderRadius: borderRadius);

  /// Curved lighting follows the existing fill so gold and purple controls
  /// keep their semantic colour while sharing the same soft volume.
  static LinearGradient buttonFill(Color color) => LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color.alphaBlend(Colors.white.withValues(alpha: .24), color),
      Color.alphaBlend(Colors.white.withValues(alpha: .08), color),
      color,
      Color.alphaBlend(Colors.black.withValues(alpha: .12), color),
      Color.alphaBlend(Colors.white.withValues(alpha: .12), color),
    ],
    stops: const [0, .20, .48, .78, 1],
  );

  final double intensity;

  @override
  bool operator ==(Object other) =>
      other is CardLensDecoration &&
      intensity == other.intensity &&
      super == other;

  @override
  int get hashCode => Object.hash(super.hashCode, intensity);

  @override
  BoxPainter createBoxPainter([VoidCallback? onChanged]) => _LensBoxPainter(
    super.createBoxPainter(onChanged),
    borderRadius!,
    image == null &&
        gradient == null &&
        (color?.a ?? 0) > .8 &&
        (color?.computeLuminance() ?? 0) > .65,
    intensity,
    onChanged,
  );

  // Keep the optics continuous when an AnimatedContainer interpolates its fill.
  @override
  BoxDecoration? lerpFrom(Decoration? a, double t) {
    if (a is! CardLensDecoration) return super.lerpFrom(a, t);
    return _from(
      BoxDecoration.lerp(a, this, t)!,
      a.intensity + (intensity - a.intensity) * t,
    );
  }

  @override
  BoxDecoration? lerpTo(Decoration? b, double t) {
    if (b is! CardLensDecoration) return super.lerpTo(b, t);
    return _from(
      BoxDecoration.lerp(this, b, t)!,
      intensity + (b.intensity - intensity) * t,
    );
  }

  static CardLensDecoration _from(BoxDecoration box, double intensity) =>
      CardLensDecoration(
        intensity: intensity,
        borderRadius: box.borderRadius ?? BorderRadius.zero,
        color: box.color,
        image: box.image,
        gradient: box.gradient,
        border: box.border,
        boxShadow: box.boxShadow,
      );

  /// Optical highlights stay at the perimeter, away from text and faces.
  /// All bands fit inside the surface, including at narrow text widths.
  static void paintFinish(
    Canvas canvas,
    RRect outline, {
    bool paleBase = false,
    double intensity = 1,
  }) {
    if (outline.isEmpty) return;
    final shape = outline.scaleRadii();
    final bounds = shape.outerRect;
    final lip = math.min(8.5, bounds.shortestSide * .075);
    final paint = Paint()..color = Colors.white.withValues(alpha: intensity);
    // Rose and lilac are the two reflections in the selected tab's lens.
    const wash = LinearGradient(
      begin: Alignment(-.45, -1),
      end: Alignment(.55, 1),
      colors: [
        Color(0x51FFE9F4),
        Color(0x17E2B9ED),
        Color(0x00CBAAD7),
        Color(0x04D1ACD9),
        Color(0x24EAD2ED),
      ],
      stops: [0, .16, .43, .73, 1],
    );
    canvas.drawRRect(shape, paint..shader = wash.createShader(bounds));
    // The soft inner falloff and narrow outer glint share a light direction.
    // A ring with a deeper underside reads as curved glass on pale artwork too.
    const bevel = LinearGradient(
      begin: Alignment(-.7, -1),
      end: Alignment(.66, 1),
      colors: [
        Color(0xBAFFE9F4),
        Color(0x55E2B9ED),
        Color(0x21CBAAD7),
        Color(0x604A3159),
        Color(0xAAEAD2ED),
      ],
      stops: [0, .25, .46, .74, 1],
    );
    const paleBevel = LinearGradient(
      begin: Alignment(-.7, -1),
      end: Alignment(.66, 1),
      colors: [
        Color(0x75FFFFFF),
        Color(0x336B537B),
        Color(0x2271597E),
        Color(0xA26B537B),
        Color(0xA4836F91),
      ],
      stops: [0, .25, .46, .74, 1],
    );
    final bevelPaint = Paint()
      ..shader = (paleBase ? paleBevel : bevel).createShader(bounds);
    // Thin adjacent bands approximate the rounded cross-section without
    // blurring an offscreen layer for every item in a scrolling list.
    const strengths = [.60, .41, .26, .16, .09, .045, .018];
    for (var i = 0; i < strengths.length; i++) {
      final outer = shape.deflate(lip * i / strengths.length);
      final inner = shape.deflate(lip * (i + 1) / strengths.length);
      bevelPaint.color = Colors.white.withValues(
        alpha: strengths[i] * intensity,
      );
      canvas.drawDRRect(outer, inner, bevelPaint);
    }
    const glint = LinearGradient(
      begin: Alignment(-.76, -1),
      end: Alignment(.72, 1),
      colors: [
        Color(0xBFFFE9F4),
        Color(0x65E2B9ED),
        Color(0x1CCBAAD7),
        Color(0x25D1ACD9),
        Color(0x8AEAD2ED),
      ],
      stops: [0, .19, .46, .72, 1],
    );
    canvas.drawDRRect(
      shape,
      shape.deflate(math.min(.9, lip * .45)),
      paint..shader = glint.createShader(bounds),
    );
  }
}

class _LensBoxPainter extends BoxPainter {
  _LensBoxPainter(
    this.base,
    this.radius,
    this.paleBase,
    this.intensity,
    super.onChanged,
  );

  final BoxPainter base;
  final BorderRadiusGeometry radius;
  final bool paleBase;
  final double intensity;

  @override
  void paint(Canvas canvas, Offset offset, ImageConfiguration configuration) {
    base.paint(canvas, offset, configuration);
    final size = configuration.size;
    if (size == null || size.isEmpty) return;
    CardLensDecoration.paintFinish(
      canvas,
      radius.resolve(configuration.textDirection).toRRect(offset & size),
      paleBase: paleBase,
      intensity: intensity,
    );
  }

  @override
  void dispose() {
    base.dispose();
    super.dispose();
  }
}
