import 'package:asteria_app/core/payments/apple/apple_purchase_coordinator.dart';
import 'package:asteria_app/core/localization/localization.dart';
import 'package:asteria_app/features/subscription/presentation/cubit/paywall_state.dart';
import 'package:flutter/widgets.dart';

String localizedPaywallFailure(BuildContext context, PaywallFailureCode code) {
  final l10n = AppLocalizations.of(context);
  return switch (code) {
    PaywallFailureCode.productsLoad => l10n.storeProductsLoadError,
    PaywallFailureCode.notAuthenticated => l10n.storeSignInRequiredError,
    PaywallFailureCode.purchaseStart => l10n.storePurchaseStartError,
    PaywallFailureCode.canceled => l10n.storePurchaseCanceled,
    PaywallFailureCode.purchaseFailed => l10n.storePurchaseFailedError,
    PaywallFailureCode.verificationMissing ||
    PaywallFailureCode.verificationRejected =>
      l10n.storePurchaseVerificationError,
    PaywallFailureCode.supportRequired => l10n.storePurchaseSupportError,
    PaywallFailureCode.restoreFailed => l10n.storeRestorePurchasesError,
  };
}

String localizedApplePurchaseStatus(
  BuildContext context,
  PaywallAppleStatus state,
) {
  final l10n = AppLocalizations.of(context);
  if (state.errorCode == 'sign_in') return l10n.storeSignInRequiredError;
  if (state.errorCode == 'alreadyActive') return l10n.applePurchaseActive;
  return switch (state.phase) {
    ApplePurchasePhase.approval => l10n.applePurchaseApproval,
    ApplePurchasePhase.accountAction => l10n.applePurchaseAccount,
    ApplePurchasePhase.error =>
      state.errorCode == 'invalid_purchase' ||
              state.errorCode == 'invalid_or_unauthenticated'
          ? l10n.applePurchaseInvalid
          : l10n.applePurchaseOffline,
    _ => l10n.applePurchaseWaiting,
  };
}
