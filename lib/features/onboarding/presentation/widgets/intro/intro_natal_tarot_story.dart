import 'dart:math' as math;

import 'package:asteria_app/app/data/models/user/user_model.dart';
import 'package:asteria_app/core/ui_kit/ui_kit.dart';
import 'package:asteria_app/core/ui_kit/widgets/card_turn.dart';
import 'package:asteria_app/core/ui_kit/widgets/tarot_card_frame.dart';
import 'package:asteria_app/features/home/presentation/widgets/home_glass_surface.dart';
import 'package:asteria_app/features/natal_card/widgets/natal_wheel.dart';
import 'package:flutter/material.dart';

import 'intro_story.dart';

const _readings = [
  (
    from: 'moon',
    to: 'mars',
    ru: 'Луна и Марс',
    en: 'Moon and Mars',
    meaningRu: 'Легче начать с того, что мне по-настоящему интересно.',
    meaningEn: 'It’s easier to begin with something I care about.',
  ),
  (
    from: 'mercury',
    to: 'jupiter',
    ru: 'Меркурий и Юпитер',
    en: 'Mercury and Jupiter',
    meaningRu: 'В разговоре моя идея становится яснее.',
    meaningEn: 'Talking my idea through helps me see it clearly.',
  ),
  (
    from: 'sun',
    to: 'moon',
    ru: 'Солнце и Луна',
    en: 'Sun and Moon',
    meaningRu: 'Рисовать я уже умею. С этого и начну своё дело.',
    meaningEn: 'I already know how to draw. That’s where I can start.',
  ),
];

class IntroNatalTarotStory extends StatelessWidget {
  const IntroNatalTarotStory({super.key, required this.active});
  final bool active;

  @override
  Widget build(BuildContext context) => IntroStory(
    active: active,
    duration: const Duration(seconds: 14),
    builder: (context, time, still, _) {
      final ru = Localizations.localeOf(context).languageCode == 'ru';
      final compact = MediaQuery.sizeOf(context).height < 650;
      final stroke = still ? 3.0 : ((time - .35) / 1.7).clamp(0.0, 3.0);
      final index = math.min(stroke.floor(), _readings.length - 1);
      final reading = _readings[index];
      final settle = still
          ? 1.0
          : Curves.easeInOutCubic.transform(
              ((time - 5.1) / .7).clamp(0.0, 1.0),
            );
      final showSpread = still || time >= 5.8;
      final complete = still || time >= 10.3;
      final expandedSize = compact ? 128.0 : 176.0;
      final foldedSize = compact ? 70.0 : 90.0;
      final wheelSize = expandedSize + (foldedSize - expandedSize) * settle;
      final textOpacity = still
          ? 1.0
          : time < 5.1
          ? ((5.1 - time) / .22).clamp(0.0, 1.0)
          : ((time - 5.8) / .24).clamp(0.0, 1.0);
      final caption = Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(context.l10n.natalChartTitle, style: _section),
          const SizedBox(height: 5),
          Text(ru ? reading.ru : reading.en, style: _title),
          const SizedBox(height: 4),
          Text(ru ? reading.meaningRu : reading.meaningEn, style: _body),
        ],
      );
      // Measure each endpoint at its actual wrap width. Interpolating those
      // heights keeps the surface continuous even for long localized captions.
      Widget captionSlot(double chartSize, double fraction) => ClipRect(
        child: Align(
          heightFactor: fraction,
          child: Container(
            constraints: BoxConstraints(minHeight: chartSize),
            alignment: Alignment.centerLeft,
            padding: EdgeInsets.only(left: chartSize + 10),
            child: caption,
          ),
        ),
      );
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          StoryEntrance(
            time: time,
            start: .17,
            child: HomeGlassSurface(
              animateEntrance: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(8, 12, 14, 12),
                child: Stack(
                  alignment: Alignment.centerLeft,
                  children: [
                    IntroStoryFocus(
                      key: ValueKey('intro-aspect-$index'),
                      enabled: !showSpread,
                      child: Opacity(
                        key: const ValueKey('intro-natal-caption-opacity'),
                        opacity: textOpacity,
                        child: StoryEntrance(
                          time: time,
                          start: .35 + index * 1.7,
                          rise: 4,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              if (settle < 1)
                                captionSlot(expandedSize, 1 - settle),
                              if (settle > 0) captionSlot(foldedSize, settle),
                            ],
                          ),
                        ),
                      ),
                    ),
                    _Chart(
                      size: wheelSize,
                      index: index,
                      progress: stroke - index,
                    ),
                  ],
                ),
              ),
            ),
          ),
          if (showSpread) ...[
            const SizedBox(height: 14),
            StoryEntrance(
              time: time,
              start: 5.8,
              child: Text(
                ru ? 'Расклад Таро' : 'Tarot spread',
                style: _section,
              ),
            ),
            const SizedBox(height: 10),
            IntroStoryFocus(
              key: const ValueKey('intro-spread'),
              enabled: !complete,
              child: StoryEntrance(
                time: time,
                start: 5.82,
                rise: 4,
                child: _Spread(
                  time: time,
                  still: still,
                  ru: ru,
                  compact: compact,
                ),
              ),
            ),
          ],
          if (complete)
            IntroStoryFocus(
              child: Padding(
                padding: const EdgeInsets.only(top: 12),
                child: StoryReveal(
                  time: time,
                  start: still ? -1 : 10.3,
                  child: HomeGlassSurface(
                    key: const ValueKey('intro-natal-tarot-result'),
                    animateEntrance: false,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            ru ? 'Мой первый шаг' : 'My first step',
                            style: _section,
                          ),
                          const SizedBox(height: 5),
                          Text(
                            ru
                                ? 'Нарисую эскиз и покажу его будущему клиенту. Спрошу, что он хотел бы изменить.'
                                : 'I’ll draw a sketch and show it to a potential client. I’ll ask what they’d change.',
                            style: _body,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
        ],
      );
    },
  );
}

final _section = AppTypography.text2SemiBold.copyWith(
  color: AppColorsDark.linkGold,
);
final _title = AppTypography.h3.copyWith(color: AppColors.textInverse);
final _body = AppTypography.text1.copyWith(color: AppColors.textInverse);

class _Chart extends StatelessWidget {
  const _Chart({
    required this.size,
    required this.index,
    required this.progress,
  });
  final double size, progress;
  final int index;

  @override
  Widget build(BuildContext context) => SizedBox.square(
    key: const ValueKey('intro-chart-wheel'),
    dimension: size,
    child: Stack(
      fit: StackFit.expand,
      children: [
        // Its entrance is driven by the story clock so pausing freezes every layer.
        MediaQuery(
          data: MediaQuery.of(context).copyWith(disableAnimations: true),
          child: NatalWheel(
            data: _chart,
            hasKnownBirthTime: false,
            preview: true,
          ),
        ),
        CustomPaint(painter: _AspectTrace(index, progress)),
      ],
    ),
  );
}

// The preview uses the actual wheel beneath this moving highlight. Its aspect
// pins are on the 118-radius circle of the wheel's 700-point zodiac artwork.
class _AspectTrace extends CustomPainter {
  const _AspectTrace(this.index, this.progress);
  final int index;
  final double progress;

  @override
  void paint(Canvas canvas, Size size) {
    final link = _readings[index];
    Offset pin(String code) {
      final degrees = _chart.positions
          .firstWhere((p) => p.code == code)
          .longitude;
      final angle = (degrees - 105) * math.pi / 180;
      return size.center(Offset.zero) +
          Offset.fromDirection(angle, size.width * 118 / 700);
    }

    final from = pin(link.from);
    final end = Offset.lerp(
      from,
      pin(link.to),
      Curves.easeInOutCubic.transform((progress / .68).clamp(0.0, 1.0)),
    )!;
    final alpha =
        (progress / .10).clamp(0.0, 1.0) *
        ((1.0 - progress) / .20).clamp(0.0, 1.0);
    final gold = AppColorsDark.linkGold;
    final pen = Paint()..strokeCap = StrokeCap.round;
    canvas.drawLine(
      from,
      end,
      pen
        ..strokeWidth = 5
        ..color = gold.withValues(alpha: .32 * alpha)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3),
    );
    canvas.drawLine(
      from,
      end,
      pen
        ..maskFilter = null
        ..strokeWidth = 2
        ..color = gold.withValues(alpha: alpha),
    );
    canvas.drawCircle(end, 2.5, pen);
  }

  @override
  bool shouldRepaint(_AspectTrace old) =>
      old.index != index || old.progress != progress;
}

const _faces = ['the_star', 'the_magician', 'page_of_pentacles'];

class _Spread extends StatelessWidget {
  const _Spread({
    required this.time,
    required this.still,
    required this.ru,
    required this.compact,
  });
  final double time;
  final bool still, ru, compact;

  @override
  Widget build(BuildContext context) {
    final roles = ru
        ? const ['Замысел', 'Ресурс', 'Первый шаг']
        : const ['The idea', 'Resources', 'First step'];
    final names = ru
        ? const ['Звезда', 'Маг', 'Паж пентаклей']
        : const ['The Star', 'The Magician', 'Page of Pentacles'];
    final directory = ru ? 'assets/images/cards' : 'assets/images/cards/en';
    final deal = still
        ? 1.0
        : Curves.easeOutCubic.transform(((time - 5.8) / .8).clamp(0.0, 1.0));
    final turns = List.generate(
      3,
      (i) => still
          ? 1.0
          : ((time - 6.9 - i * 1.15) /
                    (CardTurn.duration.inMilliseconds / 1000))
                .clamp(0.0, 1.0),
    );
    // Match the eased face change used by CardTurn itself, including semantics.
    final faceUp = turns
        .map((turn) => Curves.easeInOutCubic.transform(turn) >= .5)
        .toList();
    return LayoutBuilder(
      builder: (context, bounds) {
        final width = math.min(
          compact ? 78.0 : 100.0,
          (bounds.maxWidth - 20) / 3,
        );
        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            for (var i = 0; i < 3; i++)
              Expanded(
                child: Column(
                  children: [
                    Transform.translate(
                      offset: Offset(
                        (1 - i) * (1 - deal) * bounds.maxWidth / 4,
                        0,
                      ),
                      child: Transform.rotate(
                        angle: (i - 1) * .12 * (1 - deal),
                        child: Semantics(
                          image: true,
                          label: faceUp[i]
                              ? names[i]
                              : (ru ? 'Рубашка карты' : 'Card back'),
                          child: SizedBox(
                            key: ValueKey('intro-spread-turn-$i'),
                            width: width,
                            height: width * 1.5,
                            child: CardTurn(
                              progress: turns[i],
                              back: _face(
                                'assets/images/home/daily_symbol_tarot_back.webp',
                                'back',
                                i,
                              ),
                              front: _face(
                                '$directory/${_faces[i]}.webp',
                                'front',
                                i,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    if (faceUp[i]) ...[
                      const SizedBox(height: 6),
                      StoryEntrance(
                        time: time,
                        start:
                            6.9 +
                            i * 1.15 +
                            CardTurn.duration.inMilliseconds / 2000,
                        rise: 4,
                        child: Text(
                          roles[i],
                          style: AppTypography.text2.copyWith(
                            color: AppColors.textInverse,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
          ],
        );
      },
    );
  }

  static Widget _face(String path, String side, int index) => TarotCardFrame(
    radius: 8,
    child: Image.asset(
      path,
      key: ValueKey('intro-spread-$side-$index'),
      fit: BoxFit.cover,
      cacheWidth: 330,
      excludeFromSemantics: true,
    ),
  );
}

final _chart = PlanetsHousesDataModel(
  data: '',
  elements: const Elements(fire: '0', earth: '0', air: '0', water: '0'),
  positions: const [
    PlanetHousePositionModel(
      code: 'mercury',
      name: 'Mercury',
      signCode: 'libra',
      sign: 'Libra',
      house: 0,
      longitude: 180,
    ),
    PlanetHousePositionModel(
      code: 'jupiter',
      name: 'Jupiter',
      signCode: 'scorpio',
      sign: 'Scorpio',
      house: 0,
      longitude: 238,
    ),
    PlanetHousePositionModel(
      code: 'moon',
      name: 'Moon',
      signCode: 'taurus',
      sign: 'Taurus',
      house: 0,
      longitude: 58,
    ),
    PlanetHousePositionModel(
      code: 'sun',
      name: 'Sun',
      signCode: 'leo',
      sign: 'Leo',
      house: 0,
      longitude: 145,
    ),
    PlanetHousePositionModel(
      code: 'mars',
      name: 'Mars',
      signCode: 'aries',
      sign: 'Aries',
      house: 0,
      longitude: 1,
    ),
  ],
);
