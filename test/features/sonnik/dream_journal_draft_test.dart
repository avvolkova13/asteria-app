import 'package:asteria_app/app/data/models/user/user_model.dart';
import 'package:asteria_app/app/providers/user_provider.dart';
import 'package:asteria_app/core/localization/localization.dart';
import 'package:asteria_app/core/ui_kit/ui_kit.dart';
import 'package:asteria_app/features/sonnik/presentation/screens/dream_journal_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:provider/provider.dart';

class _User extends ChangeNotifier implements UserProvider {
  @override
  UserModel get currentUser => UserModel.empty().copyWith(id: 'draft-owner');
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  setUpAll(() => Hive.openBox<Map>('dream_journal_v1', bytes: Uint8List(0)));
  tearDownAll(Hive.close);
  for (final width in [800.0, 320.0]) {
    testWidgets(
      'Add and the actual toolbar Back protect a dream draft, width=$width',
      (tester) async {
        tester.view.physicalSize = Size(width, 844);
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.reset);
        final user = _User();
        addTearDown(user.dispose);
        await tester.pumpWidget(
          ChangeNotifierProvider<UserProvider>.value(
            value: user,
            child: MaterialApp(
              locale: const Locale('en'),
              supportedLocales: AppLocaleService.supportedLocales,
              localizationsDelegates: const [
                AppLocalizations.delegate,
                ...GlobalMaterialLocalizations.delegates,
              ],
              builder: (context, child) => Theme(
                data: AppThemeDark.instance.getThemeData(context),
                child: MediaQuery(
                  data: MediaQuery.of(
                    context,
                  ).copyWith(disableAnimations: true),
                  child: child!,
                ),
              ),
              home: Scaffold(
                body: Builder(
                  builder: (context) => TextButton(
                    onPressed: () => openDreamJournal(context, user),
                    child: const Text('Open dreams'),
                  ),
                ),
              ),
            ),
          ),
        );
        await tester.tap(find.text('Open dreams'));
        await tester.pumpAndSettle();
        await tester.enterText(
          find.byType(TextField),
          'Do not lose this dream',
        );
        await tester.pumpAndSettle();
        await tester.ensureVisible(find.text('Add dream'));
        await tester.tap(find.text('Add dream'));
        await tester.pumpAndSettle();
        expect(find.text('Discard changes?'), findsOneWidget);
        await tester.tap(find.text('Cancel'));
        await tester.pumpAndSettle();
        await tester.tap(find.byTooltip('Back'));
        await tester.pumpAndSettle();
        expect(find.text('Discard changes?'), findsOneWidget);
        await tester.tap(find.text('Cancel'));
        await tester.pumpAndSettle();
        expect(
          tester.widget<TextField>(find.byType(TextField)).controller!.text,
          'Do not lose this dream',
        );
        await tester.tap(find.byTooltip('Back'));
        await tester.pumpAndSettle();
        await tester.tap(find.text('Discard'));
        await tester.pumpAndSettle();
        expect(find.text('Open dreams'), findsOneWidget);
        expect(find.byType(DreamJournalScreen), findsNothing);
      },
    );
  }
}
