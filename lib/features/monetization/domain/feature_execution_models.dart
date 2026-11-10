class FeatureExecutionDecisionModel {
  final String executionId;
  final String featureKey;
  final String status;
  final int chargedStars;
  final bool replayed;

  const FeatureExecutionDecisionModel({
    required this.executionId,
    required this.featureKey,
    required this.status,
    required this.chargedStars,
    required this.replayed,
  });

  bool get succeeded => status == 'succeeded';

  factory FeatureExecutionDecisionModel.fromJson(Map<String, dynamic> json) {
    return FeatureExecutionDecisionModel(
      executionId: json['execution_id'] as String? ?? '',
      featureKey: json['feature_key'] as String? ?? '',
      status: json['status'] as String? ?? '',
      chargedStars: (json['charged_stars'] as num?)?.toInt() ?? 0,
      replayed: json['replayed'] as bool? ?? false,
    );
  }
}

class TarotSpreadResultModel {
  final String executionId;
  final String spreadType;
  final List<String> cardIds;

  const TarotSpreadResultModel({
    required this.executionId,
    required this.spreadType,
    required this.cardIds,
  });

  factory TarotSpreadResultModel.fromJson(Map<String, dynamic> json) {
    return TarotSpreadResultModel(
      executionId: json['execution_id'] as String? ?? '',
      spreadType: json['spread_type'] as String? ?? '',
      cardIds: (json['card_ids'] as List<dynamic>? ?? const [])
          .map((item) => item.toString())
          .toList(growable: false),
    );
  }
}

class ClientFeatureResultModel {
  final String executionId;
  final String featureKey;
  final Map<String, dynamic> result;

  const ClientFeatureResultModel({
    required this.executionId,
    required this.featureKey,
    required this.result,
  });

  factory ClientFeatureResultModel.fromJson(Map<String, dynamic> json) {
    return ClientFeatureResultModel(
      executionId: json['execution_id'] as String? ?? '',
      featureKey: json['feature_key'] as String? ?? '',
      result: Map<String, dynamic>.from(json['result'] as Map? ?? const {}),
    );
  }
}
