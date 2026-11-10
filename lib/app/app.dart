import 'package:asteria_app/core/payments/apple/apple_purchase_coordinator.dart';
import 'dart:async';
import 'dart:io' show Platform;

import 'package:asteria_app/core/analytics/durable/durable_analytics.dart';
import 'package:asteria_app/core/analytics/durable/analytics_lifecycle.dart';

import 'package:asteria_app/app/app_startup_content_warmup.dart';
import 'package:asteria_app/app/providers/content_provider.dart';
import 'package:asteria_app/app/providers/user_provider.dart';
import 'package:asteria_app/features/monetization/presentation/monetization_provider.dart';
import 'package:asteria_app/features/anakra_chat/presentation/provider/anakra_chat_provider.dart';
import 'package:asteria_app/core/analytics/analytics_facade.dart';
import 'package:asteria_app/core/analytics/attribution/attribution_service.dart';
import 'package:asteria_app/core/analytics/product_analytics_service.dart';
import 'package:asteria_app/core/di/di.dart';
import 'package:asteria_app/core/localization/app_locale_service.dart';
import 'package:asteria_app/core/localization/generated/l10n.dart';
import 'package:asteria_app/core/payments/api/store_payments_api.dart';
import 'package:asteria_app/core/payments/gateway/store_kit_gateway.dart';
import 'package:asteria_app/core/payments/storage/pending_purchases_store.dart';
import 'package:asteria_app/core/payments/recovery/google_purchase_recovery.dart';
import 'package:asteria_app/core/payments/routing/payment_return_link_service.dart';
import 'package:asteria_app/core/routing/initial_route_resolver.dart';
import 'package:asteria_app/core/services/apps_flyer_service.dart';
import 'package:asteria_app/core/services/auth/auth_session_service.dart';
import 'package:asteria_app/core/services/att_permission_service.dart';
import 'package:asteria_app/core/services/global_loader_service.dart';
import 'package:asteria_app/core/ui_kit/ui_kit.dart';
import 'package:asteria_app/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:asteria_app/features/balance/presentation/provider/rewards_provider.dart';
import 'package:asteria_app/features/home/home.dart';
import 'package:asteria_app/features/onboarding/presentation/bloc/onboarding_bloc.dart';
import 'package:asteria_app/features/shop/presentation/bloc/shop_bloc.dart';
import 'package:asteria_app/features/splash/presentation/screens/splash_screen.dart';
import 'package:asteria_app/features/splash/presentation/bloc/splash_bloc.dart';
import 'package:device_preview/device_preview.dart';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

class MyApp extends StatefulWidget {
  final AppLocaleService localeService;

  const MyApp({super.key, required this.localeService});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late Future<String> _initFuture;
  ApplePurchaseCoordinator? _appleCoordinator;
  GooglePurchaseRecovery? _googlePurchaseRecovery;

  @override
  void initState() {
    super.initState();
    widget.localeService.addListener(_handleLocaleChanged);
    _initFuture = _initializeApp();
  }

  @override
  void dispose() {
    widget.localeService.removeListener(_handleLocaleChanged);
    _appleCoordinator?.dispose();
    _googlePurchaseRecovery?.dispose();
    super.dispose();
  }

  void _handleLocaleChanged() {
    if (di.isRegistered<ContentProvider>()) {
      unawaited(di.get<ContentProvider>().loadContent());
    }
    setState(() {});
  }

  Future<String> _initializeApp() async {
    // Инициализируем DI
    await DiContainer.initialize(localeService: widget.localeService);
    final analytics = di.get<DurableAnalytics>();
    try {
      await analytics.initialize();
    } catch (_) {
      await analytics.reportStorageFailure();
    }
    di.get<AnalyticsLifecycle>().start();
    // Start listening before routing so a cold-start payment return is buffered.
    di.get<PaymentReturnLinkService>();

    // 1. Конфигурируем AppsFlyer SDK (initSdk), но ещё не запускаем.
    final appsFlyerService = di.get<AppsFlyerService>();
    await appsFlyerService.initialize();

    // 2. Подписываем AttributionService на AppsFlyer-коллбеки до запуска SDK,
    //    чтобы не потерять первый install conversion payload на холодном старте.
    await di.get<AttributionService>().initialize();

    // 3. Дать пользователю принять решение об ATT. На iOS показывает
    //    нативный промт если статус notDetermined; кэш — если статус
    //    уже определён. На Android — no-op.
    //
    //    Ответ нужен ДО startSDK, иначе AppsFlyer на iOS блокировался бы
    //    своим внутренним ATT-таймером (см. timeToWaitForATTUserAuthorization)
    //    до 50 секунд, теряя все события холодного старта.
    await di.get<AttPermissionService>().ensureRequested();

    // 4. Стартуем SDK после регистрации attribution callbacks.
    //    События, прилетевшие до onSuccess, буферизуются и будут флашнуты.
    appsFlyerService.startSDK();

    // Инициализируем UserProvider — нужно до trackAppOpen, чтобы
    // авторизованным пользователям user_id попал в app_open.
    final userProvider = di.get<UserProvider>();
    await userProvider.initialize();
    await di.get<MonetizationProvider>().start();
    await di.get<RewardsProvider>().start();

    // 4. Базовое app_open / app_first_open событие через фасад
    //    (с уже подгруженным attribution snapshot из Hive и user_id).
    await di.get<AnalyticsFacade>().trackAppOpen();

    // 4.1. Канонический ast_app_open рядом с legacy событием.
    // is_new_user: true когда локально нет авторизованного пользователя
    // (первый запуск или pre-activation).
    final isNewUser = !userProvider.isAuthenticated;
    await di.get<ProductAnalyticsService>().trackAppOpen(isNewUser: isNewUser);

    // Warm content in the background; cold-start routing must not wait for
    // large remote payloads such as the lunar calendar.
    final contentProvider = di.get<ContentProvider>();
    startLazyContentWarmup(loadContent: contentProvider.initialize);

    final usesNativeStore = Platform.isIOS || Platform.isAndroid;
    if (usesNativeStore) {
      await _initializeStorePayments(userProvider: userProvider);
    }

    // Определяем стартовый маршрут
    final splashBloc = di.get<SplashBloc>();
    splashBloc.add(const InitializeApp());

    // Ждем результат инициализации
    await for (final state in splashBloc.stream) {
      if (state is SplashSuccess) {
        final initialRoute = resolveInitialRoute(
          fallbackRoute: state.initialRoute,
          currentUserId: userProvider.currentUser?.id,
        );
        DiContainer.registerRouter(initialRoute);
        return initialRoute;
      } else if (state is SplashError) {
        throw Exception(state.message);
      }
    }

    throw Exception('Не удалось определить стартовый маршрут');
  }

  void _retryInit() {
    setState(() {
      _initFuture = _initializeApp();
    });
  }

  /// Wires up StoreKit purchase stream + retries pending verify calls
  /// from previous sessions (offline / app crash mid-verify).
  Future<void> _initializeStorePayments({
    required UserProvider userProvider,
  }) async {
    final storeGateway = di.get<StoreBillingGateway>();
    final pendingStore = di.get<PendingPurchasesStore>();
    final authSession = di.get<AuthSessionService>();

    await pendingStore.init();

    if (Platform.isAndroid) {
      _googlePurchaseRecovery?.dispose();
      final recovery = GooglePurchaseRecovery(
        identityChanges: userProvider,
        currentUserId: () =>
            userProvider.currentUser?.id == authSession.currentUid
            ? authSession.currentUid
            : null,
        purchaseUpdates: storeGateway.purchaseUpdates,
        paymentsApi: di.get<StorePaymentsApi>(),
        pendingStore: pendingStore,
        refreshEntitlements: di.get<MonetizationProvider>().refresh,
      );
      _googlePurchaseRecovery = recovery;
      unawaited(recovery.start());
      return;
    }

    final coordinator = di.get<ApplePurchaseCoordinator>();
    _appleCoordinator = coordinator;
    unawaited(coordinator.start());
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        statusBarBrightness: Brightness.dark,
        systemNavigationBarColor: Colors.transparent,
        systemNavigationBarIconBrightness: Brightness.light,
      ),
    );

    return FutureBuilder<String>(
      future: _initFuture,
      builder: (_, snapshot) {
        switch (snapshot.connectionState) {
          case ConnectionState.none:
          case ConnectionState.waiting:
          case ConnectionState.active:
            return _BootstrapApp(
              localeService: widget.localeService,
              child: const SplashScreen(),
            );
          case ConnectionState.done:
            if (snapshot.hasError) {
              return _BootstrapApp(
                localeService: widget.localeService,
                child: _ErrorScreen(
                  error: snapshot.error,
                  stackTrace: snapshot.stackTrace,
                  onRetry: _retryInit,
                ),
              );
            }

            return _App(
              initialRoute: snapshot.data!,
              localeService: widget.localeService,
            );
        }
      },
    );
  }
}

class _BootstrapApp extends StatelessWidget {
  final AppLocaleService localeService;
  final Widget child;

  const _BootstrapApp({required this.localeService, required this.child});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      locale: localeService.effectiveLocale,
      supportedLocales: AppLocaleService.supportedLocales,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      home: child,
    );
  }
}

class _App extends StatelessWidget {
  final String initialRoute;
  final AppLocaleService localeService;

  const _App({required this.initialRoute, required this.localeService});

  @override
  Widget build(BuildContext context) {
    return ThemeSwitcherWidget(
      initialMode: ThemeMode.light,
      child: Builder(
        builder: (context) {
          final themeSwitcher = ThemeSwitcher.of(context);
          final themeManager = ThemeManager.instance;

          return MaterialApp.router(
            title: 'Asteria',
            debugShowCheckedModeBanner: false,
            locale:
                DevicePreview.locale(context) ?? localeService.effectiveLocale,
            theme: themeManager.getLightThemeData(context),
            darkTheme: themeManager.getDarkThemeData(context),
            themeMode: themeSwitcher.themeMode,
            supportedLocales: AppLocaleService.supportedLocales,
            localizationsDelegates: const [
              AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            routerConfig: di.get<GoRouter>(),
            builder: (context, child) {
              final wrappedChild = DevicePreview.appBuilder(context, child);
              return MultiBlocProvider(
                providers: [
                  BlocProvider<AuthCubit>.value(value: di.get<AuthCubit>()),
                  BlocProvider<OnboardingBloc>.value(
                    value: di.get<OnboardingBloc>(),
                  ),
                  BlocProvider<SplashBloc>.value(value: di.get<SplashBloc>()),
                  BlocProvider<HomeCubit>.value(value: di.get<HomeCubit>()),
                  BlocProvider<ShopBloc>.value(value: di.get<ShopBloc>()),
                ],
                child: MultiProvider(
                  providers: [
                    ChangeNotifierProvider<UserProvider>.value(
                      value: di.get<UserProvider>(),
                    ),
                    ChangeNotifierProvider<RewardsProvider>.value(
                      value: di.get<RewardsProvider>(),
                    ),
                    ChangeNotifierProvider<MonetizationProvider>.value(
                      value: di.get<MonetizationProvider>(),
                    ),
                    ChangeNotifierProvider<ContentProvider>.value(
                      value: di.get<ContentProvider>(),
                    ),
                    ChangeNotifierProvider<AnakraChatProvider>.value(
                      value: di.get<AnakraChatProvider>(),
                    ),
                  ],
                  child: GlobalLoaderWidget(
                    loaderService: di.get<GlobalLoaderService>(),
                    child: wrappedChild,
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class _ErrorScreen extends StatelessWidget {
  final dynamic error;
  final StackTrace? stackTrace;
  final VoidCallback onRetry;

  const _ErrorScreen({
    required this.error,
    this.stackTrace,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Material(
      child: Container(
        color: Colors.black,
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, size: 64, color: Colors.white),
                const SizedBox(height: 16),
                Text(
                  l10n.initializationError,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  error.toString(),
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 16, color: Colors.white),
                ),
                const SizedBox(height: 24),
                ElevatedButton(onPressed: onRetry, child: Text(l10n.retry)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
