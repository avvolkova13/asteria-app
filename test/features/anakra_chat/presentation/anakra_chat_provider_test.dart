import 'dart:async';

import 'package:asteria_app/app/data/models/anakra_chat/anakra_chat_message_model.dart';

import 'package:asteria_app/app/data/models/user/user_model.dart';
import 'package:asteria_app/app/data/repositories/user/user_repository.dart';
import 'package:asteria_app/app/providers/user_provider.dart';
import 'package:asteria_app/core/localization/generated/l10n.dart';
import 'package:asteria_app/core/localization/app_locale_service.dart';
import 'package:asteria_app/core/services/api/backend_api.dart';
import 'package:asteria_app/core/services/auth/auth_session_service.dart';
import 'package:asteria_app/features/anakra_chat/data/services/anakra_chat_service.dart';
import 'package:asteria_app/features/anakra_chat/presentation/provider/anakra_chat_provider.dart';
import 'package:asteria_app/features/monetization/data/monetization_api.dart';
import 'package:asteria_app/features/monetization/data/pending_feature_execution_store.dart';
import 'package:asteria_app/features/monetization/domain/monetization_models.dart';
import 'package:asteria_app/features/monetization/presentation/monetization_provider.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'package:asteria_app/core/analytics/analytics_facade.dart';
import 'package:asteria_app/core/analytics/product_analytics_service.dart';
import 'package:asteria_app/core/di/di.dart';
import 'package:asteria_app/core/ui_kit/theme/theme.dart';
import 'package:asteria_app/features/anakra_chat/presentation/screens/anakra_chat_screen.dart';
import 'package:asteria_app/features/anakra_chat/presentation/widgets/anakra_composer.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  for (final scenario in [
    'visible',
    'covered',
    'disposed',
    'switch',
    'switch_failure',
    'stale',
    'preflight_switch',
    'preflight_failure',
  ]) {
    testWidgets('Anakra completion analytics: $scenario', (tester) async {
      final user = UserProvider(userRepository: _FakeUserRepository());
      final monetization = scenario == 'preflight_switch'
          ? _DelayedMonetizationProvider(user)
          : scenario == 'preflight_failure'
          ? _UnavailableMonetizationProvider(user)
          : _FailingMonetizationProvider(user);
      final provider = _ControlledChat();
      final events = _ChatEvents();
      di.registerSingleton<AnakraChatProvider>(provider);
      di.registerSingleton<AnalyticsFacade>(events);
      di.registerSingleton<ProductAnalyticsService>(
        ProductAnalyticsService(events),
      );
      final navigator = GlobalKey<NavigatorState>();
      addTearDown(() async {
        await di.reset();
        provider.dispose();
        monetization.dispose();
        user.dispose();
      });
      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider<AnakraChatProvider>.value(value: provider),
            ChangeNotifierProvider<MonetizationProvider>.value(
              value: monetization,
            ),
          ],
          child: MaterialApp(
            navigatorKey: navigator,
            localizationsDelegates: const [
              AppLocalizations.delegate,
              ...GlobalMaterialLocalizations.delegates,
            ],
            supportedLocales: AppLocalizations.delegate.supportedLocales,
            home: Builder(
              builder: (context) => Theme(
                data: AppThemeDark.instance.getThemeData(context),
                child: const AnakraChatScreen(),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextField), 'Hello');
      tester.widget<AnakraComposer>(find.byType(AnakraComposer)).onSend();
      await tester.pump();
      if (scenario == 'covered') {
        navigator.currentState!.push(
          MaterialPageRoute<void>(builder: (_) => const Scaffold()),
        );
        await tester.pumpAndSettle();
      } else if (scenario == 'disposed') {
        await tester.pumpWidget(const SizedBox());
      } else if (scenario.contains('switch')) {
        provider.revision++;
        provider.uid = 'bob';
      }
      if (scenario == 'preflight_switch') {
        (monetization as _DelayedMonetizationProvider).result.complete(true);
      } else if (scenario == 'switch_failure') {
        provider.result.complete(AnakraSendOutcome.failed);
      } else {
        provider.result.complete(
          scenario == 'stale'
              ? AnakraSendOutcome.stale
              : AnakraSendOutcome.result,
        );
      }
      await tester.pumpAndSettle();
      final outcomes = events.names.where(
        (name) =>
            name == 'ast_anakra_response_view' ||
            name == 'ast_error_state_view',
      );
      expect(
        outcomes,
        scenario == 'visible' ? ['ast_anakra_response_view'] : isEmpty,
      );
      if (scenario == 'preflight_switch') expect(provider.sends, 0);
      if (scenario == 'preflight_failure') {
        expect(provider.sends, 0);
        expect(
          tester.widget<TextField>(find.byType(TextField)).controller!.text,
          'Hello',
        );
      }
      if (scenario == 'visible') {
        expect(
          tester.widget<TextField>(find.byType(TextField)).controller!.text,
          isEmpty,
        );
      }
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox());
    });
  }

  test(
    'A to B to A during preflight is stale, never a failure or a new command',
    () async {
      await AppLocalizations.load(const Locale('ru'));
      final user = UserProvider(userRepository: _FakeUserRepository())
        ..applyServerUserSnapshot(UserModel.empty().copyWith(id: 'alice'));
      final monetization = _DelayedMonetizationProvider(user);
      final pending = _RecordingPendingStore();
      final provider = AnakraChatProvider(
        chatService: AnakraChatService(_FakeBackendApi()),
        userProvider: user,
        monetizationProvider: monetization,
        pendingFeatureExecutionStore: pending,
        localeService: AppLocaleService(platformLocales: const [Locale('ru')]),
      );
      addTearDown(() {
        provider.dispose();
        monetization.dispose();
        user.dispose();
      });
      await provider.initialize();
      final sending = provider.sendMessage('Hello');
      user.applyServerUserSnapshot(UserModel.empty().copyWith(id: 'bob'));
      user.applyServerUserSnapshot(UserModel.empty().copyWith(id: 'alice'));
      monetization.result.complete(true);
      expect((await sending).toString(), 'AnakraSendOutcome.stale');
      expect(pending.payloadKeys, isEmpty);
    },
  );

  test('quick actions depend on user history, not message count', () async {
    await AppLocalizations.load(const Locale('ru'));
    final welcome = AnakraChatMessageModel(
      text: 'Welcome',
      isUser: false,
      timestamp: DateTime(2026),
    );
    final userProvider = UserProvider(userRepository: _FakeUserRepository())
      ..applyServerUserSnapshot(
        UserModel.empty().copyWith(
          id: 'user-1',
          anakraMessages: [welcome, welcome],
        ),
      );
    final monetization = _FailingMonetizationProvider(userProvider);
    final provider = AnakraChatProvider(
      chatService: AnakraChatService(_FakeBackendApi()),
      userProvider: userProvider,
      monetizationProvider: monetization,
      pendingFeatureExecutionStore: _RecordingPendingStore(),
      localeService: AppLocaleService(platformLocales: const [Locale('ru')]),
    );
    addTearDown(provider.dispose);
    addTearDown(monetization.dispose);
    addTearDown(userProvider.dispose);
    expect(provider.showQuickActions, isFalse);
    await provider.initialize();
    expect(provider.showQuickActions, isTrue);
    userProvider.applyServerUserSnapshot(
      userProvider.currentUser!.copyWith(anakraMessages: []),
    );
    expect(provider.showQuickActions, isTrue);
    expect(provider.messages, isNotEmpty);
    expect(
      await provider.sendMessage('Hello'),
      AnakraSendOutcome.failed,
      reason: 'A displayed network error is not a useful assistant response',
    );
    expect(provider.showQuickActions, isFalse);
  });

  test(
    'preflight blocks duplicate sends and restores actions after quota refusal',
    () async {
      await AppLocalizations.load(const Locale('ru'));
      final userProvider = UserProvider(userRepository: _FakeUserRepository())
        ..applyServerUserSnapshot(
          UserModel.empty().copyWith(
            id: 'user-1',
            anakraMessages: [
              AnakraChatMessageModel(
                text: 'Welcome',
                isUser: false,
                timestamp: DateTime(2026),
              ),
            ],
          ),
        );
      final monetization = _DelayedMonetizationProvider(userProvider);
      final provider = AnakraChatProvider(
        chatService: AnakraChatService(_FakeBackendApi()),
        userProvider: userProvider,
        monetizationProvider: monetization,
        pendingFeatureExecutionStore: _RecordingPendingStore(),
        localeService: AppLocaleService(platformLocales: const [Locale('ru')]),
      );
      addTearDown(provider.dispose);
      addTearDown(monetization.dispose);
      addTearDown(userProvider.dispose);
      await provider.initialize();
      final first = provider.sendMessage('Hello');
      final expectation = expectLater(first, throwsException);
      expect(
        await provider.sendMessage('Duplicate'),
        AnakraSendOutcome.ignored,
      );
      expect(monetization.checks, 1);
      expect(provider.showQuickActions, isFalse);
      monetization.result.complete(false);
      await expectation;
      expect(provider.showQuickActions, isTrue);
    },
  );

  test('disposing during quota preflight cancels the pending send', () async {
    final userProvider = UserProvider(userRepository: _FakeUserRepository())
      ..applyServerUserSnapshot(UserModel.empty().copyWith(id: 'user-1'));
    final monetization = _DelayedMonetizationProvider(userProvider);
    final pending = _RecordingPendingStore();
    final provider = AnakraChatProvider(
      chatService: AnakraChatService(_FakeBackendApi()),
      userProvider: userProvider,
      monetizationProvider: monetization,
      pendingFeatureExecutionStore: pending,
      localeService: AppLocaleService(platformLocales: const [Locale('ru')]),
    );
    addTearDown(monetization.dispose);
    addTearDown(userProvider.dispose);
    final sending = provider.sendMessage('Hello');
    provider.dispose();
    monetization.result.complete(true);
    await sending;
    expect(pending.payloadKeys, isEmpty);
  });

  test(
    'reuses the same pending command after a transient Anakra failure',
    () async {
      await AppLocalizations.load(const Locale('ru'));
      final userProvider = UserProvider(userRepository: _FakeUserRepository())
        ..applyServerUserSnapshot(UserModel.empty().copyWith(id: 'user-1'));
      final pendingStore = _RecordingPendingStore();
      final monetizationProvider = _FailingMonetizationProvider(userProvider);
      final provider = AnakraChatProvider(
        chatService: AnakraChatService(_FakeBackendApi()),
        userProvider: userProvider,
        monetizationProvider: monetizationProvider,
        pendingFeatureExecutionStore: pendingStore,
        localeService: AppLocaleService(
          platformLocales: const <Locale>[Locale('ru')],
        ),
      );
      addTearDown(provider.dispose);
      addTearDown(userProvider.dispose);

      await provider.sendMessage('Что меня ждет?');
      await provider.sendMessage('Что меня ждет?');

      expect(pendingStore.payloadKeys, hasLength(2));
      expect(pendingStore.payloadKeys.first, pendingStore.payloadKeys.last);
    },
  );
}

class _ControlledChat extends ChangeNotifier implements AnakraChatProvider {
  final result = Completer<AnakraSendOutcome>();
  int revision = 0;
  String uid = 'alice';
  int sends = 0;
  @override
  int get identityRevision => revision;
  @override
  String? get currentUserId => uid;
  @override
  List<AnakraChatMessageModel> get messages => [];
  @override
  bool get isLoadingAnakra => false;
  @override
  bool get showQuickActions => false;
  @override
  Future<void> initialize() async {}
  @override
  Future<AnakraSendOutcome> sendMessage(String text) {
    sends++;
    return result.future;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _ChatEvents implements AnalyticsFacade {
  final names = <String>[];
  @override
  Future<void> trackEvent(String name, {Map<String, dynamic>? params}) async {
    names.add(name);
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _DelayedMonetizationProvider extends _FailingMonetizationProvider {
  _DelayedMonetizationProvider(super.userProvider);
  final result = Completer<bool>();
  @override
  Future<void> refreshForAccess() async {
    await result.future;
  }

  int checks = 0;
  @override
  Future<bool> canMakeRequestFresh(String feature) {
    checks++;
    return result.future;
  }
}

class _FailingMonetizationProvider extends MonetizationProvider {
  _FailingMonetizationProvider(UserProvider userProvider)
    : super(api: _FakeMonetizationApi(), userProvider: userProvider);

  @override
  Future<bool> canMakeRequestFresh(String feature) async => true;
  @override
  Future<void> refreshForAccess() async {}
  @override
  bool isFeatureEnabled(String feature) => true;
  @override
  bool canMakeRequest(String feature) => true;

  @override
  Future<RequestQuotaCommandResultModel> executeRequestQuotaCommand(
    String feature, {
    required Map<String, dynamic> payload,
    String? idempotencyKey,
  }) async {
    throw Exception('network lost after commit');
  }
}

class _RecordingPendingStore extends PendingFeatureExecutionStore {
  final List<String> payloadKeys = [];

  @override
  Future<PendingFeatureExecution> findOrCreate({
    required String userId,
    required String featureKey,
    required String payloadKey,
    String? idempotencyKey,
    Map<String, dynamic>? result,
  }) async {
    payloadKeys.add(payloadKey);
    return PendingFeatureExecution(
      operationId: '$userId:$featureKey:$payloadKey',
      userId: userId,
      featureKey: featureKey,
      payloadKey: payloadKey,
      idempotencyKey: 'stable-key',
      createdAt: DateTime.parse('2026-08-30T12:00:00Z'),
    );
  }
}

class _FakeMonetizationApi extends MonetizationApi {
  _FakeMonetizationApi() : super.forDio(Dio(), _FakeSession());
}

class _FakeUserRepository implements UserRepository {
  @override
  Future<void> updateCurrentUser(UserModel user) async {}
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _FakeBackendApi implements BackendApi {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _FakeSession implements AuthSessionService {
  @override
  String? get currentUid => 'user-1';

  @override
  String? get currentEmail => 'user@example.com';

  @override
  bool get hasRecentSignIn => true;

  @override
  bool get hasSession => true;

  @override
  Future<String?> getAccessToken({bool forceRefresh = false}) async =>
      'user-token';

  @override
  Future<void> saveSession({
    required String uid,
    required String? email,
    required String accessToken,
    required String refreshToken,
    required int expiresIn,
  }) async {}

  @override
  Future<void> signOut() async {}

  @override
  Future<void> deleteCurrentIdentity() async {}
}

class _UnavailableMonetizationProvider extends _FailingMonetizationProvider {
  _UnavailableMonetizationProvider(super.userProvider);
  @override
  Future<void> refreshForAccess() async => throw StateError('offline');
}
