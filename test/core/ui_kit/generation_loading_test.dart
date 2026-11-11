import 'package:asteria_app/core/localization/localization.dart';
import 'package:asteria_app/core/services/global_loader_service.dart';
import 'package:asteria_app/core/ui_kit/theme/theme.dart';
import 'package:asteria_app/core/ui_kit/widgets/generation_loading_view.dart';
import 'package:asteria_app/core/ui_kit/widgets/global_loader_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUpAll(() async {
    for (final family in ['Lora', 'Onest']) {
      await (FontLoader(family)..addFont(
            rootBundle.load(
              'assets/fonts/${family.toLowerCase()}/$family-VariableFont_wght.ttf',
            ),
          ))
          .load();
    }
  });

  for (final type in [
    GlobalLoaderType.sonnik,
    GlobalLoaderType.compatibility,
    GlobalLoaderType.natalCard,
    GlobalLoaderType.insight,
  ]) {
    testWidgets(
      '$type uses sphere, reserves phrase space and dismisses immediately',
      (tester) async {
        tester.view.physicalSize = const Size(320, 568);
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);
        final service = GlobalLoaderService()..showWithSpheres(type);
        addTearDown(service.dispose);
        final semantics = tester.ensureSemantics();
        await tester.pumpWidget(
          _app(
            GlobalLoaderWidget(
              loaderService: service,
              child: const Scaffold(body: Text('Underlying content')),
            ),
            scale: 1.6,
          ),
        );
        await tester.pump(const Duration(milliseconds: 100));
        final context = tester.element(find.byType(GenerationLoadingView));
        final phrases = generationLoadingPhrases(context, type);
        expect(find.text(phrases.first), findsOneWidget);
        final size = tester.getSize(find.byType(GenerationLoadingContent));
        final sphere = find.image(
          const AssetImage('assets/images/loading/figma_sphere.png'),
        );
        expect(sphere, findsOneWidget);
        final rotate = find
            .ancestor(of: sphere, matching: find.byType(Transform))
            .first;
        final firstMatrix = tester
            .widget<Transform>(rotate)
            .transform
            .storage
            .toList();
        await tester.pump(const Duration(milliseconds: 700));
        expect(
          tester.widget<Transform>(rotate).transform.storage.toList(),
          isNot(firstMatrix),
        );
        await tester.pump(const Duration(seconds: 3));
        await tester.pump(const Duration(milliseconds: 600));
        expect(find.text(phrases[1]), findsOneWidget);
        expect(find.text(phrases.first), findsNothing);
        expect(tester.getSize(find.byType(GenerationLoadingContent)), size);
        expect(tester.takeException(), isNull);
        service.hide();
        await tester.pump();
        expect(find.byType(GenerationLoadingView), findsNothing);
        expect(find.text('Underlying content'), findsOneWidget);
        await tester.pump(const Duration(seconds: 5));
        expect(tester.takeException(), isNull);
        semantics.dispose();
      },
    );
  }

  testWidgets('phrase handoff never paints two readable phrases together', (
    tester,
  ) async {
    await tester.pumpWidget(
      _app(const GenerationLoadingContent(phrases: ['First', 'Second'])),
    );
    await tester.pump(const Duration(seconds: 3));
    for (var frame = 0; frame < 6; frame++) {
      await tester.pump(const Duration(milliseconds: 80));
      final fades = tester.widgetList<FadeTransition>(
        find.descendant(
          of: find.byType(GenerationLoadingContent),
          matching: find.byType(FadeTransition),
        ),
      );
      expect(
        fades.where((fade) => fade.opacity.value > .01).length,
        lessThanOrEqualTo(1),
      );
    }
    await tester.pumpWidget(const SizedBox());
  });

  testWidgets('reduced motion and offstage stop rotation and phrase timer', (
    tester,
  ) async {
    Widget content({bool reduced = false, bool active = true}) => _app(
      TickerMode(
        enabled: active,
        child: const GenerationLoadingContent(phrases: ['First', 'Second']),
      ),
      reduced: reduced,
    );
    await tester.pumpWidget(content(reduced: true));
    await tester.pump(const Duration(seconds: 10));
    expect(find.text('First'), findsOneWidget);
    expect(find.text('Second'), findsNothing);
    expect(tester.binding.transientCallbackCount, 0);
    await tester.pumpWidget(content(active: false));
    await tester.pump(const Duration(seconds: 10));
    expect(find.text('First'), findsOneWidget);
    expect(tester.binding.transientCallbackCount, 0);
    await tester.pumpWidget(content());
    await tester.pump(const Duration(seconds: 3));
    await tester.pump(const Duration(milliseconds: 600));
    expect(find.text('Second'), findsOneWidget);
    await tester.pumpWidget(const SizedBox());
  });

  testWidgets('background stops updates; replacing or empty phrases is safe', (
    tester,
  ) async {
    await tester.pumpWidget(
      _app(const GenerationLoadingContent(phrases: ['First', 'Second'])),
    );
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.paused);
    await tester.pump(const Duration(seconds: 10));
    expect(find.text('First'), findsOneWidget);
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
    await tester.pump(const Duration(seconds: 3));
    await tester.pump(const Duration(milliseconds: 600));
    expect(find.text('Second'), findsOneWidget);
    await tester.pumpWidget(_app(const GenerationLoadingContent(phrases: [])));
    await tester.pump(const Duration(milliseconds: 600));
    expect(find.text('Загрузка…'), findsOneWidget);
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox());
  });

  testWidgets('generic operations stay neutral and block input under overlay', (
    tester,
  ) async {
    final service = GlobalLoaderService();
    final focus = FocusNode();
    addTearDown(service.dispose);
    addTearDown(focus.dispose);
    await tester.pumpWidget(
      _app(
        GlobalLoaderWidget(
          loaderService: service,
          child: Scaffold(body: TextField(focusNode: focus)),
        ),
      ),
    );
    focus.requestFocus();
    await tester.pump();
    expect(focus.hasFocus, isTrue);
    service.show();
    await tester.pump();
    expect(find.byType(GenerationLoadingView), findsNothing);
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    expect(focus.hasFocus, isFalse);
    service.hide();
    await tester.pumpWidget(const SizedBox());
  });
}

Widget _app(Widget child, {bool reduced = false, double scale = 1}) =>
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
              textScaler: TextScaler.linear(scale),
            ),
            child: child,
          ),
        ),
      ),
    );
