import 'package:asteria_app/core/analytics/analytics_facade.dart';
import 'package:asteria_app/core/analytics/ast_events.dart';
import 'package:asteria_app/core/analytics/dictionaries/birth_time_precision.dart';
import 'package:asteria_app/core/analytics/dictionaries/entry_surface.dart';
import 'package:asteria_app/core/analytics/dictionaries/funnel_type.dart';
import 'package:asteria_app/core/analytics/dictionaries/generation_status.dart';
import 'package:asteria_app/core/analytics/dictionaries/length_band.dart';
import 'package:asteria_app/core/analytics/dictionaries/limit_period.dart';
import 'package:asteria_app/core/analytics/dictionaries/limit_type.dart';
import 'package:asteria_app/core/analytics/dictionaries/offer_type.dart';
import 'package:asteria_app/core/analytics/dictionaries/payment_method_type.dart';
import 'package:asteria_app/core/analytics/dictionaries/payment_type.dart';
import 'package:asteria_app/core/analytics/dictionaries/product_type.dart';
import 'package:asteria_app/core/analytics/event_params.dart';

/// Product analytics layer that emits `ast_*` events with a canonical event
/// mapping attached, while delegating delivery to [AnalyticsFacade].
///
/// Design contract:
///   - One method per `ast_*` event will be added in subsequent tasks (T6+).
///   - Every emitted event carries a `canonical_event` parameter (used for
///     BI / dashboard aggregation) inferred from [_canonicalEventMap].
///   - When the event name implies a feature funnel, `funnel_type` is
///     inferred and attached automatically — unless the caller passed an
///     explicit value.
///   - This service does NOT replace [AnalyticsFacade]. The facade still
///     handles legacy `af_*` events and P1 generic events. Both can coexist.
class ProductAnalyticsService {
  ProductAnalyticsService(this._facade);

  final AnalyticsFacade _facade;

  /// Full mapping `ast_event -> canonical_event` derived from the analytics
  /// taxonomy spec. Public for tests; do not mutate.
  static const Map<String, String> _canonicalEventMap = <String, String>{
    // ─── Activation / auth ───
    AstEvents.appOpen: 'app_open',
    AstEvents.onboardingStart: 'onboarding_start',
    AstEvents.onboardingComplete: 'onboarding_complete',
    AstEvents.authCodeVerifySuccess: 'auth_code_verify_success',
    AstEvents.authCodeVerifyFailed: 'auth_code_verify_failed',
    AstEvents.activationComplete: 'activation_complete',
    AstEvents.birthDataComplete: 'profile_birth_data_complete',

    // ─── Home / discovery ───
    AstEvents.homeView: 'home_view',
    AstEvents.homeCardView: 'funnel_entry_view',
    AstEvents.homeCardClick: 'funnel_entry_click',

    // ─── Compatibility ───
    AstEvents.compatibilityStart: 'funnel_start',
    AstEvents.compatibilityInputComplete: 'funnel_step_complete',
    AstEvents.compatibilityGenerationComplete: 'funnel_generation_complete',
    AstEvents.compatibilityResultView: 'funnel_result_view',
    AstEvents.compatibilityLimitReached: 'limit_reached',
    AstEvents.compatibilityPaywallView: 'paywall_view',
    AstEvents.compatibilityPaywallClick: 'paywall_cta_click',
    AstEvents.compatibilityPurchaseStart: 'purchase_start',
    AstEvents.compatibilityPurchaseSuccess: 'purchase_success',
    AstEvents.compatibilityPurchaseFailed: 'purchase_failed',
    AstEvents.compatibilityPurchaseExpired: 'purchase_expired',

    // ─── Natal chart ───
    AstEvents.natalStart: 'funnel_start',
    AstEvents.natalBirthDataComplete: 'funnel_step_complete',
    AstEvents.natalGenerationComplete: 'funnel_generation_complete',
    AstEvents.natalResultView: 'funnel_result_view',
    AstEvents.natalSectionView: 'content_engagement',
    AstEvents.natalPaywallView: 'paywall_view',
    AstEvents.natalPaywallClick: 'paywall_cta_click',
    AstEvents.natalPurchaseStart: 'purchase_start',
    AstEvents.natalPurchaseSuccess: 'purchase_success',
    AstEvents.natalPurchaseFailed: 'purchase_failed',
    AstEvents.natalPurchaseExpired: 'purchase_expired',

    // ─── Sonnik ───
    AstEvents.sonnikStart: 'funnel_start',
    AstEvents.sonnikDreamSubmit: 'funnel_step_complete',
    AstEvents.sonnikGenerationComplete: 'funnel_generation_complete',
    AstEvents.sonnikResultView: 'funnel_result_view',
    AstEvents.sonnikLimitReached: 'limit_reached',
    AstEvents.sonnikPaywallView: 'paywall_view',
    AstEvents.sonnikPaywallClick: 'paywall_cta_click',
    AstEvents.sonnikPurchaseSuccess: 'purchase_success',
    AstEvents.sonnikPurchaseFailed: 'purchase_failed',

    // ─── Anakra ───
    AstEvents.anakraStart: 'funnel_start',
    AstEvents.anakraMessageSent: 'funnel_step_complete',
    AstEvents.anakraResponseView: 'funnel_result_view',
    AstEvents.anakraQuickActionClick: 'content_engagement',
    AstEvents.anakraLimitReached: 'limit_reached',
    AstEvents.anakraPaywallView: 'paywall_view',
    AstEvents.anakraPaywallClick: 'paywall_cta_click',
    AstEvents.anakraPurchaseSuccess: 'purchase_success',
    AstEvents.anakraPurchaseFailed: 'purchase_failed',

    // ─── Tarot ───
    AstEvents.tarotStart: 'funnel_start',
    AstEvents.tarotCardReveal: 'funnel_step_complete',
    AstEvents.tarotLockedView: 'locked_content_view',
    AstEvents.tarotPaywallView: 'paywall_view',
    AstEvents.tarotPurchaseSuccess: 'purchase_success',

    // ─── Runes ───
    AstEvents.runesStart: 'funnel_start',
    AstEvents.runesReveal: 'funnel_step_complete',
    AstEvents.runesLockedView: 'locked_content_view',
    AstEvents.runesPaywallView: 'paywall_view',
    AstEvents.runesPurchaseSuccess: 'purchase_success',

    // ─── Moon / horoscope ───
    AstEvents.moonStart: 'funnel_start',
    AstEvents.moonTabView: 'content_engagement',
    AstEvents.moonGenerationComplete: 'funnel_generation_complete',
    AstEvents.moonPaywallView: 'paywall_view',
    AstEvents.moonPurchaseSuccess: 'purchase_success',

    // ─── Affirmations ───
    AstEvents.affirmationsStart: 'funnel_start',
    AstEvents.affirmationCardView: 'funnel_result_view',
    AstEvents.affirmationEngagement: 'content_engagement',
    AstEvents.affirmationLockedView: 'locked_content_view',
    AstEvents.affirmationPaywallView: 'paywall_view',

    // ─── Coins / internal spend ───
    AstEvents.coinSpendStart: 'internal_coin_spend_start',
    AstEvents.coinSpendSuccess: 'internal_coin_spend_success',
    AstEvents.coinSpendFailed: 'internal_coin_spend_failed',
    AstEvents.coinPaywallView: 'paywall_view',
    AstEvents.coinPackageSelect: 'funnel_step_complete',
    AstEvents.coinPurchaseStart: 'purchase_start',
    AstEvents.coinPurchaseSuccess: 'purchase_success',
    AstEvents.coinPurchaseFailed: 'purchase_failed',
    AstEvents.coinPurchaseCancelled: 'purchase_cancelled',
    AstEvents.coinPurchaseExpired: 'purchase_expired',

    // ─── Payment method ───
    AstEvents.paymentMethodSelect: 'payment_method_select',

    // ─── Subscription ───
    AstEvents.subscriptionPaywallView: 'paywall_view',
    AstEvents.subscriptionPlanSelect: 'funnel_step_complete',
    AstEvents.subscriptionPurchaseStart: 'purchase_start',
    AstEvents.subscriptionPurchaseSuccess: 'purchase_success',
    AstEvents.subscriptionPurchaseFailed: 'purchase_failed',
    AstEvents.subscriptionManageClick: 'subscription_manage_click',

    // ─── Purchase restore ───
    AstEvents.purchaseRestoreClick: 'purchase_restore_click',
    AstEvents.purchaseRestoreSuccess: 'purchase_restore_success',
    AstEvents.purchaseRestoreFailed: 'purchase_restore_failed',

    // ─── Profile / shop / account ───
    AstEvents.profileView: 'profile_view',
    AstEvents.profileMenuClick: 'profile_menu_click',
    AstEvents.shopView: 'shop_view',
    AstEvents.shopItemSelect: 'shop_item_select',
    AstEvents.accountLogout: 'account_logout',
    AstEvents.accountDelete: 'account_delete',

    // ─── P1 generic ───
    AstEvents.screenView: 'screen_view',
    AstEvents.funnelStepView: 'funnel_step_view',
    AstEvents.contentEngagement: 'content_engagement',
    AstEvents.errorStateView: 'error_state_view',
    AstEvents.notificationPermissionResult: 'permission_result',
  };

  /// Maps an `ast_*` event prefix to its `funnel_type` value.
  ///
  /// Order matters: more specific prefixes (e.g. `ast_affirmation_` vs
  /// `ast_affirmations_`) come first. Generic / P1 events (`ast_screen_view`
  /// etc.) intentionally return `null` — the caller must pass `funnel_type`
  /// explicitly when needed.
  static const List<MapEntry<String, String>> _funnelPrefixes =
      <MapEntry<String, String>>[
    MapEntry('ast_compatibility_', 'compatibility'),
    MapEntry('ast_natal_', 'natal_chart'),
    MapEntry('ast_sonnik_', 'sonnik'),
    MapEntry('ast_anakra_', 'anakra'),
    MapEntry('ast_tarot_', 'tarot'),
    MapEntry('ast_runes_', 'runes'),
    MapEntry('ast_moon_', 'moon'),
    MapEntry('ast_affirmations_', 'affirmations'),
    MapEntry('ast_affirmation_', 'affirmations'),
    MapEntry('ast_coin_', 'coins'),
    MapEntry('ast_subscription_', 'subscription'),
    MapEntry('ast_shop_', 'shop'),
    MapEntry('ast_profile_', 'profile'),
  ];

  String? _funnelTypeFor(String astEvent) {
    for (final entry in _funnelPrefixes) {
      if (astEvent.startsWith(entry.key)) return entry.value;
    }
    return null;
  }

  /// Internal: forwards an `ast_*` event to [AnalyticsFacade] with the
  /// canonical event and inferred funnel type merged in. Caller-supplied
  /// params take precedence over inferred ones.
  Future<void> _track(
    String astEvent, [
    Map<String, Object?>? params,
  ]) async {
    final canonical = _canonicalEventMap[astEvent];
    assert(
      canonical != null,
      'ProductAnalyticsService: missing canonical mapping for $astEvent',
    );

    final enriched = <String, dynamic>{};
    if (canonical != null) {
      enriched[EventParams.canonicalEvent] = canonical;
    }
    final inferredFunnel = _funnelTypeFor(astEvent);
    if (inferredFunnel != null) {
      enriched[EventParams.funnelType] = inferredFunnel;
    }

    if (params != null) {
      for (final entry in params.entries) {
        if (entry.value == null) continue;
        enriched[entry.key] = entry.value;
      }
    }

    await _facade.trackEvent(astEvent, params: enriched);
  }

  /// Generic escape hatch for tests and incremental rollout. Prefer the
  /// typed `track*` methods that will be added in T6+.
  Future<void> trackAstEvent(
    String astEvent, [
    Map<String, Object?>? params,
  ]) =>
      _track(astEvent, params);

  // ============================================================
  // T6 — Auth / activation
  // ============================================================

  /// `ast_auth_code_verify_success` — OTP code verified.
  ///
  /// [isSignup] — `true` if the user did not exist before this verify (i.e.
  /// activation flow), `false` for returning users.
  Future<void> trackAuthCodeVerifySuccess({required bool isSignup}) => _track(
        AstEvents.authCodeVerifySuccess,
        <String, Object?>{EventParams.isSignup: isSignup},
      );

  /// `ast_auth_code_verify_failed` — OTP code verification failed.
  ///
  /// [failureReason] — controlled value from [FailureReasons].
  Future<void> trackAuthCodeVerifyFailed({required String failureReason}) =>
      _track(
        AstEvents.authCodeVerifyFailed,
        <String, Object?>{EventParams.failureReason: failureReason},
      );

  /// `ast_activation_complete` — auth + mandatory profile/birth data done.
  Future<void> trackActivationComplete() =>
      _track(AstEvents.activationComplete);

  /// `ast_birth_data_complete` — mandatory birth data filled in.
  ///
  /// Pass `has_birth_time` / `has_birth_place` booleans without sending the
  /// actual values; [birthTimePrecision] describes how precise the time is.
  Future<void> trackBirthDataComplete({
    required bool hasBirthTime,
    required bool hasBirthPlace,
    BirthTimePrecision? birthTimePrecision,
  }) =>
      _track(AstEvents.birthDataComplete, <String, Object?>{
        EventParams.hasBirthTime: hasBirthTime,
        EventParams.hasBirthPlace: hasBirthPlace,
        if (birthTimePrecision != null)
          EventParams.birthTimePrecision: birthTimePrecision.value,
      });

  // ============================================================
  // T7 — Onboarding
  // ============================================================

  /// `ast_onboarding_start` — first onboarding screen shown.
  Future<void> trackOnboardingStart() => _track(AstEvents.onboardingStart);

  /// `ast_onboarding_complete` — onboarding finished.
  ///
  /// Both [stepsCount] and [completionSeconds] are optional per spec.
  Future<void> trackOnboardingComplete({
    int? stepsCount,
    int? completionSeconds,
  }) =>
      _track(AstEvents.onboardingComplete, <String, Object?>{
        if (stepsCount != null) EventParams.stepsCount: stepsCount,
        if (completionSeconds != null)
          EventParams.completionSeconds: completionSeconds,
      });

  // ============================================================
  // T8 — Home
  // ============================================================

  /// `ast_home_view` — home screen loaded.
  Future<void> trackHomeView() => _track(AstEvents.homeView);

  /// `ast_home_card_view` — funnel card/widget visible on home.
  ///
  /// [funnelType] is required; [entryPointId] and [position] help BI tie
  /// the click back to the impression.
  Future<void> trackHomeCardView({
    required FunnelType funnelType,
    String? entryPointId,
    int? position,
  }) =>
      _track(AstEvents.homeCardView, <String, Object?>{
        EventParams.funnelType: funnelType.value,
        if (entryPointId != null) EventParams.entryPointId: entryPointId,
        if (position != null) EventParams.position: position,
      });

  /// `ast_home_card_click` — user tapped a funnel card/CTA on home.
  Future<void> trackHomeCardClick({
    required FunnelType funnelType,
    String? entryPointId,
    int? position,
    String? ctaName,
  }) =>
      _track(AstEvents.homeCardClick, <String, Object?>{
        EventParams.funnelType: funnelType.value,
        if (entryPointId != null) EventParams.entryPointId: entryPointId,
        if (position != null) EventParams.position: position,
        if (ctaName != null) EventParams.ctaName: ctaName,
      });

  // ============================================================
  // T9 — Compatibility funnel
  // ============================================================

  /// `ast_compatibility_start` — user opened the initial compatibility screen.
  Future<void> trackCompatibilityStart({
    EntrySurface entrySurface = EntrySurface.unknown,
  }) =>
      _track(AstEvents.compatibilityStart, <String, Object?>{
        EventParams.entrySurface: entrySurface.value,
      });

  /// `ast_compatibility_input_complete` — user filled in partner data and
  /// tapped the calculate CTA.
  Future<void> trackCompatibilityInputComplete() =>
      _track(AstEvents.compatibilityInputComplete);

  /// `ast_compatibility_generation_complete` — backend / AI produced the
  /// compatibility result (or failed).
  Future<void> trackCompatibilityGenerationComplete({
    required GenerationStatus generationStatus,
    int? generationSeconds,
  }) =>
      _track(AstEvents.compatibilityGenerationComplete, <String, Object?>{
        EventParams.generationStatus: generationStatus.value,
        if (generationSeconds != null)
          EventParams.generationSeconds: generationSeconds,
      });

  /// `ast_compatibility_result_view` — result screen shown.
  Future<void> trackCompatibilityResultView() =>
      _track(AstEvents.compatibilityResultView);

  /// `ast_compatibility_limit_reached` — user ran out of free attempts /
  /// requests; the paywall / request-pack offer is about to be shown.
  Future<void> trackCompatibilityLimitReached({
    required LimitType limitType,
    int? requestsLeft,
    LimitPeriod limitPeriod = LimitPeriod.unknown,
  }) =>
      _track(AstEvents.compatibilityLimitReached, <String, Object?>{
        EventParams.limitType: limitType.value,
        if (requestsLeft != null) EventParams.requestsLeft: requestsLeft,
        EventParams.limitPeriod: limitPeriod.value,
      });

  /// `ast_compatibility_paywall_view` — paywall / request-pack / coins offer
  /// shown to the user.
  Future<void> trackCompatibilityPaywallView({
    required String originSurface,
    required OfferType offerType,
    String? paywallVariant,
  }) =>
      _track(AstEvents.compatibilityPaywallView, <String, Object?>{
        EventParams.originSurface: originSurface,
        EventParams.offerType: offerType.value,
        if (paywallVariant != null) EventParams.paywallVariant: paywallVariant,
      });

  /// `ast_compatibility_paywall_click` — user tapped a CTA on a compatibility
  /// paywall.
  Future<void> trackCompatibilityPaywallClick({
    required String originSurface,
    required OfferType offerType,
    String? ctaName,
    String? paywallVariant,
  }) =>
      _track(AstEvents.compatibilityPaywallClick, <String, Object?>{
        EventParams.originSurface: originSurface,
        EventParams.offerType: offerType.value,
        if (ctaName != null) EventParams.ctaName: ctaName,
        if (paywallVariant != null) EventParams.paywallVariant: paywallVariant,
      });

  // ============================================================
  // T10 — Natal chart funnel
  // ============================================================

  /// `ast_natal_start` — user opened the natal chart flow.
  Future<void> trackNatalStart({
    EntrySurface entrySurface = EntrySurface.unknown,
  }) =>
      _track(AstEvents.natalStart, <String, Object?>{
        EventParams.entrySurface: entrySurface.value,
      });

  /// `ast_natal_birth_data_complete` — birth data is ready for generation.
  Future<void> trackNatalBirthDataComplete() =>
      _track(AstEvents.natalBirthDataComplete);

  /// `ast_natal_generation_complete` — natal chart generated (or failed).
  Future<void> trackNatalGenerationComplete({
    required GenerationStatus generationStatus,
    int? generationSeconds,
  }) =>
      _track(AstEvents.natalGenerationComplete, <String, Object?>{
        EventParams.generationStatus: generationStatus.value,
        if (generationSeconds != null)
          EventParams.generationSeconds: generationSeconds,
      });

  /// `ast_natal_result_view` — natal chart result screen shown.
  Future<void> trackNatalResultView() => _track(AstEvents.natalResultView);

  /// `ast_natal_section_view` — user opened a section / tab inside the natal
  /// chart (e.g. houses, aspects, elements).
  Future<void> trackNatalSectionView({String? contentType}) =>
      _track(AstEvents.natalSectionView, <String, Object?>{
        if (contentType != null) EventParams.contentType: contentType,
      });

  /// `ast_natal_paywall_view` — natal chart paywall / unlock offer shown.
  Future<void> trackNatalPaywallView({
    required String originSurface,
    required OfferType offerType,
    String? paywallVariant,
  }) =>
      _track(AstEvents.natalPaywallView, <String, Object?>{
        EventParams.originSurface: originSurface,
        EventParams.offerType: offerType.value,
        if (paywallVariant != null) EventParams.paywallVariant: paywallVariant,
      });

  /// `ast_natal_paywall_click` — user tapped a CTA on the natal chart paywall.
  Future<void> trackNatalPaywallClick({
    required String originSurface,
    required OfferType offerType,
    String? ctaName,
    String? paywallVariant,
  }) =>
      _track(AstEvents.natalPaywallClick, <String, Object?>{
        EventParams.originSurface: originSurface,
        EventParams.offerType: offerType.value,
        if (ctaName != null) EventParams.ctaName: ctaName,
        if (paywallVariant != null) EventParams.paywallVariant: paywallVariant,
      });

  // ============================================================
  // T11 — Sonnik funnel
  // ============================================================

  /// `ast_sonnik_start` — user opened the sonnik flow.
  Future<void> trackSonnikStart({
    EntrySurface entrySurface = EntrySurface.unknown,
  }) =>
      _track(AstEvents.sonnikStart, <String, Object?>{
        EventParams.entrySurface: entrySurface.value,
      });

  /// `ast_sonnik_dream_submit` — user submitted a dream for interpretation.
  ///
  /// [dreamLengthBand] is bucketed client-side from the raw text BEFORE the
  /// text is discarded. Never send the raw dream text.
  Future<void> trackSonnikDreamSubmit({
    required LengthBand dreamLengthBand,
  }) =>
      _track(AstEvents.sonnikDreamSubmit, <String, Object?>{
        EventParams.dreamLengthBand: dreamLengthBand.value,
      });

  /// `ast_sonnik_generation_complete` — dream interpretation produced.
  Future<void> trackSonnikGenerationComplete({
    required GenerationStatus generationStatus,
    int? generationSeconds,
  }) =>
      _track(AstEvents.sonnikGenerationComplete, <String, Object?>{
        EventParams.generationStatus: generationStatus.value,
        if (generationSeconds != null)
          EventParams.generationSeconds: generationSeconds,
      });

  /// `ast_sonnik_result_view` — sonnik result screen shown.
  Future<void> trackSonnikResultView() => _track(AstEvents.sonnikResultView);

  /// `ast_sonnik_limit_reached` — user ran out of sonnik attempts.
  Future<void> trackSonnikLimitReached({
    required LimitType limitType,
    int? requestsLeft,
    LimitPeriod limitPeriod = LimitPeriod.unknown,
  }) =>
      _track(AstEvents.sonnikLimitReached, <String, Object?>{
        EventParams.limitType: limitType.value,
        if (requestsLeft != null) EventParams.requestsLeft: requestsLeft,
        EventParams.limitPeriod: limitPeriod.value,
      });

  /// `ast_sonnik_paywall_view` — sonnik paywall / request-pack offer shown.
  Future<void> trackSonnikPaywallView({
    required String originSurface,
    required OfferType offerType,
    String? paywallVariant,
  }) =>
      _track(AstEvents.sonnikPaywallView, <String, Object?>{
        EventParams.originSurface: originSurface,
        EventParams.offerType: offerType.value,
        if (paywallVariant != null) EventParams.paywallVariant: paywallVariant,
      });

  /// `ast_sonnik_paywall_click` — user tapped a CTA on the sonnik paywall.
  Future<void> trackSonnikPaywallClick({
    required String originSurface,
    required OfferType offerType,
    String? ctaName,
    String? paywallVariant,
  }) =>
      _track(AstEvents.sonnikPaywallClick, <String, Object?>{
        EventParams.originSurface: originSurface,
        EventParams.offerType: offerType.value,
        if (ctaName != null) EventParams.ctaName: ctaName,
        if (paywallVariant != null) EventParams.paywallVariant: paywallVariant,
      });

  // ============================================================
  // T12 — Anakra AI chat funnel
  // ============================================================

  /// `ast_anakra_start` — user opened the Anakra AI chat.
  Future<void> trackAnakraStart({
    EntrySurface entrySurface = EntrySurface.unknown,
  }) =>
      _track(AstEvents.anakraStart, <String, Object?>{
        EventParams.entrySurface: entrySurface.value,
      });

  /// `ast_anakra_message_sent` — user sent a message to Anakra.
  ///
  /// [messageLengthBand] is bucketed from the raw text BEFORE the text is
  /// discarded; never send the raw message. [messageIndex] is the 1-based
  /// position of this message in the current chat session.
  Future<void> trackAnakraMessageSent({
    required LengthBand messageLengthBand,
    required int messageIndex,
  }) =>
      _track(AstEvents.anakraMessageSent, <String, Object?>{
        EventParams.messageLengthBand: messageLengthBand.value,
        EventParams.messageIndex: messageIndex,
      });

  /// `ast_anakra_response_view` — AI response from Anakra rendered.
  Future<void> trackAnakraResponseView() =>
      _track(AstEvents.anakraResponseView);

  /// `ast_anakra_quick_action_click` — user tapped a quick action chip.
  Future<void> trackAnakraQuickActionClick({required String actionType}) =>
      _track(AstEvents.anakraQuickActionClick, <String, Object?>{
        EventParams.actionType: actionType,
      });

  /// `ast_anakra_limit_reached` — user ran out of Anakra messages.
  Future<void> trackAnakraLimitReached({
    required LimitType limitType,
    int? requestsLeft,
    LimitPeriod limitPeriod = LimitPeriod.unknown,
  }) =>
      _track(AstEvents.anakraLimitReached, <String, Object?>{
        EventParams.limitType: limitType.value,
        if (requestsLeft != null) EventParams.requestsLeft: requestsLeft,
        EventParams.limitPeriod: limitPeriod.value,
      });

  /// `ast_anakra_paywall_view` — Anakra paywall / request-pack offer shown.
  Future<void> trackAnakraPaywallView({
    required String originSurface,
    required OfferType offerType,
    String? paywallVariant,
  }) =>
      _track(AstEvents.anakraPaywallView, <String, Object?>{
        EventParams.originSurface: originSurface,
        EventParams.offerType: offerType.value,
        if (paywallVariant != null) EventParams.paywallVariant: paywallVariant,
      });

  /// `ast_anakra_paywall_click` — user tapped a CTA on the Anakra paywall.
  Future<void> trackAnakraPaywallClick({
    required String originSurface,
    required OfferType offerType,
    String? ctaName,
    String? paywallVariant,
  }) =>
      _track(AstEvents.anakraPaywallClick, <String, Object?>{
        EventParams.originSurface: originSurface,
        EventParams.offerType: offerType.value,
        if (ctaName != null) EventParams.ctaName: ctaName,
        if (paywallVariant != null) EventParams.paywallVariant: paywallVariant,
      });

  // ============================================================
  // T13 — Tarot funnel
  // ============================================================
  //
  // NOTE on purchase events: Love deck / Kelt deck and tarot insight unlock
  // currently flow through internal coin spend, not real-money checkout. Per
  // product decision, `ast_tarot_purchase_success` fires only for real-money
  // purchases; coin-based unlocks will be covered by T15 `ast_coin_spend_*`
  // events. `paywall_view` / `locked_view` still fire for analytical
  // visibility of the offer surface.

  /// `ast_tarot_start` — user opened the tarot flow.
  Future<void> trackTarotStart({
    EntrySurface entrySurface = EntrySurface.unknown,
  }) =>
      _track(AstEvents.tarotStart, <String, Object?>{
        EventParams.entrySurface: entrySurface.value,
      });

  /// `ast_tarot_card_reveal` — a tarot card / spread slot was revealed.
  ///
  /// [contentId] is the stable card / spread id when available.
  Future<void> trackTarotCardReveal({String? contentId}) =>
      _track(AstEvents.tarotCardReveal, <String, Object?>{
        if (contentId != null) EventParams.contentId: contentId,
      });

  /// `ast_tarot_locked_view` — a locked tarot sphere / spread / insight was
  /// shown to the user (PRO-gated or coin-gated).
  Future<void> trackTarotLockedView({
    required String originSurface,
    OfferType? offerType,
  }) =>
      _track(AstEvents.tarotLockedView, <String, Object?>{
        EventParams.originSurface: originSurface,
        if (offerType != null) EventParams.offerType: offerType.value,
      });

  /// `ast_tarot_paywall_view` — paywall / unlock offer shown from tarot.
  Future<void> trackTarotPaywallView({
    required String originSurface,
    required OfferType offerType,
    String? paywallVariant,
  }) =>
      _track(AstEvents.tarotPaywallView, <String, Object?>{
        EventParams.originSurface: originSurface,
        EventParams.offerType: offerType.value,
        if (paywallVariant != null) EventParams.paywallVariant: paywallVariant,
      });

  // ============================================================
  // T13 — Runes funnel
  // ============================================================
  //
  // Same coin-vs-real-money split as tarot — see note above.

  /// `ast_runes_start` — user opened the runes flow.
  Future<void> trackRunesStart({
    EntrySurface entrySurface = EntrySurface.unknown,
  }) =>
      _track(AstEvents.runesStart, <String, Object?>{
        EventParams.entrySurface: entrySurface.value,
      });

  /// `ast_runes_reveal` — a rune was selected / revealed.
  Future<void> trackRunesReveal({String? contentId}) =>
      _track(AstEvents.runesReveal, <String, Object?>{
        if (contentId != null) EventParams.contentId: contentId,
      });

  /// `ast_runes_locked_view` — a locked rune / insight was shown.
  Future<void> trackRunesLockedView({
    required String originSurface,
    OfferType? offerType,
  }) =>
      _track(AstEvents.runesLockedView, <String, Object?>{
        EventParams.originSurface: originSurface,
        if (offerType != null) EventParams.offerType: offerType.value,
      });

  /// `ast_runes_paywall_view` — paywall / unlock offer shown from runes.
  Future<void> trackRunesPaywallView({
    required String originSurface,
    required OfferType offerType,
    String? paywallVariant,
  }) =>
      _track(AstEvents.runesPaywallView, <String, Object?>{
        EventParams.originSurface: originSurface,
        EventParams.offerType: offerType.value,
        if (paywallVariant != null) EventParams.paywallVariant: paywallVariant,
      });

  // ============================================================
  // T13 — Moon / horoscope funnel
  // ============================================================
  //
  // Horoscope is currently coin-purchased; `purchase_success` for real-money
  // moon flow is deferred until such a flow exists. Paywall visibility events
  // still fire because the offer is shown to the user.

  /// `ast_moon_start` — user opened moon / horoscope flow.
  Future<void> trackMoonStart({
    EntrySurface entrySurface = EntrySurface.unknown,
  }) =>
      _track(AstEvents.moonStart, <String, Object?>{
        EventParams.entrySurface: entrySurface.value,
      });

  /// `ast_moon_tab_view` — user switched horoscope tab.
  ///
  /// [contentType] is one of `day`, `week`, `month`, `year`.
  Future<void> trackMoonTabView({required String contentType}) =>
      _track(AstEvents.moonTabView, <String, Object?>{
        EventParams.contentType: contentType,
      });

  /// `ast_moon_generation_complete` — personal / annual horoscope generated
  /// (or failed).
  Future<void> trackMoonGenerationComplete({
    required GenerationStatus generationStatus,
    int? generationSeconds,
  }) =>
      _track(AstEvents.moonGenerationComplete, <String, Object?>{
        EventParams.generationStatus: generationStatus.value,
        if (generationSeconds != null)
          EventParams.generationSeconds: generationSeconds,
      });

  /// `ast_moon_paywall_view` — moon / horoscope offer shown.
  Future<void> trackMoonPaywallView({
    required String originSurface,
    required OfferType offerType,
    String? paywallVariant,
  }) =>
      _track(AstEvents.moonPaywallView, <String, Object?>{
        EventParams.originSurface: originSurface,
        EventParams.offerType: offerType.value,
        if (paywallVariant != null) EventParams.paywallVariant: paywallVariant,
      });

  // ============================================================
  // T14 — Affirmations funnel
  // ============================================================
  //
  // PRO-gated content. Locked category tap surfaces the closed-content modal
  // which acts as the paywall surface. No real-money purchase from this
  // surface today (subscription paywall lives elsewhere) — `purchase_success`
  // is not emitted from affirmations.

  /// `ast_affirmations_start` — user opened the affirmations flow.
  Future<void> trackAffirmationsStart({
    EntrySurface entrySurface = EntrySurface.unknown,
  }) =>
      _track(AstEvents.affirmationsStart, <String, Object?>{
        EventParams.entrySurface: entrySurface.value,
      });

  /// `ast_affirmation_card_view` — an affirmation card became visible.
  Future<void> trackAffirmationCardView({String? contentId}) =>
      _track(AstEvents.affirmationCardView, <String, Object?>{
        if (contentId != null) EventParams.contentId: contentId,
      });

  /// `ast_affirmation_engagement` — user interacted with an affirmation card.
  ///
  /// [actionType] is one of `save`, `share`, `audio`, `favorite`, `swipe`.
  Future<void> trackAffirmationEngagement({
    required String actionType,
    String? contentId,
  }) =>
      _track(AstEvents.affirmationEngagement, <String, Object?>{
        EventParams.actionType: actionType,
        if (contentId != null) EventParams.contentId: contentId,
      });

  /// `ast_affirmation_locked_view` — a PRO-gated affirmation category /
  /// content was tapped.
  Future<void> trackAffirmationLockedView({
    required String originSurface,
    OfferType? offerType,
  }) =>
      _track(AstEvents.affirmationLockedView, <String, Object?>{
        EventParams.originSurface: originSurface,
        if (offerType != null) EventParams.offerType: offerType.value,
      });

  /// `ast_affirmation_paywall_view` — affirmations PRO / subscription offer
  /// shown.
  Future<void> trackAffirmationPaywallView({
    required String originSurface,
    required OfferType offerType,
    String? paywallVariant,
  }) =>
      _track(AstEvents.affirmationPaywallView, <String, Object?>{
        EventParams.originSurface: originSurface,
        EventParams.offerType: offerType.value,
        if (paywallVariant != null) EventParams.paywallVariant: paywallVariant,
      });

  // ============================================================
  // T15 — Coin spend (internal coin spend)
  // ============================================================
  //
  // Fires whenever the user spends in-app coins (звёздочёты) on something —
  // tarot decks, runes decks, anakra request, sonnik request, compatibility
  // request, horoscope unlock, shop item, etc. NOT real money.
  //
  // [originSurface] — stable surface id where the spend happened
  // (compatibility, anakra, sonnik, natal, tarot, runes, moon, shop, ...).
  // [offerType] — what kind of offer is being purchased with coins (typically
  // `OfferType.requestPack`, `OfferType.oneOffUnlock`, `OfferType.shopItem`).

  /// `ast_coin_spend_start` — user tapped "buy for X coins".
  Future<void> trackCoinSpendStart({
    required String originSurface,
    required OfferType offerType,
    required int coinAmount,
    int? balanceBefore,
    int? balanceAfter,
  }) =>
      _track(AstEvents.coinSpendStart, <String, Object?>{
        EventParams.originSurface: originSurface,
        EventParams.offerType: offerType.value,
        EventParams.coinAmount: coinAmount,
        if (balanceBefore != null) EventParams.balanceBefore: balanceBefore,
        if (balanceAfter != null) EventParams.balanceAfter: balanceAfter,
      });

  /// `ast_coin_spend_success` — coins successfully deducted.
  Future<void> trackCoinSpendSuccess({
    required String originSurface,
    required OfferType offerType,
    required int coinAmount,
    int? balanceBefore,
    int? balanceAfter,
  }) =>
      _track(AstEvents.coinSpendSuccess, <String, Object?>{
        EventParams.originSurface: originSurface,
        EventParams.offerType: offerType.value,
        EventParams.coinAmount: coinAmount,
        if (balanceBefore != null) EventParams.balanceBefore: balanceBefore,
        if (balanceAfter != null) EventParams.balanceAfter: balanceAfter,
      });

  /// `ast_coin_spend_failed` — not enough coins / write failed.
  ///
  /// Use [FailureReasons.insufficientBalance] when balance is the cause.
  Future<void> trackCoinSpendFailed({
    required String originSurface,
    required OfferType offerType,
    required int coinAmount,
    required String failureReason,
    int? balanceBefore,
  }) =>
      _track(AstEvents.coinSpendFailed, <String, Object?>{
        EventParams.originSurface: originSurface,
        EventParams.offerType: offerType.value,
        EventParams.coinAmount: coinAmount,
        EventParams.failureReason: failureReason,
        if (balanceBefore != null) EventParams.balanceBefore: balanceBefore,
      });

  // ============================================================
  // T15 — Coin pack real-money purchase
  // ============================================================
  //
  // Fires on the coins paywall (`CoinsPaywallScreen`) and the payments screen
  // (`PaymentsScreen`) when buying coin packages with real money. revenue
  // events use the LOCAL CURRENCY amount, NEVER coin count.

  /// `ast_coin_paywall_view` — coins paywall screen opened.
  Future<void> trackCoinPaywallView({
    required String originSurface,
    OfferType offerType = OfferType.coinPackage,
    String? paywallVariant,
  }) =>
      _track(AstEvents.coinPaywallView, <String, Object?>{
        EventParams.originSurface: originSurface,
        EventParams.offerType: offerType.value,
        if (paywallVariant != null) EventParams.paywallVariant: paywallVariant,
      });

  /// `ast_coin_package_select` — user picked a coin package on the paywall.
  Future<void> trackCoinPackageSelect({
    required String packageId,
    num? price,
    String? afCurrency,
  }) =>
      _track(AstEvents.coinPackageSelect, <String, Object?>{
        EventParams.packageId: packageId,
        if (price != null) EventParams.price: price,
        if (afCurrency != null) EventParams.afCurrency: afCurrency,
      });

  /// `ast_coin_purchase_start` — real-money checkout for a coin package
  /// initiated.
  Future<void> trackCoinPurchaseStart({
    required String originSurface,
    OfferType offerType = OfferType.coinPackage,
    PaymentType paymentType = PaymentType.realMoney,
    String? packageId,
    num? price,
    String? afCurrency,
    String? paymentProvider,
    String? underlyingPaymentProvider,
  }) =>
      _track(AstEvents.coinPurchaseStart, <String, Object?>{
        EventParams.originSurface: originSurface,
        EventParams.offerType: offerType.value,
        EventParams.paymentType: paymentType.value,
        if (packageId != null) EventParams.packageId: packageId,
        if (price != null) EventParams.price: price,
        if (afCurrency != null) EventParams.afCurrency: afCurrency,
        if (paymentProvider != null)
          EventParams.paymentProvider: paymentProvider,
        if (underlyingPaymentProvider != null)
          EventParams.underlyingPaymentProvider: underlyingPaymentProvider,
      });

  /// `ast_coin_purchase_success` — real-money coin purchase succeeded.
  ///
  /// [afRevenue] MUST be the real-money amount in [afCurrency], never the
  /// coin count.
  Future<void> trackCoinPurchaseSuccess({
    required String originSurface,
    required num afRevenue,
    required String afCurrency,
    OfferType offerType = OfferType.coinPackage,
    PaymentType paymentType = PaymentType.realMoney,
    String? packageId,
    String? paymentProvider,
    String? underlyingPaymentProvider,
  }) =>
      _track(AstEvents.coinPurchaseSuccess, <String, Object?>{
        EventParams.originSurface: originSurface,
        EventParams.offerType: offerType.value,
        EventParams.paymentType: paymentType.value,
        EventParams.afRevenue: afRevenue,
        EventParams.afCurrency: afCurrency,
        if (packageId != null) EventParams.packageId: packageId,
        if (paymentProvider != null)
          EventParams.paymentProvider: paymentProvider,
        if (underlyingPaymentProvider != null)
          EventParams.underlyingPaymentProvider: underlyingPaymentProvider,
      });

  /// `ast_coin_purchase_failed` — real-money coin purchase failed.
  Future<void> trackCoinPurchaseFailed({
    required String originSurface,
    required String failureReason,
    OfferType offerType = OfferType.coinPackage,
    PaymentType paymentType = PaymentType.realMoney,
    String? failureStage,
    String? packageId,
    num? price,
    String? afCurrency,
    String? paymentProvider,
    String? underlyingPaymentProvider,
  }) =>
      _track(AstEvents.coinPurchaseFailed, <String, Object?>{
        EventParams.originSurface: originSurface,
        EventParams.offerType: offerType.value,
        EventParams.paymentType: paymentType.value,
        EventParams.failureReason: failureReason,
        if (failureStage != null) EventParams.failureStage: failureStage,
        if (packageId != null) EventParams.packageId: packageId,
        if (price != null) EventParams.price: price,
        if (afCurrency != null) EventParams.afCurrency: afCurrency,
        if (paymentProvider != null)
          EventParams.paymentProvider: paymentProvider,
        if (underlyingPaymentProvider != null)
          EventParams.underlyingPaymentProvider: underlyingPaymentProvider,
      });

  /// `ast_coin_purchase_cancelled` — user dismissed the checkout.
  Future<void> trackCoinPurchaseCancelled({
    required String originSurface,
    OfferType offerType = OfferType.coinPackage,
    PaymentType paymentType = PaymentType.realMoney,
    String? failureStage,
    String? packageId,
    String? paymentProvider,
    String? underlyingPaymentProvider,
  }) =>
      _track(AstEvents.coinPurchaseCancelled, <String, Object?>{
        EventParams.originSurface: originSurface,
        EventParams.offerType: offerType.value,
        EventParams.paymentType: paymentType.value,
        if (failureStage != null) EventParams.failureStage: failureStage,
        if (packageId != null) EventParams.packageId: packageId,
        if (paymentProvider != null)
          EventParams.paymentProvider: paymentProvider,
        if (underlyingPaymentProvider != null)
          EventParams.underlyingPaymentProvider: underlyingPaymentProvider,
      });

  /// `ast_coin_purchase_expired` — QR / payment session expired before the
  /// user paid.
  Future<void> trackCoinPurchaseExpired({
    required String originSurface,
    OfferType offerType = OfferType.coinPackage,
    PaymentType paymentType = PaymentType.realMoney,
    int? timeToExpire,
    String? packageId,
    String? paymentProvider,
    String? underlyingPaymentProvider,
  }) =>
      _track(AstEvents.coinPurchaseExpired, <String, Object?>{
        EventParams.originSurface: originSurface,
        EventParams.offerType: offerType.value,
        EventParams.paymentType: paymentType.value,
        if (timeToExpire != null) EventParams.timeToExpire: timeToExpire,
        if (packageId != null) EventParams.packageId: packageId,
        if (paymentProvider != null)
          EventParams.paymentProvider: paymentProvider,
        if (underlyingPaymentProvider != null)
          EventParams.underlyingPaymentProvider: underlyingPaymentProvider,
      });

  /// `ast_payment_method_select` — user picked a payment method (card / SBP /
  /// Apple Pay / etc).
  ///
  /// Hosted checkout reports the actual method through the backend after the
  /// payment. [paymentMethodType] is `unknown` only when the provider omits it.
  Future<void> trackPaymentMethodSelect({
    required String originSurface,
    PaymentMethodType paymentMethodType = PaymentMethodType.unknown,
  }) =>
      _track(AstEvents.paymentMethodSelect, <String, Object?>{
        EventParams.originSurface: originSurface,
        EventParams.paymentMethodType: paymentMethodType.value,
      });

  // ============================================================
  // T16 — Subscription
  // ============================================================
  //
  // Subscription paywall today routes everything through `SubscriptionScreen`,
  // including natal unlocks (per product). When the entry surface is natal,
  // callers should ALSO fire the matching `ast_natal_*` event so that natal
  // funnel analytics stay intact without double-counting revenue (revenue is
  // attached only to `ast_subscription_purchase_success`; see callers in
  // `subscription_screen.dart`).

  /// `ast_subscription_paywall_view` — subscription / PRO paywall shown.
  Future<void> trackSubscriptionPaywallView({
    required String originSurface,
    OfferType offerType = OfferType.subscription,
    String? paywallVariant,
  }) =>
      _track(AstEvents.subscriptionPaywallView, <String, Object?>{
        EventParams.originSurface: originSurface,
        EventParams.offerType: offerType.value,
        if (paywallVariant != null) EventParams.paywallVariant: paywallVariant,
      });

  /// `ast_subscription_plan_select` — user picked a plan
  /// (monthly / yearly / lifetime).
  Future<void> trackSubscriptionPlanSelect({
    required String planId,
    num? price,
    String? afCurrency,
  }) =>
      _track(AstEvents.subscriptionPlanSelect, <String, Object?>{
        EventParams.planId: planId,
        if (price != null) EventParams.price: price,
        if (afCurrency != null) EventParams.afCurrency: afCurrency,
      });

  /// `ast_subscription_purchase_start` — checkout initiated.
  Future<void> trackSubscriptionPurchaseStart({
    required String originSurface,
    OfferType offerType = OfferType.subscription,
    PaymentType paymentType = PaymentType.subscription,
    String? planId,
    num? price,
    String? afCurrency,
    String? paymentProvider,
    String? underlyingPaymentProvider,
  }) =>
      _track(AstEvents.subscriptionPurchaseStart, <String, Object?>{
        EventParams.originSurface: originSurface,
        EventParams.offerType: offerType.value,
        EventParams.paymentType: paymentType.value,
        if (planId != null) EventParams.planId: planId,
        if (price != null) EventParams.price: price,
        if (afCurrency != null) EventParams.afCurrency: afCurrency,
        if (paymentProvider != null)
          EventParams.paymentProvider: paymentProvider,
        if (underlyingPaymentProvider != null)
          EventParams.underlyingPaymentProvider: underlyingPaymentProvider,
      });

  /// `ast_subscription_purchase_success` — subscription purchase succeeded.
  ///
  /// [afRevenue] in [afCurrency] is the real-money amount.
  Future<void> trackSubscriptionPurchaseSuccess({
    required String originSurface,
    required num afRevenue,
    required String afCurrency,
    required String planId,
    OfferType offerType = OfferType.subscription,
    PaymentType paymentType = PaymentType.subscription,
    String? paymentProvider,
    String? underlyingPaymentProvider,
  }) =>
      _track(AstEvents.subscriptionPurchaseSuccess, <String, Object?>{
        EventParams.originSurface: originSurface,
        EventParams.offerType: offerType.value,
        EventParams.paymentType: paymentType.value,
        EventParams.afRevenue: afRevenue,
        EventParams.afCurrency: afCurrency,
        EventParams.planId: planId,
        if (paymentProvider != null)
          EventParams.paymentProvider: paymentProvider,
        if (underlyingPaymentProvider != null)
          EventParams.underlyingPaymentProvider: underlyingPaymentProvider,
      });

  /// `ast_subscription_purchase_failed` — subscription purchase failed.
  Future<void> trackSubscriptionPurchaseFailed({
    required String originSurface,
    required String failureReason,
    OfferType offerType = OfferType.subscription,
    PaymentType paymentType = PaymentType.subscription,
    String? failureStage,
    String? planId,
    String? paymentProvider,
    String? underlyingPaymentProvider,
  }) =>
      _track(AstEvents.subscriptionPurchaseFailed, <String, Object?>{
        EventParams.originSurface: originSurface,
        EventParams.offerType: offerType.value,
        EventParams.paymentType: paymentType.value,
        EventParams.failureReason: failureReason,
        if (failureStage != null) EventParams.failureStage: failureStage,
        if (planId != null) EventParams.planId: planId,
        if (paymentProvider != null)
          EventParams.paymentProvider: paymentProvider,
        if (underlyingPaymentProvider != null)
          EventParams.underlyingPaymentProvider: underlyingPaymentProvider,
      });

  /// `ast_subscription_manage_click` — user opened the platform subscription
  /// management surface. This records intent only, not a confirmed cancel.
  Future<void> trackSubscriptionManageClick({
    required String originSurface,
    required String platform,
    required String subscriptionState,
  }) =>
      _track(AstEvents.subscriptionManageClick, <String, Object?>{
        EventParams.originSurface: originSurface,
        EventParams.platform: platform,
        EventParams.subscriptionState: subscriptionState,
      });

  // ============================================================
  // T16 — Natal real-money purchase (via subscription_screen)
  // ============================================================
  //
  // Natal unlock currently goes through the subscription paywall, so
  // `ast_natal_purchase_*` is emitted in parallel with the matching
  // subscription event when origin == 'natal'. To avoid double-counting
  // revenue, the natal events here do NOT carry af_revenue / af_currency
  // (revenue stays on the subscription event).

  /// `ast_natal_purchase_start` — natal real-money checkout initiated.
  Future<void> trackNatalPurchaseStart({
    required String originSurface,
    OfferType offerType = OfferType.subscription,
    PaymentType paymentType = PaymentType.subscription,
    String? planId,
    num? price,
    String? afCurrency,
    String? paymentProvider,
    String? underlyingPaymentProvider,
  }) =>
      _track(AstEvents.natalPurchaseStart, <String, Object?>{
        EventParams.originSurface: originSurface,
        EventParams.offerType: offerType.value,
        EventParams.paymentType: paymentType.value,
        if (planId != null) EventParams.planId: planId,
        if (price != null) EventParams.price: price,
        if (afCurrency != null) EventParams.afCurrency: afCurrency,
        if (paymentProvider != null)
          EventParams.paymentProvider: paymentProvider,
        if (underlyingPaymentProvider != null)
          EventParams.underlyingPaymentProvider: underlyingPaymentProvider,
      });

  /// `ast_natal_purchase_success` — natal real-money purchase succeeded.
  ///
  /// Revenue intentionally omitted to avoid double-counting against
  /// `ast_subscription_purchase_success`.
  Future<void> trackNatalPurchaseSuccess({
    required String originSurface,
    required String planId,
    OfferType offerType = OfferType.subscription,
    PaymentType paymentType = PaymentType.subscription,
    String? paymentProvider,
    String? underlyingPaymentProvider,
  }) =>
      _track(AstEvents.natalPurchaseSuccess, <String, Object?>{
        EventParams.originSurface: originSurface,
        EventParams.offerType: offerType.value,
        EventParams.paymentType: paymentType.value,
        EventParams.planId: planId,
        if (paymentProvider != null)
          EventParams.paymentProvider: paymentProvider,
        if (underlyingPaymentProvider != null)
          EventParams.underlyingPaymentProvider: underlyingPaymentProvider,
      });

  /// `ast_natal_purchase_failed` — natal real-money purchase failed.
  Future<void> trackNatalPurchaseFailed({
    required String originSurface,
    required String failureReason,
    OfferType offerType = OfferType.subscription,
    PaymentType paymentType = PaymentType.subscription,
    String? failureStage,
    String? planId,
    String? paymentProvider,
    String? underlyingPaymentProvider,
  }) =>
      _track(AstEvents.natalPurchaseFailed, <String, Object?>{
        EventParams.originSurface: originSurface,
        EventParams.offerType: offerType.value,
        EventParams.paymentType: paymentType.value,
        EventParams.failureReason: failureReason,
        if (failureStage != null) EventParams.failureStage: failureStage,
        if (planId != null) EventParams.planId: planId,
        if (paymentProvider != null)
          EventParams.paymentProvider: paymentProvider,
        if (underlyingPaymentProvider != null)
          EventParams.underlyingPaymentProvider: underlyingPaymentProvider,
      });

  // ============================================================
  // T17 — Restore purchases
  // ============================================================

  /// `ast_purchase_restore_click` — user tapped the restore-purchases CTA.
  Future<void> trackPurchaseRestoreClick({required String originSurface}) =>
      _track(AstEvents.purchaseRestoreClick, <String, Object?>{
        EventParams.originSurface: originSurface,
      });

  /// `ast_purchase_restore_success` — restore succeeded.
  Future<void> trackPurchaseRestoreSuccess({
    ProductType? productType,
    String? planId,
  }) =>
      _track(AstEvents.purchaseRestoreSuccess, <String, Object?>{
        if (productType != null) EventParams.productType: productType.value,
        if (planId != null) EventParams.planId: planId,
      });

  /// `ast_purchase_restore_failed` — restore failed.
  Future<void> trackPurchaseRestoreFailed({
    required String failureReason,
    String? failureStage,
  }) =>
      _track(AstEvents.purchaseRestoreFailed, <String, Object?>{
        EventParams.failureReason: failureReason,
        if (failureStage != null) EventParams.failureStage: failureStage,
      });

  // ============================================================
  // T18 — Profile / shop / account
  // ============================================================
  //
  // `account_logout` / `account_delete` are aliases
  // that fire alongside existing `af_*` events (logout / account_deleted) —
  // both keep flowing to AppsFlyer; this layer just adds the
  // canonical product taxonomy.

  /// `ast_profile_view` — profile screen opened.
  Future<void> trackProfileView() => _track(AstEvents.profileView);

  /// `ast_profile_menu_click` — user tapped a profile menu entry.
  ///
  /// [menuItem] must be a stable id from the controlled set: `settings`,
  /// `support`, `logout`, `delete_account`, `terms_of_use`,
  /// `privacy_policy`, `subscription`, `achievements`, `shop`,
  /// `about_us`, etc. Pick one consistent id per surface and reuse it.
  Future<void> trackProfileMenuClick({required String menuItem}) =>
      _track(AstEvents.profileMenuClick, <String, Object?>{
        EventParams.menuItem: menuItem,
      });

  /// `ast_account_logout` — user signed out.
  Future<void> trackAccountLogout() => _track(AstEvents.accountLogout);

  /// `ast_account_delete` — user deleted their account.
  Future<void> trackAccountDelete() => _track(AstEvents.accountDelete);

  /// `ast_shop_view` — shop screen opened.
  Future<void> trackShopView() => _track(AstEvents.shopView);

  /// `ast_shop_item_select` — user tapped a shop item.
  ///
  /// [itemId] is the stable product id, [itemType] is the controlled category
  /// (e.g. `coins`, `requests_pack`, `unlock`).
  Future<void> trackShopItemSelect({
    required String itemId,
    String? itemType,
    int? coinAmount,
    String? originSurface,
  }) =>
      _track(AstEvents.shopItemSelect, <String, Object?>{
        EventParams.itemId: itemId,
        if (itemType != null) EventParams.itemType: itemType,
        if (coinAmount != null) EventParams.coinAmount: coinAmount,
        if (originSurface != null) EventParams.originSurface: originSurface,
      });

  // ============================================================
  // T19 — P1 generic events
  // ============================================================

  /// `ast_app_open` — emitted once per cold start, after AppsFlyer SDK init.
  ///
  /// [isNewUser] is `true` when there is no local user yet (first launch /
  /// pre-activation). [entrySurface] captures the first surface the user
  /// landed on (push, deep link, etc.) — leave as [EntrySurface.unknown] if
  /// the cold start is not attributable to a known surface.
  Future<void> trackAppOpen({
    required bool isNewUser,
    EntrySurface entrySurface = EntrySurface.unknown,
  }) =>
      _track(AstEvents.appOpen, <String, Object?>{
        EventParams.isNewUser: isNewUser,
        EventParams.entrySurface: entrySurface.value,
      });

  /// `ast_screen_view` — generic named-screen view event.
  ///
  /// [screenName] is the route name; [originSurface] is the previous route /
  /// surface, when known.
  Future<void> trackScreenView({
    required String screenName,
    String? originSurface,
  }) =>
      _track(AstEvents.screenView, <String, Object?>{
        EventParams.screenName: screenName,
        if (originSurface != null) EventParams.originSurface: originSurface,
      });

  /// `ast_error_state_view` — fires when an error UI is actually shown to
  /// the user (not when a request fails silently).
  ///
  /// [errorType] is a controlled vocabulary id; prefer values from
  /// [FailureReasons] where possible.
  Future<void> trackErrorStateView({
    required String screenName,
    required String errorType,
    String? originSurface,
  }) =>
      _track(AstEvents.errorStateView, <String, Object?>{
        EventParams.screenName: screenName,
        EventParams.errorType: errorType,
        if (originSurface != null) EventParams.originSurface: originSurface,
      });

  /// `ast_notification_permission_result` — result of a permission prompt.
  ///
  /// [permissionType] is `push` / `notification` / `location` etc.
  /// [permissionStatus] is `granted` / `denied` / `provisional`.
  Future<void> trackNotificationPermissionResult({
    required String permissionType,
    required String permissionStatus,
  }) =>
      _track(AstEvents.notificationPermissionResult, <String, Object?>{
        EventParams.permissionType: permissionType,
        EventParams.permissionStatus: permissionStatus,
      });
}
