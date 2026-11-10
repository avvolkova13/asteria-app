import 'package:asteria_app/features/auth/data/email_auth_api.dart';

abstract class EmailAuthRepository {
  Future<EmailCodeChallenge> requestCode(String email);
  Future<EmailCodeVerification> verifyCode({
    required String challengeId,
    required String code,
  });
}

class EmailAuthRepositoryImpl implements EmailAuthRepository {
  final EmailAuthApi _api;

  const EmailAuthRepositoryImpl(this._api);

  @override
  Future<EmailCodeChallenge> requestCode(String email) =>
      _api.requestCode(email);

  @override
  Future<EmailCodeVerification> verifyCode({
    required String challengeId,
    required String code,
  }) => _api.verifyCode(challengeId: challengeId, code: code);
}
