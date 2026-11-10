import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('mobile source exposes only email authentication', () {
    final authRoutes = File(
      'lib/core/routing/routes/auth_routes.dart',
    ).readAsStringSync();
    expect(authRoutes, contains('EmailLoginScreen(isRoot: true)'));
    expect(authRoutes, contains('expectedUid: arguments.expectedUid'));

    final emailLogin = File(
      'lib/features/auth/presentation/screens/email_login_screen.dart',
    ).readAsStringSync();
    expect(emailLogin, contains('AnalyticsEvents.authStarted'));
    expect(emailLogin, contains('emailAuthConsentPrefix'));
    expect(emailLogin, contains('LegalDocumentType.agreement'));
    expect(emailLogin, contains('LegalDocumentType.privacy'));

    final emailCubit = File(
      'lib/features/auth/presentation/cubit/email_auth_cubit.dart',
    ).readAsStringSync();
    expect(emailCubit, contains('trackAuthCodeVerifySuccess'));
    expect(emailCubit, contains('trackAuthCodeVerifyFailed'));
    expect(emailCubit, contains('setCustomerUserId'));

    final bundledEnvironment = File('.env');
    if (bundledEnvironment.existsSync()) {
      final hasSmsCredentials = RegExp(
        r'^SMS_AERO_',
        multiLine: true,
      ).hasMatch(bundledEnvironment.readAsStringSync());
      expect(
        hasSmsCredentials,
        isFalse,
        reason:
            'mobile .env is bundled as an asset and must not contain SMS credentials',
      );
    }

    const removedPaths = <String>[
      'lib/core/services/api/sms_aero_api.dart',
      'lib/core/utils/phone_formatter.dart',
      'lib/core/routing/routes/change_phone_number_routes.dart',
      'lib/features/auth/presentation/screens/code_verification_screen.dart',
      'lib/features/change_phone_number',
    ];

    for (final path in removedPaths) {
      expect(
        FileSystemEntity.typeSync(path),
        FileSystemEntityType.notFound,
        reason: '$path is part of the removed phone-auth surface',
      );
    }

    const forbiddenTokens = <String>[
      'AuthCodeRoute',
      'AuthIdentity.phone',
      'AuthPhone',
      'getUserByPhone',
      'sendSmsCode',
      'sendTgCode',
      'trackAuthPhoneSubmit',
      'trackPhoneChangeSuccess',
      'SMS_AERO_',
    ];
    final dartSources = Directory('lib')
        .listSync(recursive: true)
        .whereType<File>()
        .where((file) => file.path.endsWith('.dart'));

    for (final file in dartSources) {
      final source = file.readAsStringSync();
      for (final token in forbiddenTokens) {
        expect(
          source,
          isNot(contains(token)),
          reason: '${file.path} still contains phone-auth token $token',
        );
      }
    }
  });
}
