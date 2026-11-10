import 'package:asteria_app/core/location/device_location_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('detects simulator location through the native plugin', (
    tester,
  ) async {
    final result = await const DeviceLocationService().detectCurrentLocation(
      requestPermission: false,
    );

    expect(result.status, DeviceLocationStatus.available);
    final location = result.location;
    expect(location, isNotNull);
    expect(location!.latitude, closeTo(52.3676, 0.01));
    expect(location.longitude, closeTo(4.9041, 0.01));
    expect(location.location.trim(), isNotEmpty);
  });
}
