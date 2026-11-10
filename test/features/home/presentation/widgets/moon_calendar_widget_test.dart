import 'package:asteria_app/app/providers/content_provider.dart';
import 'package:asteria_app/app/providers/user_provider.dart';
import 'package:asteria_app/app/data/repositories/content/content_repository.dart';
import 'package:asteria_app/app/data/repositories/user/user_repository.dart';
import 'package:asteria_app/core/localization/localization.dart';
import 'package:asteria_app/core/ui_kit/ui_kit.dart';
import 'package:asteria_app/features/compatibility/domain/repositories/compatibility_repository.dart';
import 'package:asteria_app/features/home/presentation/cubit/moon_screen_cubit.dart';
import 'package:asteria_app/features/home/presentation/cubit/moon_screen_state.dart';
import 'package:asteria_app/features/home/presentation/models/day_status.dart';
import 'package:asteria_app/features/home/presentation/widgets/moon_calendar_widget.dart';
import 'package:asteria_app/features/home/presentation/widgets/moon_design_tokens.dart';
import 'package:asteria_app/features/home/presentation/widgets/moon_phase_marker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    await initializeDateFormatting('ru');
    final fonts = FontLoader('Urbanist')
      ..addFont(rootBundle.load('assets/fonts/urbanist/Urbanist-Regular.ttf'))
      ..addFont(rootBundle.load('assets/fonts/urbanist/Urbanist-SemiBold.ttf'));
    await fonts.load();
  });

  for (final viewportHeight in [740.0, 900.0]) {
    testWidgets('fits each month at viewport height $viewportHeight', (
      tester,
    ) async {
      _setCalendarViewport(tester);
      tester.view.physicalSize = Size(390, viewportHeight);
      final cubit = _TestMoonScreenCubit();
      addTearDown(cubit.close);

      // Four, six, then five weeks, exercising height changes in both directions.
      for (final month in [
        DateTime(2027, 2),
        DateTime(2026, 8),
        DateTime(2026, 9),
      ]) {
        cubit.replaceState(MoonScreenState(focusedDay: month));
        await tester.pumpWidget(_calendarApp(cubit, textScale: 1));
        await tester.pumpAndSettle();

        final visibleCells = find.byWidgetPredicate(
          (widget) =>
              widget is Semantics &&
              widget.properties.button == true &&
              widget.child is ExcludeSemantics,
        );
        final cells = tester.widgetList<Semantics>(visibleCells).toList();
        final lastCell = visibleCells.at(cells.length - 1);
        final cardBottom = tester
            .getBottomLeft(find.byType(MoonCalendarWidget))
            .dy;
        final lastCellBottom = tester.getBottomLeft(lastCell).dy;
        expect(cardBottom - lastCellBottom, inInclusiveRange(16, 18));

        for (var index = 0; index < cells.length; index++) {
          final label = cells[index].properties.label;
          final overlayCell = find.byWidgetPredicate(
            (widget) =>
                widget is Semantics &&
                widget.properties.label == label &&
                widget.child is SizedBox,
          );
          expect(overlayCell, findsOneWidget);
          expect(
            tester.getCenter(overlayCell).dy,
            closeTo(tester.getCenter(visibleCells.at(index)).dy, 0.1),
          );
        }
        expect(tester.takeException(), isNull);
      }
    });
  }

  testWidgets('renders star icons only for in-month dates with statuses', (
    tester,
  ) async {
    _setCalendarViewport(tester);
    final cubit = _TestMoonScreenCubit();
    addTearDown(cubit.close);
    final focusedDay = DateTime(2026, 5, 15);
    cubit.replaceState(
      MoonScreenState(
        focusedDay: focusedDay,
        selectedDate: DateTime(2026, 5, 2),
        dayStatuses: {
          DateTime(2026, 5, 1): DayStatus.favorable,
          DateTime(2026, 5, 2): DayStatus.neutral,
          DateTime(2026, 5, 3): DayStatus.unfavorable,
        },
      ),
    );

    await tester.pumpWidget(_calendarApp(cubit));
    await tester.pump();

    final assetNames = tester
        .widgetList<Image>(find.byType(Image))
        .map(_assetName)
        .whereType<String>()
        .toList();

    expect(assetNames, containsAll(_starAssetPaths));
    expect(
      assetNames.where(
        (assetName) => assetName.startsWith('assets/icons/day_status_'),
      ),
      everyElement(endsWith('_star.png')),
    );
    expect(
      assetNames.where(
        (assetName) => assetName == 'assets/icons/day_status_neutral_star.png',
      ),
      hasLength(1),
    );
    expect(
      find.byWidgetPredicate(
        (widget) =>
            widget is Semantics &&
            widget.properties.button == true &&
            (widget.properties.label ?? '').contains('Благоприятный день'),
      ),
      findsOneWidget,
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets('anchors phase stars above one- and two-digit dates', (
    tester,
  ) async {
    _setCalendarViewport(tester);
    final cubit = _TestMoonScreenCubit();
    addTearDown(cubit.close);
    final first = DateTime(2026, 5, 9);
    final second = DateTime(2026, 5, 17);
    for (final selected in [first, second]) {
      cubit.replaceState(
        MoonScreenState(
          focusedDay: first,
          selectedDate: selected,
          primaryPhaseDates: {first, second},
        ),
      );
      await tester.pumpWidget(_calendarApp(cubit, textScale: 1));
      await tester.pumpAndSettle();
      expect(find.byType(MoonPhaseMarker), findsNWidgets(2));
      for (final day in [first, second]) {
        final number = find.text('${day.day}');
        final cell = _dayCellAncestor(tester.element(number));
        final marker = find.descendant(
          of: find.byElementPredicate((e) => e == cell),
          matching: find.byType(MoonPhaseMarker),
        );
        final star = tester.getCenter(marker);
        final numeral = tester.getRect(number);
        expect(star.dx, closeTo(numeral.right, 2));
        expect(star.dy, lessThan(numeral.top));
        expect(
          tester.widget<MoonPhaseMarker>(marker).color,
          day == selected
              ? AppColors.textPrimary
              : MoonDesignTokens.selectedDay,
        );
      }
    }
    expect(tester.takeException(), isNull);
  });

  testWidgets('renders selected day as a warm gradient without outer glow', (
    tester,
  ) async {
    _setCalendarViewport(tester);
    final cubit = _TestMoonScreenCubit();
    addTearDown(cubit.close);
    final selectedDate = DateTime(2026, 5, 2);
    cubit.replaceState(
      MoonScreenState(
        focusedDay: DateTime(2026, 5, 15),
        selectedDate: selectedDate,
        dayStatuses: {selectedDate: DayStatus.unfavorable},
      ),
    );

    await tester.pumpWidget(_calendarApp(cubit));
    await tester.pumpAndSettle();

    final decoration = _selectedDayBackgroundDecoration(tester);
    final highlightSize = tester.getSize(find.byKey(_selectedDayHighlightKey));

    expect(highlightSize, const Size(32, 57));
    expect(decoration.color, isNull);
    expect(decoration.boxShadow, isNull);
    expect(decoration.gradient, isA<LinearGradient>());
    expect((decoration.gradient! as LinearGradient).colors, const [
      Color(0xFFE6994D),
      Color(0xFFF3B76A),
      Color(0xFFE6994D),
    ]);
  });

  testWidgets('keeps selection glow clipped inside the warm capsule', (
    tester,
  ) async {
    _setCalendarViewport(tester);
    final cubit = _TestMoonScreenCubit();
    addTearDown(cubit.close);
    final favorableDate = DateTime(2026, 5, 1);
    cubit.replaceState(
      MoonScreenState(
        focusedDay: DateTime(2026, 5, 15),
        selectedDate: favorableDate,
        dayStatuses: {favorableDate: DayStatus.favorable},
      ),
    );

    await tester.pumpWidget(_calendarApp(cubit));
    await tester.pumpAndSettle();

    final decoration = _selectedDayInnerGlowDecoration(tester);
    final glowSize = tester.getSize(find.byKey(_selectedDayInnerGlowKey));

    expect(find.byKey(_selectedDaySelectionGlowKey), findsNothing);
    expect(find.byKey(_selectedDayStatusGlowKey), findsNothing);
    expect(glowSize, const Size(32, 42));
    expect(decoration.gradient, isA<RadialGradient>());
    final gradient = decoration.gradient! as RadialGradient;
    expect(
      gradient.colors.first,
      const Color(0xFFFFD8A6).withValues(alpha: 0.58),
    );
    expect(gradient.colors.last, const Color(0x00F3B76A));

    final highlightAnimation = tester
        .widgetList<TweenAnimationBuilder<double>>(
          find.byType(TweenAnimationBuilder<double>),
        )
        .firstWhere((widget) => widget.duration.inMilliseconds == 380);

    expect(highlightAnimation.curve, Curves.easeOutCubic);
  });

  testWidgets('changes month when the visible next chevron is tapped', (
    tester,
  ) async {
    _setCalendarViewport(tester);
    final cubit = _TestMoonScreenCubit();
    addTearDown(cubit.close);
    cubit.replaceState(
      MoonScreenState(
        focusedDay: DateTime(2026, 8, 25),
        selectedDate: DateTime(2026, 8, 25),
      ),
    );

    await tester.pumpWidget(_calendarApp(cubit));
    await tester.pumpAndSettle();

    expect(find.textContaining('Август 2026'), findsOneWidget);

    await tester.tap(find.byTooltip('Следующий месяц'));
    await tester.pumpAndSettle();

    expect(find.textContaining('Сентябрь 2026'), findsOneWidget);
    expect(cubit.requestedMonths, [DateTime.utc(2026, 9)]);
  });
}

Widget _calendarApp(MoonScreenCubit cubit, {double textScale = 0.5}) {
  return BlocProvider<MoonScreenCubit>.value(
    value: cubit,
    child: MaterialApp(
      locale: const Locale('ru'),
      localizationsDelegates: const [
        AppLocalizations.delegate,
        ...GlobalMaterialLocalizations.delegates,
      ],
      supportedLocales: AppLocaleService.supportedLocales,
      home: Builder(
        builder: (context) => MediaQuery(
          data: MediaQuery.of(
            context,
          ).copyWith(textScaler: TextScaler.linear(textScale)),
          child: Theme(
            data: AppThemeDark.instance.getThemeData(context),
            child: const Scaffold(body: MoonCalendarWidget()),
          ),
        ),
      ),
    ),
  );
}

Element _dayCellAncestor(Element element) {
  Element? dayCell;
  element.visitAncestorElements((ancestor) {
    final widget = ancestor.widget;
    if (widget is Semantics && widget.properties.button == true) {
      dayCell = ancestor;
      return false;
    }
    return true;
  });

  return dayCell!;
}

BoxDecoration _selectedDayBackgroundDecoration(WidgetTester tester) {
  final decoratedBox = tester.widget<DecoratedBox>(
    find.byKey(_selectedDayBackgroundKey),
  );

  return decoratedBox.decoration as BoxDecoration;
}

BoxDecoration _selectedDayInnerGlowDecoration(WidgetTester tester) {
  final decoratedBox = tester.widget<DecoratedBox>(
    find.byKey(_selectedDayInnerGlowKey),
  );

  return decoratedBox.decoration as BoxDecoration;
}

void _setCalendarViewport(WidgetTester tester) {
  tester.view.devicePixelRatio = 1;
  tester.view.physicalSize = const Size(390, 900);
  addTearDown(tester.view.resetDevicePixelRatio);
  addTearDown(tester.view.resetPhysicalSize);
}

String? _assetName(Image image) {
  final provider = image.image;
  if (provider is AssetImage) return provider.assetName;
  if (provider is ResizeImage && provider.imageProvider is AssetImage) {
    return (provider.imageProvider as AssetImage).assetName;
  }
  return null;
}

const _starAssetPaths = {
  'assets/icons/day_status_favorable_star.png',
  'assets/icons/day_status_neutral_star.png',
  'assets/icons/day_status_unfavorable_star.png',
};

const _selectedDayBackgroundKey = ValueKey('selected-day-background');
const _selectedDayHighlightKey = ValueKey('selected-day-highlight');
const _selectedDayInnerGlowKey = ValueKey('selected-day-inner-glow');
const _selectedDaySelectionGlowKey = ValueKey('selected-day-selection-glow');
const _selectedDayStatusGlowKey = ValueKey('selected-day-status-glow');

class _TestMoonScreenCubit extends MoonScreenCubit {
  _TestMoonScreenCubit()
    : super(
        contentProvider: ContentProvider(
          contentRepository: _FakeContentRepository(),
          userProvider: UserProvider(userRepository: _FakeUserRepository()),
          compatibilityRepository: _FakeCompatibilityRepository(),
        ),
      );

  final List<DateTime> requestedMonths = [];

  void replaceState(MoonScreenState state) => emit(state);

  @override
  Future<void> loadDayStatuses(DateTime month) async {
    requestedMonths.add(DateTime.utc(month.year, month.month));
    emit(state.copyWith(focusedDay: month));
  }
}

class _FakeContentRepository implements ContentRepository {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _FakeUserRepository implements UserRepository {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _FakeCompatibilityRepository implements CompatibilityRepository {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}
