import 'package:asteria_app/core/localization/generated/l10n.dart';
import 'package:asteria_app/core/payments/catalog/google_subscription_offers.dart';
import 'package:asteria_app/core/payments/widgets/google_subscription_price.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  for (final locale in ['en', 'ru']) {
    testWidgets(
      '$locale displays free trial and subsequent recurring charge on compact screen',
      (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            locale: Locale(locale),
            localizationsDelegates: const [
              AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            supportedLocales: AppLocalizations.delegate.supportedLocales,
            home: const Scaffold(
              body: SizedBox(
                width: 240,
                child: GoogleSubscriptionPrice(
                  terms: GoogleSubscriptionTerms(
                    recurringPrice: r'$9.99',
                    billingPeriod: 'P1M',
                    hasFreeTrial: true,
                  ),
                ),
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();
        expect(find.textContaining(r'$9.99'), findsOneWidget);
        expect(
          find.textContaining(
            locale == 'ru' ? '7 дней бесплатно' : '7 days free',
          ),
          findsOneWidget,
        );
        expect(
          find.textContaining(locale == 'ru' ? 'месяц' : 'month'),
          findsOneWidget,
        );
        expect(tester.takeException(), isNull);
      },
    );
  }
  testWidgets(
    'regular plan discloses recurring period without advertising a trial',
    (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          localizationsDelegates: [AppLocalizations.delegate],
          home: Scaffold(
            body: GoogleSubscriptionPrice(
              terms: GoogleSubscriptionTerms(
                recurringPrice: r'$49.99',
                billingPeriod: 'P1Y',
                hasFreeTrial: false,
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.textContaining(r'$49.99'), findsOneWidget);
      expect(find.textContaining('year'), findsOneWidget);
      expect(find.textContaining('free'), findsNothing);
    },
  );
}
