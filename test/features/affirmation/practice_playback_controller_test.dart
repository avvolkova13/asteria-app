import 'package:asteria_app/features/affirmation/player/practice_playback_controller.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  const channel = MethodChannel('asteria/practice-audio');
  final messenger =
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;
  late PracticePlaybackController controller;
  late List<MethodCall> calls;
  late Map<String, Object> native;
  setUp(() {
    calls = [];
    native = {
      'duration': 75000,
      'position': 0,
      'playing': false,
      'loop': false,
      'complete': false,
    };
    messenger.setMockMethodCallHandler(channel, (call) async {
      calls.add(call);
      switch (call.method) {
        case 'toggle':
          native['playing'] = !(native['playing'] as bool);
        case 'seek':
          native['position'] = call.arguments['ms'] as int;
        case 'loop':
          native['loop'] = call.arguments['value'] as bool;
        case 'pause':
          native['playing'] = false;
        case 'close':
          return null;
      }
      return native;
    });
    controller = PracticePlaybackController();
  });
  tearDown(() {
    controller.dispose();
    messenger.setMockMethodCallHandler(channel, null);
  });

  testWidgets(
    'starts paused, seeks within recording, and mirrors native state',
    (tester) async {
      await controller.initialize();
      expect(controller.isPlaying, isFalse);
      await controller.toggle();
      await controller.seek(const Duration(seconds: 20));
      expect(controller.position, const Duration(seconds: 20));
      await controller.setLooping(true);
      expect(controller.isLooping, isTrue);
      await controller.seek(const Duration(minutes: 5));
      expect(controller.position, controller.duration);
      native.addAll({'position': 320, 'playing': true});
      await tester.pump(const Duration(milliseconds: 160));
      expect(controller.position, const Duration(milliseconds: 320));
      native.addAll({'position': 75000, 'playing': false, 'complete': true});
      await tester.pump(const Duration(milliseconds: 160));
      expect(controller.isComplete, isTrue);
      expect(controller.isPlaying, isFalse);
      expect(calls.where((call) => call.method == 'load'), hasLength(1));
    },
  );
  testWidgets('background pauses playback', (tester) async {
    await controller.toggle();
    controller.didChangeAppLifecycleState(AppLifecycleState.paused);
    await tester.pump();
    expect(controller.isPlaying, isFalse);
    expect(
      calls.map((call) => call.method),
      containsAllInOrder(['load', 'toggle', 'pause']),
    );
  });
  testWidgets('dismissing a player releases only its own session', (
    tester,
  ) async {
    final old = PracticePlaybackController();
    await old.initialize();
    final oldSession = calls.last.arguments['session'];
    await controller.initialize();
    expect(oldSession, isNot(calls.last.arguments['session']));
    old.dispose();
    await tester.pump();
    expect(calls.last.method, 'close');
    expect(calls.last.arguments['session'], oldSession);
  });
}
