part of 'affirmation_motion_artwork.dart';

/// The painter's registration coordinates are shared by every plate in a scene.
class _CalmMotion extends StatelessWidget {
  const _CalmMotion({
    required this.motion,
    required this.phase,
    required this.plate,
  });

  final PlayerSubjectMotion motion;
  final double phase;
  final Widget Function(String) plate;

  Widget _part(
    String suffix, {
    required Offset pivot,
    double angle = 0,
    double x = 0,
    double y = 0,
  }) {
    const side = 430.0;
    return FractionalTranslation(
      translation: Offset(x / side, y / side),
      child: Transform.rotate(
        alignment: Alignment(2 * pivot.dx / side - 1, 2 * pivot.dy / side - 1),
        angle: angle,
        child: plate(suffix),
      ),
    );
  }

  double _closing([double delay = 0]) => (1 - math.sin(phase + delay)) / 2;

  List<Widget> _lotus() {
    // Outer sepals lead the bloom and the two inner cups follow them.
    final open = _closing();
    Widget pair(String name, bool left, Offset pivot, double angle) => _part(
      '${name}_${left ? 'l' : 'r'}',
      pivot: pivot,
      angle: left ? angle : -angle,
    );
    return [
      _part(
        '_crown',
        pivot: const Offset(221, 301),
        angle: .035 * math.sin(phase),
        y: 5 * open - 7,
      ),
      pair('_far', true, const Offset(179, 303), .27 * _closing(.15) - .035),
      pair('_far', false, const Offset(248, 303), .27 * _closing(.15) - .035),
      pair('_high', true, const Offset(211, 301), .40 * open - .085),
      pair('_high', false, const Offset(222, 301), .40 * open - .085),
      _part(
        '_pearl',
        pivot: const Offset(217, 242),
        angle: .09 * math.sin(phase),
        y: -9 * (1 - open),
      ),
      pair('_cup', true, const Offset(202, 318), .30 * _closing(-.24) - .08),
      pair('_cup', false, const Offset(224, 318), .30 * _closing(-.24) - .08),
      pair('_low', true, const Offset(177, 343), .14 * _closing(-.40) - .025),
      pair('_low', false, const Offset(250, 343), .14 * _closing(-.40) - .025),
      _part('_lip', pivot: const Offset(214, 344), y: 3 * open),
    ];
  }

  List<Widget> _stones() {
    final base = math.sin(phase);
    final middle = math.sin(phase - .35);
    final summit = math.sin(phase - .76);
    return [
      _part('_foundation', pivot: const Offset(194, 350), angle: .027 * base),
      _part(
        '_middle',
        pivot: const Offset(203, 225),
        angle: .086 * middle,
        x: 8 * base,
        y: -.7 * middle.abs(),
      ),
      _part(
        '_summit',
        pivot: const Offset(210, 137),
        angle: -.14 * summit,
        x: 8 * (base + middle),
        y: 1 + .5 * summit.abs(),
      ),
      _part(
        '_leaf',
        pivot: const Offset(218, 347),
        angle: -.17 * math.sin(phase + .45) - .045,
        x: base,
        y: -1.5,
      ),
    ];
  }

  List<Widget> _surf() {
    final tide = math.sin(phase);
    final rise = math.cos(phase);
    return [
      _part(
        '_swell',
        pivot: const Offset(224, 335),
        angle: -.012 * tide,
        x: -4 * tide,
        y: 2 * rise,
      ),
      _part(
        '_crescent',
        pivot: const Offset(221, 272),
        angle: .095 * tide,
        x: 10 * tide,
        y: -14 * rise - 5,
      ),
      _part(
        '_curl',
        pivot: const Offset(204, 326),
        angle: .029 * math.sin(phase + .8),
        x: -8 * tide,
        y: 4 * math.cos(phase + .4),
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: switch (motion) {
        PlayerSubjectMotion.lotus => _lotus(),
        PlayerSubjectMotion.stones => _stones(),
        PlayerSubjectMotion.lunarRibbons => _surf(),
        _ => throw StateError('Unsupported calm scene: $motion'),
      },
    );
  }
}
