import 'dart:io';

import 'package:asteria_app/app/data/models/natal_card/natal_card_model.dart';
import 'package:asteria_app/features/scenarios/strength_guidance.dart';
import 'package:asteria_app/features/scenarios/strength_scenario.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';

void main() {
  final date = DateTime(2026, 11, 10, 10);
  StrengthTip guidance(String reading, {String? day}) => buildStrengthTip(
    task: StrengthTask.explain,
    language: 'ru',
    date: date,
    reading: NatalCardInterpretationModel.fromJson({'talent_area': reading}),
    todayFocus: day,
  );

  test('the same task produces different sourced strengths for two charts', () {
    final examples = guidance('Вы умеете объяснять через примеры.');
    final ordered = guidance('Вы умеете структурировать сложную информацию.');
    expect(examples.title, contains('примеры'));
    expect(ordered.title, contains('упорядочивать'));
    expect(examples.action, isNot(ordered.action));
    expect(examples.natalSource, 'Вы умеете объяснять через примеры.');
  });

  test(
    'daily guidance adapts the action while preserving the supported trait',
    () {
      const birth = 'Вы умеете объяснять через примеры.';
      final detail = guidance(birth, day: 'Уделите внимание деталям.');
      final dialogue = guidance(birth, day: 'Задайте уточняющий вопрос.');
      expect(detail.title, dialogue.title);
      expect(detail.action, contains('проверьте'));
      expect(dialogue.action, contains('Спросите'));
      expect(detail.daySource, isNot(dialogue.daySource));
      expect(guidance(birth, day: 'Не задайте вопрос.').daySource, isNull);
      expect(
        guidance(birth, day: 'Проведите время на природе.').daySource,
        isNull,
      );
    },
  );

  test(
    'missing or contradictory natal evidence leaves an editorial situation tip',
    () {
      for (final reading in [
        '',
        'Вы не умеете структурировать информацию.',
        'Вы умеете слушать, но не любите структурировать информацию.',
      ]) {
        final result = guidance(reading, day: 'Уделите внимание деталям.');
        expect(result.title, 'Совет по ситуации');
        expect(result.natalSource, isNull);
        expect(result.daySource, isNull);
      }
      final source = guidance(
        'Вы умеете замечать сходство между разными событиями.',
      );
      expect(source.title, source.natalSource);
      expect(source.daySource, isNull);
    },
  );

  test(
    'saved results survive reopening and stay owned by one account',
    () async {
      final temp = await Directory.systemTemp.createTemp('strength-tips-test');
      Hive.init(temp.path);
      addTearDown(() async {
        await Hive.close();
        await temp.delete(recursive: true);
      });
      var box = await Hive.openBox<Map>('tips');
      final alice = StrengthTipStore(box, 'alice');
      final sample = guidance(
        'Вы умеете объяснять через примеры.',
        day: 'Задайте вопрос.',
      );
      await alice.save(sample);
      await alice.save(sample);
      expect(StrengthTipStore(box, 'bob').read(), isEmpty);
      await box.close();
      box = await Hive.openBox<Map>('tips');
      expect(
        StrengthTipStore(box, 'alice').read().single.toJson(),
        sample.toJson(),
      );
    },
  );
}
