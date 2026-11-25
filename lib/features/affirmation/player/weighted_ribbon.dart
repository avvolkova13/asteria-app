part of 'affirmation_motion_artwork.dart';

class WeightedRibbonArtwork extends StatelessWidget {
  const WeightedRibbonArtwork({
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
        : seconds * math.pi / 2.4,
    painter: _WeightedRibbon.new,
  );
}

class _WeightedRibbon extends CustomPainter {
  _WeightedRibbon(this.texture, this.phase);
  final ui.Image texture;
  final double phase;

  static final uv = [
    for (final p in _SubjectMesh.points) p * (350 / _SubjectMesh.side),
  ];

  // Keep the columns over both brass weights fixed. A phase delay along
  // the free span lets the fold travel across the original satin texture.
  static Offset _wave(Offset p) {
    if (p.dx <= 105 || p.dx >= 245) return Offset.zero;
    final u = (p.dx - 105) / 140;
    final amplitude = 13 * math.pow(math.sin(math.pi * u), 2);
    final lag = (u - .5) * math.pi;
    return Offset(amplitude * math.cos(lag), amplitude * math.sin(lag));
  }

  static final waves = uv.map(_wave).toList(growable: false);

  @override
  void paint(Canvas canvas, Size size) {
    final sway = math.sin(phase);
    final follow = 1 - math.cos(phase);
    final posed = [
      for (var i = 0; i < uv.length; i++)
        uv[i].translate(0, waves[i].dx * sway + waves[i].dy * follow),
    ];
    canvas.save();
    canvas.scale(size.width / 350, size.height / 350);
    _SubjectMesh.draw(canvas, texture, posed, textureCoordinates: uv);
    canvas.restore();
  }

  @override
  bool shouldRepaint(_WeightedRibbon old) =>
      texture != old.texture || phase != old.phase;
}
