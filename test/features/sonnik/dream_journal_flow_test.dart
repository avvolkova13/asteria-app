import 'package:asteria_app/app/data/models/user/user_model.dart';
import 'package:asteria_app/app/providers/user_provider.dart';
import 'package:asteria_app/core/localization/localization.dart';
import 'package:asteria_app/core/ui_kit/ui_kit.dart';
import 'package:asteria_app/features/sonnik/data/dream_journal.dart';
import 'package:asteria_app/features/sonnik/presentation/screens/dream_journal_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:provider/provider.dart';

class _User extends ChangeNotifier implements UserProvider {
  String id = 'journal-owner';
  @override
  UserModel get currentUser => UserModel.empty().copyWith(id: id);
  void account(String value) {
    id = value;
    notifyListeners();
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  setUpAll(() => Hive.openBox<Map>('dream_journal_v1', bytes: Uint8List(0)));
  setUp(() => Hive.box<Map>('dream_journal_v1').clear());
  tearDownAll(Hive.close);
  for (final ru in [true, false]) {
    testWidgets(
      'journal separates list, writing, saved reading and intentional interpretation, ru=$ru',
      (tester) async {
        tester.view.physicalSize = ru
            ? const Size(390, 844)
            : const Size(320, 740);
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.reset);
        final user = _User();
        addTearDown(user.dispose);
        DreamEntry? chosen;
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
                    onPressed: () async {
                      chosen = await openDreamJournal(context, user);
                    },
                    child: const Text('Journal'),
                  ),
                ),
              ),
            ),
          ),
        );
        await tester.tap(find.text('Journal'));
        await tester.pumpAndSettle();
        expect(find.byType(TextField), findsNothing);
        await tester.tap(find.text(ru ? 'Записать сон' : 'Write a dream'));
        await tester.pumpAndSettle();
        expect(
          tester.widget<TextField>(find.byType(TextField)).focusNode!.hasFocus,
          isTrue,
        );
        await tester.enterText(
          find.byType(TextField),
          'A lighthouse by the sea',
        );
        await tester.pumpAndSettle();
        tester.view.viewInsets = const FakeViewPadding(bottom: 280);
        await tester.pumpAndSettle();
        await tester.tap(find.text(ru ? 'Сохранить сон' : 'Save dream'));
        await tester.pumpAndSettle();
        tester.view.resetViewInsets();
        await tester.pumpAndSettle();
        expect(find.byType(TextField), findsNothing);
        expect(find.text('A lighthouse by the sea'), findsOneWidget);
        expect(
          find.text(
            ru ? 'Сохранено на этом устройстве' : 'Saved on this device',
          ),
          findsOneWidget,
        );
        expect(chosen, isNull);
        await tester.tap(find.text(ru ? 'Изменить' : 'Edit'));
        await tester.pumpAndSettle();
        await tester.enterText(find.byType(TextField), 'A quiet lighthouse');
        await tester.pumpAndSettle();
        await tester.tap(
          find.text(ru ? 'Сохранить изменения' : 'Save changes'),
        );
        await tester.pumpAndSettle();
        final entries = await DreamJournal('journal-owner').read();
        expect(entries.single.text, 'A quiet lighthouse');
        await tester.tap(find.byTooltip(ru ? 'Назад' : 'Back'));
        await tester.pumpAndSettle();
        expect(find.byType(TextField), findsNothing);
        await tester.tap(find.text('A quiet lighthouse'));
        await tester.pumpAndSettle();
        await tester.tap(find.text(ru ? 'Спросить Ливею' : 'Ask Liveya'));
        await tester.pumpAndSettle();
        expect(chosen?.id, entries.single.id);
        expect(chosen?.text, 'A quiet lighthouse');
        await tester.tap(find.text('Journal'));
        await tester.pumpAndSettle();
        await tester.tap(find.byType(PopupMenuButton<String>));
        await tester.pumpAndSettle();
        await tester.tap(find.text(ru ? 'Удалить запись' : 'Delete entry'));
        await tester.pumpAndSettle();
        await tester.tap(find.text(ru ? 'Отмена' : 'Cancel'));
        await tester.pumpAndSettle();
        expect(await DreamJournal('journal-owner').read(), hasLength(1));
        await tester.tap(find.byType(PopupMenuButton<String>));
        await tester.pumpAndSettle();
        await tester.tap(find.text(ru ? 'Удалить запись' : 'Delete entry'));
        await tester.pumpAndSettle();
        await tester.tap(find.text(ru ? 'Удалить' : 'Delete'));
        await tester.pumpAndSettle();
        expect(await DreamJournal('journal-owner').read(), isEmpty);
        expect(find.text('A quiet lighthouse'), findsNothing);
        await tester.tap(find.text(ru ? 'Записать сон' : 'Write a dream'));
        await tester.pumpAndSettle();
        await tester.enterText(find.byType(TextField), 'Private unsaved dream');
        user.account('another-owner');
        await tester.pumpAndSettle();
        expect(find.text('Private unsaved dream'), findsNothing);
        expect(find.byType(TextField), findsNothing);
        expect(await DreamJournal('another-owner').read(), isEmpty);
        expect(tester.takeException(), isNull);
      },
    );
  }
}
