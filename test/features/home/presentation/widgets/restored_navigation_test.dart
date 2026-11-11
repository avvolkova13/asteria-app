import 'dart:io';

import 'package:asteria_app/core/localization/generated/l10n.dart';
import 'package:asteria_app/features/home/presentation/widgets/bottom_tab_bar_widget.dart';
import 'package:flutter/material.dart';
import 'package:asteria_app/core/ui_kit/theme/theme.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets(
    'home, personal, moon and practices select their expected indexes',
    (tester) async {
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
    },
  );

  for (final reduced in [false, true]) {
    testWidgets(
      'lens follows, cancels, and commits a scrub (reduced: $reduced)',
      (tester) async {
        var index = 0;
        final changes = <int>[];
        await tester.pumpWidget(
          MaterialApp(
            localizationsDelegates: const [AppLocalizations.delegate],
            supportedLocales: const [Locale('en')],
            home: StatefulBuilder(
              builder: (context, setState) {
                return MediaQuery(
                  data: MediaQuery.of(context)
                      .copyWith(disableAnimations: reduced),
                  child: Scaffold(
                    bottomNavigationBar: BottomTabBarWidget(
                      currentIndex: index,
                      aiAstrologerAsset:
                          'assets/images/year_animals/horse.webp',
                      onTabChanged: (value) {
                        changes.add(value);
                        setState(() => index = value);
                      },
                    ),
                  ),
                );
              },
            ),
          ),
        );
        await tester.pumpAndSettle();
        final l10n = AppLocalizations.of(
          tester.element(find.byType(BottomTabBarWidget)),
        );
        final lens = find.byType(RawMagnifier);
        final start = tester.getCenter(lens);
        final end = Offset(
          tester.getCenter(find.text(l10n.navPractices)).dx,
          start.dy,
        );
        final finger = await tester.startGesture(start);
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 200));
        expect(
          tester.widget<RawMagnifier>(lens).magnificationScale,
          reduced ? 1 : closeTo(1.15, .001),
        );
        await finger.moveTo(Offset.lerp(start, end, .24)!);
        await tester.pump();
        await finger.moveTo(Offset.lerp(start, end, .68)!);
        await tester.pump();
        expect(
          tester.getCenter(lens).dx,
          closeTo(Offset.lerp(start, end, reduced ? 2 / 3 : .68)!.dx, 1.5),
        );
        expect(changes, isEmpty);
        await finger.cancel();
        await tester.pumpAndSettle();
        expect(tester.getCenter(lens).dx, closeTo(start.dx, 1));
        expect(changes, isEmpty);
        final drag = await tester.startGesture(start);
        await drag.moveTo(Offset.lerp(start, end, .3)!);
        await drag.moveTo(end);
        await drag.up();
        await tester.pumpAndSettle();
        expect(changes, [3]);
        expect(tester.getCenter(lens).dx, closeTo(end.dx, 1));
      },
    );
  }

  test('retired feature implementations and entry points are absent', () {
    expect(Directory('lib/features/social').existsSync(), isFalse);
    expect(Directory('lib/features/star_fair').existsSync(), isFalse);
    final home = File('lib/features/home/presentation/screens/home_screen.dart')
        .readAsStringSync();
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
