import 'dart:math' as math;

import 'package:asteria_app/core/ui_kit/widgets/tarot_card_frame.dart';
import 'package:flutter/material.dart';

/// Three cards leave a single stack and settle into an upright row.
/// The parent controls time (seconds) and can restart the scene from zero.
class NativeTarotDeal extends StatelessWidget {
  const NativeTarotDeal({super.key, required this.seconds});

  final double seconds;

  static const _art = 'assets/images/cards';
  static const _back = 'assets/images/home/daily_symbol_tarot_back.webp';
  static const _hand = [
    '$_art/the_high_priestess.webp',
    '$_art/the_star.webp',
    '$_art/the_moon.webp',
  ];

  static double _progress(double time, double start, double end) {
    final t = ((time - start) / (end - start)).clamp(0.0, 1.0);
    return t * t * (3 - 2 * t);
  }

  static Widget _artwork(String image) {
    return TarotCardFrame(
      radius: 10,
      child: Image.asset(
        image,
        fit: BoxFit.fill,
        excludeFromSemantics: true,
        gaplessPlayback: true,
        cacheWidth: 330,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final time = MediaQuery.disableAnimationsOf(context) ? 2.54 : seconds;
    final waiting = <Widget>[];
    final dealing = <Widget>[];
    for (var i = 0; i < _hand.length; i++) {
      final local = time - .15 - i * .58;
      final travel = _progress(local, 0, .88);
      final flip = _progress(local, .18, .78);
      final showFront = flip >= .5;
      final startY = 114.0 + i * 3;
      final card = Positioned(
        key: ValueKey(_hand[i]),
        left: 165 + (i - 1) * 124 * travel,
        top: startY + (46 - startY) * travel - 9 * math.sin(math.pi * travel),
        width: 110,
        height: 165,
        child: Transform.scale(
          scale: .82 + .18 * travel,
          child: Transform(
            alignment: Alignment.center,
            transform: Matrix4.identity()
              ..setEntry(3, 2, -1 / 720)
              ..rotateY((showFront ? flip - 1 : flip) * math.pi),
            child: IndexedStack(
              sizing: StackFit.expand,
              index: showFront ? 1 : 0,
              children: [_artwork(_back), _artwork(_hand[i])],
            ),
          ),
        ),
      );
      (local > 0 ? dealing : waiting).add(card);
    }
    return AspectRatio(
      aspectRatio: 440 / 285,
      child: FittedBox(
        child: SizedBox(
          width: 440,
          height: 285,
          child: Stack(children: [...waiting.reversed, ...dealing]),
        ),
      ),
    );
  }
}
