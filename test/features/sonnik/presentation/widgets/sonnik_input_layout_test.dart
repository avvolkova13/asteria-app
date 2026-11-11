import 'package:asteria_app/app/providers/content_provider.dart';
import 'package:asteria_app/app/providers/user_provider.dart';
import 'package:asteria_app/core/analytics/analytics_facade.dart';
import 'package:asteria_app/core/analytics/product_analytics_service.dart';
import 'package:asteria_app/core/di/di.dart';
import 'package:asteria_app/core/localization/localization.dart';
import 'package:asteria_app/core/services/global_loader_service.dart';
import 'package:asteria_app/core/ui_kit/theme/theme.dart';
import 'package:asteria_app/features/monetization/presentation/monetization_provider.dart';
import 'package:asteria_app/features/sonnik/presentation/screens/create_sonnik_initial_screen.dart';
import 'package:asteria_app/features/sonnik/presentation/widgets/sonnik_layout.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUpAll(() async {
    for (final family in ['Lora', 'Onest']) {
      final loader = FontLoader(family)
        ..addFont(
          rootBundle.load(
            'assets/fonts/${family.toLowerCase()}/$family-VariableFont_wght.ttf',
          ),
        );
      await loader.load();
    }
  });
  for (final pro in [false, true]) {
    testWidgets(
      'intro stays beside Liveya and input remains usable with keyboard, PRO=$pro',
      (tester) async {
        await di.reset();
        final facade = _Analytics();
        final user = _User();
        final monetization = _Monetization(pro);
        di.registerSingleton<ContentProvider>(_Content());
        di.registerSingleton<GlobalLoaderService>(GlobalLoaderService());
        di.registerSingleton<AnalyticsFacade>(facade);
        di.registerSingleton<ProductAnalyticsService>(
          ProductAnalyticsService(facade),
        );
        addTearDown(() async {
          user.dispose();
          monetization.dispose();
          await di.reset();
        });
        tester.view.physicalSize = const Size(390, 844);
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);
        addTearDown(tester.view.resetViewInsets);
        await tester.pumpWidget(
          MultiProvider(
            providers: [
              ChangeNotifierProvider<UserProvider>.value(value: user),
              ChangeNotifierProvider<MonetizationProvider>.value(
                value: monetization,
              ),
            ],
            child: MaterialApp(
              locale: const Locale('ru'),
              localizationsDelegates: const [
                AppLocalizations.delegate,
                ...GlobalMaterialLocalizations.delegates,
              ],
              supportedLocales: AppLocaleService.supportedLocales,
              home: Builder(
                builder: (context) => Theme(
                  data: AppThemeDark.instance.getThemeData(context),
                  child: const CreateSonnikInitialScreen(),
                ),
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();
        final l10n = AppLocalizations.current;
        final prompt = find.text(l10n.dreamTellPrompt);
        final avatar = find.byType(SonnikLiveyaAvatar);
        expect(
          tester.getTopLeft(prompt).dx,
          lessThan(tester.getTopLeft(avatar).dx),
        );
        expect(
          tester.getTopLeft(prompt).dy,
          lessThan(tester.getBottomLeft(avatar).dy),
        );
        expect(
          tester.getTopLeft(find.byType(SonnikTextArea)).dy,
          lessThan(390),
        );
        expect(
          find.byType(SonnikQuotaBadge),
          pro ? findsNothing : findsOneWidget,
        );
        await tester.enterText(find.byType(TextField), 'Мне приснилось море');
        tester.view.viewInsets = const FakeViewPadding(bottom: 300);
        await tester.pumpAndSettle();
        await tester.ensureVisible(find.byType(SonnikGradientButton));
        await tester.pumpAndSettle();
        expect(
          tester.getBottomLeft(find.byType(SonnikGradientButton)).dy,
          lessThanOrEqualTo(544),
        );
        expect(
          tester.widget<TextField>(find.byType(TextField)).controller!.text,
          'Мне приснилось море',
        );
        expect(tester.takeException(), isNull);
        await tester.pumpWidget(const SizedBox());
      },
    );
  }
}

class _Content extends Fake implements ContentProvider {}

class _User extends ChangeNotifier implements UserProvider {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _Monetization extends ChangeNotifier implements MonetizationProvider {
  _Monetization(this.effectivePro);
  @override
  final bool effectivePro;
  @override
  int get balance => 1005;
  @override
  int requestsLeft(String feature) => 2;
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _Analytics extends Fake implements AnalyticsFacade {
  @override
  Future<void> trackEvent(String name, {Map<String, dynamic>? params}) async {}
}
