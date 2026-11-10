import 'package:asteria_app/core/localization/localization.dart';
import 'package:asteria_app/core/ui_kit/theme/theme.dart';
import 'package:asteria_app/features/home/presentation/widgets/affirmation_of_the_day_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';

const _expectedCardBackgroundColor = Color(0xFF1B1433);

void main() {
  testWidgets('renders the normal affirmation content', (tester) async {
    await tester.pumpWidget(
      _testApp(const AffirmationOfTheDayWidget(text: 'Я доверяю себе')),
    );

    expect(find.text('Аффирмация дня'), findsOneWidget);
    expect(find.text('Я доверяю себе'), findsOneWidget);
    expect(find.text('Все аффирмации'), findsOneWidget);
    expect(
      _cardBackgroundColor(tester, find.byType(AffirmationOfTheDayWidget)),
      _expectedCardBackgroundColor,
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets('renders offline state and invokes retry', (tester) async {
    var retryCount = 0;
    await tester.pumpWidget(
      _testApp(
        AffirmationUnavailableWidget(
          isLoading: false,
          onRetry: () => retryCount++,
        ),
      ),
    );

    expect(
      find.text('Не удалось загрузить аффирмацию. Проверьте интернет.'),
      findsOneWidget,
    );
    expect(find.text('Попробовать снова'), findsOneWidget);
    expect(
      _cardBackgroundColor(tester, find.byType(AffirmationUnavailableWidget)),
      _expectedCardBackgroundColor,
    );

    await tester.tap(find.text('Попробовать снова'));
    await tester.pump();

    expect(retryCount, 1);
    expect(tester.takeException(), isNull);
  });

  testWidgets('renders loading state without an active retry button', (
    tester,
  ) async {
    await tester.pumpWidget(
      _testApp(
        const AffirmationUnavailableWidget(isLoading: true, onRetry: null),
      ),
    );

    expect(find.text('Загружаем аффирмацию…'), findsOneWidget);
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    expect(find.text('Попробовать снова'), findsNothing);
    expect(
      _cardBackgroundColor(tester, find.byType(AffirmationUnavailableWidget)),
      _expectedCardBackgroundColor,
    );
    expect(
      tester.getSize(find.byType(AffirmationUnavailableWidget)).width,
      390,
    );
    expect(tester.takeException(), isNull);
  });
}

Color? _cardBackgroundColor(WidgetTester tester, Finder cardFinder) {
  final container = tester.widget<Container>(
    find.descendant(of: cardFinder, matching: find.byType(Container)).first,
  );

  return (container.decoration as BoxDecoration).color;
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
            body: Center(child: SizedBox(width: 390, child: child)),
          ),
        );
      },
    ),
  );
}
