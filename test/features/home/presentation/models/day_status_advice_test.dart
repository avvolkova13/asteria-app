import 'package:asteria_app/core/localization/localization.dart';
import 'package:asteria_app/features/home/presentation/models/day_status.dart';
import 'package:asteria_app/features/home/presentation/models/day_status_advice.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('DayStatusAdvice', () {
    testWidgets('returns localized titles for all statuses', (tester) async {
      final context = await _localizedContext(tester);

      expect(DayStatus.favorable.title(context), 'Благоприятный\nдень');
      expect(DayStatus.neutral.title(context), 'Нейтральный\nдень');
      expect(DayStatus.unfavorable.title(context), 'Неблагоприятный\nдень');
    });

    testWidgets('returns a dedicated description for each status', (
      tester,
    ) async {
      final context = await _localizedContext(tester);

      expect(
        DayStatus.favorable.description(context),
        contains('Луна поддерживает'),
      );
      expect(
        DayStatus.neutral.description(context),
        contains('пауза между импульсом'),
      );
      expect(
        DayStatus.unfavorable.description(context),
        contains('снизить нагрузку'),
      );
    });
  });
}

Future<BuildContext> _localizedContext(WidgetTester tester) async {
  late BuildContext result;
  await tester.pumpWidget(
    MaterialApp(
      locale: const Locale('ru'),
      localizationsDelegates: const [
        AppLocalizations.delegate,
        ...GlobalMaterialLocalizations.delegates,
      ],
      supportedLocales: AppLocaleService.supportedLocales,
      home: Builder(
        builder: (context) {
          result = context;
          return const SizedBox.shrink();
        },
      ),
    ),
  );
  return result;
}
