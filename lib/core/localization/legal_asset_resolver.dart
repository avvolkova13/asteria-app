import 'package:flutter/foundation.dart';

enum LegalDocumentType { agreement, privacy }

class LegalAssetResolver {
  const LegalAssetResolver._();

  static String resolve({
    required LegalDocumentType document,
    required String languageCode,
    required TargetPlatform platform,
  }) {
    final isAndroid = platform == TargetPlatform.android;
    if (languageCode == 'ru') {
      return switch ((document, isAndroid)) {
        (LegalDocumentType.agreement, true) =>
          'assets/agreement_text_google_play.txt',
        (LegalDocumentType.agreement, false) => 'assets/agreement_text.txt',
        (LegalDocumentType.privacy, true) =>
          'assets/privacy_text_google_play.txt',
        (LegalDocumentType.privacy, false) => 'assets/privacy_text.txt',
      };
    }
    final platformDirectory = isAndroid ? 'android' : 'ios';
    final fileName = document == LegalDocumentType.agreement
        ? 'agreement.txt'
        : 'privacy.txt';
    return 'assets/legal/en/$platformDirectory/$fileName';
  }
}
