import 'package:asteria_app/app/data/repositories/user/user_repository.dart';
import 'package:asteria_app/app/providers/user_provider.dart';
import 'package:asteria_app/core/routing/app_route.dart';
import 'package:asteria_app/core/ui_kit/theme/theme.dart';
import 'package:asteria_app/core/ui_kit/widgets/top_nav_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

void main() {
  for (final type in [
    TopNavBarType.transparent,
    TopNavBarType.moon,
    TopNavBarType.onlyCollapsed,
  ]) {
    testWidgets('scrolled $type header keeps light status and no legacy sky', (
      tester,
    ) async {
      final user = UserProvider(userRepository: _UnusedUserRepository());
      addTearDown(user.dispose);
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) => Theme(
              data: AppThemeDark.instance.getThemeData(context),
              child: ChangeNotifierProvider<UserProvider>.value(
                value: user,
                child: Scaffold(
                  body: CustomScrollView(
                    slivers: [
                      SliverPersistentHeader(
                        pinned: true,
                        delegate: TopNavBarDelegate(
                          userName: 'Расклад',
                          type: type,
                        ),
                      ),
                      const SliverToBoxAdapter(child: SizedBox(height: 1800)),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      );
      await tester.drag(find.byType(CustomScrollView), const Offset(0, -400));
      await tester.pumpAndSettle();
      final oldSky = find.byWidgetPredicate(
        (widget) =>
            widget is Image &&
            widget.image is AssetImage &&
            (widget.image as AssetImage).assetName.startsWith(
              'assets/background/app_bar_',
            ),
      );
      expect(oldSky, findsNothing);
      final regions = tester.widgetList<AnnotatedRegion<SystemUiOverlayStyle>>(
        find.byType(AnnotatedRegion<SystemUiOverlayStyle>),
      );
      expect(
        regions.any(
          (region) => region.value.statusBarBrightness == Brightness.dark,
        ),
        isTrue,
      );
      expect(find.text('Расклад').hitTestable(), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  }

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

  for (final pushed in [false, true]) {
    testWidgets('back keeps a page visible: pushed=$pushed', (tester) async {
      final userProvider = UserProvider(
        userRepository: _UnusedUserRepository(),
      );
      addTearDown(userProvider.dispose);
      final router = GoRouter(
        initialLocation: pushed ? '/home' : '/detail',
        routes: [
          GoRoute(
            path: '/home',
            name: HomeRoute.routeName,
            builder: (_, _) => const Scaffold(body: Text('home destination')),
          ),
          GoRoute(
            path: '/detail',
            builder: (_, _) => ChangeNotifierProvider<UserProvider>.value(
              value: userProvider,
              child: const Scaffold(
                body: TopNavBar(
                  userName: 'Detail',
                  type: TopNavBarType.transparent,
                  canPop: true,
                ),
              ),
            ),
          ),
        ],
      );
      addTearDown(router.dispose);
      await tester.pumpWidget(
        MaterialApp.router(
          routerConfig: router,
          builder: (context, child) => Theme(
            data: AppThemeDark.instance.getThemeData(context),
            child: child!,
          ),
        ),
      );
      if (pushed) {
        router.push('/detail');
        await tester.pumpAndSettle();
      }
      await tester.tap(find.bySemanticsLabel('Back'));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      expect(find.text('home destination'), findsOneWidget);
    });
  }

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
