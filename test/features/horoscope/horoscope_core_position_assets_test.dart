import 'dart:io';
import 'dart:ui' as ui;

import 'package:asteria_app/features/horoscope/presentation/horoscope_core_position_assets.dart';
import 'package:asteria_app/features/horoscope/presentation/horoscope_screen.dart';
import 'package:asteria_app/core/ui_kit/theme/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('horoscopeCorePositionAssetFor', () {
    test('maps yearly core position labels to matching medallion assets', () {
      expect(
        horoscopeCorePositionAssetFor('Солнце в Близнецах'),
        'assets/images/horoscope/core_positions/sun.webp',
      );
      expect(
        horoscopeCorePositionAssetFor('Луна в Скорпионе'),
        'assets/images/horoscope/core_positions/moon.webp',
      );
      expect(
        horoscopeCorePositionAssetFor('Mercury in Taurus'),
        'assets/images/horoscope/core_positions/mercury.webp',
      );
      expect(
        horoscopeCorePositionAssetFor('Северный узел в Овне'),
        'assets/images/horoscope/core_positions/north_node.webp',
      );
      expect(
        horoscopeCorePositionAssetFor('Part of Fortune in Leo'),
        'assets/images/horoscope/core_positions/fortune.webp',
      );
    });

    test(
      'uses the vertex medallion for ascendant or unknown angular labels',
      () {
        expect(
          horoscopeCorePositionAssetFor('Асцендент в Весах'),
          'assets/images/horoscope/core_positions/vertex.webp',
        );
        expect(
          horoscopeCorePositionAssetFor('Unknown point'),
          'assets/images/horoscope/core_positions/vertex.webp',
        );
      },
    );

    test(
      'loads every mapped medallion asset from the Flutter bundle',
      () async {
        final labels = <String>[
          'Солнце',
          'Луна',
          'Меркурий',
          'Венера',
          'Марс',
          'Юпитер',
          'Сатурн',
          'Уран',
          'Нептун',
          'Плутон',
          'Хирон',
          'Лилит',
          'Селена',
          'Северный узел',
          'Южный узел',
          'Колесо Фортуны',
          'Вертекс',
        ];

        for (final label in labels) {
          final data = await rootBundle.load(
            horoscopeCorePositionAssetFor(label),
          );
          expect(data.lengthInBytes, greaterThan(0), reason: label);
        }
      },
    );
  });

  testWidgets('core position card keeps the medallion out of text content', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(390, 640));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) => Theme(
            data: AppThemeDark.instance.getThemeData(context),
            child: const Scaffold(
              body: Center(
                child: SizedBox(
                  width: 325,
                  child: HoroscopeCorePositionCard(
                    title: 'Солнце в Близнецах',
                    description:
                        'Интеллект, любознательность, тяга к знаниям. Гибкость мышления и быстрая адаптация к новым обстоятельствам.',
                    imagePath:
                        'assets/images/horoscope/core_positions/sun.webp',
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pump();

    final cardFinder = find.byKey(const ValueKey('horoscope-core-card'));
    final imageFinder = find.byKey(const ValueKey('horoscope-core-card-image'));
    final titleFinder = find.text('Солнце в Близнецах');
    final descriptionFinder = find.text(
      'Интеллект, любознательность, тяга к знаниям. Гибкость мышления и быстрая адаптация к новым обстоятельствам.',
    );

    expect(tester.getSize(cardFinder).width, 325);
    expect(tester.getSize(imageFinder), const Size(130, 130));
    expect(
      tester.getTopRight(imageFinder).dx,
      greaterThan(tester.getTopRight(cardFinder).dx),
    );
    expect(
      tester.getTopLeft(imageFinder).dy,
      lessThanOrEqualTo(tester.getTopLeft(cardFinder).dy),
    );
    expect(
      tester.getTopLeft(titleFinder).dy - tester.getTopLeft(cardFinder).dy,
      greaterThanOrEqualTo(28),
    );
    expect(
      tester.getTopRight(titleFinder).dx,
      lessThan(tester.getTopLeft(imageFinder).dx),
    );
    expect(
      tester.getTopRight(descriptionFinder).dx,
      lessThan(tester.getTopLeft(imageFinder).dx),
    );
  });

  test('metaphor card uses the Figma darkening color under the image', () {
    final source = File(
      'lib/features/horoscope/presentation/horoscope_screen.dart',
    ).readAsStringSync();

    expect(source, contains('Color(0xFF151028)'));
  });

  test('metaphor icon uses proportional bounds without vertical letterbox', () {
    final source = File(
      'lib/features/horoscope/presentation/horoscope_screen.dart',
    ).readAsStringSync();

    expect(source, isNot(contains('height: 192')));
    expect(source, contains('height: 117'));
  });

  test('transformation feather asset and layout have no empty box', () async {
    final bytes = File(
      'assets/images/horoscope/year_transformation.webp',
    ).readAsBytesSync();
    final codec = await ui.instantiateImageCodec(bytes);
    final image = (await codec.getNextFrame()).image;
    try {
      expect(image.width, 1500);
      expect(image.height, 1022);
    } finally {
      image.dispose();
      codec.dispose();
    }

    final source = File(
      'lib/features/horoscope/presentation/horoscope_screen.dart',
    ).readAsStringSync();

    expect(source, isNot(contains('imageHeight: 164')));
    expect(source, contains('imageHeight: 98'));
    expect(source, contains('titleReservedImageWidth: 116'));
  });
}
