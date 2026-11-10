import 'dart:io';
import 'dart:typed_data';

import 'package:asteria_app/features/home/presentation/models/day_status.dart';
import 'package:asteria_app/features/home/presentation/models/day_status_assets.dart';
import 'package:asteria_app/features/home/presentation/widgets/day_status_icon.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('renders selected status asset at requested size', (
    tester,
  ) async {
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      const MaterialApp(
        home: DayStatusIcon(status: DayStatus.favorable, size: 14),
      ),
    );

    final sizedBox = tester.widget<SizedBox>(find.byType(SizedBox));
    final image = tester.widget<Image>(find.byType(Image));
    final asset = image.image as ResizeImage;
    final inner = asset.imageProvider as AssetImage;

    expect(sizedBox.width, 14);
    expect(sizedBox.height, 14);
    expect(image.width, 14);
    expect(image.height, 14);
    expect(image.fit, BoxFit.contain);
    expect(asset.width, 42);
    expect(asset.height, 42);
    expect(inner.assetName, 'assets/icons/day_status_favorable_star.png');
  });

  testWidgets('supports explicit semantics and exclusion', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Column(
          children: [
            DayStatusIcon(
              status: DayStatus.neutral,
              size: 25,
              semanticLabel: 'Нейтральный день',
            ),
            DayStatusIcon(
              status: DayStatus.unfavorable,
              size: 25,
              semanticLabel: 'Неблагоприятный день',
              excludeFromSemantics: true,
            ),
          ],
        ),
      ),
    );

    expect(find.bySemanticsLabel('Нейтральный день'), findsOneWidget);
    expect(find.bySemanticsLabel('Неблагоприятный день'), findsNothing);
  });

  testWidgets('loads and decodes every promoted status star asset', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Row(
          children: [
            DayStatusIcon(status: DayStatus.favorable, size: 14),
            DayStatusIcon(status: DayStatus.neutral, size: 14),
            DayStatusIcon(status: DayStatus.unfavorable, size: 14),
          ],
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
  });

  test('status star assets have transparent corners', () {
    for (final status in DayStatus.values) {
      for (final alpha in _cornerAlphas(status.iconAssetPath)) {
        expect(
          alpha,
          0,
          reason: '${status.iconAssetPath} must not render a square backdrop',
        );
      }

      for (final alpha in _edgeConnectedPreviewBackdropAlphas(
        status.iconAssetPath,
      )) {
        expect(
          alpha,
          0,
          reason:
              '${status.iconAssetPath} must not keep Figma preview checkerboard',
        );
      }
    }
  });
}

List<int> _cornerAlphas(String path) {
  final chunks = _decodePng(path);

  return [
    chunks.rows.first[3],
    chunks.rows.first[((chunks.width - 1) * 4) + 3],
    chunks.rows.last[3],
    chunks.rows.last[((chunks.width - 1) * 4) + 3],
  ];
}

List<int> _edgeConnectedPreviewBackdropAlphas(String path) {
  final chunks = _decodePng(path);
  final visited = <int>{};
  final queue = <int>[];

  void enqueue(int x, int y) {
    if (x < 0 || y < 0 || x >= chunks.width || y >= chunks.height) {
      return;
    }

    final key = (y * chunks.width) + x;
    if (visited.contains(key)) {
      return;
    }

    final index = x * 4;
    final row = chunks.rows[y];
    if (!_isPreviewBackdropPixel(
      row[index],
      row[index + 1],
      row[index + 2],
      row[index + 3],
    )) {
      return;
    }

    visited.add(key);
    queue.add(key);
  }

  for (var x = 0; x < chunks.width; x++) {
    enqueue(x, 0);
    enqueue(x, chunks.height - 1);
  }
  for (var y = 0; y < chunks.height; y++) {
    enqueue(0, y);
    enqueue(chunks.width - 1, y);
  }

  for (var cursor = 0; cursor < queue.length; cursor++) {
    final key = queue[cursor];
    final x = key % chunks.width;
    final y = key ~/ chunks.width;

    enqueue(x + 1, y);
    enqueue(x - 1, y);
    enqueue(x, y + 1);
    enqueue(x, y - 1);
  }

  return [
    for (final key in visited)
      chunks.rows[key ~/ chunks.width][((key % chunks.width) * 4) + 3],
  ];
}

bool _isPreviewBackdropPixel(int r, int g, int b, int a) {
  if (a == 0) {
    return true;
  }

  final maxChannel = [r, g, b].reduce((a, b) => a > b ? a : b);
  final minChannel = [r, g, b].reduce((a, b) => a < b ? a : b);
  final spread = maxChannel - minChannel;

  return (spread <= 24 && minChannel >= 108) ||
      (a <= 48 && spread <= 36 && minChannel >= 80);
}

_DecodedPng _decodePng(String path) {
  final png = File(path).readAsBytesSync();
  final chunks = _PngChunks(png);
  final inflated = ZLibDecoder().convert(chunks.idat);
  final stride = chunks.width * 4;
  final rows = <Uint8List>[];
  var offset = 0;
  var previous = Uint8List(stride);

  for (var y = 0; y < chunks.height; y++) {
    final filter = inflated[offset++];
    final scanline = inflated.sublist(offset, offset + stride);
    offset += stride;
    final row = Uint8List(stride);

    for (var x = 0; x < stride; x++) {
      final left = x >= 4 ? row[x - 4] : 0;
      final up = previous[x];
      final upLeft = x >= 4 ? previous[x - 4] : 0;
      final value = scanline[x];

      row[x] = switch (filter) {
        0 => value,
        1 => (value + left) & 0xFF,
        2 => (value + up) & 0xFF,
        3 => (value + ((left + up) >> 1)) & 0xFF,
        4 => (value + _paeth(left, up, upLeft)) & 0xFF,
        _ => throw FormatException('Unsupported PNG filter $filter in $path'),
      };
    }

    rows.add(row);
    previous = row;
  }

  return _DecodedPng(width: chunks.width, height: chunks.height, rows: rows);
}

int _paeth(int left, int up, int upLeft) {
  final prediction = left + up - upLeft;
  final leftDistance = (prediction - left).abs();
  final upDistance = (prediction - up).abs();
  final upLeftDistance = (prediction - upLeft).abs();

  if (leftDistance <= upDistance && leftDistance <= upLeftDistance) {
    return left;
  }
  if (upDistance <= upLeftDistance) {
    return up;
  }
  return upLeft;
}

class _PngChunks {
  _PngChunks(Uint8List png) {
    var offset = 8;

    while (offset < png.length) {
      final length = _readUint32(png, offset);
      final type = String.fromCharCodes(png.sublist(offset + 4, offset + 8));
      final chunk = png.sublist(offset + 8, offset + 8 + length);
      offset += 12 + length;

      if (type == 'IHDR') {
        width = _readUint32(chunk, 0);
        height = _readUint32(chunk, 4);
        final bitDepth = chunk[8];
        final colorType = chunk[9];
        if (bitDepth != 8 || colorType != 6) {
          throw FormatException('Expected 8-bit RGBA PNG, got $pathSummary');
        }
      } else if (type == 'IDAT') {
        idat.addAll(chunk);
      } else if (type == 'IEND') {
        break;
      }
    }
  }

  late final int width;
  late final int height;
  final idat = <int>[];

  String get pathSummary => 'bitDepth/colorType mismatch';
}

int _readUint32(List<int> bytes, int offset) {
  return ByteData.sublistView(
    Uint8List.fromList(bytes),
    offset,
    offset + 4,
  ).getUint32(0);
}

class _DecodedPng {
  const _DecodedPng({
    required this.width,
    required this.height,
    required this.rows,
  });

  final int width;
  final int height;
  final List<Uint8List> rows;
}
