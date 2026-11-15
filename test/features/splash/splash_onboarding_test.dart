import 'dart:io';

import 'package:asteria_app/app/data/models/user/user_model.dart';
import 'package:asteria_app/app/data/repositories/app_settings/app_settings_repository.dart';
import 'package:asteria_app/app/data/repositories/user/user_repository.dart';
import 'package:asteria_app/core/services/auth/auth_session_service.dart';
import 'package:asteria_app/core/services/hive/hive_service.dart';
import 'package:asteria_app/features/scenarios/first_session.dart';
import 'package:asteria_app/features/splash/presentation/bloc/splash_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';

class _User extends Fake implements UserModel {
  _User(this.id);

  @override
  final String id;
}

class _Users extends Fake implements UserRepository {
  _Users(this.value);

  final UserModel? value;

  @override
  Future<UserModel?> getCurrentUser() async => value;
}

class _Session extends Fake implements AuthSessionService {
  _Session(this.hasSession);

  @override
  final bool hasSession;
}

class _Settings extends Fake implements AppSettingsRepository {
  _Settings(this.showOnboarding);

  final bool showOnboarding;

  @override
  bool getShowOnboarding() => showOnboarding;
}

Future<String> _launch({
  String? uid,
  bool hasSession = false,
  bool showOnboarding = true,
}) async {
  final bloc = SplashBloc(
    appSettings: _Settings(showOnboarding),
    userRepository: _Users(uid == null ? null : _User(uid)),
    authSessionService: _Session(hasSession),
  );
  final result = bloc.stream.firstWhere(
    (state) => state is SplashSuccess || state is SplashError,
  );
  try {
    bloc.add(const InitializeApp());
    final state = await result.timeout(const Duration(seconds: 5));
    expect(state, isA<SplashSuccess>());
    return (state as SplashSuccess).initialRoute;
  } finally {
    await bloc.close();
  }
}

void main() {
  late Directory directory;

  setUp(() async {
    directory = await Directory.systemTemp.createTemp('asteria-splash-intro-');
    Hive.init(directory.path);
    await Hive.openBox<Map>(HiveBoxNames.appSettings);
  });

  tearDown(() async {
    await Hive.close();
    await directory.delete(recursive: true);
  });

  test('signed-out user with onboarding enabled opens onboarding', () async {
    expect(await _launch(), '/onboarding');
  });

  test('signed-out user with onboarding completed opens login', () async {
    expect(await _launch(showOnboarding: false), '/auth/login');
  });

  for (final showOnboarding in [true, false]) {
    test(
      'incomplete session opens profile entry when onboarding is $showOnboarding',
      () async {
        expect(
          await _launch(hasSession: true, showOnboarding: showOnboarding),
          '/auth/personal-info',
        );
      },
    );

    test(
      'existing account opens pending scenarios when onboarding is $showOnboarding',
      () async {
        await FirstSession.begin('existing');
        expect(
          await _launch(
            uid: 'existing',
            hasSession: true,
            showOnboarding: showOnboarding,
          ),
          FirstSession.path,
        );
      },
    );

    test(
      'existing account opens home after scenarios when onboarding is $showOnboarding',
      () async {
        await FirstSession.finish('existing');
        expect(
          await _launch(
            uid: 'existing',
            hasSession: true,
            showOnboarding: showOnboarding,
          ),
          '/home',
        );
      },
    );
  }

  test(
    'legacy account without a scenario flag keeps its introduction',
    () async {
      expect(
        await _launch(uid: 'legacy-existing', hasSession: true),
        FirstSession.path,
      );
    },
  );
}
