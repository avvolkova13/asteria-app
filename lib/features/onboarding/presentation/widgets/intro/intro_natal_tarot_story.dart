import 'dart:math' as math;

import 'package:asteria_app/app/data/models/user/user_model.dart';
import 'package:asteria_app/core/ui_kit/ui_kit.dart';
import 'package:asteria_app/core/ui_kit/widgets/card_turn.dart';
import 'package:asteria_app/core/ui_kit/widgets/tarot_card_frame.dart';
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
    meaningRu: 'Чтобы попробовать новое, могу опереться на знакомое ремесло.',
    meaningEn: 'A familiar craft gives me the confidence to try something new.',
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
      if (!still && time < 5.8) {
        final stroke = ((time - .35) / 1.7).clamp(0.0, 2.9999);
        final index = stroke.floor();
        final reading = _readings[index];
        final appear = (time / .4).clamp(0.0, 1.0);
        final leave = ((5.8 - time) / .35).clamp(0.0, 1.0);
        final wheel = _Chart(
          size: compact ? 146 : 248,
          index: index,
          progress: (stroke - index).clamp(0.0, 1.0),
        );
        final alignment = compact ? TextAlign.start : TextAlign.center;
        final interpretation = IntroStoryFocus(
          key: ValueKey('intro-aspect-$index'),
          child: Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Column(
              crossAxisAlignment: compact
                  ? CrossAxisAlignment.start
                  : CrossAxisAlignment.center,
              children: [
                Text(
                  ru ? reading.ru : reading.en,
                  style: _title,
                  textAlign: alignment,
                ),
                const SizedBox(height: 3),
                Text(
                  ru ? reading.meaningRu : reading.meaningEn,
                  style: _body,
                  textAlign: alignment,
                ),
              ],
            ),
          ),
        );
        return Opacity(
          opacity: appear * leave,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(context.l10n.natalChartTitle, style: _section),
              const SizedBox(height: 6),
              if (compact)
                Row(
                  children: [
                    Flexible(child: wheel),
                    const SizedBox(width: 12),
                    Expanded(child: interpretation),
                  ],
                )
              else ...[
                Center(child: wheel),
                const SizedBox(height: 6),
                interpretation,
              ],
            ],
          ),
        );
      }
      final complete = still || time >= 10.3;
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (still) ...[
            Row(
              children: [
                const _Chart(size: 64, index: 2, progress: 1),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    ru
                        ? 'Натальная карта: опора в знакомом ремесле'
                        : 'Birth chart: a familiar craft is my strength',
                    style: _body,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
          ],
          Text(ru ? 'Расклад Таро' : 'Tarot spread', style: _section),
          const SizedBox(height: 14),
          IntroStoryFocus(
            key: const ValueKey('intro-spread'),
            enabled: !complete,
            child: _Spread(time: time, still: still, ru: ru, compact: compact),
          ),
          if (complete)
            IntroStoryFocus(
              child: Padding(
                key: const ValueKey('intro-natal-tarot-result'),
                padding: EdgeInsets.only(top: compact ? 10 : 18, bottom: 5),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      ru ? 'Мой первый шаг' : 'My first step',
                      style: _section,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      ru
                          ? 'Я умею рисовать. Покажу один эскиз будущему клиенту и узнаю, что ему откликнется.'
                          : 'I know how to draw. I’ll show a sketch to a potential client and see what resonates.',
                      style: _body,
                    ),
                  ],
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
    return LayoutBuilder(
      builder: (context, bounds) {
        final width = math.min(
          compact ? 82.0 : 108.0,
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
                          label: time >= 7.32 + i * 1.15 || still
                              ? names[i]
                              : (ru ? 'Рубашка карты' : 'Card back'),
                          child: SizedBox(
                            key: ValueKey('intro-spread-turn-$i'),
                            width: width,
                            height: width * 1.5,
                            child: CardTurn(
                              progress: still
                                  ? 1
                                  : ((time - 6.9 - i * 1.15) / .85).clamp(
                                      0.0,
                                      1.0,
                                    ),
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
                    const SizedBox(height: 8),
                    Text(
                      roles[i],
                      style: AppTypography.text2.copyWith(
                        color: AppColors.textInverse,
                      ),
                      textAlign: TextAlign.center,
                    ),
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
