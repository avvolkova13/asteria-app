import 'package:asteria_app/app/data/models/user/user_model.dart';
import 'package:asteria_app/features/balance/domain/reward_models.dart';

enum WalletHistoryType { deposit, withdraw }

enum WalletHistoryFilter { deposits, withdrawals, all }

class WalletHistoryPageModel {
  const WalletHistoryPageModel({
    required this.items,
    required this.nextBeforeSequence,
    required this.hasEntries,
  });

  final List<WalletHistoryEntryModel> items;
  final int? nextBeforeSequence;
  final bool hasEntries;

  factory WalletHistoryPageModel.fromJson(Map<String, dynamic> json) {
    final items = json['items'];
    final next = json['next_before_sequence'];
    if (items is! List ||
        json['has_entries'] is! bool ||
        !json.containsKey('next_before_sequence') ||
        (next != null && (next is! int || next < 1))) {
      throw const FormatException('Invalid wallet history page');
    }
    return WalletHistoryPageModel(
      items: items
          .map(
            (item) => WalletHistoryEntryModel.fromJson(
              Map<String, dynamic>.from(item as Map),
            ),
          )
          .toList(growable: false),
      nextBeforeSequence: next as int?,
      hasEntries: json['has_entries'] as bool,
    );
  }
}

class WalletHistoryEntryModel {
  final String entryId;
  final int sequence;
  final int signedAmount;
  final WalletHistoryType type;
  final int amount;
  final String description;
  final int balanceAfter;
  final DateTime createdAt;

  const WalletHistoryEntryModel({
    required this.entryId,
    required this.sequence,
    required this.signedAmount,
    required this.type,
    required this.amount,
    required this.description,
    required this.balanceAfter,
    required this.createdAt,
  });

  bool get isDeposit => type == WalletHistoryType.deposit;

  factory WalletHistoryEntryModel.fromJson(Map<String, dynamic> json) {
    final signedAmount = (json['amount'] as num?)?.toInt() ?? 0;
    return WalletHistoryEntryModel(
      entryId: json['entry_id'] as String? ?? '',
      sequence: (json['sequence'] as num?)?.toInt() ?? 0,
      signedAmount: signedAmount,
      type: signedAmount >= 0
          ? WalletHistoryType.deposit
          : WalletHistoryType.withdraw,
      amount: signedAmount.abs(),
      description:
          json['description'] as String? ??
          json['entry_type'] as String? ??
          json['business_key'] as String? ??
          '',
      balanceAfter: (json['balance_after'] as num?)?.toInt() ?? 0,
      createdAt:
          DateTime.tryParse(json['created_at'] as String? ?? '') ??
          DateTime.fromMillisecondsSinceEpoch(0),
    );
  }
}

class WalletSnapshotModel {
  final String uid;
  final int balance;
  final int debt;
  final int sequence;
  final int version;
  final DateTime? updatedAt;

  const WalletSnapshotModel({
    required this.uid,
    required this.balance,
    required this.debt,
    required this.sequence,
    required this.version,
    this.updatedAt,
  });

  factory WalletSnapshotModel.fromJson(Map<String, dynamic> json) {
    return WalletSnapshotModel(
      uid: json['uid'] as String,
      balance: (json['balance'] as num?)?.toInt() ?? 0,
      debt: (json['debt'] as num?)?.toInt() ?? 0,
      sequence: (json['sequence'] as num?)?.toInt() ?? 0,
      version: (json['version'] as num?)?.toInt() ?? 0,
      updatedAt: DateTime.tryParse(json['updated_at'] as String? ?? ''),
    );
  }

  WalletSnapshotModel copyWith({
    int? balance,
    int? debt,
    int? sequence,
    int? version,
    DateTime? updatedAt,
  }) {
    return WalletSnapshotModel(
      uid: uid,
      balance: balance ?? this.balance,
      debt: debt ?? this.debt,
      sequence: sequence ?? this.sequence,
      version: version ?? this.version,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

class RequestQuotaModel {
  final String feature;
  final int freeRemaining;
  final int paidRemaining;
  final int freeLimit;
  final DateTime periodStartedAt;
  final DateTime periodEndsAt;
  final DateTime updatedAt;

  const RequestQuotaModel({
    required this.feature,
    required this.freeRemaining,
    required this.paidRemaining,
    required this.freeLimit,
    required this.periodStartedAt,
    required this.periodEndsAt,
    required this.updatedAt,
  });

  int get totalRemaining => freeRemaining + paidRemaining;

  int get daysUntilReset {
    final diff = periodEndsAt.difference(DateTime.now());
    if (diff.isNegative) return 0;
    return diff.inDays + (diff.inHours % 24 == 0 ? 0 : 1);
  }

  factory RequestQuotaModel.empty(String feature) {
    final now = DateTime.now();
    return RequestQuotaModel(
      feature: feature,
      freeRemaining: 0,
      paidRemaining: 0,
      freeLimit: 3,
      periodStartedAt: now,
      periodEndsAt: now,
      updatedAt: now,
    );
  }

  factory RequestQuotaModel.fromJson(Map<String, dynamic> json) {
    return RequestQuotaModel(
      feature: json['feature'] as String? ?? '',
      freeRemaining: (json['free_remaining'] as num?)?.toInt() ?? 0,
      paidRemaining: (json['paid_remaining'] as num?)?.toInt() ?? 0,
      freeLimit: (json['free_limit'] as num?)?.toInt() ?? 0,
      periodStartedAt:
          DateTime.tryParse(json['period_started_at'] as String? ?? '') ??
          DateTime.fromMillisecondsSinceEpoch(0),
      periodEndsAt:
          DateTime.tryParse(json['period_ends_at'] as String? ?? '') ??
          DateTime.fromMillisecondsSinceEpoch(0),
      updatedAt:
          DateTime.tryParse(json['updated_at'] as String? ?? '') ??
          DateTime.fromMillisecondsSinceEpoch(0),
    );
  }
}

class RequestQuotaPurchaseResultModel {
  final String feature;
  final int quantity;
  final int price;
  final bool replayed;
  final WalletSnapshotModel wallet;
  final RequestQuotaModel quota;

  const RequestQuotaPurchaseResultModel({
    required this.feature,
    required this.quantity,
    required this.price,
    required this.replayed,
    required this.wallet,
    required this.quota,
  });

  factory RequestQuotaPurchaseResultModel.fromJson(Map<String, dynamic> json) {
    return RequestQuotaPurchaseResultModel(
      feature: json['feature'] as String? ?? '',
      quantity: (json['quantity'] as num?)?.toInt() ?? 0,
      price: (json['price'] as num?)?.toInt() ?? 0,
      replayed: json['replayed'] as bool? ?? false,
      wallet: WalletSnapshotModel.fromJson(
        Map<String, dynamic>.from(json['wallet'] as Map),
      ),
      quota: RequestQuotaModel.fromJson(
        Map<String, dynamic>.from(json['quota'] as Map),
      ),
    );
  }
}

class RequestQuotaConsumeResultModel {
  final String feature;
  final String source;
  final bool replayed;
  final RequestQuotaModel quota;

  const RequestQuotaConsumeResultModel({
    required this.feature,
    required this.source,
    required this.replayed,
    required this.quota,
  });

  factory RequestQuotaConsumeResultModel.fromJson(Map<String, dynamic> json) {
    return RequestQuotaConsumeResultModel(
      feature: json['feature'] as String? ?? '',
      source: json['source'] as String? ?? '',
      replayed: json['replayed'] as bool? ?? false,
      quota: RequestQuotaModel.fromJson(
        Map<String, dynamic>.from(json['quota'] as Map),
      ),
    );
  }
}

class RequestQuotaCommandResultModel {
  final String uid;
  final String feature;
  final String source;
  final bool replayed;
  final RequestQuotaModel quota;
  final Map<String, dynamic> result;
  final UserModel user;

  const RequestQuotaCommandResultModel({
    required this.uid,
    required this.feature,
    required this.source,
    required this.replayed,
    required this.quota,
    required this.result,
    required this.user,
  });

  factory RequestQuotaCommandResultModel.fromJson(Map<String, dynamic> json) {
    return RequestQuotaCommandResultModel(
      uid: json['uid'] as String? ?? '',
      feature: json['feature'] as String? ?? '',
      source: json['source'] as String? ?? '',
      replayed: json['replayed'] as bool? ?? false,
      quota: RequestQuotaModel.fromJson(
        Map<String, dynamic>.from(json['quota'] as Map),
      ),
      result: Map<String, dynamic>.from(json['result'] as Map? ?? const {}),
      user: UserModel.fromJson(Map<String, dynamic>.from(json['user'] as Map)),
    );
  }
}

class EntitlementGrantModel {
  final String entitlement;
  final String provider;
  final String productId;
  final String status;
  final DateTime? endsAt;
  final DateTime? graceUntil;
  final bool cancelAtPeriodEnd;

  const EntitlementGrantModel({
    required this.entitlement,
    required this.provider,
    required this.productId,
    required this.status,
    this.endsAt,
    this.graceUntil,
    required this.cancelAtPeriodEnd,
  });

  factory EntitlementGrantModel.fromJson(Map<String, dynamic> json) {
    return EntitlementGrantModel(
      entitlement: json['entitlement'] as String,
      provider: json['provider'] as String? ?? '',
      productId: json['product_id'] as String? ?? '',
      status: json['status'] as String? ?? '',
      endsAt: DateTime.tryParse(json['ends_at'] as String? ?? ''),
      graceUntil: DateTime.tryParse(json['grace_until'] as String? ?? ''),
      cancelAtPeriodEnd: json['cancel_at_period_end'] as bool? ?? false,
    );
  }
}

class MonetizationStateModel {
  final String uid;
  final int catalogRevision;
  final WalletSnapshotModel wallet;
  final bool effectivePro;
  final List<EntitlementGrantModel> effectiveGrants;
  final List<RewardStatusModel> rewards;
  final Map<String, RequestQuotaModel> requestQuotas;
  final Map<String, dynamic> rolloutPolicy;

  const MonetizationStateModel({
    required this.uid,
    required this.catalogRevision,
    required this.wallet,
    required this.effectivePro,
    required this.effectiveGrants,
    required this.rewards,
    required this.requestQuotas,
    required this.rolloutPolicy,
  });

  int get balance => wallet.balance;

  RequestQuotaModel requestQuota(String feature) =>
      requestQuotas[feature] ?? RequestQuotaModel.empty(feature);

  factory MonetizationStateModel.fromJson(Map<String, dynamic> json) {
    final quotaJson = Map<String, dynamic>.from(
      json['request_quotas'] as Map? ?? const {},
    );
    return MonetizationStateModel(
      uid: json['uid'] as String,
      catalogRevision: (json['catalog_revision'] as num?)?.toInt() ?? 0,
      wallet: WalletSnapshotModel.fromJson(
        Map<String, dynamic>.from(json['wallet'] as Map),
      ),
      effectivePro: json['effective_pro'] as bool? ?? false,
      effectiveGrants: (json['effective_grants'] as List<dynamic>? ?? const [])
          .map(
            (item) => EntitlementGrantModel.fromJson(
              Map<String, dynamic>.from(item as Map),
            ),
          )
          .toList(growable: false),
      rewards:
          (json['rewards'] as List<dynamic>? ??
                  json['items'] as List<dynamic>? ??
                  const [])
              .map(
                (item) => RewardStatusModel.fromJson(
                  Map<String, dynamic>.from(item as Map),
                ),
              )
              .toList(growable: false),
      requestQuotas: quotaJson.map(
        (key, value) => MapEntry(
          key,
          RequestQuotaModel.fromJson(Map<String, dynamic>.from(value as Map)),
        ),
      ),
      rolloutPolicy: Map<String, dynamic>.from(
        json['rollout_policy'] as Map? ?? const {},
      ),
    );
  }

  MonetizationStateModel copyWith({
    WalletSnapshotModel? wallet,
    bool? effectivePro,
    List<EntitlementGrantModel>? effectiveGrants,
    List<RewardStatusModel>? rewards,
    Map<String, RequestQuotaModel>? requestQuotas,
    Map<String, dynamic>? rolloutPolicy,
  }) {
    return MonetizationStateModel(
      uid: uid,
      catalogRevision: catalogRevision,
      wallet: wallet ?? this.wallet,
      effectivePro: effectivePro ?? this.effectivePro,
      effectiveGrants: effectiveGrants ?? this.effectiveGrants,
      rewards: rewards ?? this.rewards,
      requestQuotas: requestQuotas ?? this.requestQuotas,
      rolloutPolicy: rolloutPolicy ?? this.rolloutPolicy,
    );
  }
}
