import 'package:asteria_app/app/data/models/user/user_model.dart';
import 'package:asteria_app/app/providers/user_provider.dart';
import 'package:asteria_app/core/localization/localization.dart';
import 'package:asteria_app/core/ui_kit/ui_kit.dart';
import 'package:asteria_app/features/practices/data/practice_notes_store.dart';
import 'package:asteria_app/features/practices/practice_catalog_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:provider/provider.dart';

class _User extends ChangeNotifier implements UserProvider {
  String? _id = 'owner';

  @override
  UserModel? get currentUser =>
      _id == null ? null : UserModel.empty().copyWith(id: _id);

  void changeAccount(String id) {
    _id = id;
    notifyListeners();
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  setUpAll(() async {
    // Persistence across box reopen is covered with a disk box in the store
    // test. Keep the widget's asynchronous interaction on the test clock.
    await Hive.openBox<Map>('practice_notes_v1', bytes: Uint8List(0));
    await Hive.openBox<bool>(
      'affirmation_player_favorites',
      bytes: Uint8List(0),
    );
  });

  tearDownAll(Hive.close);

  testWidgets('practice notes work before and after playback', (tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    final user = _User();
    addTearDown(user.dispose);

    await tester.pumpWidget(
      ChangeNotifierProvider<UserProvider>.value(
        value: user,
        child: MaterialApp(
          supportedLocales: AppLocaleService.supportedLocales,
          localizationsDelegates: const [
            AppLocalizations.delegate,
            ...GlobalMaterialLocalizations.delegates,
          ],
          builder: (context, child) => Theme(
            data: AppThemeDark.instance.getThemeData(context),
            child: MediaQuery(
              data: MediaQuery.of(context).copyWith(disableAnimations: true),
              child: child!,
            ),
          ),
          home: Scaffold(
            body: Builder(
              builder: (context) => TextButton(
                onPressed: () =>
                    openPracticeCatalog(context, PracticeCategory.meditation),
                child: const Text('Meditations'),
              ),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Meditations'));
    await tester.pumpAndSettle();
    expect(find.text('Write a note'), findsNothing);
    await tester.tap(find.text('An Unhurried Morning').hitTestable());
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('My notes'));
    await tester.tap(find.text('My notes'));
    await tester.pumpAndSettle();

    final editor = find.byType(TextField);
    await tester.enterText(editor, 'My garden is quiet');
    await tester.pumpAndSettle();
    final save = find.text('Save note');
    await tester.ensureVisible(save);
    await tester.tap(save);
    await tester.pumpAndSettle();
    expect(find.text('Saved'), findsOneWidget);
    const store = PracticeNotesStore();
    final note = (await store.read('owner', 'unhurried-morning')).single;
    expect(note.text, 'My garden is quiet');

    await tester.ensureVisible(find.text('My garden is quiet').last);
    await tester.tap(find.text('My garden is quiet').last);
    await tester.pumpAndSettle();
    await tester.enterText(editor, 'My garden is sunny');
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('Save changes'));
    await tester.tap(find.text('Save changes'));
    await tester.pumpAndSettle();
    final changed = (await store.read('owner', 'unhurried-morning')).single;
    expect(changed.text, 'My garden is sunny');
    expect(changed.recordedAt, note.recordedAt);

    await tester.pageBack();
    await tester.pumpAndSettle();

    const channel = MethodChannel('asteria/practice-audio');
    final messenger = tester.binding.defaultBinaryMessenger;
    var playing = false;
    var complete = false;
    var looping = false;
    messenger.setMockMethodCallHandler(channel, (call) async {
      if (call.method == 'toggle') playing = !playing;
      if (call.method == 'pause') playing = false;
      if (call.method == 'loop') looping = call.arguments['value'] as bool;
      return {
        'position': complete ? 180000 : 31000,
        'duration': 180000,
        'playing': playing && !complete,
        'loop': looping,
        'complete': complete,
      };
    });
    addTearDown(() => messenger.setMockMethodCallHandler(channel, null));
    await tester.tap(find.text('Start practice'));
    await tester.pumpAndSettle();
    expect(playing, isTrue);
    final pencil = find.bySemanticsLabel('My notes');
    expect(pencil.hitTestable(), findsOneWidget);
    final repeat = find.bySemanticsLabel('Repeat recording');
    expect(repeat.hitTestable(), findsOneWidget);
    final playCenter = tester.getCenter(find.bySemanticsLabel('Pause'));
    final pencilCenter = tester.getCenter(pencil);
    final repeatCenter = tester.getCenter(repeat);
    expect(playCenter.dx, closeTo(195, .5));
    expect(repeatCenter.dy, closeTo(playCenter.dy, .5));
    expect(
      repeatCenter.dx - playCenter.dx,
      closeTo(playCenter.dx - pencilCenter.dx, .5),
    );
    await tester.tap(repeat);
    await tester.pump();
    expect(looping, isTrue);
    await tester.tap(repeat);
    await tester.pump();
    expect(looping, isFalse);
    expect(find.bySemanticsLabel('Favorite'), findsNothing);
    await tester.tap(pencil);
    await tester.pumpAndSettle();
    expect(find.text('My notes'), findsOneWidget);
    expect(find.text('My garden is sunny'), findsAtLeastNWidgets(1));
    expect(playing, isFalse);
    await tester.pageBack();
    await tester.pumpAndSettle();
    expect(playing, isFalse);
    expect(find.text('0:31'), findsOneWidget);
    await tester.tap(find.bySemanticsLabel('Play'));
    await tester.pumpAndSettle();
    expect(playing, isTrue);
    complete = true;
    await tester.pump(const Duration(milliseconds: 160));
    await tester.pumpAndSettle();
    expect(find.text('Practice complete'), findsOneWidget);

    await tester.tap(find.text('Write a note'));
    await tester.pumpAndSettle();
    expect(find.byType(TextField), findsOneWidget);
    expect(tester.widget<TextField>(editor).controller!.text, isEmpty);
    await tester.pageBack();
    await tester.pumpAndSettle();
    final menu = find.byType(PopupMenuButton<String>);
    await tester.ensureVisible(menu);
    await tester.tap(menu);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Delete note'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Delete'));
    await tester.pumpAndSettle();
    expect(find.text('Note deleted.'), findsOneWidget);
    expect(await store.read('owner', 'unhurried-morning'), isEmpty);

    await tester.enterText(editor, 'Visible only to the original account');
    await tester.pumpAndSettle();
    user.changeAccount('other');
    await tester.pumpAndSettle();
    expect(find.text('Visible only to the original account'), findsNothing);
    expect(find.byType(TextField), findsNothing);
    expect(await store.read('other', 'unhurried-morning'), isEmpty);
  });
}
