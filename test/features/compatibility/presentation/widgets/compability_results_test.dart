import 'package:asteria_app/app/data/models/prompt_response.dart';
import 'package:asteria_app/core/localization/localization.dart';
import 'package:asteria_app/core/ui_kit/theme/theme.dart';
import 'package:asteria_app/features/compatibility/presentation/widgets/compability_results.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  for (final scale in [1.0, 2.0]) {
    testWidgets(
      'zodiac portraits and percentage do not overlap at scale $scale',
      (tester) async {
        await tester.binding.setSurfaceSize(Size(scale == 1 ? 390 : 320, 1200));
        addTearDown(() => tester.binding.setSurfaceSize(null));

        await tester.pumpWidget(
          MaterialApp(
            locale: const Locale('ru'),
            localizationsDelegates: const [
              AppLocalizations.delegate,
              ...GlobalMaterialLocalizations.delegates,
            ],
            supportedLocales: AppLocaleService.supportedLocales,
            builder: (context, child) => MediaQuery(
              data: MediaQuery.of(
                context,
              ).copyWith(textScaler: TextScaler.linear(scale)),
              child: child!,
            ),
            home: Builder(
              builder: (context) {
                return Theme(
                  data: AppThemeDark.instance.getThemeData(context),
                  child: Scaffold(
                    body: SingleChildScrollView(
                      child: CompabilityResults(
                        compatibilityData: _compatibilityData,
                        hisBirthdate: '13-05-1995',
                        herBirthdate: '22-05-1994',
                        onHistoryPressed: () {},
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        );
        await tester.pumpAndSettle();

        final zodiacAssets = tester
            .widgetList<Image>(find.byType(Image))
            .map((image) => image.image)
            .whereType<AssetImage>()
            .map((provider) => provider.assetName)
            .where((assetName) => assetName.contains('compatibility_round'))
            .toList();

        expect(
          zodiacAssets,
          containsAll(<String>[
            'assets/images/zodiacs/compatibility_round/telec.webp',
            'assets/images/zodiacs/compatibility_round/bliznecy.webp',
          ]),
        );
        final portraits = find.byType(ClipOval);
        expect(portraits, findsNWidgets(2));
        final percentage = tester.getRect(find.text('69%'));
        expect(percentage.overlaps(tester.getRect(portraits.first)), isFalse);
        expect(percentage.overlaps(tester.getRect(portraits.last)), isFalse);
        expect(tester.takeException(), isNull);
      },
    );
  }
}

const _compatibilityData = CompatibilityData(
  generalCompatibility: 'Общее описание совместимости.',
  loveCompatibility: 'Любовь',
  loveCompatibilityPercentage: '82%',
  familyCompatibility: 'Семья',
  familyCompatibilityPercentage: '80%',
  conflicts: 'Конфликты',
  conflictsPercentage: '30%',
  percentage: '69%',
  phrase: 'Стабильность встречает переменчивость.',
  introduction: 'Эта пара может быть интересной, но требует гибкости.',
);
