import 'package:asteria_app/features/onboarding/presentation/widgets/intro/intro_stories.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'intro_stories_test.dart' as fixture;

void main() {
  testWidgets(
    'pair gives each speaker a separate avatar and retains final prompt for 14 seconds',
    (tester) async {
      await fixture.host(tester, const IntroPairStory(active: true));
      await tester.pump(const Duration(seconds: 4));
      expect(
        find.byKey(const ValueKey('intro-pair-man-speech')),
        findsOneWidget,
      );
      expect(
        find.byKey(const ValueKey('intro-pair-woman-speech')),
        findsNothing,
      );
      await tester.pump(const Duration(seconds: 3));
      expect(find.byKey(const ValueKey('intro-pair-man-speech')), findsNothing);
      expect(
        find.byKey(const ValueKey('intro-pair-woman-speech')),
        findsOneWidget,
      );
      await tester.pump(const Duration(seconds: 5));
      expect(
        find.byKey(const ValueKey('intro-pair-woman-speech')),
        findsNothing,
      );
      expect(find.byKey(const ValueKey('intro-pair-insight')), findsOneWidget);
      final paths = tester
          .widgetList<Image>(find.byType(Image))
          .map(
            (image) =>
                ((image.image is ResizeImage
                            ? (image.image as ResizeImage).imageProvider
                            : image.image)
                        as AssetImage)
                    .assetName,
          );
      expect(
        paths,
        containsAll([
          'assets/images/onboarding/intro_pair_man.png',
          'assets/images/onboarding/intro_pair_woman.png',
        ]),
      );
      await tester.pumpWidget(const SizedBox());
    },
  );

  testWidgets('tarot has only problem, cards, and one late Anakra advice', (
    tester,
  ) async {
    await fixture.host(tester, const IntroTarotStory(active: true));
    await tester.pump(const Duration(seconds: 5));
    expect(find.byKey(const ValueKey('intro-tarot-insight')), findsNothing);
    expect(find.byKey(const ValueKey('intro-tarot-meaning')), findsNothing);
    expect(
      find.byKey(const ValueKey('intro-tarot-conversation')),
      findsNothing,
    );
    await tester.pump(const Duration(seconds: 7));
    expect(find.byKey(const ValueKey('intro-tarot-insight')), findsOneWidget);
    expect(find.byKey(const ValueKey('intro-card-1-front')), findsOneWidget);
    expect(find.byKey(const ValueKey('intro-tarot-meaning')), findsNothing);
    expect(
      find.byKey(const ValueKey('intro-tarot-conversation')),
      findsNothing,
    );
    await tester.pumpWidget(const SizedBox());
  });
}
