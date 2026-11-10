/// Stable event names sent to AppsFlyer.
///
/// Conventions:
/// - New custom events follow `<feature>_<action>` snake_case.
/// - Event names are stable: once shipped, prefer adding new events over
///   renaming existing ones.
abstract final class AnalyticsEvents {
  AnalyticsEvents._();

  // ========================================================================
  // App lifecycle
  // ========================================================================
  static const String appFirstOpen = 'app_first_open';
  static const String appOpen = 'app_open';

  // ========================================================================
  // Onboarding
  // ========================================================================
  static const String onboardingStart = 'onboarding_start';
  static const String onboardingStepView = 'onboarding_step_view';
  static const String onboardingStepCompleted = 'onboarding_step_completed';
  static const String onboardingSkipped = 'onboarding_skipped';
  static const String onboardingCompleted = 'onboarding_completed';

  // ========================================================================
  // Auth
  // ========================================================================
  static const String authStarted = 'auth_started';
  static const String authCodeRequested = 'auth_code_requested';
  static const String authCodeVerified = 'auth_code_verified';
  static const String authFailed = 'auth_failed';
  static const String signupCompleted = 'signup_completed';
  static const String loginCompleted = 'login_completed';
  static const String profileCompleted = 'profile_completed';

  // ========================================================================
  // Generic funnel / feature events. Always emit with feature_name.
  // ========================================================================
  static const String funnelStart = 'funnel_start';
  static const String inputStarted = 'input_started';
  static const String inputCompleted = 'input_completed';
  static const String calculationStarted = 'calculation_started';
  static const String calculationCompleted = 'calculation_completed';
  static const String resultView = 'result_view';
  static const String lockedContentView = 'locked_content_view';
  static const String paywallView = 'paywall_view';
  static const String paywallCtaClick = 'paywall_cta_click';
  static const String purchaseStart = 'purchase_start';
  static const String purchaseSuccess = 'purchase_success';
  static const String purchaseFailed = 'purchase_failed';
  static const String purchaseCancelled = 'purchase_cancelled';
  static const String purchaseRestored = 'purchase_restored';

  // ========================================================================
  // Compatibility
  // ========================================================================
  static const String compatibilityInputStarted = 'compatibility_input_started';
  static const String compatibilityInputCompleted =
      'compatibility_input_completed';
  static const String compatibilityCalculationCompleted =
      'compatibility_calculation_completed';
  static const String compatibilityResultView = 'compatibility_result_view';
  static const String compatibilityLockedInsightView =
      'compatibility_locked_insight_view';
  static const String compatibilityPaywallView = 'compatibility_paywall_view';
  static const String compatibilityUnlockClick = 'compatibility_unlock_click';
  static const String compatibilityPurchaseSuccess =
      'compatibility_purchase_success';

  // ========================================================================
  // Natal chart
  // ========================================================================
  static const String natalChartInputStarted = 'natal_chart_input_started';
  static const String natalChartInputCompleted = 'natal_chart_input_completed';
  static const String natalChartCalculationCompleted =
      'natal_chart_calculation_completed';
  static const String natalChartResultView = 'natal_chart_result_view';
  static const String natalChartLockedSectionView =
      'natal_chart_locked_section_view';
  static const String natalChartPaywallView = 'natal_chart_paywall_view';
  static const String natalChartUnlockClick = 'natal_chart_unlock_click';
  static const String natalChartPurchaseSuccess =
      'natal_chart_purchase_success';

  // ========================================================================
  // Sonnik
  // ========================================================================
  static const String sonnikFunnelStart = 'sonnik_funnel_start';
  static const String sonnikInputStarted = 'sonnik_input_started';
  static const String sonnikInputCompleted = 'sonnik_input_completed';
  static const String sonnikResultView = 'sonnik_result_view';
  static const String sonnikLockedContentView = 'sonnik_locked_content_view';
  static const String sonnikPaywallView = 'sonnik_paywall_view';
  static const String sonnikUnlockClick = 'sonnik_unlock_click';
  static const String sonnikPurchaseSuccess = 'sonnik_purchase_success';

  // ========================================================================
  // Anakra chat
  // ========================================================================
  static const String anakraChatOpen = 'anakra_chat_open';
  static const String anakraQuestionStarted = 'anakra_question_started';
  static const String anakraQuestionSent = 'anakra_question_sent';
  static const String anakraAnswerReceived = 'anakra_answer_received';
  static const String anakraLimitReached = 'anakra_limit_reached';
  static const String anakraPaywallView = 'anakra_paywall_view';
  static const String anakraUnlockClick = 'anakra_unlock_click';
  static const String anakraPurchaseSuccess = 'anakra_purchase_success';

  // ========================================================================
  // Tarot / runes / decks
  // ========================================================================
  static const String tarotCardView = 'tarot_card_view';
  static const String tarotDeckOpen = 'tarot_deck_open';
  static const String tarotSpreadStarted = 'tarot_spread_started';
  static const String tarotSpreadCompleted = 'tarot_spread_completed';
  static const String runeView = 'rune_view';
  static const String loveDeckOpen = 'love_deck_open';
  static const String loveDeckCardView = 'love_deck_card_view';
  static const String keltDeckOpen = 'kelt_deck_open';
  static const String keltDeckCardView = 'kelt_deck_card_view';

  // ========================================================================
  // Horoscope / moon / content
  // ========================================================================
  static const String horoscopeView = 'horoscope_view';
  static const String horoscopePaidBlockView = 'horoscope_paid_block_view';
  static const String horoscopeUnlockClick = 'horoscope_unlock_click';
  static const String moonCalendarView = 'moon_calendar_view';
  static const String moonCalendarMonthLoad = 'moon_calendar_month_load';
  static const String moonCalendarFallbackShown =
      'moon_calendar_fallback_shown';
  static const String moonCalendarContextChanged =
      'moon_calendar_context_changed';
  static const String moonDayView = 'moon_day_view';
  static const String contentSaved = 'content_saved';
  static const String contentShared = 'content_shared';
  static const String contentFavorited = 'content_favorited';

  // ========================================================================
  // Coins / subscription
  // ========================================================================
  static const String coinsPaywallView = 'coins_paywall_view';
  static const String coinsPackageSelected = 'coins_package_selected';
  static const String coinsPurchaseStart = 'coins_purchase_start';
  static const String coinsPurchaseSuccess = 'coins_purchase_success';
  static const String coinsPurchaseFailed = 'coins_purchase_failed';
  static const String coinsPurchaseCancelled = 'coins_purchase_cancelled';

  static const String subscriptionPaywallView = 'subscription_paywall_view';
  static const String subscriptionPlanSelected = 'subscription_plan_selected';
  static const String subscriptionTrialStarted = 'subscription_trial_started';
  static const String subscriptionPurchaseStart = 'subscription_purchase_start';
  static const String subscriptionPurchaseSuccess =
      'subscription_purchase_success';
  static const String subscriptionPurchaseFailed =
      'subscription_purchase_failed';
  static const String subscriptionCancelled = 'subscription_cancelled';
}
