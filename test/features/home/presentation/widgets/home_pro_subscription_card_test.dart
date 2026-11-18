import 'package:asteria_app/core/localization/localization.dart';
import 'package:asteria_app/core/ui_kit/theme/theme.dart';
import 'package:asteria_app/core/ui_kit/widgets/asteria_action_button.dart';
import 'package:asteria_app/features/home/presentation/widgets/home_pro_subscription_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUpAll(() async {
    for (final family in ['Lora', 'Onest']) {
      final loader = FontLoader(family)
        ..addFont(
          rootBundle.load(
            'assets/fonts/${family.toLowerCase()}/$family-VariableFont_wght.ttf',
          ),
        );
      await loader.load();
    }
  });

  testWidgets('renders the home PRO subscription promo and handles CTA', (
    tester,
  ) async {
    var tapCount = 0;
    await tester.binding.setSurfaceSize(const Size(390, 720));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      _testApp(
        HomeProSubscriptionCard(onPressed: () => tapCount++),
        width: 390,
      ),
    );

    expect(find.byKey(const ValueKey('home-pro-subscription-card')), findsOne);
    expect(find.text('Больше знаков\nот звёзд'), findsOneWidget);
    expect(
      find.text(
        'Полный доступ к соннику, Таро, AI-астрологу и лунному календарю',
      ),
      findsOneWidget,
    );
    expect(find.text('Подключить PRO'), findsOneWidget);
    expect(find.text('Попробовать 7 дней бесплатно'), findsNothing);
    expect(find.byType(Image), findsOneWidget);

    await tester.tap(find.text('Подключить PRO'));
    await tester.pump();

    expect(tapCount, 1);
    expect(tester.takeException(), isNull);
  });

  testWidgets('keeps the promo stable on a narrow screen with larger text', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(320, 720));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      _testApp(
        HomeProSubscriptionCard(onPressed: () {}),
        width: 320,
        textScaler: const TextScaler.linear(1.3),
      ),
    );

    final cardSize = tester.getSize(
      find.byKey(const ValueKey('home-pro-subscription-card')),
    );
    expect(cardSize.height, greaterThanOrEqualTo(276));
    expect(find.text('Подключить PRO'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('compact home promo matches the design and grows with text', (
    tester,
  ) async {
    var taps = 0;
    final promo = HomeProSubscriptionCard(
      compactHome: true,
      onPressed: () => taps++,
    );
    final card = find.byKey(const ValueKey('home-pro-subscription-card'));
    await tester.pumpWidget(_testApp(promo, width: 390));
    expect(tester.getSize(card).height, closeTo(205, 2));
    expect(find.text('Подключить PRO'), findsOneWidget);
    expect(find.text('Попробовать 7 дней бесплатно'), findsNothing);
    expect(tester.getSize(find.byType(Image)), const Size(99, 115));
    final button = find.byType(AsteriaActionButton);
    expect(tester.getSize(button).height, greaterThanOrEqualTo(50));
    expect(tester.widget<AsteriaActionButton>(button).gold, isTrue);
    await tester.tapAt(tester.getTopLeft(button) + const Offset(20, 2));
    expect(taps, 1);

    await tester.pumpWidget(
      _testApp(promo, width: 320, textScaler: const TextScaler.linear(1.6)),
    );
    expect(tester.getSize(card).height, greaterThan(205));
    expect(tester.takeException(), isNull);
  });

  testWidgets('uses the approved gold action for the subscription CTA', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(390, 720));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    var taps = 0;
    await tester.pumpWidget(
      _testApp(HomeProSubscriptionCard(onPressed: () => taps++), width: 390),
    );
    final action = find.byType(AsteriaActionButton);
    expect(tester.widget<AsteriaActionButton>(action).gold, isTrue);
    await tester.tap(action);
    expect(taps, 1);
  });

  testWidgets('removes the CTA shimmer when animations are disabled', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(390, 720));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      _testApp(
        HomeProSubscriptionCard(onPressed: () {}),
        width: 390,
        disableAnimations: true,
      ),
    );

    expect(
      find.byKey(const ValueKey('balance-subscription-cta-shimmer')),
      findsNothing,
    );
  });
}

Widget _testApp(
  Widget child, {
  required double width,
  TextScaler textScaler = TextScaler.noScaling,
  bool disableAnimations = false,
}) {
  return MaterialApp(
    locale: const Locale('ru'),
    localizationsDelegates: const [
      AppLocalizations.delegate,
      ...GlobalMaterialLocalizations.delegates,
    ],
    supportedLocales: AppLocaleService.supportedLocales,
    home: Builder(
      builder: (context) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(
            textScaler: textScaler,
            disableAnimations: disableAnimations,
          ),
          child: Theme(
            data: AppThemeDark.instance.getThemeData(context),
            child: Scaffold(
              body: Center(
                child: SizedBox(width: width, child: child),
              ),
            ),
          ),
        );
      },
    ),
  );
}
