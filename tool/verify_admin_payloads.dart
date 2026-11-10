import 'dart:convert';
import 'dart:io';

import 'package:asteria_app/app/data/models/affirmation/affirmation_model.dart';
import 'package:asteria_app/app/data/models/article/article_model.dart';
import 'package:asteria_app/app/data/models/energy_of_day/energy_of_day_model.dart';
import 'package:asteria_app/app/data/models/rune_of_day/rune_of_day_model.dart';
import 'package:asteria_app/app/data/models/shop_item/shop_item_model.dart';
import 'package:asteria_app/app/data/models/tarot_card/tarot_card_model.dart';

void main() {
  final input =
      jsonDecode(stdin.readLineSync() ?? '{}') as Map<String, dynamic>;
  final decoders = <String, Object Function(Map<String, dynamic>)>{
    'tarot_cards': TarotCardModel.fromJson,
    'rune_of_day': RuneOfDayModel.fromJson,
    'articles': ArticleModel.fromJson,
    'affirmation': AffirmationModel.fromJson,
    'energy_of_day': EnergyOfDayModel.fromJson,
    'shop_items': ShopItemModel.fromJson,
  };

  final counts = <String, int>{};
  for (final entry in decoders.entries) {
    final items = input[entry.key] as List<dynamic>? ?? const [];
    for (final item in items) {
      entry.value(Map<String, dynamic>.from(item as Map));
    }
    counts[entry.key] = items.length;
  }
  stdout.writeln(jsonEncode(counts));
}
