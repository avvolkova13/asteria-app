import 'package:asteria_app/app/data/models/anakra_chat/anakra_chat_message_model.dart';
import 'package:asteria_app/features/anakra_chat/presentation/widgets/anakra_chat_message.dart';
import 'package:asteria_app/features/anakra_chat/presentation/widgets/anakra_composer.dart';
import 'package:asteria_app/features/anakra_chat/presentation/widgets/anakra_glass_surface.dart';
import 'package:asteria_app/core/localization/generated/l10n.dart';
import 'package:asteria_app/features/anakra_chat/presentation/widgets/anakra_layout.dart';
import 'package:asteria_app/features/anakra_chat/presentation/widgets/anakra_quick_action_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:asteria_app/core/ui_kit/theme/theme.dart';

Widget app(Widget child) => MaterialApp(
  localizationsDelegates: const [
    AppLocalizations.delegate,
    ...GlobalMaterialLocalizations.delegates,
  ],
  supportedLocales: AppLocalizations.delegate.supportedLocales,
  home: Builder(
    builder: (context) => Theme(
      data: AppThemeDark.instance.getThemeData(context),
      child: Scaffold(body: Center(child: child)),
    ),
  ),
);

void main() {
  test('bubble tails keep their side as messages grow', () {
    for (final height in [52.0, 240.0]) {
      final size = Size(280, height);
      final outgoing = anakraBubblePath(size, AnakraBubbleSide.outgoing, 16);
      final incoming = anakraBubblePath(size, AnakraBubbleSide.incoming, 16);
      expect(outgoing.getBounds(), Offset.zero & size);
      expect(incoming.getBounds(), Offset.zero & size);
      expect(outgoing.contains(Offset(278, height - 0.5)), isTrue);
      expect(incoming.contains(Offset(2, height - 0.5)), isTrue);
      expect(outgoing.contains(const Offset(278, 20)), isFalse);
      expect(incoming.contains(const Offset(2, 20)), isFalse);
    }
  });

  testWidgets('composer keeps its size and disables sending while busy', (
    tester,
  ) async {
    final controller = TextEditingController(text: 'Hello');
    addTearDown(controller.dispose);
    var sends = 0;
    Widget composer(bool busy) => app(
      Padding(
        padding: const EdgeInsets.all(16),
        child: AnakraComposer(
          controller: controller,
          busy: busy,
          hasInput: true,
          onSend: () => sends++,
        ),
      ),
    );
    await tester.pumpWidget(composer(false));
    await tester.pumpAndSettle();
    final send = find.widgetWithIcon(IconButton, Icons.cancel);
    expect(tester.getSize(find.byType(TextField)).height, 48);
    await tester.tap(find.byType(IconButton).last);
    expect(sends, 1);
    await tester.tap(send);
    expect(controller.text, isEmpty);
    await tester.pumpWidget(composer(true));
    expect(tester.widget<TextField>(find.byType(TextField)).enabled, isFalse);
    expect(
      tester.widget<IconButton>(find.byType(IconButton).last).onPressed,
      isNull,
    );
    expect(tester.getSize(find.byType(TextField)).height, 48);
    expect(tester.takeException(), isNull);
  });
  testWidgets('avatar uses the complete Figma composition', (tester) async {
    await tester.pumpWidget(app(const AnakraAvatar()));
    final image = tester.widget<Image>(find.byType(Image));
    expect(
      (image.image as AssetImage).assetName,
      'assets/images/anakra/avatar.png',
    );
    expect(tester.getSize(find.byType(AnakraAvatar)), const Size(156, 156));
  });

  testWidgets('quick action has Onest text and no filled background', (
    tester,
  ) async {
    var taps = 0;
    await tester.pumpWidget(
      app(
        AnakraQuickActionButton(text: 'Test action', onPressed: () => taps++),
      ),
    );
    final text = tester.widget<Text>(find.text('Test action'));
    expect(text.style?.fontFamily, 'Onest');
    expect(text.style?.fontSize, 16);
    expect(
      tester
          .widget<Material>(
            find.descendant(
              of: find.byType(AnakraQuickActionButton),
              matching: find.byType(Material),
            ),
          )
          .color,
      Colors.transparent,
    );
    await tester.tap(find.text('Test action'));
    expect(taps, 1);
  });

  for (final width in [320.0, 390.0, 430.0]) {
    testWidgets('user message uses Onest and wraps at $width', (tester) async {
      tester.view.physicalSize = Size(width, 844);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      final message = AnakraChatMessageModel(
        text: List.filled(20, 'Long message').join(' '),
        isUser: true,
        timestamp: DateTime(2026),
      );
      await tester.pumpWidget(app(AnakraChatMessage(message: message)));
      expect(
        tester.widget<Text>(find.text(message.text)).style?.fontFamily,
        'Onest',
      );
      expect(tester.takeException(), isNull);
    });
  }
}
