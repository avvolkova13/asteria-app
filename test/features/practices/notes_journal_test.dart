import 'package:asteria_app/app/data/models/user/user_model.dart';
import 'package:asteria_app/app/providers/user_provider.dart';
import 'package:asteria_app/core/localization/localization.dart';
import 'package:asteria_app/core/ui_kit/ui_kit.dart';
import 'package:asteria_app/features/practices/data/practice_notes_store.dart';
import 'package:asteria_app/features/practices/presentation/notes_journal_screen.dart';
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

  testWidgets(
    'all notes opens existing entries and returns after a personal note is saved',
    (tester) async {
      await const PracticeNotesStore().save(
        ownerId: 'editor-owner',
        practiceId: 'unhurried-morning',
        text: 'Morning note',
      );
      tester.view.physicalSize = const Size(390, 844);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      final user = _NotesUser();
      addTearDown(user.dispose);
      await tester.pumpWidget(
        ChangeNotifierProvider<UserProvider>.value(
          value: user,
          child: MaterialApp(
            locale: const Locale('ru'),
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
                  textScaler: TextScaler.noScaling,
                ),
                child: child!,
              ),
            ),
            home: const Scaffold(body: NotesJournalLink()),
          ),
        ),
      );

      await tester.tap(find.text('Мои заметки'));
      await tester.pumpAndSettle();
      expect(find.textContaining('Утро без спешки'), findsOneWidget);
      await tester.tap(find.text('Morning note'));
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextField), 'Revised morning');
      await tester.pump();
      await tester.tap(find.text('Сохранить изменения'));
      await tester.pumpAndSettle();
      expect(find.text('Revised morning'), findsOneWidget);
      await tester.tap(find.text('Написать заметку'));
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextField), 'Personal note');
      await tester.pump();
      await tester.tap(find.text('Сохранить заметку'));
      await tester.pumpAndSettle();
      expect(find.text('Personal note'), findsOneWidget);
      expect(find.text('Revised morning'), findsOneWidget);
      expect(find.textContaining('Личная заметка'), findsOneWidget);
    },
  );
}
