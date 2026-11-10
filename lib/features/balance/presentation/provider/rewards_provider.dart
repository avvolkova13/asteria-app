import 'dart:async';

import 'package:asteria_app/app/providers/user_provider.dart';
import 'package:asteria_app/features/balance/data/reward_event_store.dart';
import 'package:asteria_app/features/balance/data/reward_share_service.dart';
import 'package:asteria_app/features/balance/data/rewards_api.dart';
import 'package:asteria_app/features/balance/domain/reward_models.dart';
import 'package:asteria_app/features/monetization/presentation/monetization_provider.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

class RewardsProvider extends ChangeNotifier {
  final RewardsApi _api;
  final RewardEventStore _store;
  final RewardShareService _shareService;
  final UserProvider _userProvider;
  final MonetizationProvider _monetizationProvider;
  final Uuid _uuid;

  RewardsProvider({
    required RewardsApi api,
    required RewardEventStore store,
    required RewardShareService shareService,
    required UserProvider userProvider,
    required MonetizationProvider monetizationProvider,
    Uuid uuid = const Uuid(),
  }) : _api = api,
       _store = store,
       _shareService = shareService,
       _userProvider = userProvider,
       _monetizationProvider = monetizationProvider,
       _uuid = uuid;

  List<RewardStatusModel> _items = defaultRewardStatuses;
  bool _isLoading = false;
  bool _isSharing = false;
  RewardErrorCode? _error;
  String? _activeUserId;
  String? _initializedUserId;
  bool _isStarted = false;

  List<RewardStatusModel> get items => _items;
  bool get isLoading => _isLoading;
  bool get isSharing => _isSharing;
  RewardErrorCode? get error => _error;

  int get _timezoneOffsetMinutes => DateTime.now().timeZoneOffset.inMinutes;

  Future<void> start() async {
    if (_isStarted) return;
    _isStarted = true;
    try {
      await _store.init();
      _userProvider.addListener(_handleUserChanged);
      _handleUserChanged();
    } catch (error) {
      _isStarted = false;
      _error = RewardErrorCode.startFailed;
      debugPrint('[RewardsProvider] start failed: $error');
      notifyListeners();
    }
  }

  void _handleUserChanged() {
    final userId = _userProvider.currentUser?.id;
    if (userId == null || userId.isEmpty) {
      final hadUser = _activeUserId != null;
      _activeUserId = null;
      _initializedUserId = null;
      if (hadUser) {
        _items = defaultRewardStatuses;
        _error = null;
        notifyListeners();
      }
      return;
    }
    if (_initializedUserId == userId) return;
    unawaited(initializeForUser(userId));
  }

  Future<void> initializeForUser(String? userId) async {
    await _store.init();
    if (userId == null || userId.isEmpty) return;
    if (_initializedUserId == userId) return;
    _initializedUserId = userId;
    _activeUserId = userId;
    await _replayPending(userId);
    await enqueueEvent(RewardEventType.onboardingComplete);
    await enqueueEvent(RewardEventType.dailyCheckIn);
    await load();
  }

  Future<void> load() async {
    final userId = _activeUserId ?? _userProvider.currentUser?.id;
    if (userId == null || userId.isEmpty) return;
    _activeUserId = userId;
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      final response = await _api.getRewards(
        userId: userId,
        timezoneOffsetMinutes: _timezoneOffsetMinutes,
      );
      if (_userProvider.currentUser?.id == userId &&
          (response.uid == null || response.uid == userId)) {
        _applyResponse(response);
      }
    } catch (error) {
      _error = RewardErrorCode.loadFailed;
      debugPrint('[RewardsProvider] load failed: $error');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<int> enqueueEvent(
    RewardEventType eventType, {
    String? referenceId,
  }) async {
    final userId = _activeUserId ?? _userProvider.currentUser?.id;
    if (userId == null || userId.isEmpty) return 0;
    _activeUserId = userId;
    final needsTimezone =
        eventType == RewardEventType.shareComplete ||
        eventType == RewardEventType.dailyCheckIn;
    final event = PendingRewardEvent(
      eventId: _uuid.v4(),
      userId: userId,
      eventType: eventType,
      referenceId: referenceId,
      timezoneOffsetMinutes: needsTimezone ? _timezoneOffsetMinutes : null,
      createdAt: DateTime.now().toUtc(),
    );
    await _store.save(event);
    return _send(event);
  }

  Future<void> recordOnboarding({String? userId}) async {
    if (userId != null && userId.isNotEmpty) _activeUserId = userId;
    await enqueueEvent(RewardEventType.onboardingComplete);
  }

  Future<void> recordTarotSpread(String deckType) async {
    if ({'main', 'love', 'kelt'}.contains(deckType)) {
      debugPrint(
        '[RewardsProvider] skipping legacy tarot reward evidence: $deckType',
      );
      return;
    }
    await enqueueEvent(
      RewardEventType.tarotSpreadComplete,
      referenceId: deckType,
    );
  }

  Future<void> recordArticleRead(String articleId) async {
    final receiptId = await _api.serveArticleRead(
      articleId: articleId,
      idempotencyKey: 'article-read:$articleId',
    );
    if (receiptId.isEmpty) return;
    await enqueueEvent(RewardEventType.articleRead, referenceId: receiptId);
  }

  Future<int> shareInvite({
    required String text,
    required String subject,
    Rect? origin,
  }) async {
    if (_isSharing) return 0;
    _isSharing = true;
    _error = null;
    notifyListeners();
    try {
      final link = defaultTargetPlatform == TargetPlatform.iOS
          ? 'https://apps.apple.com/app/id6766823016'
          : 'https://play.google.com/store/apps/details?id=com.finext.asteria';
      final succeeded = await _shareService.shareInvite(
        text: text.replaceFirst('{link}', link),
        subject: subject,
        origin: origin,
      );
      if (!succeeded) return 0;
      return await enqueueEvent(RewardEventType.shareComplete);
    } catch (error) {
      _error = RewardErrorCode.shareFailed;
      debugPrint('[RewardsProvider] share failed: $error');
      return 0;
    } finally {
      _isSharing = false;
      notifyListeners();
    }
  }

  Future<void> _replayPending(String userId) async {
    final pending = await _store.eventsFor(userId);
    for (final event in pending) {
      await _send(event);
    }
  }

  Future<int> _send(PendingRewardEvent event) async {
    try {
      if (_userProvider.currentUser?.id != event.userId) {
        return 0;
      }
      final response = await _api.postEvent(event);
      if (_userProvider.currentUser?.id != event.userId ||
          (response.uid != null && response.uid != event.userId)) {
        return 0;
      }
      await _store.delete(event.eventId);
      _applyResponse(response);
      if (response.grantedAmount > 0) {
        await _monetizationProvider.refresh();
      }
      notifyListeners();
      return response.grantedAmount;
    } catch (error) {
      // The event stays in Hive and will be retried on the next authenticated
      // launch. Backend natural keys make replay safe.
      debugPrint(
        '[RewardsProvider] event ${event.eventType.wireValue} failed: $error',
      );
      return 0;
    }
  }

  void _applyResponse(RewardsResponseModel response) {
    _items = response.items;
    _error = null;
    _monetizationProvider.applyRewardResponse(response);
  }
}
