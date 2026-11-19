import 'package:asteria_app/app/data/models/rune_of_day/rune_of_day_model.dart';
import 'package:asteria_app/app/data/models/user/user_model.dart';
import 'package:asteria_app/app/data/repositories/content/content_repository.dart';
import 'package:asteria_app/app/data/repositories/user/user_repository.dart';
import 'package:asteria_app/app/providers/content_provider.dart';
import 'package:asteria_app/app/providers/user_provider.dart';
import 'package:asteria_app/core/analytics/analytics_facade.dart';
import 'package:asteria_app/core/const/keys_const.dart';
import 'package:asteria_app/core/di/di.dart';
import 'package:asteria_app/core/localization/localization.dart';
import 'package:asteria_app/core/ui_kit/ui_kit.dart';
import 'package:asteria_app/features/compatibility/domain/repositories/compatibility_repository.dart';
import 'package:asteria_app/features/scenarios/free_rune_scenario.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets(
    'a free user can retry, open three runes and read their position meanings',
    (tester) async {
      final repo = _Runes();
      final user = UserProvider(userRepository: _Users());
      user.applyServerUserSnapshot(UserModel.empty().copyWith(id: 'free-user'));
      final content = ContentProvider(
        contentRepository: repo,
        userProvider: user,
        compatibilityRepository: _Compatibility(),
      );
      di.registerSingleton<ContentProvider>(content);
      di.registerSingleton<AnalyticsFacade>(_Analytics());
      addTearDown(() async {
        content.dispose();
        user.dispose();
        await di.reset();
      });
      await tester.binding.setSurfaceSize(const Size(390, 840));
      addTearDown(() => tester.binding.setSurfaceSize(null));
      final app = MaterialApp(
        locale: const Locale('ru'),
        supportedLocales: AppLocaleService.supportedLocales,
        localizationsDelegates: const [
          AppLocalizations.delegate,
          ...GlobalMaterialLocalizations.delegates,
        ],
        builder: (context, child) => MediaQuery(
          data: MediaQuery.of(context).copyWith(disableAnimations: true),
          child: Theme(
            data: AppThemeDark.instance.getThemeData(context),
            child: child!,
          ),
        ),
        home: const FreeRuneScenario(),
      );
      await tester.pumpWidget(app);
      await tester.pumpAndSettle();
      expect(find.text('Не удалось загрузить расклад.'), findsOneWidget);
      repo.available = true;
      await tester.tap(find.text('Попробовать снова'));
      await tester.pumpAndSettle();
      const positions = [
        KeysConst.runeDeckLeftKey,
        KeysConst.runeDeckCenterKey,
        KeysConst.runeDeckRightKey,
      ];
      for (final i in [1, 0, 2]) {
        final card = find.byKey(ValueKey('rune_layout_back_$i'));
        await tester.ensureVisible(card);
        await tester.tap(card);
        await tester.pumpAndSettle();
        final rune = content.getRuneInDeck(positions[i])!;
        final meaning = [rune.pastDeck, rune.presentDeck, rune.futureDeck][i];
        expect(find.text(meaning), findsOneWidget);
      }
      expect(content.areAllRuneDeckCardsOpened(), isTrue);
      final ids = positions.map((p) => content.getRuneInDeck(p)!.id).toList();
      final resetDate = user.currentUser!.runeDeckLayoutLastResetDate;
      content.setDailySymbolRuneOpened();
      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pumpWidget(app);
      await tester.pumpAndSettle();

      for (var i = 0; i < positions.length; i++) {
        expect(find.byKey(ValueKey('rune_layout_back_$i')), findsOneWidget);
        expect(content.isRuneInDeckOpened(positions[i]), isFalse);
        expect(content.getRuneInDeck(positions[i])!.id, ids[i]);
      }
      expect(find.textContaining(' · '), findsNothing);
      expect(content.isDailySymbolRuneOpened(), isTrue);
      expect(user.currentUser!.runeDeckLayoutLastResetDate, resetDate);
      await tester.tap(find.byKey(const ValueKey('rune_layout_back_1')));
      await tester.pumpAndSettle();
      expect(positions.map(content.isRuneInDeckOpened), [false, true, false]);
      expect(find.textContaining(' · '), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );
}

class _Runes extends Fake implements ContentRepository {
  bool available = false;

  @override
  Future<void> refreshContentVersions() async {}

  @override
  Future<List<RuneOfDayModel>> getRunes() async => available
      ? [
          for (final name in ['algiz', 'fehu', 'uruz'])
            RuneOfDayModel(
              id: name,
              title: name,
              imageName: name,
              sort: 0,
              cardOfDayDescription: '',
              generalDescription: '',
              pastDeck: 'past $name',
              presentDeck: 'present $name',
              futureDeck: 'future $name',
              keywords: [],
              definitions: [],
            ),
        ]
      : [];
}

class _Users extends Fake implements UserRepository {
  @override
  Future<void> updateCurrentUser(UserModel user) async {}
}

class _Compatibility extends Fake implements CompatibilityRepository {}

class _Analytics extends Fake implements AnalyticsFacade {
  @override
  Future<void> trackEvent(String name, {Map<String, dynamic>? params}) async {}
}
