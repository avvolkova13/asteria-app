import 'package:asteria_app/features/onboarding/presentation/widgets/intro/onboarding_tour.dart';
import 'package:asteria_app/features/onboarding/presentation/widgets/onboarding_pagination_widget.dart';
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
      expect(find.byType(OnboardingTour), findsOneWidget);
      expect(
        tester
            .widget<OnboardingPaginationWidget>(
              find.byType(OnboardingPaginationWidget),
            )
            .currentPage,
        0,
      );
      expect(
        tester.widget<OnboardingTour>(find.byType(OnboardingTour)).pages.length,
        3,
      );
      await tester.tap(find.text('Пропустить'));
      await tester.pumpAndSettle();
      expect(find.text('Демонстрация завершена'), findsOneWidget);
      await tester.tap(find.text('Открыть онбординг'));
      await tester.pumpAndSettle();
      expect(find.byType(OnboardingTour), findsOneWidget);
      expect(
        tester
            .widget<OnboardingPaginationWidget>(
              find.byType(OnboardingPaginationWidget),
            )
            .currentPage,
        0,
      );
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox());
    },
  );
}
