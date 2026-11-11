import 'package:asteria_app/core/ui_kit/app_colors/app_colors.dart';
import 'package:asteria_app/core/ui_kit/widgets/card_lens_decoration.dart';
import 'package:asteria_app/core/ui_kit/widgets/modal_glass_surface.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  for (final brightness in Brightness.values) {
    testWidgets('uses opaque $brightness glass when contrast is increased', (
      tester,
    ) async {
      final color = ColorScheme.fromSeed(
        seedColor: Colors.deepPurple,
        brightness: brightness,
      ).surface;
      await tester.pumpWidget(
        MediaQuery(
          data: const MediaQueryData(highContrast: true),
          child: ModalGlassSurface(
            color: color,
            child: const SizedBox.square(dimension: 88),
          ),
        ),
      );
      expect(find.byType(BackdropFilter), findsNothing);
      final surface = tester.widget<DecoratedBox>(find.byType(DecoratedBox));
      expect((surface.decoration as CardLensDecoration).color, color);
    });
  }

  for (final surface in [AppColorsDark.modal, AppColors.modal]) {
    testWidgets(
      'alert text follows the actual surface $surface in the light application theme',
      (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            theme: ThemeData.light(),
            home: Scaffold(
              body: ModalGlassAlert(
                color: surface,
                title: const Text('Title'),
                content: const Text('Message'),
                actions: const [],
              ),
            ),
          ),
        );
        final ink = surface == AppColorsDark.modal
            ? AppColors.textInverse
            : AppColors.textPrimary;
        for (final label in ['Title', 'Message']) {
          final rich = tester.widget<RichText>(
            find.descendant(
              of: find.text(label),
              matching: find.byType(RichText),
            ),
          );
          expect(rich.text.style!.color, ink);
        }
      },
    );
  }

  testWidgets(
    'a long high-scale confirmation remains scrollable and returns its choice',
    (tester) async {
      tester.view.devicePixelRatio = 1;
      tester.view.physicalSize = const Size(320, 568);
      addTearDown(tester.view.resetDevicePixelRatio);
      addTearDown(tester.view.resetPhysicalSize);
      bool? result;
      await tester.pumpWidget(
        MaterialApp(
          builder: (context, child) => MediaQuery(
            data: MediaQuery.of(
              context,
            ).copyWith(textScaler: TextScaler.linear(2)),
            child: child!,
          ),
          home: Scaffold(
            body: Builder(
              builder: (context) => TextButton(
                onPressed: () async {
                  result = await showDialog<bool>(
                    context: context,
                    builder: (context) => ModalGlassAlert(
                      title: const Text('Confirm'),
                      content: Text(
                        List.filled(16, 'A longer explanation.').join(' '),
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context, false),
                          child: const Text('Cancel'),
                        ),
                      ],
                    ),
                  );
                },
                child: const Text('Open'),
              ),
            ),
          ),
        ),
      );
      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();
      expect(find.byType(BackdropFilter), findsOneWidget);
      await tester.ensureVisible(find.text('Cancel'));
      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();
      expect(result, isFalse);
      expect(tester.takeException(), isNull);
    },
  );
}
