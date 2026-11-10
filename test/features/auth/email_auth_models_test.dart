import 'package:asteria_app/app/data/models/user/user_model.dart';
import 'package:asteria_app/features/auth/presentation/cubit/email_auth_cubit.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('legacy profile without auth method defaults to email auth', () {
    final json = UserModel.empty().copyWith(phoneNumber: '79000000000').toJson()
      ..remove('email')
      ..remove('auth_method');

    final user = UserModel.fromJson(json);

    expect(user.phoneNumber, '79000000000');
    expect(user.email, isNull);
    expect(user.authMethod, AuthMethod.email);
  });

  test('legacy phone auth method is treated as email-only', () {
    final json = UserModel.empty().copyWith(phoneNumber: '79000000000').toJson()
      ..['auth_method'] = 'phone';

    expect(UserModel.fromJson(json).authMethod, AuthMethod.email);
  });

  test('email profile serializes nullable phone and auth method', () {
    final json = UserModel.empty()
        .copyWith(
          id: 'backend-uid',
          clearPhoneNumber: true,
          email: 'user@example.com',
          authMethod: AuthMethod.email,
        )
        .toJson();

    expect(json['id'], 'backend-uid');
    expect(json['phone_number'], isNull);
    expect(json['email'], 'user@example.com');
    expect(json['auth_method'], 'email');
  });

  test('email normalization and validation are deterministic', () {
    expect(
      EmailAuthCubit.normalizeEmail('  User@Example.COM '),
      'user@example.com',
    );
    expect(EmailAuthCubit.isValidEmail('user@example.com'), isTrue);
    expect(EmailAuthCubit.isValidEmail('invalid-email'), isFalse);
  });
}
