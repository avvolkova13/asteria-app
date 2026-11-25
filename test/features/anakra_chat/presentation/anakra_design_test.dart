import 'package:asteria_app/core/ui_kit/widgets/asteria_action_button.dart';
import 'package:asteria_app/core/ui_kit/widgets/card_lens_decoration.dart';
import 'package:asteria_app/app/data/models/anakra_chat/anakra_chat_message_model.dart';
import 'package:asteria_app/features/anakra_chat/presentation/widgets/anakra_chat_message.dart';
import 'package:asteria_app/features/anakra_chat/presentation/widgets/anakra_composer.dart';
import 'package:asteria_app/features/anakra_chat/presentation/widgets/anakra_glass_surface.dart';
import 'package:asteria_app/core/localization/generated/l10n.dart';
import 'package:asteria_app/features/anakra_chat/presentation/widgets/anakra_layout.dart';
import 'package:asteria_app/features/anakra_chat/presentation/widgets/anakra_quick_action_button.dart';
import 'package:asteria_app/features/home/presentation/models/year_animal_asset.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:asteria_app/core/ui_kit/theme/theme.dart';

Widget app(Widget child, {Locale? locale}) => MaterialApp(
  locale: locale,
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
  testWidgets('legacy system texts follow locale, chat text stays original', (
    tester,
  ) async {
    final ru = await AppLocalizations.load(const Locale('ru'));
    final russianWelcome = ru.anakraWelcomeMessage;
    final russianError = ru.anakraServerError;
    final en = await AppLocalizations.load(const Locale('en'));
    final englishWelcome = en.anakraWelcomeMessage;
    final englishError = en.anakraServerError;
    final time = DateTime(2026);
    final child = Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (final text in [russianWelcome, russianError])
          AnakraChatMessage(
            message: AnakraChatMessageModel(
              text: text,
              isUser: false,
              timestamp: time,
            ),
          ),
        AnakraChatMessage(
          message: AnakraChatMessageModel(
            text: russianError,
            isUser: true,
            timestamp: time,
          ),
        ),
      ],
    );
    await tester.pumpWidget(app(child, locale: const Locale('en')));
    await tester.pumpAndSettle();
    expect(find.text(englishWelcome), findsOneWidget);
    expect(find.text(englishError), findsOneWidget);
    expect(find.text(russianError), findsOneWidget);
    await tester.pumpWidget(app(child, locale: const Locale('ru')));
    await tester.pumpAndSettle();
    expect(find.text(russianWelcome), findsOneWidget);
    expect(find.text(russianError), findsNWidgets(2));
    expect(find.text(englishError), findsNothing);
  });

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
    final clear = find.byTooltip(AppLocalizations.current.clearMessage);
    expect(tester.getSize(find.byType(TextField)).height, 48);
    await tester.tap(find.byType(IconButton).last);
    expect(sends, 1);
    await tester.tap(clear);
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
  testWidgets('chat shows the same year animal as the tab bar', (tester) async {
    await tester.pumpWidget(app(const AnakraAvatar()));
    final image = tester.widget<Image>(find.byType(Image));
    expect(
      (image.image as AssetImage).assetName,
      YearAnimalAsset.forYear(DateTime.now().year),
    );
    expect(tester.getSize(find.byType(AnakraAvatar)), const Size(156, 156));
  });

  testWidgets(
    'quick action uses canonical purple CTA and resolved Onest text',
    (tester) async {
      var taps = 0;
      await tester.pumpWidget(
        app(
          AnakraQuickActionButton(text: 'Test action', onPressed: () => taps++),
        ),
      );
      final text = tester.widget<RichText>(
        find.descendant(
          of: find.text('Test action'),
          matching: find.byType(RichText),
        ),
      );
      expect(text.text.style?.fontFamily, 'Onest');
      expect(text.text.style?.fontSize, 16);
      expect(
        find.descendant(
          of: find.byType(AnakraQuickActionButton),
          matching: find.byType(AsteriaActionButton),
        ),
        findsOneWidget,
      );
      final surface = tester.widget<DecoratedBox>(
        find
            .descendant(
              of: find.byType(AsteriaActionButton),
              matching: find.byWidgetPredicate(
                (widget) =>
                    widget is DecoratedBox &&
                    widget.decoration is CardLensDecoration,
              ),
            )
            .first,
      );
      expect(
        (surface.decoration as CardLensDecoration).gradient,
        AsteriaActionButton.purpleGradient,
      );
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
    },
  );

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
