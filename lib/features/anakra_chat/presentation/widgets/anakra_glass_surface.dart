import 'package:asteria_app/core/ui_kit/widgets/static_glass_surface.dart';
import 'package:flutter/material.dart';

enum AnakraBubbleSide { none, incoming, outgoing }

/// Corners and tails retain their dimensions when a message grows.
Path anakraBubblePath(Size size, AnakraBubbleSide side, double radius) {
  if (side == AnakraBubbleSide.none) {
    return Path()..addRRect(
      RRect.fromRectAndRadius(Offset.zero & size, Radius.circular(radius)),
    );
  }
  const tail = 5.0;
  final w = size.width - tail;
  final h = size.height;
  final r = radius.clamp(0.0, h / 2);
  final path = Path()
    ..moveTo(r, 0)
    ..lineTo(w - r, 0)
    ..quadraticBezierTo(w, 0, w, r)
    ..lineTo(w, h - 16)
    ..cubicTo(w - 1, h - 8, w + 1, h - 3, w + tail, h)
    ..quadraticBezierTo(w, h, w - 7, h - 3)
    ..quadraticBezierTo(w - 10, h, w - r, h)
    ..lineTo(r, h)
    ..quadraticBezierTo(0, h, 0, h - r)
    ..lineTo(0, r)
    ..quadraticBezierTo(0, 0, r, 0)
    ..close();
  if (side == AnakraBubbleSide.outgoing) return path;
  return path.transform(
    Matrix4.identity().storage
      ..[0] = -1
      ..[12] = size.width,
  );
}

class AnakraGlassSurface extends StatelessWidget {
  const AnakraGlassSurface({
    super.key,
    required this.child,
    this.side = AnakraBubbleSide.none,
    this.radius = 24,
    this.tint = const Color(0x33000000),
    this.light = 0.6,
    this.shadow = false,
  });
  final Widget child;
  final AnakraBubbleSide side;
  final double radius;
  final Color tint;
  final double light;
  final bool shadow;

  @override
  Widget build(BuildContext context) => StaticGlassSurface(
    backgroundAsset: 'assets/images/anakra/background.png',
    pathBuilder: (size, radius) => anakraBubblePath(size, side, radius),
    radius: radius,
    tint: tint,
    light: light,
    shadow: shadow,
    child: child,
  );
}
