import 'dart:io';
import 'dart:ui' as ui;
import 'package:asteria_app/core/ui_kit/widgets/not_enough_stars_purchase_content.dart';
import 'package:asteria_app/core/analytics/dictionaries/offer_type.dart';
import 'package:asteria_app/core/localization/localization.dart';
import 'package:asteria_app/core/ui_kit/theme/theme.dart';
import 'package:asteria_app/core/ui_kit/widgets/shared_purchase_modal.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  for (final width in [320.0, 390.0]) {
    testWidgets('PRO and stars choices fit at width $width', (tester) async {
      await tester.binding.setSurfaceSize(Size(width, 600));
      addTearDown(() => tester.binding.setSurfaceSize(null));
      for (final font in {
        'Lora': 'assets/fonts/lora/Lora-VariableFont_wght.ttf',
        'Onest': 'assets/fonts/onest/Onest-VariableFont_wght.ttf',
      }.entries) {
        await (FontLoader(
          font.key,
        )..addFont(rootBundle.load(font.value))).load();
      }
      final key = GlobalKey();
      var pro = 0;
      var stars = 0;
      await tester.pumpWidget(
        MaterialApp(
          locale: const Locale('ru'),
          localizationsDelegates: const [
            AppLocalizations.delegate,
            ...GlobalMaterialLocalizations.delegates,
          ],
          supportedLocales: AppLocaleService.supportedLocales,
          home: Builder(
            builder: (context) => Theme(
              data: AppThemeDark.instance.getThemeData(context),
              child: Scaffold(
                body: Align(
                  alignment: Alignment.bottomCenter,
                  child: RepaintBoundary(
                    key: key,
                    child: ColoredBox(
                      color: const Color(0xFF110628),
                      child: MediaQuery(
                        data: MediaQuery.of(context).copyWith(
                          textScaler: TextScaler.linear(width == 320 ? 1.3 : 1),
                        ),
                        child: NotEnoughStarsPurchaseContent(
                          balance: 5,
                          requiredAmount: 55,
                          onCancel: () {},
                          onBuyStars: () => stars++,
                          onSubscribe: () => pro++,
                        ),
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
      await tester.tap(find.text('Перейти к подписке'));
      await tester.tap(find.text('Купить звёздочёты'));
      expect(pro, 1);
      expect(stars, 1);
      await tester.pumpAndSettle();
      final captureDir = Platform.environment['AST194_CAPTURE_DIR'];
      if (captureDir != null) {
        await tester.runAsync(() async {
          final image =
              await (key.currentContext!.findRenderObject()
                      as RenderRepaintBoundary)
                  .toImage(pixelRatio: 2);
          final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
          await File(
            '$captureDir/ast194-insufficient-${width.toInt()}.png',
          ).writeAsBytes(bytes!.buffer.asUint8List());
          image.dispose();
        });
      }
    });
  }

  testWidgets(
    'keeps the reading description on one line at the Figma viewport',
    (tester) async {
      await tester.binding.setSurfaceSize(const Size(390, 350));
      addTearDown(() => tester.binding.setSurfaceSize(null));
      for (final font in {


        'Lora': 'assets/fonts/lora/Lora-VariableFont_wght.ttf',
        'Onest': 'assets/fonts/onest/Onest-VariableFont_wght.ttf',
      }.entries) {
        await (FontLoader(
          font.key,
        )..addFont(rootBundle.load(font.value))).load();
      }
      final key = GlobalKey();
      await tester.pumpWidget(
        MaterialApp(
          locale: const Locale('ru'),
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
                    data: const MediaQueryData(
                      padding: EdgeInsets.only(bottom: 34),
                    ),
                    child: RepaintBoundary(
                      key: key,
                      child: SharedPurchaseModal(
                        purchaseTitle: 'Любовный расклад',
                        price: 10,
                        offerType: OfferType.oneOffUnlock,
                        onPurchase: () async {},
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
      await tester.runAsync(
        () => Future<void>.delayed(const Duration(milliseconds: 300)),
      );
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      expect(tester.getSize(find.byKey(key)), const Size(390, 265));
      final description = tester.renderObject<RenderParagraph>(
        find.text('Недостаточно для покупки расклада'),
      );
      expect(description.didExceedMaxLines, isFalse);
      expect(
        description.getBoxesForSelection(
          const TextSelection(baseOffset: 0, extentOffset: 34),
        ),
        hasLength(1),
      );
    },
  );
}
