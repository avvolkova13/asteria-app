import 'package:asteria_app/core/ui_kit/widgets/asteria_activity_indicator.dart';
import 'package:asteria_app/core/ui_kit/widgets/custom_button.dart';
import 'package:asteria_app/core/ui_kit/theme/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets(
    'compact and linear loaders fit their slots and respect Reduce Motion',
    (tester) async {
      Widget content(bool reduced) => MaterialApp(
        home: MediaQuery(
          data: MediaQueryData(disableAnimations: reduced),
          child: const Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox.square(
                  dimension: 16,
                  child: AsteriaActivityIndicator(),
                ),
                SizedBox(width: 100, child: AsteriaLoadingLine(minHeight: 2)),
              ],
            ),
          ),
        ),
      );
      await tester.pumpWidget(content(false));
      await tester.pump(const Duration(milliseconds: 300));
      expect(tester.binding.transientCallbackCount, greaterThan(0));
      await tester.pumpWidget(content(true));
      await tester.pump();
      expect(tester.binding.transientCallbackCount, 0);
      expect(
        tester.getSize(find.byType(AsteriaActivityIndicator)),
        const Size.square(16),
      );
      expect(
        tester.getSize(find.byType(AsteriaLoadingLine)),
        const Size(100, 2),
      );
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('busy button keeps its bounds and ignores repeated taps', (
    tester,
  ) async {
    var calls = 0;
    Widget view(bool loading) => MaterialApp(
      home: Builder(
        builder: (context) => Theme(
          data: AppThemeDark.instance.getThemeData(context),
          child: Scaffold(
            body: Center(
              child: CustomButton(
                text: 'Продолжить',
                width: 200,
                isLoading: loading,
                onPressed: () => calls++,
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pumpWidget(view(false));
    final size = tester.getSize(find.byType(CustomButton));
    await tester.pumpWidget(view(true));
    expect(tester.getSize(find.byType(CustomButton)), size);
    await tester.tap(find.byType(CustomButton));
    expect(calls, 0);
    await tester.pumpWidget(view(false));
    await tester.tap(find.byType(CustomButton));
    expect(calls, 1);
  });
}
