import 'package:asteria_app/core/ui_kit/widgets/asteria_activity_indicator.dart';
import 'package:asteria_app/app/data/repositories/user/user_repository.dart';
import 'package:asteria_app/app/providers/user_provider.dart';
import 'package:asteria_app/core/ui_kit/theme/theme.dart';
import 'package:asteria_app/core/localization/localization.dart';
import 'package:asteria_app/features/about_us/about_us_screen.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('does not show the app metadata block', (tester) async {
    await _pumpAboutUsScreen(tester, TargetPlatform.android);

    expect(find.text('О приложении'), findsOneWidget);
    expect(find.text('Контакты для связи'), findsOneWidget);
    expect(find.textContaining('Название: Asteria'), findsNothing);
    expect(find.textContaining('Разработчик: Finext'), findsNothing);
  });

  testWidgets('uses and scrolls the Google Play agreement on Android', (
    tester,
  ) async {
    _useCompactView(tester);
    await _pumpAboutUsScreen(tester, TargetPlatform.android);

    expect(
      find.textContaining(
        'Пользовательское соглашение устанавливает условия использования Asteria',
      ),
      findsOneWidget,
    );

    await tester.tap(find.text('Пользовательское соглашение'));
    await _finishExpansion(tester);

    expect(find.textContaining('Редакция от 22.07.2026 г.'), findsOneWidget);
    expect(
      find.textContaining('законодательством Кыргызской Республики'),
      findsOneWidget,
    );
    expect(
      find.textContaining('8.7. Настоящая Политика возврата применяется'),
      findsOneWidget,
    );
    expect(find.textContaining('ASTERIA USER AGREEMENT'), findsNothing);
    await _expectDocumentScrolls(tester);
  });

  testWidgets('uses the Google Play privacy policy on Android', (tester) async {
    await _pumpAboutUsScreen(tester, TargetPlatform.android);

    expect(
      find.textContaining(
        'Политика конфиденциальности объясняет, какие персональные данные обрабатывает Asteria',
      ),
      findsOneWidget,
    );

    await _expandDocument(tester, title: 'Политики конфиденциальности');

    expect(
      find.textContaining('Дата вступления в силу: 22 июля 2026 г.'),
      findsOneWidget,
    );
    expect(
      find.textContaining(
        'ОсОО «Кюльчоро» является оператором персональных данных',
      ),
      findsOneWidget,
    );
    expect(find.textContaining('12. Контакты'), findsOneWidget);
    expect(find.textContaining('PRIVACY POLICY'), findsNothing);
  });

  testWidgets('uses the approved English Google Play agreement on Android', (
    tester,
  ) async {
    _useCompactView(tester);
    await _pumpAboutUsScreen(
      tester,
      TargetPlatform.android,
      locale: const Locale('en', 'US'),
      initialDocument: LegalDocumentType.agreement,
    );
    await _finishExpansion(tester);

    expect(find.textContaining('Revision dated July 22, 2026'), findsOneWidget);
    expect(
      find.textContaining(
        'The subject of this User Agreement governs the relationship',
      ),
      findsOneWidget,
    );
    expect(find.textContaining('8. Return Policy.'), findsOneWidget);
    expect(
      find.text(
        'The approved English legal document is not available in this build.',
      ),
      findsNothing,
    );
    _expectNoCyrillic(tester);
    await _expectDocumentScrolls(tester);
  });

  testWidgets(
    'uses the approved English Google Play privacy policy on Android',
    (tester) async {
      _useCompactView(tester);
      await _pumpAboutUsScreen(
        tester,
        TargetPlatform.android,
        locale: const Locale('en', 'US'),
        initialDocument: LegalDocumentType.privacy,
      );
      await _finishExpansion(tester);

      expect(
        find.textContaining('Effective Date: July 22, 2026'),
        findsOneWidget,
      );
      expect(
        find.textContaining('Kyulchoro Limited Liability Company'),
        findsOneWidget,
      );
      expect(
        find.textContaining('Google Play Developer Policy requirements'),
        findsOneWidget,
      );
      expect(find.textContaining('12. Contacts'), findsOneWidget);
      expect(
        find.text(
          'The approved English legal document is not available in this build.',
        ),
        findsNothing,
      );
      _expectNoCyrillic(tester);
      await _expectDocumentScrolls(tester);
      await _expectDocumentReachesEnd(tester);
    },
  );

  testWidgets('uses the approved English App Store agreement on iOS', (
    tester,
  ) async {
    _useCompactView(tester);
    await _pumpAboutUsScreen(
      tester,
      TargetPlatform.iOS,
      locale: const Locale('en', 'US'),
      initialDocument: LegalDocumentType.agreement,
    );
    await _finishExpansion(tester);

    expect(find.textContaining('ASTERIA USER AGREEMENT'), findsOneWidget);
    expect(find.textContaining('Version dated July 27, 2026'), findsOneWidget);
    expect(
      find.textContaining(
        'TOOL SAFE SOLUTIONS LIMITED, a company registered under number',
      ),
      findsOneWidget,
    );
    expect(find.textContaining('22. CONTACTS'), findsOneWidget);
    expect(
      find.text(
        'The approved English legal document is not available in this build.',
      ),
      findsNothing,
    );
    _expectNoCyrillic(tester);
    await _expectDocumentScrolls(tester);
  });

  testWidgets('uses the approved English App Store privacy policy on iOS', (
    tester,
  ) async {
    _useCompactView(tester);
    await _pumpAboutUsScreen(
      tester,
      TargetPlatform.iOS,
      locale: const Locale('en', 'US'),
      initialDocument: LegalDocumentType.privacy,
    );
    await _finishExpansion(tester);

    expect(find.textContaining('PRIVACY POLICY'), findsOneWidget);
    expect(
      find.textContaining('Effective Date: July 24, 2026'),
      findsOneWidget,
    );
    expect(find.textContaining('22. Contacts and Complaints'), findsOneWidget);
    expect(find.text('Profile and Account Details'), findsOneWidget);
    expect(find.text('Purpose and Limitations'), findsOneWidget);
    expect(
      find.text(
        'The approved English legal document is not available in this build.',
      ),
      findsNothing,
    );

    for (var tableIndex = 0; tableIndex < 4; tableIndex++) {
      expect(
        find.byKey(ValueKey('legal-document-table-$tableIndex')),
        findsOneWidget,
      );
    }

    _expectNoCyrillic(tester);
    await _expectHorizontalTableScrolls(tester, tableIndex: 0);
    await _expectDocumentScrolls(tester);
    await _expectDocumentReachesEnd(tester);
  });

  testWidgets('uses and scrolls the App Store agreement on iOS', (
    tester,
  ) async {
    _useCompactView(tester);
    await _pumpAboutUsScreen(tester, TargetPlatform.iOS);

    expect(
      find.textContaining(
        'Пользовательское соглашение устанавливает условия использования Asteria',
      ),
      findsOneWidget,
    );

    await tester.tap(find.text('Пользовательское соглашение'));
    await _finishExpansion(tester);

    expect(find.textContaining('Редакция от 27 июля 2026 г.'), findsOneWidget);
    expect(
      find.textContaining(
        'TOOL SAFE SOLUTIONS LIMITED, компанией, зарегистрированной',
      ),
      findsOneWidget,
    );
    expect(
      find.textContaining(
        'настоящее Соглашение является пользовательским лицензионным',
      ),
      findsOneWidget,
    );
    expect(find.textContaining('ASTERIA USER AGREEMENT'), findsOneWidget);
    expect(find.textContaining('Version dated July 27, 2026'), findsOneWidget);
    expect(find.textContaining('22. КОНТАКТЫ'), findsOneWidget);
    expect(find.textContaining('22. CONTACTS'), findsOneWidget);
    await _expectDocumentScrolls(tester);
  });

  testWidgets('uses the App Store privacy policy on iOS', (tester) async {
    _useCompactView(tester);
    await _pumpAboutUsScreen(tester, TargetPlatform.iOS);

    expect(
      find.textContaining(
        'Политика конфиденциальности объясняет, какие персональные данные обрабатывает Asteria',
      ),
      findsOneWidget,
    );

    await _expandDocument(tester, title: 'Политики конфиденциальности');

    expect(
      find.textContaining('Дата вступления в силу: 24 июля 2026 г.'),
      findsOneWidget,
    );
    expect(
      find.textContaining(
        'TOOL SAFE SOLUTIONS LIMITED («Компания», «мы», «нас», «наш»)',
      ),
      findsWidgets,
    );
    expect(find.textContaining('App Store Review Guidelines'), findsWidgets);
    expect(
      find.textContaining(
        'Контакт по вопросам конфиденциальности и реализации прав субъектов данных: support@asteria-calendar.com',
      ),
      findsWidgets,
    );
    expect(find.textContaining('PRIVACY POLICY'), findsOneWidget);
    expect(
      find.textContaining('Effective Date: July 24, 2026'),
      findsOneWidget,
    );
    expect(find.textContaining('22. Контакты и жалобы'), findsOneWidget);
    expect(find.textContaining('22. Contacts and Complaints'), findsOneWidget);
    expect(find.text('Данные профиля и аккаунта'), findsOneWidget);
    expect(find.text('Profile and Account Details'), findsOneWidget);
    expect(find.text('Назначение и ограничения'), findsOneWidget);
    expect(find.text('Purpose and Limitations'), findsOneWidget);

    for (var tableIndex = 0; tableIndex < 8; tableIndex++) {
      expect(
        find.byKey(ValueKey('legal-document-table-$tableIndex')),
        findsOneWidget,
      );
    }

    await _expectHorizontalTableScrolls(tester, tableIndex: 0);
    await _expectDocumentScrolls(tester);
    await _expectDocumentReachesEnd(tester);
  });
}

void _useCompactView(WidgetTester tester) {
  tester.view.physicalSize = const Size(320, 568);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
}

void _expectNoCyrillic(WidgetTester tester) {
  final renderedText = tester
      .widgetList<Text>(find.byType(Text))
      .map((widget) => widget.data ?? widget.textSpan?.toPlainText() ?? '')
      .join('\n');
  expect(renderedText, isNot(matches(RegExp('[А-Яа-яЁё]'))));
}

Future<void> _expectDocumentScrolls(WidgetTester tester) async {
  expect(tester.takeException(), isNull);

  final scrollView = _verticalScrollView();
  final scrollable = _verticalScrollable();
  final positionBefore = tester
      .state<ScrollableState>(scrollable)
      .position
      .pixels;

  await tester.drag(scrollView, const Offset(0, -400));
  await tester.pump();

  final positionAfter = tester
      .state<ScrollableState>(scrollable)
      .position
      .pixels;
  expect(positionAfter, greaterThan(positionBefore));
  expect(tester.takeException(), isNull);
}

Future<void> _expectHorizontalTableScrolls(
  WidgetTester tester, {
  required int tableIndex,
}) async {
  final tableScrollView = find.byKey(
    ValueKey('legal-document-table-scroll-$tableIndex'),
  );
  await tester.scrollUntilVisible(
    tableScrollView,
    400,
    scrollable: _verticalScrollable(),
  );
  await tester.pump();

  final horizontalScrollable = find.descendant(
    of: tableScrollView,
    matching: find.byType(Scrollable),
  );
  final positionBefore = tester
      .state<ScrollableState>(horizontalScrollable)
      .position
      .pixels;

  final tableBounds = tester.getRect(tableScrollView);
  await tester.dragFrom(
    Offset(tableBounds.left + 160, tableBounds.top + 24),
    const Offset(-300, 0),
  );
  await tester.pump();

  final positionAfter = tester
      .state<ScrollableState>(horizontalScrollable)
      .position
      .pixels;
  expect(positionAfter, greaterThan(positionBefore));
  expect(tester.takeException(), isNull);
}

Future<void> _expectDocumentReachesEnd(WidgetTester tester) async {
  final position = tester
      .state<ScrollableState>(_verticalScrollable())
      .position;

  position.jumpTo(position.maxScrollExtent);
  await tester.pump();

  expect(position.pixels, position.maxScrollExtent);
  expect(tester.takeException(), isNull);
}

Finder _verticalScrollView() {
  return find.byWidgetPredicate(
    (widget) =>
        widget is SingleChildScrollView &&
        widget.scrollDirection == Axis.vertical,
  );
}

Finder _verticalScrollable() {
  return find.byWidgetPredicate(
    (widget) =>
        widget is Scrollable &&
        (widget.axisDirection == AxisDirection.down ||
            widget.axisDirection == AxisDirection.up),
  );
}

Future<void> _pumpAboutUsScreen(
  WidgetTester tester,
  TargetPlatform platform, {
  Locale locale = const Locale('ru'),
  LegalDocumentType? initialDocument,
}) async {
  debugDefaultTargetPlatformOverride = platform;
  final userProvider = UserProvider(userRepository: _FakeUserRepository());
  addTearDown(userProvider.dispose);

  try {
    await tester.pumpWidget(
      ChangeNotifierProvider<UserProvider>.value(
        value: userProvider,
        child: MaterialApp(
          locale: locale,
          localizationsDelegates: const [
            AppLocalizations.delegate,
            ...GlobalMaterialLocalizations.delegates,
          ],
          supportedLocales: AppLocaleService.supportedLocales,
          home: Builder(
            builder: (context) {
              return Theme(
                data: AppThemeLight.instance.getThemeData(context),
                child: AboutUsScreen(initialDocument: initialDocument),
              );
            },
          ),
        ),
      ),
    );
    await tester.pump();
  } finally {
    debugDefaultTargetPlatformOverride = null;
  }
}

Future<void> _expandDocument(
  WidgetTester tester, {
  required String title,
}) async {
  final titleFinder = find.text(title);
  await tester.scrollUntilVisible(
    titleFinder,
    200,
    scrollable: find.byType(Scrollable).first,
  );
  await tester.tap(titleFinder);
  await _finishExpansion(tester);
}

Future<void> _finishExpansion(WidgetTester tester) async {
  await tester.pump();

  // Large legal assets are decoded on a background isolate in widget tests.
  for (var attempt = 0; attempt < 40; attempt++) {
    if (find.byType(AsteriaActivityIndicator).evaluate().isEmpty) break;

    await tester.runAsync(
      () => Future<void>.delayed(const Duration(milliseconds: 50)),
    );
    await tester.pump();
  }

  expect(find.byType(AsteriaActivityIndicator), findsNothing);
  await tester.pump(const Duration(milliseconds: 250));
  await tester.pump();
}

class _FakeUserRepository implements UserRepository {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}
