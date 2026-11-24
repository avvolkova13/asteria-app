import 'package:asteria_app/features/onboarding/presentation/widgets/intro/intro_natal_tarot_story.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'intro_stories_test.dart' as fixture;

Finder _key(String value) => find.byKey(ValueKey(value));

void main() {
  testWidgets(
    'a planet tap selects its own reading and survives the automatic highlight',
    (tester) async {
      await fixture.host(tester, const IntroNatalTarotStory(active: true));
      expect(find.text('Луна в\u00a0Тельце'), findsOneWidget);
      await tester.tap(_key('natal-wheel-sun'));
      await tester.pump();
      expect(find.text('Солнце во\u00a0Льве'), findsOneWidget);
      expect(find.text('Что я хочу сделать по-своему?'), findsOneWidget);
      await tester.pump(const Duration(seconds: 3));
      expect(find.text('Солнце во\u00a0Льве'), findsOneWidget);
      await tester.tap(_key('natal-wheel-mars'));
      await tester.pump();
      expect(find.text('Марс в\u00a0Овне'), findsOneWidget);
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox());
    },
  );

  testWidgets(
    'each drawn card turns from its back to a localized face in order',
    (tester) async {
      await fixture.host(tester, const IntroNatalTarotStory(active: true));
      for (var i = 0; i < 3; i++) {
        expect(_key('intro-spread-back-$i'), findsOneWidget);
        expect(_key('intro-spread-front-$i'), findsNothing);
      }
      await tester.pump(const Duration(milliseconds: 6100));
      for (var i = 0; i < 3; i++) {
        if (i > 0) await tester.pump(const Duration(milliseconds: 1350));
        expect(_key('intro-spread-front-$i'), findsOneWidget);
        if (i < 2) expect(_key('intro-spread-back-${i + 1}'), findsOneWidget);
      }
      expect(_key('intro-natal-tarot-result'), findsOneWidget);
      await tester.pumpWidget(const SizedBox());
    },
  );

  testWidgets('cards can be turned in a different order before autoplay', (
    tester,
  ) async {
    await fixture.host(tester, const IntroNatalTarotStory(active: true));
    for (final i in [2, 0, 1]) {
      await tester.tap(_key('intro-spread-turn-$i'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 880));
      expect(_key('intro-spread-front-$i'), findsOneWidget);
    }
    expect(_key('intro-natal-tarot-result'), findsOneWidget);
    await tester.pumpWidget(const SizedBox());
  });

  testWidgets(
    'reduced motion exposes all cards and keeps planet selection usable',
    (tester) async {
      await fixture.host(
        tester,
        const IntroNatalTarotStory(active: true),
        reduced: true,
        textScale: 2,
      );
      for (var i = 0; i < 3; i++) {
        expect(_key('intro-spread-front-$i'), findsOneWidget);
      }
      expect(_key('intro-natal-tarot-result'), findsOneWidget);
      await tester.tap(_key('natal-wheel-sun'));
      await tester.pump();
      expect(find.text('Солнце во\u00a0Льве'), findsOneWidget);
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox());
    },
  );
}
