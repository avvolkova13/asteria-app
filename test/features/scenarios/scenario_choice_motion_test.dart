import 'package:asteria_app/core/ui_kit/widgets/lotus_raster_icon.dart';
import 'package:asteria_app/features/scenarios/scenario_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets(
    'choice artwork rests between passes and stops for reduced motion or a hidden route',
    (tester) async {
      var taps = 0;
      Widget screen({bool reduced = false, bool visible = true}) => MaterialApp(
        home: MediaQuery(
          data: MediaQueryData(disableAnimations: reduced),
          child: TickerMode(
            enabled: visible,
            child: Scaffold(
              body: Center(
                child: SizedBox(
                  width: 170,
                  child: ScenarioChoiceCard(
                    title: 'A choice',
                    art: 'assets/images/scenarios/lotus.webp',
                    onTap: () => taps++,
                  ),
                ),
              ),
            ),
          ),
        ),
      );

      final art = find.byType(LotusRasterIcon);
      await tester.pumpWidget(screen());
      await tester.pumpAndSettle();
      final rest = tester.getCenter(art);
      expect(tester.hasRunningAnimations, isFalse);
      await tester.pump(const Duration(seconds: 6));
      await tester.pump(const Duration(milliseconds: 1800));
      expect((tester.getCenter(art) - rest).distance, greaterThan(.5));

      for (final disabled in [screen(reduced: true), screen(visible: false)]) {
        await tester.pumpWidget(disabled);
        final stationary = tester.getCenter(art);
        await tester.pump(const Duration(seconds: 18));
        await tester.pump(const Duration(seconds: 2));
        expect(tester.getCenter(art), stationary);
        expect(tester.hasRunningAnimations, isFalse);
      }
      await tester.pumpWidget(screen(reduced: true));
      await tester.tap(find.text('A choice'));
      expect(taps, 1);
      await tester.pumpWidget(screen());
      await tester.pumpWidget(const SizedBox());
      await tester.pump(const Duration(seconds: 20));
      expect(tester.takeException(), isNull);
    },
  );
}
