import 'package:asteria_app/app/data/models/user/user_model.dart';
import 'package:asteria_app/app/providers/user_provider.dart';
import 'package:asteria_app/core/localization/localization.dart';
import 'package:asteria_app/core/ui_kit/ui_kit.dart';
import 'package:asteria_app/features/practices/data/practice_notes_store.dart';
import 'package:asteria_app/features/practices/presentation/practice_notes_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:provider/provider.dart';

class _NotesUser extends ChangeNotifier implements UserProvider {
  @override
  UserModel get currentUser => UserModel.empty().copyWith(id: 'editor-owner');
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  setUpAll(() => Hive.openBox<Map>('practice_notes_v1', bytes: Uint8List(0)));
  setUp(() => Hive.box<Map>('practice_notes_v1').clear());
  tearDownAll(Hive.close);

  for (final ru in [true, false]) {
    testWidgets(
      'saved text remains readable and Add starts a focused draft, ru=$ru',
      (tester) async {
        tester.view.physicalSize = ru
            ? const Size(390, 844)
            : const Size(320, 740);
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.reset);
        final user = _NotesUser();
        addTearDown(user.dispose);
        await tester.pumpWidget(
          ChangeNotifierProvider<UserProvider>.value(
            value: user,
            child: MaterialApp(
              locale: Locale(ru ? 'ru' : 'en'),
              supportedLocales: AppLocaleService.supportedLocales,
              localizationsDelegates: const [
                AppLocalizations.delegate,
                ...GlobalMaterialLocalizations.delegates,
              ],
              builder: (context, child) => Theme(
                data: AppThemeDark.instance.getThemeData(context),
                child: MediaQuery(
                  data: MediaQuery.of(context).copyWith(
                    disableAnimations: true,
                    textScaler: TextScaler.linear(ru ? 1 : 1.5),
                  ),
                  child: child!,
                ),
              ),
              home: Scaffold(
                body: Builder(
                  builder: (context) => TextButton(
                    onPressed: () => openPracticeNotes(
                      context,
                      practiceId: 'morning',
                      practiceTitle: ru
                          ? 'Утро без спешки'
                          : 'An Unhurried Morning',
                    ),
                    child: const Text('Open notes'),
                  ),
                ),
              ),
            ),
          ),
        );
        await tester.tap(find.text('Open notes'));
        await tester.pumpAndSettle();
        final editor = find.byType(TextField);
        await tester.enterText(editor, 'A quiet morning');
        await tester.pumpAndSettle();
        await tester.ensureVisible(
          find.text(ru ? 'Сохранить заметку' : 'Save note'),
        );
        await tester.pumpAndSettle();
        await tester.tap(find.text(ru ? 'Сохранить заметку' : 'Save note'));
        await tester.pumpAndSettle();
        expect(
          tester.widget<TextField>(editor).controller!.text,
          'A quiet morning',
        );
        expect(find.text(ru ? 'Сохранено' : 'Saved'), findsOneWidget);
        expect(find.text(ru ? 'Удалить заметку' : 'Delete note'), findsNothing);
        final add = find.text(ru ? 'Добавить заметку' : 'Add note');
        await tester.ensureVisible(add);
        await tester.tap(add);
        await tester.pumpAndSettle();
        expect(tester.widget<TextField>(editor).controller!.text, isEmpty);
        expect(tester.widget<TextField>(editor).focusNode!.hasFocus, isTrue);
        tester.view.viewInsets = const FakeViewPadding(bottom: 300);
        await tester.pumpAndSettle();
        await tester.enterText(editor, 'A second thought');
        await tester.pumpAndSettle();
        await tester.ensureVisible(
          find.text(ru ? 'Сохранить заметку' : 'Save note'),
        );
        await tester.pumpAndSettle();
        await tester.tap(find.text(ru ? 'Сохранить заметку' : 'Save note'));
        await tester.pumpAndSettle();
        tester.view.resetViewInsets();
        await tester.pumpAndSettle();
        expect(
          await const PracticeNotesStore().read('editor-owner', 'morning'),
          hasLength(2),
        );
        await tester.enterText(editor, 'An unsaved revision');
        await tester.pumpAndSettle();
        await tester.ensureVisible(add);
        await tester.tap(add);
        await tester.pumpAndSettle();
        await tester.tap(find.text(ru ? 'Отмена' : 'Cancel'));
        await tester.pumpAndSettle();
        expect(
          tester.widget<TextField>(editor).controller!.text,
          'An unsaved revision',
        );
        final firstRow = find.widgetWithText(ListTile, 'A quiet morning');
        final menu = find.descendant(
          of: firstRow,
          matching: find.byType(PopupMenuButton<String>),
        );
        await tester.ensureVisible(menu);
        await tester.tap(menu);
        await tester.pumpAndSettle();
        await tester.tap(find.text(ru ? 'Удалить заметку' : 'Delete note'));
        await tester.pumpAndSettle();
        await tester.tap(find.text(ru ? 'Удалить' : 'Delete'));
        await tester.pumpAndSettle();
        expect(
          tester.widget<TextField>(editor).controller!.text,
          'An unsaved revision',
        );
        final remaining = await const PracticeNotesStore().read(
          'editor-owner',
          'morning',
        );
        expect(remaining.single.text, 'A second thought');
        expect(tester.takeException(), isNull);
      },
    );
  }
}
