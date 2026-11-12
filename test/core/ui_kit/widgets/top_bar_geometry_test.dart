import 'package:asteria_app/app/data/repositories/user/user_repository.dart';
import 'package:asteria_app/app/providers/user_provider.dart';
import 'package:asteria_app/core/localization/localization.dart';
import 'package:asteria_app/core/ui_kit/theme/theme.dart';
import 'package:asteria_app/core/ui_kit/widgets/top_bar_geometry.dart';
import 'package:asteria_app/core/ui_kit/widgets/top_nav_bar.dart';
import 'package:asteria_app/features/anakra_chat/presentation/widgets/anakra_layout.dart';
import 'package:asteria_app/features/monetization/presentation/monetization_provider.dart';
import 'package:asteria_app/features/profile_flow/profile_flow_ui.dart';
import 'package:asteria_app/features/sonnik/presentation/widgets/sonnik_layout.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

void main() {
  for (final inset in [20.0, 59.0, 62.0]) {
    for (final scale in [1.0, 1.6]) {
      testWidgets(
        'headers share the safe-area baseline: inset=$inset scale=$scale',
        (tester) async {
          tester.view.physicalSize = const Size(390, 844);
          tester.view.devicePixelRatio = 1;
          addTearDown(tester.view.reset);
          final user = UserProvider(userRepository: _Repository());
          final wallet = _Wallet();
          addTearDown(user.dispose);
          addTearDown(wallet.dispose);
          for (final kind in [
            'home',
            'profile',
            'sonnik',
            'anakra',
            'moon',
            'transparent',
            'onlyCollapsed',
          ]) {
            await tester.pumpWidget(
              MultiProvider(
                providers: [
                  ChangeNotifierProvider<UserProvider>.value(value: user),
                  ChangeNotifierProvider<MonetizationProvider>.value(
                    value: wallet,
                  ),
                ],
                child: MaterialApp(
                  locale: const Locale('ru'),
                  supportedLocales: AppLocaleService.supportedLocales,
                  localizationsDelegates: const [
                    AppLocalizations.delegate,
                    ...GlobalMaterialLocalizations.delegates,
                  ],
                  home: Builder(
                    builder: (context) => Theme(
                      data: AppThemeDark.instance.getThemeData(context),
                      child: MediaQuery(
                        data: MediaQuery.of(context).copyWith(
                          padding: EdgeInsets.only(top: inset),
                          textScaler: TextScaler.linear(scale),
                          disableAnimations: true,
                        ),
                        child: Scaffold(
                          body: Builder(
                            builder: (context) {
                              if ([
                                'moon',
                                'transparent',
                                'onlyCollapsed',
                              ].contains(kind)) {
                                return CustomScrollView(
                                  key: ValueKey(kind),
                                  slivers: [
                                    SliverPersistentHeader(
                                      pinned: true,
                                      delegate: TopNavBarDelegate(
                                        userName: 'Заголовок',
                                        canPop: true,
                                        type: TopNavBarType.values.byName(kind),
                                        topInset: MediaQuery.paddingOf(
                                          context,
                                        ).top,
                                        toolbarHeight:
                                            AsteriaTopBarMetrics.heightOf(
                                              context,
                                            ),
                                      ),
                                    ),
                                    const SliverToBoxAdapter(
                                      child: SizedBox(height: 1800),
                                    ),
                                  ],
                                );
                              }
                              final header = switch (kind) {
                                'home' => const HomeAccountBar(),
                                'profile' => const Padding(
                                  padding: EdgeInsets.symmetric(horizontal: 16),
                                  child: ProfileFlowHeader(
                                    title: 'Заголовок',
                                    canPop: true,
                                  ),
                                ),
                                'sonnik' => const SonnikTopNavBar(
                                  title: 'Заголовок',
                                ),
                                _ => const AnakraTopNavBar(),
                              };
                              return SafeArea(
                                bottom: false,
                                child: Column(children: [header]),
                              );
                            },
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            );
            await tester.pumpAndSettle();
            final frame = find.byType(AsteriaTopBarFrame).first;
            final rect = tester.getRect(frame);
            expect(rect.top, closeTo(inset, 0.01), reason: kind);
            expect(rect.height, closeTo(52, 0.01), reason: kind);
            expect(tester.takeException(), isNull, reason: kind);
            if (find.byType(CustomScrollView).evaluate().isNotEmpty) {
              await tester.drag(
                find.byType(CustomScrollView),
                const Offset(0, -300),
              );
              await tester.pumpAndSettle();
              expect(
                tester.getRect(frame).top,
                closeTo(inset, 0.01),
                reason: '$kind scrolled',
              );
              expect(
                tester.getRect(frame).height,
                closeTo(rect.height, 0.01),
                reason: '$kind scrolled',
              );
              expect(tester.takeException(), isNull);
            }
          }
        },
      );
    }
  }
}

class _Repository implements UserRepository {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _Wallet extends ChangeNotifier implements MonetizationProvider {
  @override
  int get balance => 123;
  @override
  bool get effectivePro => false;
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}
