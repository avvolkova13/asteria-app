import 'package:asteria_app/app/data/models/user/rune_deck_model.dart';
import 'package:asteria_app/app/data/models/user/tarot_deck_model.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('spread deck migration', () {
    test('legacy rune cards without an opened flag stay closed', () {
      final deck = RuneDeckModel.fromJson({
        'cards': [
          {'id': 'rune-1'},
        ],
      });

      expect(deck.cards, hasLength(3));
      expect(deck.cards.every((rune) => !rune.isOpened), isTrue);
      expect(deck.cards.first.id, 'rune-1');
    });

    test('legacy tarot cards without an opened flag stay closed', () {
      final deck = TarotDeckModel.fromJson({
        'cards': [
          {'id': 'card-1'},
        ],
      });

      expect(deck.cards, hasLength(3));
      expect(deck.cards.every((card) => !card.isOpened), isTrue);
      expect(deck.cards.first.id, 'card-1');
    });

    test('rune opened state uses snake case when serialized', () {
      const rune = RuneInDeckModel(id: 'rune-1', isOpened: true);

      expect(rune.toJson(), {'id': 'rune-1', 'is_opened': true});
      expect(RuneInDeckModel.fromJson(rune.toJson()).isOpened, isTrue);
    });

    test('tarot opened state uses snake case when serialized', () {
      const card = TarotCardInDeckModel(id: 'card-1', isOpened: true);

      expect(card.toJson(), {'id': 'card-1', 'is_opened': true});
      expect(TarotCardInDeckModel.fromJson(card.toJson()).isOpened, isTrue);
    });
  });
}
