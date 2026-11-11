import 'package:asteria_app/core/localization/localization.dart';
import 'package:asteria_app/core/routing/app_route.dart';
import 'package:asteria_app/core/ui_kit/theme/theme.dart';
import 'package:asteria_app/features/home/presentation/widgets/affirmation_of_the_day_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

void main() {
  testWidgets('shows the daily quote and opens the collection from the quote', (
    tester,
  ) async {
    final router = _router(
      const AffirmationOfTheDayWidget(text: 'Я доверяю себе'),
    );
    addTearDown(router.dispose);
    await tester.pumpWidget(_testApp(router));

    expect(find.text('Аффирмация дня'), findsOneWidget);
    expect(find.text('Все аффирмации'), findsOneWidget);
    expect(
      tester.getSemantics(find.text('Я доверяю себе')),
      matchesSemantics(
        label: 'Аффирмация дня\nЯ доверяю себе\nВсе аффирмации',
        isButton: true,
        hasTapAction: true,
      ),
    );

    await tester.tap(find.text('Я доверяю себе'));
    await tester.pumpAndSettle();
    expect(find.text('collection'), findsOneWidget);
    router.pop();
    await tester.pumpAndSettle();
    expect(find.text('Я доверяю себе'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('gives long quotes full width and preserves large text', (
    tester,
  ) async {
    final quote = List.filled(
      4,
      'Я даю себе время и выбираю то, что сейчас важно для меня.',
    ).join(' ');
    final router = _router(
      AffirmationOfTheDayWidget(text: quote),
      width: 320,
      scale: 2,
    );
    addTearDown(router.dispose);
    await tester.pumpWidget(_testApp(router));
    final text = find.text(quote);
    final render = tester.renderObject<RenderBox>(text);
    expect(render.size.width, greaterThan(240));
    expect(MediaQuery.textScalerOf(tester.element(text)).scale(16), 32);
    expect(tester.widget<Text>(text).maxLines, isNull);
    await tester.ensureVisible(find.text('Все аффирмации'));
    await tester.tap(find.text('Все аффирмации'));
    await tester.pumpAndSettle();
    expect(find.text('collection'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('renders offline state and invokes retry once', (tester) async {
    var retryCount = 0;
    final router = _router(
      AffirmationUnavailableWidget(
        isLoading: false,
        onRetry: () => retryCount++,
      ),
      width: 320,
      scale: 2,
    );
    addTearDown(router.dispose);
    await tester.pumpWidget(_testApp(router));

    expect(
      find.text('Не удалось загрузить аффирмацию. Проверьте интернет.'),
      findsOneWidget,
    );
    await tester.ensureVisible(find.text('Попробовать снова'));
    await tester.tap(find.text('Попробовать снова'));
    await tester.pump();
    expect(retryCount, 1);
    expect(tester.takeException(), isNull);
  });

  testWidgets('renders loading state without an active retry button', (
    tester,
  ) async {
    final router = _router(
      const AffirmationUnavailableWidget(isLoading: true, onRetry: null),
    );
    addTearDown(router.dispose);
    await tester.pumpWidget(_testApp(router));

    expect(find.text('Загружаем аффирмацию…'), findsOneWidget);
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    expect(find.text('Попробовать снова'), findsNothing);
    expect(tester.takeException(), isNull);
  });
}

GoRouter _router(Widget child, {double width = 390, double scale = 1}) =>
    GoRouter(
      routes: [
        GoRoute(
          path: '/',
          builder: (context, _) => Theme(
            data: AppThemeDark.instance.getThemeData(context),
            child: Scaffold(
              body: Center(
                child: SizedBox(
                  width: width,
                  child: SingleChildScrollView(
                    child: MediaQuery(
                      data: MediaQuery.of(
                        context,
                      ).copyWith(textScaler: TextScaler.linear(scale)),
                      child: child,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
        GoRoute(
          path: AffirmationRoute.routeName,
          name: AffirmationRoute.routeName,
          builder: (_, _) => const Scaffold(body: Text('collection')),
        ),
      ],
    );

Widget _testApp(GoRouter router) => MaterialApp.router(
  routerConfig: router,
  locale: const Locale('ru'),
  localizationsDelegates: const [
    AppLocalizations.delegate,
    ...GlobalMaterialLocalizations.delegates,
  ],
  supportedLocales: AppLocaleService.supportedLocales,
);
