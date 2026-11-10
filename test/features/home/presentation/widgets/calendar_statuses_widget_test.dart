import 'package:asteria_app/core/localization/localization.dart';
import 'package:asteria_app/core/ui_kit/theme/theme.dart';
import 'package:asteria_app/features/home/presentation/widgets/calendar_statuses_widget.dart';
import 'package:asteria_app/features/home/presentation/widgets/moon_phase_marker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('renders the three star status icons at legend size', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        locale: const Locale('ru'),
        localizationsDelegates: const [
          AppLocalizations.delegate,
          ...GlobalMaterialLocalizations.delegates,
        ],
        supportedLocales: AppLocaleService.supportedLocales,
        home: Builder(
          builder: (context) => Theme(
            data: AppThemeDark.instance.getThemeData(context),
            child: const Scaffold(body: CalendarStatusesWidget()),
          ),
        ),
      ),
    );

    final images = tester.widgetList<Image>(find.byType(Image)).toList();
    final assetNames = images.map(_assetName).whereType<String>().toSet();

    expect(assetNames, equals(_starAssetPaths));
    expect(images, hasLength(3));
    for (final image in images) {
      expect(image.width, 25);
      expect(image.height, 25);
    }
    expect(find.byType(MoonPhaseMarker), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('keeps the phase legend before a sphere is selected', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        locale: const Locale('ru'),
        localizationsDelegates: const [
          AppLocalizations.delegate,
          ...GlobalMaterialLocalizations.delegates,
        ],
        supportedLocales: AppLocaleService.supportedLocales,
        home: Builder(
          builder: (context) => Theme(
            data: AppThemeDark.instance.getThemeData(context),
            child: const Scaffold(body: CalendarStatusesWidget(visible: false)),
          ),
        ),
      ),
    );

    expect(find.byType(Image), findsNothing);
    expect(find.textContaining('день'), findsNothing);
    expect(find.byType(MoonPhaseMarker), findsOneWidget);
    expect(find.text('смена фазы Луны'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
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
