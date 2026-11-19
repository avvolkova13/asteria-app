import 'package:asteria_app/features/monetization/domain/monetization_models.dart';

// The command endpoint chooses the balance to debit. Only submit when a
// free request is available and there is no purchased balance to spend.
bool canUseFreeAttempt(RequestQuotaModel? quota) =>
    quota != null && quota.freeRemaining > 0 && quota.paidRemaining == 0;
