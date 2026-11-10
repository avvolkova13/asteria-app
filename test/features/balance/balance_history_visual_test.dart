import 'package:asteria_app/features/balance/presentation/balance_history_controller.dart';
import 'package:asteria_app/features/monetization/domain/monetization_models.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

import 'balance_history_screen_test.dart' show historyApp;

List<WalletHistoryEntryModel> referenceEntries() =>
    [
          (4, 300, '01', '07', 'Пополнение'),
          (3, -50, '30', '06', 'Совместимость'),
          (2, -30, '29', '06', 'Расшифровка сна'),
          (1, 300, '16', '06', 'Награда за отзыв'),
        ]
        .map(
          (row) => WalletHistoryEntryModel.fromJson({
            'entry_id': 'entry-${row.$1}',
            'sequence': row.$1,
            'amount': row.$2,
            'description': row.$5,
            'created_at': '2025-${row.$4}-${row.$3}T12:00:00Z',
          }),
        )
        .toList();

void main() {
  for (final empty in [false, true]) {
    testWidgets('history reference ${empty ? 'empty' : 'populated'}', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(390, 844);
      tester.view.devicePixelRatio = 1;
      tester.view.padding = const FakeViewPadding(top: 59, bottom: 34);
      addTearDown(tester.view.reset);
      await tester.runAsync(() async {
        for (final font in [
          ('MaterialIcons', 'fonts/MaterialIcons-Regular.otf'),
          ('Onest', 'assets/fonts/onest/Onest-VariableFont_wght.ttf'),
          ('Lora', 'assets/fonts/lora/Lora-VariableFont_wght.ttf'),
          (
            'PlayfairDisplay',
            'assets/fonts/playfair/PlayfairDisplay-SemiBold.ttf',
          ),
        ]) {
          await (FontLoader(font.$1)..addFont(rootBundle.load(font.$2))).load();
        }
      });
      final controller = BalanceHistoryController(
        loadPage: ({required filter, beforeSequence}) async =>
            WalletHistoryPageModel(
              items: empty ? [] : referenceEntries(),
              hasEntries: !empty,
              nextBeforeSequence: null,
            ),
      );
      addTearDown(controller.dispose);
      controller.setAccount('fixture');
      await tester.pumpWidget(
        RepaintBoundary(
          key: const Key('capture'),
          child: historyApp(controller, balance: 230, hasPro: true),
        ),
      );
      await tester.pumpAndSettle();
      // Image decoding and GPU resource loading run outside the fake test clock.
      await tester.runAsync(
        () => Future<void>.delayed(const Duration(milliseconds: 300)),
      );
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      await expectLater(
        find.byKey(const Key('capture')),
        matchesGoldenFile(
          'goldens/history-${empty ? 'empty' : 'populated'}.png',
        ),
      );
    });
  }
}
