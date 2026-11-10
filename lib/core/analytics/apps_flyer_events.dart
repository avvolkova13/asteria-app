import 'package:uuid/uuid.dart';

import 'dictionaries/entry_surface.dart';
import 'dictionaries/birth_time_precision.dart';
import 'dictionaries/failure_reason.dart';
import 'dictionaries/failure_stage.dart';
import 'dictionaries/input_mode.dart';
import 'dictionaries/length_band.dart';
import 'dictionaries/limit_period.dart';
import 'dictionaries/limit_type.dart';
import 'dictionaries/payment_method_type.dart';
import 'dictionaries/partner_data_completeness.dart';
import 'dictionaries/product_type.dart';
import 'durable/analytics_taxonomy.dart';

/// AF names are a projection of product facts, not a second product taxonomy.
abstract final class AppsFlyerEvents {
  static const screens = {
    '/about-us': 'ast_about_us_view',
    '/achievements': 'ast_achievements_view',
    '/anakra/requests-left': 'ast_anakra_requests_left_view',
    '/anakra/subscription': 'ast_anakra_subscription_view',
    '/article': 'ast_article_view',
    '/auth/email': 'ast_auth_email_view',
    '/auth/email/code': 'ast_auth_email_code_view',
    '/auth/login': 'ast_auth_login_view',
    '/auth/personal-info': 'ast_auth_personal_info_view',
    '/balance': 'ast_balance_view',
    '/balance-history': 'ast_balance_history_view',
    '/coins-paywall': 'ast_coins_paywall_view',
    '/compatibility/create': 'ast_compatibility_create_view',
    '/compatibility/history': 'ast_compatibility_history_view',
    '/compatibility/loaded': 'ast_compatibility_loaded_view',
    '/compatibility/requests-left': 'ast_compatibility_requests_left_view',
    '/compatibility/subscription': 'ast_compatibility_subscription_view',
    '/home/astrology': 'ast_home_astrology_view',
    '/home/personal': 'ast_home_personal_view',
    '/home/practices': 'ast_home_practices_view',
    '/kelt-deck': 'ast_kelt_deck_view',
    '/love-deck': 'ast_love_deck_view',
    '/onboarding': 'ast_onboarding_view',
    '/payments': 'ast_payments_view',
    '/payments-settings': 'ast_payments_settings_view',
    '/profile/payment': 'ast_profile_payment_view',
    '/settings': 'ast_settings_view',
    '/social/feed': 'ast_social_feed_view',
    '/social/notifications': 'ast_social_notifications_view',
    '/social/post': 'ast_social_post_view',
    '/social/profile': 'ast_social_profile_view',
    '/social/search': 'ast_social_search_view',
    '/social/settings': 'ast_social_settings_view',
    '/sonnik/create': 'ast_sonnik_create_view',
    '/sonnik/history': 'ast_sonnik_history_view',
    '/sonnik/loaded': 'ast_sonnik_loaded_view',
    '/sonnik/requests-left': 'ast_sonnik_requests_left_view',
    '/sonnik/subscription': 'ast_sonnik_subscription_view',
    '/star-fair': 'ast_star_fair_view',
    '/subscription': 'ast_subscription_view',
    '/home': 'ast_home_view',
    'home': 'ast_home_view',
    '/home/profile': 'ast_profile_view',
    'profile': 'ast_profile_view',
    '/shop': 'ast_shop_view',
    'shop': 'ast_shop_view',
    '/compatibility/initial': 'ast_compatibility_start',
    '/natal-card': 'ast_natal_start',
    '/sonnik/initial': 'ast_sonnik_start',
    '/anakra-chat': 'ast_anakra_start',
    '/taro-cards': 'ast_tarot_start',
    '/runes': 'ast_runes_start',
    '/home/moon': 'ast_moon_start',
    'moon': 'ast_moon_start',
    '/horoscope': 'ast_horoscope_start',
    '/affirmation': 'ast_affirmations_start',
  };

  static const results = {
    'compatibility': 'ast_compatibility_result_view',
    'natal_chart': 'ast_natal_result_view',
    'sonnik': 'ast_sonnik_result_view',
    'anakra': 'ast_anakra_response_view',
    'tarot': 'ast_tarot_card_reveal',
    'runes': 'ast_runes_reveal',
    'horoscope': 'ast_horoscope_result_view',
    'moon': 'ast_moon_result_view',
    'affirmations': 'ast_affirmation_card_view',
    'love_deck': 'ast_love_deck_card_view',
    'kelt_deck': 'ast_kelt_deck_card_view',
    'articles': 'ast_article_read',
  };

  // Only actions with no canonical owner. Views, outcomes and server facts
  // must never be emitted here as aliases of their canonical projection.
  static const additionalNames = {
    'ast_onboarding_start',
    'ast_home_card_view',
    'ast_home_card_click',
    'ast_profile_menu_click',
    'ast_shop_item_select',
    'ast_account_logout',
    'ast_account_delete',
    'ast_compatibility_input_complete',
    'ast_natal_birth_data_complete',
    'ast_natal_section_view',
    'ast_anakra_quick_action_click',
    'ast_affirmation_engagement',
    'ast_compatibility_limit_reached',
    'ast_sonnik_limit_reached',
    'ast_anakra_limit_reached',
    'ast_tarot_locked_view',
    'ast_runes_locked_view',
    'ast_affirmation_locked_view',
    'ast_compatibility_paywall_click',
    'ast_natal_paywall_click',
    'ast_sonnik_paywall_click',
    'ast_anakra_paywall_click',
    'ast_coin_spend_start',
    'ast_coin_spend_failed',
    'ast_payment_method_select',
    'ast_subscription_manage_click',
    'ast_content_engagement',
    'ast_error_state_view',
    'ast_notification_permission_result',
  };

  static const generationNames = {
    'ast_compatibility_generation_complete',
    'ast_natal_generation_complete',
    'ast_sonnik_generation_complete',
    'ast_moon_generation_complete',
  };

  static const additionalAliases = {
    'onboarding_step_completed': 'ast_onboarding_step_complete',
    'onboarding_skipped': 'ast_onboarding_skip',
    'auth_started': 'ast_auth_start',
    'auth_code_requested': 'ast_auth_code_request',
    'horoscope_unlock_click': 'ast_horoscope_paywall_click',
    'tarot_spread_started': 'ast_tarot_spread_start',
  };

  static const paywallClicks = {
    'subscription': 'ast_subscription_paywall_click',
    'love_deck': 'ast_love_deck_paywall_click',
    'kelt_deck': 'ast_kelt_deck_paywall_click',
  };

  static const starFairActions = {
    'start',
    'resume',
    'choice',
    'replay',
    'complete',
    'reading_view',
    'reading_failed',
  };

  static final Set<String> names = Set.unmodifiable({
    ...screens.values,
    ...results.values,
    ...additionalNames,
    ...generationNames,
    ...additionalAliases.values,
    ...paywallClicks.values,
    for (final action in starFairActions) 'ast_star_fair_$action',
    'af_tutorial_completion',
    'af_initiated_checkout',
    'ast_first_useful_result',
    'ast_paywall_view',
    'ast_first_open',
    'ast_app_open',
    'ast_screen_view',
    'ast_social_action',
    'ast_onboarding_step_view',
    'ast_auth_code_verify_success',
    'ast_auth_code_verify_failed',
    'ast_sonnik_dream_submit',
    'ast_anakra_message_sent',
    'ast_article_open',
    'ast_feature_action_start',
    'ast_feature_action_failed',
    'ast_feature_result_view',
    'ast_coin_package_select',
    'ast_subscription_plan_select',
    'ast_offer_select',
    'ast_checkout_outcome',
    'ast_purchase_restore_click',
    'ast_purchase_restore_success',
    'ast_purchase_restore_failed',
    'ast_purchase_restore_empty',
  });

  static String? fromCanonical(String name, Map<String, Object?> payload) {
    if (name == 'social_action') return 'ast_social_action';
    final feature = payload['feature'];
    if (feature == 'star_fair' &&
        name.startsWith('feature_') &&
        starFairActions.contains(payload['game_action'])) {
      return 'ast_star_fair_${payload['game_action']}';
    }
    return switch (name) {
      'first_open' => 'ast_first_open',
      'session_started' => 'ast_app_open',
      'screen_viewed' => screens[payload['screen']] ?? 'ast_screen_view',
      'onboarding_step_viewed' => 'ast_onboarding_step_view',
      'auth_result' =>
        payload['outcome'] == 'success'
            ? 'ast_auth_code_verify_success'
            : 'ast_auth_code_verify_failed',
      'feature_action_started' => switch (feature) {
        'sonnik' => 'ast_sonnik_dream_submit',
        'anakra' => 'ast_anakra_message_sent',
        'articles' => 'ast_article_open',
        _ => 'ast_feature_action_start',
      },
      'feature_result_viewed' => results[feature] ?? 'ast_feature_result_view',
      'feature_action_failed' => 'ast_feature_action_failed',
      'paywall_viewed' => 'ast_paywall_view',
      'offer_selected' => switch (feature) {
        'stars' => 'ast_coin_package_select',
        'subscription' => 'ast_subscription_plan_select',
        _ => 'ast_offer_select',
      },
      'checkout_started' => 'af_initiated_checkout',
      'checkout_outcome' => 'ast_checkout_outcome',
      'restore_started' => 'ast_purchase_restore_click',
      'restore_outcome' => switch (payload['outcome']) {
        'success' => 'ast_purchase_restore_success',
        'empty' => 'ast_purchase_restore_empty',
        'failed' => 'ast_purchase_restore_failed',
        _ => null,
      },
      _ => null,
    };
  }

  static String? additional(String source, Map<String, dynamic> params) {
    if (additionalAliases.containsKey(source)) return additionalAliases[source];
    if (source == 'paywall_cta_click') {
      return paywallClicks[params['feature_name']];
    }
    if (source == 'ast_onboarding_complete') return 'af_tutorial_completion';
    if (generationNames.contains(source)) {
      return params['generation_status'] == 'success' ? source : null;
    }
    // These are emitted on initial load, not a separate tab/section action.
    if (source == 'ast_natal_section_view' &&
        params['content_type'] == 'overview') {
      return null;
    }
    return additionalNames.contains(source) ? source : null;
  }

  static bool isVisible(
    String source,
    Map<String, dynamic> params,
    String? screen,
  ) {
    if (source != 'ast_home_card_view') return true;
    return switch (params['entry_point_id']) {
      'home_natal_card' ||
      'home_compatibility_card' => screen == '/home/personal',
      'home_tarot_card' ||
      'home_affirmation_card' ||
      'home_rune_card' ||
      'home_pro_promo_card' => screen == '/home',
      _ => false,
    };
  }

  static Map<String, Object?> sanitize(Map<String, dynamic> params) {
    final clean = AnalyticsTaxonomy.sanitize(params);
    for (final key in ['event_id', 'session_id', 'attempt_id']) {
      final value = params[key];
      if (value is String && Uuid.isValidUUID(fromString: value)) {
        clean[key] = value;
      }
    }
    const strings = {
      'failure_reason': {
        FailureReasons.userCancelled,
        FailureReasons.paymentDeclined,
        FailureReasons.networkError,
        FailureReasons.qrExpired,
        FailureReasons.invalidCode,
        FailureReasons.serverError,
        FailureReasons.insufficientBalance,
        FailureReasons.unknown,
      },
      'failure_stage': {
        FailureStages.checkoutStart,
        FailureStages.providerRedirect,
        FailureStages.confirmation,
        FailureStages.requestOtp,
        FailureStages.verifyCode,
        FailureStages.saveUser,
        FailureStages.unknown,
      },
      'menu_item': {
        'settings',
        'support',
        'logout',
        'delete_account',
        'terms_of_use',
        'privacy_policy',
        'subscription',
        'achievements',
        'shop',
        'about_us',
        'site',
      },
      'entry_point_id': {
        'home_natal_card',
        'home_compatibility_card',
        'home_tarot_card',
        'home_affirmation_card',
        'home_rune_card',
        'home_pro_promo_card',
        'sonnik',
      },
      'action_type': {
        'swipe',
        'copy',
        'share',
        'save',
        'favorite',
        'draw_card',
        'compatibility',
        'natal_chart',
        'power_day',
      },
      'item_type': {
        'coins',
        'requests_pack',
        'unlock',
        'subscription',
        'pro',
        'compatibility',
        'sonnik',
        'anakra',
        'tarot',
        'runes',
        'natal_chart',
      },
      'content_type': {
        'overview',
        'day',
        'year',
        'month',
        'week',
        'tarot',
        'rune',
        'affirmation',
      },
      'permission_type': {'notifications', 'tracking'},
      'permission_status': {
        'granted',
        'denied',
        'authorized',
        'not_determined',
        'provisional',
        'restricted',
      },
      'environment': {'test', 'production'},
      'platform': {'ios', 'android'},
    };
    for (final entry in strings.entries) {
      if (entry.value.contains(params[entry.key])) {
        clean[entry.key] = params[entry.key];
      }
    }
    final enums = {
      'input_mode': InputMode.values.map((e) => e.value),
      'partner_data_completeness': PartnerDataCompleteness.values.map(
        (e) => e.value,
      ),
      'birth_time_precision': BirthTimePrecision.values.map((e) => e.value),
      'product_type': ProductType.values.map((e) => e.value),
      'entry_surface': EntrySurface.values.map((e) => e.value),
      'limit_type': LimitType.values.map((e) => e.value),
      'limit_period': LimitPeriod.values.map((e) => e.value),
      'payment_method_type': PaymentMethodType.values.map((e) => e.value),
      'dream_length_band': LengthBand.values.map((e) => e.value),
      'message_length_band': LengthBand.values.map((e) => e.value),
    };
    for (final entry in enums.entries) {
      if (entry.value.contains(params[entry.key])) {
        clean[entry.key] = params[entry.key];
      }
    }
    for (final key in [
      'position',
      'requests_left',
      'steps_count',
      'completion_seconds',
      'coin_amount',
    ]) {
      final value = params[key];
      if (value is int && value >= 0 && value <= 1000000) clean[key] = value;
    }
    for (final key in ['app_version', 'occurred_at']) {
      final value = params[key];
      if (value is! String) continue;
      if (key == 'app_version' &&
          RegExp(r'^\d+(\.\d+){0,3}(\+\d+)?$').hasMatch(value)) {
        clean[key] = value;
      } else if (key == 'occurred_at' && DateTime.tryParse(value) != null) {
        clean[key] = value;
      }
    }
    return clean;
  }
}
