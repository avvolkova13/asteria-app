import 'package:asteria_app/core/localization/localization.dart';
import 'package:asteria_app/core/ui_kit/theme/theme.dart';
import 'package:asteria_app/core/ui_kit/widgets/not_enough_stars_purchase_content.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

void main() {
  setUpAll(() async {
    for (final font in {
      'Lora': 'assets/fonts/lora/Lora-VariableFont_wght.ttf',
      'Onest': 'assets/fonts/onest/Onest-VariableFont_wght.ttf',
    }.entries) {
      await (FontLoader(font.key)..addFont(rootBundle.load(font.value))).load();
    }
  });

  testWidgets('renders not enough stars purchase content from balance data', (
    tester,
  ) async {
    var cancelPressed = false;
    var buyStarsPressed = false;

    await tester.pumpWidget(
      MaterialApp(
        locale: const Locale('ru'),
        localizationsDelegates: const [
          AppLocalizations.delegate,
          ...GlobalMaterialLocalizations.delegates,
        ],
        supportedLocales: AppLocaleService.supportedLocales,
        home: Builder(
          builder: (context) {
            return Theme(
              data: AppThemeLight.instance.getThemeData(context),
              child: Scaffold(
                body: NotEnoughStarsPurchaseContent(
                  balance: 4,
                  requiredAmount: 55,
                  onCancel: () => cancelPressed = true,
                  onBuyStars: () => buyStarsPressed = true,
                ),
              ),
            );
          },
        ),
      ),
    );

    expect(find.text('Недостаточно звёздочётов'), findsOneWidget);
    expect(find.text('Недостаточно для покупки'), findsOneWidget);
    expect(find.textContaining('Баланс', findRichText: true), findsOneWidget);
    expect(find.textContaining('4', findRichText: true), findsOneWidget);
    expect(
      find.textContaining('Для покупки требуется', findRichText: true),
      findsOneWidget,
    );
    expect(find.textContaining('55', findRichText: true), findsOneWidget);
    expect(find.text('Отмена'), findsOneWidget);
    expect(find.text('Купить звёздочёты'), findsOneWidget);

    await tester.tap(find.text('Отмена'));
    await tester.pump();
    await tester.tap(find.text('Купить звёздочёты'));
    await tester.pump();

    expect(cancelPressed, isTrue);
    expect(buyStarsPressed, isTrue);
  });

  for (final locale in ['ru', 'en']) {
    for (final width in [320.0, 390.0]) {
      for (final scale in [1.0, 1.5, 2.0]) {
        testWidgets(
          'keeps purchase actions reachable at $locale/$width/$scale',
          (tester) async {
            await tester.binding.setSurfaceSize(Size(width, 568));
            addTearDown(() => tester.binding.setSurfaceSize(null));
            var buyPressed = false;
            await tester.pumpWidget(
              MaterialApp(
                locale: Locale(locale),
                localizationsDelegates: const [
                  AppLocalizations.delegate,
                  ...GlobalMaterialLocalizations.delegates,
                ],
                supportedLocales: AppLocaleService.supportedLocales,
                home: Builder(
                  builder: (context) => Theme(
                    data: AppThemeLight.instance.getThemeData(context),
                    child: Scaffold(
                      body: Align(
                        alignment: Alignment.bottomCenter,
                        child: MediaQuery(
                          data: MediaQueryData(
                            textScaler: TextScaler.linear(scale),
                          ),
                          child: ConstrainedBox(
                            constraints: const BoxConstraints(maxHeight: 300),
                            child: NotEnoughStarsPurchaseContent(
                              balance: 12345,
                              requiredAmount: 123456,
                              description: AppLocalizations.of(
                                context,
                              ).purchaseNotEnoughReading,
                              onCancel: _noop,
                              onBuyStars: () => buyPressed = true,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            );
            await tester.pumpAndSettle();
            expect(tester.takeException(), isNull);
            for (final element in find.byType(RichText).evaluate()) {
              final paragraph = element.renderObject! as RenderParagraph;
              expect(paragraph.didExceedMaxLines, isFalse);
            }
            await tester.tap(
              find.text(
                locale == 'ru' ? 'Купить звёздочёты' : 'Buy Star Coins',
              ),
            );
            expect(buyPressed, isTrue);
            expect(tester.takeException(), isNull);
          },
        );
      }
    }
  }

  testWidgets('fits compact modal bounds with text scaling', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        locale: const Locale('ru'),
        localizationsDelegates: const [
          AppLocalizations.delegate,
          ...GlobalMaterialLocalizations.delegates,
        ],
        supportedLocales: AppLocaleService.supportedLocales,
        home: Builder(
          builder: (context) {
            return Theme(
              data: AppThemeLight.instance.getThemeData(context),
              child: const Scaffold(
                body: MediaQuery(
                  data: MediaQueryData(
                    size: Size(320, 568),
                    textScaler: TextScaler.linear(1.1),
                  ),
                  child: SizedBox(
                    width: 320,
                    height: 260,
                    child: NotEnoughStarsPurchaseContent(
                      balance: 4,
                      requiredAmount: 250,
                      onCancel: _noop,
                      onBuyStars: _noop,
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );

    expect(tester.takeException(), isNull);
    expect(find.text('Купить звёздочёты'), findsOneWidget);
  });
}

void _noop() {}
