part of 'user_model.dart';

class BalanceHistoryModel {
  final DateTime date;
  final BalanceHistoryType type;
  final int amount;
  final String description;

  const BalanceHistoryModel({required this.date, required this.type, required this.amount, required this.description});

  factory BalanceHistoryModel.fromJson(Map<String, dynamic> json) {
    return BalanceHistoryModel(
      date: DateTime.parse(json['date'] as String),
      type: BalanceHistoryType.values.firstWhere((e) => e.name == json['type'], orElse: () => BalanceHistoryType.deposit),
      amount: json['amount'] as int,
      description: json['description'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {'date': date.toIso8601String(), 'type': type.name, 'amount': amount, 'description': description};
  }

  BalanceHistoryModel copyWith({DateTime? date, BalanceHistoryType? type, int? amount, String? description}) {
    return BalanceHistoryModel(
      date: date ?? this.date,
      type: type ?? this.type,
      amount: amount ?? this.amount,
      description: description ?? this.description,
    );
  }
}
