import 'package:asteria_app/app/data/models/user/user_model.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('reads persisted counters and preserves them through profile edits', () {
    final json = UserModel.empty().toJson()
      ..['statistics'] = {
        'tarot_cards_opened': 4,
        'horoscope_opened': 2,
        'runes_opened': 1,
      };
    final user = UserModel.fromJson(json).copyWith(name: 'Updated');
    expect(user.statistics.tarotCardsOpened, 4);
    expect(user.statistics.horoscopeOpened, 2);
    expect(user.statistics.runesOpened, 1);
    expect(user.toJson()['statistics'], json['statistics']);
  });

  test('legacy profiles without statistics start with zero progress', () {
    final json = UserModel.empty().toJson()..remove('statistics');
    final statistics = UserModel.fromJson(json).statistics;
    expect(statistics.tarotCardsOpened, 0);
    expect(statistics.horoscopeOpened, 0);
    expect(statistics.runesOpened, 0);
  });

  test('invalid counters cannot create negative remaining progress', () {
    final statistics = UserStatisticsModel.fromJson({
      'tarot_cards_opened': -2,
      'horoscope_opened': null,
      'runes_opened': 'invalid',
    });
    expect(statistics.toJson().values, everyElement(0));
  });
}
