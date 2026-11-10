import 'package:asteria_app/app/data/models/article/article_model.dart';
import 'package:asteria_app/app/data/models/energy_of_day/energy_of_day_model.dart';
import 'package:asteria_app/app/data/models/user/user_model.dart';
import 'package:asteria_app/app/providers/content_provider.dart';
import 'package:asteria_app/app/providers/user_provider.dart';
import 'package:asteria_app/core/analytics/product_analytics_service.dart';
import 'package:asteria_app/core/di/di.dart';
import 'package:asteria_app/core/localization/generated/l10n.dart';
import 'package:asteria_app/core/routing/app_route.dart';
import 'package:asteria_app/core/ui_kit/theme/theme.dart';
import 'package:asteria_app/features/home/presentation/screens/practices_screen.dart';
import 'package:asteria_app/features/home/presentation/screens/profile_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

void main() {
  testWidgets('open profile from practices and return using its back button', (
    tester,
  ) async {
    final content = _Content();
    final user = _User();
    di.registerSingleton<ContentProvider>(content);
    di.registerSingleton<ProductAnalyticsService>(_ProfileAnalytics());
    final router = GoRouter(
      initialLocation: '/home',
      routes: [
        GoRoute(
          path: '/home',
          routes: [HomeProfileRoute()],
          builder: (_, _) => const Scaffold(body: PracticesScreen()),
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
            child: child,
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    final context = tester.element(find.byType(PracticesScreen));
    final profileLabel = AppLocalizations.of(context).navProfile;
    final avatar = find.byTooltip(profileLabel);
    expect(find.text(profileLabel), findsNothing);
    expect(tester.getSize(avatar), const Size(44, 44));
    await tester.tap(avatar);
    await tester.pumpAndSettle();
    expect(find.byType(ProfileScreen), findsOneWidget);
    expect(
      router.routerDelegate.currentConfiguration.last.route.name,
      HomeProfileRoute.routeName,
    );
    final back = MaterialLocalizations.of(context).backButtonTooltip;
    await tester.tap(find.bySemanticsLabel(back));
    await tester.pumpAndSettle();
    expect(find.byType(PracticesScreen), findsOneWidget);
    expect(find.byType(ProfileScreen), findsNothing);
    await tester.pumpWidget(const SizedBox.shrink());
  });
}

class _Content extends ChangeNotifier implements ContentProvider {
  @override
  List<ArticleModel> get articles => const [];
  @override
  bool get isLoadingContent => false;
  @override
  EnergyOfDayModel? getTodayEnergyOfDay() => null;
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
