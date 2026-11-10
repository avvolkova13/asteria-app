import 'package:asteria_app/core/localization/localization.dart';
import 'package:asteria_app/core/ui_kit/ui_kit.dart';
import 'package:asteria_app/features/onboarding/data/onboarding_data.dart';
import 'package:asteria_app/features/onboarding/localization/onboarding_localization_contract.dart';
import 'package:asteria_app/features/onboarding/presentation/widgets/onboarding_page_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  setUpAll(() async {
    for (final entry in {
      'Lora': 'assets/fonts/lora/Lora-VariableFont_wght.ttf',
      'Onest': 'assets/fonts/onest/Onest-VariableFont_wght.ttf',
    }.entries) {
      final loader = FontLoader(entry.key)
        ..addFont(rootBundle.load(entry.value));
      await loader.load();
    }
  });

  Future<void> pumpPage(
    WidgetTester tester,
    String locale,
    int page,
    Size size,
    double scale,
  ) async {
    tester.view.devicePixelRatio = 3;
    tester.view.physicalSize = size * 3;
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetPhysicalSize);
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
            data: AppThemeDark.instance.getThemeData(context),
            child: MediaQuery(
              data: MediaQuery.of(context).copyWith(
                textScaler: TextScaler.linear(scale),
                padding: EdgeInsets.only(
                  top: size.height >= 800 ? 59 : 20,
                  bottom: size.height >= 800 ? 34 : 0,
                ),
              ),
              child: Scaffold(
                body: RepaintBoundary(
                  key: const ValueKey('onboarding-golden'),
                  child: OnboardingPageWidget(
                    page: OnboardingData.getPages(context)[page],
                    localization: OnboardingLocalization(),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  for (final locale in ['ru', 'en']) {
    for (final size in [
      const Size(320, 568),
      const Size(375, 667),
      const Size(390, 844),
      const Size(430, 932),
    ]) {
      for (final scale in [1.0, 1.3, 2.0]) {
        for (var page = 0; page < 4; page++) {
          testWidgets(
            '$locale page ${page + 1} ${size.width}x${size.height} text $scale',
            (tester) async {
              await pumpPage(tester, locale, page, size, scale);
              expect(tester.takeException(), isNull);
              final content = find.byKey(ValueKey('onboarding-content-$page'));
              final bottomSafe = size.height >= 800 ? 34 : 0;
              expect(
                tester.getRect(content).bottom,
                lessThanOrEqualTo(size.height - bottomSafe - 90),
              );
              final context = tester.element(find.byType(OnboardingPageWidget));
              final model = OnboardingData.getPages(context)[page];
              final description = find.text(model.description);
              // Copy can wrap freely; the illustration follows it even when scrolling.
              final visual = find.byKey(ValueKey('onboarding-visual-$page'));
              if (visual.evaluate().isNotEmpty) {
                expect(
                  tester.getRect(description).bottom,
                  lessThan(tester.getRect(visual).top),
                );
                await tester.drag(content, const Offset(0, -2000));
                await tester.pumpAndSettle();
                expect(
                  tester.getRect(visual).bottom,
                  lessThanOrEqualTo(tester.getRect(content).bottom + .1),
                );
              }
              if (page == 1) {
                expect(
                  find.text(AppLocalizations.of(context).affirmationOfDay),
                  findsOneWidget,
                );
                expect(
                  find.text(AppLocalizations.of(context).energyFocus),
                  findsOneWidget,
                );
                expect(find.text('80%'), findsOneWidget);
              }
              if (locale == 'en') {
                for (final text in tester.widgetList<Text>(find.byType(Text))) {
                  expect(
                    text.data ?? text.textSpan?.toPlainText() ?? '',
                    isNot(matches(RegExp('[А-Яа-яЁё]'))),
                  );
                }
              }
              expect(
                find.byWidgetPredicate(
                  (widget) =>
                      widget is Image &&
                      widget.image is AssetImage &&
                      (widget.image as AssetImage).assetName.contains(
                        'onboarding_visual_',
                      ),
                ),
                findsNothing,
              );
              // Text in bounded miniatures must fit vertically, not silently paint past its card.
              for (final element in find.byType(RichText).evaluate()) {
                final render = element.renderObject;
                if (render is RenderParagraph) {
                  expect(render.didExceedMaxLines, isFalse);
                  final painter = TextPainter(
                    text: render.text,
                    textDirection: render.textDirection,
                    textScaler: render.textScaler,
                    locale: render.locale,
                    strutStyle: render.strutStyle,
                    textHeightBehavior: render.textHeightBehavior,
                    textWidthBasis: render.textWidthBasis,
                  )..layout(maxWidth: render.size.width);
                  expect(
                    painter.height,
                    lessThanOrEqualTo(render.size.height + .1),
                    reason: render.text.toPlainText(),
                  );
                  painter.dispose();
                }
              }
              expect(tester.takeException(), isNull);
            },
          );
        }
      }
    }
  }
}
