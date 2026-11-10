String resolveInitialRoute({
  required String fallbackRoute,
  String? subscriptionRoute,
  String? pendingSubscriptionUserId,
  String? currentUserId,
}) {
  final hasMatchingPendingSubscription =
      subscriptionRoute != null &&
      pendingSubscriptionUserId != null &&
      currentUserId != null &&
      pendingSubscriptionUserId == currentUserId;
  return hasMatchingPendingSubscription ? subscriptionRoute : fallbackRoute;
}
