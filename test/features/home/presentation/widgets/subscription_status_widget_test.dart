import 'package:asteria_app/core/localization/localization.dart';
import 'package:asteria_app/core/ui_kit/theme/theme.dart';
import 'package:asteria_app/features/home/presentation/widgets/subscription_status_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
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
}

Widget _testApp(Widget child) {
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
            body: Center(child: SizedBox(width: 358, child: child)),
          ),
        );
      },
    ),
  );
}
