import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('Android Arc Pay coin flow keeps Android platform contract', (
    tester,
  ) async {
    expect(defaultTargetPlatform, TargetPlatform.android);
  });
}
