import 'package:asteria_app/core/localization/localization.dart';
import 'package:asteria_app/core/routing/app_route.dart';
import 'package:asteria_app/core/ui_kit/theme/theme.dart';
import 'package:asteria_app/features/home/presentation/widgets/affirmation_of_the_day_widget.dart';
import 'package:asteria_app/features/affirmation/player/player_artwork.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

void main() {
  const channel = MethodChannel('asteria/practice-audio');
  final messenger =
      TestWidgetsFlutterBinding.ensureInitialized().defaultBinaryMessenger;
  final calls = <String>[];
  final native = <String, Object>{};
  setUp(() {
    calls.clear();
    native.addAll({
      'duration': 75000,
      'position': 0,
      'playing': false,
      'loop': false,
      'complete': false,
    });
    messenger.setMockMethodCallHandler(channel, (call) async {
      calls.add(call.method);
      switch (call.method) {
        case 'toggle':
          native['playing'] = !(native['playing'] as bool);
        case 'seek':
          native['position'] = call.arguments['ms'] as int;
        case 'close':
          native['playing'] = false;
          native['position'] = 0;
          return null;
      }
      return native;
    });
  });
  tearDown(() => messenger.setMockMethodCallHandler(channel, null));

  testWidgets(
    'plays and pauses the artwork in place, then releases audio when covered',
    (tester) async {
      late final GoRouter router;
      int starts = 0;
      router = _router(
        AffirmationOfTheDayWidget(
          onPlay: () => starts++,
          onOpenCollection: () async =>
              router.pushNamed<void>(AffirmationRoute.routeName),
        ),
      );
      addTearDown(router.dispose);
      await tester.pumpWidget(_testApp(router));
      expect(find.text('Аффирмация дня'), findsOneWidget);
      expect(calls, isEmpty);
      PlayerArtwork art() => tester.widget(find.byType(PlayerArtwork));
      expect(art().playing, isFalse);
      await tester.tapAt(tester.getCenter(find.byType(PlayerArtwork)));
      await tester.pump();
      expect(calls, containsAllInOrder(['load', 'toggle']));
      expect(art().playing, isTrue);
      expect(starts, 1);
      expect(router.routerDelegate.currentConfiguration.uri.path, '/');
      await tester.tap(find.bySemanticsLabel('Пауза'));
      await tester.pumpAndSettle();
      expect(art().playing, isFalse);
      expect(starts, 1);
      await tester.tap(find.bySemanticsLabel('Воспроизвести'));
      await tester.pump();
      native['position'] = 2400;
      await tester.pump(const Duration(milliseconds: 150));
      expect(art().position, const Duration(milliseconds: 2400));
      await tester.tap(find.text('Все аффирмации'));
      await tester.pumpAndSettle();
      expect(find.text('collection'), findsOneWidget);
      expect(calls.last, 'close');
      router.pop();
      await tester.pumpAndSettle();
      expect(art().playing, isFalse);
      await tester.tap(find.bySemanticsLabel('Воспроизвести'));
      await tester.pump();
      expect(calls, containsAllInOrder(['close', 'load', 'seek', 'toggle']));
      expect(art().position, const Duration(milliseconds: 2400));
      await tester.pumpWidget(const SizedBox.shrink());
      expect(calls.last, 'close');
    },
  );

  testWidgets(
    'a collection error leaves the offline recording playable and allows retry',
    (tester) async {
      var attempts = 0;
      late final GoRouter router;
      router = _router(
        AffirmationOfTheDayWidget(
          onOpenCollection: () async {
            if (++attempts == 1) throw StateError('offline');
            await router.pushNamed<void>(AffirmationRoute.routeName);
          },
        ),
      );
      addTearDown(router.dispose);
      await tester.pumpWidget(_testApp(router));
      await tester.tap(find.text('Все аффирмации'));
      await tester.pumpAndSettle();
      expect(
        find.text('Не удалось загрузить аффирмацию. Проверьте интернет.'),
        findsOneWidget,
      );
      await tester.tap(find.bySemanticsLabel('Воспроизвести'));
      await tester.pump();
      expect(
        tester.widget<PlayerArtwork>(find.byType(PlayerArtwork)).playing,
        isTrue,
      );
      await tester.tap(find.text('Все аффирмации'));
      await tester.pumpAndSettle();
      expect(find.text('collection'), findsOneWidget);
      expect(calls.last, 'close');
    },
  );

  testWidgets(
    'changing tabs releases inline audio and keeps controls accessible at 200%',
    (tester) async {
      final active = ValueNotifier(true);
      addTearDown(active.dispose);
      final router = _router(
        ValueListenableBuilder<bool>(
          valueListenable: active,
          builder: (_, enabled, child) =>
              TickerMode(enabled: enabled, child: child!),
          child: AffirmationOfTheDayWidget(onOpenCollection: () async {}),
        ),
        width: 320,
        scale: 2,
      );
      addTearDown(router.dispose);
      await tester.pumpWidget(_testApp(router));
      expect(
        tester.getSize(find.bySemanticsLabel('Воспроизвести')).shortestSide,
        greaterThanOrEqualTo(44),
      );
      await tester.tap(find.bySemanticsLabel('Воспроизвести'));
      await tester.pump();
      active.value = false;
      await tester.pump();
      expect(calls.last, 'close');
      active.value = true;
      await tester.pumpAndSettle();
      expect(find.bySemanticsLabel('Воспроизвести'), findsOneWidget);
      expect(find.text('Все аффирмации'), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );
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
