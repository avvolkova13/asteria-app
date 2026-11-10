import 'dart:io';

import 'package:integration_test/integration_test_driver_extended.dart';

Future<void> main() async {
  final screenshotDirectory = Directory(
    '${Directory.systemTemp.path}/asteria_ast127_screenshots',
  );
  await screenshotDirectory.create(recursive: true);

  await integrationDriver(
    onScreenshot: (name, bytes, [args]) async {
      final screenshot = File('${screenshotDirectory.path}/$name.png');
      await screenshot.writeAsBytes(bytes, flush: true);
      stdout.writeln('Saved AST-127 screenshot: ${screenshot.path}');
      return true;
    },
  );
}
