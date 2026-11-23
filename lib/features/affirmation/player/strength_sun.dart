part of 'affirmation_motion_artwork.dart';

class _StrengthSun extends StatelessWidget {
  const _StrengthSun({
    required this.phase,
    required this.mountain,
    required this.plate,
  });

  final double phase;
  final bool mountain;
  final Widget Function(String) plate;

  @override
  Widget build(BuildContext context) {
    if (mountain) {
      // A complete orbit passes behind the foreground ridge at night. The
      // sunrise and sunset remain continuous even when playback wraps.
      final orbit = phase - .76;
      final position = Offset(
        60 * math.sin(orbit),
        16 - 43 * math.cos(orbit),
      );
      return Stack(
        fit: StackFit.expand,
        children: [
          Transform.translate(offset: position, child: plate('_a')),
          plate(''),
        ],
      );
    }

    // The morning illustration has a complete bracelet, wrist and fingertips.
    // Keep the palm fixed and let only the separate sun turn and rise above it.
    const art = 'assets/images/practices';
    final lift = (1 + math.sin(phase - .45)) / 2;
    return Stack(
      children: [
        Positioned(
          left: 62,
          top: 33 - 20 * lift,
          width: 144,
          height: 134,
          child: Transform.rotate(
            angle: phase,
            child: Image.asset(
              '$art/motion-sun.webp',
              fit: BoxFit.contain,
              filterQuality: FilterQuality.medium,
              excludeFromSemantics: true,
            ),
          ),
        ),
        Positioned(
          left: 21,
          top: 126,
          width: 208,
          height: 115,
          child: Image.asset(
            '$art/motion-palm.webp',
            fit: BoxFit.contain,
            filterQuality: FilterQuality.medium,
            excludeFromSemantics: true,
          ),
        ),
      ],
    );
  }
}
