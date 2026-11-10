import 'package:asteria_app/features/monetization/domain/monetization_models.dart';
import 'package:flutter/foundation.dart';

typedef WalletHistoryLoader =
    Future<WalletHistoryPageModel> Function({
      required WalletHistoryFilter filter,
      int? beforeSequence,
    });

class BalanceHistoryController extends ChangeNotifier {
  BalanceHistoryController({required WalletHistoryLoader loadPage})
    : _loadPage = loadPage;

  final WalletHistoryLoader _loadPage;
  List<WalletHistoryEntryModel> _items = const [];
  List<WalletHistoryEntryModel> get items => _items;
  WalletHistoryFilter _filter = WalletHistoryFilter.all;
  WalletHistoryFilter get filter => _filter;
  bool? hasEntries;
  bool isLoading = false;
  bool isRefreshing = false;
  bool isLoadingMore = false;
  Object? error;
  Object? refreshError;
  Object? pageError;
  int? _next;
  int _generation = 0;
  String? _account;
  bool _disposed = false;
  bool _hasLoadedFilter = false;

  bool get hasMore => _next != null;
  bool get isGloballyEmpty => hasEntries == false && error == null;

  void setAccount(String? account) {
    if (_account == account || _disposed) return;
    _account = account;
    _filter = WalletHistoryFilter.all;
    _reset();
    if (account != null) {
      refresh();
    } else {
      notifyListeners();
    }
  }

  void _reset() {
    _generation++;
    _items = const [];
    _next = null;
    hasEntries = null;
    _hasLoadedFilter = false;
    error = refreshError = pageError = null;
    isLoading = isRefreshing = isLoadingMore = false;
  }

  Future<void> selectFilter(WalletHistoryFilter value) async {
    if (_filter == value || _disposed) return;
    _filter = value;
    final previousHasEntries = hasEntries;
    _reset();
    hasEntries = previousHasEntries;
    await refresh();
  }

  Future<void> refresh() async {
    if (_disposed || _account == null) return;
    final generation = ++_generation;
    final keepContent = _hasLoadedFilter;
    isLoading = !keepContent;
    isRefreshing = keepContent;
    isLoadingMore = false;
    error = refreshError = pageError = null;
    notifyListeners();
    try {
      final page = await _loadPage(filter: _filter);
      if (!_isCurrent(generation)) return;
      _items = List.unmodifiable(
        {for (final item in page.items) item.entryId: item}.values,
      );
      hasEntries = page.hasEntries;
      _hasLoadedFilter = true;
      _next = page.nextBeforeSequence;
    } catch (failure) {
      if (!_isCurrent(generation)) return;
      if (keepContent) {
        refreshError = failure;
      } else {
        error = failure;
      }
    } finally {
      if (_isCurrent(generation)) {
        isLoading = isRefreshing = false;
        notifyListeners();
      }
    }
  }

  Future<void> loadMore() async {
    final before = _next;
    if (_disposed ||
        before == null ||
        isLoading ||
        isRefreshing ||
        isLoadingMore) {
      return;
    }
    final generation = _generation;
    isLoadingMore = true;
    pageError = null;
    notifyListeners();
    try {
      final page = await _loadPage(filter: _filter, beforeSequence: before);
      if (!_isCurrent(generation)) return;
      if (page.nextBeforeSequence != null &&
          page.nextBeforeSequence! >= before) {
        throw const FormatException('Wallet history cursor did not advance');
      }
      _items = List.unmodifiable(
        {
          for (final item in [..._items, ...page.items]) item.entryId: item,
        }.values,
      );
      _next = page.nextBeforeSequence;
    } catch (failure) {
      if (_isCurrent(generation)) pageError = failure;
    } finally {
      if (_isCurrent(generation)) {
        isLoadingMore = false;
        notifyListeners();
      }
    }
  }

  bool _isCurrent(int generation) => !_disposed && generation == _generation;

  @override
  void dispose() {
    if (_disposed) return;
    _disposed = true;
    _generation++;
    super.dispose();
  }
}
