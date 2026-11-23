import 'dart:async';

import 'package:asteria_app/core/ui_kit/widgets/dictation_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const channel = MethodChannel('asteria/dictation');
  const mobile = TargetPlatformVariant({
    TargetPlatform.iOS,
    TargetPlatform.android,
  });
  final messenger =
      TestWidgetsFlutterBinding.ensureInitialized().defaultBinaryMessenger;
  late TextEditingController controller;
  late List<bool> activeStates;

  setUp(() {
    controller = TextEditingController.fromValue(
      const TextEditingValue(
        text: 'Утром море',
        selection: TextSelection.collapsed(offset: 6),
      ),
    );
    activeStates = [];
  });

  tearDown(() {
    messenger.setMockMethodCallHandler(channel, null);
    controller.dispose();
  });

  Future<void> showDraft(WidgetTester tester) => tester.pumpWidget(
    MaterialApp(
      home: Scaffold(
        body: Column(
          children: [
            TextField(controller: controller),
            DictationButton(
              controller: controller,
              showLabel: true,
              onActiveChanged: activeStates.add,
            ),
          ],
        ),
      ),
    ),
  );

  testWidgets('inserts dictation at the caret and keeps the draft editable', (
    tester,
  ) async {
    final transcription = Completer<String>();
    final calls = <MethodCall>[];
    messenger.setMockMethodCallHandler(channel, (call) async {
      calls.add(call);
      if (call.method == 'start') return transcription.future;
      if (call.method == 'stop') transcription.complete('было');
      return null;
    });

    await showDraft(tester);
    await tester.tap(find.text('Dictate'));
    await tester.pump();
    expect(find.text('Stop dictation'), findsOneWidget);
    expect(controller.text, 'Утром море');

    await tester.tap(find.text('Stop dictation'));
    await tester.pumpAndSettle();
    expect(controller.text, 'Утром было море');
    expect(activeStates, [true, false]);
    expect(calls.map((call) => call.method), ['start', 'stop']);
    expect(calls.first.arguments['locale'], 'en-US');
    expect(calls.last.arguments['id'], calls.first.arguments['id']);

    await tester.enterText(find.byType(TextField), 'Утром я увидела море');
    expect(controller.text, 'Утром я увидела море');
  }, variant: mobile);

  testWidgets('keeps the draft when microphone permission is denied', (
    tester,
  ) async {
    messenger.setMockMethodCallHandler(channel, (_) async {
      throw PlatformException(code: 'permission_denied');
    });

    await showDraft(tester);
    await tester.tap(find.text('Dictate'));
    await tester.pumpAndSettle();

    expect(controller.text, 'Утром море');
    expect(activeStates, [true, false]);
    expect(
      find.text('Allow microphone and speech access in Settings.'),
      findsOneWidget,
    );
  }, variant: mobile);

  testWidgets('background cancels dictation and ignores a late result', (
    tester,
  ) async {
    final transcription = Completer<String>();
    final calls = <MethodCall>[];
    messenger.setMockMethodCallHandler(channel, (call) async {
      calls.add(call);
      if (call.method == 'start') return transcription.future;
      return null;
    });

    await showDraft(tester);
    await tester.tap(find.text('Dictate'));
    await tester.pump();
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.paused);
    await tester.pump();
    transcription.complete('text from interrupted dictation');
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.hidden);
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.inactive);
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
    await tester.pumpAndSettle();

    expect(controller.text, 'Утром море');
    expect(activeStates, [true, false]);
    expect(calls.map((call) => call.method), ['start', 'cancel']);
    expect(calls.last.arguments['id'], calls.first.arguments['id']);
    expect(find.text('Dictate'), findsOneWidget);
  }, variant: mobile);
}
