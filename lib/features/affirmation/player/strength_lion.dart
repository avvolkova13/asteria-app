part of 'affirmation_motion_artwork.dart';

/// A breeze bends the lengths of the mane on the intact portrait.
class _LionMane extends CustomPainter {
  _LionMane(this.texture, this.phase);
  static const asset =
      'assets/images/affirmation/motion/subjects/lion_whole.png';
  final ui.Image texture;
  final double phase;

  // Distances are measured on the registered 430 px artwork. Each fixed
  // area has a soft transition into the surrounding hair.
  static double _outside(Offset p, Offset center, double rx, double ry) {
    final x = (p.dx - center.dx) / rx;
    final y = (p.dy - center.dy) / ry;
    final t = ((math.sqrt(x * x + y * y) - 1) / .6).clamp(0.0, 1.0);
    return t * t * (3 - 2 * t);
  }

  static (Offset, Offset) _bend(Offset p) {
    final free =
        _outside(p, const Offset(216, 178), 96, 100) *
        _outside(p, const Offset(116, 113), 34, 32) *
        _outside(p, const Offset(327, 113), 34, 32);
    final length = (p.dy / _SubjectMesh.side).clamp(0.0, 1.0);
    // The wave arrives at the crown first and trails through the long locks.
    final lag = p.dx * .0018 + length * 1.3;
    final swing = free * (6 + 4 * length);
    final lift = free * 3.0 * (p.dx - 216) / 180;
    return (
      Offset(swing * math.cos(lag), lift * math.cos(lag + .4)),
      Offset(-swing * math.sin(lag), -lift * math.sin(lag + .4)),
    );
  }

  static final _bends = _SubjectMesh.points.map(_bend).toList(growable: false);

  @override
  void paint(Canvas canvas, Size size) {
    final wave = math.sin(phase), follow = math.cos(phase);
    final posed = [
      for (var i = 0; i < _bends.length; i++)
        _SubjectMesh.points[i] + _bends[i].$1 * wave + _bends[i].$2 * follow,
    ];
    canvas.save();
    canvas.scale(
      size.width / _SubjectMesh.side,
      size.height / _SubjectMesh.side,
    );
    _SubjectMesh.draw(canvas, texture, posed);
    canvas.restore();
  }

  @override
  bool shouldRepaint(_LionMane old) =>
      old.phase != phase || old.texture != texture;
}
