import 'dart:io';

import 'package:asteria_app/core/localization/localization.dart';
import 'package:asteria_app/core/ui_kit/ui_kit.dart';
import 'package:asteria_app/features/affirmation/player/affirmation_player_screen.dart';
import 'package:asteria_app/features/affirmation/player/player_pebble.dart';
import 'package:asteria_app/features/affirmation/recorded_affirmations.dart';
import 'package:asteria_app/features/affirmation/selected_affirmation_player.dart';
import 'package:asteria_app/features/practices/practice_catalog_screen.dart';
import 'package:asteria_app/features/scenarios/practice_scenario.dart';
import 'package:hive/hive.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

const _door = '5UgabJFV5M2TiptnhZMm';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  late Directory playerData;
  setUpAll(() async {
    playerData = await Directory.systemTemp.createTemp('bilingual-player');
    Hive.init(playerData.path);
    await Hive.openBox<bool>('affirmation_player_favorites');
  });
  tearDownAll(() async {
    await Hive.close();
    await playerData.delete(recursive: true);
  });

  testWidgets('the simulator bundle contains the full bilingual catalog', (
    tester,
  ) async {
    final assets = await AssetManifest.loadFromAssetBundle(rootBundle);
    final paths = assets.listAssets().toSet();
    expect(
      englishAffirmationRecordings.keys,
      unorderedEquals(longAffirmationRecordings.keys),
    );
    final visibleEnglish = [
      for (final category in [
        'love',
        'abundance',
        'strength',
        'creativity',
        'lunar',
        'calm',
      ])
        ...mergeEnglishRecordedAffirmations(category, []),
    ];
    expect(visibleEnglish.map((card) => card.id).toSet(), hasLength(68));
    final visibleRussian = [
      for (final category in [
        'love',
        'abundance',
        'strength',
        'creativity',
        'lunar',
        'calm',
      ])
        ...mergeRecordedAffirmations(category, []),
    ];
    expect(
      visibleRussian.map((card) => card.id),
      unorderedEquals(visibleEnglish.map((card) => card.id)),
    );
    for (final entry in englishAffirmationRecordings.entries) {
      final ru = longAffirmationRecordings[entry.key]!;
      final en = entry.value;
      expect(en.notesId, ru.notesId);
      expect(en.duration, ru.duration);
      expect(
        en.transcript.map((line) => line.$1),
        orderedEquals(ru.transcript.map((line) => line.$1)),
      );
      expect(en.transcript.first.$2, isNot(ru.transcript.first.$2));
      expect(paths, containsAll([en.asset, ru.asset]));
    }
    for (final id in [
      'unhurried-morning',
      'workday-is-over',
      'time-for-sleep',
      'easy-breathing-rhythm',
      'gentle-exhale',
      'shake-off-the-day',
      'feel-the-difference',
      'cloud-hands',
      'sadhu-board',
    ]) {
      expect(
        paths,
        containsAll(['assets/audio/$id-en.mp3', 'assets/audio/$id-ru.m4a']),
      );
    }
  });

  for (final ru in [false, true]) {
    final locale = ru ? 'ru' : 'en';
    testWidgets('actual practice and affirmation audio plays in $locale', (
      tester,
    ) async {
      final door = lookupRecordedAffirmation(_door, ru: ru)!;
      await tester.pumpWidget(
        MaterialApp(
          locale: Locale(locale),
          supportedLocales: AppLocaleService.supportedLocales,
          localizationsDelegates: const [
            AppLocalizations.delegate,
            ...GlobalMaterialLocalizations.delegates,
          ],
          builder: (context, child) => Theme(
            data: AppThemeDark.instance.getThemeData(context),
            child: MediaQuery(
              data: MediaQuery.of(context).copyWith(disableAnimations: true),
              child: child!,
            ),
          ),
          home: Scaffold(
            body: Builder(
              builder: (context) => Column(
                children: [
                  TextButton(
                    onPressed: () => Navigator.of(context).push<void>(
                      MaterialPageRoute(
                        builder: (_) => SelectedAffirmationPlayer(
                          selection: AffirmationSelection(
                            affirmation: door.asCard(0).copyWith(id: _door),
                          ),
                        ),
                      ),
                    ),
                    child: const Text('Open affirmation'),
                  ),
                  TextButton(
                    onPressed: () => openPracticeCatalog(
                      context,
                      PracticeCategory.meditation,
                    ),
                    child: const Text('Open practices'),
                  ),
                  TextButton(
                    onPressed: () => openPracticeScenario(context),
                    child: const Text('Open scenario'),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
      await tester.tap(find.text('Open affirmation'));
      await tester.pumpAndSettle();
      var session = tester
          .widget<AffirmationPlayerScreen>(find.byType(AffirmationPlayerScreen))
          .session!;
      expect(
        session.audioAsset,
        ru
            ? 'assets/audio/affirmation-$_door.mp3'
            : 'assets/audio/affirmation-$_door-en.mp3',
      );
      expect(session.title, ru ? 'Открытая дверь' : 'An Open Door');
      expect(
        session.transcript.first.$2,
        startsWith(ru ? 'Кто-то' : 'Someone'),
      );
      final playerContext = tester.element(
        find.byType(AffirmationPlayerScreen),
      );
      final strings = AppLocalizations.of(playerContext);
      await tester.tap(_primaryAction(strings.playerPlay));
      await _expectNativePlayback(tester, strings.playerPause);
      Navigator.of(playerContext).pop();
      await tester.pumpAndSettle();

      await tester.tap(find.text('Open practices'));
      await tester.pumpAndSettle();
      await tester.tap(
        find
            .text(ru ? 'Утро без спешки' : 'An Unhurried Morning')
            .hitTestable()
            .last,
      );
      await tester.pumpAndSettle();
      final start = find.text(ru ? 'Начать практику' : 'Start practice');
      await tester.ensureVisible(start);
      await tester.tap(start);
      await tester.pump(const Duration(milliseconds: 450));
      session = tester
          .widget<AffirmationPlayerScreen>(find.byType(AffirmationPlayerScreen))
          .session!;
      expect(
        session.audioAsset,
        ru
            ? 'assets/audio/unhurried-morning-ru.m4a'
            : 'assets/audio/unhurried-morning-en.mp3',
      );
      expect(session.duration, const Duration(minutes: 5));
      expect(
        session.transcript.first.$2,
        startsWith(ru ? 'Утро начинается' : 'Before you look'),
      );
      await _expectNativePlayback(tester, strings.playerPause);
      Navigator.of(
        tester.element(find.byType(AffirmationPlayerScreen)),
      ).popUntil((route) => route.isFirst);
      await tester.pumpAndSettle();

      await tester.tap(find.text('Open scenario'));
      await tester.pumpAndSettle();
      await tester.tap(find.text(strings.scenarioPracticeSlowDown));
      await tester.pump(const Duration(milliseconds: 450));
      final scenario = tester.widget<AffirmationPlayerScreen>(
        find.byType(AffirmationPlayerScreen),
      );
      expect(scenario.autoPlay, isTrue);
      expect(
        scenario.session?.audioAsset,
        ru
            ? 'assets/audio/affirmation-time.mp3'
            : 'assets/audio/affirmation-time-en.mp3',
      );
      expect(
        scenario.session?.duration,
        const Duration(minutes: 3, seconds: 30),
      );
      expect(scenario.session?.title, ru ? 'У меня есть время' : 'I Have Time');
      await _expectNativePlayback(tester, strings.playerPause);
      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pump();
    });
  }
}

Future<void> _expectNativePlayback(WidgetTester tester, String pause) async {
  final slider = find.byType(Slider);
  for (var attempt = 0; attempt < 20; attempt++) {
    await tester.pump(const Duration(milliseconds: 250));
    if (slider.evaluate().isNotEmpty &&
        tester.widget<Slider>(slider.first).value > 0) {
      expect(_primaryAction(pause), findsOneWidget);
      return;
    }
  }
  fail('Native audio did not advance the player timeline.');
}

Finder _primaryAction(String label) => find.byWidgetPredicate(
  (widget) => widget is PlayerPebble && widget.primary && widget.label == label,
);
