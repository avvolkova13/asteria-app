import 'package:asteria_app/core/localization/localization.dart';
import 'package:asteria_app/core/ui_kit/theme/theme.dart';
import 'package:asteria_app/features/home/presentation/widgets/card_advertisement_widget.dart';
import 'package:asteria_app/features/home/presentation/widgets/tarot_card_of_the_day_widget.dart';
import 'package:asteria_app/features/home/presentation/widgets/advertising_block_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';

Widget app(Widget child, {double scale = 1}) => MaterialApp(
  locale: const Locale('ru'),
  localizationsDelegates: const [
    AppLocalizations.delegate,
    ...GlobalMaterialLocalizations.delegates,
  ],
  supportedLocales: AppLocaleService.supportedLocales,
  builder: (context, child) => Theme(
    data: AppThemeDark.instance.getThemeData(context),
    child: MediaQuery(
      data: MediaQuery.of(
        context,
      ).copyWith(textScaler: TextScaler.linear(scale), disableAnimations: true),
      child: child!,
    ),
  ),
  home: Scaffold(body: SingleChildScrollView(child: child)),
);

void main() {
  for (final variant in [
    CardAdvertisementVariant.natalCardBanner,
    CardAdvertisementVariant.balanceSubscriptionBanner,
  ]) {
    testWidgets('$variant can activate its CTA through accessibility', (
      tester,
    ) async {
      final handle = tester.ensureSemantics();
      var taps = 0;
      await tester.pumpWidget(
        app(
          CardAdvertisementWidget(
            variant: variant,
            title: 'Asteria',
            description: 'Описание',
            buttonText: 'Открыть карту',
            onPressed: () => taps++,
          ),
        ),
      );
      await tester.pumpAndSettle();
      final node = tester.getSemantics(find.text('Открыть карту'));
      expect(node.getSemanticsData().hasAction(SemanticsAction.tap), isTrue);
      node.owner!.performAction(node.id, SemanticsAction.tap);
      await tester.pump();
      expect(taps, 1);
      handle.dispose();
    });
  }
  for (final dark in [false, true]) {
    testWidgets('daily tarot accessibility opens and refreshes in dark=$dark', (
      tester,
    ) async {
      final handle = tester.ensureSemantics();
      var opens = 0;
      var refreshes = 0;
      await tester.pumpWidget(
        app(
          TarotCardOfTheDayWidget(
            isDarkLayout: dark,
            showMoreButton: false,
            onCardTap: () => opens++,
            onRefresh: () => refreshes++,
          ),
        ),
      );
      await tester.pumpAndSettle();
      final context = tester.element(find.byType(TarotCardOfTheDayWidget));
      final l = AppLocalizations.of(context);
      for (final label in [l.dailyTarotFlipLabel, l.refreshDailyTarotLabel]) {
        final target = find.bySemanticsLabel(label);
        if (label == l.refreshDailyTarotLabel) {
          final size = tester.getSize(target);
          expect(size.width, greaterThanOrEqualTo(44));
          expect(size.height, greaterThanOrEqualTo(44));
        }
        final node = tester.getSemantics(target);
        expect(node.getSemanticsData().hasAction(SemanticsAction.tap), isTrue);
        node.owner!.performAction(node.id, SemanticsAction.tap);
      }
      await tester.pump();
      expect(opens, 1);
      expect(refreshes, 1);
      handle.dispose();
    });
  }
  testWidgets('dream banner respects large text without shrinking its CTA', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(320, 1400);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(app(const AdvertisingBlockWidget(), scale: 2));
    await tester.pumpAndSettle();
    final label = find.text('Расшифровать');
    expect(label, findsOneWidget);
    final paragraph = tester.renderObject<RenderParagraph>(
      find.descendant(of: label, matching: find.byType(RichText)),
    );
    expect(paragraph.didExceedMaxLines, isFalse);
    expect(
      find.ancestor(of: label, matching: find.byType(FittedBox)),
      findsNothing,
    );
    expect(tester.takeException(), isNull);
  });
}
