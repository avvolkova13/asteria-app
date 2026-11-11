import 'package:asteria_app/core/ui_kit/theme/theme.dart';
import 'package:asteria_app/core/ui_kit/widgets/pearl_metric_row.dart';
import 'package:asteria_app/core/ui_kit/widgets/pearl_progress_ring_painter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  Future<void> show(
    WidgetTester tester, {
    bool reduced = false,
    double scale = 1,
  }) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) {
            return Theme(
              data: AppThemeDark.instance.getThemeData(context),
              child: MediaQuery(
                data: MediaQuery.of(context).copyWith(
                  disableAnimations: reduced,
                  textScaler: TextScaler.linear(scale),
                ),
                child: Scaffold(
                  body: SizedBox(
                    width: 320,
                    child: PearlMetricRow(
                      metrics: [
                        const PearlMetric(
                          'Огонь',
                          '0',
                          0,
                          paintKey: ValueKey('zero'),
                        ),
                        PearlMetric.percentage(
                          'Любовь',
                          '37,5%',
                          paintKey: const ValueKey('partial'),
                        ),
                        const PearlMetric(
                          'Земля',
                          '8',
                          1,
                          paintKey: ValueKey('full'),
                        ),
                        PearlMetric.percentage('Семья', '100%'),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  double arc(WidgetTester tester, String id) {
    final paint = tester.widget<CustomPaint>(find.byKey(ValueKey(id)));
    return (paint.painter as PearlProgressRingPainter).progress;
  }

  testWidgets(
    'animates to the reported score or percent, including empty and full rings',
    (tester) async {
      await show(tester);
      expect(arc(tester, 'partial'), 0);
      await tester.pump(const Duration(milliseconds: 250));
      expect(arc(tester, 'partial'), inExclusiveRange(0, .375));
      await tester.pumpAndSettle();
      expect(arc(tester, 'zero'), 0);
      expect(arc(tester, 'partial'), .375);
      expect(arc(tester, 'full'), 1);
      expect(
        tester.getCenter(find.text('0')).dy,
        tester.getCenter(find.text('8')).dy,
      );
      expect(find.text('37,5%'), findsOneWidget);
    },
  );

  testWidgets(
    'large type stacks the gauges and reduced motion shows final values immediately',
    (tester) async {
      await show(tester, reduced: true, scale: 2);
      expect(arc(tester, 'partial'), .375);
      expect(arc(tester, 'full'), 1);
      expect(
        tester.getCenter(find.text('Огонь')).dy,
        lessThan(tester.getCenter(find.text('Любовь')).dy),
      );
      expect(tester.takeException(), isNull);
    },
  );
}
