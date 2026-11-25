part of 'affirmation_motion_artwork.dart';

class RoseReflectionArtwork extends StatelessWidget {
  const RoseReflectionArtwork({
    super.key,
    required this.asset,
    required this.seconds,
  });
  final String asset;
  final double seconds;

  @override
  Widget build(BuildContext context) => _TexturedPlate(
    asset: asset,
    phase: MediaQuery.disableAnimationsOf(context) ? 0 : seconds * math.pi / 3,
    painter: _RoseReflection.new,
  );
}

// All positions are registered to the original 350-point cover. Pin the
// brass rim and the bottom of the stem; flex the bloom and leaves together.
class _RoseReflection extends CustomPainter {
  _RoseReflection(this.texture, this.phase);
  final ui.Image texture;
  final double phase;
  static final uv = [
    for (final point in _SubjectMesh.points) point * (350 / _SubjectMesh.side),
  ];
  static double _influence(Offset p, Offset center, double w, double h) {
    final x = (p.dx - center.dx) / w, y = (p.dy - center.dy) / h;
    return math.exp(-x * x - y * y);
  }

  static final weights = [
    for (final p in uv)
      (
        bloom: _weight(p, const Offset(202, 140), 56, 57),
        leaves: _weight(p, const Offset(181, 218), 53, 33),
      ),
  ];
  static double _weight(Offset p, Offset center, double w, double h) {
    final edge = math.min(
      math.min(p.dx - 111, 239 - p.dx),
      math.min(p.dy - 78, 258 - p.dy),
    );
    final t = (edge / 22).clamp(0.0, 1.0);
    return t * t * (3 - 2 * t) * _influence(p, center, w, h);
  }

  @override
  void paint(Canvas canvas, Size size) {
    final sway = math.sin(phase);
    final leaf = math.sin(phase - .6) + math.sin(.6) * math.cos(phase * 2);
    final points = [
      for (var i = 0; i < uv.length; i++)
        uv[i] +
            Offset(
              14 * weights[i].bloom * sway + 7 * weights[i].leaves * leaf,
              -6 * weights[i].bloom * sway + 5 * weights[i].leaves * leaf,
            ),
    ];
    canvas.save();
    canvas.scale(size.width / 350, size.height / 350);
    _SubjectMesh.draw(canvas, texture, points, textureCoordinates: uv);
    canvas.restore();
  }

  @override
  bool shouldRepaint(_RoseReflection old) =>
      texture != old.texture || phase != old.phase;
}
