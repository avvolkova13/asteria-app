import 'dart:io';

import 'package:asteria_app/features/balance/presentation/balance_history_controller.dart';
import 'package:asteria_app/features/monetization/domain/monetization_models.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import '../test/features/balance/balance_history_screen_test.dart'
    show historyApp;
import '../test/features/balance/balance_history_visual_test.dart'
    show referenceEntries;

void main() {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  testWidgets('AST-188 renders history and empty states on device', (
    tester,
  ) async {
    var empty = false;
    final controller = BalanceHistoryController(
      loadPage: ({required filter, beforeSequence}) async =>
          WalletHistoryPageModel(
            items: empty
                ? []
                : referenceEntries()
                      .where(
                        (entry) => switch (filter) {
                          WalletHistoryFilter.all => true,
                          WalletHistoryFilter.deposits => entry.isDeposit,
                          WalletHistoryFilter.withdrawals => !entry.isDeposit,
                        },
                      )
                      .toList(),
            hasEntries: !empty,
            nextBeforeSequence: null,
          ),
    );
    addTearDown(controller.dispose);
    controller.setAccount('fixture');
    await tester.pumpWidget(historyApp(controller, balance: 230, hasPro: true));
    await tester.pumpAndSettle();
    await tester.pump(const Duration(seconds: 1));
    expect(find.text('Пополнение'), findsOneWidget);
    expect(tester.takeException(), isNull);
    final populated = await binding.takeScreenshot('ast188-populated');
    final dir = Directory('${Directory.systemTemp.path}/ast188')
      ..createSync(recursive: true);
    await File('${dir.path}/populated.png').writeAsBytes(populated);
    await tester.tap(find.text('Списания'));
    await tester.pumpAndSettle();
    expect(find.text('Пополнение'), findsNothing);
    expect(find.text('Совместимость'), findsOneWidget);
    empty = true;
    await controller.refresh();
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('history-empty')), findsOneWidget);
    expect(find.byKey(const Key('history-filters')), findsNothing);
    final screenshot = await binding.takeScreenshot('ast188-empty');
    await File('${dir.path}/empty.png').writeAsBytes(screenshot);
    expect(tester.takeException(), isNull);
    debugPrint('AST188_SCREENSHOTS=${dir.path}');
    if (const bool.fromEnvironment('AST188_CAPTURE')) {
      await Future<void>.delayed(const Duration(seconds: 30));
    }
  });
}
