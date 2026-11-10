enum RewardStatusValue { available, inProgress, completed, cooldown }

enum RewardErrorCode { startFailed, loadFailed, shareFailed }

enum RewardEventType {
  onboardingComplete('onboarding_complete'),
  tarotSpreadComplete('tarot_spread_complete'),
  articleRead('article_read'),
  shareComplete('share_complete'),
  dailyCheckIn('daily_check_in');

  final String wireValue;
  const RewardEventType(this.wireValue);
}

const Map<String, String> _rewardKeyToLegacyId = {
  'onboarding_complete': 'onboarding',
  'first_tarot_spread': 'tarot',
  'read_three_articles': 'articles',
  'monthly_share': 'share',
  'five_day_streak': 'login_streak',
};

const Map<String, String> _legacyIdToRewardKey = {
  'onboarding': 'onboarding_complete',
  'tarot': 'first_tarot_spread',
  'articles': 'read_three_articles',
  'share': 'monthly_share',
  'login_streak': 'five_day_streak',
};

const Map<String, ({String title, String frequency})> _rewardDisplay = {
  'onboarding': (title: 'Завершить онбординг', frequency: 'Разово'),
  'tarot': (title: 'Раскинуть Таро', frequency: 'Разово'),
  'articles': (title: 'Прочитать 3 статьи', frequency: 'Разово'),
  'share': (title: 'Поделиться в соцсетях', frequency: '1 раз в месяц'),
  'login_streak': (title: 'Зайти 5 дней подряд', frequency: 'Разово'),
};

class RewardStatusModel {
  final String id;
  final String title;
  final int amount;
  final String frequency;
  final RewardStatusValue status;
  final int current;
  final int target;
  final DateTime? nextAvailableAt;

  const RewardStatusModel({
    required this.id,
    required this.title,
    required this.amount,
    required this.frequency,
    required this.status,
    required this.current,
    required this.target,
    this.nextAvailableAt,
  });

  factory RewardStatusModel.fromJson(Map<String, dynamic> json) {
    final rawStatus = json['status'] as String? ?? 'available';
    final rawId = json['id'] as String? ?? json['key'] as String;
    final id = _rewardKeyToLegacyId[rawId] ?? rawId;
    final display = _rewardDisplay[id];
    return RewardStatusModel(
      id: id,
      title: json['title'] as String? ?? display?.title ?? id,
      amount: (json['amount'] as num).toInt(),
      frequency: json['frequency'] as String? ?? display?.frequency ?? '',
      status: switch (rawStatus) {
        'in_progress' => RewardStatusValue.inProgress,
        'completed' => RewardStatusValue.completed,
        'cooldown' => RewardStatusValue.cooldown,
        _ => RewardStatusValue.available,
      },
      current: (json['current'] as num).toInt(),
      target: (json['target'] as num).toInt(),
      nextAvailableAt: DateTime.tryParse(
        json['next_available_at'] as String? ?? '',
      ),
    );
  }
}

String rewardKeyForEvent(RewardEventType eventType) => switch (eventType) {
  RewardEventType.onboardingComplete => _legacyIdToRewardKey['onboarding']!,
  RewardEventType.tarotSpreadComplete => _legacyIdToRewardKey['tarot']!,
  RewardEventType.articleRead => _legacyIdToRewardKey['articles']!,
  RewardEventType.shareComplete => _legacyIdToRewardKey['share']!,
  RewardEventType.dailyCheckIn => _legacyIdToRewardKey['login_streak']!,
};

const List<RewardStatusModel> defaultRewardStatuses = [
  RewardStatusModel(
    id: 'onboarding',
    title: 'Завершить онбординг',
    amount: 5,
    frequency: 'Разово',
    status: RewardStatusValue.available,
    current: 0,
    target: 1,
  ),
  RewardStatusModel(
    id: 'tarot',
    title: 'Раскинуть Таро',
    amount: 5,
    frequency: 'Разово',
    status: RewardStatusValue.available,
    current: 0,
    target: 1,
  ),
  RewardStatusModel(
    id: 'articles',
    title: 'Прочитать 3 статьи',
    amount: 5,
    frequency: 'Разово',
    status: RewardStatusValue.inProgress,
    current: 0,
    target: 3,
  ),
  RewardStatusModel(
    id: 'share',
    title: 'Поделиться в соцсетях',
    amount: 30,
    frequency: '1 раз в месяц',
    status: RewardStatusValue.available,
    current: 0,
    target: 1,
  ),
  RewardStatusModel(
    id: 'login_streak',
    title: 'Зайти 5 дней подряд',
    amount: 25,
    frequency: 'Разово',
    status: RewardStatusValue.inProgress,
    current: 0,
    target: 5,
  ),
];

class RewardsResponseModel {
  final String? uid;
  final int balance;
  final int grantedAmount;
  final String? grantedRewardId;
  final List<RewardStatusModel> items;

  const RewardsResponseModel({
    this.uid,
    required this.balance,
    required this.grantedAmount,
    required this.grantedRewardId,
    required this.items,
  });

  factory RewardsResponseModel.fromJson(Map<String, dynamic> json) {
    final wallet = json['wallet'];
    final walletMap = wallet is Map ? Map<String, dynamic>.from(wallet) : null;
    final rawItems =
        json['items'] as List<dynamic>? ??
        json['rewards'] as List<dynamic>? ??
        const [];
    return RewardsResponseModel(
      uid: json['uid'] as String?,
      balance:
          (json['balance'] as num?)?.toInt() ??
          (walletMap?['balance'] as num?)?.toInt() ??
          0,
      grantedAmount: (json['granted_amount'] as num?)?.toInt() ?? 0,
      grantedRewardId:
          json['granted_reward_id'] as String? ??
          json['reward_key'] as String? ??
          json['grant_id'] as String?,
      items: rawItems
          .map(
            (item) => RewardStatusModel.fromJson(
              Map<String, dynamic>.from(item as Map),
            ),
          )
          .toList(growable: false),
    );
  }
}

class PendingRewardEvent {
  final String eventId;
  final String userId;
  final RewardEventType eventType;
  final String? referenceId;
  final int? timezoneOffsetMinutes;
  final DateTime createdAt;

  const PendingRewardEvent({
    required this.eventId,
    required this.userId,
    required this.eventType,
    required this.createdAt,
    this.referenceId,
    this.timezoneOffsetMinutes,
  });

  Map<String, dynamic> toJson() => {
    'event_id': eventId,
    'user_id': userId,
    'event_type': eventType.wireValue,
    'reference_id': referenceId,
    'timezone_offset_minutes': timezoneOffsetMinutes,
    'created_at': createdAt.toIso8601String(),
  };

  factory PendingRewardEvent.fromJson(Map<String, dynamic> json) {
    final wireType = json['event_type'] as String;
    return PendingRewardEvent(
      eventId: json['event_id'] as String,
      userId: json['user_id'] as String,
      eventType: RewardEventType.values.firstWhere(
        (type) => type.wireValue == wireType,
      ),
      referenceId: json['reference_id'] as String?,
      timezoneOffsetMinutes: json['timezone_offset_minutes'] as int?,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }
}
