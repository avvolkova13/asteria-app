import 'package:asteria_app/core/analytics/analytics_events.dart';
import 'package:asteria_app/core/analytics/analytics_facade.dart';
import 'package:asteria_app/core/analytics/dictionaries/offer_type.dart';
import 'package:asteria_app/core/analytics/event_params.dart';
import 'package:asteria_app/core/analytics/feature_names.dart';
import 'package:asteria_app/core/analytics/product_analytics_service.dart';
import 'package:asteria_app/core/di/di.dart';
import 'package:asteria_app/core/ui_kit/ui_kit.dart';
import 'package:asteria_app/features/monetization/presentation/monetization_provider.dart';
import 'package:asteria_app/features/sonnik/presentation/widgets/sonnik_buy_requests_screen.dart';
import 'package:asteria_app/features/sonnik/presentation/widgets/sonnik_layout.dart';
import 'package:flutter/material.dart';

class CreateSonnikSubscriptionScreen extends StatefulWidget {
  const CreateSonnikSubscriptionScreen({Key? key}) : super(key: key);

  @override
  State<CreateSonnikSubscriptionScreen> createState() =>
      _CreateSonnikSubscriptionScreenState();
}

class _CreateSonnikSubscriptionScreenState
    extends State<CreateSonnikSubscriptionScreen> {
  @override
  void initState() {
    super.initState();
    di.get<AnalyticsFacade>().trackEvent(
      AnalyticsEvents.sonnikPaywallView,
      params: {
        EventParams.featureName: FeatureName.sonnik.eventValue,
        EventParams.paywallVariant: 'requests_pack',
      },
    );
    di.get<ProductAnalyticsService>().trackSonnikPaywallView(
      originSurface: 'sonnik_requests_left',
      offerType: OfferType.requestPack,
      paywallVariant: 'requests_pack',
    );
  }

  @override
  Widget build(BuildContext context) {
    return SonnikPageScaffold(
      title: context.l10n.dreamDictionaryTitle,
      child: ListView(
        physics: const ClampingScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(16, 30, 16, 40),
        children: [
          SonnikBuyRequestsScreen(
            title: context.l10n.choosePackageTitle,
            originSurface: 'sonnik',
            packages: const [
              PurchasePackage(price: 7, requestQuantity: 1),
              PurchasePackage(price: 20, requestQuantity: 3),
              PurchasePackage(price: 30, requestQuantity: 5),
              PurchasePackage(price: 55, requestQuantity: 10),
            ],
            onPurchase: (requestQuantity, idempotencyKey) async {
              final facade = di.get<AnalyticsFacade>();
              final monetizationProvider = di.get<MonetizationProvider>();
              final featureParam = {
                EventParams.featureName: FeatureName.sonnik.eventValue,
              };
              facade.trackEvent(
                AnalyticsEvents.purchaseStart,
                params: {
                  ...featureParam,
                  EventParams.packageId: 'sonnik_$requestQuantity',
                },
              );
              try {
                await monetizationProvider.purchaseRequestPack(
                  feature: 'sonnik',
                  quantity: requestQuantity,
                  idempotencyKey: idempotencyKey,
                );
                facade.trackEvent(
                  AnalyticsEvents.sonnikPurchaseSuccess,
                  params: {
                    ...featureParam,
                    EventParams.packageId: 'sonnik_$requestQuantity',
                    EventParams.purchaseType: 'requests_pack',
                    EventParams.currency: 'coins',
                  },
                );
              } catch (e) {
                facade.trackPurchaseFailed(
                  feature: FeatureName.sonnik,
                  productId: 'sonnik_$requestQuantity',
                  failureStage: 'purchase_request_pack',
                  failureReason: e.toString(),
                );
                rethrow;
              }
            },
          ),
        ],
      ),
    );
  }
}
