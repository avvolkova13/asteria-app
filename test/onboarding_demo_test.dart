import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import '../tool/onboarding_demo.dart';

void main() {
  testWidgets(
    'demo starts without services and can open a fresh presentation',
    (tester) async {
      tester.platformDispatcher.accessibilityFeaturesTestValue =
          const FakeAccessibilityFeatures(disableAnimations: true);
      addTearDown(
        tester.platformDispatcher.clearAccessibilityFeaturesTestValue,
      );
      await tester.pumpWidget(const OnboardingDemoApp());
      await tester.pumpAndSettle();
      expect(find.text('Твой день'), findsOneWidget);
      await tester.tap(find.text('Пропустить'));
      await tester.pumpAndSettle();
      expect(find.text('Демонстрация завершена'), findsOneWidget);
      await tester.tap(find.text('Открыть онбординг'));
      await tester.pumpAndSettle();
      expect(find.text('Твой день'), findsOneWidget);
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox());
    },
  );
}
