import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:in_app_purchase_android/in_app_purchase_android.dart';
import 'package:in_app_purchase_android/billing_client_wrappers.dart';

const _plans = {
  'asteria_pro_week': ('weekly', 'P1W'),
  'asteria_pro_month': ('monthly', 'P1M'),
  'asteria_pro_year': ('yearly', 'P1Y'),
};

/// Only select plans whose complete price schedule the paywall can explain.
/// Google returns eligible offers; absence of a trial means use the base plan.
List<ProductDetails> selectGooglePlayOffers(List<ProductDetails> products) {
  final selected = <String, ProductDetails>{};
  for (final product in products) {
    if (!_plans.containsKey(product.id)) {
      selected[product.id] = product;
      continue;
    }
    final terms = googleSubscriptionTerms(product);
    if (terms == null) continue;
    final previous = selected[product.id];
    if (previous == null ||
        (terms.hasFreeTrial &&
            !(googleSubscriptionTerms(previous)?.hasFreeTrial ?? false))) {
      selected[product.id] = product;
    }
  }
  return selected.values.toList(growable: false);
}

class GoogleSubscriptionTerms {
  const GoogleSubscriptionTerms({
    required this.recurringPrice,
    required this.billingPeriod,
    required this.hasFreeTrial,
  });
  final String recurringPrice;
  final String billingPeriod;
  final bool hasFreeTrial;
}

GoogleSubscriptionTerms? googleSubscriptionTerms(Object? details) {
  if (details is! GooglePlayProductDetails) return null;
  final plan = _plans[details.id];
  final offers = details.productDetails.subscriptionOfferDetails;
  final index = details.subscriptionIndex;
  if (plan == null ||
      offers == null ||
      index == null ||
      index < 0 ||
      index >= offers.length) {
    return null;
  }
  final offer = offers[index];
  if (offer.basePlanId != plan.$1 ||
      offer.installmentPlanDetails != null ||
      offer.offerIdToken.isEmpty) {
    return null;
  }
  final phases = offer.pricingPhases;
  if (phases.isEmpty) return null;
  final recurring = phases.last;
  if (recurring.recurrenceMode != RecurrenceMode.infiniteRecurring ||
      recurring.billingPeriod != plan.$2 ||
      recurring.priceAmountMicros <= 0) {
    return null;
  }
  final isBase = offer.offerId == null && phases.length == 1;
  final isTrial =
      details.id != 'asteria_pro_week' &&
      offer.offerId == 'trial-7d' &&
      phases.length == 2 &&
      phases.first.priceAmountMicros == 0 &&
      phases.first.billingPeriod == 'P7D' &&
      phases.first.billingCycleCount == 1 &&
      phases.first.recurrenceMode == RecurrenceMode.finiteRecurring &&
      phases.first.priceCurrencyCode == recurring.priceCurrencyCode;
  if (!isBase && !isTrial) return null;
  return GoogleSubscriptionTerms(
    recurringPrice: recurring.formattedPrice,
    billingPeriod: recurring.billingPeriod,
    hasFreeTrial: isTrial,
  );
}
