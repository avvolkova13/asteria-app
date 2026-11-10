import 'dart:ui';

import 'package:share_plus/share_plus.dart';

class RewardShareService {
  const RewardShareService();

  Future<bool> shareInvite({
    required String text,
    required String subject,
    Rect? origin,
  }) async {
    final result = await SharePlus.instance.share(
      ShareParams(
        text: text,
        subject: subject,
        sharePositionOrigin: origin,
      ),
    );
    return result.status == ShareResultStatus.success;
  }
}
