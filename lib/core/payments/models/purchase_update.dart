import 'package:asteria_app/core/payments/models/purchase_result.dart';

/// Emitted by the gateway's purchase stream — used both for in-flight
/// purchases and for auto-renewals / restores delivered out-of-band.
class PurchaseUpdate {
  final PurchaseResult result;

  const PurchaseUpdate(this.result);
}
