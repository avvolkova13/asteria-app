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
import 'package:asteria_app/features/compatibility/presentation/screens/compatibility_requests_left_screen.dart';
import 'package:asteria_app/features/compatibility/presentation/widgets/compatibility_layout.dart';
import 'package:flutter/material.dart';

class CreateCompatibilityRequestsLeftScreen extends StatefulWidget {
  const CreateCompatibilityRequestsLeftScreen({Key? key}) : super(key: key);

  @override
  State<CreateCompatibilityRequestsLeftScreen> createState() =>
      _CreateCompatibilityRequestsLeftScreenState();
}

class _CreateCompatibilityRequestsLeftScreenState
    extends State<CreateCompatibilityRequestsLeftScreen> {
  static const _featureParams = {
    EventParams.featureName: 'compatibility',
    EventParams.paywallVariant: 'requests_left',
  };

  @override
  void initState() {
    super.initState();
    di.get<AnalyticsFacade>().trackEvent(
      AnalyticsEvents.compatibilityPaywallView,
      params: _featureParams,
    );
    di.get<ProductAnalyticsService>().trackCompatibilityPaywallView(
      originSurface: 'compatibility_initial',
      offerType: OfferType.requestPack,
      paywallVariant: 'requests_left',
    );
  }

  Future<void> _onUnlockClick(BuildContext context, String offerType) async {
    di.get<AnalyticsFacade>().trackEvent(
      AnalyticsEvents.compatibilityUnlockClick,
      params: {
        EventParams.featureName: FeatureName.compatibility.eventValue,
        EventParams.offerType: offerType,
      },
    );
    di.get<ProductAnalyticsService>().trackCompatibilityPaywallClick(
      originSurface: 'compatibility_requests_left',
      offerType: offerType == 'subscription'
          ? OfferType.subscription
          : OfferType.requestPack,
      ctaName: offerType == 'subscription'
          ? 'open_subscription'
          : 'buy_requests',
      paywallVariant: 'requests_left',
    );
    final provider = MonetizationProvider.maybeOf(context, listen: false);
    final uid = provider?.state?.uid;
    if (offerType == 'subscription') {
      await openContextualPurchase(
        context,
        subscription: true,
        originSurface: 'compatibility_requests_left',
      );
    } else {
      await CreateCompatibilitySubscriptionRoute.push(context);
    }
    if (!context.mounted || uid == null || !provider!.isCurrentUser(uid)) {
      return;
    }
    try {
      await provider.refreshForAccess();
      if (context.mounted &&
          provider.isCurrentUser(uid) &&
          provider.canMakeRequest('compatibility')) {
        returnToRequestFeature(context, 'compatibility');
      }
    } catch (_) {
      if (context.mounted) showAccessError(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return CompatibilityLayout(
      showRequestsBadge: false,
      padding: const EdgeInsets.fromLTRB(16, 22, 16, 28),
      child: CompatibilityRequestsLeftScreen(
        onBuyRequestsPressed: () => _onUnlockClick(context, 'requests_pack'),
        onSubscriptionPressed: () => _onUnlockClick(context, 'subscription'),
      ),
    );
  }
}
