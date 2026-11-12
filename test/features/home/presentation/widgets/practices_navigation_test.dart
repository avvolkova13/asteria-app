import 'package:asteria_app/app/data/models/article/article_model.dart';
import 'package:asteria_app/app/data/models/user/user_model.dart';
import 'package:asteria_app/app/providers/content_provider.dart';
import 'package:asteria_app/app/data/repositories/user/user_repository.dart';
import 'package:asteria_app/features/home/presentation/cubit/home_cubit.dart';
import 'package:asteria_app/features/home/presentation/cubit/home_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:asteria_app/app/providers/user_provider.dart';
import 'package:asteria_app/core/analytics/product_analytics_service.dart';
import 'package:asteria_app/core/di/di.dart';
import 'package:asteria_app/core/localization/generated/l10n.dart';
import 'package:asteria_app/core/routing/app_route.dart';
import 'package:asteria_app/core/ui_kit/theme/theme.dart';
import 'package:asteria_app/features/home/presentation/screens/practices_screen.dart';
import 'package:asteria_app/features/home/presentation/screens/profile_screen.dart';
import 'package:asteria_app/features/scenarios/first_session.dart';
import 'package:asteria_app/features/scenarios/scenario_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

void main() {
  testWidgets(
    'reopen scenarios from profile and return through each step to practices',
    (tester) async {
      final content = _Content();
      final user = _User();
      di.registerSingleton<ContentProvider>(content);
      di.registerSingleton<UserProvider>(user);
      di.registerSingleton<ProductAnalyticsService>(_ProfileAnalytics());
      final home = HomeCubit(
        userRepository: _Repository(),
        contentProvider: content,
        userProvider: user,
      );
      await home.start();
      home.changeTab(2);
      addTearDown(home.close);
      final router = GoRouter(
        initialLocation: '/home',
        routes: [
          GoRoute(
            path: FirstSession.path,
            builder: (_, _) => const ScenarioPicker(),
          ),
          GoRoute(
            path: '/home',
            routes: [HomeProfileRoute()],
            builder: (_, _) => BlocBuilder<HomeCubit, HomeState>(
              builder: (_, state) => Scaffold(
                body: (state as HomeLoaded).currentTabIndex == 2
                    ? const PracticesScreen()
                    : const Text('Main tab'),
              ),
            ),
          ),
        ],
      );
      addTearDown(() async {
        router.dispose();
        content.dispose();
        user.dispose();
        await di.reset();
      });
      await tester.pumpWidget(
        MaterialApp.router(
          routerConfig: router,
          localizationsDelegates: const [AppLocalizations.delegate],
          builder: (context, child) => Theme(
            data: AppThemeDark.instance.getThemeData(context),
            child: ChangeNotifierProvider<UserProvider>.value(
              value: user,
              child: BlocProvider.value(value: home, child: child!),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      final context = tester.element(find.byType(PracticesScreen));
      final labels = AppLocalizations.of(context);
      expect(find.text(labels.energyOfDay), findsNothing);
      final profileLabel = labels.navProfile;
      final avatar = find.byTooltip(profileLabel);
      expect(find.text(profileLabel), findsOneWidget);
      expect(tester.getSize(avatar).width, greaterThan(44));
      expect(tester.getSize(avatar).height, greaterThanOrEqualTo(44));
      await tester.tap(avatar);
      await tester.pumpAndSettle();
      expect(find.byType(ProfileScreen), findsOneWidget);
      expect(
        router.routerDelegate.currentConfiguration.last.route.name,
        HomeProfileRoute.routeName,
      );
      final back = MaterialLocalizations.of(context).backButtonTooltip;
      await tester.tap(find.text(labels.scenarioStartTitle));
      await tester.pumpAndSettle();
      expect(find.byType(ScenarioPicker), findsOneWidget);
      await tester.tap(find.text(labels.scenarioPracticeTitle));
      await tester.pumpAndSettle();
      expect(find.text(labels.scenarioPracticeChooseMood), findsOneWidget);
      await tester.tap(find.byTooltip(back));
      await tester.pumpAndSettle();
      expect(find.byType(ScenarioPicker), findsOneWidget);
      await tester.tap(find.byTooltip(back));
      await tester.pumpAndSettle();
      expect(find.byType(ProfileScreen), findsOneWidget);
      await tester.tap(find.bySemanticsLabel(back));
      await tester.pumpAndSettle();
      expect(find.byType(PracticesScreen), findsOneWidget);
      expect(find.byType(ProfileScreen), findsNothing);
      expect((home.state as HomeLoaded).currentTabIndex, 2);
      await tester.tap(avatar);
      await tester.pumpAndSettle();
      await tester.tap(find.text(labels.scenarioStartTitle));
      await tester.pumpAndSettle();
      await tester.tap(find.text(labels.scenarioGoHome));
      await tester.pumpAndSettle();
      expect((home.state as HomeLoaded).currentTabIndex, 0);
      expect(find.text('Main tab'), findsOneWidget);
      expect(router.canPop(), isFalse);
      await tester.pumpWidget(const SizedBox.shrink());
    },
  );
}

class _Repository extends Fake implements UserRepository {}

class _Content extends ChangeNotifier implements ContentProvider {
  @override
  List<ArticleModel> get articles => const [];
  @override
  bool isTodayTarotCardOpened() => false;
  @override
  bool isTodayRuneOpened() => false;
  @override
  bool get isLoadingContent => false;
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _User extends ChangeNotifier implements UserProvider {
  @override
  UserModel? get currentUser => null;
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _ProfileAnalytics extends Fake implements ProductAnalyticsService {
  @override
  Future<void> trackProfileView() async {}
}
