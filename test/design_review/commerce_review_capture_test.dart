import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:asteria_app/core/di/di.dart';
import 'package:asteria_app/core/localization/localization.dart';
import 'package:asteria_app/core/ui_kit/ui_kit.dart';
import 'package:asteria_app/core/analytics/analytics_facade.dart';
import 'package:asteria_app/core/analytics/product_analytics_service.dart';
import 'package:asteria_app/core/services/global_loader_service.dart';
import 'package:asteria_app/app/providers/user_provider.dart';

import '../features/subscription/native_subscription_analytics_test.dart'
    as sub;
import '../features/coins_paywall/native_coins_analytics_test.dart' as coins;
import '../features/balance/balance_history_visual_test.dart'
    show referenceEntries;

import 'package:asteria_app/core/payments/routing/payment_provider_route.dart';
import 'package:asteria_app/features/subscription/presentation/cubit/paywall_cubit.dart';
import 'package:asteria_app/features/subscription/presentation/cubit/paywall_state.dart';
import 'package:asteria_app/features/subscription/presentation/subscription_screen.dart';
import 'package:asteria_app/features/coins_paywall/presentation/screens/coins_paywall_screen.dart';
import 'package:asteria_app/features/monetization/presentation/monetization_provider.dart';
import 'package:asteria_app/core/ui_kit/widgets/closed_content_modal.dart';
import 'package:asteria_app/features/shop/presentation/widgets/purchase_modal_sheet.dart';
import 'package:asteria_app/app/data/models/shop_item/shop_item_model.dart';
import 'package:asteria_app/features/balance/presentation/balance_history_controller.dart';
import 'package:asteria_app/features/balance/presentation/screens/balance_history_screen.dart';
import 'package:asteria_app/features/monetization/domain/monetization_models.dart';

import 'dart:async';

class ReviewWallet extends sub.TestMonetization {
  int amount = 230;
  bool failCheckout = false;
  bool failAccessRefresh = false;
  @override
  int neededBalanceFor(int price) {
    if (failCheckout) throw StateError('review checkout failure');
    return (price - amount).clamp(0, price);
  }

  bool reviewPro = false;
  @override
  bool get effectivePro => reviewPro;
  void setPro(bool active) {
    reviewPro = active;
    notifyListeners();
  }

  @override
  int get balance => amount;
  @override
  bool canSpend(int value) => amount >= value;
  @override
  int balanceAfterSpend(int value) => amount - value;
  @override
  bool isCurrentUser(String uid) => uid == 'review';
  @override
  Future<void> refreshForAccess() async {
    if (failAccessRefresh) throw StateError('review refresh failure');
  }

  @override
  Future<void> refresh({bool requireFresh = false}) async {}
  @override
  MonetizationStateModel? get state => MonetizationStateModel(
    uid: 'review',
    catalogRevision: 1,
    wallet: WalletSnapshotModel(
      uid: 'review',
      balance: amount,
      debt: 0,
      sequence: 1,
      version: 1,
      updatedAt: DateTime(2026, 11, 16),
    ),
    effectivePro: effectivePro,
    effectiveGrants: const [],
    rewards: const [],
    requestQuotas: const {},
    rolloutPolicy: const {},
  );
}

class ReviewBinding extends AutomatedTestWidgetsFlutterBinding {
  @override
  bool get disableShadows => false;
}

const captureKey = ValueKey('forms-review-capture');
Future<void> capture(WidgetTester tester, String name) async {
  debugPrint('CAPTURE $name');
  await tester.runAsync(
    () => Future<void>.delayed(const Duration(milliseconds: 350)),
  );
  await tester.pump(const Duration(milliseconds: 100));
  final context = tester.element(find.byKey(captureKey));
  final providers = <ImageProvider>{
    for (final image in tester.widgetList<Image>(find.byType(Image)))
      image.image,
    for (final box in tester.widgetList<DecoratedBox>(
      find.byType(DecoratedBox),
    ))
      if (box.decoration case BoxDecoration(image: final image?)) image.image,
  };
  await tester.runAsync(() async {
    await Future.wait(
      providers.map((p) => precacheImage(p, context)),
    ).timeout(const Duration(seconds: 3), onTimeout: () => []);
  });
  await tester.pump();
  await tester.runAsync(
    () => Future<void>.delayed(const Duration(milliseconds: 100)),
  );
  await tester.pump(const Duration(milliseconds: 100));
  final boundary = tester.renderObject<RenderRepaintBoundary>(
    find.byKey(captureKey),
  );
  await tester.runAsync(() async {
    final image = await boundary.toImage(pixelRatio: 1);
    final data = await image.toByteData(format: ui.ImageByteFormat.png);
    await File(
      '/private/tmp/asteria-design-review/commerce/$name.png',
    ).writeAsBytes(data!.buffer.asUint8List());
    image.dispose();
  });
}

Future<void> reviewPump(
  WidgetTester t,
  Widget screen,
  sub.TestMonetization wallet,
  sub.TestUser user,
  String lang,
  bool compact,
) async {
  t.view.devicePixelRatio = 1;
  t.view.physicalSize = compact ? const Size(320, 568) : const Size(390, 844);
  await t.pumpWidget(
    MultiProvider(
      providers: [
        ChangeNotifierProvider<UserProvider>.value(value: user),
        ChangeNotifierProvider<MonetizationProvider>.value(value: wallet),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
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
              textScaler: TextScaler.linear(compact ? 2 : 1),
              disableAnimations: true,
              padding: EdgeInsets.only(
                top: compact ? 20 : 59,
                bottom: compact ? 0 : 34,
              ),
            ),
            child: RepaintBoundary(key: captureKey, child: child!),
          ),
        ),
        home: screen,
      ),
    ),
  );
  await t.pumpAndSettle();
}

Future<void> bottom(WidgetTester t, String name) async {
  for (final e in find.byType(Scrollable).evaluate()) {
    final p = ((e as StatefulElement).state as ScrollableState).position;
    if (p.hasContentDimensions) p.jumpTo(p.maxScrollExtent);
  }
  await t.pump();
  await capture(t, '${name}_bottom');
}

void main() {
  ReviewBinding();
  setUpAll(() async {
    Directory(
      '/private/tmp/asteria-design-review/commerce',
    ).createSync(recursive: true);
    for (final font in [
      ('MaterialIcons', 'fonts/MaterialIcons-Regular.otf'),
      (
        'packages/cupertino_icons/CupertinoIcons',
        'packages/cupertino_icons/assets/CupertinoIcons.ttf',
      ),
      ('Lora', 'assets/fonts/lora/Lora-VariableFont_wght.ttf'),
      ('Onest', 'assets/fonts/onest/Onest-VariableFont_wght.ttf'),
    ]) {
      await (FontLoader(font.$1)..addFont(rootBundle.load(font.$2))).load();
    }
  });
  for (final lang in ['ru', 'en']) {
    for (final compact in [false, true]) {
      testWidgets('commerce $lang compact=$compact', (t) async {
        await di.reset();
        final wallet = ReviewWallet();
        di.registerSingleton<GlobalLoaderService>(GlobalLoaderService());
        final user = sub.TestUser();
        final analytics = sub.RecordingFacade();
        di.registerSingleton<AnalyticsFacade>(analytics);
        di.registerSingleton<ProductAnalyticsService>(
          ProductAnalyticsService(analytics),
        );
        di.registerSingleton<PaymentProviderRouter>(
          PaymentProviderRouter(
            sub.Storefront(),
            platform: TargetPlatform.iOS,
            distributionChannel: DistributionChannel.global,
          ),
        );
        addTearDown(() async {
          await t.pumpWidget(const SizedBox());
          wallet.dispose();
          user.dispose();
          await di.reset();
          t.view.reset();
        });
        for (final kind in ['coins', 'pro']) {
          final suffix = '${lang}_${compact ? '320_text2' : '390'}';
          for (final stateName in [
            'loaded',
            'empty',
            'loading',
            'pending',
            'verifying',
            'error',
            'failed',
            'success',
          ]) {
            final dynamic cubit = kind == 'coins'
                ? coins.TestPaywall()
                : sub.TestPaywall(wallet);
            di.registerFactory<PaywallCubit>(() => cubit as PaywallCubit);
            await reviewPump(
              t,
              kind == 'coins'
                  ? const CoinsPaywallScreen()
                  : const SubscriptionScreen(),
              wallet,
              user,
              lang,
              compact,
            );
            final messenger = t.state<ScaffoldMessengerState>(
              find.byType(ScaffoldMessenger).first,
            );
            messenger.clearSnackBars();
            if ([
              'pending',
              'verifying',
              'failed',
              'success',
            ].contains(stateName)) {
              final price = find.text(
                kind == 'coins'
                    ? coins.product.localizedPrice
                    : sub.product.localizedPrice,
              );
              await t.ensureVisible(price);
              await t.pump();
              await t.tap(price);
              await t.pump();
              if (kind == 'pro') {
                final connect = find.text(
                  AppLocalizations.current.subscriptionConnect,
                );
                await t.ensureVisible(connect);
                await t.tap(connect);
                await t.pump();
              }
            }
            final id = kind == 'coins' ? coins.product.id : sub.product.id;
            if (stateName == 'success' && kind == 'pro') wallet.setPro(true);
            final state = switch (stateName) {
              'empty' => const PaywallProductsLoaded([]),
              'loading' => const PaywallLoading(),
              'pending' => PaywallPending(id),
              'verifying' => PaywallVerifying(id),
              'error' => const PaywallFailed(PaywallFailureCode.productsLoad),
              'failed' => PaywallFailed(
                PaywallFailureCode.purchaseFailed,
                productId: id,
              ),
              'success' => PaywallSuccess(productId: id, newBalance: 240),
              _ => null,
            };
            if (state != null) cubit.publish(state);
            await t.pump();
            await t.pump(const Duration(milliseconds: 350));
            for (final e in find.byType(Scrollable).evaluate()) {
              final p =
                  ((e as StatefulElement).state as ScrollableState).position;
              if (p.hasContentDimensions) p.jumpTo(p.minScrollExtent);
            }
            await t.pump();
            await capture(t, '${kind}_${stateName}_$suffix');
            await bottom(t, '${kind}_${stateName}_$suffix');
            await t.pumpWidget(const SizedBox());
            if (!cubit.isClosed) await cubit.close();
            await di.unregister<PaywallCubit>();
            wallet.setPro(false);
          }
        }

        final suffix = '${lang}_${compact ? '320_text2' : '390'}';
        for (final state in ['loaded', 'empty', 'error']) {
          final controller = BalanceHistoryController(
            loadPage: ({required filter, beforeSequence}) async {
              if (state == 'error') throw StateError('offline');
              return WalletHistoryPageModel(
                items: state == 'empty' ? [] : referenceEntries(),
                hasEntries: state != 'empty',
                nextBeforeSequence: null,
              );
            },
          );
          controller.setAccount('review');
          await reviewPump(
            t,
            BalanceHistoryView(
              controller: controller,
              balance: 230,
              hasPro: false,
              onBack: () {},
            ),
            wallet,
            user,
            lang,
            compact,
          );
          await capture(t, 'history_${state}_$suffix');
          await bottom(t, 'history_${state}_$suffix');
          await t.pumpWidget(const SizedBox());
          controller.dispose();
        }
        for (final kind in [
          'confirm',
          'insufficient',
          'locked',
          'quantity',
          'success',
          'error',
          'submitting',
          'checkout_error',
          'refresh_error',
        ]) {
          wallet.amount = ['insufficient', 'checkout_error'].contains(kind)
              ? 5
              : 230;
          wallet.failCheckout = kind == 'checkout_error';
          wallet.failAccessRefresh = kind == 'refresh_error';
          final pending = Completer<void>();
          await reviewPump(
            t,
            Scaffold(
              backgroundColor: AppColorsDark.homeCanvas,
              body: Builder(
                builder: (context) => TextButton(
                  onPressed: () => showModalBottomSheet<void>(
                    context: context,
                    isScrollControlled: true,
                    useSafeArea: true,
                    backgroundColor: Colors.transparent,
                    builder: (_) => kind == 'locked'
                        ? ClosedContentModal(
                            description: lang == 'ru'
                                ? 'Персональные рекомендации доступны в подписке PRO.'
                                : 'Personal recommendations are available with PRO.',
                            onSubscribe: () {},
                          )
                        : kind == 'quantity'
                        ? PurchaseModalSheet(
                            product: const ShopItemModel(
                              id: 'love-layout',
                              title: 'Любовный расклад',
                              category: 'Таро',
                              description: 'Расклад о любви',
                              price: 6,
                            ),
                            onConfirm: () {},
                          )
                        : SharedPurchaseModal(
                            purchaseTitle: lang == 'ru'
                                ? 'Любовный расклад'
                                : 'Love reading',
                            price: 10,
                            featureKey: 'love_deck',
                            showSuccessState: true,
                            onPurchase: () async {
                              if (kind == 'submitting') await pending.future;
                              if (kind == 'error') throw StateError('offline');
                            },
                          ),
                  ),
                  child: const Text('Open'),
                ),
              ),
            ),
            wallet,
            user,
            lang,
            compact,
          );
          await t.tap(find.text('Open'));
          await t.pumpAndSettle();
          if ([
            'success',
            'error',
            'submitting',
            'refresh_error',
          ].contains(kind)) {
            final buy = find.text(lang == 'ru' ? 'Купить' : 'Buy');
            await t.ensureVisible(buy);
            await t.tap(buy);
            await t.pump();
            await t.pump(const Duration(milliseconds: 350));
          }
          if (kind == 'checkout_error') {
            final buyStars = find.text(
              lang == 'ru' ? 'Купить звёздочёты' : 'Buy Star Coins',
            );
            await t.ensureVisible(buyStars);
            await t.tap(buyStars);
            await t.pump();
            await t.pump(const Duration(milliseconds: 350));
          }
          if (['error', 'checkout_error', 'refresh_error'].contains(kind)) {
            expect(
              find.byKey(const ValueKey('purchase-inline-error')),
              findsOneWidget,
            );
          }
          await capture(t, 'modal_${kind}_$suffix');
          await bottom(t, 'modal_${kind}_$suffix');
          await t.pumpWidget(const SizedBox());
          if (kind == 'submitting') pending.complete();
        }
      });
    }
  }
}
