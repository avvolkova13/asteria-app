import 'package:asteria_app/core/ui_kit/ui_kit.dart';
import 'package:asteria_app/core/ui_kit/widgets/subscription_widget.dart';
import 'package:asteria_app/core/routing/app_route.dart';
import 'package:asteria_app/core/ui_kit/widgets/pro_badge_surface.dart';
import 'package:asteria_app/features/profile_flow/profile_flow_ui.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('keeps the compact PRO badge usable without a user provider', (
    tester,
  ) async {
    var taps = 0;
    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) {
            return Theme(
              data: AppThemeDark.instance.getThemeData(context),
              child: Scaffold(
                body: Center(child: SubscriptionWidget(onTap: () => taps++)),
              ),
            );
          },
        ),
      ),
    );

    final badgeFinder = find.byType(SubscriptionWidget);
    expect(badgeFinder, findsOneWidget);
    expect(tester.getSize(badgeFinder), const Size(76, 44));
    expect(tester.getSize(find.byType(ProBadgeSurface)), const Size(76, 28));
    expect(find.text('PRO'), findsOneWidget);
    expect(find.byType(SvgPicture), findsNothing);

    await tester.tap(badgeFinder);
    expect(taps, 1);

    final label = tester.widget<Text>(find.text('PRO'));
    expect(label.style?.fontFamily, 'Lora');
    expect(label.style?.fontSize, 17);
    expect(label.style?.fontWeight, FontWeight.w600);
    expect(label.style?.color, Colors.white);
    expect(tester.takeException(), isNull);
  });

  for (final active in [false, true]) {
    testWidgets(
      'opens subscription from a profile header and returns (PRO $active)',
      (tester) async {
        final router = GoRouter(
          routes: [
            GoRoute(
              path: '/',
              builder: (_, _) => Scaffold(
                body: Center(child: ProfileProPill(isActive: active)),
              ),
            ),
            GoRoute(
              path: '/subscription',
              name: SubscriptionRoute.routeName,
              pageBuilder: (context, state) => MaterialPage<void>(
                key: state.pageKey,
                name: SubscriptionRoute.routeName,
                child: Scaffold(
                  appBar: AppBar(title: const Text('Subscription')),
                  body: Center(child: ProfileProPill(isActive: active)),
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
        await tester.pumpAndSettle();
        final badge = find.byType(SubscriptionWidget);
        await tester.tapAt(tester.getTopLeft(badge) + const Offset(38, 2));
        await tester.pumpAndSettle();
        expect(find.text('Subscription'), findsOneWidget);
        await tester.tap(find.text('PRO'));
        await tester.pumpAndSettle();
        await tester.pageBack();
        await tester.pumpAndSettle();
        expect(find.text('Subscription'), findsNothing);
        expect(badge, findsOneWidget);
      },
    );
  }
}
