import 'dart:async';

import 'package:asteria_app/core/routing/practice_link_intake.dart';
import 'package:asteria_app/features/affirmation/player/practice_link.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

void main() {
  const player = '/affirmation/player';
  final https = Uri.parse(PracticeLink.url);
  final scheme = Uri.parse('asteria://practice/i-have-time');

  test('only the shared recording is accepted from the registered origins', () {
    for (final link in [
      https,
      scheme,
      Uri.parse(
        'https://asteria-calendar.com/practice/i-have-time?utm_source=share',
      ),
    ]) {
      expect(PracticeLink.matches(link), isTrue, reason: link.toString());
    }
    for (final link in [
      'asteria://payment-return?status=success',
      'asteria://practice/other',
      'https://asteria-calendar.com.evil.test/practice/i-have-time/',
      'https://u@asteria-calendar.com/practice/i-have-time/',
      'https://asteria-calendar.com:123/practice/i-have-time/',
      'https://asteria-calendar.com/practice/i-have-time/more',
      'http://asteria-calendar.com/practice/i-have-time/',
    ]) {
      expect(PracticeLink.matches(Uri.parse(link)), isFalse, reason: link);
    }
  });

  GoRouter routerFor(String start) => GoRouter(
    initialLocation: start,
    routes: [
      for (final path in ['/home', '/onboarding', '/auth/login', player])
        GoRoute(
          path: path,
          name: path,
          builder: (_, _) => Scaffold(body: Text(path)),
        ),
    ],
  );

  for (final start in ['/home', '/onboarding', '/auth/login']) {
    testWidgets('cold public link opens over $start and back restores it', (
      tester,
    ) async {
      final router = routerFor(start);
      final links = StreamController<Uri>.broadcast(sync: true);
      final intake = PracticeLinkIntake(playerRouteName: player);
      intake.start(links.stream, () async => https);
      await tester.pump();
      await tester.pumpWidget(MaterialApp.router(routerConfig: router));
      intake.attachRouter(router);
      await tester.pumpAndSettle();
      expect(find.text(player), findsOneWidget);
      // OS channels can report the same initial link a second time.
      links.add(https);
      await tester.pumpAndSettle();
      router.pop();
      await tester.pumpAndSettle();
      expect(find.text(start), findsOneWidget);
      expect(router.canPop(), isFalse);
      intake.dispose();
      await links.close();
      await tester.pumpWidget(const SizedBox());
      router.dispose();
    });
  }

  testWidgets(
    'warm links, repeats and payment returns preserve the route stack',
    (tester) async {
      final router = routerFor('/home');
      final links = StreamController<Uri>.broadcast(sync: true);
      final initial = Completer<Uri?>();
      final intake = PracticeLinkIntake(playerRouteName: player);
      await tester.pumpWidget(MaterialApp.router(routerConfig: router));
      await tester.pumpAndSettle();
      intake.start(links.stream, () => initial.future);
      intake.attachRouter(router);
      links.add(Uri.parse('asteria://payment-return'));
      initial.complete(https);
      await tester.pumpAndSettle();
      expect(find.text('/home'), findsOneWidget);
      for (final link in [scheme, https]) {
        links.add(link);
        await tester.pumpAndSettle();
        expect(find.text(player), findsOneWidget);
        router.pop();
        await tester.pumpAndSettle();
        expect(router.canPop(), isFalse);
      }
      // The regular catalog can open a player independently of a shared link.
      unawaited(router.pushNamed<void>(player));
      await tester.pumpAndSettle();
      links.add(https);
      await tester.pumpAndSettle();
      router.pop();
      await tester.pumpAndSettle();
      expect(router.canPop(), isFalse);
      intake.dispose();
      await links.close();
      await tester.pumpWidget(const SizedBox());
      router.dispose();
    },
  );
}
