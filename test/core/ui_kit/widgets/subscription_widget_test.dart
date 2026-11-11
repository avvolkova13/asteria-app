import 'package:asteria_app/core/ui_kit/ui_kit.dart';
import 'package:asteria_app/core/ui_kit/widgets/subscription_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('keeps the compact PRO badge usable without a user provider', (
    tester,
  ) async {
    var taps = 0;
    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) {
            return Theme(
              data: AppThemeDark.instance.getThemeData(context),
              child: Scaffold(
                body: Center(child: SubscriptionWidget(onTap: () => taps++)),
              ),
            );
          },
        ),
      ),
    );

    final badgeFinder = find.byType(SubscriptionWidget);
    expect(badgeFinder, findsOneWidget);
    expect(tester.getSize(badgeFinder), const Size(76, 28));
    expect(find.text('PRO'), findsOneWidget);
    expect(find.byType(SvgPicture), findsNothing);

    await tester.tap(badgeFinder);
    expect(taps, 1);

    final label = tester.widget<Text>(find.text('PRO'));
    expect(label.style?.fontFamily, 'Lora');
    expect(label.style?.fontSize, 17);
    expect(label.style?.fontWeight, FontWeight.w600);
    expect(label.style?.color, Colors.white);
    expect(tester.takeException(), isNull);
  });
}
