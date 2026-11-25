import 'package:asteria_app/features/sonnik/data/dream_journal.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'dream_journal_flow_test.dart' show DreamTestUser, mountDreams;

void main() {
  setUpAll(() => Hive.openBox<Map>('dream_journal_v1', bytes: Uint8List(0)));
  setUp(() => Hive.box<Map>('dream_journal_v1').clear());
  tearDownAll(Hive.close);
  for (final width in [800.0, 320.0]) {
    testWidgets(
      'Quick capture and toolbar Back protect a dream draft, width=$width',
      (tester) async {
        final user = DreamTestUser();
        addTearDown(user.dispose);
        await mountDreams(tester, user, ru: false, width: width);
        await tester.tap(find.text('Write a dream'));
        await tester.pumpAndSettle();
        await tester.enterText(
          find.byType(TextField),
          'Do not lose this dream',
        );
        await tester.pumpAndSettle();
        await tester.tap(find.byTooltip('Back'));
        await tester.pumpAndSettle();
        expect(find.text('Save your changes?'), findsOneWidget);
        await tester.tap(find.text('Keep editing'));
        await tester.pumpAndSettle();
        expect(
          tester.widget<TextField>(find.byType(TextField)).controller!.text,
          'Do not lose this dream',
        );
        await tester.tap(find.byTooltip('Back'));
        await tester.pumpAndSettle();
        await tester.tap(find.text('Discard changes'));
        await tester.pumpAndSettle();
        expect(find.text('Write a dream'), findsOneWidget);
        expect(await DreamJournal(user.id).read(), isEmpty);
        await tester.tap(find.text('Write a dream'));
        await tester.pumpAndSettle();
        await tester.enterText(find.byType(TextField), 'Save before leaving');
        await tester.pumpAndSettle();
        await tester.tap(find.byTooltip('Back'));
        await tester.pumpAndSettle();
        await tester.tap(
          find.descendant(
            of: find.byType(CupertinoAlertDialog),
            matching: find.text('Save and exit'),
          ),
        );
        await tester.pumpAndSettle();
        expect(find.text('Write a dream'), findsOneWidget);
        expect(
          (await DreamJournal(user.id).read()).single.text,
          'Save before leaving',
        );
        expect(find.text('Save before leaving'), findsOneWidget);
      },
    );
  }
}
