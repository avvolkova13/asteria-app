import 'package:asteria_app/app/data/repositories/user/user_repository.dart';
import 'package:asteria_app/app/providers/user_provider.dart';
import 'package:asteria_app/core/routing/app_route.dart';
import 'package:asteria_app/core/ui_kit/theme/theme.dart';
import 'package:asteria_app/core/ui_kit/widgets/top_nav_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

void main() {
  testWidgets('renders the transparent greeting with the Figma title style', (
    tester,
  ) async {
    final userProvider = UserProvider(userRepository: _UnusedUserRepository());
    addTearDown(userProvider.dispose);

    const greeting = 'Привет, Анастасия!';
    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) => Theme(
            data: AppThemeDark.instance.getThemeData(context),
            child: ChangeNotifierProvider<UserProvider>.value(
              value: userProvider,
              child: const Scaffold(
                body: TopNavBar(
                  userName: greeting,
                  type: TopNavBarType.transparent,
                ),
              ),
            ),
          ),
        ),
      ),
    );

    final greetingText = tester.widget<Text>(find.text(greeting));
    expect(greetingText.style?.fontFamily, 'Lora');
    expect(greetingText.style?.fontSize, 17);
    expect(greetingText.style?.fontWeight, FontWeight.w600);
    expect(greetingText.style?.height, 1.2);
    expect(greetingText.style?.letterSpacing, -0.408);
    expect(greetingText.style?.color, Colors.white);
    expect(tester.takeException(), isNull);
  });

  testWidgets('opens subscription screen from the PRO badge', (tester) async {
    final userProvider = UserProvider(userRepository: _UnusedUserRepository());
    addTearDown(userProvider.dispose);

    Object? subscriptionExtra;
    final router = GoRouter(
      routes: [
        GoRoute(
          path: '/',
          builder: (context, state) =>
              ChangeNotifierProvider<UserProvider>.value(
                value: userProvider,
                child: const Scaffold(
                  body: TopNavBar(
                    userName: 'Гороскоп',
                    type: TopNavBarType.transparent,
                  ),
                ),
              ),
        ),
        GoRoute(
          path: SubscriptionRoute.routeName,
          name: SubscriptionRoute.routeName,
          builder: (context, state) {
            subscriptionExtra = state.extra;
            return const Scaffold(body: Text('subscription destination'));
          },
        ),
      ],
    );

    await tester.pumpWidget(
      MaterialApp.router(
        routerConfig: router,
        builder: (context, child) => Theme(
          data: AppThemeDark.instance.getThemeData(context),
          child: child ?? const SizedBox.shrink(),
        ),
      ),
    );

    await tester.tap(find.text('PRO'));
    await tester.pumpAndSettle();

    expect(find.text('subscription destination'), findsOneWidget);
    expect(subscriptionExtra, isA<SubscriptionRouteParams>());
    expect(
      (subscriptionExtra as SubscriptionRouteParams).originSurface,
      'top_nav_pro_badge',
    );
  });
}

class _UnusedUserRepository implements UserRepository {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}
