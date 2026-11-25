import 'package:asteria_app/features/practices/practice_catalog_screen.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('approved practice duration is shared by both languages', () {
    final russian = practicePreview('unhurried-morning', ru: true);
    final english = practicePreview('unhurried-morning', ru: false);
    expect(russian.title, 'Утро без спешки');
    expect(russian.metadata, startsWith('5 мин'));
    expect(english.title, 'An Unhurried Morning');
    expect(english.metadata, startsWith('5 min'));
  });
}
