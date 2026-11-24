import 'dart:io';
import 'package:asteria_app/features/affirmation/player/affirmation_player_screen.dart';
import 'dart:ui' as ui;
import 'package:asteria_app/features/onboarding/presentation/widgets/intro/intro_next_button.dart';
import 'package:asteria_app/features/onboarding/presentation/widgets/intro/intro_story.dart';
import 'package:asteria_app/app/data/repositories/app_settings/app_settings_repository.dart';
import 'package:asteria_app/core/analytics/analytics_events.dart';
import 'package:asteria_app/core/analytics/analytics_facade.dart';
import 'package:asteria_app/core/analytics/ast_events.dart';
import 'package:asteria_app/core/analytics/event_params.dart';
import 'package:asteria_app/core/analytics/product_analytics_service.dart';
import 'package:asteria_app/core/di/di.dart';
import 'package:asteria_app/core/localization/localization.dart';
import 'package:asteria_app/core/ui_kit/ui_kit.dart';
import 'package:asteria_app/features/onboarding/data/onboarding_data.dart';
import 'package:asteria_app/features/onboarding/localization/onboarding_localization_contract.dart';
import 'package:asteria_app/features/onboarding/presentation/bloc/onboarding_bloc.dart';
import 'package:asteria_app/features/onboarding/presentation/screens/onboarding_screen.dart';
import 'package:asteria_app/features/onboarding/presentation/widgets/onboarding_pagination_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';

const _storySequence = ['hero', 'natalTarot', 'dream', 'practice'];
int get _pageCount => _storySequence.length;
int get _lastPage => _pageCount - 1;
Iterable<int> get _indices => Iterable<int>.generate(_pageCount);

void main() {
  _OnboardingGoldenBinding();
  late _RecordingSettings settings;
  late _RecordingAnalyticsFacade analytics;
  late OnboardingBloc bloc;
  late int completions;
  late List<String> audioCalls;

  setUpAll(() async {
    for (final entry in {
      'Lora': 'assets/fonts/lora/Lora-VariableFont_wght.ttf',
      'Onest': 'assets/fonts/onest/Onest-VariableFont_wght.ttf',
      'MaterialIcons': 'fonts/MaterialIcons-Regular.otf',
      'CupertinoIcons': 'packages/cupertino_icons/assets/CupertinoIcons.ttf',
    }.entries) {
      final loader = FontLoader(entry.key)
        ..addFont(rootBundle.load(entry.value));
      await loader.load();
    }
  });

  setUp(() async {
    audioCalls = [];
    // Any audio platform call is recorded: this tour must remain silent.
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
          const MethodChannel('asteria/practice-audio'),
          (call) async {
            audioCalls.add(call.method);
            return call.method == 'close'
                ? null
                : {
                    'duration': 75000,
                    'position': 75000,
                    'playing': false,
                    'loop': false,
                    'complete': true,
                  };
          },
        );
    await di.reset();
    settings = _RecordingSettings();
    analytics = _RecordingAnalyticsFacade();
    di.registerSingleton<AnalyticsFacade>(analytics);
    di.registerSingleton<ProductAnalyticsService>(
      ProductAnalyticsService(analytics),
    );
    completions = 0;
  });

  tearDown(() async {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
          const MethodChannel('asteria/practice-audio'),
          null,
        );
    await bloc.close();
    await di.reset();
  });

  for (final language in ['ru', 'en']) {
    testWidgets(
      '$language only the simulated calendar plan is marked as a sample',
      (tester) async {
        bloc = OnboardingBloc(settings);
        await _pumpOnboarding(
          tester,
          bloc,
          locale: Locale(language),
          onComplete: () => completions++,
        );
        final unexpected = <String>[];
        for (var page = 0; page < _pageCount; page++) {
          for (final text in tester.widgetList<Text>(find.byType(Text))) {
            final value = text.data ?? text.textSpan?.toPlainText() ?? '';
            if (_unexpectedDemoLabel(value, calendar: page == 0)) {
              unexpected.add('scene${page + 1}: $value');
            }
          }
          if (page < _lastPage) {
            await tester.tap(_cta(tester));
            await tester.pumpAndSettle();
          }
        }
        expect(unexpected, isEmpty);
        expect(audioCalls, isEmpty);
      },
    );
  }

  testWidgets('approved automatic tour has no playback footer controls', (
    tester,
  ) async {
    bloc = OnboardingBloc(settings);
    await _pumpOnboarding(
      tester,
      bloc,
      locale: const Locale('ru'),
      disableAnimations: false,
      onComplete: () => completions++,
    );
    await tester.pump(const Duration(seconds: 1));
    expect(
      find.textContaining(
        RegExp(
          r'Пауза показа|Продолжить показ|Повторить|Pause story|Resume story|Replay',
        ),
      ),
      findsNothing,
    );
    final context = tester.element(find.byType(OnboardingScreen));
    final media = MediaQuery.of(context);
    expect(
      tester.getRect(find.byType(IntroNextButton)).bottom,
      greaterThanOrEqualTo(media.size.height - media.padding.bottom - 12),
    );
    await tester.pumpWidget(const SizedBox());
  });

  testWidgets('tour starts at the first of four short stories', (tester) async {
    bloc = OnboardingBloc(settings);
    await _pumpOnboarding(
      tester,
      bloc,
      locale: const Locale('ru'),
      onComplete: () => completions++,
    );
    expect(bloc.state.pages, hasLength(_pageCount));
    expect(
      bloc.state.pages.map((page) => page.visualKind.name),
      _storySequence,
    );
    expect(
      bloc.state.pages.map((page) => page.title).toSet(),
      hasLength(_pageCount),
    );
    final semantics = tester.ensureSemantics();
    await tester.pump();
    try {
      expect(
        find.bySemanticsLabel(
          AppLocalizations.of(
            tester.element(find.byType(OnboardingScreen)),
          ).introProgress(1, _pageCount),
        ),
        findsOneWidget,
      );
    } finally {
      semantics.dispose();
    }
    expect(bloc.state.pages.map((page) => page.pageIndex), _indices);
    final progress = tester.widget<OnboardingPaginationWidget>(
      find.byType(OnboardingPaginationWidget),
    );
    expect(progress.totalPages, _pageCount);
    expect(progress.currentPage, 0);
    expect(bloc.state.isLastPage, isFalse);
    expect(completions, 0);
    expect(tester.takeException(), isNull);
  });

  testWidgets(
    'all scenes advance automatically without feature taps or audio',
    (tester) async {
      bloc = OnboardingBloc(settings);
      await _pumpOnboarding(
        tester,
        bloc,
        disableAnimations: false,
        onComplete: () => completions++,
      );
      for (var page = 0; page < _pageCount; page++) {
        expect(bloc.state.currentPageIndex, page);
        final context = tester.element(find.byType(OnboardingScreen));
        expect(
          find.text(AppLocalizations.of(context).introStart),
          page == _lastPage ? findsOneWidget : findsNothing,
        );
        expect(settings.onboardingWrites, isEmpty);
        final duration = _activeStoryDuration(tester);
        expect(duration.inSeconds, [10, 14, 11, 11][page]);
        await _pumpStoryTo(tester, page, duration.inMilliseconds - 1500);
        expect(
          bloc.state.currentPageIndex,
          page,
          reason:
              'The scene must retain its result for its configured duration',
        );
        if (page == _lastPage) {
          expect(
            find.byKey(const ValueKey('intro-practice-result')),
            findsOneWidget,
          );
          expect(
            find.byType(AffirmationPlayerScreen, skipOffstage: false),
            findsNothing,
          );
        }
        await tester.pump(const Duration(seconds: 2));
        await tester.pump();
        for (var frame = 0; frame < 8; frame++) {
          await tester.pump(const Duration(milliseconds: 100));
        }
      }
      expect(bloc.state.currentPageIndex, _lastPage);
      expect(completions, 0);
      expect(audioCalls, isEmpty);
      expect(
        analytics
            .named(AnalyticsEvents.onboardingStepView)
            .map((event) => event.params[EventParams.stepIndex]),
        _indices,
      );
      await tester.tap(_cta(tester));
      await tester.pump();
      expect(completions, 1);
      expect(settings.onboardingWrites, [false]);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('swiping updates the real page, progress, and step analytics', (
    tester,
  ) async {
    bloc = OnboardingBloc(settings);
    await _pumpOnboarding(tester, bloc, onComplete: () => completions++);
    _expectPage(tester, bloc, 0);

    await tester.drag(find.byType(PageView), const Offset(-350, 0));
    await tester.pumpAndSettle();
    _expectPage(tester, bloc, 1);

    await tester.drag(find.byType(PageView), const Offset(350, 0));
    await tester.pumpAndSettle();
    _expectPage(tester, bloc, 0);

    expect(
      analytics
          .named(AnalyticsEvents.onboardingStepView)
          .map((event) => event.params[EventParams.stepIndex]),
      [0, 1, 0],
    );
    expect(analytics.named(AnalyticsEvents.onboardingStart), hasLength(1));
    expect(analytics.named(AstEvents.onboardingStart), hasLength(1));
    expect(analytics.named(AnalyticsEvents.onboardingCompleted), isEmpty);
    expect(analytics.named(AstEvents.onboardingComplete), isEmpty);
    expect(settings.onboardingWrites, isEmpty);
    expect(completions, 0);
    expect(tester.takeException(), isNull);
  });

  for (final language in ['en', 'ru']) {
    testWidgets('$language screen reader CTA advances the page', (
      tester,
    ) async {
      bloc = OnboardingBloc(settings);
      final semantics = tester.ensureSemantics();
      try {
        await _pumpOnboarding(
          tester,
          bloc,
          locale: Locale(language),
          onComplete: () => completions++,
        );
        final context = tester.element(find.byType(OnboardingScreen));
        final cta = find.semantics.byLabel(
          OnboardingLocalization().nextButton(context),
        );
        expect(cta, findsOne);
        expect(
          cta.evaluate().single.getSemanticsData().hasAction(
            SemanticsAction.tap,
          ),
          isTrue,
        );
        tester.semantics.tap(cta);
        await tester.pumpAndSettle();
        _expectPage(tester, bloc, 1);
        expect(completions, 0);
        expect(tester.takeException(), isNull);
      } finally {
        semantics.dispose();
      }
    });

    testWidgets(
      '$language compact large text keeps CTA fixed while scrolling',
      (tester) async {
        bloc = OnboardingBloc(settings);
        await _pumpOnboarding(
          tester,
          bloc,
          locale: Locale(language),
          size: const Size(320, 568),
          textScale: 2,
          padding: const EdgeInsets.only(top: 20),
          onComplete: () => completions++,
        );
        await tester.tap(_cta(tester));
        await tester.pumpAndSettle();
        _expectPage(tester, bloc, 1);

        final ctaButton = find.ancestor(
          of: _cta(tester),
          matching: find.byType(InkWell),
        );
        final beforeScroll = tester.getRect(ctaButton);
        expect(beforeScroll.left, greaterThanOrEqualTo(0));
        expect(beforeScroll.right, lessThanOrEqualTo(320));
        expect(beforeScroll.top, greaterThanOrEqualTo(0));
        expect(beforeScroll.bottom, lessThanOrEqualTo(568));
        expect(_cta(tester).hitTestable(), findsOneWidget);

        final content = find.byKey(const ValueKey('onboarding-content-1'));
        final visual = find.byKey(const ValueKey('onboarding-visual-1'));
        final scrollable = tester.state<ScrollableState>(
          find.descendant(of: content, matching: find.byType(Scrollable)),
        );
        for (
          var swipe = 0;
          swipe < 10 && scrollable.position.extentAfter > 0;
          swipe++
        ) {
          await tester.drag(content, const Offset(0, -300));
          await tester.pumpAndSettle();
        }
        expect(scrollable.position.pixels, greaterThan(0));
        expect(
          scrollable.position.pixels,
          closeTo(scrollable.position.maxScrollExtent, .1),
        );
        expect(
          tester.getRect(visual).bottom,
          lessThanOrEqualTo(tester.getRect(content).bottom + .1),
        );
        expect(tester.getRect(ctaButton), beforeScroll);
        expect(tester.getRect(content).bottom, lessThan(beforeScroll.top));

        await tester.tap(_cta(tester));
        await tester.pumpAndSettle();
        _expectPage(tester, bloc, 2);
        expect(completions, 0);
        expect(settings.onboardingWrites, isEmpty);
        expect(tester.takeException(), isNull);
      },
    );

    testWidgets('$language CTA advances all pages and completes once', (
      tester,
    ) async {
      bloc = OnboardingBloc(settings);
      await _pumpOnboarding(
        tester,
        bloc,
        locale: Locale(language),
        onComplete: () => completions++,
      );

      expect(bloc.state.pages, hasLength(_pageCount));
      for (var page = 0; page < _pageCount; page++) {
        _expectPage(tester, bloc, page);
        expect(settings.onboardingWrites, isEmpty);
        expect(completions, 0);
        await tester.tap(_cta(tester));
        await tester.pumpAndSettle();
      }

      expect(bloc.state.isCompleted, isTrue);
      expect(settings.getShowOnboarding(), isFalse);
      expect(settings.onboardingWrites, [false]);
      expect(completions, 1);
      expect(analytics.named(AnalyticsEvents.onboardingStart), hasLength(1));
      expect(analytics.named(AstEvents.onboardingStart), hasLength(1));
      expect(
        analytics.named(AnalyticsEvents.onboardingCompleted),
        hasLength(1),
      );
      final completion = analytics.named(AstEvents.onboardingComplete);
      expect(completion, hasLength(1));
      expect(completion.single.params[EventParams.stepsCount], _pageCount);
      expect(
        completion.single.params[EventParams.completionSeconds],
        isNonNegative,
      );
      expect(
        analytics
            .named(AnalyticsEvents.onboardingStepView)
            .map((event) => event.params[EventParams.stepIndex]),
        _indices,
      );
      expect(tester.takeException(), isNull);
    });

    for (var page = 0; page < _pageCount; page++) {
      testWidgets('$language full screen page ${page + 1} reference golden', (
        tester,
      ) async {
        bloc = OnboardingBloc(settings);
        await _pumpOnboarding(
          tester,
          bloc,
          locale: Locale(language),
          devicePixelRatio: 3,
          padding: const EdgeInsets.only(top: 59, bottom: 34),
          onComplete: () => completions++,
        );
        for (var index = 0; index < page; index++) {
          await tester.tap(_cta(tester));
          await tester.pumpAndSettle();
        }
        _expectPage(tester, bloc, page);
        expect(tester.takeException(), isNull);
        await _waitForGoldenImages(tester);
        final boundary = tester.renderObject<RenderRepaintBoundary>(
          find.byKey(const ValueKey('onboarding-screen-golden')),
        );
        final reference = await tester.runAsync(
          () => boundary.toImage(pixelRatio: 3),
        );
        expect(reference, isNotNull);
        try {
          await _saveReviewImage(
            tester,
            reference!,
            '${language}_${page + 1}_390_static',
          );
          await expectLater(
            reference,
            matchesGoldenFile(
              'goldens/onboarding_screen_${language}_${page + 1}.png',
            ),
          );
        } finally {
          reference?.dispose();
        }
      });
    }
  }

  for (final lightTheme in [false, true]) {
    for (final language in ['en', 'ru']) {
      testWidgets(
        'all scenes fit large text, theme=$lightTheme, language=$language',
        (tester) async {
          bloc = OnboardingBloc(settings);
          await _pumpOnboarding(
            tester,
            bloc,
            locale: Locale(language),
            size: const Size(320, 568),
            textScale: 2,
            lightTheme: lightTheme,
            onComplete: () => completions++,
          );
          for (var index = 0; index < _pageCount; index++) {
            final content = find.byKey(ValueKey('onboarding-content-$index'));
            await _saveReviewScreen(
              tester,
              '${language}_${index + 1}_320_text2_${lightTheme ? 'light' : 'dark'}_top',
            );
            await tester.drag(content, const Offset(0, -2200));
            await tester.pumpAndSettle();
            expect(_cta(tester).hitTestable(), findsOneWidget);
            await _saveReviewScreen(
              tester,
              '${language}_${index + 1}_320_text2_${lightTheme ? 'light' : 'dark'}_bottom',
            );
            expect(tester.takeException(), isNull);
            await tester.tap(_cta(tester));
            await tester.pumpAndSettle();
            expect(tester.takeException(), isNull);
          }
          expect(completions, 1);
        },
      );
    }
  }

  for (final scale in [1.0, 1.3]) {
    testWidgets('autoplay keeps navigation reachable at text scale $scale', (
      tester,
    ) async {
      bloc = OnboardingBloc(settings);
      await _pumpOnboarding(
        tester,
        bloc,
        locale: const Locale('ru'),
        disableAnimations: false,
        textScale: scale,
        padding: const EdgeInsets.only(top: 59, bottom: 34),
        onComplete: () => completions++,
      );
      for (var page = 0; page < _pageCount; page++) {
        _expectPage(tester, bloc, page);
        await _pumpStoryTo(
          tester,
          page,
          _activeStoryDuration(tester).inMilliseconds - 1500,
        );
        expect(_cta(tester).hitTestable(), findsOneWidget);
        expect(
          find.textContaining(
            RegExp(r'Пауза показа|Продолжить показ|Повторить'),
          ),
          findsNothing,
        );
        expect(tester.takeException(), isNull);
        await tester.tap(_cta(tester));
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 650));
        await tester.pump();
      }
      expect(completions, 1);
    });
  }

  testWidgets(
    'button morph follows an interrupted swipe and reverses without finishing',
    (tester) async {
      bloc = OnboardingBloc(settings);
      await _pumpOnboarding(
        tester,
        bloc,
        disableAnimations: false,
        onComplete: () => completions++,
      );
      for (var i = 0; i < _lastPage - 1; i++) {
        await tester.tap(_cta(tester));
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 650));
        await tester.pump();
      }
      final swipe = await tester.startGesture(
        tester.getCenter(find.byType(PageView)),
      );
      await swipe.moveBy(const Offset(-20, 0));
      await tester.pump();
      await swipe.moveBy(const Offset(-115, 0));
      await tester.pump(const Duration(milliseconds: 100));
      final button = tester.widget<IntroNextButton>(
        find.byType(IntroNextButton),
      );
      expect(button.page, greaterThan(_lastPage - 1));
      expect(button.page, lessThan(_lastPage));
      await swipe.moveBy(const Offset(135, 0));
      await swipe.up();
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 650));
      await tester.pump();
      expect(
        tester.widget<IntroNextButton>(find.byType(IntroNextButton)).page,
        _lastPage - 1,
      );
      expect(completions, 0);
      await tester.tap(_cta(tester));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 650));
      await tester.pump();
      expect(
        tester.widget<IntroNextButton>(find.byType(IntroNextButton)).page,
        _lastPage,
      );
      expect(completions, 0);
      expect(tester.takeException(), isNull);
    },
  );

  for (final language in ['ru', 'en']) {
    for (final width in [390.0, 320.0]) {
      testWidgets('$language autoplay results fit the visible scene at $width', (
        tester,
      ) async {
        bloc = OnboardingBloc(settings);
        await _pumpOnboarding(
          tester,
          bloc,
          locale: Locale(language),
          size: Size(width, width == 390 ? 844 : 568),
          padding: EdgeInsets.only(
            top: width == 390 ? 59 : 20,
            bottom: width == 390 ? 34 : 0,
          ),
          disableAnimations: false,
          onComplete: () => completions++,
        );
        final results = <Finder>[
          find.byKey(const ValueKey('intro-day-result')),
          find.byKey(const ValueKey('intro-natal-tarot-result')),
          find.byKey(const ValueKey('intro-dream-result')),
          find.byKey(const ValueKey('intro-practice-result')),
        ];
        final issues = <String>[];
        for (var page = 0; page < _pageCount; page++) {
          // On a short screen, an outcome may fit even if the animation that
          // explains it was offscreen. Check the action while it is happening.
          final moments = switch (page) {
            0 => [
              (3400, 'intro-calendar-save'),
              (5800, 'intro-calendar-remind'),
            ],
            1 => [for (var i = 0; i < 3; i++) (7000, 'intro-spread-turn-$i')],
            2 => [(4600, 'intro-dream-transcript')],
            _ => const <(int, String)>[],
          };
          final viewport = tester.getRect(
            find.byKey(ValueKey('onboarding-content-$page')),
          );
          for (final (time, key) in moments) {
            await _pumpStoryTo(tester, page, time);
            final rect = tester.getRect(find.byKey(ValueKey(key)));
            if (rect.top < viewport.top - .5 ||
                rect.bottom > viewport.bottom + .5) {
              issues.add('scene${page + 1}: $key $rect outside $viewport');
            }
          }
          await _pumpStoryTo(
            tester,
            page,
            _activeStoryDuration(tester).inMilliseconds - 1500,
          );
          final result = results[page];
          expect(result, findsOneWidget);
          final bounds = tester.getRect(result);
          if (bounds.top < viewport.top - .5 ||
              bounds.bottom > viewport.bottom + .5) {
            issues.add(
              'scene${page + 1}: result$bounds outside viewport$viewport',
            );
          }
          await tester.tap(_cta(tester));
          await tester.pump();
          await tester.pump(const Duration(milliseconds: 650));
          await tester.pump();
        }
        expect(
          issues,
          isEmpty,
          reason:
              'Autoplay must display the full result before leaving; scrolling must not be required',
        );
        expect(completions, 1);
        expect(tester.takeException(), isNull);
        await tester.pumpWidget(const SizedBox());
      });
    }
  }

  for (final width in [390.0, 320.0]) {
    testWidgets(
      'holding a scene pauses and releasing resumes automatic playback at $width',
      (tester) async {
        bloc = OnboardingBloc(settings);
        await _pumpOnboarding(
          tester,
          bloc,
          locale: const Locale('ru'),
          size: Size(width, width == 390 ? 844 : 568),
          padding: EdgeInsets.only(
            top: width == 390 ? 59 : 20,
            bottom: width == 390 ? 34 : 0,
          ),
          disableAnimations: false,
          onComplete: () => completions++,
        );
        await _pumpStoryTo(tester, 0, 1500);
        final content = find.byKey(const ValueKey('onboarding-content-0'));
        final gesture = await tester.startGesture(tester.getCenter(content));
        await gesture.moveBy(const Offset(0, -100));
        await tester.pump();
        await tester.pump();
        final progress = tester
            .widget<OnboardingPaginationWidget>(
              find.byType(OnboardingPaginationWidget),
            )
            .progress[0];
        final scroll = tester.state<ScrollableState>(
          find.descendant(of: content, matching: find.byType(Scrollable)),
        );
        final heldOffset = scroll.position.pixels;
        await tester.pump(const Duration(seconds: 20));
        _expectPage(tester, bloc, 0);
        expect(
          tester
              .widget<OnboardingPaginationWidget>(
                find.byType(OnboardingPaginationWidget),
              )
              .progress[0],
          progress,
        );
        expect(scroll.position.pixels, closeTo(heldOffset, .1));
        expect(
          find.textContaining(
            RegExp(r'Пауза показа|Продолжить показ|Повторить'),
          ),
          findsNothing,
        );
        await gesture.up();
        for (var frame = 0; frame < 20; frame++) {
          await tester.pump(const Duration(milliseconds: 100));
        }
        expect(
          tester
              .widget<OnboardingPaginationWidget>(
                find.byType(OnboardingPaginationWidget),
              )
              .progress[0],
          greaterThan(progress),
        );
        await _pumpStoryTo(
          tester,
          0,
          _activeStoryDuration(tester).inMilliseconds - 1500,
        );
        final result = find.byKey(const ValueKey('intro-day-result'));
        expect(result, findsOneWidget);
        expect(
          tester.getRect(result).bottom,
          lessThanOrEqualTo(tester.getRect(content).bottom + .5),
        );
        await tester.pump(const Duration(seconds: 2));
        await tester.pump();
        for (var frame = 0; frame < 8; frame++) {
          await tester.pump(const Duration(milliseconds: 100));
        }
        _expectPage(tester, bloc, 1);
        expect(completions, 0);
        expect(audioCalls, isEmpty);
        await tester.pumpWidget(const SizedBox());
      },
    );
  }

  testWidgets('returning to a scene replays from the top with fresh progress', (
    tester,
  ) async {
    bloc = OnboardingBloc(settings);
    await _pumpOnboarding(
      tester,
      bloc,
      size: const Size(320, 568),
      padding: const EdgeInsets.only(top: 20),
      disableAnimations: false,
      onComplete: () => completions++,
    );
    await _pumpStoryTo(
      tester,
      0,
      _activeStoryDuration(tester).inMilliseconds - 2000,
    );
    final firstContent = find.byKey(const ValueKey('onboarding-content-0'));
    final firstScroll = tester.state<ScrollableState>(
      find.descendant(of: firstContent, matching: find.byType(Scrollable)),
    );
    if (firstScroll.position.maxScrollExtent > 0) {
      await tester.drag(firstContent, const Offset(0, -200));
      await tester.pump();
      expect(firstScroll.position.pixels, greaterThan(0));
    }
    await tester.tap(_cta(tester));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 650));
    await tester.pump();
    _expectPage(tester, bloc, 1);
    final context = tester.element(find.byType(OnboardingScreen));
    await tester.tap(
      find.byTooltip(MaterialLocalizations.of(context).backButtonTooltip),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 650));
    await tester.pump();
    _expectPage(tester, bloc, 0);
    final returned = tester.state<ScrollableState>(
      find.descendant(of: firstContent, matching: find.byType(Scrollable)),
    );
    expect(returned.position.pixels, 0);
    expect(
      tester
          .widget<OnboardingPaginationWidget>(
            find.byType(OnboardingPaginationWidget),
          )
          .progress[0],
      lessThan(.1),
    );
    expect(completions, 0);
    await tester.pumpWidget(const SizedBox());
  });

  if (const bool.fromEnvironment('ONBOARDING_REVIEW_CAPTURE')) {
    for (final language in ['ru', 'en']) {
      for (final width in [390.0, 320.0]) {
        testWidgets('$language animated full tour review at $width', (
          tester,
        ) async {
          bloc = OnboardingBloc(settings);
          await _pumpOnboarding(
            tester,
            bloc,
            locale: Locale(language),
            size: Size(width, width == 390 ? 844 : 568),
            padding: EdgeInsets.only(
              top: width == 390 ? 59 : 20,
              bottom: width == 390 ? 34 : 0,
            ),
            disableAnimations: false,
            onComplete: () => completions++,
          );
          for (var page = 0; page < _pageCount; page++) {
            _expectPage(tester, bloc, page);
            const moments = [
              [
                (650, 'start'),
                (2800, 'date'),
                (5300, 'plan'),
                (8600, 'result'),
              ],
              [
                (650, 'start'),
                (2800, 'chart'),
                (7000, 'deal'),
                (12200, 'result'),
              ],
              [
                (650, 'start'),
                (1600, 'dictation'),
                (4600, 'saved'),
                (8750, 'result'),
              ],
              [
                (650, 'start'),
                (2700, 'body'),
                (4900, 'meditation'),
                (8750, 'result'),
              ],
            ];
            for (final phase in moments[page]) {
              await _pumpStoryTo(tester, page, phase.$1);
              await _saveReviewScreen(
                tester,
                '${language}_${page + 1}_${width.toInt()}_animated_${phase.$2}',
              );
              expect(tester.takeException(), isNull);
            }
            expect(completions, 0);
            await tester.tap(_cta(tester));
            await tester.pump();
            await tester.pump(const Duration(milliseconds: 650));
            await tester.pump();
          }
          expect(completions, 1);
          expect(audioCalls, isEmpty);
          await tester.pumpWidget(const SizedBox());
        });
      }
    }
  }

  testWidgets('automatic navigation waits while app is in background', (
    tester,
  ) async {
    bloc = OnboardingBloc(settings);
    await _pumpOnboarding(
      tester,
      bloc,
      disableAnimations: false,
      onComplete: () => completions++,
    );
    await tester.pump(const Duration(seconds: 2));
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.inactive);
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.paused);
    await tester.pump(const Duration(seconds: 20));
    _expectPage(tester, bloc, 0);
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
    await tester.pump();
    await _pumpStoryTo(
      tester,
      0,
      _activeStoryDuration(tester).inMilliseconds - 500,
    );
    await tester.pump(const Duration(seconds: 1));
    await tester.pump();
    for (var frame = 0; frame < 8; frame++) {
      await tester.pump(const Duration(milliseconds: 100));
    }
    await tester.pump();
    _expectPage(tester, bloc, 1);
    expect(completions, 0);
    await tester.pumpWidget(const SizedBox());
  });

  for (final mode in ['reduced', 'screenReader', 'largeText']) {
    testWidgets('$mode tour stays static and never opens audio', (
      tester,
    ) async {
      bloc = OnboardingBloc(settings);
      await _pumpOnboarding(
        tester,
        bloc,
        disableAnimations: mode == 'reduced',
        accessibleNavigation: mode == 'screenReader',
        textScale: mode == 'largeText' ? 2 : 1,
        onComplete: () => completions++,
      );
      await tester.pump(const Duration(minutes: 1));
      _expectPage(tester, bloc, 0);
      expect(_cta(tester).hitTestable(), findsOneWidget);
      expect(completions, 0);
      expect(audioCalls, isEmpty);
      await tester.pumpWidget(const SizedBox());
    });
  }

  for (var skippedPage = 0; skippedPage < _pageCount; skippedPage++) {
    testWidgets('skip from scene ${skippedPage + 1} completes once', (
      tester,
    ) async {
      bloc = OnboardingBloc(settings);
      await _pumpOnboarding(tester, bloc, onComplete: () => completions++);
      for (var page = 0; page < skippedPage; page++) {
        await tester.tap(_cta(tester));
        await tester.pumpAndSettle();
      }
      _expectPage(tester, bloc, skippedPage);
      final context = tester.element(find.byType(OnboardingScreen));
      final skip = find.text(AppLocalizations.of(context).introSkip);
      await tester.tap(skip);
      await tester.tap(skip);
      await tester.pumpAndSettle();
      expect(settings.onboardingWrites, [false]);
      expect(completions, 1);
      final completed = analytics.named(AstEvents.onboardingComplete);
      expect(completed, hasLength(1));
      expect(completed.single.params[EventParams.stepsCount], _pageCount);
      expect(audioCalls, isEmpty);
      expect(tester.takeException(), isNull);
    });
  }

  testWidgets('skip completes and a reopened tour completes again', (
    tester,
  ) async {
    bloc = OnboardingBloc(settings);
    for (var attempt = 0; attempt < 2; attempt++) {
      if (attempt > 0) {
        await tester.pumpWidget(const SizedBox());
      }
      await _pumpOnboarding(tester, bloc, onComplete: () => completions++);
      final context = tester.element(find.byType(OnboardingScreen));
      final skip = find.text(AppLocalizations.of(context).introSkip);
      await tester.tap(skip);
      await tester.tap(skip);
      await tester.pumpAndSettle();
      expect(audioCalls, isEmpty);
      expect(
        analytics.named(AstEvents.onboardingComplete),
        hasLength(attempt + 1),
      );
      expect(completions, attempt + 1);
      expect(tester.takeException(), isNull);
    }
    expect(settings.onboardingWrites, [false, false]);
  });

  testWidgets('rapid final taps complete and record analytics only once', (
    tester,
  ) async {
    bloc = OnboardingBloc(settings);
    await _pumpOnboarding(tester, bloc, onComplete: () => completions++);
    for (var page = 0; page < _lastPage; page++) {
      await tester.tap(_cta(tester));
      await tester.pumpAndSettle();
    }
    _expectPage(tester, bloc, _lastPage);

    // Keep the screen mounted, as navigation can finish after another tap.
    // No frame between taps: both target the same rendered CTA callback.
    final cta = _cta(tester);
    await tester.tap(cta);
    await tester.tap(cta);
    await tester.pumpAndSettle();

    expect(completions, 1);
    expect(settings.onboardingWrites, [false]);
    expect(bloc.state.isCompleted, isTrue);
    expect(analytics.named(AnalyticsEvents.onboardingCompleted), hasLength(1));
    expect(analytics.named(AstEvents.onboardingComplete), hasLength(1));
    expect(tester.takeException(), isNull);
  });
}

Duration _activeStoryDuration(WidgetTester tester) => tester
    .widgetList<IntroStory>(find.byType(IntroStory))
    .singleWhere((story) => story.active)
    .duration;

Future<void> _pumpStoryTo(
  WidgetTester tester,
  int page,
  int milliseconds,
) async {
  final progress = tester
      .widget<OnboardingPaginationWidget>(
        find.byType(OnboardingPaginationWidget),
      )
      .progress[page];
  final durationMs = _activeStoryDuration(tester).inMilliseconds;
  var remaining = (milliseconds - progress * durationMs).round().clamp(
    0,
    durationMs,
  );
  // Let semantic focus anchors appear on their real frames, including the
  // camera's scroll animation; a single clock jump skips these transitions.
  while (remaining > 0) {
    final frame = remaining.clamp(0, 100);
    await tester.pump(Duration(milliseconds: frame));
    remaining -= frame;
  }
  await tester.pump();
}

Future<void> _saveReviewImage(
  WidgetTester tester,
  ui.Image image,
  String name,
) async {
  await tester.runAsync(() async {
    final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
    final directory = Directory(
      '/private/tmp/asteria-design-review/onboarding-v2',
    );
    await directory.create(recursive: true);
    await File(
      '${directory.path}/$name.png',
    ).writeAsBytes(bytes!.buffer.asUint8List());
  });
}

bool _unexpectedDemoLabel(String value, {required bool calendar}) {
  if (calendar &&
      (value == 'Стрижка · пример плана' || value == 'Haircut · sample plan')) {
    return false;
  }
  return RegExp(
    r'пример|demo|example|sample',
    caseSensitive: false,
  ).hasMatch(value);
}

Future<void> _saveReviewScreen(WidgetTester tester, String name) async {
  for (final text in tester.widgetList<Text>(find.byType(Text))) {
    final value = text.data ?? text.textSpan?.toPlainText() ?? '';
    expect(
      _unexpectedDemoLabel(value, calendar: name.split('_')[1] == '1'),
      isFalse,
      reason: '$name: $value',
    );
  }
  await _waitForGoldenImages(tester);
  final boundary = tester.renderObject<RenderRepaintBoundary>(
    find.byKey(const ValueKey('onboarding-screen-golden')),
  );
  final image = await tester.runAsync(() => boundary.toImage(pixelRatio: 1));
  try {
    await _saveReviewImage(tester, image!, name);
  } finally {
    image?.dispose();
  }
}

// pumpAndSettle waits for scheduled frames, but a cold asset may still be
// decoding when no frame is scheduled.
Future<void> _waitForGoldenImages(WidgetTester tester) async {
  final context = tester.element(find.byType(OnboardingScreen));
  final images = <ImageProvider>{
    for (final image in tester.widgetList<Image>(find.byType(Image)))
      image.image,
    for (final box in tester.widgetList<DecoratedBox>(
      find.byType(DecoratedBox),
    ))
      if (box.decoration case BoxDecoration(image: final image?)) image.image,
  };
  await tester.runAsync(
    () =>
        Future.wait(images.map((provider) => precacheImage(provider, context))),
  );
  await tester.pump();
}

Future<void> _pumpOnboarding(
  WidgetTester tester,
  OnboardingBloc bloc, {
  Locale locale = const Locale('en'),
  Size size = const Size(390, 844),
  double textScale = 1,
  bool lightTheme = false,
  bool disableAnimations = true,
  bool accessibleNavigation = false,
  double devicePixelRatio = 1,
  EdgeInsets padding = EdgeInsets.zero,
  required VoidCallback onComplete,
}) async {
  tester.view.devicePixelRatio = devicePixelRatio;
  tester.view.physicalSize = size * devicePixelRatio;
  addTearDown(tester.view.resetDevicePixelRatio);
  addTearDown(tester.view.resetPhysicalSize);

  await tester.pumpWidget(
    BlocProvider<OnboardingBloc>.value(
      value: bloc,
      child: MaterialApp(
        locale: locale,
        localizationsDelegates: const [
          AppLocalizations.delegate,
          ...GlobalMaterialLocalizations.delegates,
        ],
        supportedLocales: AppLocaleService.supportedLocales,
        home: Builder(
          builder: (context) => Theme(
            data: lightTheme
                ? AppThemeLight.instance.getThemeData(context)
                : AppThemeDark.instance.getThemeData(context),
            child: MediaQuery(
              data: MediaQuery.of(context).copyWith(
                textScaler: TextScaler.linear(textScale),
                padding: padding,
                disableAnimations: disableAnimations,
                accessibleNavigation: accessibleNavigation,
              ),
              child: RepaintBoundary(
                key: const ValueKey('onboarding-screen-golden'),
                child: OnboardingScreen(
                  now: () => DateTime(2026, 11, 16, 12),
                  pages: OnboardingData.getPages(context),
                  localization: OnboardingLocalization(),
                  onComplete: onComplete,
                ),
              ),
            ),
          ),
        ),
      ),
    ),
  );
  await tester.pump();
  if (disableAnimations) {
    await tester.pumpAndSettle();
  } else {
    await tester.pump(const Duration(milliseconds: 100));
    await tester.pump();
  }
}

Finder _cta(WidgetTester tester) {
  final context = tester.element(find.byType(OnboardingScreen));
  final index = tester
      .widget<OnboardingPaginationWidget>(
        find.byType(OnboardingPaginationWidget),
      )
      .currentPage;
  return find.text(
    index == _lastPage
        ? AppLocalizations.of(context).introStart
        : OnboardingLocalization().nextButton(context),
  );
}

void _expectPage(WidgetTester tester, OnboardingBloc bloc, int index) {
  final pageView = tester.widget<PageView>(find.byType(PageView));
  final pagination = tester.widget<OnboardingPaginationWidget>(
    find.byType(OnboardingPaginationWidget),
  );
  expect(pageView.controller?.page, closeTo(index.toDouble(), 0.01));
  expect(bloc.state.currentPageIndex, index);
  expect(bloc.state.isLastPage, index == _lastPage);
  expect(pagination.currentPage, index);
  expect(pagination.totalPages, _pageCount);
}

class _RecordingSettings implements AppSettingsRepository {
  final List<bool> onboardingWrites = [];
  bool _showOnboarding = true;

  @override
  bool getShowOnboarding() => _showOnboarding;

  @override
  void setShowOnboarding(bool showOnboarding) {
    onboardingWrites.add(showOnboarding);
    _showOnboarding = showOnboarding;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _RecordedEvent {
  const _RecordedEvent(this.name, this.params);

  final String name;
  final Map<String, dynamic> params;
}

class _RecordingAnalyticsFacade implements AnalyticsFacade {
  final List<_RecordedEvent> events = [];

  List<_RecordedEvent> named(String name) =>
      events.where((event) => event.name == name).toList(growable: false);

  @override
  Future<void> trackEvent(String name, {Map<String, dynamic>? params}) async {
    events.add(_RecordedEvent(name, {...?params}));
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

// Goldens include the same soft shadows as the running app.
class _OnboardingGoldenBinding extends AutomatedTestWidgetsFlutterBinding {
  @override
  bool get disableShadows => false;
}
