import 'dart:async';
import 'dart:io';

import 'package:asteria_app/app/data/models/user/user_model.dart';
import 'package:asteria_app/app/data/repositories/user/user_repository.dart';
import 'package:asteria_app/app/providers/user_provider.dart';
import 'package:asteria_app/features/achievements/data/achievement_event_store.dart';
import 'package:asteria_app/features/achievements/data/achievement_recorder.dart';
import 'package:asteria_app/features/achievements/data/achievements_api.dart';
import 'package:asteria_app/features/achievements/domain/achievement_event.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late Directory directory;
  late UserProvider user;
  late _Api api;
  late AchievementEventStore store;
  late AchievementRecorder recorder;

  setUp(() async {
    directory = await Directory.systemTemp.createTemp('asteria-achievements-');
    Hive.init(directory.path);
    user = UserProvider(userRepository: _Repository());
    user.applyServerUserSnapshot(
      UserModel.empty().copyWith(id: 'a', balance: 42),
    );
    api = _Api();
    store = AchievementEventStore();
    recorder = AchievementRecorder(api: api, store: store, userProvider: user);
    await recorder.flush();
  });
  tearDown(() async {
    recorder.dispose();
    user.dispose();
    await Hive.close();
    await directory.delete(recursive: true);
  });

  test(
    'successful event updates progress while preserving other account data',
    () async {
      await recorder.record(_event());
      await recorder.flush();
      expect(user.currentUser!.statistics.tarotCardsOpened, 1);
      expect(user.currentUser!.balance, 42);
      expect(await store.eventsFor('a'), isEmpty);
    },
  );

  test(
    'lost server response survives restart and replay without duplicate credit',
    () async {
      api.loseResponse = true;
      await recorder.record(_event());
      await recorder.flush();
      expect(user.currentUser!.statistics.tarotCardsOpened, 0);
      expect(await store.eventsFor('a'), hasLength(1));
      recorder.dispose();
      await Hive.close();
      api.loseResponse = false;
      store = AchievementEventStore();
      recorder = AchievementRecorder(
        api: api,
        store: store,
        userProvider: user,
      );
      await recorder.flush();
      expect(user.currentUser!.statistics.tarotCardsOpened, 1);
      expect(api.credited, hasLength(1));
      expect(await store.eventsFor('a'), isEmpty);
    },
  );

  test('late response cannot write progress into another account', () async {
    api.pause = Completer<void>();
    final request = recorder.record(_event());
    await api.started.future;
    user.applyServerUserSnapshot(UserModel.empty().copyWith(id: 'b'));
    api.pause!.complete();
    await request;
    await recorder.flush();
    expect(user.currentUser!.id, 'b');
    expect(user.currentUser!.statistics.tarotCardsOpened, 0);
    expect(await store.eventsFor('a'), hasLength(1));
    user.applyServerUserSnapshot(UserModel.empty().copyWith(id: 'a'));
    await recorder.flush();
    expect(user.currentUser!.statistics.tarotCardsOpened, 1);
    expect(await store.eventsFor('a'), isEmpty);
  });

  test('reopening same day counts once and next day adds progress', () async {
    await recorder.record(_event());
    await recorder.record(_event());
    await recorder.record(_event(reference: '2026-09-17'));
    await recorder.flush();
    expect(user.currentUser!.statistics.tarotCardsOpened, 2);
    expect(api.credited, hasLength(2));
  });
}

AchievementEvent _event({String reference = '2026-09-16'}) => AchievementEvent(
  userId: 'a',
  kind: AchievementEventKind.tarotDay,
  reference: reference,
);

class _Repository extends Fake implements UserRepository {}

class _Api extends Fake implements AchievementsApi {
  bool loseResponse = false;
  Completer<void>? pause;
  final started = Completer<void>();
  final credited = <String>{};

  @override
  Future<UserStatisticsModel> record(AchievementEvent event) async {
    if (!started.isCompleted) started.complete();
    if (pause != null) await pause!.future;
    credited.add(event.key);
    if (loseResponse) throw StateError('Connection lost after server commit');
    return UserStatisticsModel(tarotCardsOpened: credited.length);
  }
}
