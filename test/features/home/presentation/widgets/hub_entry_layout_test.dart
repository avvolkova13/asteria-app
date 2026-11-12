import 'package:asteria_app/core/localization/localization.dart';
import 'package:asteria_app/core/ui_kit/ui_kit.dart';
import 'package:asteria_app/features/home/presentation/widgets/daily_practice_hub.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  for (final locale in [const Locale('ru'), const Locale('en')]) {
    testWidgets('paired tools align their actions (${locale.languageCode})', (
      tester,
    ) async {
      await tester.binding.setSurfaceSize(const Size(390, 844));
      addTearDown(() => tester.binding.setSurfaceSize(null));
      await tester.pumpWidget(
        MaterialApp(
          locale: locale,
          supportedLocales: AppLocaleService.supportedLocales,
          localizationsDelegates: const [
            AppLocalizations.delegate,
            ...GlobalMaterialLocalizations.delegates,
          ],
          builder: (context, child) => Theme(
            data: AppThemeDark.instance.getThemeData(context),
            child: child!,
          ),
          home: const Scaffold(
            body: SingleChildScrollView(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: PracticeToolEntries(),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      final actions = find.text(
        locale.languageCode == 'ru' ? 'Открыть' : 'Explore',
      );
      expect(actions, findsNWidgets(2));
      expect(
        tester.getCenter(actions.first).dy,
        tester.getCenter(actions.last).dy,
      );
      expect(tester.takeException(), isNull);
    });
  }

  testWidgets(
    'practice entries remain readable and tappable at 320pt with large text',
    (tester) async {
      await tester.binding.setSurfaceSize(const Size(320, 680));
      addTearDown(() => tester.binding.setSurfaceSize(null));
      var taps = 0;
      await tester.pumpWidget(
        MaterialApp(
          locale: const Locale('ru'),
          supportedLocales: AppLocaleService.supportedLocales,
          localizationsDelegates: const [
            AppLocalizations.delegate,
            ...GlobalMaterialLocalizations.delegates,
          ],
          builder: (context, child) => Theme(
            data: AppThemeDark.instance.getThemeData(context),
            child: MediaQuery(
              data: MediaQuery.of(context).copyWith(
                textScaler: TextScaler.linear(2),
                disableAnimations: true,
              ),
              child: child!,
            ),
          ),
          home: Scaffold(
            body: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    HubEntryCard(
                      title: 'Аффирмации',
                      description: 'Выберите короткую запись по настроению.',
                      action: 'Выбрать аффирмацию',
                      art: 'assets/images/scenarios/lotus.webp',
                      onTap: () => taps++,
                    ),
                    const SizedBox(height: 16),
                    const PracticeToolEntries(),
                  ],
                ),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      await tester.ensureVisible(find.text('Выбрать аффирмацию'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Выбрать аффирмацию'));
      expect(taps, 1);
      await tester.ensureVisible(find.text('Открыть').last);
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      expect(find.text('Руны'), findsOneWidget);
    },
  );
}
