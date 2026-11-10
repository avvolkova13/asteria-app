import 'dart:async';

import 'package:asteria_app/app/data/models/user/user_model.dart';
import 'package:asteria_app/core/localization/localization.dart';
import 'package:asteria_app/core/location/city_search_service.dart';
import 'package:asteria_app/core/location/widgets/city_selection_screen.dart';
import 'package:asteria_app/core/ui_kit/ui_kit.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('renders city search field without global light fill', (
    tester,
  ) async {
    await tester.pumpWidget(
      _TestApp(
        home: CitySelectionScreen(citySearchService: _FakeCitySearchService()),
      ),
    );

    final textField = tester.widget<TextField>(find.byType(TextField));
    final decoration = textField.decoration;

    expect(decoration?.filled, isFalse);
    expect(decoration?.fillColor, Colors.transparent);
    expect(decoration?.border, InputBorder.none);
    expect(decoration?.enabledBorder, InputBorder.none);
    expect(decoration?.focusedBorder, InputBorder.none);
    expect(find.byIcon(CupertinoIcons.search), findsOneWidget);
  });

  testWidgets('returns confirmed manual city location', (tester) async {
    final citySearchService = _FakeCitySearchService()
      ..suggestions = const [
        CitySuggestion(placeId: 'almaty', description: 'Алматы, Казахстан'),
      ]
      ..locations = {
        'almaty': const CurrentLocationModel(
          location: 'Алматы, Казахстан',
          latitude: 43.2389,
          longitude: 76.8897,
          source: CurrentLocationSource.manual,
        ),
      };
    CitySelectionResult? selectedResult;

    await tester.pumpWidget(
      _TestApp(
        home: Builder(
          builder: (context) {
            return TextButton(
              onPressed: () async {
                final currentTheme = Theme.of(context);
                selectedResult = await Navigator.of(context).push(
                  MaterialPageRoute<CitySelectionResult>(
                    builder: (_) => Theme(
                      data: currentTheme,
                      child: CitySelectionScreen(
                        citySearchService: citySearchService,
                      ),
                    ),
                  ),
                );
              },
              child: const Text('open'),
            );
          },
        ),
      ),
    );

    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), 'Ал');
    await tester.pump(const Duration(milliseconds: 400));
    await tester.pumpAndSettle();

    expect(find.text('Алматы, Казахстан'), findsOneWidget);

    await tester.tap(find.text('Алматы, Казахстан'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));

    expect(selectedResult?.location.location, 'Алматы, Казахстан');
    expect(selectedResult?.location.source, CurrentLocationSource.manual);
    expect(selectedResult?.suggestion.placeId, 'almaty');
    expect(selectedResult?.suggestions.single.placeId, 'almaty');
  });

  testWidgets('ignores stale city search responses', (tester) async {
    final firstSearch = Completer<List<CitySuggestion>>();
    final secondSearch = Completer<List<CitySuggestion>>();
    final citySearchService = _FakeCitySearchService()
      ..searchResultsByQuery = {
        'Ал': firstSearch.future,
        'Аст': secondSearch.future,
      };

    await tester.pumpWidget(
      _TestApp(home: CitySelectionScreen(citySearchService: citySearchService)),
    );

    await tester.enterText(find.byType(TextField), 'Ал');
    await tester.pump(const Duration(milliseconds: 400));
    await tester.enterText(find.byType(TextField), 'Аст');
    await tester.pump(const Duration(milliseconds: 400));

    secondSearch.complete(const [
      CitySuggestion(placeId: 'astana', description: 'Астана, Казахстан'),
    ]);
    await tester.pump();
    await tester.pumpAndSettle();

    expect(find.text('Астана, Казахстан'), findsOneWidget);
    expect(find.text('Алматы, Казахстан'), findsNothing);

    firstSearch.complete(const [
      CitySuggestion(placeId: 'almaty', description: 'Алматы, Казахстан'),
    ]);
    await tester.pump();
    await tester.pumpAndSettle();

    expect(find.text('Астана, Казахстан'), findsOneWidget);
    expect(find.text('Алматы, Казахстан'), findsNothing);
  });
}

class _TestApp extends StatelessWidget {
  const _TestApp({required this.home});

  final Widget home;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      locale: const Locale('ru'),
      localizationsDelegates: const [
        AppLocalizations.delegate,
        ...GlobalMaterialLocalizations.delegates,
      ],
      supportedLocales: AppLocaleService.supportedLocales,
      home: Builder(
        builder: (context) {
          return Theme(
            data: AppThemeDark.instance.getThemeData(context),
            child: Scaffold(body: home),
          );
        },
      ),
    );
  }
}

class _FakeCitySearchService extends CitySearchService {
  _FakeCitySearchService() : super(googleMapsApiKey: 'test');

  List<CitySuggestion> suggestions = const [];
  Map<String, Future<List<CitySuggestion>>> searchResultsByQuery = const {};
  Map<String, CurrentLocationModel> locations = const {};

  @override
  Future<List<CitySuggestion>> searchCities(
    String query, {
    required String language,
  }) {
    return searchResultsByQuery[query] ?? Future.value(suggestions);
  }

  @override
  Future<CurrentLocationModel?> getLocationForSuggestion(
    CitySuggestion suggestion, {
    required String language,
  }) async {
    return locations[suggestion.placeId];
  }
}
