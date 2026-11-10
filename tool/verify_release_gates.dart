import 'dart:io';

const requiredEnglishLegalAssets = <String>[
  'assets/legal/en/ios/agreement.txt',
  'assets/legal/en/ios/privacy.txt',
  'assets/legal/en/android/agreement.txt',
  'assets/legal/en/android/privacy.txt',
];

void main() {
  final missing = requiredEnglishLegalAssets
      .where((path) => !File(path).existsSync())
      .toList(growable: false);
  if (missing.isNotEmpty) {
    stderr.writeln(
      'Release blocked: approved English legal assets are missing:',
    );
    for (final path in missing) {
      stderr.writeln('  - $path');
    }
    exitCode = 1;
  }
}
