import 'dart:async';

import 'package:asteria_app/features/balance/presentation/balance_history_controller.dart';
import 'package:asteria_app/features/monetization/domain/monetization_models.dart';
import 'package:flutter_test/flutter_test.dart';

WalletHistoryEntryModel entry(int sequence) =>
    WalletHistoryEntryModel.fromJson({
      'entry_id': 'entry-$sequence',
      'sequence': sequence,
      'amount': 5,
      'created_at': '2026-09-10T12:00:00Z',
    });

WalletHistoryPageModel page(
  List<int> sequences, {
  int? next,
  bool hasEntries = true,
}) => WalletHistoryPageModel(
  items: sequences.map(entry).toList(),
  nextBeforeSequence: next,
  hasEntries: hasEntries,
);

void main() {
  late List<
    ({
      WalletHistoryFilter filter,
      int? before,
      Completer<WalletHistoryPageModel> result,
    })
  >
  calls;
  late BalanceHistoryController controller;
  setUp(() {
    calls = [];
    controller = BalanceHistoryController(
      loadPage: ({required filter, beforeSequence}) {
        final result = Completer<WalletHistoryPageModel>();
        calls.add((filter: filter, before: beforeSequence, result: result));
        return result.future;
      },
    );
    controller.setAccount('a');
  });
  tearDown(() => controller.dispose());
  Future<void> resolve(WalletHistoryPageModel value) async {
    calls.last.result.complete(value);
    await Future<void>.delayed(Duration.zero);
  }

  test('loads all and distinguishes global empty from empty filter', () async {
    expect(controller.isLoading, isTrue);
    expect(calls.single.filter, WalletHistoryFilter.all);
    await resolve(page([], hasEntries: false));
    expect(controller.isGloballyEmpty, isTrue);
    controller.selectFilter(WalletHistoryFilter.withdrawals);
    await resolve(page([]));
    expect(controller.isGloballyEmpty, isFalse);
    expect(controller.hasEntries, isTrue);
  });

  test('initial failure is not empty and can retry', () async {
    calls.single.result.completeError(Exception('offline'));
    await Future<void>.delayed(Duration.zero);
    expect(controller.error, isNotNull);
    expect(controller.isGloballyEmpty, isFalse);
    final retry = controller.refresh();
    await resolve(page([4]));
    await retry;
    expect(controller.error, isNull);
    expect(controller.items.single.sequence, 4);
  });

  test('pages once per cursor, deduplicates and stops at end', () async {
    await resolve(page([5, 4], next: 4));
    final loading = controller.loadMore();
    controller.loadMore();
    expect(calls.length, 2);
    expect(calls.last.before, 4);
    await resolve(page([4, 3]));
    await loading;
    expect(controller.items.map((e) => e.sequence), [5, 4, 3]);
    await controller.loadMore();
    expect(calls.length, 2);
  });

  test('filter switch discards late previous response', () async {
    final previous = calls.single.result;
    controller.selectFilter(WalletHistoryFilter.deposits);
    await resolve(page([8]));
    previous.complete(page([100]));
    await Future<void>.delayed(Duration.zero);
    expect(controller.items.single.sequence, 8);
    expect(controller.filter, WalletHistoryFilter.deposits);
  });

  test(
    'failed newly selected filter is a loading error, not empty results',
    () async {
      await resolve(page([8]));
      controller.selectFilter(WalletHistoryFilter.withdrawals);
      expect(controller.isLoading, isTrue);
      calls.last.result.completeError(Exception('offline'));
      await Future<void>.delayed(Duration.zero);
      expect(controller.error, isNotNull);
      expect(controller.isGloballyEmpty, isFalse);
    },
  );

  test('refresh invalidates next page and retains rows on failure', () async {
    await resolve(page([5], next: 5));
    controller.loadMore();
    final stalePage = calls.last.result;
    controller.refresh();
    calls.last.result.completeError(Exception('offline'));
    await Future<void>.delayed(Duration.zero);
    stalePage.complete(page([4]));
    await Future<void>.delayed(Duration.zero);
    expect(controller.items.map((e) => e.sequence), [5]);
    expect(controller.refreshError, isNotNull);
    expect(controller.error, isNull);
  });

  test('page failure preserves rows and retry uses same cursor', () async {
    await resolve(page([5], next: 5));
    controller.loadMore();
    calls.last.result.completeError(Exception('offline'));
    await Future<void>.delayed(Duration.zero);
    expect(controller.items.single.sequence, 5);
    expect(controller.pageError, isNotNull);
    controller.loadMore();
    expect(calls.last.before, 5);
    await resolve(page([4]));
    expect(controller.pageError, isNull);
  });

  test(
    'account change and logout clear rows and discard pending work',
    () async {
      final previous = calls.single.result;
      controller.setAccount('b');
      await resolve(page([2]));
      previous.complete(page([1]));
      await Future<void>.delayed(Duration.zero);
      expect(controller.items.single.sequence, 2);
      controller.setAccount(null);
      expect(controller.items, isEmpty);
      expect(controller.hasEntries, isNull);
      await controller.refresh();
      expect(calls.length, 2);
    },
  );

  test('disposal prevents late notification', () async {
    var notifications = 0;
    controller.addListener(() => notifications++);
    controller.dispose();
    await resolve(page([1]));
    expect(notifications, 0);
  });
}
