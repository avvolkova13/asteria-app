import 'package:asteria_app/app/data/models/sonnik/sonnik_model.dart';
import 'package:asteria_app/app/data/models/user/user_model.dart';
import 'package:asteria_app/app/providers/content_provider.dart';
import 'package:asteria_app/app/providers/user_provider.dart';
import 'package:asteria_app/core/analytics/analytics_facade.dart';
import 'package:asteria_app/core/analytics/product_analytics_service.dart';
import 'package:asteria_app/core/di/di.dart';
import 'package:asteria_app/core/localization/localization.dart';
import 'package:asteria_app/core/services/global_loader_service.dart';
import 'package:asteria_app/core/ui_kit/ui_kit.dart';
import 'package:asteria_app/features/monetization/presentation/monetization_provider.dart';
import 'package:asteria_app/features/sonnik/data/dream_journal.dart';
import 'package:asteria_app/features/sonnik/presentation/screens/dream_journal_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:provider/provider.dart';

class DreamTestUser extends ChangeNotifier implements UserProvider {
  String id = 'journal-owner';
  List<SonnikModel> history = [];
  @override
  UserModel get currentUser =>
      UserModel.empty().copyWith(id: id, sonnikHistory: history);
  void account(String value) {
    id = value;
    history = [];
    notifyListeners();
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _Content extends Fake implements ContentProvider {}

class _Analytics extends Fake implements AnalyticsFacade {
  @override
  Future<void> trackEvent(String name, {Map<String, dynamic>? params}) async {}
}

class _Access extends ChangeNotifier implements MonetizationProvider {
  @override
  bool get effectivePro => false;
  @override
  int get balance => 0;
  @override
  int requestsLeft(String feature) => 0;
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

Future<void> mountDreams(
  WidgetTester tester,
  DreamTestUser user, {
  required bool ru,
  required double width,
  double scale = 1,
}) async {
  await di.reset();
  final analytics = _Analytics();
  final access = _Access();
  di.registerSingleton<AnalyticsFacade>(analytics);
  di.registerSingleton<ProductAnalyticsService>(
    ProductAnalyticsService(analytics),
  );
  di.registerSingleton<ContentProvider>(_Content());
  di.registerSingleton<GlobalLoaderService>(GlobalLoaderService());
  addTearDown(() async {
    access.dispose();
    await di.reset();
  });
  tester.view.physicalSize = Size(width, 844);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(
    MultiProvider(
      providers: [
        ChangeNotifierProvider<UserProvider>.value(value: user),
        ChangeNotifierProvider<MonetizationProvider>.value(value: access),
      ],
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
              textScaler: TextScaler.linear(scale),
            ),
            child: child!,
          ),
        ),
        home: Scaffold(
          body: Builder(
            builder: (c) => TextButton(
              onPressed: () => openDreamJournal(c, user),
              child: const Text('Journal'),
            ),
          ),
        ),
      ),
    ),
  );
  await tester.tap(find.text('Journal'));
  await tester.pumpAndSettle();
}

SonnikModel reading(String id, int day) => SonnikModel(
  id: id,
  dateGenerated: DateTime(2026, 11, day),
  title: 'Title $id',
  interpretation: 'Meaning $id',
);

void main() {
  setUpAll(() => Hive.openBox<Map>('dream_journal_v1', bytes: Uint8List(0)));
  setUp(() => Hive.box<Map>('dream_journal_v1').clear());
  tearDownAll(Hive.close);

  test(
    'legacy rows, repeated responses and edited dreams keep their identities',
    () async {
      final box = Hive.box<Map>('dream_journal_v1');
      await box.put('a/old', {'text': 'Same words', 'at': 5});
      final journal = DreamJournal('a');
      final old = (await journal.read()).single;
      final first = reading('1', 2);
      final second = reading('2', 3);
      final historical = reading('3', 1);
      final another = await journal.save(old.text);
      await journal.save(old.text, entry: old, interpretation: first);
      await journal.save(old.text, entry: old, interpretation: first);
      final changed = await journal.save('Second night', entry: old);
      expect(changed.currentInterpretation, isNull);
      await journal.save(changed.text, entry: changed, interpretation: second);
      final restored = await journal.save(old.text, entry: changed);
      expect(restored.currentInterpretation?.id, first.id);
      final all = await journal.read(
        history: [historical, first, second, first],
      );
      expect(all, hasLength(3));
      final linked = all.singleWhere((d) => d.id == old.id);
      expect(linked.interpretations.map((r) => r.id), ['2', '1']);
      expect(linked.currentInterpretation?.id, '1');
      expect(
        all.singleWhere((d) => d.id == another.id).interpretations,
        isEmpty,
      );
      expect(all.singleWhere((d) => d.historyOnly).text, historical.title);
      await journal.delete(old.id);
      final afterDelete = await journal.read(
        history: [historical, first, second],
      );
      expect(afterDelete.map((d) => d.text), [another.text, historical.title]);
      await journal.delete(afterDelete.last.id);
      expect(
        await journal.read(history: [historical, first, second]),
        hasLength(1),
      );
      expect(
        await DreamJournal('other').read(history: [historical, first]),
        hasLength(2),
      );
    },
  );

  for (final ru in [true, false]) {
    testWidgets(
      'one journal opens original dreams and archived interpretations, ru=$ru',
      (tester) async {
        final user = DreamTestUser();
        addTearDown(user.dispose);
        final model = reading('old', 1);
        user.history = [model, model];
        final journal = DreamJournal(user.id);
        await journal.save('A quiet lighthouse');
        await mountDreams(
          tester,
          user,
          ru: ru,
          width: ru ? 390 : 320,
          scale: ru ? 1 : 1.5,
        );
        expect(find.text('A quiet lighthouse'), findsOneWidget);
        expect(find.text(model.title), findsOneWidget);
        await tester.tap(find.text(model.title));
        await tester.pumpAndSettle();
        expect(find.text(model.interpretation), findsOneWidget);
        await tester.tap(find.byTooltip(ru ? 'Назад' : 'Back'));
        await tester.pumpAndSettle();
        await tester.tap(find.text('A quiet lighthouse'));
        await tester.pumpAndSettle();
        expect(
          tester.widget<TextField>(find.byType(TextField)).controller!.text,
          'A quiet lighthouse',
        );
        await tester.enterText(find.byType(TextField), 'An open door');
        await tester.pumpAndSettle();
        tester.view.viewInsets = const FakeViewPadding(bottom: 250);
        await tester.pumpAndSettle();
        final save = find.text(ru ? 'Сохранить и выйти' : 'Save and exit');
        await tester.ensureVisible(save);
        await tester.pumpAndSettle();
        expect(save.hitTestable(), findsOneWidget);
        await tester.tap(save);
        await tester.pumpAndSettle();
        tester.view.resetViewInsets();
        await tester.pumpAndSettle();
        expect(find.text('An open door'), findsOneWidget);
        expect(find.byType(TextField), findsNothing);
        expect(await journal.read(), hasLength(1));
        await tester.tap(find.byType(PopupMenuButton<String>).first);
        await tester.pumpAndSettle();
        await tester.tap(find.text(ru ? 'Удалить запись' : 'Delete entry'));
        await tester.pumpAndSettle();
        await tester.tap(find.text(ru ? 'Отмена' : 'Cancel'));
        await tester.pumpAndSettle();
        expect(find.text('An open door'), findsOneWidget);
        final newEntry = find.text(ru ? 'Записать сон' : 'Write a dream');
        expect(newEntry.hitTestable(), findsOneWidget);
        await tester.tap(newEntry);
        await tester.pumpAndSettle();
        await tester.enterText(find.byType(TextField), 'Private draft');
        user.account('other');
        await tester.pumpAndSettle();
        expect(find.text('Private draft'), findsNothing);
        expect(find.byType(TextField), findsNothing);
        expect(await DreamJournal('other').read(), isEmpty);
        expect(tester.takeException(), isNull);
      },
    );
  }
}
