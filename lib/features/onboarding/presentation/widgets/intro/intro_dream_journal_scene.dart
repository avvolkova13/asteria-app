import 'dart:math' as math;

import 'package:asteria_app/core/ui_kit/ui_kit.dart';
import 'package:flutter/material.dart';

import 'intro_lighthouse.dart';
import 'intro_story.dart';

/// Dictation is illustrated locally, without opening the microphone or diary.
class IntroDreamJournalScene extends StatelessWidget {
  const IntroDreamJournalScene({
    super.key,
    required this.time,
    required this.still,
  });
  final double time;
  final bool still;

  @override
  Widget build(BuildContext context) {
    final ru = Localizations.localeOf(context).languageCode == 'ru';
    final compact = MediaQuery.sizeOf(context).height < 650;
    final saved = still || time >= 3.7;
    final words =
        (ru
                ? 'В тумане светил маяк. Я шла на свет.'
                : 'A lighthouse shone through the fog. I followed its light.')
            .split(' ');
    final spoken = still
        ? words.length
        : (words.length * ((time - .45) / 2.65).clamp(0.0, 1.0)).ceil();
    final reply = still
        ? 1.0
        : Curves.easeOut.transform(((time - 5.0) / .7).clamp(0.0, 1.0));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(18),
          child: SizedBox(
            height: compact ? 108 : 170,
            child: CustomPaint(
              painter: IntroLighthouse(time: still ? 3 : time),
            ),
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            if (saved)
              const Icon(
                Icons.bookmark_added_outlined,
                color: AppColorsDark.linkGold,
                size: 18,
              )
            else
              SizedBox(
                width: 27,
                height: 16,
                child: CustomPaint(painter: _Voice(time)),
              ),
            const SizedBox(width: 7),
            Expanded(
              child: Text(
                saved
                    ? (ru
                          ? 'Сон сохранён в дневнике'
                          : 'Saved in your dream journal')
                    : (ru ? 'Надиктованный сон' : 'A dictated dream'),
                key: ValueKey(
                  saved ? 'intro-dream-saved' : 'intro-dream-dictation',
                ),
                style: AppTypography.text2SemiBold.copyWith(
                  color: AppColorsDark.linkGold,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 5),
        // Reserve the whole sentence so the next line stays in place while
        // words arrive from the illustrated recording.
        IntroStoryFocus(
          enabled: compact && time >= 2.5 && reply == 0,
          child: Padding(
            padding: EdgeInsets.only(bottom: compact && reply == 0 ? 12 : 0),
            child: Text.rich(
              TextSpan(
                children: [
                  TextSpan(text: words.take(spoken).join(' ')),
                  if (spoken < words.length)
                    TextSpan(
                      text: ' ${words.skip(spoken).join(' ')}',
                      style: const TextStyle(color: Colors.transparent),
                    ),
                ],
              ),
              key: const ValueKey('intro-dream-transcript'),
              semanticsLabel: words.join(' '),
              style: AppTypography.h3.copyWith(
                color: AppColors.textInverse,
                height: 1.22,
              ),
            ),
          ),
        ),
        if (reply > 0)
          IntroStoryFocus(
            child: Opacity(
              opacity: reply,
              child: Padding(
                padding: EdgeInsets.only(top: compact ? 10 : 19),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Image.asset(
                      'assets/images/sonnik/liveya_character.webp',
                      width: compact ? 42 : 57,
                      height: compact ? 54 : 71,
                      fit: BoxFit.contain,
                      excludeFromSemantics: true,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            ru ? 'Разбор с Ливеей' : 'Liveya’s reading',
                            style: AppTypography.text2SemiBold.copyWith(
                              color: AppColorsDark.linkGold,
                            ),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            ru
                                ? 'Даже в тумане был виден свет. Кто помогает тебе держать курс?'
                                : 'Even in the fog, you could see a light. Who helps you stay on course?',
                            key: const ValueKey('intro-dream-result'),
                            style: AppTypography.text1.copyWith(
                              color: AppColors.textInverse,
                              height: 1.32,
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
