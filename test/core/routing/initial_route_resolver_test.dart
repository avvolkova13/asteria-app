import 'package:asteria_app/core/routing/initial_route_resolver.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('resolveInitialRoute', () {
    test('keeps onboarding when there is no user or pending order', () {
      expect(resolveInitialRoute(fallbackRoute: '/onboarding'), '/onboarding');
    });

    test('keeps login when both user ids are null', () {
      expect(
        resolveInitialRoute(fallbackRoute: '/auth/login', currentUserId: null),
        '/auth/login',
      );
    });

    test('does not restore coin payments on app start', () {
      expect(
        resolveInitialRoute(fallbackRoute: '/home', currentUserId: 'user-1'),
        '/home',
      );
    });

    test('restores an iOS subscription for the authenticated owner', () {
      expect(
        resolveInitialRoute(
          fallbackRoute: '/home',
          subscriptionRoute: '/subscription',
          pendingSubscriptionUserId: 'user-1',
          currentUserId: 'user-1',
        ),
        '/subscription',
      );
      expect(
        resolveInitialRoute(
          fallbackRoute: '/home',
          subscriptionRoute: '/subscription',
          pendingSubscriptionUserId: 'user-1',
          currentUserId: 'user-2',
        ),
        '/home',
      );
    });
  });
}
