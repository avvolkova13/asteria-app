import 'package:flutter/widgets.dart';

/// Rows in the illustrated 16-frame atlas used by the lotus player.
enum LotusPose {
  play,
  pause,
  download,
  bookmark,
  saved,
  repeat,
  close,
  chevron,
  spark,
}

class LotusSprite extends StatelessWidget {
  const LotusSprite(
    this.pose, {
    super.key,
    required this.size,
    this.frame = 0,
    this.tint,
    this.flip = false,
  });

  final LotusPose pose;
  final double size;
  final int frame;
  final Color? tint;
  final bool flip;

  @override
  Widget build(BuildContext context) {
    final art = SizedBox.square(
      dimension: size,
      child: ClipRect(
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Positioned(
              left: -size * frame.clamp(0, 15),
              top: -size * pose.index,
              width: size * 16,
              height: size * LotusPose.values.length,
              child: Image.asset(
                'assets/images/affirmation/iconity-clay.webp',
                color: tint,
                colorBlendMode: BlendMode.modulate,
                fit: BoxFit.fill,
                excludeFromSemantics: true,
              ),
            ),
          ],
        ),
      ),
    );
    return flip ? Transform.flip(flipX: true, child: art) : art;
  }
}
