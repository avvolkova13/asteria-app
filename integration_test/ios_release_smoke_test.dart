import 'balance_history_ast188_test.dart' as balance;
import 'moon_phase_primary_phase_test.dart' as moon;
import 'personal_compatibility_ast127_test.dart' as compatibility;
import 'personal_screen_ast126_test.dart' as readings;
import 'storefront_bridge_test.dart' as storefront;

// The integration runner owns its install; use an isolated QA simulator.
void main() {
  balance.main();
  moon.main();
  compatibility.main();
  readings.main();
  storefront.main();
}
