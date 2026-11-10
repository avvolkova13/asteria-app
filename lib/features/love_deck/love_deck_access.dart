import 'package:asteria_app/app/providers/user_provider.dart';
import 'package:asteria_app/core/analytics/analytics_events.dart';
import 'package:asteria_app/core/analytics/analytics_facade.dart';
import 'package:asteria_app/core/analytics/dictionaries/offer_type.dart';
import 'package:asteria_app/core/analytics/event_params.dart';
import 'package:asteria_app/core/analytics/feature_names.dart';
import 'package:asteria_app/core/const/purchase_products_const.dart';
import 'package:asteria_app/core/di/di.dart';
import 'package:asteria_app/core/services/global_loader_service.dart';
import 'package:asteria_app/core/ui_kit/ui_kit.dart';
import 'package:asteria_app/core/utils/enums.dart';
import 'package:asteria_app/features/monetization/presentation/monetization_provider.dart';
import 'package:flutter/material.dart';

Future<void> openLoveDeck(
  BuildContext context, {
  required VoidCallback onOpen,
}) async {
  final userProvider = di.get<UserProvider>();
  final accountId = userProvider.currentUser?.id;
  if (accountId == null) {
    showAccessError(context);
    return;
  }
  final facade = di.get<AnalyticsFacade>();
  final loveFeatureParam = {
    EventParams.featureName: FeatureName.loveDeck.eventValue,
  };
  if (userProvider.currentUser?.loveDeck?.loveDeckCards.isNotEmpty != true) {
    final loader = di.get<GlobalLoaderService>()..show();
    bool loaded;
    try {
      loaded = await userProvider.loadLatestDeck(DeckType.love);
    } finally {
      loader.hide();
    }
    if (!context.mounted ||
        userProvider.currentUser?.id != accountId ||
        ModalRoute.of(context)?.isCurrent == false) {
      return;
    }
    if (loaded) {
      facade.trackEvent(AnalyticsEvents.loveDeckOpen, params: loveFeatureParam);
      onOpen();
      return;
    }
    facade.trackEvent(
      AnalyticsEvents.paywallView,
      params: {
        ...loveFeatureParam,
        EventParams.paywallVariant: 'one_time_purchase',
        EventParams.price: PurchaseProductsConst.loveDeck.price,
        EventParams.currency: 'coins',
      },
    );
    await showFeaturePurchaseModal(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (modalContext) => SharedPurchaseModal(
        featureKey: 'tarot_spread',
        purchaseTitle: context.l10n.loveDeckTitle,
        price: PurchaseProductsConst.loveDeck.price,
        originSurface: 'tarot',
        offerType: OfferType.oneOffUnlock,
        onAccessPurchase: (requirePro, idempotencyKey) async {
          facade.trackEvent(
            AnalyticsEvents.paywallCtaClick,
            params: loveFeatureParam,
          );
          try {
            await facade.runFeatureAction(
              'love_deck',
              () => userProvider.buyLoveDeck(
                idempotencyKey: idempotencyKey,
                requirePro: requirePro,
              ),
            );
            if (!di.get<MonetizationProvider>().effectivePro) {
              facade.trackPurchaseSuccess(
                feature: FeatureName.loveDeck,
                productId: 'love_deck',
                price: PurchaseProductsConst.loveDeck.price,
                currency: 'coins',
                purchaseType: 'one_time',
              );
            }
          } catch (e) {
            if (!di.get<MonetizationProvider>().effectivePro) {
              facade.trackPurchaseFailed(
                feature: FeatureName.loveDeck,
                productId: 'love_deck',
                failureStage: 'buy_love_deck',
                failureReason: e.toString(),
              );
            }
            rethrow;
          }
        },
        onSuccess: () {
          if (context.mounted && userProvider.currentUser?.id == accountId) {
            onOpen();
          }
        },
      ),
    );
  } else {
    facade.trackEvent(AnalyticsEvents.loveDeckOpen, params: loveFeatureParam);
    onOpen();
  }
}
