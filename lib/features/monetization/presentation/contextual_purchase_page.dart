import 'dart:async';

import 'package:asteria_app/core/routing/app_route.dart';
import 'package:asteria_app/core/ui_kit/ui_kit.dart';
import 'package:asteria_app/features/monetization/presentation/monetization_provider.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// Dispatched only from a verified provider success (never a browser return).
class PurchaseVerifiedNotification extends Notification {}

Future<bool> openContextualPurchase(
  BuildContext context, {
  required bool subscription,
  required String originSurface,
  int minimumStars = 0,
}) async {
  final provider = MonetizationProvider.maybeOf(context, listen: false);
  final uid = provider?.state?.uid;
  if (uid == null || !provider!.isCurrentUser(uid)) return false;
  final result = await context.pushNamed<bool>(
    subscription ? SubscriptionRoute.routeName : CoinsPaywallRoute.routeName,
    extra: subscription
        ? SubscriptionRouteParams(originSurface: originSurface, returnUid: uid)
        : CoinsPaywallRouteParams(minimumStars: minimumStars, returnUid: uid),
  );
  if (!context.mounted || !provider.isCurrentUser(uid)) return false;
  try {
    await provider.refreshForAccess();
    return result == true && provider.isCurrentUser(uid);
  } catch (_) {
    return false;
  }
}

/// A purchase opened from a feature returns to that feature, while purchases
/// opened from the balance/profile retain their standalone behavior.
class ContextualPurchasePage extends StatefulWidget {
  const ContextualPurchasePage({
    super.key,
    required this.child,
    required this.subscription,
    this.returnUid,
  });

  final Widget child;
  final bool subscription;
  final String? returnUid;

  @override
  State<ContextualPurchasePage> createState() => _ContextualPurchasePageState();
}

class _ContextualPurchasePageState extends State<ContextualPurchasePage> {
  bool _returning = false;

  Future<void> _complete() async {
    if (_returning || widget.returnUid == null) return;
    final provider = MonetizationProvider.maybeOf(context, listen: false);
    if (provider == null || !provider.isCurrentUser(widget.returnUid!)) return;
    _returning = true;
    try {
      await provider.refreshForAccess();
      if (!mounted || !provider.isCurrentUser(widget.returnUid!)) return;
      if (widget.subscription && !provider.effectivePro) return;
      if (ModalRoute.of(context)?.isCurrent != true) return;
      Navigator.of(context).pop(true);
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(context.l10n.purchaseErrorTryAgain)),
        );
      }
    } finally {
      _returning = false;
    }
  }

  @override
  Widget build(BuildContext context) =>
      NotificationListener<PurchaseVerifiedNotification>(
        onNotification: (_) {
          unawaited(_complete());
          return widget.returnUid != null;
        },
        child: widget.child,
      );
}

/// The subscription offer inside a contextual stars checkout must return through
/// the same purchase flow as its parent, including verified PRO activation.
Future<void> openSubscriptionFromCoins(BuildContext context) async {
  final page = context.findAncestorWidgetOfExactType<ContextualPurchasePage>();
  if (page?.returnUid == null) {
    SubscriptionRoute.push(context);
    return;
  }
  final purchased = await openContextualPurchase(
    context,
    subscription: true,
    originSurface: 'coins_paywall',
  );
  if (purchased && context.mounted) {
    PurchaseVerifiedNotification().dispatch(context);
  }
}
