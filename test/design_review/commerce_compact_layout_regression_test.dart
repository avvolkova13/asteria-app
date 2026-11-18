import 'package:asteria_app/app/data/models/shop_item/shop_item_model.dart';
import 'package:asteria_app/core/analytics/analytics_facade.dart';
import 'package:asteria_app/core/analytics/product_analytics_service.dart';
import 'package:asteria_app/core/di/di.dart';
import 'package:asteria_app/core/localization/localization.dart';
import 'package:asteria_app/core/payments/routing/payment_provider_route.dart';
import 'package:asteria_app/core/payments/routing/payment_return_link_service.dart';
import 'package:asteria_app/features/payments/presentation/cubit/arc_pay_checkout_state.dart';
import 'package:asteria_app/features/subscription/presentation/cubit/paywall_cubit.dart';
import 'package:asteria_app/features/subscription/presentation/subscription_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

import '../features/subscription/native_subscription_analytics_test.dart'
    as sub;
import 'commerce_review_capture_test.dart'
    show ReviewBinding, ReviewWallet, reviewPump;
import 'commerce_heading_readability_test.dart' show expectWholeWord;
import 'commerce_main_capture_test.dart' as main_capture;
import 'commerce_payments_capture_test.dart' as pay_capture;

void main() {
  ReviewBinding();
  setUpAll(() async {
    for (final f in [
      ('Lora', 'assets/fonts/lora/Lora-VariableFont_wght.ttf'),
      ('Onest', 'assets/fonts/onest/Onest-VariableFont_wght.ttf'),
    ]) {
      await (FontLoader(f.$1)..addFont(rootBundle.load(f.$2))).load();
    }
  });
  for (final kind in [
    'payment_word',
    'shop_word',
    'shop_header',
    'history_link',
    'spend_heading',
    'reward_word',
    'pro_benefit',
  ]) {
    testWidgets('commerce compact $kind preserves the complete label', (
      tester,
    ) async {
      tester.view.devicePixelRatio = 1;
      tester.view.physicalSize = const Size(320, 568);
      final user = sub.TestUser();
      final wallet = ReviewWallet();
      await tester.runAsync(() => di.reset());
      addTearDown(() async {
        await tester.pumpWidget(const SizedBox());
        await tester.runAsync(() => di.reset());
        user.dispose();
        wallet.dispose();
        tester.view.reset();
      });
      main_capture.reviewLang = 'ru';
      main_capture.reviewCompact = true;
      if (kind.startsWith('shop')) {
        await tester.pumpWidget(
          await main_capture.reviewShopApp(
            effectivePro: false,
            products: const [
              ShopItemModel(
                id: 'love-layout',
                title: 'Любовный расклад',
                category: 'Таро',
                description: 'Расклад таро о любви',
                price: 10,
              ),
            ],
          ),
        );
        await tester.pumpAndSettle();
        if (kind == 'shop_word') {
          await tester.ensureVisible(find.text('Любовный расклад'));
          await tester.pump();
          expectWholeWord(tester, 'Любовный расклад', 'Любовный');
          expect(
            tester
                .renderObject<RenderParagraph>(find.text('Любовный расклад'))
                .constraints
                .maxWidth,
            greaterThanOrEqualTo(260),
          );
        } else {
          final header = tester.renderObject<RenderParagraph>(
            find.text(AppLocalizations.current.shopTitle).first,
          );
          expect(
            header.didExceedMaxLines,
            isFalse,
            reason: 'The shop navigation title must be complete.',
          );
        }
      } else if (kind == 'payment_word') {
        final links = PaymentReturnLinkService();
        di.registerSingleton<PaymentReturnLinkService>(links);
        final cubit = pay_capture.ReviewCheckoutCubit();
        addTearDown(() async {
          await tester.pumpWidget(const SizedBox());
          await tester.runAsync(() async {
            await cubit.close();
            await links.dispose();
          });
        });
        pay_capture.reviewLang = 'ru';
        pay_capture.reviewCompact = true;
        await pay_capture.pumpReviewPaymentsScreen(tester, cubit, user);
        await tester.pump(const Duration(milliseconds: 100));
        cubit.publish(
          ArcPayCheckoutConfirming(
            pay_capture.reviewPaymentOrder(status: 'pending'),
          ),
        );
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 350));
        expectWholeWord(
          tester,
          AppLocalizations.current.paymentConfirming,
          'Подтверждаем',
        );
      } else if (kind == 'pro_benefit') {
        final facade = sub.RecordingFacade();
        di.registerSingleton<AnalyticsFacade>(facade);
        di.registerSingleton<ProductAnalyticsService>(
          ProductAnalyticsService(facade),
        );
        di.registerFactory<PaywallCubit>(() => sub.TestPaywall(wallet));
        di.registerSingleton<PaymentProviderRouter>(
          PaymentProviderRouter(
            sub.Storefront(),
            platform: TargetPlatform.iOS,
            distributionChannel: DistributionChannel.global,
          ),
        );
        wallet.setPro(true);
        await reviewPump(
          tester,
          const SubscriptionScreen(),
          wallet,
          user,
          'ru',
          true,
        );
        final label = AppLocalizations.current.subscriptionBenefitAffirmations;
        await tester.ensureVisible(find.text(label));
        await tester.pump();
        expectWholeWord(tester, label, 'Неограниченные');
        expect(
          tester
              .renderObject<RenderParagraph>(find.text(label))
              .constraints
              .maxWidth,
          greaterThanOrEqualTo(250),
        );
      } else {
        await tester.pumpWidget(main_capture.reviewBalanceApp());
        await tester.pumpAndSettle();
        final l10n = AppLocalizations.current;
        final label = switch (kind) {
          'history_link' => l10n.balanceHistoryTitle,
          'spend_heading' => l10n.balanceWhereToSpend,
          _ => l10n.rewardShare,
        };
        await tester.ensureVisible(find.text(label));
        await tester.pump();
        if (kind == 'history_link') {
          expect(
            tester
                .renderObject<RenderParagraph>(find.text(label))
                .didExceedMaxLines,
            isFalse,
          );
        } else if (kind == 'spend_heading') {
          expectWholeWord(tester, label, 'потратить?');
        } else {
          expectWholeWord(tester, label, 'Поделиться');
          expect(
            tester
                .renderObject<RenderParagraph>(find.text(label))
                .constraints
                .maxWidth,
            greaterThanOrEqualTo(260),
          );
        }
      }
      expect(tester.takeException(), isNull);
    });
  }
}
