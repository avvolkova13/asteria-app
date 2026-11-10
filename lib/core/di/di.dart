import 'package:asteria_app/core/payments/apple/apple_purchase_coordinator.dart';
import 'package:asteria_app/core/payments/apple/apple_models.dart';
import 'package:asteria_app/core/payments/apple/apple_attempt_store.dart';
import 'package:asteria_app/core/payments/apple/apple_transactions.dart';
import 'package:flutter/material.dart';
import 'package:asteria_app/features/achievements/data/achievement_event_store.dart';
import 'package:asteria_app/features/achievements/data/achievement_recorder.dart';
import 'package:asteria_app/features/achievements/data/achievements_api.dart';
import 'package:asteria_app/features/compatibility/data/compatibility_selection_store.dart';
import 'dart:async';
import 'package:asteria_app/core/analytics/analytics_device_context.dart';
import 'dart:io' show Platform;

import 'package:asteria_app/app/data/repositories/app_settings/app_settings_repository.dart';
import 'package:asteria_app/app/data/repositories/content/content_repository.dart';
import 'package:asteria_app/app/data/repositories/lunar_calendar/personalized_lunar_calendar_repository.dart';
import 'package:asteria_app/app/data/repositories/user/user_profile_api.dart';
import 'package:asteria_app/app/data/repositories/user/user_repository.dart';
import 'package:asteria_app/app/providers/content_provider.dart';
import 'package:asteria_app/app/providers/user_provider.dart';
import 'package:asteria_app/core/environment/environment.dart';
import 'package:asteria_app/core/localization/app_locale_service.dart';
import 'package:asteria_app/core/location/city_search_service.dart';
import 'package:asteria_app/core/location/device_location_service.dart';
import 'package:asteria_app/core/payments/api/apple_payments_api.dart';
import 'package:asteria_app/core/payments/api/google_payments_api.dart';
import 'package:asteria_app/core/payments/api/store_payments_api.dart';
import 'package:asteria_app/core/payments/api/arc_pay_payments_api.dart';
import 'package:asteria_app/core/payments/api/arc_pay_subscriptions_api.dart';
import 'package:asteria_app/core/payments/routing/payment_provider_route.dart';
import 'package:asteria_app/core/payments/routing/google_play_country_service.dart';
import 'package:asteria_app/core/payments/routing/payment_return_link_service.dart';
import 'package:asteria_app/core/payments/gateway/store_kit_gateway.dart';
import 'package:asteria_app/core/payments/storage/arc_pay_pending_order_store.dart';
import 'package:asteria_app/core/payments/storage/arc_pay_pending_subscription_store.dart';
import 'package:asteria_app/core/payments/storage/pending_purchases_store.dart';
import 'package:asteria_app/core/routing/router.dart';
import 'package:asteria_app/core/services/api/backend_api.dart';
import 'package:asteria_app/core/services/api/open_ai_api.dart';
import 'package:asteria_app/core/services/content/content_version_service.dart';
import 'package:asteria_app/core/analytics/analytics_facade.dart';
import 'package:asteria_app/core/analytics/durable/analytics_store.dart';
import 'package:asteria_app/core/analytics/durable/analytics_app_version.dart';
import 'package:asteria_app/core/analytics/durable/analytics_transport.dart';
import 'package:asteria_app/core/analytics/durable/analytics_lifecycle.dart';
import 'package:asteria_app/core/analytics/durable/durable_analytics.dart';
import 'package:asteria_app/core/analytics/durable/native_checkout_analytics.dart';
import 'package:asteria_app/core/analytics/analytics_route_observer.dart';
import 'package:asteria_app/core/analytics/attribution/attribution_service.dart';
import 'package:asteria_app/core/analytics/product_analytics_service.dart';
import 'package:asteria_app/core/services/apps_flyer_service.dart';
import 'package:asteria_app/core/services/att_permission_service.dart';
import 'package:asteria_app/core/services/auth/auth_session_service.dart';
import 'package:asteria_app/core/services/global_loader_service.dart';
import 'package:asteria_app/core/services/hive/hive_service.dart';
import 'package:asteria_app/features/auth/data/datasources/auth_datasource.dart';
import 'package:asteria_app/features/auth/data/repositories/auth_repository.dart';
import 'package:asteria_app/features/auth/data/email_auth_api.dart';
import 'package:asteria_app/features/auth/data/email_auth_repository.dart';
import 'package:asteria_app/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:asteria_app/features/auth/presentation/cubit/email_auth_cubit.dart';
import 'package:asteria_app/features/balance/data/reward_event_store.dart';
import 'package:asteria_app/features/balance/data/reward_share_service.dart';
import 'package:asteria_app/features/balance/data/rewards_api.dart';
import 'package:asteria_app/features/monetization/data/feature_execution_api.dart';
import 'package:asteria_app/features/balance/presentation/provider/rewards_provider.dart';
import 'package:asteria_app/features/monetization/data/monetization_api.dart';
import 'package:asteria_app/features/monetization/data/pending_feature_execution_store.dart';
import 'package:asteria_app/features/monetization/presentation/monetization_provider.dart';
import 'package:asteria_app/features/subscription/presentation/cubit/paywall_cubit.dart';
import 'package:asteria_app/features/subscription/presentation/cubit/arc_pay_subscription_cubit.dart';
import 'package:asteria_app/features/payments/presentation/cubit/arc_pay_checkout_cubit.dart';
import 'package:asteria_app/features/compatibility/data/datasources/compatibility_datasource.dart';
import 'package:asteria_app/features/compatibility/domain/repositories/compatibility_repository.dart';
import 'package:asteria_app/features/compatibility/presentation/provider/compatibility_provider.dart';
import 'package:asteria_app/features/home/presentation/cubit/home_cubit.dart';
import 'package:asteria_app/features/home/presentation/cubit/moon_screen_cubit.dart';
import 'package:asteria_app/features/onboarding/presentation/bloc/onboarding_bloc.dart';
import 'package:asteria_app/features/shop/data/shop_datasource.dart';
import 'package:asteria_app/features/shop/domain/shop_repository.dart';
import 'package:asteria_app/features/shop/presentation/bloc/shop_bloc.dart';
import 'package:asteria_app/features/sonnik/presentation/provider/sonnik_provider.dart';
import 'package:asteria_app/features/anakra_chat/presentation/provider/anakra_chat_provider.dart';
import 'package:asteria_app/features/anakra_chat/data/services/anakra_chat_service.dart';
import 'package:asteria_app/features/splash/presentation/bloc/splash_bloc.dart';
import 'package:flutter/foundation.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';

final GetIt di = GetIt.instance;

class DiContainer {
  static Future<void> initialize({AppLocaleService? localeService}) async {
    if (!di.isRegistered<AppLocaleService>()) {
      di.registerSingleton<AppLocaleService>(
        localeService ?? (AppLocaleService()..startObserving()),
      );
    }
    // Инициализация Environment
    final environment = await Environment.initialize();
    di.registerSingleton<Environment>(environment);

    // Инициализация Hive
    await HiveService.initialize();

    // Имитация асинхронной инициализации

    // TODO: remove in production
    await Future.delayed(const Duration(seconds: 1));

    debugPrint('DI initialized');

    // Services
    di.registerLazySingleton<AuthSessionService>(
      () => BackendAuthSessionService(
        environment: di.get<Environment>(),
        onIdentityDeleted: (uid) async {
          final box = HiveService.appSettingsBox;
          final keys = box.keys
              .where(
                (key) =>
                    key is String && key.startsWith('social_pending:$uid:'),
              )
              .toList();
          await box.deleteAll(keys);
        },
      ),
    );
    di.registerSingleton<AnalyticsStore>(AnalyticsStore.deferred());
    final installedVersion = await readAnalyticsAppVersion();
    if (installedVersion == null) {
      await di.get<AnalyticsStore>().count('app_version_unavailable');
    }
    di.registerLazySingleton<AnalyticsTransport>(
      () => HttpAnalyticsTransport(
        baseUrl: environment.asteriaBackendUrl,
        apiKey: environment.asteriaApiKey,
      ),
    );
    di.registerLazySingleton<DurableAnalytics>(
      () => DurableAnalytics(
        store: di.get<AnalyticsStore>(),
        transport: di.get<AnalyticsTransport>(),
        currentUid: () => di.get<AuthSessionService>().currentUid,
        accessToken: (uid) =>
            di.get<AuthSessionService>().getAccessTokenForUid(uid),
        platform: Platform.isIOS ? 'ios' : 'android',
        appVersion: installedVersion ?? '',
        environment: const String.fromEnvironment(
          'ASTERIA_ANALYTICS_ENVIRONMENT',
          defaultValue: 'test',
        ),
        enabled: DurableAnalytics.buildEnabled && installedVersion != null,
        deviceContext: AnalyticsDeviceContext.read,
        onEventRecorded: (event) =>
            di.get<AnalyticsFacade>().trackRecordedEvent(event),
      ),
    );
    di.registerLazySingleton<AnalyticsLifecycle>(
      () => AnalyticsLifecycle(di.get<DurableAnalytics>()),
    );
    di.registerLazySingleton<BackendApi>(
      () => BackendApi(
        di.get<Environment>(),
        localeService: di.get<AppLocaleService>(),
      ),
    );
    di.registerLazySingleton<OpenAiApi>(() => OpenAiApi(di.get<BackendApi>()));
    di.registerLazySingleton<ContentVersionService>(
      () => ContentVersionService(
        api: di.get<BackendApi>(),
        localeService: di.get<AppLocaleService>(),
      ),
    );
    di.registerLazySingleton<ArcPayPaymentsApi>(
      () => ArcPayPaymentsApi(
        di.get<Environment>(),
        di.get<AuthSessionService>(),
      ),
    );
    di.registerLazySingleton<AppleStorefrontService>(
      () => StoreKitAppleStorefrontService(),
    );
    di.registerLazySingleton<GooglePlayCountryService>(
      () => BillingConfigGooglePlayCountryService(),
    );
    di.registerLazySingleton<PaymentProviderRouter>(
      () => PaymentProviderRouter(
        di.get<AppleStorefrontService>(),
        distributionChannel: DistributionChannelConfig.current,
        platform: defaultTargetPlatform,
        googlePlayCountry: di.get<GooglePlayCountryService>(),
        locationCountry: di.get<PaymentLocationCountryService>(),
      ),
    );
    di.registerLazySingleton<PaymentReturnLinkService>(
      () => PaymentReturnLinkService()..initialize(),
    );
    di.registerLazySingleton<ArcPaySubscriptionsApi>(
      () => ArcPaySubscriptionsApi(
        di.get<Environment>(),
        di.get<AuthSessionService>(),
      ),
    );
    di.registerLazySingleton<RewardsApi>(
      () => RewardsApi(di.get<Environment>(), di.get<AuthSessionService>()),
    );
    di.registerLazySingleton<MonetizationApi>(
      () =>
          MonetizationApi(di.get<Environment>(), di.get<AuthSessionService>()),
    );
    di.registerLazySingleton<FeatureExecutionApi>(
      () => FeatureExecutionApi(
        di.get<Environment>(),
        di.get<AuthSessionService>(),
      ),
    );
    di.registerLazySingleton<PendingFeatureExecutionStore>(
      () => PendingFeatureExecutionStore(),
    );
    di.registerLazySingleton<RewardEventStore>(() => RewardEventStore());
    di.registerLazySingleton<RewardShareService>(
      () => const RewardShareService(),
    );

    // Payments: iOS StoreKit and Android Arc Pay are separate flows.
    di.registerLazySingleton<ApplePaymentsApi>(
      () =>
          ApplePaymentsApi(di.get<Environment>(), di.get<AuthSessionService>()),
    );
    if (Platform.isAndroid) {
      di.registerLazySingleton<StorePaymentsApi>(
        () => GooglePaymentsApi(
          di.get<Environment>(),
          di.get<AuthSessionService>(),
        ),
      );
    }
    di.registerLazySingleton<PendingPurchasesStore>(
      () => PendingPurchasesStore(),
    );
    di.registerLazySingleton<StoreBillingGateway>(() => StoreBillingGateway());
    di.registerLazySingleton<ArcPayPendingOrderStore>(
      () => ArcPayPendingOrderStore(),
    );
    di.registerLazySingleton<ArcPayPendingSubscriptionStore>(
      () => ArcPayPendingSubscriptionStore(),
    );
    di.registerLazySingleton<ApplePurchaseCoordinator>(() {
      final session = di.get<AuthSessionService>();
      final user = di.get<UserProvider>();
      return ApplePurchaseCoordinator(
        native: StoreKitAppleTransactions(),
        api: di.get<ApplePaymentsApi>(),
        journal: di.get<PendingPurchasesStore>(),
        attempts: AppleAttemptStore(HiveService.appSettingsBox),
        currentIdentity: () => AppleIdentity(
          user.currentUser?.id == session.currentUid &&
                  (session is! SessionIdentityVersion ||
                      (session as SessionIdentityVersion).identityReady)
              ? session.currentUid
              : null,
          session is SessionIdentityVersion
              ? (session as SessionIdentityVersion).identityVersion
              : session.currentUid ?? '',
        ),
        identityChanges: Listenable.merge([
          user,
          if (session is Listenable) session as Listenable,
        ]),
        updates: di
            .get<StoreBillingGateway>()
            .purchaseUpdates
            .where(
              (update) =>
                  update.result.signedTransactionJws?.isNotEmpty == true,
            )
            .map(
              (update) =>
                  AppleReceipt.fromJws(update.result.signedTransactionJws!),
            ),
        refreshEntitlements: (identity, isCurrent) => di
            .get<MonetizationProvider>()
            .refreshAppleEntitlements(identity.uid!, isCurrent: isCurrent),
        analyticsContext: di.get<DurableAnalytics>().checkoutContext,
      );
    });
    // PaywallCubit — factory so each paywall screen gets a fresh state machine.
    di.registerFactory<PaywallCubit>(() {
      final cubit = PaywallCubit(
        storeGateway: di.get<StoreBillingGateway>(),
        storePaymentsApi: Platform.isAndroid
            ? di.get<StorePaymentsApi>()
            : null,
        appleCoordinator: Platform.isIOS
            ? di.get<ApplePurchaseCoordinator>()
            : null,
        pendingPurchasesStore: di.get<PendingPurchasesStore>(),
        monetizationProvider: di.get<MonetizationProvider>(),
        authSession: di.get<AuthSessionService>(),
        analyticsContext: di.get<DurableAnalytics>().checkoutContext,
      );
      cubit.stream.listen(
        NativeCheckoutAnalytics(di.get<AnalyticsFacade>()).onState,
      );
      return cubit;
    });
    di.registerFactory<ArcPaySubscriptionCubit>(
      () => ArcPaySubscriptionCubit(
        api: di.get<ArcPaySubscriptionsApi>(),
        store: di.get<ArcPayPendingSubscriptionStore>(),
        currentUserId: () => di.get<AuthSessionService>().currentUid,
        refreshUser: di.get<MonetizationProvider>().refresh,
      ),
    );
    di.registerFactory<ArcPayCheckoutCubit>(
      () => ArcPayCheckoutCubit(
        api: di.get<ArcPayPaymentsApi>(),
        analyticsContext: di.get<DurableAnalytics>().checkoutContext,
        store: di.get<ArcPayPendingOrderStore>(),
        currentUserId: () => di.get<AuthSessionService>().currentUid,
        refreshUser: di.get<MonetizationProvider>().refresh,
        platform: Platform.isIOS ? 'ios' : 'android',
      ),
    );

    di.registerLazySingleton<GlobalLoaderService>(() => GlobalLoaderService());
    di.registerLazySingleton<AppsFlyerService>(
      () => AppsFlyerService(di.get<Environment>()),
    );
    di.registerLazySingleton<AttPermissionService>(
      () => AttPermissionService(),
    );
    di.registerLazySingleton<DeviceLocationService>(
      () => const DeviceLocationService(),
    );
    di.registerLazySingleton<CitySearchService>(
      () => CitySearchService(
        googleMapsApiKey: di.get<Environment>().googleMapsApiKey,
      ),
    );
    di.registerLazySingleton<AttributionService>(
      () => AttributionService(
        di.get<AppsFlyerService>(),
        analytics: di.get<DurableAnalytics>(),
      ),
    );
    di.registerLazySingleton<AnalyticsRouteObserver>(
      () => AnalyticsRouteObserver(),
    );

    // App Settings Repository
    di.registerLazySingleton<AppSettingsRepository>(
      () => AppSettingsRepositoryImpl(),
    );

    // User Repository
    di.registerLazySingleton<UserProfileApi>(
      () => UserProfileApi(di.get<Environment>(), di.get<AuthSessionService>()),
    );
    di.registerLazySingleton<UserRepository>(
      () => UserRepositoryImpl(
        profileApi: di.get<UserProfileApi>(),
        authSessionService: di.get<AuthSessionService>(),
      ),
    );

    // User Provider
    di.registerLazySingleton<UserProvider>(
      () => UserProvider(
        userRepository: di.get<UserRepository>(),
        authSessionService: di.get<AuthSessionService>(),
      ),
    );
    di.registerLazySingleton<PaymentLocationCountryService>(
      () => UserProviderPaymentLocationCountryService(di.get<UserProvider>()),
    );
    di.registerLazySingleton<MonetizationProvider>(
      () => MonetizationProvider(
        api: di.get<MonetizationApi>(),
        userProvider: di.get<UserProvider>(),
        pendingStore: di.get<PendingFeatureExecutionStore>(),
      ),
    );
    di.registerLazySingleton<RewardsProvider>(
      () => RewardsProvider(
        api: di.get<RewardsApi>(),
        store: di.get<RewardEventStore>(),
        shareService: di.get<RewardShareService>(),
        userProvider: di.get<UserProvider>(),
        monetizationProvider: di.get<MonetizationProvider>(),
      ),
    );

    // Analytics Facade — depends on AppsFlyer + Attribution + UserProvider
    di.registerLazySingleton<AnalyticsFacade>(
      () => AnalyticsFacade(
        appsFlyerService: di.get<AppsFlyerService>(),
        durableAnalytics: di.get<DurableAnalytics>(),
        visibleScreen: () => di.get<AnalyticsRouteObserver>().visibleScreen,
        isSourceVisible: (source) {
          final screen = di.get<AnalyticsRouteObserver>().visibleScreen;
          if (source == 'moon_day_view') return screen == '/home/moon';
          if (source == 'ast_moon_start') {
            return screen == '/home/moon' || screen == '/horoscope';
          }
          return true;
        },
      ),
    );

    // Product Analytics Service — typed ast_* events, wraps AnalyticsFacade
    di.registerLazySingleton<ProductAnalyticsService>(
      () => ProductAnalyticsService(di.get<AnalyticsFacade>()),
    );

    // Content Repository
    di.registerLazySingleton<ContentRepository>(
      () => ContentRepositoryImpl(
        openAiApi: di.get<OpenAiApi>(),
        backendApi: di.get<BackendApi>(),
        contentVersionService: di.get<ContentVersionService>(),
        localeService: di.get<AppLocaleService>(),
      ),
    );
    di.registerLazySingleton<PersonalizedLunarCalendarRepository>(
      () => PersonalizedLunarCalendarRepositoryImpl(api: di.get<BackendApi>()),
    );

    di.registerLazySingleton<AchievementEventStore>(
      () => AchievementEventStore(),
    );
    di.registerLazySingleton<AchievementsApi>(
      () => AchievementsApi(environment, di.get<AuthSessionService>()),
    );
    di.registerLazySingleton<AchievementRecorder>(
      () => AchievementRecorder(
        api: di.get<AchievementsApi>(),
        store: di.get<AchievementEventStore>(),
        userProvider: di.get<UserProvider>(),
      ),
      dispose: (recorder) => recorder.dispose(),
    );

    // Content Provider
    di.registerLazySingleton<ContentProvider>(
      () => ContentProvider(
        achievementRecorder: di.get<AchievementRecorder>(),
        contentRepository: di.get<ContentRepository>(),
        userProvider: di.get<UserProvider>(),
        monetizationProvider: di.get<MonetizationProvider>(),
        backendApi: di.get<BackendApi>(),
        localeService: di.get<AppLocaleService>(),
      ),
    );

    // Shop Data Layer
    di.registerLazySingleton<ShopDataSource>(
      () => ShopDataSourceImpl(api: di.get<BackendApi>()),
    );

    // Shop Domain Layer
    di.registerLazySingleton<ShopRepository>(
      () => ShopRepositoryImpl(dataSource: di.get<ShopDataSource>()),
    );

    // Auth Data Layer
    di.registerLazySingleton<AuthDataSource>(
      () => AuthDataSourceImpl(userProfileApi: di.get<UserProfileApi>()),
    );

    // Auth Domain Layer
    di.registerLazySingleton<AuthRepository>(
      () => AuthRepositoryImpl(di.get<AuthDataSource>(), di.get<BackendApi>()),
    );
    di.registerLazySingleton<EmailAuthApi>(
      () => EmailAuthApi(di.get<Environment>()),
    );
    di.registerLazySingleton<EmailAuthRepository>(
      () => EmailAuthRepositoryImpl(di.get<EmailAuthApi>()),
    );

    // Compatibility Data Layer
    di.registerLazySingleton<CompatibilityDataSource>(
      () => CompatibilityDataSourceImpl(api: di.get<BackendApi>()),
    );

    // Compatibility Domain Layer
    di.registerLazySingleton<CompatibilityRepository>(
      () => CompatibilityRepositoryImpl(
        dataSource: di.get<CompatibilityDataSource>(),
      ),
    );

    // Auth Cubit
    di.registerLazySingleton<AuthCubit>(
      () => AuthCubit(
        authRepository: di.get<AuthRepository>(),
        userRepository: di.get<UserRepository>(),
        userProvider: di.get<UserProvider>(),
        globalLoaderService: di.get<GlobalLoaderService>(),
      ),
    );
    di.registerFactory<EmailAuthCubit>(
      () => EmailAuthCubit(
        repository: di.get<EmailAuthRepository>(),
        sessionService: di.get<AuthSessionService>(),
        userRepository: di.get<UserRepository>(),
        userProvider: di.get<UserProvider>(),
        analytics: di.get<AnalyticsFacade>(),
        productAnalytics: di.get<ProductAnalyticsService>(),
        appsFlyer: di.get<AppsFlyerService>(),
        attribution: di.get<AttributionService>(),
      ),
    );
    di.registerLazySingleton<OnboardingBloc>(
      () => OnboardingBloc(di.get<AppSettingsRepository>()),
    );
    di.registerLazySingleton<SplashBloc>(
      () => SplashBloc(
        userRepository: di.get<UserRepository>(),
        appSettingsRepository: di.get<AppSettingsRepository>(),
        authSessionService: di.get<AuthSessionService>(),
      ),
    );
    di.registerLazySingleton<HomeCubit>(
      () => HomeCubit(
        userRepository: di.get<UserRepository>(),
        userProvider: di.get<UserProvider>(),
        contentProvider: di.get<ContentProvider>(),
      ),
    );
    di.registerFactory<MoonScreenCubit>(() => MoonScreenCubit());
    di.registerLazySingleton<ShopBloc>(
      () => ShopBloc(
        shopRepository: di.get<ShopRepository>(),
        monetizationProvider: di.get<MonetizationProvider>(),
      ),
    );
    di.registerLazySingleton<CompatibilityProvider>(
      () => CompatibilityProvider(
        userProvider: di.get<UserProvider>(),
        store: HiveCompatibilitySelectionStore(HiveService.appSettingsBox),
      ),
    );
    di.registerLazySingleton<SonnikProvider>(() => SonnikProvider());
    di.registerLazySingleton<AnakraChatService>(
      () => AnakraChatService(
        di.get<BackendApi>(),
        localeService: di.get<AppLocaleService>(),
      ),
    );
    di.registerLazySingleton<AnakraChatProvider>(
      () => AnakraChatProvider(
        chatService: di.get<AnakraChatService>(),
        userProvider: di.get<UserProvider>(),
        monetizationProvider: di.get<MonetizationProvider>(),
        localeService: di.get<AppLocaleService>(),
      ),
    );
  }

  static void registerRouter(String initialLocation) {
    if (!di.isRegistered<GoRouter>()) {
      di.registerSingleton<GoRouter>(AppRouter.getRouter(initialLocation));
    }
  }
}

class UserProviderPaymentLocationCountryService
    implements PaymentLocationCountryService {
  final UserProvider _userProvider;
  final StreamController<String?> _controller =
      StreamController<String?>.broadcast();

  UserProviderPaymentLocationCountryService(this._userProvider) {
    _userProvider.addListener(_emitCurrentCountry);
  }

  @override
  Future<String?> currentCountryCode() async =>
      _userProvider.currentUser?.currentLocation?.countryCode;

  @override
  Stream<String?> get countryCodeUpdates => _controller.stream;

  void _emitCurrentCountry() {
    _controller.add(_userProvider.currentUser?.currentLocation?.countryCode);
  }
}
