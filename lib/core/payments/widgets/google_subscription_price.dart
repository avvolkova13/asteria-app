import 'package:asteria_app/core/localization/generated/l10n.dart';
import 'package:asteria_app/core/payments/catalog/google_subscription_offers.dart';
import 'package:flutter/widgets.dart';

class GoogleSubscriptionPrice extends StatelessWidget {
  const GoogleSubscriptionPrice({super.key, required this.terms, this.style});

  final GoogleSubscriptionTerms terms;
  final TextStyle? style;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final price = switch (terms.billingPeriod) {
      'P1W' => l10n.googleSubscriptionPerWeek(terms.recurringPrice),
      'P1M' => l10n.googleSubscriptionPerMonth(terms.recurringPrice),
      'P1Y' => l10n.googleSubscriptionPerYear(terms.recurringPrice),
      _ => terms.recurringPrice,
    };
    return Text(
      terms.hasFreeTrial
          ? l10n.googleSubscriptionTrialTerms(price)
          : l10n.googleSubscriptionRecurringTerms(price),
      style: style,
    );
  }
}
