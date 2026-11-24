import 'package:asteria_app/app/data/models/user/user_model.dart';
import 'package:asteria_app/app/providers/user_provider.dart';
import 'package:asteria_app/features/practices/data/practice_notes_store.dart';
import 'package:asteria_app/features/practices/presentation/practice_note_indicators.dart';
import 'package:flutter/material.dart';
import 'package:asteria_app/core/ui_kit/ui_kit.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:provider/provider.dart';

class _User extends ChangeNotifier implements UserProvider {
  String? id = 'owner';
  @override
  UserModel? get currentUser =>
      id == null ? null : UserModel.empty().copyWith(id: id);
  void account(String? next) {
    id = next;
    notifyListeners();
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  setUpAll(() => Hive.openBox<Map>('practice_notes_v1', bytes: Uint8List(0)));
  tearDownAll(Hive.close);
  testWidgets(
    'counts update, clear, and never leak across account or logout changes',
    (tester) async {
      final user = _User();
      addTearDown(user.dispose);
      await tester.pumpWidget(
        ChangeNotifierProvider<UserProvider>.value(
          value: user,
          child: MaterialApp(
            builder: (context, child) => Theme(
              data: AppThemeDark.instance.getThemeData(context),
              child: child!,
            ),
            home: Scaffold(
              body: Column(
                children: [
                  PracticeNotesCountBuilder(
                    practiceId: 'morning',
                    builder: (context, count) =>
                        Text(practiceNoteCountLabel(context, count)),
                  ),
                  PracticeNotesCountBuilder(
                    practiceId: 'body',
                    builder: (context, count) =>
                        Text(practiceNoteCountLabel(context, count)),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      const store = PracticeNotesStore();
      final note = await store.save(
        ownerId: 'owner',
        practiceId: 'morning',
        text: 'Morning',
      );
      await tester.pumpAndSettle();
      expect(find.text('1 note'), findsOneWidget);
      await store.save(
        ownerId: 'different',
        practiceId: 'morning',
        text: 'Private',
      );
      await tester.pumpAndSettle();
      expect(find.text('1 note'), findsOneWidget);
      user.account(null);
      await tester.pumpAndSettle();
      expect(find.text('1 note'), findsNothing);
      user.account('owner');
      await tester.pumpAndSettle();
      expect(find.text('1 note'), findsOneWidget);
      await store.delete('owner', 'morning', note.id);
      await tester.pumpAndSettle();
      expect(find.text('1 note'), findsNothing);
      user.account('different');
      await tester.pumpAndSettle();
      expect(find.text('1 note'), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );
}
