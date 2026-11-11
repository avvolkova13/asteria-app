part of 'scenario_ui.dart';

/// Paint the atmospheric artwork directly into the tile: no backdrop capture,
/// offscreen blur, or moving layer over the caption.
class _ChoiceClouds extends CustomPainter {
  _ChoiceClouds({
    required this.mood,
    required this.accent,
    required this.seed,
    required this.wide,
    required Animation<double> motion,
    required this.drift,
  }) : super(repaint: motion);
  final ScenarioMood mood;
  final Color? accent;
  final int seed;
  final bool wide;
  final double Function() drift;

  @override
  void paint(Canvas canvas, Size size) {
    if (size.isEmpty) return;
    final bounds = Offset.zero & size;
    final highlight = Color.lerp(mood.rim, accent ?? mood.rim, .14)!;
    final foundation = Color.lerp(mood.mist, mood.ground, .27)!;
    final plum = Color.lerp(mood.ground, AppColors.textPrimary, .56)!;
    final movement = drift();
    final position = (seed % 97) / 97;
    canvas.drawRect(
      bounds,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [mood.mist, foundation, mood.ground],
        ).createShader(bounds),
    );
    // An elliptical radial wash blends into its neighbours without sharp ends.
    void cloud(
      double x,
      double y,
      double rx,
      double ry,
      Color tint, {
      double tilt = 0,
    }) {
      canvas.save();
      canvas.translate(size.width * x, size.height * y);
      canvas.rotate(tilt);
      canvas.scale(size.width * rx, size.height * ry);
      final paint = Paint()
        ..shader = ui.Gradient.radial(
          Offset.zero,
          1,
          [
            tint,
            tint.withValues(alpha: tint.a * .77),
            tint.withValues(alpha: 0),
          ],
          const [0, .36, 1],
        );
      canvas.drawCircle(Offset.zero, 1, paint);
      canvas.restore();
    }

    final offset = (position - .5) * .16 + movement * .05;
    switch (mood) {
      case ScenarioMood.calendar:
        // Parallel banks of mist rise towards the right, with a pale wave crest.
        cloud(.78 + offset, .18, .8, .55, mood.mist);
        cloud(.56 + offset, .34, .95, .16, highlight, tilt: -.27);
        cloud(
          .06 - offset,
          .53,
          .56,
          .13,
          mood.rim.withValues(alpha: .72),
          tilt: -.27,
        );
      case ScenarioMood.strength:
        // A broad apricot light blooms from the horizon into a rose sky.
        cloud(.10 + offset, .08, .9, .72, ScenarioMood.relationships.rim);
        cloud(.74 - offset, .48, .83, .73, highlight);
        cloud(
          .8 - offset,
          .59,
          .5,
          .33,
          Color.lerp(highlight, AppColors.white, .38)!,
        );
      case ScenarioMood.practice:
        // Billowing lilac clouds have distinct overlapping lobes.
        cloud(.12 + offset, .08, .78, .65, ScenarioMood.calendar.mist);
        cloud(.61 + offset, .22, .52, .62, mood.mist);
        cloud(.95 - offset, .32, .57, .59, highlight);
        cloud(
          .14 + offset,
          .64,
          .58,
          .30,
          ScenarioMood.calendar.rim.withValues(alpha: .70),
          tilt: .18,
        );
      case ScenarioMood.relationships:
        cloud(.17 - offset, .14, .72, .60, highlight);
        cloud(.73 + offset, .45, .62, .40, mood.mist, tilt: .40);
        cloud(
          .94 - offset,
          .54,
          .51,
          .22,
          ScenarioMood.practice.rim.withValues(alpha: .77),
          tilt: .40,
        );
    }
    // The type lane is darker, while the rest of the illustration stays luminous.
    canvas.drawRect(
      bounds,
      Paint()
        ..shader = LinearGradient(
          begin: wide ? Alignment.centerRight : Alignment.topCenter,
          end: wide ? const Alignment(-1, .6) : Alignment.bottomCenter,
          colors: [
            plum.withValues(alpha: .02),
            plum.withValues(alpha: .13),
            plum.withValues(alpha: .72),
            plum.withValues(alpha: .90),
          ],
          stops: const [0, .37, .76, 1],
        ).createShader(bounds),
    );
  }

  @override
  bool shouldRepaint(_ChoiceClouds old) =>
      old.mood != mood ||
      old.accent != accent ||
      old.wide != wide ||
      old.seed != seed ||
      old.drift != drift;
}
