part of 'affirmation_motion_artwork.dart';

class FigLeavesArtwork extends StatelessWidget {
  const FigLeavesArtwork({
    super.key,
    required this.asset,
    required this.seconds,
  });

  final String asset;
  final double seconds;

  @override
  Widget build(BuildContext context) => _TexturedPlate(
    asset: asset,
    phase: MediaQuery.disableAnimationsOf(context)
        ? 0
        : seconds * math.pi / 2.5,
    painter: _FigLeaves.new,
  );
}

class _FigLeaves extends CustomPainter {
  _FigLeaves(this.texture, this.phase);
  final ui.Image texture;
  final double phase;

  static final uv = [
    for (final point in _SubjectMesh.points) point * (350 / _SubjectMesh.side),
  ];

  // The exposed leaf tips sit above the sloping shoulder of the front fig.
  // Taper the bend to zero before the texture reaches either fruit or the dish.
  static double _bend(Offset point) {
    final clearance = 124 + .57 * (point.dx - 197) - point.dy;
    final weight = (clearance / 43).clamp(0.0, 1.0);
    final leftEdge = ((point.dx - 179) / 25).clamp(0.0, 1.0);
    return weight * weight * (3 - 2 * weight) * leftEdge;
  }

  static final bend = [for (final point in uv) _bend(point)];

  @override
  void paint(Canvas canvas, Size size) {
    final sway = math.sin(phase);
    final lift = math.sin(phase * 2);
    final posed = [
      for (var i = 0; i < uv.length; i++)
        uv[i] + Offset(12 * sway, -5 * sway + 2 * lift) * bend[i],
    ];
    canvas.save();
    canvas.scale(size.width / 350, size.height / 350);
    _SubjectMesh.draw(canvas, texture, posed, textureCoordinates: uv);
    canvas.restore();
  }

  @override
  bool shouldRepaint(_FigLeaves old) =>
      texture != old.texture || phase != old.phase;
}
