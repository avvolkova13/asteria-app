import 'package:asteria_app/core/ui_kit/theme/theme.dart';
import 'package:asteria_app/core/localization/generated/l10n.dart';
import 'package:asteria_app/features/balance/presentation/balance_history_controller.dart';
import 'package:asteria_app/features/balance/presentation/screens/balance_history_screen.dart';
import 'package:asteria_app/features/monetization/domain/monetization_models.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';

import 'balance_history_controller_test.dart' show page;

Widget historyApp(
  BalanceHistoryController controller, {
  String locale = 'ru',
  double scale = 1,
  int balance = 0,
  bool hasPro = false,
}) => MaterialApp(
  debugShowCheckedModeBanner: false,
  locale: Locale(locale),
  supportedLocales: AppLocalizations.delegate.supportedLocales,
  localizationsDelegates: const [
    AppLocalizations.delegate,
    ...GlobalMaterialLocalizations.delegates,
  ],
  home: Builder(
    builder: (context) => Theme(
      data: AppThemeDark.instance.getThemeData(context),
      child: MediaQuery(
        data: MediaQuery.of(
          context,
        ).copyWith(textScaler: TextScaler.linear(scale)),
        child: BalanceHistoryView(
          controller: controller,
          balance: balance,
          hasPro: hasPro,
          onBack: () {},
        ),
      ),
    ),
  ),
);

void main() {
  testWidgets('legacy horoscope charge keeps its amount and ledger entry', (
    tester,
  ) async {
    final entry = WalletHistoryEntryModel.fromJson({
      'entry_id': 'legacy-debit',
      'sequence': 3,
      'amount': -30,
      'balance_after': 12,
      'created_at': '2026-08-30T14:00:00Z',
      'description': 'Покупка гороскопа на неделю',
    });
    final controller = BalanceHistoryController(
      loadPage: ({required filter, beforeSequence}) async =>
          WalletHistoryPageModel(
            items: [entry],
            nextBeforeSequence: null,
            hasEntries: true,
          ),
    );
    addTearDown(controller.dispose);
    controller.setAccount('a');
    await tester.pumpWidget(historyApp(controller));
    await tester.pumpAndSettle();
    expect(find.byKey(const ValueKey('legacy-debit')), findsOneWidget);
    expect(find.text('Операция по балансу'), findsOneWidget);
    expect(find.text('-30'), findsOneWidget);
    expect(find.text(entry.description), findsNothing);
    expect(entry.description, 'Покупка гороскопа на неделю');
  });
  testWidgets('scrolling loads next page and retry retains existing rows', (
    tester,
  ) async {
    var failPage = true;
    final cursors = <int?>[];
    final controller = BalanceHistoryController(
      loadPage: ({required filter, beforeSequence}) async {
        cursors.add(beforeSequence);
        if (beforeSequence == null) {
          return page(List.generate(20, (i) => 30 - i), next: 11);
        }
        if (failPage) throw Exception('offline');
        return page(List.generate(10, (i) => 10 - i));
      },
    );
    addTearDown(controller.dispose);
    controller.setAccount('a');
    await tester.pumpWidget(historyApp(controller));
    await tester.pumpAndSettle();
    await tester.drag(
      find.byKey(const Key('history-scroll')),
      const Offset(0, -900),
    );
    await tester.pumpAndSettle();
    expect(controller.items.length, 20);
    expect(controller.pageError, isNotNull);
    await tester.ensureVisible(find.text('Повторить'));
    await tester.pumpAndSettle();
    failPage = false;
    await tester.tap(find.text('Повторить'));
    await tester.pumpAndSettle();
    expect(controller.items.length, 30);
    expect(cursors, [null, 11, 11]);
    expect(controller.pageError, isNull);
  });

  testWidgets('pull to refresh retains rows when request fails', (
    tester,
  ) async {
    var fail = false;
    final controller = BalanceHistoryController(
      loadPage: ({required filter, beforeSequence}) async {
        if (fail) throw Exception('offline');
        return page([1]);
      },
    );
    addTearDown(controller.dispose);
    controller.setAccount('a');
    await tester.pumpWidget(historyApp(controller));
    await tester.pumpAndSettle();
    fail = true;
    await tester.drag(
      find.byKey(const Key('history-scroll')),
      const Offset(0, 400),
    );
    await tester.pumpAndSettle();
    expect(find.text('+5'), findsOneWidget);
    expect(find.text('Не удалось обновить историю'), findsOneWidget);
    expect(find.byKey(const Key('history-empty')), findsNothing);
  });

  testWidgets('global empty uses Figma artwork and no filters', (tester) async {
    final controller = BalanceHistoryController(
      loadPage: ({required filter, beforeSequence}) async =>
          page([], hasEntries: false),
    );
    addTearDown(controller.dispose);
    controller.setAccount('a');
    await tester.pumpWidget(historyApp(controller));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('history-empty')), findsOneWidget);
    expect(find.byKey(const Key('history-filters')), findsNothing);
    final text = tester.widget<Text>(
      find.text(AppLocalizations.current.balanceHistoryEmpty),
    );
    expect(text.style?.fontFamily, 'Lora');
    expect(text.style?.fontSize, 24);
    expect(find.byKey(const Key('history-empty-art')), findsOneWidget);
  });

  testWidgets('zero balance retains history and filter empty retains tabs', (
    tester,
  ) async {
    final controller = BalanceHistoryController(
      loadPage: ({required filter, beforeSequence}) async =>
          page(filter == WalletHistoryFilter.all ? [1] : []),
    );
    addTearDown(controller.dispose);
    controller.setAccount('a');
    await tester.pumpWidget(historyApp(controller));
    await tester.pumpAndSettle();
    expect(find.text('+5'), findsOneWidget);
    await tester.tap(find.text('Списания'));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('history-filters')), findsOneWidget);
    expect(find.text('Нет списаний'), findsOneWidget);
    expect(find.byKey(const Key('history-empty')), findsNothing);
  });

  testWidgets('initial error is retryable and never displays empty artwork', (
    tester,
  ) async {
    var fail = true;
    final controller = BalanceHistoryController(
      loadPage: ({required filter, beforeSequence}) async {
        if (fail) throw Exception('offline');
        return page([1]);
      },
    );
    addTearDown(controller.dispose);
    controller.setAccount('a');
    await tester.pumpWidget(historyApp(controller));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('history-empty')), findsNothing);
    expect(find.byKey(const Key('history-error')), findsOneWidget);
    fail = false;
    await tester.tap(find.text('Повторить'));
    await tester.pumpAndSettle();
    expect(find.text('+5'), findsOneWidget);
  });

  for (final width in [320.0, 390.0, 430.0]) {
    for (final locale in ['ru', 'en']) {
      for (final scale in [1.0, 2.0]) {
        testWidgets('history fits width=$width locale=$locale scale=$scale', (
          tester,
        ) async {
          tester.view.physicalSize = Size(width, 844);
          tester.view.devicePixelRatio = 1;
          addTearDown(tester.view.resetPhysicalSize);
          addTearDown(tester.view.resetDevicePixelRatio);
          final entry = WalletHistoryEntryModel.fromJson({
            'entry_id': 'long',
            'sequence': 1,
            'amount': 9007199254740991,
            'description': List.filled(
              3,
              'Длинное описание операции',
            ).join(' '),
            'created_at': '2026-09-10T12:00:00Z',
          });
          var empty = false;
          final controller = BalanceHistoryController(
            loadPage: ({required filter, beforeSequence}) async =>
                WalletHistoryPageModel(
                  items: empty ? [] : [entry],
                  hasEntries: !empty,
                  nextBeforeSequence: null,
                ),
          );
          addTearDown(controller.dispose);
          controller.setAccount('a');
          await tester.pumpWidget(
            historyApp(
              controller,
              locale: locale,
              scale: scale,
              balance: 9007199254740991,
            ),
          );
          await tester.pumpAndSettle();
          expect(tester.takeException(), isNull);
          expect(find.text(entry.description), findsOneWidget);
          empty = true;
          await controller.refresh();
          await tester.pumpAndSettle();
          expect(tester.takeException(), isNull);
          expect(find.byKey(const Key('history-empty')), findsOneWidget);
        });
      }
    }
  }
}
