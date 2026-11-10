import 'package:asteria_app/app/data/models/lunar_calendar/lunar_recommendation_models.dart';
import 'package:asteria_app/core/localization/localization.dart';
import 'package:asteria_app/core/ui_kit/theme/theme.dart';
import 'package:asteria_app/features/home/presentation/widgets/phase_background_widget.dart';
import 'package:asteria_app/features/home/presentation/widgets/sphere_selection_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('renders phase background without generic day favorability', (
    tester,
  ) async {
    await tester.pumpWidget(
      _app(const PhaseBackgroundWidget(background: _background)),
    );

    expect(find.text('Фон дня: Восстановление'), findsOneWidget);
    expect(find.text('Нужно сбавить темп.'), findsOneWidget);
    expect(find.textContaining('Неблагоприятный'), findsNothing);
  });

  testWidgets('renders selected sphere status as scoped recommendation', (
    tester,
  ) async {
    await tester.pumpWidget(
      _app(
        PhaseBackgroundWidget(
          background: _background,
          sphere: Sphere.garden,
          recommendation: _recommendation,
        ),
      ),
    );

    expect(find.text('Сфера «Садоводство»: благоприятно'), findsOneWidget);
    expect(find.text('Нужно сбавить темп.'), findsOneWidget);
    expect(find.text('Фон дня: Восстановление'), findsNothing);
  });
}

Widget _app(Widget child) {
  return MaterialApp(
    locale: const Locale('ru'),
    localizationsDelegates: const [
      AppLocalizations.delegate,
      ...GlobalMaterialLocalizations.delegates,
    ],
    supportedLocales: AppLocaleService.supportedLocales,
    home: Builder(
      builder: (context) => Theme(
        data: AppThemeDark.instance.getThemeData(context),
        child: Scaffold(body: child),
      ),
    ),
  );
}

const _background = DailyBackgroundModel(
  tone: PhaseTone.recovery,
  title: 'Восстановление',
  summary: 'Нужно сбавить темп.',
);

const _recommendation = SphereRecommendationModel(
  status: RecommendationStatus.favorable,
  tasks: {
    'houseplants': TaskRecommendationModel(
      status: RecommendationStatus.favorable,
      description: 'Можно пересаживать комнатные растения.',
    ),
  },
);
