part of 'affirmation_motion_artwork.dart';

class LinkedStonesArtwork extends StatelessWidget {
  const LinkedStonesArtwork({
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
    painter: _LinkedStones.new,
  );
}

class _LinkedStones extends CustomPainter {
  _LinkedStones(this.texture, this.phase);
  final ui.Image texture;
  final double phase;

  static final uv = [
    for (final point in _SubjectMesh.points) point * (350 / _SubjectMesh.side),
  ];

  // Beyond each knot the stone and its wrapped thread move as a rigid body.
  // Only the free span between them can change curvature.
  static final weights = [
    for (final point in uv) ((point.dx - 131) / (213 - 131)).clamp(0.0, 1.0),
  ];

  @override
  void paint(Canvas canvas, Size size) {
    final pull = math.sin(phase);
    final posed = <Offset>[];
    for (var i = 0; i < uv.length; i++) {
      final t = weights[i];
      final side = 2 * t - 1;
      final slack = 4 * t * (1 - t);
      posed.add(
        uv[i] + Offset(9 * side * pull, (4 * side - 15 * slack) * pull),
      );
    }
    canvas.save();
    canvas.scale(size.width / 350, size.height / 350);
    _SubjectMesh.draw(canvas, texture, posed, textureCoordinates: uv);
    canvas.restore();
  }

  @override
  bool shouldRepaint(_LinkedStones old) =>
      texture != old.texture || phase != old.phase;
}
