import 'package:asteria_app/core/localization/localization.dart';
import 'package:asteria_app/core/ui_kit/theme/theme.dart';
import 'package:asteria_app/features/home/presentation/widgets/subscription_status_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUpAll(() async {
    for (final font in {
      'Lora': 'assets/fonts/lora/Lora-VariableFont_wght.ttf',
      'Onest': 'assets/fonts/onest/Onest-VariableFont_wght.ttf',
    }.entries) {
      await (FontLoader(font.key)..addFont(rootBundle.load(font.value))).load();
    }
  });
  testWidgets(
    'renders inactive profile subscription card from the Figma layout',
    (tester) async {
      var tapCount = 0;

      await tester.binding.setSurfaceSize(const Size(390, 720));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      await tester.pumpWidget(
        _testApp(SubscriptionInactiveStatusWidget(onTap: () => tapCount++)),
      );

      final cardFinder = find.byKey(
        const ValueKey('profile-subscription-status-card'),
      );
      expect(cardFinder, findsOneWidget);
      expect(tester.getSize(cardFinder).height, 224);
      expect(find.text('Подписка PRO\nне активна'), findsOneWidget);
      expect(find.text('Подключить PRO'), findsOneWidget);

      final art = tester.getRect(
        find.byKey(const ValueKey('profile-subscription-status-art')),
      );
      final card = tester.getRect(cardFinder);
      expect(art.right, lessThanOrEqualTo(card.right - 12));
      expect(
        art.left,
        greaterThan(
          tester.getRect(find.text('Подписка PRO\nне активна')).right,
        ),
      );

      await tester.tap(find.text('Подключить PRO'));
      await tester.pump();

      expect(tapCount, 1);
      expect(tester.takeException(), isNull);
    },
  );
  for (final active in [true, false]) {
    testWidgets('crystal and action clear scaled PRO copy (active=$active)', (
      tester,
    ) async {
      await tester.binding.setSurfaceSize(const Size(320, 1000));
      addTearDown(() => tester.binding.setSurfaceSize(null));
      await tester.pumpWidget(
        _testApp(
          active
              ? SubscriptionActiveStatusWidget(
                  onTap: () {},
                  nextPaymentDateText: '11.11.2027',
                )
              : SubscriptionInactiveStatusWidget(onTap: () {}),
          width: 288,
          scale: 2,
        ),
      );
      final art = tester.getRect(
        find.byKey(const ValueKey('profile-subscription-status-art')),
      );
      final card = find.byKey(
        const ValueKey('profile-subscription-status-card'),
      );
      final labels = find
          .descendant(of: card, matching: find.byType(Text))
          .evaluate()
          .map((e) => tester.getRect(find.byWidget(e.widget)))
          .toList();
      expect(labels, hasLength(3));
      expect(labels.any((rect) => rect.overlaps(art)), isFalse);
      expect(labels[1].bottom, lessThan(labels[2].top));
      expect(labels[2].bottom, lessThanOrEqualTo(tester.getRect(card).bottom));
      expect(tester.takeException(), isNull);
    });
  }
}

Widget _testApp(Widget child, {double width = 358, double scale = 1}) {
  return MaterialApp(
    locale: const Locale('ru'),
    localizationsDelegates: const [
      AppLocalizations.delegate,
      ...GlobalMaterialLocalizations.delegates,
    ],
    supportedLocales: AppLocaleService.supportedLocales,
    home: Builder(
      builder: (context) {
        return Theme(
          data: AppThemeDark.instance.getThemeData(context),
          child: Scaffold(
            body: MediaQuery(
              data: MediaQuery.of(
                context,
              ).copyWith(textScaler: TextScaler.linear(scale)),
              child: Center(
                child: SizedBox(width: width, child: child),
              ),
            ),
          ),
        );
      },
    ),
  );
}
