import 'package:asteria_app/core/ui_kit/ui_kit.dart';
import 'package:asteria_app/core/ui_kit/widgets/subscription_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('renders the Figma PRO badge without a user provider', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) {
            return Theme(
              data: AppThemeDark.instance.getThemeData(context),
              child: const Scaffold(body: Center(child: SubscriptionWidget())),
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

    final container = tester.widget<Container>(find.byType(Container).last);
    final decoration = container.decoration! as BoxDecoration;
    final gradient = decoration.gradient! as LinearGradient;

    expect(
      container.padding,
      const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
    );
    expect(decoration.borderRadius, BorderRadius.circular(100));
    expect(gradient.begin, Alignment.centerLeft);
    expect(gradient.end, Alignment.centerRight);
    expect(gradient.colors, const [
      Color(0xFFF3B76A),
      Color(0xFF8A6BFF),
      Color(0xFF5A3FD1),
    ]);
    expect(gradient.stops, const [0, 0.50032, 1]);

    final label = tester.widget<Text>(find.text('PRO'));
    expect(label.style?.fontFamily, 'PlayfairDisplay');
    expect(label.style?.fontSize, 17);
    expect(label.style?.fontWeight, FontWeight.w600);
    expect(label.style?.color, Colors.white);
    expect(tester.takeException(), isNull);
  });
}
