import 'package:asteria_app/core/ui_kit/ui_kit.dart';
import 'package:asteria_app/features/monetization/presentation/contextual_purchase_page.dart';
import 'package:asteria_app/features/monetization/presentation/monetization_provider.dart';
import 'package:asteria_app/core/analytics/analytics_events.dart';
import 'package:asteria_app/core/analytics/analytics_facade.dart';
import 'package:asteria_app/core/analytics/dictionaries/offer_type.dart';
import 'package:asteria_app/core/analytics/event_params.dart';
import 'package:asteria_app/core/analytics/feature_names.dart';
import 'package:asteria_app/core/analytics/product_analytics_service.dart';
import 'package:asteria_app/core/di/di.dart';
import 'package:asteria_app/core/routing/app_route.dart';
import 'package:asteria_app/features/anakra_chat/presentation/screens/anakra_requests_left_screen.dart';
import 'package:asteria_app/features/anakra_chat/presentation/widgets/anakra_layout.dart';
import 'package:flutter/material.dart';

class CreateAnakraRequestsLeftScreen extends StatefulWidget {
  const CreateAnakraRequestsLeftScreen({super.key});

  @override
  State<CreateAnakraRequestsLeftScreen> createState() =>
      _CreateAnakraRequestsLeftScreenState();
}

class _CreateAnakraRequestsLeftScreenState
    extends State<CreateAnakraRequestsLeftScreen> {
  @override
  void initState() {
    super.initState();
    di.get<AnalyticsFacade>().trackEvent(
      AnalyticsEvents.anakraPaywallView,
      params: {
        EventParams.featureName: FeatureName.anakraChat.eventValue,
        EventParams.paywallVariant: 'requests_left',
      },
    );
    di.get<ProductAnalyticsService>().trackAnakraPaywallView(
      originSurface: 'anakra_chat',
      offerType: OfferType.requestPack,
      paywallVariant: 'requests_left',
    );
  }

  Future<void> _onUnlockClick(BuildContext context, String offerType) async {
    di.get<AnalyticsFacade>().trackEvent(
      AnalyticsEvents.anakraUnlockClick,
      params: {
        EventParams.featureName: FeatureName.anakraChat.eventValue,
        EventParams.offerType: offerType,
      },
    );
    final mappedOfferType = offerType == 'subscription'
        ? OfferType.subscription
        : OfferType.requestPack;
    di.get<ProductAnalyticsService>().trackAnakraPaywallClick(
      originSurface: 'anakra_chat',
      offerType: mappedOfferType,
      ctaName: offerType == 'subscription' ? 'subscribe' : 'buy_requests',
      paywallVariant: 'requests_left',
    );
    final provider = MonetizationProvider.maybeOf(context, listen: false);
    final uid = provider?.state?.uid;
    if (offerType == 'subscription') {
      await openContextualPurchase(
        context,
        subscription: true,
        originSurface: 'anakra_requests_left',
      );
    } else {
      await CreateAnakraSubscriptionRoute.push(context);
    }
    if (!context.mounted || uid == null || !provider!.isCurrentUser(uid)) {
      return;
    }
    try {
      await provider.refreshForAccess();
      if (context.mounted &&
          provider.isCurrentUser(uid) &&
          provider.canMakeRequest('anakra')) {
        returnToRequestFeature(context, 'anakra');
      }
    } catch (_) {
      if (context.mounted) showAccessError(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnakraPageScaffold(
      child: CustomScrollView(
        physics: const ClampingScrollPhysics(),
        slivers: [
          const SliverToBoxAdapter(child: AnakraHeroHeader()),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 28),
              child: AnakraRequestsLeftScreen(
                onBuyRequestsPressed: () =>
                    _onUnlockClick(context, 'requests_pack'),
                onSubscriptionPressed: () =>
                    _onUnlockClick(context, 'subscription'),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
