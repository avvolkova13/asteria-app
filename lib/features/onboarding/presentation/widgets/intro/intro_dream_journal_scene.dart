import 'dart:math' as math;

import 'package:asteria_app/core/ui_kit/ui_kit.dart';
import 'package:asteria_app/features/sonnik/presentation/widgets/sonnik_layout.dart';
import 'package:flutter/material.dart';

import 'intro_lighthouse.dart';
import 'intro_story.dart';

/// A journal page and its reader share the scene. Each keeps one speaking voice.
class IntroDreamJournalScene extends StatelessWidget {
  const IntroDreamJournalScene({
    super.key,
    required this.time,
    required this.still,
  });
  final double time;
  final bool still;

  static String transcript(BuildContext context) =>
      Localizations.localeOf(context).languageCode == 'ru'
      ? 'В тумане светил маяк. Внутри мама заваривала чай.'
      : 'A lighthouse shone through the fog. Inside, my mother was making tea.';

  @override
  Widget build(BuildContext context) {
    final ru = Localizations.localeOf(context).languageCode == 'ru';
    final compact = MediaQuery.sizeOf(context).height < 740;
    final saved = still || time >= 3.7;
    final reflection = still || time >= 8.1;
    final wish = still || time >= 10.6;
    final words = transcript(context).split(' ');
    final spoken = (words.length * ((time - .45) / 2.65).clamp(0.0, 1.0))
        .ceil();
    final thought = ru
        ? 'Я соскучилась по маме. Сегодня зайду к ней на чай.'
        : 'I miss my mother. I’ll stop by for tea today.';
    final String caption;
    if (reflection) {
      caption = ru ? 'Мысль из дневника снов' : 'From my dream journal';
    } else if (saved) {
      caption = ru ? 'Сон сохранён в дневнике' : 'Saved in your dream journal';
    } else {
      caption = ru ? 'Записываю сон' : 'Recording my dream';
    }
    final reading = compact || still
        ? (ru
              ? 'Возможно, свет маяка напомнил тебе о доме.'
              : 'Perhaps the light reminded you of home.')
        : (ru
              ? 'Может, свет в окне запомнился потому, что дома тебя ждали к чаю.'
              : 'Maybe that light felt like home because someone was waiting for you with tea.');
    final farewell = ru
        ? 'Пусть у вас будет время ещё на одну чашку.'
        : 'I hope you have time for a second cup.';
    final minimumSkyHeight = compact ? 64.0 : 120.0;
    final inset = compact ? 12.0 : 20.0;
    final quoteStyle = (compact ? AppTypography.h4 : AppTypography.h3).copyWith(
      color: AppColors.textInverse,
      height: 1.25,
    );

    final messageStyle = (compact ? AppTypography.text2 : AppTypography.text1)
        .copyWith(color: AppColors.textInverse, height: 1.3);
    return IntrinsicHeight(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: StoryEntrance(
              time: time,
              start: .16,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(18),
                child: ColoredBox(
                  color: AppColorsDark.homeCanvas,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Expanded(
                        child: Stack(
                          fit: StackFit.passthrough,
                          children: [
                            SizedBox(
                              height: minimumSkyHeight,
                              child: ClipRect(
                                child: FittedBox(
                                  fit: BoxFit.cover,
                                  alignment: const Alignment(.22, -.12),
                                  child: SizedBox(
                                    width: 380,
                                    height: 180,
                                    child: CustomPaint(
                                      painter: IntroLighthouse(
                                        time: still ? 3 : time,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            Positioned.fill(
                              child: DecoratedBox(
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    begin: Alignment.topCenter,
                                    end: Alignment.bottomCenter,
                                    colors: [
                                      AppColorsDark.homeCanvas.withValues(
                                        alpha: 0,
                                      ),
                                      AppColorsDark.homeCanvas,
                                    ],
                                    stops: const [.68, 1],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.fromLTRB(inset, 0, inset, inset),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                if (saved)
                                  const Icon(
                                    Icons.bookmark_added_outlined,
                                    size: 16,
                                    color: AppColorsDark.linkGold,
                                  )
                                else
                                  SizedBox(
                                    width: 24,
                                    height: 16,
                                    child: CustomPaint(painter: _Voice(time)),
                                  ),
                                const SizedBox(width: 6),
                                Flexible(
                                  child: Text(
                                    caption,
                                    key: ValueKey(
                                      saved
                                          ? 'intro-dream-saved'
                                          : 'intro-dream-dictation',
                                    ),
                                    style: AppTypography.text2.copyWith(
                                      color: AppColorsDark.linkGold,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: compact ? 5 : 8),
                            if (reflection)
                              StoryEntrance(
                                time: time,
                                start: 8.1,
                                child: Text(
                                  thought,
                                  key: const ValueKey('intro-dream-result'),
                                  style: quoteStyle,
                                ),
                              )
                            else
                              Opacity(
                                opacity: ((8.1 - time) / .25).clamp(0.0, 1.0),
                                child: Text.rich(
                                  key: const ValueKey('intro-dream-transcript'),
                                  TextSpan(
                                    children: [
                                      TextSpan(
                                        text: words.take(spoken).join(' '),
                                      ),
                                      if (spoken < words.length)
                                        TextSpan(
                                          text:
                                              ' ${words.skip(spoken).join(' ')}',
                                          style: const TextStyle(
                                            color: Colors.transparent,
                                          ),
                                        ),
                                    ],
                                  ),
                                  semanticsLabel: words.take(spoken).join(' '),
                                  style: quoteStyle,
                                ),
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          AnimatedSize(
            alignment: Alignment.bottomLeft,
            duration: still ? Duration.zero : const Duration(milliseconds: 320),
            curve: Curves.easeOutCubic,
            child: !still && time < 5
                ? const SizedBox.shrink()
                : Padding(
                    padding: EdgeInsets.only(top: compact ? 10 : 20),
                    child: StoryEntrance(
                      time: time,
                      start: 5,
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SonnikLiveyaAvatar(size: compact ? 36 : 52),
                          SizedBox(width: compact ? 10 : 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  ru ? 'Ливея' : 'Liveya',
                                  style: AppTypography.text2SemiBold.copyWith(
                                    color: AppColorsDark.textSecondary,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                if (!wish || still)
                                  Opacity(
                                    opacity: still
                                        ? 1
                                        : ((10.6 - time) / .25).clamp(0.0, 1.0),
                                    child: Text(
                                      reading,
                                      key: const ValueKey(
                                        'intro-dream-reading',
                                      ),
                                      style: messageStyle,
                                    ),
                                  ),
                                if (wish)
                                  StoryEntrance(
                                    time: time,
                                    start: 10.6,
                                    child: Text(
                                      farewell,
                                      key: const ValueKey('intro-dream-wish'),
                                      style: messageStyle,
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}

class _Voice extends CustomPainter {
  _Voice(this.time);
  final double time;
  @override
  void paint(Canvas canvas, Size size) {
    final pen = Paint()
      ..color = AppColorsDark.linkGold
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round;
    for (var i = 0; i < 7; i++) {
      final h =
          2 + (size.height / 2 - 2) * (.5 + .5 * math.sin(time * 9 + i * 1.8));
      final x = 2 + i * (size.width - 4) / 6;
      canvas.drawLine(
        Offset(x, size.height / 2 - h),
        Offset(x, size.height / 2 + h),
        pen,
      );
    }
  }

  @override
  bool shouldRepaint(_Voice old) => old.time != time;
}
