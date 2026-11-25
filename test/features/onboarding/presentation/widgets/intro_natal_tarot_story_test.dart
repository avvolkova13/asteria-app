import 'package:asteria_app/features/onboarding/presentation/widgets/intro/intro_natal_tarot_story.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'intro_stories_test.dart' as fixture;

Finder _key(String value) => find.byKey(ValueKey(value));

void main() {
  testWidgets('wheel spotlights three aspects before the spread arrives', (
    tester,
  ) async {
    await fixture.host(tester, const IntroNatalTarotStory(active: true));
    await tester.pump(const Duration(milliseconds: 600));
    for (var i = 0; i < 3; i++) {
      if (i != 0) await tester.pump(const Duration(milliseconds: 1700));
      expect(_key('intro-chart-wheel'), findsOneWidget);
      expect(_key('intro-aspect-$i'), findsOneWidget);
      expect(_key('intro-spread'), findsNothing);
    }
    await tester.pump(const Duration(milliseconds: 2100));
    expect(_key('intro-chart-wheel'), findsOneWidget);
    expect(
      tester.getBottomLeft(_key('intro-chart-wheel')).dy,
      lessThan(tester.getTopLeft(_key('intro-spread')).dy),
    );
    const roles = ['Замысел', 'Ресурс', 'Первый шаг'];
    for (var i = 0; i < 3; i++) {
      expect(_key('intro-spread-back-$i'), findsOneWidget);
      expect(_key('intro-spread-front-$i'), findsNothing);
      expect(find.text(roles[i]), findsNothing);
    }
    expect(_key('intro-natal-tarot-result'), findsNothing);
    await tester.pumpWidget(const SizedBox());
  });

  testWidgets(
    'each card turns in order and the insight follows the last turn',
    (tester) async {
      await fixture.host(tester, const IntroNatalTarotStory(active: true));
      await tester.pump(const Duration(milliseconds: 7700));
      for (var i = 0; i < 3; i++) {
        if (i > 0) await tester.pump(const Duration(milliseconds: 1150));
        expect(_key('intro-spread-front-$i'), findsOneWidget);
        const roles = ['Замысел', 'Ресурс', 'Первый шаг'];
        expect(find.text(roles[i]), findsOneWidget);
        if (i < 2) {
          expect(_key('intro-spread-back-${i + 1}'), findsOneWidget);
          expect(find.text(roles[i + 1]), findsNothing);
        }
        expect(_key('intro-natal-tarot-result'), findsNothing);
      }
      await tester.pump(const Duration(milliseconds: 600));
      expect(_key('intro-natal-tarot-result'), findsOneWidget);
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox());
    },
  );

  testWidgets('tapping the displayed artwork does not alter the timeline', (
    tester,
  ) async {
    await fixture.host(tester, const IntroNatalTarotStory(active: true));
    await tester.pump(const Duration(milliseconds: 1400));
    await tester.tap(_key('intro-chart-wheel'));
    await tester.pump();
    expect(_key('intro-aspect-0'), findsOneWidget);
    await tester.pump(const Duration(milliseconds: 4800));
    await tester.tap(_key('intro-spread-turn-2'));
    await tester.pump();
    expect(_key('intro-spread-back-2'), findsOneWidget);
    expect(_key('intro-natal-tarot-result'), findsNothing);
    await tester.pumpWidget(const SizedBox());
  });

  testWidgets(
    'reduced motion exposes a static birth chart, spread and combined insight',
    (tester) async {
      await fixture.host(
        tester,
        const IntroNatalTarotStory(active: true),
        reduced: true,
        textScale: 2,
      );
      expect(_key('intro-chart-wheel'), findsOneWidget);
      expect(_key('intro-natal-tarot-result'), findsOneWidget);
      for (var i = 0; i < 3; i++) {
        expect(_key('intro-spread-front-$i'), findsOneWidget);
      }
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox());
    },
  );
}
