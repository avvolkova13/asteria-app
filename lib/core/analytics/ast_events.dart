/// Centralized constants for `ast_*` product analytics events.
///
/// Naming convention:
///   - Event id in AppsFlyer: `ast_<feature>_<action>`
///   - Dart constant name: camelCase without the `ast` prefix
///     (e.g. `ast_compatibility_paywall_view` -> `compatibilityPaywallView`).
///
/// These names are **stable** — once data lands in AppsFlyer / dashboards,
/// renaming breaks downstream queries. Adding new ones is safe.
abstract final class AstEvents {
  AstEvents._();

  // ============================================================
  // Activation / auth
  // ============================================================

  static const String appOpen = 'ast_app_open';
  static const String onboardingStart = 'ast_onboarding_start';
  static const String onboardingComplete = 'ast_onboarding_complete';
  static const String authCodeVerifySuccess = 'ast_auth_code_verify_success';
  static const String authCodeVerifyFailed = 'ast_auth_code_verify_failed';
  static const String activationComplete = 'ast_activation_complete';
  static const String birthDataComplete = 'ast_birth_data_complete';

  // ============================================================
  // Home / discovery
  // ============================================================

  static const String homeView = 'ast_home_view';
  static const String homeCardView = 'ast_home_card_view';
  static const String homeCardClick = 'ast_home_card_click';

  // ============================================================
  // Compatibility
  // ============================================================

  static const String compatibilityStart = 'ast_compatibility_start';
  static const String compatibilityInputComplete =
      'ast_compatibility_input_complete';
  static const String compatibilityGenerationComplete =
      'ast_compatibility_generation_complete';
  static const String compatibilityResultView = 'ast_compatibility_result_view';
  static const String compatibilityLimitReached =
      'ast_compatibility_limit_reached';
  static const String compatibilityPaywallView =
      'ast_compatibility_paywall_view';
  static const String compatibilityPaywallClick =
      'ast_compatibility_paywall_click';
  static const String compatibilityPurchaseStart =
      'ast_compatibility_purchase_start';
  static const String compatibilityPurchaseSuccess =
      'ast_compatibility_purchase_success';
  static const String compatibilityPurchaseFailed =
      'ast_compatibility_purchase_failed';
  static const String compatibilityPurchaseExpired =
      'ast_compatibility_purchase_expired';

  // ============================================================
  // Natal chart
  // ============================================================

  static const String natalStart = 'ast_natal_start';
  static const String natalBirthDataComplete = 'ast_natal_birth_data_complete';
  static const String natalGenerationComplete = 'ast_natal_generation_complete';
  static const String natalResultView = 'ast_natal_result_view';
  static const String natalSectionView = 'ast_natal_section_view';
  static const String natalPaywallView = 'ast_natal_paywall_view';
  static const String natalPaywallClick = 'ast_natal_paywall_click';
  static const String natalPurchaseStart = 'ast_natal_purchase_start';
  static const String natalPurchaseSuccess = 'ast_natal_purchase_success';
  static const String natalPurchaseFailed = 'ast_natal_purchase_failed';
  static const String natalPurchaseExpired = 'ast_natal_purchase_expired';

  // ============================================================
  // Sonnik
  // ============================================================

  static const String sonnikStart = 'ast_sonnik_start';
  static const String sonnikDreamSubmit = 'ast_sonnik_dream_submit';
  static const String sonnikGenerationComplete =
      'ast_sonnik_generation_complete';
  static const String sonnikResultView = 'ast_sonnik_result_view';
  static const String sonnikLimitReached = 'ast_sonnik_limit_reached';
  static const String sonnikPaywallView = 'ast_sonnik_paywall_view';
  static const String sonnikPaywallClick = 'ast_sonnik_paywall_click';
  static const String sonnikPurchaseSuccess = 'ast_sonnik_purchase_success';
  static const String sonnikPurchaseFailed = 'ast_sonnik_purchase_failed';

  // ============================================================
  // Anakra
  // ============================================================

  static const String anakraStart = 'ast_anakra_start';
  static const String anakraMessageSent = 'ast_anakra_message_sent';
  static const String anakraResponseView = 'ast_anakra_response_view';
  static const String anakraQuickActionClick = 'ast_anakra_quick_action_click';
  static const String anakraLimitReached = 'ast_anakra_limit_reached';
  static const String anakraPaywallView = 'ast_anakra_paywall_view';
  static const String anakraPaywallClick = 'ast_anakra_paywall_click';
  static const String anakraPurchaseSuccess = 'ast_anakra_purchase_success';
  static const String anakraPurchaseFailed = 'ast_anakra_purchase_failed';

  // ============================================================
  // Tarot / runes / moon / affirmations
  // ============================================================

  static const String tarotStart = 'ast_tarot_start';
  static const String tarotCardReveal = 'ast_tarot_card_reveal';
  static const String tarotLockedView = 'ast_tarot_locked_view';
  static const String tarotPaywallView = 'ast_tarot_paywall_view';
  static const String tarotPurchaseSuccess = 'ast_tarot_purchase_success';

  static const String runesStart = 'ast_runes_start';
  static const String runesReveal = 'ast_runes_reveal';
  static const String runesLockedView = 'ast_runes_locked_view';
  static const String runesPaywallView = 'ast_runes_paywall_view';
  static const String runesPurchaseSuccess = 'ast_runes_purchase_success';

  static const String moonStart = 'ast_moon_start';
  static const String moonTabView = 'ast_moon_tab_view';
  static const String moonGenerationComplete = 'ast_moon_generation_complete';
  static const String moonPaywallView = 'ast_moon_paywall_view';
  static const String moonPurchaseSuccess = 'ast_moon_purchase_success';

  static const String affirmationsStart = 'ast_affirmations_start';
  static const String affirmationCardView = 'ast_affirmation_card_view';
  static const String affirmationEngagement = 'ast_affirmation_engagement';
  static const String affirmationLockedView = 'ast_affirmation_locked_view';
  static const String affirmationPaywallView = 'ast_affirmation_paywall_view';

  // ============================================================
  // Coins / internal spend / payments / subscription
  // ============================================================

  static const String coinSpendStart = 'ast_coin_spend_start';
  static const String coinSpendSuccess = 'ast_coin_spend_success';
  static const String coinSpendFailed = 'ast_coin_spend_failed';
  static const String coinPaywallView = 'ast_coin_paywall_view';
  static const String coinPackageSelect = 'ast_coin_package_select';
  static const String coinPurchaseStart = 'ast_coin_purchase_start';
  static const String coinPurchaseSuccess = 'ast_coin_purchase_success';
  static const String coinPurchaseFailed = 'ast_coin_purchase_failed';
  static const String coinPurchaseCancelled = 'ast_coin_purchase_cancelled';
  static const String coinPurchaseExpired = 'ast_coin_purchase_expired';

  static const String paymentMethodSelect = 'ast_payment_method_select';

  static const String subscriptionPaywallView = 'ast_subscription_paywall_view';
  static const String subscriptionPlanSelect = 'ast_subscription_plan_select';
  static const String subscriptionPurchaseStart =
      'ast_subscription_purchase_start';
  static const String subscriptionPurchaseSuccess =
      'ast_subscription_purchase_success';
  static const String subscriptionPurchaseFailed =
      'ast_subscription_purchase_failed';
  static const String subscriptionManageClick =
      'ast_subscription_manage_click';

  static const String purchaseRestoreClick = 'ast_purchase_restore_click';
  static const String purchaseRestoreSuccess = 'ast_purchase_restore_success';
  static const String purchaseRestoreFailed = 'ast_purchase_restore_failed';

  // ============================================================
  // Profile / shop / account actions
  // ============================================================

  static const String profileView = 'ast_profile_view';
  static const String profileMenuClick = 'ast_profile_menu_click';
  static const String shopView = 'ast_shop_view';
  static const String shopItemSelect = 'ast_shop_item_select';
  static const String accountLogout = 'ast_account_logout';
  static const String accountDelete = 'ast_account_delete';

  // ============================================================
  // P1 — generic / fallback events
  // ============================================================

  static const String screenView = 'ast_screen_view';
  static const String funnelStepView = 'ast_funnel_step_view';
  static const String contentEngagement = 'ast_content_engagement';
  static const String errorStateView = 'ast_error_state_view';
  static const String notificationPermissionResult =
      'ast_notification_permission_result';
}
