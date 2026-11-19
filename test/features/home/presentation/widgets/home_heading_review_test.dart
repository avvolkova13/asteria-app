import 'package:asteria_app/core/localization/localization.dart';
import 'package:asteria_app/core/ui_kit/ui_kit.dart';
import 'package:asteria_app/features/home/presentation/widgets/home_section_heading.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  setUpAll(() async {
    await (FontLoader('Lora')..addFont(
          rootBundle.load('assets/fonts/lora/Lora-VariableFont_wght.ttf'),
        ))
        .load();
  });
  for (final language in ['ru', 'en']) {
    for (final large in [false, true]) {
      testWidgets(
        'shared home headings preserve whole words in $language large=$large',
        (tester) async {
          tester.view.physicalSize = Size(large ? 320 : 390, 844);
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
                  data: MediaQuery.of(
                    context,
                  ).copyWith(textScaler: TextScaler.linear(large ? 2 : 1)),
                  child: child!,
                ),
              ),
              home: Scaffold(
                body: Builder(
                  builder: (context) {
                    final l = context.l10n;
                    return SingleChildScrollView(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            for (final title in [
                              l.lunarCalendarTitle,
                              l.moonPhaseTitle,
                              l.navPractices,
                              l.navigationReadings,
                              l.scenarioStrengthTitle,
                              l.scenarioCalendarChooseActivity,
                              l.scenarioCalendarChooseDates,
                              l.scenarioRelationshipChooseSituation,
                            ])
                              HomeSectionHeading(title),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          );
          await tester.pumpAndSettle();
          for (final heading in find.byType(HomeSectionHeading).evaluate()) {
            final textFinder = find.descendant(
              of: find.byWidget(heading.widget),
              matching: find.byType(Text),
            );
            final text = tester.widget<Text>(textFinder);
            final paragraph = tester.renderObject<RenderParagraph>(
              find.descendant(of: textFinder, matching: find.byType(RichText)),
            );
            final data = text.data!;
            var offset = 0;
            for (final word in data.split(RegExp(r'\s+'))) {
              final index = data.indexOf(word, offset);
              final boxes = paragraph.getBoxesForSelection(
                TextSelection(
                  baseOffset: index,
                  extentOffset: index + word.length,
                ),
              );
              expect(
                boxes,
                hasLength(1),
                reason: 'Whole word "$word" must stay on one line in "$data"',
              );
              offset = index + word.length;
            }
            expect(paragraph.didExceedMaxLines, isFalse);
            if (!large) {
              expect(text.style?.fontSize, AppTypography.h1.fontSize);
              expect(text.style?.fontWeight, AppTypography.h1.fontWeight);
            }
          }
          expect(tester.takeException(), isNull);
        },
      );
    }
  }
}
