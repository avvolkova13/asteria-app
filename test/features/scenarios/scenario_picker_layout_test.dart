import 'package:asteria_app/core/localization/localization.dart';
import 'package:asteria_app/core/ui_kit/ui_kit.dart';
import 'package:asteria_app/features/scenarios/scenario_card_grid.dart';
import 'package:asteria_app/features/scenarios/scenario_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
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
        await tester.ensureVisible(find.text('Найти свою сильную сторону'));
        await tester.pumpAndSettle();
        expect(
          find.text('Найти свою сильную сторону').hitTestable(),
          findsOneWidget,
        );
      }
      final homeAction = find.text('На главную').hitTestable();
      expect(homeAction, findsOneWidget);
      expect(tester.widget<Text>(homeAction).style?.fontFamily, 'Lora');
      expect(tester.takeException(), isNull);
    });
  }
}
