import 'package:asteria_app/core/localization/localization.dart';
import 'package:asteria_app/features/auth/presentation/cubit/email_auth_state.dart';
import 'package:flutter/widgets.dart';

String localizedEmailAuthFailure(
  BuildContext context,
  EmailAuthFailureCode code,
) {
  final l10n = AppLocalizations.of(context);
  return switch (code) {
    EmailAuthFailureCode.invalidInput => l10n.emailInvalidError,
    EmailAuthFailureCode.sendCode => l10n.emailSendCodeError,
    EmailAuthFailureCode.invalidOrExpiredCode =>
      l10n.emailInvalidOrExpiredCodeError,
    EmailAuthFailureCode.rateLimited => l10n.emailRateLimitedError,
    EmailAuthFailureCode.deliveryFailed => l10n.emailDeliveryError,
    EmailAuthFailureCode.unavailable => l10n.emailUnavailableError,
    EmailAuthFailureCode.network => l10n.emailNetworkError,
    EmailAuthFailureCode.signIn => l10n.emailSignInError,
    EmailAuthFailureCode.unknown => l10n.emailUnknownError,
  };
}
