import 'package:asteria_app/features/monetization/presentation/monetization_provider.dart';

// PRO is handled by the command endpoint. For accounts without PRO, only
// submit when a free request is available and no purchased request can be used.
bool canUseScenarioRequest(MonetizationProvider access, String feature) {
  if (!access.isFeatureEnabled(feature)) return false;
  if (access.effectivePro) return true;
  final quota = access.requestQuotas[feature];
  return quota != null && quota.freeRemaining > 0 && quota.paidRemaining == 0;
}
