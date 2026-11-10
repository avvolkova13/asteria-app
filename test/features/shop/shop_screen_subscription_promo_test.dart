import 'package:asteria_app/app/data/models/saved_compatibility/saved_compatibility_model.dart';
import 'package:asteria_app/app/data/models/shop_item/shop_item_model.dart';
import 'package:asteria_app/app/data/models/user/user_model.dart';
import 'package:asteria_app/app/data/repositories/user/user_repository.dart';
import 'package:asteria_app/app/providers/user_provider.dart';
import 'package:asteria_app/core/analytics/analytics_facade.dart';
import 'package:asteria_app/core/analytics/product_analytics_service.dart';
import 'package:asteria_app/core/di/di.dart';
import 'package:asteria_app/core/localization/localization.dart';
import 'package:asteria_app/core/routing/app_route.dart';
import 'package:asteria_app/core/services/auth/auth_session_service.dart';
import 'package:asteria_app/core/ui_kit/theme/theme.dart';
import 'package:asteria_app/features/monetization/data/monetization_api.dart';
import 'package:asteria_app/features/monetization/domain/monetization_models.dart';
import 'package:asteria_app/features/monetization/presentation/monetization_provider.dart';
import 'package:asteria_app/features/shop/domain/shop_repository.dart';
import 'package:asteria_app/features/shop/presentation/bloc/shop_bloc.dart';
import 'package:asteria_app/features/shop/presentation/shop_screen.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  tearDown(() async {
    await di.reset();
  });

  testWidgets('shows reusable PRO promo in shop for non-PRO users', (
    tester,
  ) async {
    Object? subscriptionExtra;

    await tester.binding.setSurfaceSize(const Size(390, 840));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      await _shopApp(
        effectivePro: false,
        onSubscriptionRoute: (extra) => subscriptionExtra = extra,
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byKey(const ValueKey('home-pro-subscription-card')), findsOne);
    expect(find.text('Больше знаков\nот звёзд'), findsOneWidget);
    expect(find.text('Попробовать 7 дней бесплатно'), findsOneWidget);

    await tester.ensureVisible(find.text('Попробовать 7 дней бесплатно'));
    await tester.tap(find.text('Попробовать 7 дней бесплатно'));
    await tester.pumpAndSettle();

    expect(find.text('subscription destination'), findsOneWidget);
    expect(subscriptionExtra, isA<SubscriptionRouteParams>());
    expect(
      (subscriptionExtra as SubscriptionRouteParams).originSurface,
      'shop_pro_promo_card',
    );
  });

  testWidgets('hides shop PRO promo for active PRO users', (tester) async {
    await tester.binding.setSurfaceSize(const Size(390, 840));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(await _shopApp(effectivePro: true));
    await tester.pumpAndSettle();

    expect(
      find.byKey(const ValueKey('home-pro-subscription-card')),
      findsNothing,
    );
  });

  testWidgets(
    'uses current year animal image for products without explicit image',
    (tester) async {
      await tester.binding.setSurfaceSize(const Size(390, 840));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      await tester.pumpWidget(
        await _shopApp(
          effectivePro: true,
          products: const [
            ShopItemModel(
              id: 'new-shop-pack',
              title: 'Новый товар',
              category: 'Запросы',
              description: 'Пакет запросов',
              price: 7,
            ),
          ],
        ),
      );
      await tester.pumpAndSettle();

      final assetNames = tester
          .widgetList<Image>(find.byType(Image))
          .map(_assetName)
          .whereType<String>()
          .toSet();
      final animalImage = tester.widget<Image>(
        find.byWidgetPredicate(
          (widget) =>
              widget is Image &&
              _assetName(widget) == _currentYearAnimalAsset(),
        ),
      );

      expect(assetNames, contains(_currentYearAnimalAsset()));
      expect(assetNames, isNot(contains('assets/icons/ai_astrologer.png')));
      expect(animalImage.alignment, Alignment.topCenter);
    },
  );

  testWidgets('uses top aligned Anakra image for Anakra products', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(390, 840));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      await _shopApp(
        effectivePro: true,
        products: const [
          ShopItemModel(
            id: UserProvider.shopItemAnakraId,
            title: 'Вопрос Анакре',
            category: 'Запросы',
            description: 'узнай свой путь',
            price: 10,
          ),
        ],
      ),
    );
    await tester.pumpAndSettle();

    final anakraImage = tester.widget<Image>(
      find.byWidgetPredicate(
        (widget) =>
            widget is Image &&
            _assetName(widget) == 'assets/images/shop/shop_ai_astrologer.webp',
      ),
    );

    expect(anakraImage.fit, BoxFit.cover);
    expect(anakraImage.alignment, Alignment.topCenter);
  });

  testWidgets('uses former Sonnik image for Love Deck products', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(390, 840));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      await _shopApp(
        effectivePro: true,
        products: const [
          ShopItemModel(
            id: '464ef852-f767-49f1-b8d7-724f188f90c4',
            title: 'Любовный расклад',
            category: 'Таро',
            description: 'Расклад таро о любви',
            price: 10,
          ),
        ],
      ),
    );
    await tester.pumpAndSettle();

    final loveDeckImageFinder = find.byWidgetPredicate(
      (widget) =>
          widget is Image &&
          _assetName(widget) == 'assets/images/shop/shop_love_deck.webp',
    );

    expect(loveDeckImageFinder, findsOneWidget);
    final loveDeckImage = tester.widget<Image>(loveDeckImageFinder);
    expect(loveDeckImage.fit, BoxFit.contain);
    expect(loveDeckImage.alignment, Alignment.topCenter);
  });

  testWidgets('uses default year animal image for Sonnik products', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(390, 840));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      await _shopApp(
        effectivePro: true,
        products: const [
          ShopItemModel(
            id: UserProvider.shopItemSonnikId,
            title: 'Вопросы к соннику',
            category: 'Запросы',
            description: 'Толкование сна',
            price: 7,
          ),
        ],
      ),
    );
    await tester.pumpAndSettle();

    final assetNames = tester
        .widgetList<Image>(find.byType(Image))
        .map(_assetName)
        .whereType<String>()
        .toSet();

    expect(assetNames, contains(_currentYearAnimalAsset()));
    expect(
      assetNames,
      isNot(contains('assets/images/shop/shop_love_deck.webp')),
    );
  });
}

Future<Widget> _shopApp({
  required bool effectivePro,
  List<ShopItemModel> products = const [
    ShopItemModel(
      id: UserProvider.shopItemSonnikId,
      title: 'Сонник',
      category: 'Запросы',
      description: 'Пакет запросов',
      price: 7,
    ),
  ],
  ValueChanged<Object?>? onSubscriptionRoute,
}) async {
  final userProvider = UserProvider(
    userRepository: _FakeUserRepository(),
    authSessionService: _FakeSession(),
  )..applyServerUserSnapshot(UserModel.empty().copyWith(id: 'user-1'));
  final monetizationProvider = MonetizationProvider(
    api: _FakeMonetizationApi(_state(effectivePro: effectivePro)),
    userProvider: userProvider,
  );
  await monetizationProvider.ensureLoaded();
  final shopBloc = ShopBloc(
    shopRepository: _FakeShopRepository(products),
    monetizationProvider: monetizationProvider,
  );
  final analytics = _RecordingAnalyticsFacade();

  di.registerSingleton<AnalyticsFacade>(analytics);
  di.registerSingleton<ProductAnalyticsService>(
    ProductAnalyticsService(analytics),
  );
  di.registerSingleton<ShopBloc>(shopBloc, dispose: (bloc) => bloc.close());

  final router = GoRouter(
    initialLocation: ShopRoute.routeName,
    routes: [
      GoRoute(
        path: ShopRoute.routeName,
        name: ShopRoute.routeName,
        builder: (context, state) => MultiProvider(
          providers: [
            ChangeNotifierProvider<UserProvider>.value(value: userProvider),
            ChangeNotifierProvider<MonetizationProvider>.value(
              value: monetizationProvider,
            ),
          ],
          child: BlocProvider<ShopBloc>.value(
            value: shopBloc,
            child: const ShopScreen(),
          ),
        ),
      ),
      GoRoute(
        path: SubscriptionRoute.routeName,
        name: SubscriptionRoute.routeName,
        builder: (context, state) {
          onSubscriptionRoute?.call(state.extra);
          return const Scaffold(body: Text('subscription destination'));
        },
      ),
    ],
  );

  return MaterialApp.router(
    locale: const Locale('ru'),
    localizationsDelegates: const [
      AppLocalizations.delegate,
      ...GlobalMaterialLocalizations.delegates,
    ],
    supportedLocales: AppLocaleService.supportedLocales,
    routerConfig: router,
    builder: (context, child) {
      return Theme(
        data: AppThemeDark.instance.getThemeData(context),
        child: child ?? const SizedBox.shrink(),
      );
    },
  );
}

String? _assetName(Image image) {
  final provider = image.image;
  if (provider is AssetImage) return provider.assetName;
  if (provider is ResizeImage && provider.imageProvider is AssetImage) {
    return (provider.imageProvider as AssetImage).assetName;
  }
  return null;
}

String _currentYearAnimalAsset() {
  const assetsByCycleIndex = [
    'assets/images/year_animals/rat.webp',
    'assets/images/year_animals/ox.webp',
    'assets/images/year_animals/tiger.webp',
    'assets/images/year_animals/rabbit.webp',
    'assets/images/year_animals/dragon.webp',
    'assets/images/year_animals/snake.webp',
    'assets/images/year_animals/horse.webp',
    'assets/images/year_animals/goat.webp',
    'assets/images/year_animals/monkey.webp',
    'assets/images/year_animals/rooster.webp',
    'assets/images/year_animals/dog.webp',
    'assets/images/year_animals/pig.webp',
  ];
  return assetsByCycleIndex[(DateTime.now().year - 4) %
      assetsByCycleIndex.length];
}

MonetizationStateModel _state({required bool effectivePro}) {
  final now = DateTime.parse('2026-09-06T12:00:00Z');
  return MonetizationStateModel(
    uid: 'user-1',
    catalogRevision: 1,
    wallet: WalletSnapshotModel(
      uid: 'user-1',
      balance: 0,
      debt: 0,
      sequence: 0,
      version: 0,
      updatedAt: now,
    ),
    effectivePro: effectivePro,
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
}

class _FakeShopRepository implements ShopRepository {
  const _FakeShopRepository(this.products);

  final List<ShopItemModel> products;

  @override
  Future<List<ShopItemModel>> getShopItems() async => products;
}

class _RecordingAnalyticsFacade implements AnalyticsFacade {
  @override
  Future<void> trackEvent(String name, {Map<String, dynamic>? params}) async {}

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

  @override
  Future<void> signOut() async {}
}

class _FakeUserRepository implements UserRepository {
  @override
  Future<void> addCompatibilityToHistory(
    SavedCompatibilityModel compatibility,
  ) async {}

  @override
  Future<void> clearCurrentUser() async {}

  @override
  Future<void> deleteUser(String userId) async {}

  @override
  Future<UserModel?> getCurrentUser() async => null;

  @override
  Stream<UserModel?> getMe() => const Stream.empty();

  @override
  Future<UserModel?> getUserById(String userId) async => null;

  @override
  Future<void> setCurrentUser(UserModel user) async {}

  @override
  Future<void> updateCurrentUser(UserModel user) async {}

  @override
  Future<void> updateUserShopItems(
    String userId,
    List<ShopItemModel> shopItems,
  ) async {}
}
