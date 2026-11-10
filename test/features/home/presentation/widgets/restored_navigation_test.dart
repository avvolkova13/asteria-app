import 'dart:io';

import 'package:asteria_app/core/localization/generated/l10n.dart';
import 'package:asteria_app/features/home/presentation/widgets/bottom_tab_bar_widget.dart';
import 'package:flutter/material.dart';
import 'package:asteria_app/core/ui_kit/theme/theme.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('home, personal, moon and practices select their expected indexes', (
    tester,
  ) async {
    var selected = -1;
    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: const [AppLocalizations.delegate],
        supportedLocales: const [Locale('en')],
        home: Builder(
          builder: (context) => Theme(
            data: AppThemeDark.instance.getThemeData(context),
            child: Scaffold(
              bottomNavigationBar: BottomTabBarWidget(
                currentIndex: 0,
                aiAstrologerAsset: 'assets/images/year_animals/horse.webp',
                onTabChanged: (index) => selected = index,
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    final context = tester.element(find.byType(BottomTabBarWidget));
    final l10n = AppLocalizations.of(context);
    final labels = [
      l10n.navHome,
      l10n.navPersonal,
      l10n.navMoon,
      l10n.navPractices,
    ];
    for (var index = 0; index < labels.length; index++) {
      await tester.tap(find.text(labels[index]));
      expect(selected, index);
    }
  });

  test('retired feature implementations and entry points are absent', () {
    expect(Directory('lib/features/social').existsSync(), isFalse);
    expect(Directory('lib/features/star_fair').existsSync(), isFalse);
    final home = File(
      'lib/features/home/presentation/screens/home_screen.dart',
    ).readAsStringSync();
    expect(home, contains('const MainScreen()'));
    expect(home, contains('const PersonalScreen()'));
    for (final path in [
      'lib/core/di/di.dart',
      'lib/core/routing/app_route.dart',
      'lib/core/routing/routing_scheme.dart',
    ]) {
      expect(File(path).readAsStringSync(), isNot(contains('features/social')));
      expect(File(path).readAsStringSync(), isNot(contains('StarFair')));
    }
  });
}
