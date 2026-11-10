import 'package:asteria_app/core/payments/gateway/store_kit_gateway.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test(
    'Google Play account id is a deterministic SHA-256 backend UID hash',
    () {
      expect(
        googlePlayObfuscatedAccountId('backend-user-1'),
        '19ea7a277491f1f5a07a466887aa841f9b79edca66eead6c1537abcede600823',
      );
      expect(googlePlayObfuscatedAccountId(null), isNull);
      expect(googlePlayObfuscatedAccountId(''), isNull);
    },
  );
}
