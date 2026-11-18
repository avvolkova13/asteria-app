import 'package:asteria_app/app/data/models/user/user_model.dart';
import 'package:asteria_app/app/providers/user_provider.dart';
import 'package:asteria_app/core/di/di.dart';
import 'package:asteria_app/core/localization/localization.dart';
import 'package:asteria_app/core/ui_kit/theme/theme.dart';
import 'package:asteria_app/features/settings/presentation/settings_screen.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  for (final language in ['ru', 'en']) {
    testWidgets(
      'unimplemented notification settings stay unavailable after reopening in $language',
      (tester) async {
        tester.view.devicePixelRatio = 1;
        tester.view.physicalSize = const Size(320, 700);
        addTearDown(tester.view.reset);
        final account = _Account();
        di.registerSingleton<UserProvider>(account);
        addTearDown(() async {
          await di.reset();
          account.dispose();
        });
        var permissionCalls = 0;
        const channel = MethodChannel('asteria/calendar-plan-reminders');
        tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
          channel,
          (_) async {
            permissionCalls++;
            return null;
          },
        );
        addTearDown(
          () => tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
            channel,
            null,
          ),
        );
        final semantics = tester.ensureSemantics();
        await tester.pumpWidget(
          MaterialApp(
            locale: Locale(language),
            supportedLocales: AppLocaleService.supportedLocales,
            localizationsDelegates: const [
              AppLocalizations.delegate,
              ...GlobalMaterialLocalizations.delegates,
            ],
            builder: (context, child) => Theme(
              data: AppThemeDark.instance.getThemeData(context),
              child: MediaQuery(
                data: MediaQuery.of(context).copyWith(
                  textScaler: const TextScaler.linear(2),
                  disableAnimations: true,
                ),
                child: child!,
              ),
            ),
            home: Builder(
              builder: (context) => Scaffold(
                body: TextButton(
                  onPressed: () => Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (_) => const SettingsScreen(),
                    ),
                  ),
                  child: const Text('Open'),
                ),
              ),
            ),
          ),
        );
        for (var visit = 0; visit < 2; visit++) {
          await tester.tap(find.text('Open'));
          await tester.pumpAndSettle();
          final l = AppLocalizations.of(
            tester.element(find.byType(SettingsScreen)),
          );
          final switches = find.byType(CupertinoSwitch);
          expect(switches, findsNWidgets(3));
          expect(find.text(l.commonUnavailable), findsNWidgets(3));
          for (final control in tester.widgetList<CupertinoSwitch>(switches)) {
            expect(control.value, isFalse);
            expect(control.onChanged, isNull);
          }
          await tester.drag(
            find.byType(SingleChildScrollView),
            const Offset(0, -1600),
          );
          await tester.pumpAndSettle();
          final push = tester.getSemantics(
            find.bySemanticsLabel(
              '${l.settingsPushNotifications}. ${l.commonUnavailable}',
            ),
          );
          expect(
            push.getSemanticsData().flagsCollection.isEnabled.toBoolOrNull(),
            isFalse,
          );
          expect(
            push.getSemanticsData().flagsCollection.isToggled.toBoolOrNull(),
            isFalse,
          );
          expect(
            push.getSemanticsData().hasAction(SemanticsAction.tap),
            isFalse,
          );
          await tester.tap(switches.last);
          await tester.pump();
          expect(tester.widget<CupertinoSwitch>(switches.last).value, isFalse);
          await tester.drag(
            find.byType(SingleChildScrollView),
            const Offset(0, 3000),
          );
          await tester.pumpAndSettle();
          await tester.tap(
            find.bySemanticsLabel(
              MaterialLocalizations.of(
                tester.element(find.byType(SettingsScreen)),
              ).backButtonTooltip,
            ),
          );
          await tester.pumpAndSettle();
          expect(find.byType(SettingsScreen), findsNothing);
        }
        expect(permissionCalls, 0);
        expect(tester.takeException(), isNull);
        semantics.dispose();
      },
    );
  }
}

class _Account extends ChangeNotifier implements UserProvider {
  @override
  UserModel? get currentUser => null;
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}
