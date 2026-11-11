import 'package:asteria_app/core/localization/generated/l10n.dart';
import 'package:asteria_app/core/ui_kit/theme/theme.dart';
import 'package:asteria_app/features/home/presentation/widgets/bottom_tab_bar_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets(
    'Anakra floats in the foreground, pauses when covered and respects Reduce Motion',
    (tester) async {
      var taps = 0;
      final navKey = GlobalKey<NavigatorState>();
      final reduced = ValueNotifier(false);
      addTearDown(reduced.dispose);
      await tester.pumpWidget(
        MaterialApp(
          navigatorKey: navKey,
          localizationsDelegates: const [AppLocalizations.delegate],
          supportedLocales: const [Locale('en')],
          home: Builder(
            builder: (context) => Theme(
              data: AppThemeDark.instance.getThemeData(context),
              child: ValueListenableBuilder<bool>(
                valueListenable: reduced,
                builder: (context, value, child) => MediaQuery(
                  data: MediaQuery.of(
                    context,
                  ).copyWith(disableAnimations: value),
                  child: child!,
                ),
                child: Scaffold(
                  bottomNavigationBar: BottomTabBarWidget(
                    currentIndex: 0,
                    aiAstrologerAsset: 'assets/images/year_animals/horse.webp',
                    onTabChanged: (_) {},
                    onAiAstrologerPressed: () => taps++,
                  ),
                ),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      final badge = find.byWidgetPredicate(
        (widget) =>
            widget is Image &&
            widget.image is AssetImage &&
            (widget.image as AssetImage).assetName.endsWith(
              'anakra_horse_badge.png',
            ),
        skipOffstage: false,
      );
      Matrix4 transform() => Matrix4.copy(
        tester
            .widget<Transform>(
              find
                  .ancestor(
                    of: badge,
                    matching: find.byType(Transform, skipOffstage: false),
                  )
                  .first,
            )
            .transform,
      );
      final start = transform();
      await tester.pump(const Duration(milliseconds: 600));
      expect(transform(), isNot(start));
      final button = find.bySemanticsLabel(
        AppLocalizations.of(
          tester.element(find.byType(BottomTabBarWidget)),
        ).anakraTitle,
      );
      await tester.tap(button);
      expect(taps, 1);

      navKey.currentState!.push(
        MaterialPageRoute<void>(builder: (_) => const Scaffold()),
      );
      await tester.pumpAndSettle();
      final covered = transform();
      await tester.pump(const Duration(seconds: 1));
      expect(transform(), covered);
      navKey.currentState!.pop();
      await tester.pumpAndSettle();
      final resumed = transform();
      await tester.pump(const Duration(milliseconds: 600));
      expect(transform(), isNot(resumed));
      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.paused);
      await tester.pump();
      final background = transform();
      await tester.pump(const Duration(milliseconds: 600));
      expect(transform(), background);
      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
      await tester.pump();

      reduced.value = true;
      await tester.pumpAndSettle();
      expect(transform(), Matrix4.identity());
      await tester.pump(const Duration(seconds: 1));
      expect(transform(), Matrix4.identity());
      await tester.tap(button);
      expect(taps, 2);
      await tester.pumpWidget(const SizedBox.shrink());
    },
  );
}
