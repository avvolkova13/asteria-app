import 'dart:io';
import 'dart:ui' as ui;
import 'package:asteria_app/app/data/repositories/user/user_repository.dart';
import 'package:asteria_app/app/providers/user_provider.dart';
import 'package:asteria_app/core/localization/localization.dart';
import 'package:asteria_app/core/ui_kit/theme/theme.dart';
import 'package:asteria_app/core/ui_kit/widgets/top_bar_geometry.dart';
import 'package:asteria_app/core/ui_kit/widgets/top_nav_bar.dart';
import 'package:asteria_app/features/anakra_chat/presentation/widgets/anakra_layout.dart';
import 'package:asteria_app/features/monetization/presentation/monetization_provider.dart';
import 'package:asteria_app/features/sonnik/presentation/widgets/sonnik_layout.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

class HeaderReviewBinding extends AutomatedTestWidgetsFlutterBinding {
  @override
  bool get disableShadows => false;
}

class HeaderUserRepo extends Fake implements UserRepository {}

class HeaderWallet extends ChangeNotifier implements MonetizationProvider {
  HeaderWallet(this.amount);
  final int amount;
  @override
  int get balance => amount;
  @override
  bool get effectivePro => false;
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

const captureKey = ValueKey('header-capture');
Future<void> save(WidgetTester tester, String name) async {
  await tester.runAsync(
    () => Future<void>.delayed(const Duration(milliseconds: 200)),
  );
  await tester.pumpAndSettle();
  final boundary = tester.renderObject<RenderRepaintBoundary>(
    find.byKey(captureKey),
  );
  await tester.runAsync(() async {
    final image = await boundary.toImage(pixelRatio: 1);
    final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
    await File(
      '/private/tmp/asteria-design-review/headers/$name.png',
    ).writeAsBytes(bytes!.buffer.asUint8List());
    image.dispose();
  });
}

void main() {
  HeaderReviewBinding();
  setUpAll(() async {
    Directory(
      '/private/tmp/asteria-design-review/headers',
    ).createSync(recursive: true);
    for (final font in [
      ('Lora', 'assets/fonts/lora/Lora-VariableFont_wght.ttf'),
      ('Onest', 'assets/fonts/onest/Onest-VariableFont_wght.ttf'),
      ('MaterialIcons', 'fonts/MaterialIcons-Regular.otf'),
      (
        'packages/cupertino_icons/CupertinoIcons',
        'packages/cupertino_icons/assets/CupertinoIcons.ttf',
      ),
    ]) {
      await (FontLoader(font.$1)..addFont(rootBundle.load(font.$2))).load();
    }
  });
  for (final language in ['ru', 'en']) {
    for (final compact in [false, true]) {
      for (final kind in [
        'payment',
        'moon',
        'transparent',
        'onlyCollapsed',
        'sonnik',
        'anakra',
      ]) {
        testWidgets('real header $kind $language ${compact ? '320x2' : '390'}', (
          tester,
        ) async {
          final semantics = tester.ensureSemantics();
          try {
            tester.view.devicePixelRatio = 1;
            tester.view.physicalSize = compact
                ? const Size(320, 568)
                : const Size(390, 844);
            addTearDown(tester.view.reset);
            final user = UserProvider(userRepository: HeaderUserRepo());
            final wallet = HeaderWallet(compact ? 12345678 : 123);
            addTearDown(user.dispose);
            addTearDown(wallet.dispose);
            String title = '';
            await tester.pumpWidget(
              MultiProvider(
                providers: [
                  ChangeNotifierProvider<UserProvider>.value(value: user),
                  ChangeNotifierProvider<MonetizationProvider>.value(
                    value: wallet,
                  ),
                ],
                child: MaterialApp(
                  locale: Locale(language),
                  supportedLocales: AppLocaleService.supportedLocales,
                  localizationsDelegates: const [
                    AppLocalizations.delegate,
                    ...GlobalMaterialLocalizations.delegates,
                  ],
                  builder: (context, child) => Theme(
                    data: AppThemeDark.instance.getThemeData(context),
                    child: MediaQuery(
                      data: MediaQuery.of(context).copyWith(
                        padding: EdgeInsets.only(
                          top: compact ? 20 : 59,
                          bottom: compact ? 0 : 34,
                        ),
                        textScaler: TextScaler.linear(compact ? 2 : 1),
                        disableAnimations: true,
                      ),
                      child: RepaintBoundary(key: captureKey, child: child!),
                    ),
                  ),
                  home: Builder(
                    builder: (context) => Scaffold(
                      body: TextButton(
                        onPressed: () => Navigator.of(context).push(
                          MaterialPageRoute<void>(
                            builder: (context) {
                              final l = AppLocalizations.of(context);
                              title = switch (kind) {
                                'payment' => l.paymentTitle,
                                'sonnik' => l.dreamDictionaryTitle,
                                'anakra' => l.anakraTitle,
                                _ => l.natalChartTitle,
                              };
                              final sliver = [
                                'moon',
                                'transparent',
                                'onlyCollapsed',
                              ].contains(kind);
                              if (sliver) {
                                return Scaffold(
                                  backgroundColor: const Color(0xFF0F0A1A),
                                  body: CustomScrollView(
                                    slivers: [
                                      SliverPersistentHeader(
                                        pinned: true,
                                        delegate: TopNavBarDelegate.adaptive(
                                          context,
                                          userName: title,
                                          type: TopNavBarType.values.byName(
                                            kind,
                                          ),
                                          canPop: true,
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
                                  ),
                                );
                              }
                              return Scaffold(
                                backgroundColor: const Color(0xFF0F0A1A),
                                body: SafeArea(
                                  child: Column(
                                    children: [
                                      switch (kind) {
                                        'sonnik' => SonnikTopNavBar(
                                          title: title,
                                        ),
                                        'anakra' => const AnakraTopNavBar(),
                                        _ => TopNavBar(
                                          userName: title,
                                          type: TopNavBarType.payment,
                                          canPop: true,
                                        ),
                                      },
                                      const Expanded(child: SizedBox()),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                        child: const Text('open'),
                      ),
                    ),
                  ),
                ),
              ),
            );
            await tester.tap(find.text('open'));
            await tester.pumpAndSettle();
            final paragraph = tester.renderObject<RenderParagraph>(
              find.text(title),
            );
            expect(
              paragraph.didExceedMaxLines,
              isFalse,
              reason: 'full readable title',
            );
            final headerRect = tester.getRect(find.text(title));
            expect(headerRect.left, greaterThanOrEqualTo(16));
            expect(headerRect.right, lessThanOrEqualTo(compact ? 304 : 374));
            expect(tester.takeException(), isNull);
            final key =
                '${kind}_${language}_${compact ? '320_text2_longbalance' : '390'}';
            await save(tester, key);
            if (['moon', 'transparent', 'onlyCollapsed'].contains(kind)) {
              final before = tester.getRect(find.text(title));
              await tester.drag(
                find.byType(CustomScrollView),
                const Offset(0, -400),
              );
              await tester.pumpAndSettle();
              expect(tester.getRect(find.text(title)), before);
              expect(tester.takeException(), isNull);
              await save(tester, '${key}_scrolled');
            }
            final backLabel = MaterialLocalizations.of(
              tester.element(find.text(title)),
            ).backButtonTooltip;
            final tooltip = find.byTooltip(backLabel);
            await tester.tap(
              tooltip.evaluate().isNotEmpty
                  ? tooltip.first
                  : find.bySemanticsLabel(backLabel).first,
            );
            await tester.pumpAndSettle();
            expect(find.text('open'), findsOneWidget);
          } finally {
            semantics.dispose();
          }
        });
      }
    }
  }
}
