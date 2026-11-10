import 'dart:io';
import 'package:asteria_app/app/data/models/user/user_model.dart';
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

Future<String> launch({String? uid, bool session = true}) async {
  final bloc = SplashBloc(
    userRepository: _Users(uid == null ? null : _User(uid)),
    authSessionService: _Session(session),
  );
  final result = bloc.stream
      .where((e) => e is SplashSuccess || e is SplashError)
      .first;
  bloc.add(const InitializeApp());
  final state = await result;
  await bloc.close();
  return (state as SplashSuccess).initialRoute;
}

void main() {
  late Directory dir;
  setUp(() async {
    dir = await Directory.systemTemp.createTemp('asteria-first-session');
    Hive.init(dir.path);
    final box = await Hive.openBox<Map>(HiveBoxNames.appSettings);
    await box.put('show_onboarding', {'value': true});
  });
  tearDown(() async {
    await Hive.close();
    await dir.delete(recursive: true);
  });
  test(
    'old onboarding preference skips directly to login or missing profile',
    () async {
      expect(await launch(session: false), '/auth/login');
      expect(await launch(), '/auth/personal-info');
    },
  );
  test(
    'existing accounts skip the chooser; unfinished choice persists across relaunch',
    () async {
      await FirstSession.begin('new');
      await Hive.close();
      await Hive.openBox<Map>(HiveBoxNames.appSettings);
      expect(await launch(uid: 'new'), FirstSession.path);
      expect(await launch(uid: 'existing'), '/home');
      await FirstSession.finish('new');
      expect(await launch(uid: 'new'), '/home');
    },
  );
}
