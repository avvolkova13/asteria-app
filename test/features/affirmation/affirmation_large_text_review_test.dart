import 'package:asteria_app/app/data/models/affirmation/affirmation_model.dart';
import 'package:asteria_app/core/localization/localization.dart';
import 'package:asteria_app/core/ui_kit/theme/theme.dart';
import 'package:asteria_app/core/ui_kit/widgets/lotus_feedback.dart';
import 'package:asteria_app/features/affirmation/selected_affirmation_player.dart';
import 'package:asteria_app/features/affirmation/widgets/affirmation_category_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  setUpAll(() async {
    for (final font in [
      ('Lora', 'assets/fonts/lora/Lora-VariableFont_wght.ttf'),
      ('Onest', 'assets/fonts/onest/Onest-VariableFont_wght.ttf'),
    ]) {
      await (FontLoader(font.$1)..addFont(rootBundle.load(font.$2))).load();
    }
  });
  for (final language in ['ru', 'en']) {
    for (final locked in [false, true]) {
      testWidgets(
        'category labels stay complete with large text in $language locked=$locked',
        (tester) async {
          await pump(
            tester,
            language,
            SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    for (final category in [
                      'love',
                      'abundance',
                      'strength',
                      'creativity',
                      'lunar',
                      'calm',
                    ])
                      AffirmationCategoryWidget(
                        category: category,
                        affirmations: const [],
                        showAffirmations: !locked,
                      ),
                  ],
                ),
              ),
            ),
          );
          for (final text in tester.widgetList<Text>(find.byType(Text))) {
            final paragraph = tester.renderObject<RenderParagraph>(
              find.descendant(
                of: find.text(text.data!),
                matching: find.byType(RichText),
              ),
            );
            final natural = TextPainter(
              text: paragraph.text,
              textDirection: paragraph.textDirection,
              textScaler: paragraph.textScaler,
            )..layout(maxWidth: paragraph.size.width);
            expect(paragraph.didExceedMaxLines, isFalse, reason: text.data);
            expect(
              paragraph.size.height,
              greaterThanOrEqualTo(natural.height),
              reason:
                  '${text.data} must receive its complete scaled line height',
            );
            natural.dispose();
          }
          if (locked) {
            for (final target in find.byType(LotusTap).evaluate()) {
              expect(
                (target.renderObject as RenderBox).size.height,
                greaterThanOrEqualTo(44),
              );
            }
          }
          expect(tester.takeException(), isNull);
        },
      );
    }
    testWidgets(
      'player category label keeps the entire word in $language at 320 and text x2',
      (tester) async {
        await pump(
          tester,
          language,
          const SelectedAffirmationPlayer(
            selection: AffirmationSelection(
              affirmation: AffirmationModel(
                id: 'review',
                categoryId: 'love',
                category: 'Любовь',
                text: 'I choose calm.',
                sort: 1,
              ),
            ),
          ),
        );
        final label = language == 'ru' ? 'АФФИРМАЦИИ' : 'AFFIRMATIONS';
        final paragraph = tester.renderObject<RenderParagraph>(
          find.descendant(
            of: find.text(label),
            matching: find.byType(RichText),
          ),
        );
        final boxes = paragraph.getBoxesForSelection(
          TextSelection(baseOffset: 0, extentOffset: label.length),
        );
        expect(
          boxes,
          hasLength(1),
          reason:
              'The short navigation label must not split off its final letters',
        );
        expect(paragraph.didExceedMaxLines, isFalse);
        expect(tester.takeException(), isNull);
      },
    );
  }
}

Future<void> pump(WidgetTester tester, String language, Widget child) async {
  tester.view.physicalSize = const Size(320, 568);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(
    MaterialApp(
      locale: Locale(language),
      supportedLocales: AppLocaleService.supportedLocales,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        ...GlobalMaterialLocalizations.delegates,
      ],
      builder: (context, child) => Theme(
        data: AppThemeDark.instance.getThemeData(context),
        child: MediaQuery(
          data: MediaQuery.of(context).copyWith(
            textScaler: const TextScaler.linear(2),
            disableAnimations: true,
          ),
          child: child!,
        ),
      ),
      home: Scaffold(body: child),
    ),
  );
  await tester.pumpAndSettle();
}
