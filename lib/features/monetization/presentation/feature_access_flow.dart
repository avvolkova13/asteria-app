import 'package:asteria_app/core/routing/app_route.dart';
import 'package:go_router/go_router.dart';
import 'package:asteria_app/core/analytics/dictionaries/offer_type.dart';
import 'package:asteria_app/core/di/di.dart';
import 'package:asteria_app/core/services/global_loader_service.dart';
import 'package:asteria_app/core/ui_kit/ui_kit.dart';
import 'package:asteria_app/features/monetization/presentation/monetization_provider.dart';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

/// Null means access could not be checked; it must never open a paywall.
Future<bool?> checkRequestAccess(BuildContext context, String feature) async {
  try {
    final provider =
        MonetizationProvider.maybeOf(context, listen: false) ??
        di.get<MonetizationProvider>();
    await provider.refreshForAccess();
    if (!provider.isFeatureEnabled(feature)) {
      if (context.mounted) showAccessError(context);
      return null;
    }
    return provider.canMakeRequest(feature);
  } catch (_) {
    if (context.mounted) showAccessError(context);
    return null;
  }
}

void showAccessError(BuildContext context) {
  ScaffoldMessenger.of(
    context,
  ).showSnackBar(SnackBar(content: Text(context.l10n.purchaseErrorTryAgain)));
}

/// All one-off entry points use the same fresh access decision. The ordinary
/// purchase widget remains responsible only for explicit wallet confirmation.
Future<PurchaseModalOutcome?> showFeaturePurchaseModal({
  required BuildContext context,
  required SharedPurchaseModal Function(BuildContext) builder,
  Color? backgroundColor,
  bool isScrollControlled = true,
}) async {
  final route = ModalRoute.of(context);
  final provider =
      MonetizationProvider.maybeOf(context, listen: false) ??
      di.get<MonetizationProvider>();
  final uid = provider.state?.uid;
  try {
    await provider.refreshForAccess();
    if (!context.mounted || (route != null && !route.isCurrent)) return null;
    if (uid != null && !provider.isCurrentUser(uid)) return null;
    final accessUid = provider.state!.uid;
    final purchase = builder(context);
    if (purchase.featureKey != null &&
        !provider.isFeatureEnabled(purchase.featureKey!)) {
      showAccessError(context);
      return null;
    }
    if (provider.effectivePro && purchase.featureKey != null) {
      // Buying request packs is unnecessary with PRO. Return to the action.
      if (purchase.offerType == OfferType.requestPack) {
        return PurchaseModalOutcome.proActivated;
      }
      final loader = di.get<GlobalLoaderService>();
      if (purchase.loaderType != null) {
        loader.showWithSpheres(purchase.loaderType!);
      } else {
        loader.show();
      }
      try {
        final action = purchase.onAccessPurchase;
        if (action == null)
          throw StateError(
            'PRO execution requires an explicit access contract',
          );
        await action(true, const Uuid().v4());
        await provider.refresh();
        if (context.mounted &&
            provider.isCurrentUser(accessUid) &&
            (uid == null || provider.isCurrentUser(uid))) {
          purchase.onSuccess?.call();
        }
      } finally {
        loader.hide();
      }
      return null;
    }
    return await showModalBottomSheet<PurchaseModalOutcome>(
      context: context,
      backgroundColor: backgroundColor ?? Colors.transparent,
      isScrollControlled: isScrollControlled,
      builder: (_) => purchase,
    );
  } catch (_) {
    if (context.mounted) showAccessError(context);
    return null;
  }
}

/// Pop the purchase route without replacing the editor beneath it. Deep links
/// have no editor on the stack and must open the feature instead.
void returnToRequestFeature(BuildContext context, String feature) {
  if (Navigator.of(context).canPop()) {
    Navigator.of(context).pop();
    return;
  }
  final route = switch (feature) {
    'anakra' => AnakraChatRoutes.anakraChatRouteName,
    'sonnik' => SonnikRoutes.createSonnikInitialRouteName,
    'compatibility' => CompatibilityRoutes.createCompatibilityInitialRouteName,
    _ => null,
  };
  if (route != null) context.goNamed(route);
}
