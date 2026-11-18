import 'dart:convert';
import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:asteria_app/core/di/di.dart';
import 'package:asteria_app/core/environment/environment.dart';
import 'package:asteria_app/core/localization/localization.dart';
import 'package:asteria_app/core/ui_kit/ui_kit.dart';
import 'package:asteria_app/core/analytics/analytics_facade.dart';
import 'package:asteria_app/core/analytics/product_analytics_service.dart';
import 'package:asteria_app/core/services/auth/auth_session_service.dart';
import 'package:asteria_app/core/services/global_loader_service.dart';
import 'package:asteria_app/app/data/models/user/user_model.dart';
import 'package:asteria_app/app/data/repositories/user/user_repository.dart';
import 'package:asteria_app/app/data/repositories/app_settings/app_settings_repository.dart';
import 'package:asteria_app/app/providers/user_provider.dart';
import 'package:asteria_app/features/auth/data/email_auth_repository.dart';
import 'package:asteria_app/features/auth/data/repositories/auth_repository.dart';
import 'package:asteria_app/features/auth/domain/models/auth_identity.dart';
import 'package:asteria_app/features/auth/localization/auth_localization_contract.dart';
import 'package:asteria_app/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:asteria_app/features/auth/presentation/widgets/bottom_button_widget.dart';
import 'package:asteria_app/features/auth/presentation/widgets/code_input_widget.dart';
import 'package:asteria_app/features/auth/presentation/widgets/date_picker_bottom_sheet.dart';
import 'package:asteria_app/core/ui_kit/widgets/asteria_activity_indicator.dart';
import 'package:asteria_app/core/ui_kit/widgets/asteria_action_button.dart';
import 'package:asteria_app/features/auth/presentation/cubit/email_auth_cubit.dart';
import 'package:asteria_app/features/auth/presentation/cubit/email_auth_state.dart';
import 'package:asteria_app/features/auth/presentation/screens/email_login_screen.dart';
import 'package:asteria_app/features/auth/presentation/screens/email_code_screen.dart';
import 'package:asteria_app/features/auth/presentation/screens/personal_info_input_screen.dart';
import 'package:asteria_app/features/home/presentation/screens/profile_screen.dart';
import 'package:asteria_app/features/settings/presentation/settings_screen.dart';
import 'package:asteria_app/features/about_us/about_us_screen.dart';
import 'package:asteria_app/features/achievements/presentation/achievements_screen.dart';
import 'package:asteria_app/features/profile_avatar/avatar_picker_screen.dart';
import 'package:asteria_app/features/profile_avatar/avatar_preferences.dart';
import 'package:asteria_app/features/onboarding/data/onboarding_data.dart';
import 'package:asteria_app/features/onboarding/localization/onboarding_localization_contract.dart';
import 'package:asteria_app/features/onboarding/presentation/bloc/onboarding_bloc.dart';
import 'package:asteria_app/features/onboarding/presentation/screens/onboarding_screen.dart';

class ReviewBinding extends AutomatedTestWidgetsFlutterBinding {
  @override
  bool get disableShadows => false;
}

class UnusedRepository extends Fake implements UserRepository {}

class UnusedAuth extends Fake implements AuthRepository {}

class UnusedEmail extends Fake implements EmailAuthRepository {}

class UnusedSession extends Fake implements AuthSessionService {}

class Analytics extends Fake implements AnalyticsFacade {
  @override
  Future<void> trackEvent(String name, {Map<String, dynamic>? params}) async {}
}

class Settings extends Fake implements AppSettingsRepository {
  @override
  bool getShowOnboarding() => true;
  @override
  void setShowOnboarding(bool value) {}
}

class Storage implements AvatarStorage {
  @override
  String? read(String id) => null;
  @override
  Future<void> write(String id, String preset) async {
    throw StateError('review storage failure');
  }
}

class ReviewEmail extends EmailAuthCubit {
  ReviewEmail(UserProvider user)
    : super(
        repository: UnusedEmail(),
        sessionService: UnusedSession(),
        userRepository: UnusedRepository(),
        userProvider: user,
      );
  @override
  String? get currentEmail => 'marina.romanova@example.com';
  void show(EmailAuthState value) => emit(value);
}

const captureKey = ValueKey('forms-review-capture');
Future<void> capture(WidgetTester tester, String name) async {
  debugPrint('CAPTURE $name');
  await tester.runAsync(
    () => Future<void>.delayed(const Duration(milliseconds: 350)),
  );
  await tester.pumpAndSettle();
  final context = tester.element(find.byKey(captureKey));
  final providers = <ImageProvider>{
    for (final image in tester.widgetList<Image>(find.byType(Image)))
      image.image,
    for (final box in tester.widgetList<DecoratedBox>(
      find.byType(DecoratedBox),
    ))
      if (box.decoration case BoxDecoration(image: final image?)) image.image,
  };
  await tester.runAsync(() async {
    await Future.wait(
      providers.map((p) => precacheImage(p, context)),
    ).timeout(const Duration(seconds: 3), onTimeout: () => []);
  });
  await tester.pump();
  await tester.runAsync(
    () => Future<void>.delayed(const Duration(milliseconds: 100)),
  );
  await tester.pumpAndSettle();
  final boundary = tester.renderObject<RenderRepaintBoundary>(
    find.byKey(captureKey),
  );
  await tester.runAsync(() async {
    final image = await boundary.toImage(pixelRatio: 1);
    final data = await image.toByteData(format: ui.ImageByteFormat.png);
    await File(
      '/private/tmp/asteria-design-review/forms/$name.png',
    ).writeAsBytes(data!.buffer.asUint8List());
    image.dispose();
  });
}

Future<void> pump(
  WidgetTester tester,
  Widget screen,
  UserProvider user, {
  required String lang,
  required bool compact,
  double keyboard = 0,
  EmailAuthCubit? email,
  AuthCubit? auth,
  OnboardingBloc? onboarding,
}) async {
  tester.view.devicePixelRatio = 1;
  tester.view.physicalSize = compact
      ? const Size(320, 568)
      : const Size(390, 844);
  await tester.pumpWidget(
    MultiProvider(
      providers: [
        ChangeNotifierProvider<UserProvider>.value(value: user),
        if (email != null) BlocProvider<EmailAuthCubit>.value(value: email),
        if (auth != null) BlocProvider<AuthCubit>.value(value: auth),
        if (onboarding != null)
          BlocProvider<OnboardingBloc>.value(value: onboarding),
      ],
      child: MaterialApp(
        locale: Locale(lang),
        supportedLocales: AppLocaleService.supportedLocales,
        localizationsDelegates: const [
          AppLocalizations.delegate,
          ...GlobalMaterialLocalizations.delegates,
        ],
        builder: (context, child) => Theme(
          data: AppThemeDark.instance.getThemeData(context),
          child: MediaQuery(
            data: MediaQuery.of(context).copyWith(
              padding: EdgeInsets.only(
                top: compact ? 20 : 59,
                bottom: compact ? 0 : 34,
              ),
              textScaler: TextScaler.linear(compact ? 2 : 1),
              disableAnimations: true,
              viewInsets: EdgeInsets.only(bottom: keyboard),
            ),
            child: RepaintBoundary(key: captureKey, child: child!),
          ),
        ),
        home: screen,
      ),
    ),
  );
  await tester.pump();
  await tester.pump(const Duration(seconds: 1));
  await tester.pump();
}

void main() {
  final binding = ReviewBinding();
  late Environment environment;
  setUpAll(() async {
    Directory(
      '/private/tmp/asteria-design-review/forms',
    ).createSync(recursive: true);
    for (final font in [
      ('MaterialIcons', 'fonts/MaterialIcons-Regular.otf'),
      (
        'packages/cupertino_icons/CupertinoIcons',
        'packages/cupertino_icons/assets/CupertinoIcons.ttf',
      ),
      ('Lora', 'assets/fonts/lora/Lora-VariableFont_wght.ttf'),
      ('Onest', 'assets/fonts/onest/Onest-VariableFont_wght.ttf'),
    ]) {
      await (FontLoader(font.$1)..addFont(rootBundle.load(font.$2))).load();
    }
    binding.defaultBinaryMessenger.setMockMessageHandler('flutter/assets', (
      message,
    ) async {
      if (utf8.decode(message!.buffer.asUint8List()) == '.env') {
        return ByteData.sublistView(utf8.encode('GOOGLE_MAPS_API_KEY=test'));
      }
      return null;
    });
    rootBundle.evict('.env');
    environment = await Environment.initialize();
    binding.defaultBinaryMessenger.setMockMessageHandler(
      'flutter/assets',
      null,
    );
  });
  for (final lang in ['ru', 'en']) {
    for (final compact in [false, true]) {
      final suffix = '${lang}_${compact ? '320_text2' : '390'}';
      testWidgets('forms production renders $suffix', (tester) async {
        await di.reset();
        final user = UserProvider(userRepository: UnusedRepository());
        user.applyServerUserSnapshot(
          UserModel.empty().copyWith(
            id: 'design-review',
            name: 'Марина Романова',
            personalInfo: PersonalInfoModel(gender: Gender.female),
          ),
        );
        final analytics = Analytics();
        di.registerSingleton<UserProvider>(user);
        di.registerSingleton<Environment>(environment);
        di.registerSingleton<AnalyticsFacade>(analytics);
        di.registerSingleton<ProductAnalyticsService>(
          ProductAnalyticsService(analytics),
        );
        final email = ReviewEmail(user);
        final auth = AuthCubit(
          authRepository: UnusedAuth(),
          userRepository: UnusedRepository(),
          userProvider: user,
          globalLoaderService: GlobalLoaderService(),
        );
        final onboard = OnboardingBloc(Settings());
        final avatars = AvatarPreferences(storage: Storage());
        addTearDown(() async {
          await email.close();
          await auth.close();
          await onboard.close();
          avatars.dispose();
          user.dispose();
          await di.reset();
          tester.view.reset();
        });
        for (final pair in <(String, Widget)>[
          ('profile', const ProfileScreen()),
          ('settings', const SettingsScreen()),
          ('about', const AboutUsScreen()),
          ('achievements', const AchievementsScreen()),
          (
            'avatar',
            AvatarPickerScreen(
              userId: 'design-review',
              gender: Gender.female,
              preferences: avatars,
            ),
          ),
        ]) {
          await pump(tester, pair.$2, user, lang: lang, compact: compact);
          await capture(tester, '${pair.$1}_$suffix');
          if (pair.$1 == 'settings' && compact) {
            final title = find.text(
              lang == 'ru' ? 'Геолокация' : 'Geolocation',
            );
            final paragraph = tester.renderObject<RenderParagraph>(title);
            expect(
              paragraph.getBoxesForSelection(
                TextSelection(
                  baseOffset: 0,
                  extentOffset: (tester.widget<Text>(title).data!).length,
                ),
              ),
              hasLength(1),
            );
          }

          final scroll = find.byType(SingleChildScrollView);
          if (scroll.evaluate().isNotEmpty) {
            await tester.drag(scroll.first, const Offset(0, -2000));
            await tester.pumpAndSettle();
            await capture(tester, '${pair.$1}_bottom_$suffix');
          }
        }
        final account = user.currentUser!;
        for (final entry in [('progress', 2, 1), ('complete', 5, 3)]) {
          user.applyServerUserSnapshot(
            UserModel.fromJson({
              ...account.toJson(),
              'statistics': {
                'tarot_cards_opened': entry.$2,
                'horoscope_opened': entry.$3,
                'runes_opened': entry.$3,
              },
            }),
          );
          await pump(
            tester,
            const AchievementsScreen(),
            user,
            lang: lang,
            compact: compact,
          );
          await tester.ensureVisible(
            find.byKey(const ValueKey('achievement-tarot')),
          );
          await tester.pumpAndSettle();
          await capture(tester, 'achievements_${entry.$1}_$suffix');
        }
        user.applyServerUserSnapshot(account);
        for (final state in <(String, EmailAuthState)>[
          ('empty', const EmailAuthInitial()),
          ('loading', const EmailAuthRequesting()),
          ('error', const EmailAuthFailure(EmailAuthFailureCode.network)),
        ]) {
          email.show(state.$2);
          await pump(
            tester,
            EmailLoginScreen(isRoot: true, onAuthStarted: () {}),
            user,
            lang: lang,
            compact: compact,
            email: email,
          );
          await capture(tester, 'email_${state.$1}_$suffix');
        }
        await pump(
          tester,
          EmailLoginScreen(isRoot: true, onAuthStarted: () {}),
          user,
          lang: lang,
          compact: compact,
          email: email,
          keyboard: 260,
        );
        await capture(tester, 'email_keyboard_$suffix');
        for (final state in <(String, EmailAuthState)>[
          (
            'sent',
            const EmailAuthCodeSent('marina.romanova@example.com', 45),
          ),
          (
            'loading',
            const EmailAuthVerifying('marina.romanova@example.com', 45),
          ),
          (
            'error',
            const EmailAuthFailure(
              EmailAuthFailureCode.invalidOrExpiredCode,
              remainingSeconds: 45,
            ),
          ),
        ]) {
          email.show(state.$2);
          await pump(
            tester,
            const EmailCodeScreen(),
            user,
            lang: lang,
            compact: compact,
            email: email,
          );
          await capture(tester, 'code_${state.$1}_$suffix');
          final emailText = tester.widget<Text>(find.text(email.currentEmail!));
          expect(emailText.style!.fontSize, 16);
          expect(emailText.style!.fontFamily, 'Onest');
          if (state.$1 == 'loading') {
            expect(find.byType(AsteriaActivityIndicator), findsOneWidget);
            expect(
              find.text(lang == 'ru' ? 'Загрузка…' : 'Loading…'),
              findsOneWidget,
            );
            final focus = find.ancestor(
              of: find.byType(CodeInputWidget),
              matching: find.byType(ExcludeFocus),
            );
            expect(tester.widget<ExcludeFocus>(focus.first).excluding, isTrue);
          }
        }
        await pump(
          tester,
          PersonalInfoInputScreen(
            identity: const AuthIdentity.email(
              userId: 'review',
              email: 'review@example.com',
            ),
            authLocalization: AuthLocalization(),
          ),
          user,
          lang: lang,
          compact: compact,
          auth: auth,
        );
        await capture(tester, 'personal_empty_$suffix');
        final date = find.text(
          lang == 'ru' ? 'Дата рождения' : 'Date of birth',
        );
        if (date.evaluate().isNotEmpty) {
          await tester.ensureVisible(date);
          await tester.tap(date);
          await tester.pumpAndSettle();
          await capture(tester, 'date_picker_$suffix');
          expect(
            find.descendant(
              of: find.byType(DateTimePickerBottomSheet),
              matching: find.byType(AsteriaActionButton),
            ),
            findsOneWidget,
          );

          Navigator.of(
            tester.element(find.byType(PersonalInfoInputScreen)),
          ).pop();
          await tester.pumpAndSettle();
        }
        final time = find.text(
          AuthLocalization().birthTimeLabel(
            tester.element(find.byType(PersonalInfoInputScreen)),
          ),
        );
        await tester.ensureVisible(time);
        await tester.tap(time);
        await tester.pumpAndSettle();
        await capture(tester, 'time_picker_$suffix');
        expect(
          find.descendant(
            of: find.byType(DateTimePickerBottomSheet),
            matching: find.byType(AsteriaActionButton),
          ),
          findsOneWidget,
        );

        Navigator.of(
          tester.element(find.byType(PersonalInfoInputScreen)),
        ).pop();
        await tester.pumpAndSettle();
        auth.updateUserName(lang == 'ru' ? 'Анастасия' : 'Anastasia');
        auth.updateUserBirthPlace(
          'Yekaterinburg',
          latitude: 56.8,
          longitude: 60.6,
        );
        auth.updateUserBirthDate(DateTime(1996, 8, 21));
        auth.updateUserBirthTime(
          birthTime: DateTime(2000, 1, 1, 17, 5),
          isTimeUnknown: false,
        );
        await tester.pumpAndSettle();
        await capture(tester, 'personal_populated_$suffix');
        final dateLabel = tester
            .widgetList<Text>(find.byType(Text))
            .map((text) => text.data)
            .whereType<String>()
            .firstWhere((text) => text.contains('1996'));
        final timeLabel = tester
            .widgetList<Text>(find.byType(Text))
            .map((text) => text.data)
            .whereType<String>()
            .firstWhere(
              (text) => text.contains('17:05') || text.contains('5:05'),
            );
        expect(
          tester
              .renderObject<RenderParagraph>(find.text(dateLabel))
              .didExceedMaxLines,
          isFalse,
        );
        expect(
          tester
              .renderObject<RenderParagraph>(find.text(timeLabel))
              .didExceedMaxLines,
          isFalse,
        );
        await auth.saveUser();
        await tester.pumpAndSettle();
        await capture(tester, 'personal_error_$suffix');
        ScaffoldMessenger.of(
          tester.element(find.byType(PersonalInfoInputScreen)),
        ).hideCurrentSnackBar();
        await tester.pumpAndSettle();
        await tester.ensureVisible(find.byType(BottomButtonWidget));
        await tester.pumpAndSettle();
        await capture(tester, 'personal_retry_$suffix');

        expect(find.text(dateLabel), findsOneWidget);
        expect(find.text(timeLabel), findsOneWidget);
        expect(
          tester
              .widget<BottomButtonWidget>(find.byType(BottomButtonWidget))
              .isFormValid,
          isTrue,
        );

        await auth.saveUser();
        await tester.pumpAndSettle();
        final personalContext = tester.element(
          find.byType(PersonalInfoInputScreen),
        );
        expect(
          find.text(AppLocalizations.of(personalContext).authSaveUserError),
          findsOneWidget,
        );

        await pump(
          tester,
          Builder(
            builder: (context) => OnboardingScreen(
              now: () => DateTime(2026, 11, 16, 12),
              pages: OnboardingData.getPages(context),
              localization: OnboardingLocalization(),
              onComplete: () {},
            ),
          ),
          user,
          lang: lang,
          compact: compact,
          onboarding: onboard,
        );
        final pageCount = OnboardingData.getPages(
          tester.element(find.byType(OnboardingScreen)),
        ).length;
        for (var page = 0; page < pageCount; page++) {
          await capture(tester, 'onboarding_${page + 1}_$suffix');
          final context = tester.element(find.byType(OnboardingScreen));
          final text = page == pageCount - 1
              ? AppLocalizations.of(context).introStart
              : OnboardingLocalization().nextButton(context);
          await tester.tap(find.text(text));
          await tester.pumpAndSettle();
        }
        expect(tester.takeException(), isNull);
      });
    }
  }
}
