import 'package:asteria_app/app/data/models/affirmation/affirmation_model.dart';
import 'package:asteria_app/app/data/models/user/user_model.dart';
import 'package:asteria_app/app/providers/user_provider.dart';
import 'package:asteria_app/core/localization/localization.dart';
import 'package:asteria_app/core/ui_kit/theme/theme.dart';
import 'package:asteria_app/features/affirmation/selected_affirmation_player.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:provider/provider.dart';

class _User extends ChangeNotifier implements UserProvider {
  @override
  UserModel get currentUser =>
      UserModel.empty().copyWith(id: 'affirmation-user');

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  setUpAll(() async {
    await Hive.openBox<Map>('practice_notes_v1', bytes: Uint8List(0));
  });
  tearDownAll(Hive.close);

  for (final language in ['ru', 'en']) {
    testWidgets(
      'selected text remains readable at 320 points and large text in $language',
      (tester) async {
        tester.view.physicalSize = const Size(320, 568);
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.reset);
        final calls = <MethodCall>[];
        const channel = MethodChannel('asteria/practice-audio');
        tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
          channel,
          (call) async {
            calls.add(call);
            return null;
          },
        );
        addTearDown(
          () => tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
            channel,
            null,
          ),
        );
        final text = List.filled(
          16,
          language == 'ru'
              ? 'Любовь наполняет мою жизнь.'
              : 'Love fills my life.',
        ).join(' ');
        final user = _User();
        addTearDown(user.dispose);
        await tester.pumpWidget(
          ChangeNotifierProvider<UserProvider>.value(
            value: user,
            child: MaterialApp(
              locale: Locale(language),
              supportedLocales: AppLocaleService.supportedLocales,
              localizationsDelegates: const [
                AppLocalizations.delegate,
                ...GlobalMaterialLocalizations.delegates,
              ],
              builder: (context, child) => Theme(
                data: AppThemeDark.instance.getThemeData(context),
                child: MediaQuery(
                  data: MediaQuery.of(context).copyWith(
                    textScaler: const TextScaler.linear(2),
                    disableAnimations: true,
                  ),
                  child: child!,
                ),
              ),
              home: SelectedAffirmationPlayer(
                selection: AffirmationSelection(
                  affirmation: AffirmationModel(
                    id: 'selected-love',
                    categoryId: 'love',
                    category: 'Любовь',
                    text: text,
                    sort: 1,
                  ),
                ),
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();
        expect(find.text(language == 'ru' ? 'Любовь' : 'Love'), findsOneWidget);
        expect(find.text(text), findsOneWidget);
        final paragraph = tester.renderObject<RenderParagraph>(
          find.descendant(of: find.text(text), matching: find.byType(RichText)),
        );
        expect(paragraph.didExceedMaxLines, isFalse);
        await tester.drag(
          find.byType(SingleChildScrollView),
          const Offset(0, -3000),
        );
        await tester.pumpAndSettle();
        final lastLetter = paragraph
            .getBoxesForSelection(
              TextSelection(
                baseOffset: text.length - 1,
                extentOffset: text.length,
              ),
            )
            .last;
        final bottom =
            paragraph.localToGlobal(Offset.zero).dy + lastLetter.bottom;
        expect(bottom, lessThanOrEqualTo(568));
        expect(
          calls,
          isEmpty,
          reason:
              'Text content must never initialize the unrelated bundled recording',
        );
        expect(find.byType(Slider), findsOneWidget);
        expect(
          find.text(language == 'ru' ? 'Начать практику' : 'Start practice'),
          findsNothing,
        );

        final play = find.bySemanticsLabel(
          language == 'ru' ? 'Воспроизвести' : 'Play',
        );
        final repeat = find.bySemanticsLabel(
          language == 'ru' ? 'Повтор записи' : 'Repeat recording',
        );
        final notes = find.bySemanticsLabel(
          language == 'ru' ? 'Мои заметки' : 'My notes',
        );
        await tester.ensureVisible(play);
        await tester.pumpAndSettle();
        final center = tester.getCenter(play);
        expect(find.text(language == 'ru' ? 'Заметки' : 'Notes'), findsNothing);
        expect(tester.getCenter(notes).dy, closeTo(center.dy, .5));
        expect(tester.getCenter(notes).dx, lessThan(center.dx));
        expect(tester.getCenter(repeat).dx, greaterThan(center.dx));
        await tester.tap(repeat);
        await tester.pump();
        expect(
          find.text(language == 'ru' ? 'Повтор включён' : 'Repeat on'),
          findsOneWidget,
        );
        await tester.tap(play);
        await tester.pump();
        expect(
          find.bySemanticsLabel(language == 'ru' ? 'Пауза' : 'Pause'),
          findsOneWidget,
        );
        await tester.tap(notes);
        await tester.pumpAndSettle();
        expect(find.byType(TextField), findsOneWidget);
        Navigator.of(tester.element(find.byType(TextField))).pop();
        await tester.pumpAndSettle();
        expect(play, findsOneWidget);
        expect(find.text(text), findsOneWidget);
        expect(calls, isEmpty);
        expect(tester.takeException(), isNull);
      },
    );
  }
}
