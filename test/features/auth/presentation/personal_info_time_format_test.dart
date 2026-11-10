import 'dart:convert';

import 'package:asteria_app/app/data/repositories/user/user_repository.dart';
import 'package:asteria_app/app/providers/user_provider.dart';
import 'package:asteria_app/core/di/di.dart';
import 'package:asteria_app/core/environment/environment.dart';
import 'package:asteria_app/core/localization/localization.dart';
import 'package:asteria_app/core/services/global_loader_service.dart';
import 'package:asteria_app/core/ui_kit/theme/theme.dart';
import 'package:asteria_app/features/auth/data/repositories/auth_repository.dart';
import 'package:asteria_app/features/auth/domain/models/auth_identity.dart';
import 'package:asteria_app/features/auth/localization/auth_localization_contract.dart';
import 'package:asteria_app/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:asteria_app/features/auth/presentation/cubit/auth_state.dart';
import 'package:asteria_app/features/auth/presentation/screens/personal_info_input_screen.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final binding = TestWidgetsFlutterBinding.ensureInitialized();
  late Environment environment;

  setUpAll(() async {
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
  tearDown(() async => di.reset());
  tearDownAll(() => rootBundle.evict('.env'));

  for (final scenario in [
    (
      locale: const Locale('en', 'US'),
      system24h: false,
      picker24h: false,
      label: '5:05 PM',
    ),
    (
      locale: const Locale('en', 'US'),
      system24h: true,
      picker24h: false,
      label: '5:05 PM',
    ),
    (
      locale: const Locale('ru'),
      system24h: false,
      picker24h: true,
      label: '17:05',
    ),
  ]) {
    testWidgets(
      'birth time picker and label agree for ${scenario.locale}, system24h=${scenario.system24h}',
      (tester) async {
        tester.view.physicalSize = const Size(390, 844);
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);
        di.registerSingleton<Environment>(environment);
        final cubit = AuthCubit(
          authRepository: _UnusedAuthRepository(),
          userRepository: _UnusedUserRepository(),
          userProvider: _UnusedUserProvider(),
          globalLoaderService: GlobalLoaderService(),
        );
        addTearDown(cubit.close);
        final localization = AuthLocalization();
        await tester.pumpWidget(
          BlocProvider.value(
            value: cubit,
            child: MaterialApp(
              locale: scenario.locale,
              supportedLocales: AppLocaleService.supportedLocales,
              localizationsDelegates: const [
                AppLocalizations.delegate,
                ...GlobalMaterialLocalizations.delegates,
              ],
              builder: (context, child) => MediaQuery(
                data: MediaQuery.of(
                  context,
                ).copyWith(alwaysUse24HourFormat: scenario.system24h),
                child: child!,
              ),
              home: Builder(
                builder: (context) => Theme(
                  data: AppThemeDark.instance.getThemeData(context),
                  child: PersonalInfoInputScreen(
                    identity: const AuthIdentity.email(
                      userId: 'time-test',
                      email: 'test@example.com',
                    ),
                    authLocalization: localization,
                  ),
                ),
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();
        final context = tester.element(find.byType(PersonalInfoInputScreen));
        await tester.tap(find.text(localization.birthTimeLabel(context)));
        await tester.pumpAndSettle();
        final picker = tester.widget<CupertinoDatePicker>(
          find.byType(CupertinoDatePicker),
        );
        expect(picker.use24hFormat, scenario.picker24h);
        expect(
          find.text('PM'),
          scenario.picker24h ? findsNothing : findsOneWidget,
        );
        picker.onDateTimeChanged(DateTime(2000, 1, 1, 17, 5));
        await tester.pump();
        await tester.tap(find.text(AppLocalizations.of(context).commonSelect));
        await tester.pumpAndSettle();
        expect(find.text(scenario.label), findsOneWidget);
        final storedTime = (cubit.state as UserUpdated)
            .user
            .personalInfo!
            .birthDate!
            .birthTime!;
        expect(storedTime.hour, 17);
        expect(storedTime.minute, 5);
        expect(tester.takeException(), isNull);
      },
    );
  }
}

class _UnusedAuthRepository implements AuthRepository {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _UnusedUserRepository implements UserRepository {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _UnusedUserProvider implements UserProvider {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}
