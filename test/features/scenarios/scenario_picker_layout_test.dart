import 'package:asteria_app/core/localization/localization.dart';
import 'package:asteria_app/core/ui_kit/ui_kit.dart';
import 'package:asteria_app/core/ui_kit/widgets/asteria_entrance.dart';
import 'package:asteria_app/features/scenarios/scenario_card_grid.dart';
import 'package:asteria_app/features/scenarios/scenario_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('the rim moves one card at a time and respects reduced motion', (
    tester,
  ) async {
    final grid = ScenarioCardGrid(
      cards: [
        for (final mood in ScenarioMood.values)
          ScenarioCard(
            mood: mood,
            title: mood.name,
            subtitle: '',
            onTap: () {},
            art: 'assets/images/scenarios/lotus.webp',
          ),
      ],
    );
    Widget screen({bool reduced = false}) => MaterialApp(
      home: MediaQuery(
        data: MediaQueryData(disableAnimations: reduced),
        child: Scaffold(body: SingleChildScrollView(child: grid)),
      ),
    );
    List<ScenarioMood> lit() => [
      for (final mood in ScenarioMood.values)
        if (find
            .descendant(
              of: find.byWidgetPredicate(
                (w) => w is ScenarioCard && w.mood == mood,
              ),
              matching: find.byWidgetPredicate(
                (w) => w is CustomPaint && w.foregroundPainter != null,
              ),
            )
            .evaluate()
            .isNotEmpty)
          mood,
    ];

    await tester.pumpWidget(screen());
    expect(lit(), isEmpty);
    for (final mood in ScenarioMood.values) {
      await tester.pump(const Duration(milliseconds: 1100));
      await tester.pump(const Duration(milliseconds: 1400));
      expect(lit(), [mood]);
      await tester.pump(const Duration(milliseconds: 1450));
      expect(lit(), isEmpty);
    }
    await tester.pump(const Duration(milliseconds: 1100));
    expect(lit(), [ScenarioMood.calendar]);
    await tester.pumpWidget(screen(reduced: true));
    expect(lit(), isEmpty);
    await tester.pump(const Duration(milliseconds: 3900));
    expect(lit(), isEmpty);
  });

  for (final (width, scale) in [(375.0, 1.0), (390.0, 1.25), (375.0, 2.0)]) {
    testWidgets('Russian picker at ${width}pt with text scale $scale', (
      tester,
    ) async {
      tester.view.devicePixelRatio = 1;
      tester.view.physicalSize = Size(width, 812);
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      await tester.pumpWidget(
        MaterialApp(
          locale: const Locale('ru'),
          supportedLocales: AppLocaleService.supportedLocales,
          localizationsDelegates: const [
            AppLocalizations.delegate,
            ...GlobalMaterialLocalizations.delegates,
          ],
          builder: (context, child) => MediaQuery(
            data: MediaQuery.of(
              context,
            ).copyWith(textScaler: TextScaler.linear(scale)),
            child: Theme(
              data: AppThemeDark.instance.getThemeData(context),
              child: child!,
            ),
          ),
          home: const ScenarioPicker(),
        ),
      );
      await tester.pumpAndSettle();
      final cards = find.byType(ScenarioCard);
      expect(cards, findsNWidgets(4));
      final entrances = cards.evaluate().map(
        (element) => element.findAncestorWidgetOfExactType<AsteriaEntrance>(),
      );
      expect(entrances, isNot(contains(null)));
      expect(entrances.toSet(), hasLength(4));
      // A common outer entrance would consume the four individual reveals.
      expect(
        find.ancestor(
          of: find.byType(ScenarioCardGrid),
          matching: find.byType(AsteriaEntrance),
        ),
        findsNothing,
      );
      final boxes = [
        for (final mood in ScenarioMood.values)
          tester.getRect(
            find.byWidgetPredicate((w) => w is ScenarioCard && w.mood == mood),
          ),
      ];
      if (scale < 2) {
        expect(boxes[0].top, boxes[1].top);
        expect(boxes[0].height, greaterThan(boxes[1].height));
        expect(boxes[2].bottom, closeTo(boxes[3].bottom, .01));
      } else {
        expect(boxes.map((r) => r.left).toSet(), hasLength(1));
        final fourthCard = find.byWidgetPredicate(
          (w) => w is ScenarioCard && w.mood == ScenarioMood.strength,
        );
        final title = find.descendant(
          of: fourthCard,
          matching: find.text(
            AppLocalizations.of(
              tester.element(fourthCard),
            ).scenarioStrengthTitle,
          ),
        );
        await tester.ensureVisible(title);
        await tester.pumpAndSettle();
        expect(title.hitTestable(), findsOneWidget);
        final cardBounds = tester.getRect(fourthCard);
        final titleBounds = tester.getRect(title);
        expect(cardBounds.contains(titleBounds.topLeft), isTrue);
        expect(cardBounds.contains(titleBounds.bottomRight), isTrue);
      }
      final homeAction = find.text('На главную').hitTestable();
      expect(homeAction, findsOneWidget);
      expect(tester.widget<Text>(homeAction).style?.fontFamily, 'Lora');
      expect(tester.takeException(), isNull);
    });
  }
}
