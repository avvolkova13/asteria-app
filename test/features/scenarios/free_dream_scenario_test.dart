import 'package:asteria_app/app/data/models/sonnik/sonnik_model.dart';
import 'package:asteria_app/app/data/models/user/user_model.dart';
import 'package:asteria_app/app/providers/content_provider.dart';
import 'package:asteria_app/app/providers/user_provider.dart';
import 'package:asteria_app/core/localization/localization.dart';
import 'package:asteria_app/core/ui_kit/theme/theme.dart';
import 'package:asteria_app/features/monetization/domain/monetization_models.dart';
import 'package:asteria_app/features/monetization/presentation/monetization_provider.dart';
import 'package:asteria_app/features/scenarios/free_dream_scenario.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

final _dream = SonnikModel(
  id: 'dream',
  dateGenerated: DateTime(2026),
  title: 'Знакомый берег',
  interpretation: 'Берег во сне может напомнить о доме.',
);

class _User extends ChangeNotifier implements UserProvider {
  @override
  UserModel currentUser = UserModel.empty().copyWith(id: 'reader');

  void switchAccount() {
    currentUser = UserModel.empty().copyWith(id: 'another');
    notifyListeners();
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _Access extends ChangeNotifier implements MonetizationProvider {
  int remaining = 1, paid = 0, checks = 0;
  bool throwOnRefresh = false;
  @override
  bool effectivePro = false;
  @override
  Future<void> refreshForAccess() async {
    checks++;
    if (throwOnRefresh) throw StateError('offline');
  }

  @override
  bool isCurrentUser(String uid) => uid == 'reader';
  @override
  bool isFeatureEnabled(String key) => true;
  @override
  Map<String, RequestQuotaModel> get requestQuotas => {
    'sonnik': requestQuota('sonnik'),
  };
  @override
  RequestQuotaModel requestQuota(String key) => RequestQuotaModel.fromJson({
    'feature': key,
    'free_remaining': remaining,
    'paid_remaining': paid,
  });
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _Content extends ChangeNotifier implements ContentProvider {
  final requests = <String>[];
  @override
  Future<SonnikModel> createSonnik(String text) async {
    requests.add(text);
    return _dream;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  late _Access access;
  late _User user;
  late _Content content;
  late bool openedRunes;
  setUp(() {
    access = _Access();
    user = _User();
    content = _Content();
    openedRunes = false;
  });
  Future<void> mount(WidgetTester tester, {String lang = 'ru'}) async {
    await tester.binding.setSurfaceSize(const Size(390, 844));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(
      MaterialApp(
        locale: Locale(lang),
        supportedLocales: AppLocaleService.supportedLocales,
        localizationsDelegates: const [
          AppLocalizations.delegate,
          ...GlobalMaterialLocalizations.delegates,
        ],
        builder: (context, child) => Theme(
          data: AppThemeDark.instance.getThemeData(context),
          child: MultiProvider(
            providers: [
              ChangeNotifierProvider<UserProvider>.value(value: user),
              ChangeNotifierProvider<MonetizationProvider>.value(value: access),
              ChangeNotifierProvider<ContentProvider>.value(value: content),
            ],
            child: child!,
          ),
        ),
        home: FreeDreamScenario(onOpenRunes: () => openedRunes = true),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('PRO interprets dreams with zero free requests', (tester) async {
    access.remaining = 0;
    access.effectivePro = true;
    await mount(tester);
    expect(find.textContaining('Бесплатных толкований'), findsNothing);
    await tester.enterText(find.byType(TextField), 'Дом у реки');
    await tester.pumpAndSettle();
    await tester.tap(find.text('Расшифровать'));
    await tester.pumpAndSettle();
    expect(access.checks, 2);
    expect(content.requests, ['Дом у реки']);
    expect(find.text(_dream.interpretation), findsOneWidget);
  });

  testWidgets(
    'a new free user can interpret a dream and open its full result',
    (tester) async {
      await mount(tester);
      expect(find.text('Бесплатных толкований осталось: 1'), findsOneWidget);
      await tester.enterText(find.byType(TextField), '  Дом у реки  ');
      await tester.pumpAndSettle();
      await tester.tap(find.text('Расшифровать'));
      await tester.pumpAndSettle();
      expect(access.checks, 2);
      expect(content.requests, ['Дом у реки']);
      expect(find.text(_dream.interpretation), findsOneWidget);
    },
  );

  testWidgets(
    'checks again before submitting and offers a free rune when the last attempt is gone',
    (tester) async {
      await mount(tester, lang: 'en');
      await tester.enterText(find.byType(TextField), 'A quiet river');
      await tester.pumpAndSettle();
      access.remaining = 0;
      access.paid = 3;
      await tester.tap(find.text('Interpret'));
      await tester.pumpAndSettle();
      expect(content.requests, isEmpty);
      expect(find.byType(TextField), findsNothing);
      expect(access.checks, 2);
      await tester.tap(find.text('Open three runes'));
      expect(openedRunes, isTrue);
    },
  );

  testWidgets(
    'a failed quota check still allows opening a saved interpretation',
    (tester) async {
      access.throwOnRefresh = true;
      user.currentUser = user.currentUser.copyWith(sonnikHistory: [_dream]);
      await mount(tester);
      expect(find.byType(TextField), findsNothing);
      await tester.tap(find.text(_dream.title));
      await tester.pumpAndSettle();
      expect(find.text(_dream.interpretation), findsOneWidget);
      expect(content.requests, isEmpty);
      user.switchAccount();
      await tester.pumpAndSettle();
      expect(find.text(_dream.interpretation), findsNothing);
    },
  );
}
