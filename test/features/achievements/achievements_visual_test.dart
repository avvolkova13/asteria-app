import 'package:asteria_app/app/providers/user_provider.dart';
import 'package:asteria_app/core/di/di.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';

import 'achievements_screen_test.dart' show pumpAchievements, achievementUser;

void main() {
  testWidgets('achievements reference screen at 390 by 844', (tester) async {
    await tester.runAsync(() async {
      for (final font in [
        ('MaterialIcons', 'fonts/MaterialIcons-Regular.otf'),
        ('Lora', 'assets/fonts/lora/Lora-VariableFont_wght.ttf'),
        ('Onest', 'assets/fonts/onest/Onest-VariableFont_wght.ttf'),
        (
          'PlayfairDisplay',
          'assets/fonts/playfair/PlayfairDisplay-SemiBold.ttf',
        ),
      ]) {
        await (FontLoader(font.$1)..addFont(rootBundle.load(font.$2))).load();
      }
    });
    await pumpAchievements(tester);
    await tester.runAsync(
      () => Future<void>.delayed(const Duration(milliseconds: 300)),
    );
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    await expectLater(
      find.byKey(const ValueKey('achievements-capture')),
      matchesGoldenFile('goldens/achievements-ru.png'),
    );
    di.get<UserProvider>().applyServerUserSnapshot(
      achievementUser(id: 'new-account', tarot: 0, horoscope: 0, runes: 0),
    );
    await tester.pumpAndSettle();
    await expectLater(
      find.byKey(const ValueKey('achievements-capture')),
      matchesGoldenFile('goldens/achievements-all-locked-ru.png'),
    );
  });
}
