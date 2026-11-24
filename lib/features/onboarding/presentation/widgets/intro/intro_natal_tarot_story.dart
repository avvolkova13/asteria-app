import 'dart:math' as math;

import 'package:asteria_app/app/data/models/user/user_model.dart';
import 'package:asteria_app/core/ui_kit/ui_kit.dart';
import 'package:asteria_app/core/ui_kit/widgets/card_turn.dart';
import 'package:asteria_app/core/ui_kit/widgets/tarot_card_frame.dart';
import 'package:asteria_app/features/natal_card/widgets/natal_wheel.dart';
import 'package:flutter/material.dart';

import 'intro_story.dart';

class IntroNatalTarotStory extends StatefulWidget {
  const IntroNatalTarotStory({super.key, required this.active});
  final bool active;

  @override
  State<IntroNatalTarotStory> createState() => _IntroNatalTarotStoryState();
}

class _IntroNatalTarotStoryState extends State<IntroNatalTarotStory> {
  String? _chosenPlanet;
  final Set<int> _turned = {};
  int? _inspected;

  @override
  void didUpdateWidget(IntroNatalTarotStory oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.active != oldWidget.active) {
      _chosenPlanet = null;
      _turned.clear();
      _inspected = null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final ru = Localizations.localeOf(context).languageCode == 'ru';
    final names = ru
        ? const ['Звезда', 'Маг', 'Паж пентаклей']
        : const ['The Star', 'The Magician', 'Page of Pentacles'];
    final roles = ru
        ? const ['Замысел', 'Ресурс', 'Первый шаг']
        : const ['The idea', 'Resources', 'First step'];
    final readings = ru
        ? const [
            'Звезда · Мне всё ещё интересно рисовать.',
            'Маг · Карандаш и\u00a0альбом уже под\u00a0рукой.',
            'Паж пентаклей · Пора проверить замысел на\u00a0деле.',
          ]
        : const [
            'The Star · I keep coming back to drawing.',
            'The Magician · I already have a pencil and a sketchbook.',
            'Page of Pentacles · I can try the idea on a small scale.',
          ];
    final gold = AppTypography.text2SemiBold.copyWith(
      color: AppColorsDark.linkGold,
    );
    final body = AppTypography.text1.copyWith(color: AppColors.textInverse);
    final compact = MediaQuery.sizeOf(context).height < 650;

    return IntroStory(
      active: widget.active,
      duration: const Duration(seconds: 14),
      builder: (context, time, still, _) {
        final planet = _chosenPlanet ?? (time < 2.5 || still ? 'moon' : 'mars');
        final (placement, interpretation) = switch (planet) {
          'sun' =>
            ru
                ? ('Солнце во\u00a0Льве', 'Что я хочу сделать по-своему?')
                : ('Sun in Leo', 'What do I want to do my own way?'),
          'mercury' =>
            ru
                ? (
                    'Меркурий в\u00a0Весах',
                    'Разговор помогает мне уточнить замысел.',
                  )
                : (
                    'Mercury in Libra',
                    'Talking it through helps me refine the idea.',
                  ),
          'jupiter' =>
            ru
                ? (
                    'Юпитер в\u00a0Скорпионе',
                    'Мне интересно исследовать одну тему глубже.',
                  )
                : (
                    'Jupiter in Scorpio',
                    'I like exploring one subject in depth.',
                  ),
          'mars' =>
            ru
                ? (
                    'Марс в\u00a0Овне',
                    'Мне легче начать с\u00a0маленькой пробы.',
                  )
                : (
                    'Mars in Aries',
                    'A small experiment feels easier to start.',
                  ),
          _ =>
            ru
                ? ('Луна в\u00a0Тельце', 'Опора для меня — знакомое ремесло.')
                : ('Moon in Taurus', 'A familiar craft gives me solid ground.'),
        };
        final progress = List<double>.generate(
          3,
          (i) => still ? 1 : ((time - 5.25 - 1.35 * i) / .85).clamp(0.0, 1.0),
        );
        final visible = [
          for (var i = 0; i < 3; i++)
            if (_turned.contains(i) || progress[i] >= .5) i,
        ];
        final complete = visible.length == 3;
        final reading = _inspected ?? visible.lastOrNull;
        final chartSize = compact
            ? 136.0
            : still
            ? 150.0
            : 170.0;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(context.l10n.natalChartTitle, style: gold),
            Row(
              children: [
                SizedBox(
                  width: chartSize,
                  child: MediaQuery(
                    data: MediaQuery.of(
                      context,
                    ).copyWith(disableAnimations: still || !widget.active),
                    child: NatalWheel(
                      data: _exampleChart,
                      hasKnownBirthTime: false,
                      selectedPlanet: planet,
                      onSelectionChanged: (code) {
                        if (code != null) setState(() => _chosenPlanet = code);
                      },
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        placement,
                        style: AppTypography.h3.copyWith(
                          color: AppColors.textInverse,
                        ),
                      ),
                      const SizedBox(height: 5),
                      Text(interpretation, style: body),
                      const SizedBox(height: 10),
                      Text(
                        ru ? 'Коснись планеты' : 'Tap a planet',
                        style: gold,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(ru ? 'Расклад Таро' : 'Tarot spread', style: gold),
            const SizedBox(height: 12),
            IntroStoryFocus(
              enabled: !still && time >= 4 && !complete,
              child: LayoutBuilder(
                builder: (context, bounds) {
                  final width = math.min(
                    compact
                        ? 70.0
                        : still
                        ? 75.0
                        : 84.0,
                    (bounds.maxWidth - 24) / 3,
                  );
                  final deal = still
                      ? 1.0
                      : Curves.easeOutCubic.transform(
                          ((time - 3.5) / 1.1).clamp(0.0, 1.0),
                        );
                  return Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      for (var i = 0; i < 3; i++)
                        Expanded(
                          child: Column(
                            children: [
                              Transform.translate(
                                offset: Offset(
                                  (1 - i) *
                                      (1 - deal) *
                                      (bounds.maxWidth / 3 - width * .72),
                                  0,
                                ),
                                child: Transform.rotate(
                                  angle: (i - 1) * .09 * (1 - deal),
                                  child: _StoryTarotCard(
                                    index: i,
                                    width: width,
                                    language: ru ? 'ru' : 'en',
                                    name: names[i],
                                    role: roles[i],
                                    progress: progress[i],
                                    turned: _turned.contains(i),
                                    still: still,
                                    onTap: () => setState(() {
                                      _turned.add(i);
                                      _inspected = i;
                                    }),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                roles[i],
                                textAlign: TextAlign.center,
                                style: AppTypography.text2.copyWith(
                                  color: AppColors.textInverse,
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  );
                },
              ),
            ),
            const SizedBox(height: 12),
            if (complete)
              IntroStoryFocus(
                child: Column(
                  key: const ValueKey('intro-natal-tarot-result'),
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(ru ? 'Мой первый шаг' : 'My first step', style: gold),
                    const SizedBox(height: 3),
                    Text(
                      ru
                          ? 'Сегодня покажу один эскиз человеку, для\u00a0которого рисую.'
                          : 'Today I’ll show one sketch to someone I’m drawing for.',
                      style: body,
                    ),
                  ],
                ),
              ),
            if (_inspected != null || !complete)
              Padding(
                padding: EdgeInsets.only(top: complete ? 8 : 0),
                child: Text(
                  reading == null
                      ? (ru ? 'Открой любую карту' : 'Turn over a card')
                      : readings[reading],
                  style: reading == null ? gold : body,
                ),
              ),
          ],
        );
      },
    );
  }
}

// Illustrative birth chart: stable sample coordinates, no user profile required.
final _exampleChart = PlanetsHousesDataModel(
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

class _StoryTarotCard extends StatelessWidget {
  const _StoryTarotCard({
    required this.index,
    required this.width,
    required this.language,
    required this.name,
    required this.role,
    required this.progress,
    required this.turned,
    required this.still,
    required this.onTap,
  });
  final int index;
  final double width, progress;
  final String language, name, role;
  final bool turned, still;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    const faces = ['the_star', 'the_magician', 'page_of_pentacles'];
    final directory = language == 'ru'
        ? 'assets/images/cards'
        : 'assets/images/cards/en';
    final front = turned || progress >= .5;
    return Semantics(
      label: front
          ? '$role · $name'
          : (language == 'ru' ? 'Открыть карту: $role' : 'Reveal card: $role'),
      button: true,
      child: InkWell(
        key: ValueKey('intro-spread-turn-$index'),
        onTap: onTap,
        borderRadius: BorderRadius.circular(9),
        child: SizedBox(
          width: width,
          height: width * 1.5,
          child: TweenAnimationBuilder<double>(
            tween: Tween<double>(begin: 0, end: turned ? 1 : 0),
            duration: still ? Duration.zero : CardTurn.duration,
            builder: (context, tapProgress, _) => CardTurn(
              progress: math.max(progress, tapProgress),
              back: _face(
                'assets/images/home/daily_symbol_tarot_back.webp',
                'back',
              ),
              front: _face('$directory/${faces[index]}.webp', 'front'),
            ),
          ),
        ),
      ),
    );
  }

  Widget _face(String path, String side) => TarotCardFrame(
    radius: 8,
    child: Image.asset(
      path,
      key: ValueKey('intro-spread-$side-$index'),
      fit: BoxFit.cover,
      cacheWidth: 256,
      excludeFromSemantics: true,
    ),
  );
}
