import 'package:asteria_app/features/subscription/presentation/subscription_screen.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('Google subscription management URL uses the published package name', () {
    final uri = googlePlaySubscriptionManagementUrl();

    expect(uri.scheme, 'https');
    expect(uri.host, 'play.google.com');
    expect(uri.path, '/store/account/subscriptions');
    expect(uri.queryParameters['package'], 'com.finext.asteria');
  });
}
