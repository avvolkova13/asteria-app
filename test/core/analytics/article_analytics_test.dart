import 'package:asteria_app/app/data/models/article/article_model.dart';
import 'package:asteria_app/app/data/repositories/user/user_repository.dart';
import 'package:asteria_app/app/providers/content_provider.dart';
import 'package:asteria_app/app/providers/user_provider.dart';
import 'package:asteria_app/core/analytics/analytics_facade.dart';
import 'package:asteria_app/core/di/di.dart';
import 'package:asteria_app/core/localization/localization.dart';
import 'package:asteria_app/core/ui_kit/theme/theme.dart';
import 'package:asteria_app/features/article/presentation/article_screen.dart';
import 'package:asteria_app/features/balance/presentation/provider/rewards_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

void main() {
  testWidgets(
    'article open and read are distinct, once per visible article, no content params',
    (tester) async {
      final analytics = ArticleEvents();
      final content = ArticleContent();
      di.registerSingleton<AnalyticsFacade>(analytics);
      di.registerSingleton<ContentProvider>(content);
      di.registerSingleton<RewardsProvider>(ArticleRewards());
      final user = UserProvider(userRepository: ArticleUserRepository());
      addTearDown(() async {
        user.dispose();
        await di.reset();
      });
      await tester.pumpWidget(
        ChangeNotifierProvider<UserProvider>.value(
          value: user,
          child: MaterialApp(
            locale: const Locale('en'),
            localizationsDelegates: const [
              AppLocalizations.delegate,
              ...GlobalMaterialLocalizations.delegates,
            ],
            supportedLocales: AppLocaleService.supportedLocales,
            home: Builder(
              builder: (context) => Theme(
                data: AppThemeLight.instance.getThemeData(context),
                child: const ArticleScreen(articleId: 'test'),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(analytics.events, ['article_opened']);
      final scroll = tester.widget<CustomScrollView>(
        find.byType(CustomScrollView),
      );
      scroll.controller!.jumpTo(scroll.controller!.position.maxScrollExtent);
      await tester.pumpAndSettle();
      expect(analytics.events, ['article_opened', 'article_read']);
      scroll.controller!.jumpTo(0);
      scroll.controller!.jumpTo(scroll.controller!.position.maxScrollExtent);
      await tester.pumpAndSettle();
      expect(analytics.events, hasLength(2));
      expect(tester.takeException(), isNull);
    },
  );
}

class ArticleEvents implements AnalyticsFacade {
  final events = <String>[];
  @override
  Future<void> trackEvent(String name, {Map<String, dynamic>? params}) async {
    expect(params, isNull);
    events.add(name);
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class ArticleContent implements ContentProvider {
  @override
  List<ArticleModel> get articles => [];
  @override
  ArticleModel? getArticleById(String id) => ArticleModel(
    id: 'article1',
    title: 'Test',
    category: 'Test',
    intro: 'Introduction',
    text: List.filled(80, 'Content paragraph.').join('\n\n'),
    conclusion: 'Conclusion',
    timeToRead: 3,
  );
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class ArticleRewards implements RewardsProvider {
  @override
  Future<void> recordArticleRead(String articleId) async {}
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class ArticleUserRepository implements UserRepository {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}
