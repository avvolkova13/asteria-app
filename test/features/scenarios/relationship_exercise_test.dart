import 'dart:ui' show SemanticsAction;

import 'package:asteria_app/core/localization/localization.dart';
import 'package:asteria_app/core/ui_kit/theme/theme.dart';
import 'package:asteria_app/features/scenarios/relationships_scenario.dart';
import 'package:asteria_app/features/scenarios/scenario_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('three accessible choices show titles without attempt labels', (
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
        home: const RelationshipsScenarioScreen(),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.byType(ScenarioChoiceCard), findsNWidgets(3));
    for (final label in [
      'Почему мы спорим?',
      'О чём нам поговорить?',
      'Как сказать, что задело?',
    ]) {
      final target = find.text(label);
      await tester.ensureVisible(target);
      await tester.pumpAndSettle();
      expect(
        tester
            .getSemantics(target)
            .getSemanticsData()
            .hasAction(SemanticsAction.tap),
        isTrue,
      );
    }
    expect(
      tester
          .widgetList<ScenarioChoiceCard>(find.byType(ScenarioChoiceCard))
          .map((card) => card.subtitle),
      everyElement(isNull),
    );
    expect(tester.takeException(), isNull);
  });
}
