import 'package:asteria_app/core/ui_kit/widgets/lotus_icon_surface.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('the standalone surface preserves glyph and tap target bounds', (
    tester,
  ) async {
    const glyph = Key('glyph');
    const target = Key('target');
    int taps = 0;
    await tester.pumpWidget(
      MaterialApp(
        home: Center(
          child: SizedBox.square(
            dimension: 44,
            child: IconButton(
              key: target,
              onPressed: () => taps++,
              tooltip: 'Previous month',
              padding: EdgeInsets.zero,
              icon: const LotusIconSurface(
                diameter: 30,
                child: SizedBox(key: glyph, width: 10, height: 18),
              ),
            ),
          ),
        ),
      ),
    );
    final icon = find.byKey(glyph);
    final button = find.byKey(target);
    final disc = find.descendant(
      of: find.byType(LotusIconSurface),
      matching: find.byType(CustomPaint),
    );
    expect(tester.getSize(icon), const Size(10, 18));
    expect(tester.getSize(disc), const Size.square(30));
    expect(tester.getCenter(disc), tester.getCenter(icon));
    expect(tester.getSize(button), const Size.square(44));
    expect(find.byTooltip('Previous month'), findsOneWidget);
    await tester.tapAt(tester.getTopLeft(button) + const Offset(3, 3));
    expect(taps, 1);
  });
}
