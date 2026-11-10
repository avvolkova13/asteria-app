import 'package:asteria_app/app/data/models/user/user_model.dart';
import 'package:asteria_app/core/localization/localization.dart';
import 'package:asteria_app/core/ui_kit/theme/theme.dart';
import 'package:asteria_app/features/auth/presentation/widgets/radio_button_group.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('renders birth time-of-day options in English', (tester) async {
    await _pumpRadioButtonGroup(tester, const Locale('en', 'US'));

    expect(find.text('Daytime'), findsOneWidget);
    expect(find.text('Time unknown'), findsOneWidget);
    expect(find.text('Nighttime'), findsOneWidget);
    expect(find.textContaining(RegExp(r'[\u0400-\u04FF]')), findsNothing);
    expect(find.bySemanticsLabel('Daytime'), findsOneWidget);
    expect(find.bySemanticsLabel('Time unknown'), findsOneWidget);
    expect(find.bySemanticsLabel('Nighttime'), findsOneWidget);
  });

  testWidgets('preserves Russian birth time-of-day options', (tester) async {
    await _pumpRadioButtonGroup(tester, const Locale('ru'));

    expect(find.text('Дневное время'), findsOneWidget);
    expect(find.text('Время неизвестно'), findsOneWidget);
    expect(find.text('Ночное время'), findsOneWidget);
  });
}

Future<void> _pumpRadioButtonGroup(WidgetTester tester, Locale locale) async {
  await tester.pumpWidget(
    MaterialApp(
      locale: locale,
      supportedLocales: AppLocaleService.supportedLocales,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        ...GlobalMaterialLocalizations.delegates,
      ],
      home: Builder(
        builder: (context) => Theme(
          data: AppThemeLight.instance.getThemeData(context),
          child: Scaffold(
            body: RadioButtonGroup(
              selectedValue: TimeOfDayEnum.morning,
              onChanged: (_) {},
            ),
          ),
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();
}
