import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:asteria_app/core/localization/localization.dart';
import 'package:asteria_app/core/ui_kit/ui_kit.dart';
import 'package:asteria_app/features/scenarios/scenario_ui.dart';
import 'package:asteria_app/features/scenarios/calendar_plan.dart';
import 'package:asteria_app/features/scenarios/calendar_plans_view.dart';
import 'package:asteria_app/features/home/presentation/widgets/bottom_tab_bar_widget.dart';
import 'package:asteria_app/features/home/presentation/screens/practices_screen.dart';
import 'package:asteria_app/app/providers/content_provider.dart';
import 'package:asteria_app/app/providers/user_provider.dart';
import 'package:asteria_app/app/data/models/user/user_model.dart';
import 'package:asteria_app/app/data/models/article/article_model.dart';
import 'package:asteria_app/core/di/di.dart';
import 'package:provider/provider.dart';

Future<void> capture(WidgetTester tester, String name) async {
  await tester.pump(const Duration(seconds: 1));
  await tester.runAsync(() async {
    await Future<void>.delayed(const Duration(milliseconds: 220));
  });
  await tester.pump(const Duration(milliseconds: 80));
  final boundary = tester.renderObject<RenderRepaintBoundary>(find.byKey(const Key('capture')));
  await tester.runAsync(() async {
    final image = await boundary.toImage(pixelRatio: 1);
    final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
    final file = File('/private/tmp/asteria-design-review/home-calendar/$name.png');
    await file.parent.create(recursive: true);
    await file.writeAsBytes(bytes!.buffer.asUint8List());
    image.dispose();
  });
}

Widget host(Widget child, {String language = 'ru', double scale = 1, bool navigation = false}) => RepaintBoundary(
  key: const Key('capture'),
  child: MaterialApp(
    locale: Locale(language), supportedLocales: AppLocaleService.supportedLocales,
    localizationsDelegates: const [AppLocalizations.delegate, ...GlobalMaterialLocalizations.delegates],
    builder: (context, child) => Theme(data: AppThemeDark.instance.getThemeData(context),
      child: MediaQuery(data: MediaQuery.of(context).copyWith(textScaler: TextScaler.linear(scale), disableAnimations: true), child: child!)),
    home: navigation ? Scaffold(body: child, bottomNavigationBar: BottomTabBarWidget(currentIndex: 2, aiAstrologerAsset: 'assets/images/year_animals/horse.webp', onTabChanged: (_) {})) : child,
  ),
);

void main() {
  setUpAll(() async {
    for (final f in [('MaterialIcons','fonts/MaterialIcons-Regular.otf'),('Lora','assets/fonts/lora/Lora-VariableFont_wght.ttf'),('Onest','assets/fonts/onest/Onest-VariableFont_wght.ttf'),('CupertinoIcons','packages/cupertino_icons/assets/CupertinoIcons.ttf')]) {
      await (FontLoader(f.$1)..addFont(rootBundle.load(f.$2))).load();
    }
  });
  for (final language in ['ru', 'en']) {
    for (final compact in [false, true]) {
      testWidgets('plans $language compact=$compact', (tester) async {
        tester.view.physicalSize = compact ? const Size(320,568) : const Size(390,844);
        tester.view.devicePixelRatio = 1;
        tester.view.padding = const FakeViewPadding(top: 59, bottom: 34);
        addTearDown(tester.view.reset);
        for (final populated in [false,true]) {
          await tester.pumpWidget(host(ScenarioPage(title: language == 'ru' ? 'Мои планы' : 'My plans', child: CalendarPlansView(
            key: ValueKey('$populated'), now: () => DateTime(2026,11,17),
            plans: populated ? [CalendarPlan(id: 'hair', owner: 'fixture', day: DateTime.utc(2026,11,17), activity: CalendarActivity.haircut, title: language == 'ru' ? 'Стрижка и уход за волосами' : 'Haircut and hair care', recommendation: null),CalendarPlan(id: 'plant', owner: 'fixture', day: DateTime.utc(2026,11,17), activity: CalendarActivity.transplant, title: language == 'ru' ? 'Пересадка комнатных растений' : 'Repotting indoor plants', recommendation: null)] : [],
            onOpenPlan: (_) {}, onChooseDate: () {},
          )), language: language, scale: compact ? 2 : 1));
          await tester.pumpAndSettle();
          final modes = language == 'ru' ? ['Месяц','Неделя','День'] : ['Month','Week','Day'];
          for (final mode in modes) {
            final label = find.text(mode);
            if (label.hitTestable().evaluate().isEmpty) {
              await Scrollable.ensureVisible(tester.element(label), alignment: .5);
              await tester.pumpAndSettle();
            }
            await tester.tap(label);
            await tester.pumpAndSettle();
            await tester.drag(find.byType(ListView).first, const Offset(0, 4000));
            await tester.pumpAndSettle();
            final name = '$language-${compact ? '320-2x' : '390'}-${populated ? 'plans' : 'empty'}-${modes.indexOf(mode)}';
            await capture(tester, '$name-top');
            await tester.drag(find.byType(ListView).first, const Offset(0,-1700));
            await tester.pumpAndSettle();
            await capture(tester, '$name-bottom');
            expect(tester.takeException(), isNull);
          }
        }
      });
      testWidgets('practices with native navigation $language compact=$compact', (tester) async {
        tester.view.physicalSize = compact ? const Size(320,568) : const Size(390,844);
        tester.view.devicePixelRatio = 1;
        tester.view.padding = const FakeViewPadding(top: 59,bottom: 34);
        addTearDown(tester.view.reset);
        final user = _User(); final content = _Content();
        await di.reset();
        di.registerSingleton<UserProvider>(user); di.registerSingleton<ContentProvider>(content);
        addTearDown(() async { await di.reset(); user.dispose(); content.dispose(); });
        await tester.pumpWidget(ChangeNotifierProvider<UserProvider>.value(value: user, child: host(const PracticesScreen(), language: language, scale: compact ? 2 : 1, navigation: true)));
        await tester.pumpAndSettle();
        await capture(tester,'practices-$language-${compact ? '320-2x' : '390'}-top');
        await tester.drag(find.byType(ListView).first,const Offset(0,-1800));
        await tester.pumpAndSettle();
        await capture(tester,'practices-$language-${compact ? '320-2x' : '390'}-bottom');
        expect(tester.takeException(), isNull);
      });
    }
  }
}

class _User extends ChangeNotifier implements UserProvider {
  @override UserModel? get currentUser => UserModel.empty().copyWith(id: 'visual-review', name: 'Анастасия');
  @override dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}
class _Content extends ChangeNotifier implements ContentProvider {
  @override List<ArticleModel> get articles => [];
  @override dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}
