part of 'user_model.dart';

enum TimeOfDayEnum { morning, night, unknown }

enum Gender { male, female }

enum UserGroup { user, manager, admin }

enum SubscriptionType { free, pro }

enum SubscriptionProvider { apple, google, arcPay }

enum SubscriptionStatus { active, pastDue, canceled, expired, manualReview }

SubscriptionProvider? subscriptionProviderFromJson(Object? value) =>
    switch (value) {
      'apple' => SubscriptionProvider.apple,
      'google' => SubscriptionProvider.google,
      'arc_pay' => SubscriptionProvider.arcPay,
      _ => null,
    };

SubscriptionStatus? subscriptionStatusFromJson(Object? value) =>
    switch (value) {
      'active' => SubscriptionStatus.active,
      'past_due' => SubscriptionStatus.pastDue,
      'canceled' => SubscriptionStatus.canceled,
      'expired' => SubscriptionStatus.expired,
      'manual_review' => SubscriptionStatus.manualReview,
      _ => null,
    };

String? subscriptionProviderToJson(SubscriptionProvider? value) =>
    switch (value) {
      SubscriptionProvider.apple => 'apple',
      SubscriptionProvider.google => 'google',
      SubscriptionProvider.arcPay => 'arc_pay',
      null => null,
    };

String? subscriptionStatusToJson(SubscriptionStatus? value) => switch (value) {
  SubscriptionStatus.active => 'active',
  SubscriptionStatus.pastDue => 'past_due',
  SubscriptionStatus.canceled => 'canceled',
  SubscriptionStatus.expired => 'expired',
  SubscriptionStatus.manualReview => 'manual_review',
  null => null,
};

enum AuthMethod { email }

enum BalanceHistoryType { deposit, withdraw }
