import 'package:asteria_app/core/analytics/analytics_facade.dart';
import 'package:asteria_app/core/analytics/product_analytics_service.dart';
import 'package:asteria_app/core/di/di.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:asteria_app/core/ui_kit/widgets/modal_glass_surface.dart';
import 'package:asteria_app/app/data/models/shop_item/shop_item_model.dart';
import 'package:asteria_app/app/data/models/user/user_model.dart';
import 'package:asteria_app/app/data/repositories/user/user_repository.dart';
import 'package:asteria_app/app/providers/user_provider.dart';
import 'package:asteria_app/core/localization/localization.dart';
import 'package:asteria_app/core/services/auth/auth_session_service.dart';
import 'package:asteria_app/core/ui_kit/theme/theme.dart';
import 'package:asteria_app/features/monetization/data/monetization_api.dart';
import 'package:asteria_app/features/monetization/domain/monetization_models.dart';
import 'package:asteria_app/features/monetization/presentation/monetization_provider.dart';
import 'package:asteria_app/features/shop/presentation/widgets/purchase_modal_sheet.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late UserProvider userProvider;
  late MonetizationProvider monetizationProvider;

  setUp(() async {
    userProvider = UserProvider(
      userRepository: _FakeUserRepository(),
      authSessionService: _FakeSession(),
    )..applyServerUserSnapshot(UserModel.empty().copyWith(id: 'user-1'));
    monetizationProvider = MonetizationProvider(
      api: _FakeMonetizationApi(_state(balance: 230)),
      userProvider: userProvider,
    );
    await monetizationProvider.ensureLoaded();
  });

  tearDown(() {
    userProvider.dispose();
    monetizationProvider.dispose();
  });

  testWidgets('shows the compact purchase on a dark glass surface', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(390, 844));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      ChangeNotifierProvider<MonetizationProvider>.value(
        value: monetizationProvider,
        child: MaterialApp(
          locale: const Locale('ru'),
          localizationsDelegates: const [
            AppLocalizations.delegate,
            ...GlobalMaterialLocalizations.delegates,
          ],
          supportedLocales: AppLocaleService.supportedLocales,
          home: Builder(
            builder: (context) => Theme(
              data: AppThemeLight.instance.getThemeData(context),
              child: const Scaffold(
                body: PurchaseModalSheet(
                  product: ShopItemModel(
                    id: 'love-layout',
                    title: 'Любовный расклад',
                    category: 'Таро',
                    description: 'Расклад о любви',
                    price: 6,
                  ),
                  onConfirm: _noop,
                ),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    final surface = find.byType(ModalGlassSurface);
    expect(tester.getSize(surface).height, 329);
    expect(
      tester.widget<ModalGlassSurface>(surface).color,
      ModalGlassTokens.surface,
    );
    expect(
      find.descendant(of: surface, matching: find.byType(BackdropFilter)),
      findsOneWidget,
    );

    expect(
      tester.getTopLeft(find.text('Сколько хотите купить?')).dy,
      lessThan(tester.getTopLeft(find.text('цена за 1 = 6')).dy),
    );
  });
  testWidgets(
    'large text fits a long item and the resulting balance after buying on a compact phone',
    (tester) async {
      tester.view.devicePixelRatio = 1;
      tester.view.physicalSize = const Size(320, 568);
      tester.view.padding = const FakeViewPadding(top: 24, bottom: 20);
      addTearDown(tester.view.reset);
      await tester.runAsync(() async {
        for (final font in [
          ('Lora', 'assets/fonts/lora/Lora-VariableFont_wght.ttf'),
          ('Onest', 'assets/fonts/onest/Onest-VariableFont_wght.ttf'),
        ]) {
          await (FontLoader(font.$1)..addFont(rootBundle.load(font.$2))).load();
        }
      });
      di.registerSingleton<ProductAnalyticsService>(
        ProductAnalyticsService(_NoopAnalytics()),
      );
      addTearDown(() => di.unregister<ProductAnalyticsService>());
      var confirmed = 0;
      const title = 'Любовный расклад на отношения с близким человеком';
      await tester.pumpWidget(
        ChangeNotifierProvider<MonetizationProvider>.value(
          value: monetizationProvider,
          child: MaterialApp(
            locale: const Locale('ru'),
            localizationsDelegates: const [
              AppLocalizations.delegate,
              ...GlobalMaterialLocalizations.delegates,
            ],
            supportedLocales: AppLocaleService.supportedLocales,
            builder: (context, child) => Theme(
              data: AppThemeLight.instance.getThemeData(context),
              child: MediaQuery(
                data: MediaQuery.of(
                  context,
                ).copyWith(textScaler: TextScaler.linear(1.8)),
                child: child!,
              ),
            ),
            home: Scaffold(
              body: Builder(
                builder: (context) => TextButton(
                  onPressed: () => showModalBottomSheet<void>(
                    context: context,
                    isScrollControlled: true,
                    backgroundColor: Colors.transparent,
                    builder: (_) => PurchaseModalSheet(
                      product: const ShopItemModel(
                        id: 'love-layout',
                        title: title,
                        category: 'Таро',
                        description: 'Расклад о любви',
                        price: 6,
                      ),
                      onConfirm: () => confirmed++,
                    ),
                  ),
                  child: const Text('Open'),
                ),
              ),
            ),
          ),
        ),
      );
      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();
      void expectFullLabels() {
        for (final rich
            in find
                .descendant(
                  of: find.byType(ModalGlassSurface),
                  matching: find.byType(RichText),
                )
                .evaluate()) {
          final paragraph = rich.renderObject! as RenderParagraph;
          expect(
            paragraph.didExceedMaxLines,
            isFalse,
            reason: paragraph.text.toPlainText(),
          );
        }
        expect(tester.takeException(), isNull);
      }

      expect(find.text(title), findsOneWidget);
      expectFullLabels();
      final increase = find.bySemanticsLabel('Увеличить количество');
      await tester.ensureVisible(increase);
      await tester.pumpAndSettle();
      expect(tester.getSize(increase).shortestSide, greaterThanOrEqualTo(44));
      await tester.tap(increase);
      await tester.pumpAndSettle();
      expect(find.text('2'), findsOneWidget);
      final buy = find.text('Купить');
      await tester.ensureVisible(buy);
      await tester.pumpAndSettle();
      expect(buy.hitTestable(), findsOneWidget);
      await tester.tap(buy);
      await tester.pumpAndSettle();
      expect(confirmed, 1);
      expect(monetizationProvider.balance, 218);
      final scroll = find.descendant(
        of: find.byType(ModalGlassSurface),
        matching: find.byType(Scrollable),
      );
      expect(tester.state<ScrollableState>(scroll).position.pixels, 0);
      expect(
        tester.getRect(find.text('Покупка завершена')).top,
        greaterThanOrEqualTo(tester.getRect(scroll).top),
      );
      expectFullLabels();
      final done = find.text('Продолжить');
      await tester.ensureVisible(done);
      await tester.pumpAndSettle();
      expect(done.hitTestable(), findsOneWidget);
      await tester.tap(done);
      await tester.pumpAndSettle();
      expect(find.byType(ModalGlassSurface), findsNothing);
    },
  );
}

void _noop() {}

MonetizationStateModel _state({required int balance}) {
  final now = DateTime.parse('2026-09-09T12:00:00Z');
  return MonetizationStateModel(
    uid: 'user-1',
    catalogRevision: 1,
    wallet: WalletSnapshotModel(
      uid: 'user-1',
      balance: balance,
      debt: 0,
      sequence: balance,
      version: balance,
      updatedAt: now,
    ),
    effectivePro: false,
    effectiveGrants: const [],
    rewards: const [],
    requestQuotas: const {},
    rolloutPolicy: const {},
  );
}

class _FakeMonetizationApi extends MonetizationApi {
  _FakeMonetizationApi(this.state) : super.forDio(Dio(), _FakeSession());

  final MonetizationStateModel state;

  @override
  Future<MonetizationStateModel> getCurrent() async => state;
  @override
  Future<RequestQuotaPurchaseResultModel> purchaseShopRequestPack({
    required String productId,
    required int quantity,
    required int expectedPrice,
    required String idempotencyKey,
  }) async => RequestQuotaPurchaseResultModel(
    feature: 'tarot',
    quantity: quantity,
    price: expectedPrice,
    replayed: false,
    wallet: _state(balance: state.wallet.balance - expectedPrice).wallet,
    quota: RequestQuotaModel.fromJson({
      'feature': 'tarot',
      'paid_remaining': quantity,
    }),
  );
}

class _FakeUserRepository implements UserRepository {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _FakeSession implements AuthSessionService {
  @override
  String? get currentEmail => 'user@example.com';

  @override
  String? get currentUid => 'user-1';

  @override
  bool get hasRecentSignIn => true;

  @override
  bool get hasSession => true;

  @override
  Future<String?> getAccessToken({bool forceRefresh = false}) async =>
      'access-token';

  Future<String?> getAccessTokenForUid(
    String expectedUid, {
    bool forceRefresh = false,
  }) async => expectedUid == currentUid ? 'access-token' : null;

  @override
  Future<void> deleteCurrentIdentity() async {}

  @override
  Future<void> saveSession({
    required String uid,
    required String? email,
    required String accessToken,
    required String refreshToken,
    required int expiresIn,
  }) async {}

  Future<void> clear() async {}

  @override
  Future<void> signOut() async {}
}

class _NoopAnalytics implements AnalyticsFacade {
  @override
  Future<void> trackEvent(String name, {Map<String, dynamic>? params}) async {}
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}
