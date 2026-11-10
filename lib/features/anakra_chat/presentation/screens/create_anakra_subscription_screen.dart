import 'package:asteria_app/core/analytics/analytics_events.dart';
import 'package:asteria_app/core/analytics/analytics_facade.dart';
import 'package:asteria_app/core/analytics/dictionaries/offer_type.dart';
import 'package:asteria_app/core/analytics/event_params.dart';
import 'package:asteria_app/core/analytics/feature_names.dart';
import 'package:asteria_app/core/analytics/product_analytics_service.dart';
import 'package:asteria_app/core/di/di.dart';
import 'package:asteria_app/core/ui_kit/ui_kit.dart';
import 'package:asteria_app/features/anakra_chat/presentation/widgets/anakra_layout.dart';
import 'package:asteria_app/features/monetization/presentation/monetization_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class CreateAnakraSubscriptionScreen extends StatefulWidget {
  const CreateAnakraSubscriptionScreen({super.key});

  @override
  State<CreateAnakraSubscriptionScreen> createState() =>
      _CreateAnakraSubscriptionScreenState();
}

class _CreateAnakraSubscriptionScreenState
    extends State<CreateAnakraSubscriptionScreen> {
  @override
  void initState() {
    super.initState();
    di.get<AnalyticsFacade>().trackEvent(
      AnalyticsEvents.anakraPaywallView,
      params: {
        EventParams.featureName: FeatureName.anakraChat.eventValue,
        EventParams.paywallVariant: 'requests_pack',
      },
    );
    di.get<ProductAnalyticsService>().trackAnakraPaywallView(
      originSurface: 'anakra_chat',
      offerType: OfferType.requestPack,
      paywallVariant: 'requests_pack',
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnakraPageScaffold(
      child: CustomScrollView(
        physics: const ClampingScrollPhysics(),
        slivers: [
          const SliverToBoxAdapter(
            child: AnakraHeroHeader(showRequestsBadge: false),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 62, 16, 28),
              child: SharedBuyRequestsScreen(
                title: context.l10n.choosePackageTitle,
                originSurface: 'anakra',
                packages: const [
                  PurchasePackage(price: 7, requestQuantity: 1),
                  PurchasePackage(price: 20, requestQuantity: 3),
                  PurchasePackage(price: 30, requestQuantity: 5),
                  PurchasePackage(price: 55, requestQuantity: 10),
                ],
                onPurchase: (requestQuantity, idempotencyKey) async {
                  final facade = di.get<AnalyticsFacade>();
                  final monetizationProvider = context
                      .read<MonetizationProvider>();
                  final featureParam = {
                    EventParams.featureName: FeatureName.anakraChat.eventValue,
                  };
                  facade.trackEvent(
                    AnalyticsEvents.purchaseStart,
                    params: {
                      ...featureParam,
                      EventParams.packageId: 'anakra_$requestQuantity',
                    },
                  );
                  try {
                    await monetizationProvider.purchaseRequestPack(
                      feature: 'anakra',
                      quantity: requestQuantity,
                      idempotencyKey: idempotencyKey,
                    );
                    facade.trackEvent(
                      AnalyticsEvents.anakraPurchaseSuccess,
                      params: {
                        ...featureParam,
                        EventParams.packageId: 'anakra_$requestQuantity',
                        EventParams.purchaseType: 'requests_pack',
                        EventParams.currency: 'coins',
                      },
                    );
                  } catch (e) {
                    facade.trackPurchaseFailed(
                      feature: FeatureName.anakraChat,
                      productId: 'anakra_$requestQuantity',
                      failureStage: 'purchase_request_pack',
                      failureReason: e.toString(),
                    );
                    rethrow;
                  }
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
