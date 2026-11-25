part of 'affirmation_motion_artwork.dart';

class AbacusArtwork extends StatelessWidget {
  const AbacusArtwork({super.key, required this.asset, required this.seconds});

  final String asset;
  final double seconds;

  @override
  Widget build(BuildContext context) => _TexturedPlate(
    asset: asset,
    phase: MediaQuery.disableAnimationsOf(context)
        ? 0
        : seconds * 2 * math.pi / 5,
    painter: _Abacus.new,
  );
}

class _Abacus extends CustomPainter {
  _Abacus(this.texture, this.phase);

  final ui.Image texture;
  final double phase;
  static const plate = Rect.fromLTWH(0, 0, 350, 350);
  static final bead = Path()
    ..moveTo(134, 102)
    ..cubicTo(141, 102, 145, 107, 144.5, 114)
    ..lineTo(144, 120)
    ..cubicTo(143, 129, 137, 132, 131, 130)
    ..cubicTo(120, 128, 120, 105, 134, 102)
    ..close();
  static final frame = Path.combine(
    PathOperation.difference,
    Path()..addRect(plate),
    bead,
  );

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..filterQuality = FilterQuality.medium;
    canvas.save();
    canvas.scale(size.width / 350, size.height / 350);
    final travel = 23 * (1 - math.cos(phase));
    if (travel < .01) {
      canvas.drawImageRect(texture, plate, plate, paint);
    } else {
      canvas.save();
      canvas.clipPath(frame);
      canvas.drawImageRect(texture, plate, plate, paint);
      canvas.restore();

      // Reconstruct only the newly exposed rod and the edge of the adjacent bead.
      canvas.save();
      canvas.clipPath(bead);
      canvas.drawImageRect(
        texture,
        const Rect.fromLTRB(149, 110, 169, 121),
        const Rect.fromLTRB(119, 109, 146, 120),
        paint,
      );
      canvas.translate(-14.5, -.3);
      canvas.clipPath(bead);
      canvas.drawImageRect(texture, plate, plate, paint);
      canvas.restore();

      canvas.translate(travel, travel * .022);
      canvas.clipPath(bead);
      canvas.drawImageRect(texture, plate, plate, paint);
    }
    canvas.restore();
  }

  @override
  bool shouldRepaint(_Abacus old) =>
      texture != old.texture || phase != old.phase;
}
