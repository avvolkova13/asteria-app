part of 'affirmation_motion_artwork.dart';

/// The crown, rind and seed bed share one continuous source surface.
class _Pomegranate extends CustomPainter {
  _Pomegranate(this.texture, this.phase);
  static const asset =
      'assets/images/affirmation/motion/subjects/pomegranate_whole.png';
  final ui.Image texture;
  final double phase;

  static double _falloff(
    Offset p,
    double x,
    double y,
    double width,
    double height,
  ) {
    final dx = (p.dx - x) / width, dy = (p.dy - y) / height;
    return math.exp(-dx * dx - dy * dy);
  }

  // Movement is strongest at the leaf tips and dies away at their stems.
  static final weights = [
    for (final p in _SubjectMesh.points)
      (
        _falloff(p, 79, 77, 56, 67),
        _falloff(p, 45, 263, 62, 48),
        _falloff(p, 346, 366, 69, 40),
      ),
  ];

  @override
  void paint(Canvas canvas, Size size) {
    final upper = math.sin(phase);
    final lower = math.sin(phase - .52);
    final roll = math.sin(phase - .85);
    final posed = <Offset>[
      for (var i = 0; i < _SubjectMesh.points.length; i++)
        _SubjectMesh.points[i] +
            Offset(
              12 * weights[i].$1 * upper +
                  6 * weights[i].$2 * lower +
                  7 * weights[i].$3 * roll,
              -8 * weights[i].$1 * upper +
                  17 * weights[i].$2 * lower -
                  3 * weights[i].$3 * roll,
            ),
    ];
    canvas.save();
    canvas.scale(size.width / _SubjectMesh.side, size.height / _SubjectMesh.side);
    canvas.translate(229, 301);
    canvas.rotate(.024 * upper);
    canvas.translate(-229, -301);
    _SubjectMesh.draw(canvas, texture, posed);
    canvas.restore();
  }

  @override
  bool shouldRepaint(_Pomegranate old) =>
      phase != old.phase || texture != old.texture;
}
