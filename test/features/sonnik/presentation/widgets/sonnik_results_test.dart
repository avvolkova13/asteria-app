import 'package:asteria_app/core/ui_kit/widgets/requests_left_badge.dart';
import 'package:asteria_app/app/data/models/sonnik/sonnik_model.dart';
import 'package:asteria_app/core/localization/localization.dart';
import 'package:asteria_app/core/ui_kit/theme/theme.dart';
import 'package:asteria_app/features/sonnik/presentation/widgets/sonnik_layout.dart';
import 'package:asteria_app/features/sonnik/presentation/widgets/sonnik_results.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('renders decode-again action on dream result', (tester) async {
    var decodeAgainTaps = 0;

    await tester.pumpWidget(
      _testApp(
        SonnikResults(
          sonnik: _sonnik,
          onDecodeAgainPressed: () => decodeAgainTaps++,
        ),
      ),
    );

    expect(find.text('Сон про море'), findsOneWidget);
    expect(find.text('Расшифровать еще'), findsOneWidget);

    await tester.tap(find.text('Расшифровать еще'));
    await tester.pump();

    expect(decodeAgainTaps, 1);
    expect(tester.takeException(), isNull);
  });

  testWidgets('formats quota badge as total attempts remaining label', (
    tester,
  ) async {
    await tester.pumpWidget(_testApp(const SonnikQuotaBadge(requestsLeft: 2)));

    expect(find.text('Осталось 2 попытки'), findsOneWidget);
    expect(find.byType(RequestsLeftBadge), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}

Widget _testApp(Widget child) {
  return MaterialApp(
    locale: const Locale('ru'),
    localizationsDelegates: const [
      AppLocalizations.delegate,
      ...GlobalMaterialLocalizations.delegates,
    ],
    supportedLocales: AppLocaleService.supportedLocales,
    home: Builder(
      builder: (context) {
        return Theme(
          data: AppThemeDark.instance.getThemeData(context),
          child: Scaffold(
            backgroundColor: SonnikPalette.background,
            body: Center(child: child),
          ),
        );
      },
    ),
  );
}

final _sonnik = SonnikModel(
  id: 'sonnik-1',
  dateGenerated: DateTime(2026, 9, 9),
  title: 'Сон про море',
  interpretation: 'Море во сне показывает сильную эмоцию и движение вперед.',
);
