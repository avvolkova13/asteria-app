import 'dart:io';
import 'package:asteria_app/core/localization/localization.dart';
import 'package:asteria_app/core/routing/app_route.dart';
import 'package:asteria_app/core/ui_kit/theme/theme.dart';
import 'package:asteria_app/core/ui_kit/app_typography.dart';
import 'package:asteria_app/core/ui_kit/widgets/top_nav_bar.dart';
import 'package:asteria_app/app/providers/user_provider.dart';
import 'package:asteria_app/features/monetization/presentation/monetization_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'header_review_capture_test.dart' as header;

void main() {
  header.HeaderReviewBinding();
  setUpAll(() async {
    Directory(
      '/private/tmp/asteria-design-review/headers',
    ).createSync(recursive: true);
    for (final font in [
      ('Lora', 'assets/fonts/lora/Lora-VariableFont_wght.ttf'),
      ('Onest', 'assets/fonts/onest/Onest-VariableFont_wght.ttf'),
      ('MaterialIcons', 'fonts/MaterialIcons-Regular.otf'),
    ]) {
      await (FontLoader(font.$1)..addFont(rootBundle.load(font.$2))).load();
    }
  });
  for (final lang in ['ru', 'en']) {
    for (final config in [
      ('normal', 390.0, 1.0, 42, true),
      ('compact', 320.0, 2.0, 42, true),
      ('long', 320.0, 2.0, 12345678, true),
      ('practices', 320.0, 2.0, 42, false),
    ]) {
      testWidgets(
        'home account $lang ${config.$1} full link, actions, and pinned height',
        (tester) async {
          tester.view.devicePixelRatio = 1;
          tester.view.physicalSize = Size(config.$2, 844);
          addTearDown(tester.view.reset);
          final user = UserProvider(userRepository: header.HeaderUserRepo());
          final wallet = header.HeaderWallet(config.$4);
          addTearDown(user.dispose);
          addTearDown(wallet.dispose);
          late String profile;
          final router = GoRouter(
            routes: [
              GoRoute(
                path: '/',
                builder: (context, state) {
                  profile = AppLocalizations.of(context).navProfile;
                  return Scaffold(
                    body: CustomScrollView(
                      slivers: [
                        PinnedHeaderSliver(
                          child: SafeArea(
                            bottom: false,
                            child: HomeAccountBar(
                              showAccountActions: config.$5,
                              accountLabelStyle: AppTypography.navTitle,
                            ),
                          ),
                        ),
                        const SliverToBoxAdapter(child: SizedBox(height: 1800)),
                      ],
                    ),
                  );
                },
              ),
              for (final destination in [
                HomeProfileRoute.routeName,
                BalanceRoute.routeName,
                SubscriptionRoute.routeName,
              ])
                GoRoute(
                  path: destination,
                  name: destination,
                  builder: (context, state) =>
                      Scaffold(body: Text(destination)),
                ),
            ],
          );
          addTearDown(router.dispose);
          await tester.pumpWidget(
            MultiProvider(
              providers: [
                ChangeNotifierProvider<UserProvider>.value(value: user),
                ChangeNotifierProvider<MonetizationProvider>.value(
                  value: wallet,
                ),
              ],
              child: MaterialApp.router(
                routerConfig: router,
                locale: Locale(lang),
                supportedLocales: AppLocaleService.supportedLocales,
                localizationsDelegates: const [
                  AppLocalizations.delegate,
                  ...GlobalMaterialLocalizations.delegates,
                ],
                builder: (context, child) => Theme(
                  data: AppThemeDark.instance.getThemeData(context),
                  child: MediaQuery(
                    data: MediaQuery.of(context).copyWith(
                      padding: const EdgeInsets.only(top: 20, bottom: 34),
                      textScaler: TextScaler.linear(config.$3),
                      disableAnimations: true,
                    ),
                    child: RepaintBoundary(
                      key: header.captureKey,
                      child: child!,
                    ),
                  ),
                ),
              ),
            ),
          );
          await tester.pumpAndSettle();
          await header.save(tester, 'home_account_${lang}_${config.$1}');
          final text = find.text(profile);
          expect(
            tester.renderObject<RenderParagraph>(text).didExceedMaxLines,
            isFalse,
          );
          final before = tester.getRect(text);
          final barRect = tester.getRect(find.byType(HomeAccountBar));
          expect(before.bottom, lessThanOrEqualTo(barRect.bottom));
          await tester.drag(
            find.byType(CustomScrollView),
            const Offset(0, -500),
          );
          await tester.pumpAndSettle();
          expect(tester.getRect(text), before);
          expect(tester.takeException(), isNull);
          await tester.tap(text);
          await tester.pumpAndSettle();
          expect(find.text(HomeProfileRoute.routeName), findsOneWidget);
          router.pop();
          await tester.pumpAndSettle();
          if (config.$5) {
            await tester.tap(find.text('${config.$4} '));
            await tester.pumpAndSettle();
            expect(find.text(BalanceRoute.routeName), findsOneWidget);
            router.pop();
            await tester.pumpAndSettle();
            await tester.tap(find.text('PRO'));
            await tester.pumpAndSettle();
            expect(find.text(SubscriptionRoute.routeName), findsOneWidget);
          }
          expect(tester.takeException(), isNull);
        },
      );
    }
  }
}
