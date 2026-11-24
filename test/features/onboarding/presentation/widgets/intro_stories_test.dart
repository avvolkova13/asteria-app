import 'package:flutter/services.dart';
import 'package:asteria_app/features/onboarding/presentation/widgets/intro/intro_next_button.dart';
import 'package:asteria_app/core/localization/localization.dart';
import 'package:asteria_app/core/ui_kit/ui_kit.dart';
import 'package:asteria_app/features/onboarding/presentation/widgets/intro/intro_stories.dart';
import 'package:asteria_app/features/onboarding/presentation/widgets/intro/intro_story.dart';
import 'package:asteria_app/features/onboarding/presentation/widgets/intro/intro_natal_story.dart';
import 'package:asteria_app/features/onboarding/presentation/widgets/intro/native_intro_audio.dart';
import 'package:asteria_app/features/onboarding/presentation/widgets/intro/intro_mood_artwork.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';

Future<void> host(
  WidgetTester tester,
  Widget child, {
  bool reduced = false,
  bool accessible = false,
  double textScale = 1,
}) async {
  tester.view.physicalSize = const Size(390, 844);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
  await tester.pumpWidget(
    MaterialApp(
      locale: const Locale('ru'),
      localizationsDelegates: const [
        AppLocalizations.delegate,
        ...GlobalMaterialLocalizations.delegates,
      ],
      supportedLocales: AppLocaleService.supportedLocales,
      home: Builder(
        builder: (context) => Theme(
          data: AppThemeDark.instance.getThemeData(context),
          child: MediaQuery(
            data: MediaQuery.of(context).copyWith(
              disableAnimations: reduced,
              accessibleNavigation: accessible,
              textScaler: TextScaler.linear(textScale),
            ),
            child: Scaffold(
              body: SingleChildScrollView(
                child: Padding(padding: const EdgeInsets.all(16), child: child),
              ),
            ),
          ),
        ),
      ),
    ),
  );
  await tester.pump();
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUp(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
          const MethodChannel('asteria/practice-audio'),
          (call) async => call.method == 'close'
              ? null
              : {
                  'duration': 75000,
                  'position': 75000,
                  'playing': false,
                  'loop': false,
                  'complete': true,
                },
        );
  });
  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
          const MethodChannel('asteria/practice-audio'),
          null,
        );
  });

  for (final reduced in [false, true]) {
    testWidgets('mood story stays silent including exit (reduced=$reduced)', (
      tester,
    ) async {
      final calls = <String>[];
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(
            const MethodChannel('asteria/practice-audio'),
            (call) async {
              calls.add(call.method);
              return {
                'duration': 75000,
                'position': 0,
                'playing': false,
                'loop': false,
                'complete': false,
              };
            },
          );
      await host(tester, const IntroMoodStory(active: true), reduced: reduced);
      await tester.pump(const Duration(seconds: 4));
      await tester.pump(const Duration(seconds: 3));
      await tester.pump();
      final containsPlayer = find
          .byType(NativeIntroAudio)
          .evaluate()
          .isNotEmpty;
      await tester.pumpWidget(const SizedBox());
      await tester.pump();
      expect(
        calls,
        isEmpty,
        reason: 'Onboarding must never open an audio session',
      );
      expect(containsPlayer, isFalse, reason: 'No player or playback controls');
    });
  }

  testWidgets(
    'expanded affirmation autoplays once, follows story pause and closes on exit',
    (tester) async {
      final calls = <String>[];
      var playing = false;
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(
            const MethodChannel('asteria/practice-audio'),
            (call) async {
              calls.add(call.method);
              if (call.method == 'close') {
                playing = false;
                return null;
              }
              if (call.method == 'toggle') playing = !playing;
              return {
                'duration': 75000,
                'position': 0,
                'playing': playing,
                'loop': false,
                'complete': false,
              };
            },
          );
      final story = IntroPlaybackController();
      story.update(IntroPlaybackMode.pause, () {});
      Widget scene(bool active) => IntroPlaybackScope(
        controller: story,
        child: SizedBox(
          height: 380,
          child: NativeIntroAudio(active: active, autoPlay: true),
        ),
      );
      await host(tester, scene(false));
      expect(calls, isEmpty);
      await host(tester, scene(true));
      await tester.pump();
      expect(calls.where((call) => call == 'toggle'), hasLength(1));
      expect(playing, isTrue);
      await tester.pump(const Duration(seconds: 1));
      expect(calls.where((call) => call == 'toggle'), hasLength(1));
      story.update(IntroPlaybackMode.resume, () {});
      await tester.pump();
      expect(playing, isFalse);
      story.update(IntroPlaybackMode.pause, () {});
      await tester.pump();
      expect(playing, isTrue);
      await host(tester, scene(false));
      await tester.pump();
      expect(playing, isFalse);
      expect(calls, contains('close'));
      await tester.pumpWidget(const SizedBox());
      story.dispose();
    },
  );
  test(
    'upcoming dates never go backwards at month, year or leap boundaries',
    () {
      for (final now in [
        DateTime(2026, 11, 16, 23, 59),
        DateTime(2026, 11, 30),
        DateTime(2026, 12, 31),
        DateTime(2028, 2, 28),
      ]) {
        final dates = introUpcomingDates(now);
        expect(dates.first, DateTime(now.year, now.month, now.day));
        expect(dates.toSet(), hasLength(5));
        for (var i = 0; i < 5; i++) {
          expect(dates[i], DateTime(now.year, now.month, now.day + i));
        }
      }
    },
  );

  testWidgets('mood options appear, selection resolves to a quiet reflection', (
    tester,
  ) async {
    final semantics = tester.ensureSemantics();
    await host(tester, const IntroMoodStory(active: true));
    await tester.pump(const Duration(seconds: 4));
    expect(find.text('Всё время спешу'), findsOneWidget);
    expect(find.text('Нет сил'), findsOneWidget);
    await tester.pump(const Duration(seconds: 3));
    expect(find.text('Нет сил'), findsNothing);
    expect(find.text('Сейчас можно никуда не спешить.'), findsOneWidget);
    expect(find.bySemanticsLabel('Слушать «У меня есть время»'), findsNothing);
    semantics.dispose();
    await tester.pumpWidget(const SizedBox());
  });

  testWidgets(
    'mood motion follows the internal clock without visible playback links',
    (tester) async {
      final playback = IntroPlaybackController();
      await host(
        tester,
        IntroPlaybackScope(
          controller: playback,
          child: const IntroMoodStory(active: true),
        ),
      );
      await tester.pump(const Duration(seconds: 3));
      final choices = ['Нет сил', 'Всё время спешу', 'Хочу спокойствия'];
      for (var i = 0; i < choices.length - 1; i++) {
        expect(
          tester
              .getRect(find.text(choices[i]))
              .overlaps(tester.getRect(find.text(choices[i + 1]))),
          isFalse,
        );
      }
      await tester.pump(const Duration(milliseconds: 2100));
      final flower = tester.getRect(find.byType(IntroMoodArtwork));
      playback.toggle!();
      await tester.pump();
      final paused = playback.progress.value;
      await tester.pump(const Duration(seconds: 2));
      expect(playback.progress.value, paused);
      expect(tester.getRect(find.byType(IntroMoodArtwork)), flower);
      playback.toggle!();
      await tester.pump();
      await tester.pump(const Duration(seconds: 7));
      expect(playback.progress.value, greaterThan(paused));
      expect(
        find.textContaining(RegExp(r'Пауза показа|Продолжить показ|Повторить')),
        findsNothing,
      );
      expect(
        find.bySemanticsLabel('Слушать «У меня есть время»'),
        findsNothing,
      );
      await tester.pumpWidget(const SizedBox());
      playback.dispose();
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('drop motion resumes after the full iOS background sequence', (
    tester,
  ) async {
    await host(
      tester,
      IntroNextButton(index: 0, label: 'Далее', onPressed: () {}),
    );
    await tester.pump(const Duration(milliseconds: 400));
    expect(tester.binding.transientCallbackCount, greaterThan(0));
    for (final state in [
      AppLifecycleState.inactive,
      AppLifecycleState.hidden,
      AppLifecycleState.paused,
    ]) {
      tester.binding.handleAppLifecycleStateChanged(state);
    }
    await tester.pump();
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
    await tester.pump();
    expect(tester.binding.transientCallbackCount, greaterThan(0));
    await tester.pumpAndSettle();
    expect(tester.binding.transientCallbackCount, 0);
    await tester.pumpWidget(const SizedBox());
  });

  testWidgets(
    'pair gives each person time to speak before the conversation starter',
    (tester) async {
      await host(tester, const IntroPairStory(active: true));
      final l = AppLocalizations.current;
      await tester.pump(const Duration(milliseconds: 4500));
      expect(find.text(l.introPairNeedTime), findsOneWidget);
      expect(find.text(l.introPairPrompt), findsNothing);
      await tester.pump(const Duration(seconds: 3));
      expect(find.text(l.introPairNeedTime), findsNothing);
      expect(find.text(l.introPairNeedTalk), findsOneWidget);
      await tester.pump(const Duration(seconds: 5));
      expect(find.text(l.introPairNeedTalk), findsNothing);
      expect(find.text(l.introPairPrompt), findsOneWidget);
      expect(find.byKey(const ValueKey('intro-pair-insight')), findsOneWidget);
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox());
    },
  );

  testWidgets('tarot shows the cards before the lasting advice', (
    tester,
  ) async {
    await host(tester, const IntroTarotStory(active: true));
    final l = AppLocalizations.current;
    await tester.pump(const Duration(milliseconds: 1500));
    expect(find.text(l.introAnakraMessage), findsNothing);
    await tester.pump(const Duration(seconds: 5));
    for (var i = 0; i < 3; i++) {
      expect(find.byKey(ValueKey('intro-card-$i-front')), findsOneWidget);
    }
    expect(find.text(l.introAnakraMessage), findsNothing);
    await tester.pump(const Duration(seconds: 6));
    expect(find.text(l.introAnakraMessage), findsOneWidget);
    expect(find.byKey(const ValueKey('intro-tarot-insight')), findsOneWidget);
    await tester.pump(const Duration(seconds: 3));
    expect(find.byKey(const ValueKey('intro-daily-rune')), findsOneWidget);
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox());
  });

  testWidgets(
    'approved reveals fade in place without moving or scaling content',
    (tester) async {
      var time = .24;
      late StateSetter update;
      await host(
        tester,
        StatefulBuilder(
          builder: (context, setState) {
            update = setState;
            return StoryReveal(
              time: time,
              start: 0,
              end: 2,
              child: const SizedBox(
                key: ValueKey('reveal-measure'),
                width: 240,
                height: 80,
                child: Text('Content stays in place'),
              ),
            );
          },
        ),
      );
      final finder = find.byKey(const ValueKey('reveal-measure'));
      final incoming = tester.getRect(finder);
      update(() => time = 1);
      await tester.pump();
      expect(tester.getRect(finder), incoming);
      update(() => time = 2.1);
      await tester.pump();
      expect(tester.getRect(finder), incoming);
      await tester.pumpWidget(const SizedBox());
    },
  );

  testWidgets(
    'configured clock supports internal interruption, background and reactivation without playback UI',
    (tester) async {
      var active = true;
      late StateSetter update;
      double time = 0;
      final playback = IntroPlaybackController();
      await host(
        tester,
        IntroPlaybackScope(
          controller: playback,
          child: StatefulBuilder(
            builder: (context, setState) {
              update = setState;
              return IntroStory(
                active: active,
                duration: const Duration(seconds: 4),
                builder: (context, seconds, static, now) {
                  time = seconds;
                  return const Text('story');
                },
              );
            },
          ),
        ),
      );
      await tester.pump(const Duration(seconds: 2));
      expect(time, closeTo(2, .01));
      playback.toggle!();
      await tester.pump();
      final paused = time;
      await tester.pump(const Duration(seconds: 3));
      expect(time, paused);
      playback.toggle!();
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));
      expect(time, greaterThan(paused));
      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.paused);
      final background = time;
      await tester.pump(const Duration(seconds: 2));
      expect(time, background);
      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));
      expect(time, greaterThan(background));
      update(() => active = false);
      await tester.pump();
      final inactive = time;
      await tester.pump(const Duration(seconds: 2));
      expect(time, inactive);
      update(() => active = true);
      await tester.pump();
      expect(time, 0);
      await tester.pump(const Duration(seconds: 5));
      expect(time, 4);
      expect(
        find.textContaining(RegExp(r'Пауза показа|Продолжить показ|Повторить')),
        findsNothing,
      );
      await tester.pumpWidget(const SizedBox());
      playback.dispose();
      expect(tester.takeException(), isNull);
    },
  );

  for (final mode in ['reduced', 'accessible', 'largeText']) {
    testWidgets('$mode retains the meaning without automatic transient cards', (
      tester,
    ) async {
      await host(
        tester,
        const IntroTarotStory(active: true),
        reduced: mode == 'reduced',
        accessible: mode == 'accessible',
        textScale: mode == 'largeText' ? 2 : 1,
      );
      expect(
        find.text(AppLocalizations.current.introTarotRequest),
        findsOneWidget,
      );
      expect(
        find.text(AppLocalizations.current.introTarotInsight),
        findsOneWidget,
      );
      expect(find.text('Пауза показа'), findsNothing);
      for (var card = 0; card < 3; card++) {
        expect(find.byKey(ValueKey('intro-card-$card-front')), findsOneWidget);
      }
      await tester.pumpWidget(const SizedBox());
      expect(tester.takeException(), isNull);
    });
  }

  testWidgets(
    'approved natal chart keeps its assembled size through observations',
    (tester) async {
      await host(tester, const IntroNatalStory(active: true));
      await tester.pump(const Duration(seconds: 2));
      expect(find.text(AppLocalizations.current.introNatalDate), findsNothing);
      final chart = find.byKey(const ValueKey('intro-natal-chart'));
      final initial = tester.getSize(chart);
      await tester.pump(const Duration(seconds: 4));
      expect(tester.getSize(chart), initial);
      await tester.pump(const Duration(seconds: 8));
      expect(tester.getSize(chart), initial);
      await tester.pumpWidget(const SizedBox());
    },
  );

  testWidgets('approved mood practice is below the complete flower artwork', (
    tester,
  ) async {
    await host(tester, const IntroMoodStory(active: true));
    await tester.pump(const Duration(seconds: 9));
    final practice = find.text(AppLocalizations.current.introMoodPractice);
    expect(practice, findsOneWidget);
    final flower = tester.getRect(find.byType(IntroMoodArtwork));
    final text = tester.getRect(practice);
    expect(flower.overlaps(text), isFalse);
    expect(text.top, greaterThanOrEqualTo(flower.bottom));
    await tester.pumpWidget(const SizedBox());
  });

  testWidgets('midnight refresh updates a finished calendar without reentry', (
    tester,
  ) async {
    var now = DateTime(2026, 12, 31, 23, 59, 59);
    await host(
      tester,
      IntroCalendarStory(active: true, now: () => now),
      reduced: true,
    );
    expect(find.textContaining('Напоминание — 1 января'), findsOneWidget);
    now = DateTime(2027, 1, 1);
    await tester.pump(const Duration(seconds: 2));
    expect(find.textContaining('Напоминание — 2 января'), findsOneWidget);
    await tester.pumpWidget(const SizedBox());
  });
}
