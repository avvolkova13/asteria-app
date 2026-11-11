import 'dart:async';
import 'dart:io';
import 'dart:ui' show SemanticsAction, Tristate;

import 'package:asteria_app/core/localization/generated/l10n.dart';
import 'package:asteria_app/features/affirmation/player/affirmation_player_screen.dart';
import 'package:asteria_app/features/affirmation/player/practice_playback_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';

class _Audio extends PracticePlaybackController {
  Duration elapsed = Duration.zero;
  bool active = false;
  bool loop = false;
  Completer<void>? loading;

  @override
  Duration get position => elapsed;
  @override
  bool get isPlaying => active;
  @override
  bool get isLooping => loop;
  @override
  Future<void> initialize() async {
    await loading?.future;
  }

  @override
  Future<void> toggle() async {
    active = !active;
    notifyListeners();
  }

  @override
  Future<void> setLooping(bool value) async {
    loop = value;
    notifyListeners();
  }

  @override
  Future<void> seek(Duration position) async {
    elapsed = position;
    notifyListeners();
  }
}

void main() {
  late Directory temp;
  setUpAll(() async {
    temp = await Directory.systemTemp.createTemp('asteria-player-ui-test-');
    Hive.init(temp.path);
    await Hive.openBox<bool>('affirmation_player_favorites');
  });
  tearDownAll(() async {
    await Hive.close();
    await temp.delete(recursive: true);
  });

  Future<_Audio> show(
    WidgetTester tester,
    Size size, {
    double textScale = 1,
    bool autoPlay = false,
    Completer<void>? loading,
  }) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = size;
    addTearDown(tester.view.reset);
    final audio = _Audio()..loading = loading;
    addTearDown(audio.dispose);
    await tester.pumpWidget(
      MaterialApp(
        locale: const Locale('ru'),
        supportedLocales: const [Locale('ru'), Locale('en')],
        localizationsDelegates: const [
          AppLocalizations.delegate,
          ...GlobalMaterialLocalizations.delegates,
        ],
        builder: (context, child) => MediaQuery(
          data: MediaQuery.of(context).copyWith(
            disableAnimations: true,
            textScaler: TextScaler.linear(textScale),
          ),
          child: child!,
        ),
        home: AffirmationPlayerScreen(controller: audio, autoPlay: autoPlay),
      ),
    );
    await tester.pumpAndSettle();
    return audio;
  }

  testWidgets('scenario autoplay starts when the recording is ready', (
    tester,
  ) async {
    final loading = Completer<void>();
    final audio = await show(
      tester,
      const Size(393, 852),
      autoPlay: true,
      loading: loading,
    );
    expect(audio.isPlaying, isFalse);
    loading.complete();
    await tester.pump();
    expect(audio.isPlaying, isTrue);
    await tester.pump();
    expect(find.bySemanticsLabel('Пауза'), findsOneWidget);
  });

  testWidgets('leaving during loading cannot start audio afterwards', (
    tester,
  ) async {
    final loading = Completer<void>();
    final audio = await show(
      tester,
      const Size(393, 852),
      autoPlay: true,
      loading: loading,
    );
    await tester.pumpWidget(const SizedBox.shrink());
    loading.complete();
    await tester.pump();
    expect(audio.isPlaying, isFalse);
    expect(tester.takeException(), isNull);
  });

  testWidgets(
    'scrubbing provides one selection on commit and stays silent during the drag',
    (tester) async {
      final audio = await show(tester, const Size(393, 852));
      final messenger =
          TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;
      final haptics = <Object?>[];
      messenger.setMockMethodCallHandler(SystemChannels.platform, (call) async {
        if (call.method == 'HapticFeedback.vibrate') {
          haptics.add(call.arguments);
        }
        return null;
      });
      addTearDown(
        () => messenger.setMockMethodCallHandler(SystemChannels.platform, null),
      );
      final track = tester.getRect(find.byType(Slider));
      final finger = await tester.startGesture(
        Offset(track.left + 2, track.center.dy),
      );
      await finger.moveTo(track.center);
      await tester.pump();
      await finger.moveBy(const Offset(8, 0));
      await tester.pump();
      expect(haptics, isEmpty);
      await finger.up();
      await tester.pump();
      expect(audio.elapsed.inSeconds, greaterThan(20));
      expect(haptics, ['HapticFeedbackType.selectionClick']);
      final slider = tester.getSemantics(
        find.bySemanticsLabel('Позиция воспроизведения'),
      );
      slider.owner!.performAction(slider.id, SemanticsAction.increase);
      await tester.pump();
      expect(haptics, hasLength(2));
    },
  );

  testWidgets(
    'Playback, scrubbing, repeat, link sharing and transcript are connected',
    (tester) async {
      final audio = await show(tester, const Size(393, 852));
      final play = find.bySemanticsLabel('Воспроизвести');
      expect(play.hitTestable(), findsOneWidget);
      for (final label in ['Воспроизвести', 'Повтор записи', 'В избранном']) {
        final node = tester.getSemantics(find.bySemanticsLabel(label));
        expect(node.flagsCollection.isEnabled, Tristate.isTrue);
        expect(node.getSemanticsData().hasAction(SemanticsAction.tap), isTrue);
      }
      final slider = tester.getSemantics(
        find.bySemanticsLabel('Позиция воспроизведения'),
      );
      expect(slider.flagsCollection.isSlider, isTrue);
      expect(
        slider.getSemanticsData().hasAction(SemanticsAction.increase),
        isTrue,
      );
      await tester.tap(play);
      await tester.pump();
      expect(find.bySemanticsLabel('Пауза'), findsOneWidget);
      await tester.tap(find.bySemanticsLabel('Пауза'));
      await tester.pump();
      await tester.tap(find.bySemanticsLabel('Повтор записи'));
      await tester.pump();
      expect(audio.isLooping, isTrue);
      final track = tester.getRect(find.byType(Slider));
      await tester.tapAt(Offset(track.center.dx, track.center.dy));
      await tester.pump();
      expect(audio.elapsed.inSeconds, inInclusiveRange(36, 39));
      expect(find.text('0:37'), findsOneWidget);
      final line = tester.widget<Text>(
        find.text('Мне не нужно решать всё сразу.'),
      );
      expect(line.style?.color, const Color(0xffffdfc6));
      const channel = MethodChannel('dev.fluttercommunity.plus/share');
      final messenger =
          TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;
      MethodCall? shared;
      messenger.setMockMethodCallHandler(channel, (call) async {
        shared = call;
        return '';
      });
      addTearDown(() => messenger.setMockMethodCallHandler(channel, null));
      await tester.tap(find.bySemanticsLabel('Поделиться аффирмацией'));
      await tester.pump();
      expect(shared?.method, 'share');
      expect(
        shared?.arguments['uri'],
        'https://asteria-calendar.com/practice/i-have-time/',
      );
      expect(shared?.arguments['paths'], isNull);
      await tester.tap(find.byTooltip('Показать весь текст'));
      await tester.pump();
      expect(
        find.text('И дальше пойду в своём темпе.').hitTestable(),
        findsOneWidget,
      );
      await tester.tap(find.byTooltip('Свернуть текст'));
      await tester.pump();
      expect(play.hitTestable(), findsOneWidget);
    },
  );

  testWidgets('Small screen with larger type can reach the full transcript', (
    tester,
  ) async {
    await show(tester, const Size(320, 568), textScale: 1.8);
    expect(tester.takeException(), isNull);
    await tester.dragUntilVisible(
      find.text('И дальше пойду в своём темпе.'),
      find.byType(SingleChildScrollView),
      const Offset(0, -260),
    );
    expect(
      find.text('И дальше пойду в своём темпе.').hitTestable(),
      findsOneWidget,
    );
    expect(tester.takeException(), isNull);
  });
}
