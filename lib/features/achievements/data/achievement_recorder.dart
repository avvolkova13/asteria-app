import 'dart:async';

import 'package:asteria_app/app/providers/user_provider.dart';
import 'package:asteria_app/features/achievements/data/achievement_event_store.dart';
import 'package:asteria_app/features/achievements/data/achievements_api.dart';
import 'package:asteria_app/features/achievements/domain/achievement_event.dart';
import 'package:flutter/widgets.dart';

/// Sends durable, account-scoped events; the backend deduplicates their natural keys.
class AchievementRecorder with WidgetsBindingObserver {
  AchievementRecorder({
    required AchievementsApi api,
    required AchievementEventStore store,
    required UserProvider userProvider,
  }) : _api = api,
       _store = store,
       _userProvider = userProvider {
    _userProvider.addListener(_onUserChanged);
    WidgetsBinding.instance.addObserver(this);
    _onUserChanged();
  }

  final AchievementsApi _api;
  final AchievementEventStore _store;
  final UserProvider _userProvider;
  Future<void> _queue = Future<void>.value();
  String? _userId;
  bool _disposed = false;

  void _onUserChanged() {
    final userId = _userProvider.currentUser?.id;
    if (_userId == userId) return;
    _userId = userId;
    if (userId != null && userId.isNotEmpty) unawaited(flush());
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) unawaited(flush());
  }

  Future<void> record(AchievementEvent event) async {
    if (_disposed || _userProvider.currentUser?.id != event.userId) return;
    try {
      await _store.save(event);
      unawaited(flush());
    } catch (error) {
      // Achievement failure must not turn a successful content action into an error.
      debugPrint('[Achievements] Could not persist event: $error');
    }
  }

  Future<void> flush() {
    _queue = _queue.then((_) => _sendPending());
    return _queue;
  }

  Future<void> _sendPending() async {
    final userId = _userProvider.currentUser?.id;
    if (_disposed || userId == null || userId.isEmpty) return;
    try {
      for (final event in await _store.eventsFor(userId)) {
        if (_disposed || _userProvider.currentUser?.id != userId) return;
        final statistics = await _api.record(event);
        final currentUser = _userProvider.currentUser;
        if (_disposed || currentUser?.id != userId) return;
        _userProvider.applyAchievementStatistics(userId, statistics);
        await _store.delete(event);
      }
    } catch (error) {
      // Keep the event for the next action, app resume or authenticated launch.
      debugPrint('[Achievements] Event remains pending: $error');
    }
  }

  void dispose() {
    _disposed = true;
    _userProvider.removeListener(_onUserChanged);
    WidgetsBinding.instance.removeObserver(this);
  }
}
