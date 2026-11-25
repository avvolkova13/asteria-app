import 'package:asteria_app/features/home/presentation/models/day_status.dart';
import 'package:asteria_app/features/home/presentation/widgets/moon_calendar_widget.dart';
import 'package:asteria_app/features/home/presentation/widgets/day_status_icon.dart';
import 'package:asteria_app/core/localization/localization.dart';
import 'package:asteria_app/core/ui_kit/ui_kit.dart';
import 'package:asteria_app/features/scenarios/calendar_plan.dart';
import 'package:asteria_app/features/scenarios/calendar_plans_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';

CalendarPlan plan(String id, DateTime day) => CalendarPlan(
  id: id,
  owner: 'owner',
  day: day,
  activity: CalendarActivity.haircut,
  title: id,
  recommendation: null,
);

Future<void> host(
  WidgetTester tester, {
  List<CalendarPlan> plans = const [],
  DateTime? today,
  String locale = 'ru',
  String? region,
  double scale = 1,
  bool reducedMotion = true,
  Size size = const Size(390, 844),
  ValueChanged<CalendarPlan>? onOpen,
  VoidCallback? onChoose,
}) async {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
  await tester.pumpWidget(
    MaterialApp(
      locale: Locale(locale, region),
      supportedLocales: AppLocaleService.supportedLocales,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        ...GlobalMaterialLocalizations.delegates,
      ],
      home: Builder(
        builder: (c) => Theme(
          data: AppThemeDark.instance.getThemeData(c),
          child: MediaQuery(
            data: MediaQuery.of(c).copyWith(
              textScaler: TextScaler.linear(scale),
              disableAnimations: reducedMotion,
            ),
            child: Scaffold(
              body: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: CalendarPlansView(
                  plans: plans,
                  now: () => today ?? DateTime(2026, 11, 16),
                  onOpenPlan: onOpen ?? (_) {},
                  onChooseDate: onChoose ?? () {},
                ),
              ),
            ),
          ),
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

Future<void> tap(WidgetTester tester, Finder finder) async {
  await tester.ensureVisible(finder);
  await tester.tapAt(tester.getCenter(finder));
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('plans move beside the calendar when the available width grows', (
    tester,
  ) async {
    final saved = plan('Haircut', DateTime.utc(2026, 11, 16));
    await host(tester, plans: [saved], size: const Size(780, 1100));
    final calendar = find.byType(MoonCalendarWidget);
    final card = find.byKey(const ValueKey('saved-plan-Haircut'));
    expect(
      tester.getTopLeft(card).dy,
      greaterThan(tester.getBottomLeft(calendar).dy),
    );

    tester.view.physicalSize = const Size(1100, 780);
    await tester.pumpAndSettle();
    expect(
      tester.getTopLeft(card).dx,
      greaterThan(tester.getTopRight(calendar).dx),
    );
    expect(card.hitTestable(), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('British English uses a Monday-first day–month week label', (
    tester,
  ) async {
    await host(tester, locale: 'en', region: 'GB');

    await tap(tester, find.text('Week'));

    expect(find.text('16–22 Nov'), findsOneWidget);
    expect(
      tester
          .widget<TableCalendar<DayStatus>>(
            find.byType(TableCalendar<DayStatus>),
          )
          .startingDayOfWeek,
      StartingDayOfWeek.monday,
    );
  });

  testWidgets('compact English calendar keeps weekday and month words intact', (
    tester,
  ) async {
    await tester.runAsync(() async {
      final loader = FontLoader(AppTypography.headingFamily)
        ..addFont(
          rootBundle.load('assets/fonts/lora/Lora-VariableFont_wght.ttf'),
        );
      await loader.load();
    });
    await host(tester, locale: 'en', scale: 2, size: const Size(320, 568));

    List<TextBox> glyphBoxes(String text, int length) {
      final paragraph = tester.renderObject<RenderParagraph>(
        find.descendant(of: find.text(text), matching: find.byType(RichText)),
      );
      return paragraph.getBoxesForSelection(
        TextSelection(baseOffset: 0, extentOffset: length),
      );
    }

    for (final weekday in ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat']) {
      expect(
        glyphBoxes(weekday, weekday.length),
        hasLength(1),
        reason: weekday,
      );
    }

    await tap(tester, find.text('Week'));
    expect(find.text('Nov 15–21'), findsOneWidget);
    expect(glyphBoxes('Wed', 3), hasLength(1));

    await tap(tester, find.text('Day'));
    expect(glyphBoxes('November 2026', 8), hasLength(1));
    expect(tester.takeException(), isNull);
  });

  testWidgets('month and week show both activity icons on mixed-plan dates', (
    tester,
  ) async {
    final day = DateTime.utc(2026, 11, 18);
    await host(
      tester,
      scale: 2,
      size: const Size(320, 568),
      plans: [
        plan('Haircut', day),
        plan('Another haircut', day),
        CalendarPlan(
          id: 'plant',
          owner: 'owner',
          day: day,
          activity: CalendarActivity.transplant,
          title: 'Plant',
          recommendation: null,
        ),
      ],
    );
    final cell = find.byKey(const ValueKey('plans-date-2026-11-18'));
    for (final mode in ['Месяц', 'Неделя']) {
      await tap(tester, cell);
      await tap(tester, find.text(mode));
      final images = tester.widgetList<Image>(
        find.descendant(of: cell, matching: find.byType(Image)),
      );
      expect(
        images.map((image) {
          final provider = image.image;
          return ((provider is ResizeImage ? provider.imageProvider : provider)
                  as AssetImage)
              .assetName;
        }).toList(),
        [
          'assets/images/prediction_images/moon_card_beauty_haircut.webp',
          'assets/images/prediction_images/moon_card_gardening_transplanting_pricking.webp',
        ],
      );
      expect(tester.takeException(), isNull);
    }
  });

  testWidgets('month grid keeps six-week height across short and long months', (
    tester,
  ) async {
    await host(tester, today: DateTime(2027, 2, 1));
    double gridHeight() =>
        tester.getSize(find.byType(MoonCalendarWidget)).height;
    final height = gridHeight();
    for (var i = 0; i < 4; i++) {
      await tap(tester, find.byTooltip('Следующий период'));
      expect(gridHeight(), height);
      expect(tester.takeException(), isNull);
    }
  });

  testWidgets('month selects historical dates and opens every saved plan', (
    tester,
  ) async {
    CalendarPlan? opened;
    final first = plan('Стрижка', DateTime.utc(2026, 11, 12));
    final second = plan('Пересадка', DateTime(2026, 11, 12));
    await host(tester, plans: [first, second], onOpen: (p) => opened = p);
    expect(find.text('На этот день планов пока нет.'), findsOneWidget);
    expect(find.byType(DayStatusIcon), findsNothing);
    expect(
      find.byKey(const ValueKey('selected-day-highlight')),
      findsOneWidget,
    );
    expect(find.text('Пн'), findsOneWidget);
    await tap(tester, find.byKey(const ValueKey('plans-date-2026-11-12')));
    await tap(tester, find.text('Стрижка'));
    expect(opened, same(first));
    await tap(tester, find.text('Пересадка'));
    expect(opened, same(second));
    expect(find.text('Без указания времени'), findsNWidgets(2));
    await tap(tester, find.text('День'));
    expect(find.text('Стрижка'), findsOneWidget);
    await tap(tester, find.text('Сегодня, 16 ноября'));
    expect(find.text('Стрижка'), findsNothing);
  });

  testWidgets('month navigation clamps leap-year date and Today restores it', (
    tester,
  ) async {
    await host(
      tester,
      today: DateTime(2028, 1, 31),
      plans: [plan('Leap', DateTime.utc(2028, 2, 29))],
    );
    await tap(tester, find.byTooltip('Следующий период'));
    expect(find.text('Leap'), findsOneWidget);
    expect(find.byKey(const ValueKey('plans-date-2028-02-29')), findsOneWidget);
    expect(find.byKey(const ValueKey('plans-date-2028-02-30')), findsNothing);
    await tap(tester, find.text('Сегодня, 31 января'));
    expect(find.byKey(const ValueKey('plans-date-2028-01-31')), findsOneWidget);
    await tap(tester, find.byTooltip('Предыдущий период'));
    expect(find.byKey(const ValueKey('plans-date-2027-12-31')), findsOneWidget);
  });

  for (final locale in ['ru', 'en']) {
    testWidgets('$locale week respects local start and crosses the year', (
      tester,
    ) async {
      await host(
        tester,
        locale: locale,
        today: DateTime(2027, 1, 1),
        plans: [
          plan('Sunday', DateTime.utc(2026, 12, 27)),
          plan('Monday', DateTime.utc(2026, 12, 28)),
          plan('New year', DateTime.utc(2027, 1, 1)),
          plan('Next Sunday', DateTime.utc(2027, 1, 3)),
        ],
      );
      await tap(tester, find.text(locale == 'ru' ? 'Неделя' : 'Week'));
      expect(find.text('Monday'), findsOneWidget);
      expect(find.text('New year'), findsOneWidget);
      expect(
        find.text('Sunday'),
        locale == 'ru' ? findsNothing : findsOneWidget,
      );
      expect(
        find.text('Next Sunday'),
        locale == 'ru' ? findsOneWidget : findsNothing,
      );
      await tap(
        tester,
        find.byTooltip(locale == 'ru' ? 'Следующий период' : 'Next period'),
      );
      expect(find.text('Monday'), findsNothing);
    });
  }

  testWidgets('VoiceOver can activate a date and hear all plan counts', (
    tester,
  ) async {
    final semantics = tester.ensureSemantics();

    await host(
      tester,
      plans: List.generate(
        4,
        (i) => plan('Plan $i', DateTime.utc(2026, 11, 18)),
      ),
    );
    final date = find.bySemanticsLabel(RegExp('18 ноября.*Планов: 4'));
    final node = tester.getSemantics(date);
    expect(node.getSemanticsData().hasAction(SemanticsAction.tap), isTrue);
    tester.semantics.tap(
      find.semantics.byLabel(RegExp('18 ноября.*Планов: 4')),
    );
    await tester.pumpAndSettle();
    expect(find.text('Plan 3'), findsOneWidget);
    semantics.dispose();
  });

  testWidgets(
    'month paging animates without resizing and rapid reversal settles correctly',
    (tester) async {
      await host(tester, reducedMotion: false);
      final page = find.descendant(
        of: find.byWidgetPredicate((widget) => widget is TableCalendar),
        matching: find.byType(PageView),
      );
      PageController controller() => tester.widget<PageView>(page).controller!;
      final startPage = controller().page!;
      final height = tester.getSize(find.byType(MoonCalendarWidget)).height;
      await tester.tap(find.byTooltip('Следующий период'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));
      expect(controller().page, greaterThan(startPage));
      expect(controller().page, lessThan(startPage + 1));
      expect(tester.getSize(find.byType(MoonCalendarWidget)).height, height);
      await tester.tap(find.byTooltip('Предыдущий период'));
      await tester.pumpAndSettle();
      expect(controller().page, closeTo(startPage, .001));
      expect(find.text('Ноябрь 2026'), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'day mode changes height smoothly and interrupted mode switches recover',
    (tester) async {
      await host(tester, reducedMotion: false);
      final pane = find.byKey(const ValueKey('plans-calendar-transition'));
      final monthHeight = tester.getSize(pane).height;
      await tester.tap(find.text('День'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 80));
      final middleHeight = tester.getSize(pane).height;
      await tester.pumpAndSettle();
      final dayHeight = tester.getSize(pane).height;
      expect(middleHeight, lessThan(monthHeight));
      expect(middleHeight, greaterThan(dayHeight));
      await tester.tap(find.text('Месяц'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 50));
      await tester.tap(find.text('Неделя'));
      await tester.pumpAndSettle();
      expect(
        find.byKey(const ValueKey('plans-date-2026-11-16')),
        findsOneWidget,
      );
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('reduced motion switches month and day immediately', (
    tester,
  ) async {
    await host(tester);
    await tester.tap(find.byTooltip('Следующий период'));
    await tester.pump();
    final calendar = tester.widget<TableCalendar>(
      find.byWidgetPredicate((widget) => widget is TableCalendar),
    );
    expect(calendar.focusedDay.month, 12);
    expect(calendar.pageAnimationEnabled, isFalse);
    await tester.tap(find.text('День'));
    await tester.pump();
    final pane = find.byKey(const ValueKey('plans-calendar-transition'));
    final height = tester.getSize(pane).height;
    await tester.pump(const Duration(milliseconds: 100));
    expect(tester.getSize(pane).height, height);
    expect(find.byType(MoonCalendarWidget), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('period navigation stays within the original calendar range', (
    tester,
  ) async {
    for (final date in [DateTime(2000, 1, 1), DateTime(2050, 12, 31)]) {
      await tester.pumpWidget(const SizedBox());
      await host(tester, today: date);
      final label = date.year == 2000
          ? 'Предыдущий период'
          : 'Следующий период';
      for (final mode in ['Месяц', 'Неделя', 'День', 'Месяц']) {
        await tap(tester, find.text(mode));
        await tap(tester, find.byTooltip(label));
        expect(tester.takeException(), isNull);
      }
      expect(
        find.byKey(ValueKey('plans-date-${calendarDateKey(date)}')),
        findsOneWidget,
      );
    }
  });

  testWidgets('compact large-text modes and empty action remain usable', (
    tester,
  ) async {
    var chosen = false;
    await host(
      tester,
      scale: 2,
      size: const Size(320, 568),
      onChoose: () => chosen = true,
    );
    for (final mode in ['Неделя', 'День', 'Месяц']) {
      await tap(tester, find.text(mode));
      expect(tester.takeException(), isNull);
    }
    await tap(tester, find.text('Подобрать день'));
    expect(chosen, isTrue);
  });
}
