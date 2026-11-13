import 'dart:async';

import 'package:asteria_app/core/ui_kit/widgets/asteria_activity_indicator.dart';
import 'package:asteria_app/core/payments/routing/payment_provider_route.dart';
import 'package:flutter/material.dart';

class PaymentProviderRouteBuilder extends StatefulWidget {
  final PaymentProviderRouter router;
  final PaymentProviderRoute? activeSubscriptionRoute;
  final Widget Function(BuildContext context, PaymentProviderRoute route)
  builder;

  const PaymentProviderRouteBuilder({
    super.key,
    required this.router,
    required this.builder,
    this.activeSubscriptionRoute,
  });

  @override
  State<PaymentProviderRouteBuilder> createState() =>
      _PaymentProviderRouteBuilderState();
}

class _PaymentProviderRouteBuilderState
    extends State<PaymentProviderRouteBuilder>
    with WidgetsBindingObserver {
  PaymentProviderRoute? _route;
  StreamSubscription<PaymentProviderRoute>? _subscription;
  int _generation = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _resolve();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _resolve();
    }
  }

  @override
  void didUpdateWidget(covariant PaymentProviderRouteBuilder oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.activeSubscriptionRoute != widget.activeSubscriptionRoute) {
      _resolve();
    }
  }

  Future<void> _resolve() async {
    final generation = ++_generation;
    await _subscription?.cancel();
    final route = await widget.router.current(
      activeSubscriptionRoute: widget.activeSubscriptionRoute,
    );
    if (!mounted || generation != _generation) return;
    setState(() => _route = route);
    _subscription = widget.router
        .updates(activeSubscriptionRoute: widget.activeSubscriptionRoute)
        .listen((value) {
          if (!mounted || generation != _generation || value == _route) return;
          setState(() => _route = value);
        });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _subscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final route = _route;
    if (route == null) {
      return const Scaffold(body: Center(child: AsteriaActivityIndicator()));
    }
    return widget.builder(context, route);
  }
}
