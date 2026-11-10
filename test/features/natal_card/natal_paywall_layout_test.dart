import 'package:asteria_app/core/localization/localization.dart';
import 'package:asteria_app/core/ui_kit/theme/theme.dart';
import 'package:asteria_app/features/natal_card/widgets/natal_card_empty_screen.dart';
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

  for (final width in [320.0, 390.0, 430.0]) {
    for (final locale in [const Locale('ru'), const Locale('en')]) {
      testWidgets('wand fits beside the text at $width in $locale', (
        tester,
      ) async {
        await tester.binding.setSurfaceSize(Size(width, 1000));
        addTearDown(() => tester.binding.setSurfaceSize(null));
        await tester.pumpWidget(
          MaterialApp(
            locale: locale,
            localizationsDelegates: const [
              AppLocalizations.delegate,
              ...GlobalMaterialLocalizations.delegates,
            ],
            supportedLocales: AppLocaleService.supportedLocales,
            home: Builder(
              builder: (context) => Theme(
                data: AppThemeDark.instance.getThemeData(context),
                child: Scaffold(
                  body: SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    child: NatalCardEmptyScreen(onBuyPressed: () {}),
                  ),
                ),
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();

        final wandFinder = find.byWidgetPredicate(
          (widget) =>
              widget is Image &&
              widget.image is AssetImage &&
              (widget.image as AssetImage).assetName.endsWith(
                'paywall_wand.webp',
              ),
        );
        final wand = tester.getRect(wandFinder);
        final title = tester.getRect(
          find.text(AppLocalizations.current.natalInsideTitle),
        );
        final cardFinder = find
            .ancestor(
              of: find.text(AppLocalizations.current.natalInsideTitle),
              matching: find.byWidgetPredicate(
                (widget) => widget is Container && widget.decoration != null,
              ),
            )
            .first;
        final card = tester.getRect(cardFinder);

        expect(wand.right, lessThanOrEqualTo(card.right - 15));
        expect(wand.bottom, lessThanOrEqualTo(card.bottom - 15));
        expect(wand.top, greaterThan(title.bottom));
        for (final paragraph
            in find
                .descendant(of: cardFinder, matching: find.byType(RichText))
                .evaluate()) {
          expect(
            wand.overlaps(tester.getRect(find.byWidget(paragraph.widget))),
            isFalse,
            reason: 'The illustration must not overlap any feature text',
          );
        }
        if (width == 390) {
          expect(wand.size, const Size(105, 157));
          expect(card.right - wand.right, closeTo(16, 1));
          expect(wand.top - card.top, closeTo(80, 1));
        }
        expect(tester.takeException(), isNull);
      });
    }
  }
}
