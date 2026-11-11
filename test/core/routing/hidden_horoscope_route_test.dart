import 'package:asteria_app/core/routing/app_route.dart';
import 'package:asteria_app/core/services/global_loader_service.dart';
import 'package:asteria_app/features/horoscope/presentation/horoscope_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

void main() {
  testWidgets('old links resolve to Home before constructing the horoscope', (
    tester,
  ) async {
    final router = GoRouter(
      initialLocation: '/horoscope?period=year',
      routes: [
        HoroscopeRoute(),
        GoRoute(path: '/home', builder: (_, __) => const Text('Home')),
        GoRoute(path: '/other', builder: (_, __) => const Text('Other')),
      ],
    );
    addTearDown(router.dispose);
    await tester.pumpWidget(MaterialApp.router(routerConfig: router));
    await tester.pumpAndSettle();
    expect(router.routeInformationProvider.value.uri.path, '/home');
    expect(find.byType(HoroscopeScreen), findsNothing);
    router.go('/other');
    await tester.pumpAndSettle();
    router.goNamed(HoroscopeRoute.routeName);
    await tester.pumpAndSettle();
    expect(find.text('Home'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets(
    'a directly restored old screen does not start its analytics or purchase flow',
    (tester) async {
      final router = GoRouter(
        initialLocation: '/restored',
        routes: [
          GoRoute(
            path: '/restored',
            builder: (_, __) => const HoroscopeScreen(),
          ),
          GoRoute(path: '/home', builder: (_, __) => const Text('Home')),
        ],
      );
      addTearDown(router.dispose);
      await tester.pumpWidget(MaterialApp.router(routerConfig: router));
      await tester.pumpAndSettle();
      expect(find.text('Home'), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );

  test('only the hidden feature suppresses its loader', () {
    final loader = GlobalLoaderService();
    addTearDown(loader.dispose);
    loader.showWithSpheres(GlobalLoaderType.horoscope);
    expect(loader.isLoading, isFalse);
    for (final type in [
      GlobalLoaderType.compatibility,
      GlobalLoaderType.natalCard,
    ]) {
      loader.showWithSpheres(type);
      expect(loader.loaderType, type);
      expect(loader.isLoading, isTrue);
      loader.hide();
    }
  });
}
