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

void main() {
  _OnboardingGoldenBinding();
  late _RecordingSettings settings;
  late _RecordingAnalyticsFacade analytics;
  late OnboardingBloc bloc;
  late int completions;

  setUpAll(() async {
    for (final entry in {
      'Lora': 'assets/fonts/lora/Lora-VariableFont_wght.ttf',
      'Onest': 'assets/fonts/onest/Onest-VariableFont_wght.ttf',
    }.entries) {
      final loader = FontLoader(entry.key)
        ..addFont(rootBundle.load(entry.value));
      await loader.load();
    }
  });

  setUp(() async {
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
    await bloc.close();
    await di.reset();
  });

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
        expect(
          tester.getRect(visual).bottom,
          greaterThan(tester.getRect(content).bottom),
        );
        await tester.drag(content, const Offset(0, -2000));
        await tester.pumpAndSettle();
        final scrollable = tester.state<ScrollableState>(
          find.descendant(of: content, matching: find.byType(Scrollable)),
        );
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

      expect(bloc.state.pages, hasLength(4));
      for (var page = 0; page < 4; page++) {
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
      expect(completion.single.params[EventParams.stepsCount], 4);
      expect(
        completion.single.params[EventParams.completionSeconds],
        isNonNegative,
      );
      expect(
        analytics
            .named(AnalyticsEvents.onboardingStepView)
            .map((event) => event.params[EventParams.stepIndex]),
        [0, 1, 2, 3],
      );
      expect(tester.takeException(), isNull);
    });

    for (var page = 0; page < 4; page++) {
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
        final boundary = tester.renderObject<RenderRepaintBoundary>(
          find.byKey(const ValueKey('onboarding-screen-golden')),
        );
        final reference = await tester.runAsync(
          () => boundary.toImage(pixelRatio: 3),
        );
        expect(reference, isNotNull);
        try {
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

  testWidgets('rapid final taps complete and record analytics only once', (
    tester,
  ) async {
    bloc = OnboardingBloc(settings);
    await _pumpOnboarding(tester, bloc, onComplete: () => completions++);
    for (var page = 0; page < 3; page++) {
      await tester.tap(_cta(tester));
      await tester.pumpAndSettle();
    }
    _expectPage(tester, bloc, 3);

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

Future<void> _pumpOnboarding(
  WidgetTester tester,
  OnboardingBloc bloc, {
  Locale locale = const Locale('en'),
  Size size = const Size(390, 844),
  double textScale = 1,
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
            data: AppThemeDark.instance.getThemeData(context),
            child: MediaQuery(
              data: MediaQuery.of(context).copyWith(
                textScaler: TextScaler.linear(textScale),
                padding: padding,
              ),
              child: RepaintBoundary(
                key: const ValueKey('onboarding-screen-golden'),
                child: OnboardingScreen(
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
  await tester.pumpAndSettle();
}

Finder _cta(WidgetTester tester) {
  final context = tester.element(find.byType(OnboardingScreen));
  return find.text(OnboardingLocalization().nextButton(context));
}

void _expectPage(WidgetTester tester, OnboardingBloc bloc, int index) {
  final pageView = tester.widget<PageView>(find.byType(PageView));
  final pagination = tester.widget<OnboardingPaginationWidget>(
    find.byType(OnboardingPaginationWidget),
  );
  expect(pageView.controller?.page, closeTo(index.toDouble(), 0.01));
  expect(bloc.state.currentPageIndex, index);
  expect(bloc.state.isLastPage, index == 3);
  expect(pagination.currentPage, index);
  expect(pagination.totalPages, 4);
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
