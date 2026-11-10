import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('mobile runtime has no direct Firestore dependency', () {
    final blockedPatterns = [
      'cloud_firestore',
      'firebase_core',
      'FirebaseFirestore',
      'Firebase.initializeApp',
      'FirebaseOptions',
      'FirebaseFunctionsApi',
      'FirestoreApiService',
      'cloudfunctions.net',
      'run.app',
      'firebase_functions_api',
      'firestore_api_service',
      'firestore_collection_names',
    ];
    final offenders = <String>[];

    _scanFile(File('pubspec.yaml'), blockedPatterns, offenders);
    for (final entity in Directory('lib').listSync(recursive: true)) {
      if (entity is File && entity.path.endsWith('.dart')) {
        _scanFile(entity, blockedPatterns, offenders);
      }
    }

    expect(offenders, isEmpty);
  });
}

void _scanFile(
  File file,
  List<String> blockedPatterns,
  List<String> offenders,
) {
  final content = file.readAsStringSync();
  for (final pattern in blockedPatterns) {
    if (content.contains(pattern)) {
      offenders.add('${file.path}: $pattern');
    }
  }
}
