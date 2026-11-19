import 'dart:ui' show SemanticsAction;

import 'package:asteria_app/core/localization/localization.dart';
import 'package:asteria_app/core/ui_kit/ui_kit.dart';
import 'package:asteria_app/features/scenarios/strength_scenario.dart';
import 'package:asteria_app/features/scenarios/scenario_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('three separate situations remain accessible at large text size', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(320, 680));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(
      MaterialApp(
        locale: const Locale('ru'),
        supportedLocales: AppLocaleService.supportedLocales,
        localizationsDelegates: const [
          AppLocalizations.delegate,
          ...GlobalMaterialLocalizations.delegates,
        ],
        builder: (context, child) => MediaQuery(
          data: MediaQuery.of(context).copyWith(
            disableAnimations: true,
            textScaler: TextScaler.linear(1.65),
          ),
          child: Theme(
            data: AppThemeDark.instance.getThemeData(context),
            child: child!,
          ),
        ),
        home: const StrengthScenarioScreen(),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Разобраться\nв ситуации'), findsOneWidget);
    expect(find.byType(ScenarioChoiceCard), findsNWidgets(3));
    for (final title in [
      'Открыть карту дня',
      'Вытянуть три руны',
      'Растолковать сон',
    ]) {
      final label = find.text(title);
      await tester.ensureVisible(label);
      await tester.pumpAndSettle();
      final node = tester.getSemantics(label);
      expect(node.label, title);
      expect(node.getSemanticsData().hasAction(SemanticsAction.tap), isTrue);
    }
    expect(find.text('Почему мы спорим?'), findsNothing);
    expect(find.text('Принять решение'), findsNothing);
    expect(tester.takeException(), isNull);
  });
}
