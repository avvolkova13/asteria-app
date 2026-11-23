import 'dart:typed_data';

import 'package:asteria_app/app/data/repositories/user/user_repository.dart';
import 'package:asteria_app/app/providers/user_provider.dart';
import 'package:asteria_app/core/di/di.dart';
import 'package:asteria_app/core/localization/localization.dart';
import 'package:asteria_app/core/routing/app_route.dart';
import 'package:asteria_app/core/services/auth/auth_session_service.dart';
import 'package:asteria_app/core/ui_kit/theme/theme.dart';
import 'package:asteria_app/features/auth/data/email_auth_repository.dart';
import 'package:asteria_app/features/auth/domain/models/auth_identity.dart';
import 'package:asteria_app/features/auth/presentation/cubit/email_auth_cubit.dart';
import 'package:asteria_app/features/auth/presentation/cubit/email_auth_state.dart';
import 'package:asteria_app/features/auth/presentation/screens/email_code_screen.dart';
import 'package:asteria_app/features/practices/data/practice_notes_store.dart';
import 'package:asteria_app/features/sonnik/data/dream_journal.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:hive/hive.dart';

class _Repository extends Fake implements UserRepository {
  final deleted = <String>[];

  @override
  Future<void> deleteUser(String userId) async {
    deleted.add(userId);
  }
}

class _Users extends Fake implements UserProvider {
  int clears = 0;

  @override
  Future<void> clearUser() async {
    clears++;
  }
}

class _Session extends Fake implements AuthSessionService {
  @override
  String? currentUid = 'test-owner';
  int attempts = 0;

  @override
  Future<void> deleteCurrentIdentity() async {
    if (++attempts == 1) throw StateError('temporary failure');
    currentUid = null;
  }
}

class _AuthRepository extends Fake implements EmailAuthRepository {}

class _TestCubit extends EmailAuthCubit {
  _TestCubit(_Repository repository, _Session session, _Users users)
    : super(
        repository: _AuthRepository(),
        sessionService: session,
        userRepository: repository,
        userProvider: users,
      );

  void verify(String uid) {
    emit(
      EmailAuthVerified(
        profileExists: true,
        identity: AuthIdentity.email(userId: uid, email: 'tester@example.test'),
      ),
    );
  }
}

void main() {
  testWidgets('account deletion clears only the verified owner and can retry', (
    tester,
  ) async {
    await Hive.openBox<Map>('dream_journal_v1', bytes: Uint8List(0));
    await Hive.openBox<Map>('practice_notes_v1', bytes: Uint8List(0));
    const notes = PracticeNotesStore();
    final dreams = DreamJournal('test-owner');
    final unrelated = DreamJournal('test-owner/other');
    addTearDown(() async {
      await Hive.close();
      await di.reset();
    });
    await dreams.save('Own dream');
    await unrelated.save('Another account dream');
    for (final owner in ['test-owner', 'test-owner/other']) {
      for (final practice in ['morning', 'evening']) {
        await notes.save(
          ownerId: owner,
          practiceId: practice,
          text: 'Note for $owner',
        );
      }
    }

    final repository = _Repository();
    final session = _Session();
    final users = _Users();
    final cubit = _TestCubit(repository, session, users);
    di.registerSingleton<UserRepository>(repository);
    di.registerSingleton<AuthSessionService>(session);
    di.registerSingleton<UserProvider>(users);
    final router = GoRouter(
      initialLocation: '/verify',
      routes: [
        GoRoute(
          path: '/verify',
          builder: (context, _) => BlocProvider<EmailAuthCubit>.value(
            value: cubit,
            child: Theme(
              data: AppThemeDark.instance.getThemeData(context),
              child: const EmailCodeScreen(
                deleteAfterVerification: true,
                expectedUid: 'test-owner',
              ),
            ),
          ),
        ),
        GoRoute(
          name: AuthRoutes.loginRouteName,
          path: '/login',
          builder: (_, _) => const Scaffold(body: Text('Signed out')),
        ),
      ],
    );
    addTearDown(cubit.close);
    addTearDown(router.dispose);
    await tester.pumpWidget(
      MaterialApp.router(
        routerConfig: router,
        localizationsDelegates: const [
          AppLocalizations.delegate,
          ...GlobalMaterialLocalizations.delegates,
        ],
        supportedLocales: AppLocaleService.supportedLocales,
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));

    cubit.verify('test-owner/other');
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));
    expect(repository.deleted, isEmpty);

    cubit.verify('test-owner');
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));
    expect(session.attempts, 1);
    expect(repository.deleted, ['test-owner']);
    final l10n = AppLocalizations.current;
    expect(find.text(l10n.emailUnknownError), findsOneWidget);
    await tester.tap(find.text(l10n.retry));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));

    expect(find.text('Signed out'), findsOneWidget);
    expect(repository.deleted, ['test-owner']);
    expect(session.attempts, 2);
    expect(await dreams.read(), isEmpty);
    expect((await unrelated.read()).single.text, 'Another account dream');
    for (final practice in ['morning', 'evening']) {
      expect(await notes.read('test-owner', practice), isEmpty);
      expect(
        (await notes.read('test-owner/other', practice)).single.text,
        'Note for test-owner/other',
      );
    }
  });
}
