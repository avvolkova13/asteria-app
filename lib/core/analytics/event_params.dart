/// Centralized parameter keys used across product analytics events.
///
/// Keep these stable — once data is in AppsFlyer / dashboards, renaming a
/// key breaks downstream queries. Adding new keys is safe.
abstract final class EventParams {
  EventParams._();

  // ─── User / identity ───
  static const String userId = 'user_id';
  static const String appsflyerId = 'appsflyer_id';
  static const String authMethod = 'auth_method';

  // ─── Attribution ───
  static const String trafficSource = 'traffic_source';
  static const String campaignId = 'campaign_id';
  static const String campaignName = 'campaign_name';
  static const String audienceSegment = 'audience_segment';
  static const String isOrganic = 'is_organic';
  static const String firstTouchAt = 'first_touch_at';
  static const String lastTouchAt = 'last_touch_at';
  static const String publisher = 'publisher';
  static const String placement = 'placement';
  static const String creativeId = 'creative_id';

  // ─── Funnel / feature ───
  static const String featureName = 'feature_name';
  static const String funnelType = 'funnel_type';
  static const String entrySurface = 'entry_surface';
  static const String originSurface = 'origin_surface';
  static const String stepName = 'step_name';
  static const String stepIndex = 'step_index';
  static const String resultStatus = 'result_status';
  static const String errorCode = 'error_code';
  static const String canonicalEvent = 'canonical_event';
  static const String calculationMode = 'calculation_mode';
  static const String rulesVersion = 'rules_version';
  static const String schemaVersion = 'schema_version';
  static const String statusContext = 'status_context';
  static const String phaseTone = 'phase_tone';
  static const String sphereStatus = 'sphere_status';

  // ─── User lifecycle / activation ───
  static const String isNewUser = 'is_new_user';
  static const String isSignup = 'is_signup';
  static const String stepsCount = 'steps_count';
  static const String completionSeconds = 'completion_seconds';

  // ─── Home / discovery ───
  static const String entryPointId = 'entry_point_id';
  static const String position = 'position';
  static const String ctaName = 'cta_name';
  static const String paywallCtaName = 'paywall_cta_name';
  static const String screenName = 'screen_name';

  // ─── Birth / profile inputs ───
  static const String hasBirthTime = 'has_birth_time';
  static const String birthTimePrecision = 'birth_time_precision';
  static const String hasBirthPlace = 'has_birth_place';
  static const String genderSelected = 'gender_selected';
  static const String inputMode = 'input_mode';
  static const String partnerDataCompleteness = 'partner_data_completeness';

  // ─── Free-text length bands (sonnik / anakra) ───
  static const String dreamLengthBand = 'dream_length_band';
  static const String messageLengthBand = 'message_length_band';
  static const String messageIndex = 'message_index';

  // ─── Generation / errors ───
  static const String generationStatus = 'generation_status';
  static const String generationSeconds = 'generation_seconds';
  static const String errorType = 'error_type';

  // ─── Limits / entitlement ───
  static const String limitType = 'limit_type';
  static const String requestsLeft = 'requests_left';
  static const String limitPeriod = 'limit_period';

  // ─── Paywall / purchase ───
  static const String paywallVariant = 'paywall_variant';
  static const String offerType = 'offer_type';
  static const String paymentType = 'payment_type';
  static const String productId = 'product_id';
  static const String productType = 'product_type';
  static const String packageId = 'package_id';
  static const String planId = 'plan_id';
  static const String price = 'price';
  static const String currency = 'currency';
  static const String afRevenue = 'af_revenue';
  static const String afCurrency = 'af_currency';
  static const String purchaseType = 'purchase_type';
  static const String paymentMethod = 'payment_method';
  static const String paymentMethodType = 'payment_method_type';
  static const String paymentProvider = 'payment_provider';
  static const String underlyingPaymentProvider = 'underlying_payment_provider';
  static const String platform = 'platform';
  static const String subscriptionState = 'subscription_state';
  static const String failureStage = 'failure_stage';
  static const String failureReason = 'failure_reason';
  static const String timeToExpire = 'time_to_expire';

  // ─── Coins / internal spend ───
  static const String coinAmount = 'coin_amount';
  static const String balanceBefore = 'balance_before';
  static const String balanceAfter = 'balance_after';

  // ─── Shop / profile ───
  static const String itemId = 'item_id';
  static const String itemType = 'item_type';
  static const String menuItem = 'menu_item';

  // ─── Content engagement (generic / P1) ───
  static const String contentType = 'content_type';
  static const String actionType = 'action_type';
  static const String contentId = 'content_id';

  // ─── Permissions (P1) ───
  static const String permissionType = 'permission_type';
  static const String permissionStatus = 'permission_status';
}
