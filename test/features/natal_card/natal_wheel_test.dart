import 'dart:ui' as ui;

import 'package:flutter/foundation.dart';
import 'package:asteria_app/app/data/models/user/user_model.dart';
import 'package:asteria_app/core/localization/localization.dart';
import 'package:asteria_app/core/ui_kit/theme/theme.dart';
import 'package:asteria_app/features/natal_card/widgets/natal_wheel.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets(
    'all ten clustered planets can be selected across the Aries boundary on a compact phone',
    (tester) async {
      final positions = [
        for (final (index, code) in [
          'sun',
          'moon',
          'mercury',
          'venus',
          'mars',
          'jupiter',
          'saturn',
          'uranus',
          'neptune',
          'pluto',
        ].indexed)
          _planet(code, (359.0 + index * .2) % 360),
      ];
      await _pump(tester, positions, exact: true);
      for (final planet in positions) {
        final target = find.byKey(ValueKey('natal-wheel-${planet.code}'));
        await tester.tapAt(tester.getCenter(target));
        await tester.pump();
        final state = tester.widget<Semantics>(
          find
              .descendant(
                of: target,
                matching: find.byWidgetPredicate(
                  (w) => w is Semantics && w.properties.button == true,
                ),
              )
              .first,
        );
        expect(state.properties.selected, isTrue, reason: planet.code);
        expect(find.text(state.properties.label!), findsOneWidget);
      }
      await tester.tapAt(
        tester.getCenter(find.byKey(const ValueKey('natal-wheel-pluto'))),
      );
      await tester.pump();
      expect(
        find.text('Коснись планеты, чтобы увидеть её связи'),
        findsOneWidget,
      );
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'an unknown birth time omits precise degrees; accessibility activation selects the planet',
    (tester) async {
      await _pump(tester, [
        _planet('moon', .25),
        _planet('ascendant', 90),
      ], exact: false);
      final button = tester.widget<Semantics>(
        find.byWidgetPredicate(
          (w) => w is Semantics && w.properties.label == 'Луна · Овен',
        ),
      );
      button.properties.onTap!();
      await tester.pump();
      expect(find.text('Луна · Овен'), findsOneWidget);
      expect(find.byKey(const ValueKey('natal-wheel-ascendant')), findsNothing);
      expect(tester.takeException(), isNull);
    },
  );
  testWidgets(
    'the wheel draws supplied house boundaries only with a known birth time',
    (tester) async {
      final planets = [_planet('sun', 14), _planet('mercury', 35)];
      final cusps = [
        for (var i = 0; i < 12; i++)
          HouseCuspModel(house: i + 1, longitude: (73.0 + i * 30) % 360),
      ];
      Future<Uint8List> render({
        required bool exact,
        required bool withHouses,
      }) async {
        await _pump(
          tester,
          planets,
          exact: exact,
          cusps: withHouses ? cusps : const [],
        );
        final layer = tester
            .widget<CustomPaint>(
              find
                  .descendant(
                    of: find.byType(NatalWheel),
                    matching: find.byWidgetPredicate(
                      (w) => w is CustomPaint && w.painter != null,
                    ),
                  )
                  .first,
            )
            .painter!;
        // Compare only the painted geometry, independently of asset decoding
        // or platform font rasterization on other machines.
        final pixels = await tester.runAsync(() async {
          final recorder = ui.PictureRecorder();
          layer.paint(Canvas(recorder), const Size.square(350));
          final picture = recorder.endRecording();
          final image = await picture.toImage(350, 350);
          final bytes = await image.toByteData();
          image.dispose();
          picture.dispose();
          return bytes!.buffer.asUint8List();
        });
        return pixels!;
      }

      final bare = await render(exact: true, withHouses: false);
      expect(
        listEquals(bare, await render(exact: true, withHouses: true)),
        isFalse,
      );
      expect(
        listEquals(bare, await render(exact: false, withHouses: true)),
        isTrue,
      );
    },
  );
}

PlanetHousePositionModel _planet(String code, double longitude) =>
    PlanetHousePositionModel(
      code: code,
      name: code,
      signCode: '',
      sign: '',
      house: 1,
      longitude: longitude,
    );

Future<void> _pump(
  WidgetTester tester,
  List<PlanetHousePositionModel> positions, {
  required bool exact,
  List<HouseCuspModel> cusps = const [],
}) async {
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
          child: MediaQuery(
            data: MediaQuery.of(context).copyWith(
              disableAnimations: true,
              textScaler: const TextScaler.linear(1.7),
            ),
            child: Scaffold(
              body: Center(
                child: SizedBox(
                  width: 320,
                  child: NatalWheel(
                    hasKnownBirthTime: exact,
                    data: PlanetsHousesDataModel(
                      data: '',
                      elements: const Elements(
                        fire: '1',
                        earth: '0',
                        air: '1',
                        water: '0',
                      ),
                      positions: positions,
                      houseCusps: cusps,
                    ),
                  ),
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
