import 'package:asteria_app/app/data/models/affirmation/affirmation_model.dart';
import 'package:asteria_app/core/localization/localization.dart';
import 'package:asteria_app/core/ui_kit/theme/theme.dart';
import 'package:asteria_app/features/affirmation/affirmation_detail_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  for (final language in ['ru', 'en']) {
    testWidgets(
      'selected text remains readable at 320 points and large text in $language',
      (tester) async {
        tester.view.physicalSize = const Size(320, 568);
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.reset);
        final calls = <MethodCall>[];
        const channel = MethodChannel('asteria/practice-audio');
        tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
          channel,
          (call) async {
            calls.add(call);
            return null;
          },
        );
        addTearDown(
          () => tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
            channel,
            null,
          ),
        );
        final text = List.filled(
          16,
          language == 'ru'
              ? 'Любовь наполняет мою жизнь.'
              : 'Love fills my life.',
        ).join(' ');
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
            home: AffirmationDetailScreen(
              selection: AffirmationSelection(
                affirmation: AffirmationModel(
                  id: 'selected-love',
                  categoryId: 'love',
                  category: 'Любовь',
                  text: text,
                  sort: 1,
                ),
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();
        expect(find.text(language == 'ru' ? 'Любовь' : 'Love'), findsOneWidget);
        expect(find.text(text), findsOneWidget);
        final paragraph = tester.renderObject<RenderParagraph>(
          find.descendant(of: find.text(text), matching: find.byType(RichText)),
        );
        expect(paragraph.didExceedMaxLines, isFalse);
        await tester.drag(
          find.byType(SingleChildScrollView),
          const Offset(0, -3000),
        );
        await tester.pumpAndSettle();
        final lastLetter = paragraph
            .getBoxesForSelection(
              TextSelection(
                baseOffset: text.length - 1,
                extentOffset: text.length,
              ),
            )
            .last;
        final bottom =
            paragraph.localToGlobal(Offset.zero).dy + lastLetter.bottom;
        expect(bottom, lessThanOrEqualTo(568));
        expect(
          calls,
          isEmpty,
          reason:
              'Text content must never initialize the unrelated bundled recording',
        );
        expect(find.byType(Slider), findsNothing);
        expect(tester.takeException(), isNull);
      },
    );
  }
}
