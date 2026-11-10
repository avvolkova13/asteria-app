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
import 'package:asteria_app/core/ui_kit/ui_kit.dart';
import 'package:asteria_app/features/sonnik/presentation/screens/sonnik_requests_left_screen.dart';
import 'package:asteria_app/features/sonnik/presentation/widgets/sonnik_layout.dart';
import 'package:flutter/material.dart';

class CreateSonnikRequestsLeftScreen extends StatefulWidget {
  const CreateSonnikRequestsLeftScreen({Key? key}) : super(key: key);

  @override
  State<CreateSonnikRequestsLeftScreen> createState() =>
      _CreateSonnikRequestsLeftScreenState();
}

class _CreateSonnikRequestsLeftScreenState
    extends State<CreateSonnikRequestsLeftScreen> {
  @override
  void initState() {
    super.initState();
    di.get<AnalyticsFacade>().trackEvent(
      AnalyticsEvents.sonnikPaywallView,
      params: {
        EventParams.featureName: FeatureName.sonnik.eventValue,
        EventParams.paywallVariant: 'requests_left',
      },
    );
    di.get<ProductAnalyticsService>().trackSonnikPaywallView(
      originSurface: 'sonnik_initial',
      offerType: OfferType.requestPack,
      paywallVariant: 'requests_left',
    );
  }

  Future<void> _onUnlockClick(BuildContext context, String offerType) async {
    di.get<AnalyticsFacade>().trackEvent(
      AnalyticsEvents.sonnikUnlockClick,
      params: {
        EventParams.featureName: FeatureName.sonnik.eventValue,
        EventParams.offerType: offerType,
      },
    );
    di.get<ProductAnalyticsService>().trackSonnikPaywallClick(
      originSurface: 'sonnik_requests_left',
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
        originSurface: 'sonnik_requests_left',
      );
    } else {
      await CreateSonnikSubscriptionRoute.push(context);
    }
    if (!context.mounted || uid == null || !provider!.isCurrentUser(uid)) {
      return;
    }
    try {
      await provider.refreshForAccess();
      if (context.mounted &&
          provider.isCurrentUser(uid) &&
          provider.canMakeRequest('sonnik')) {
        returnToRequestFeature(context, 'sonnik');
      }
    } catch (_) {
      if (context.mounted) showAccessError(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SonnikPageScaffold(
      title: context.l10n.dreamDictionaryTitle,
      child: ListView(
        physics: const ClampingScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(16, 30, 16, 40),
        children: [
          SonnikRequestsLeftScreen(
            onBuyRequestsPressed: () =>
                _onUnlockClick(context, 'requests_pack'),
            onSubscriptionPressed: () =>
                _onUnlockClick(context, 'subscription'),
          ),
        ],
      ),
    );
  }
}
