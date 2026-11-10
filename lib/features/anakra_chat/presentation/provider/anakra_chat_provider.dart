import 'dart:async';
import 'dart:convert';

import 'package:asteria_app/app/data/models/anakra_chat/anakra_chat_message_model.dart';
import 'package:asteria_app/app/providers/user_provider.dart';
import 'package:asteria_app/core/di/di.dart';
import 'package:asteria_app/core/extensions/datetime_extensions.dart';
import 'package:asteria_app/core/localization/app_locale_service.dart';
import 'package:asteria_app/core/localization/generated/l10n.dart';
import 'package:asteria_app/features/anakra_chat/data/services/anakra_chat_service.dart';
import 'package:asteria_app/features/monetization/data/pending_feature_execution_store.dart';
import 'package:asteria_app/features/monetization/presentation/monetization_provider.dart';
import 'package:crypto/crypto.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/scheduler.dart';

enum AnakraSendOutcome { result, failed, stale, ignored }

class AnakraChatProvider extends ChangeNotifier {
  final UserProvider _userProvider;
  final MonetizationProvider _monetizationProvider;
  final PendingFeatureExecutionStore _pendingFeatureExecutionStore;
  final AppLocaleService _localeService;
  final List<AnakraChatMessageModel> _messages = [];
  bool _isLoadingAnakra = false;
  bool _isSending = false;
  bool _isInitialized = false;
  bool _disposed = false;
  String? _activeUserId;
  int _identityRevision = 0;
  int get identityRevision => _identityRevision;
  String? get currentUserId => _userProvider.currentUser?.id;

  AnakraChatProvider({
    required AnakraChatService chatService,
    UserProvider? userProvider,
    MonetizationProvider? monetizationProvider,
    PendingFeatureExecutionStore? pendingFeatureExecutionStore,
    AppLocaleService? localeService,
  }) : _userProvider = userProvider ?? di.get<UserProvider>(),
       _monetizationProvider =
           monetizationProvider ?? di.get<MonetizationProvider>(),
       _pendingFeatureExecutionStore =
           pendingFeatureExecutionStore ??
           (di.isRegistered<PendingFeatureExecutionStore>()
               ? di.get<PendingFeatureExecutionStore>()
               : PendingFeatureExecutionStore()),
       _localeService = localeService ?? di.get<AppLocaleService>() {
    _userProvider.addListener(_onUserChanged);
  }

  List<AnakraChatMessageModel> get messages => _messages;
  bool get hasMessages => _messages.isNotEmpty;
  bool get isLoadingAnakra => _isLoadingAnakra || _isSending;
  bool get showQuickActions =>
      _isInitialized &&
      !isLoadingAnakra &&
      !_messages.any((message) => message.isUser);

  Future<void> initialize() async {
    if (_isInitialized) return;

    final user = _userProvider.currentUser;
    _activeUserId = user?.id;
    if (user != null && user.anakraMessages.isNotEmpty) {
      _messages.clear();
      _messages.addAll(user.anakraMessages);
      _isInitialized = true;
      _safeNotifyListeners();
      return;
    }

    if (_messages.isEmpty) {
      _isInitialized = true;
      _messages.add(
        AnakraChatMessageModel(
          text: AppLocalizations.current.anakraWelcomeMessage,
          isUser: false,
          timestamp: DateTime.now(),
          locale: _localeService.languageTag,
        ),
      );
      notifyListeners();
      unawaited(_saveMessages());
    } else {
      _isInitialized = true;
    }
  }

  void _onUserChanged() {
    final user = _userProvider.currentUser;
    final userId = user?.id;
    if (_activeUserId != userId) _identityRevision++;
    if (userId == null || userId.isEmpty) {
      _activeUserId = null;
      _isInitialized = false;
      if (_messages.isNotEmpty) {
        _messages.clear();
        _safeNotifyListeners();
      }
      return;
    }
    final changedUser = _activeUserId != userId;
    _activeUserId = userId;
    final serverMessages = user?.anakraMessages ?? const [];
    // Balance/quota refreshes must not erase an optimistic message or greeting.
    if (!changedUser &&
        (_isSending ||
            (serverMessages.isEmpty &&
                !_messages.any((message) => message.isUser)))) {
      return;
    }
    final sameMessages =
        _messages.length == serverMessages.length &&
        listEquals(
          _messages.map((message) => message.toJson()).toList(),
          serverMessages.map((message) => message.toJson()).toList(),
        );
    if (changedUser || !sameMessages) {
      _messages.clear();
      _messages.addAll(serverMessages);
      if (changedUser) {
        _isInitialized = false;
        unawaited(initialize());
      }
      _safeNotifyListeners();
    }
  }

  Future<void> _saveMessages() async {
    final user = _userProvider.currentUser;
    if (user == null) return;

    final updatedUser = user.copyWith(anakraMessages: _messages);
    await _userProvider.updateUser(updatedUser);
  }

  Future<AnakraSendOutcome> sendMessage(String text) async {
    if (_disposed || text.trim().isEmpty || _isSending) {
      return AnakraSendOutcome.ignored;
    }
    _isSending = true;
    _safeNotifyListeners();
    try {
      return await _sendMessage(text);
    } finally {
      _isSending = false;
      _isLoadingAnakra = false;
      _safeNotifyListeners();
    }
  }

  Future<AnakraSendOutcome> _sendMessage(String text) async {
    final sendingUserId = _userProvider.currentUser?.id;
    final revision = _identityRevision;
    bool stale() =>
        _disposed ||
        _identityRevision != revision ||
        _userProvider.currentUser?.id != sendingUserId;

    final allowed = await _monetizationProvider.canMakeRequestFresh('anakra');
    if (stale()) {
      return AnakraSendOutcome.stale;
    }
    if (!allowed) {
      throw Exception('no_requests');
    }
    final user = _userProvider.currentUser;
    final userId = user?.id;
    if (userId != sendingUserId) return AnakraSendOutcome.stale;
    if (userId == null || userId.isEmpty) {
      throw Exception('Пользователь не авторизован');
    }
    final commandMessages = _messagesForCommandKey(text.trim());
    final payloadKey = _stablePayloadKey('anakra', {
      'text': text.trim(),
      'history': commandMessages
          .map(
            (m) => {'role': m.isUser ? 'user' : 'assistant', 'content': m.text},
          )
          .toList(),
    });
    final pending = await _pendingFeatureExecutionStore.findOrCreate(
      userId: userId,
      featureKey: 'request_quota_command',
      payloadKey: payloadKey,
    );
    if (stale()) return AnakraSendOutcome.stale;
    final conversationHistory = commandMessages
        .map(
          (m) => {'role': m.isUser ? 'user' : 'assistant', 'content': m.text},
        )
        .toList();

    final userMessage = AnakraChatMessageModel(
      text: text.trim(),
      isUser: true,
      timestamp: DateTime.now(),
      locale: _localeService.languageTag,
    );

    _messages.add(userMessage);
    _isLoadingAnakra = true;
    notifyListeners();

    final userName = user?.name;
    final zodiac = user?.personalInfo?.birthDate?.birthDate.getZodiacSignName(
      languageCode: _localeService.contentLanguage,
    );

    try {
      final result = await _monetizationProvider.executeRequestQuotaCommand(
        'anakra',
        payload: {
          'message': text.trim(),
          'conversation_history': conversationHistory,
          'user_name': userName,
          'zodiac': zodiac,
          'locale': _localeService.languageTag,
        },
        idempotencyKey: pending.idempotencyKey,
      );

      if (stale()) {
        _isLoadingAnakra = false;
        return AnakraSendOutcome.stale;
      }

      _messages
        ..clear()
        ..addAll(result.user.anakraMessages);
      _isLoadingAnakra = false;
      notifyListeners();

      await _pendingFeatureExecutionStore.delete(
        userId: userId,
        featureKey: 'request_quota_command',
        payloadKey: payloadKey,
      );
      final delivered = result.user.anakraMessages;
      if (stale()) return AnakraSendOutcome.stale;
      return delivered.length > commandMessages.length &&
              delivered.isNotEmpty &&
              !delivered.last.isUser &&
              delivered.last.text.trim().isNotEmpty
          ? AnakraSendOutcome.result
          : AnakraSendOutcome.failed;
    } catch (e) {
      _isLoadingAnakra = false;
      if (stale()) {
        return AnakraSendOutcome.stale;
      }

      if (e.toString().contains('no_requests') ||
          e.toString().contains('request_quota_insufficient')) {
        _messages.removeLast();
        notifyListeners();
        rethrow;
      }

      final errorMessage = AnakraChatMessageModel(
        text: AppLocalizations.current.anakraServerError,
        isUser: false,
        timestamp: DateTime.now(),
        locale: _localeService.languageTag,
      );
      _messages.add(errorMessage);
      notifyListeners();
      return AnakraSendOutcome.failed;
    }
  }

  String _stablePayloadKey(String feature, Map<String, dynamic> payload) {
    final canonical = jsonEncode({'feature': feature, 'payload': payload});
    return '$feature:${sha256.convert(utf8.encode(canonical))}';
  }

  List<AnakraChatMessageModel> _messagesForCommandKey(String text) {
    final messages = List<AnakraChatMessageModel>.of(_messages);
    if (messages.length < 2) return messages;
    final last = messages.last;
    final previous = messages[messages.length - 2];
    if (!last.isUser &&
        last.text == AppLocalizations.current.anakraServerError &&
        previous.isUser &&
        previous.text.trim() == text) {
      messages.removeLast();
      messages.removeLast();
    }
    return messages;
  }

  Future<void> addInitialMessage() async {
    if (_messages.isEmpty) {
      _messages.add(
        AnakraChatMessageModel(
          text: AppLocalizations.current.anakraWelcomeMessage,
          isUser: false,
          timestamp: DateTime.now(),
          locale: _localeService.languageTag,
        ),
      );
      notifyListeners();
      await _saveMessages();
    }
  }

  void clearMessages() {
    _messages.clear();
    notifyListeners();
  }

  void _safeNotifyListeners() {
    if (_disposed) return;
    if (SchedulerBinding.instance.schedulerPhase ==
        SchedulerPhase.persistentCallbacks) {
      SchedulerBinding.instance.addPostFrameCallback((_) {
        if (!_disposed) notifyListeners();
      });
    } else {
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _disposed = true;
    _userProvider.removeListener(_onUserChanged);
    super.dispose();
  }
}
