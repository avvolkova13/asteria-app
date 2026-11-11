import 'clay_icon.dart';
import 'package:flutter/material.dart';

/// Corner proportions from the four hand-shaped controls in the lotus player.
enum LotusPebbleContour {
  action(.49, .51, .45, .55, .56, .54, .46, .44),
  repeat(.54, .46, .50, .50, .55, .55, .45, .45),
  bookmark(.54, .46, .51, .49, .54, .58, .42, .46),
  play(.52, .48, .46, .54, .60, .57, .43, .40);

  const LotusPebbleContour(
    this.upperLeftX,
    this.upperRightX,
    this.lowerRightX,
    this.lowerLeftX,
    this.upperLeftY,
    this.upperRightY,
    this.lowerRightY,
    this.lowerLeftY,
  );
  final double upperLeftX, upperRightX, lowerRightX, lowerLeftX;
  final double upperLeftY, upperRightY, lowerRightY, lowerLeftY;

  BorderRadius resolve(double width, double height) => BorderRadius.only(
    topLeft: Radius.elliptical(width * upperLeftX, height * upperLeftY),
    topRight: Radius.elliptical(width * upperRightX, height * upperRightY),
    bottomRight: Radius.elliptical(width * lowerRightX, height * lowerRightY),
    bottomLeft: Radius.elliptical(width * lowerLeftX, height * lowerLeftY),
  );
}

/// The pearlescent surface used by the lotus player, behind a standalone glyph.
/// The control retains its original layout, gestures and accessibility target.
class LotusIconSurface extends StatelessWidget {
  const LotusIconSurface({super.key, required this.child, this.diameter = 34});

  final Widget child;
  final double diameter;

  @override
  Widget build(BuildContext context) {
    final height = diameter * 75 / 84;
    final radius = LotusPebbleContour.play.resolve(diameter, height);
    return Stack(
      fit: StackFit.passthrough,
      alignment: Alignment.center,
      clipBehavior: Clip.none,
      children: [
        Positioned.fill(
          child: IgnorePointer(
            child: OverflowBox(
              minWidth: diameter,
              maxWidth: diameter,
              minHeight: height,
              maxHeight: height,
              child: CustomPaint(
                painter: LotusSurfacePainter(radius, false, false),
              ),
            ),
          ),
        ),
        child,
      ],
    );
  }
}

/// Shared optical size for arrows in navigation buttons and clickable cards.
/// The surrounding button owns semantics, gestures and its minimum tap target.
class LotusArrowBubble extends StatelessWidget {
  const LotusArrowBubble({super.key, this.back = false});

  static const diameter = 34.0;
  static const glyphSize = 17.0;
  static const hitExtent = 44.0;
  final bool back;

  @override
  Widget build(BuildContext context) {
    return SizedBox.square(
      dimension: diameter,
      child: LotusIconSurface(
        diameter: diameter,
        child: Center(
          child: ClayIcon(
            back ? Icons.chevron_left : Icons.chevron_right,
            size: glyphSize,
            color: const Color(0xFFFFE6F4),
          ),
        ),
      ),
    );
  }
}

/// Refresh and shuffle share the navigation arrows' optical proportions.
/// A parent button retains a minimum 44-point touch target.
class LotusRefreshBubble extends StatelessWidget {
  const LotusRefreshBubble({super.key, this.shuffle = false, this.tint});

  final bool shuffle;
  final Color? tint;

  @override
  Widget build(BuildContext context) => SizedBox.square(
    dimension: LotusArrowBubble.diameter,
    child: LotusIconSurface(
      diameter: LotusArrowBubble.diameter,
      child: Center(
        child: ClayAssetIcon(
          shuffle
              ? 'assets/icons/daily_symbol_shuffle.svg'
              : 'assets/icons/repeat_icon.svg',
          width: LotusArrowBubble.glyphSize,
          height: LotusArrowBubble.glyphSize,
          tint: tint,
        ),
      ),
    ),
  );
}

class LotusSurfacePainter extends CustomPainter {
  const LotusSurfacePainter(this.radius, this.active, this.focused);
  final BorderRadius radius;
  final bool active;
  final bool focused;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final shape = radius.toRRect(rect);
    void fill(Gradient gradient) =>
        canvas.drawRRect(shape, Paint()..shader = gradient.createShader(rect));
    fill(
      const LinearGradient(
        begin: Alignment(-.5, -1),
        end: Alignment(.5, 1),
        colors: [Color(0x25fbdeef), Color(0x0cfae3ec), Color(0x26c4b4dd)],
      ),
    );
    fill(
      const RadialGradient(
        center: Alignment(-.5, -.84),
        radius: .73,
        colors: [Color(0x34fff5f5), Color(0x00fff5f5)],
      ),
    );
    fill(
      const RadialGradient(
        center: Alignment(.66, .8),
        radius: .76,
        colors: [Color(0x34cbbde7), Color(0x00cbbde7)],
      ),
    );
    if (active) {
      fill(
        const RadialGradient(
          center: Alignment(-.18, -.12),
          radius: .72,
          colors: [Color(0x66fff5ee), Color(0x20f4d8ec), Color(0x00f4d8ec)],
          stops: [0, .6, 1],
        ),
      );
    }
    final stroke = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 1.1);
    canvas.drawRRect(
      shape.shift(const Offset(0, .75)),
      stroke
        ..color = const Color(0x5efff8f5)
        ..shader = const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0x9afff8f5), Color(0x30f9e0f1), Color(0x335e4766)],
        ).createShader(rect),
    );
    // A narrow directional rim follows the upper edge of the clay surface.
    final rim = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = .85
      ..shader = const LinearGradient(
        begin: Alignment(-.55, -1),
        end: Alignment(.4, 1),
        colors: [
          Color(0xa8fff8f5),
          Color(0x48f9e0f1),
          Color(0x115e4766),
          Color(0x355e4766),
        ],
        stops: [0, .32, .72, 1],
      ).createShader(rect);
    canvas.drawRRect(shape.deflate(.45), rim);
    if (focused) {
      canvas.drawRRect(
        shape.deflate(1),
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2
          ..color = const Color(0xfff3cbab),
      );
    }
  }

  @override
  bool shouldRepaint(LotusSurfacePainter old) =>
      radius != old.radius || active != old.active || focused != old.focused;
}
