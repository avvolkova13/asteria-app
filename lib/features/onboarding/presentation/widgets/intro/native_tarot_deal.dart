import 'package:asteria_app/core/ui_kit/widgets/card_turn.dart';
import 'package:asteria_app/core/ui_kit/widgets/tarot_card_frame.dart';
import 'package:flutter/material.dart';

/// Cards arrive face down in a row, rest, then turn one at a time.
class NativeTarotDeal extends StatefulWidget {
  const NativeTarotDeal({super.key, required this.seconds});
  final double seconds;
  @override
  State<NativeTarotDeal> createState() => _NativeTarotDealState();
}

class _NativeTarotDealState extends State<NativeTarotDeal> {
  String? _preloadedLanguage;
  List<String> _hand = const [];
  static const _back = 'assets/images/home/daily_symbol_tarot_back.webp';

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final language = Localizations.localeOf(context).languageCode;
    if (_preloadedLanguage == language) return;
    _preloadedLanguage = language;
    final directory = language == 'ru'
        ? 'assets/images/cards'
        : 'assets/images/cards/en';
    _hand = [
      '$directory/the_high_priestess.webp',
      '$directory/the_star.webp',
      '$directory/the_moon.webp',
    ];
    // Decode both sides before the first turn, while the question is visible.
    for (final path in [_back, ..._hand]) {
      precacheImage(ResizeImage(AssetImage(path), width: 330), context);
    }
  }

  static double _progress(double time, double start, double end) => Curves
      .easeInOutCubic
      .transform(((time - start) / (end - start)).clamp(0.0, 1.0));

  @override
  Widget build(BuildContext context) {
    final time = MediaQuery.disableAnimationsOf(context) ? 5.0 : widget.seconds;
    return ExcludeSemantics(
      child: AspectRatio(
        aspectRatio: 354 / 232,
        child: LayoutBuilder(
          builder: (context, bounds) {
            final width = (bounds.maxWidth - 24) / 3;
            return Stack(
              clipBehavior: Clip.none,
              children: [
                for (var i = 0; i < 3; i++)
                  Positioned(
                    left: i * (width + 12),
                    top: 24,
                    width: width,
                    height: width * 1.5,
                    child: Builder(
                      builder: (context) {
                        final arrive = _progress(time, i * .13, .5 + i * .13);
                        final flip = ((time - 1.25 - i * .65) / .85).clamp(
                          0.0,
                          1.0,
                        );
                        final focus = _progress(time, 3.6, 4.4);
                        return Opacity(
                          opacity: arrive * (i == 1 ? 1 : 1 - .24 * focus),
                          child: Transform.translate(
                            offset: Offset(
                              0,
                              24 * (1 - arrive) - (i == 1 ? 12 * focus : 0),
                            ),
                            child: CardTurn(
                              progress: flip,
                              back: _face(_back, 'intro-card-$i-back'),
                              front: _face(_hand[i], 'intro-card-$i-front'),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _face(String path, String key) => TarotCardFrame(
    radius: 10,
    child: Image.asset(
      path,
      key: ValueKey(key),
      fit: BoxFit.fill,
      gaplessPlayback: true,
      cacheWidth: 330,
      excludeFromSemantics: true,
    ),
  );
}
