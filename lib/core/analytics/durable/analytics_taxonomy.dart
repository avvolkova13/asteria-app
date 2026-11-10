import 'package:asteria_app/core/payments/catalog/product_catalog.dart';
import 'package:uuid/uuid.dart';

class CanonicalAnalyticsEvent {
  const CanonicalAnalyticsEvent(this.name, this.payload);
  final String name;
  final Map<String, Object?> payload;
}

/// Explicit event and parameter allowlists. Raw provider text belongs only to
/// the restricted attribution stream, never to product events or SDK marketing.
abstract final class AnalyticsTaxonomy {
  static const features = {
    'social',
    'compatibility',
    'natal_chart',
    'sonnik',
    'anakra',
    'tarot',
    'runes',
    'horoscope',
    'moon',
    'affirmations',
    'love_deck',
    'kelt_deck',
    'stars',
    'subscription',
    'articles',
    'star_fair',
  };
  static const _prefixes = {
    'compatibility': 'compatibility',
    'natal': 'natal_chart',
    'sonnik': 'sonnik',
    'anakra': 'anakra',
    'tarot': 'tarot',
    'runes': 'runes',
    'moon': 'moon',
    'affirmations': 'affirmations',
    'affirmation': 'affirmations',
    'coin': 'stars',
    'subscription': 'subscription',
  };
  static const screens = {
    '/social/feed',
    '/social/post',
    '/social/search',
    '/social/profile',
    '/social/notifications',
    '/social/settings',
    '/home/astrology',
    '/star-fair',
    '/home/personal',
    '/home/moon',
    '/home/practices',
    '/home/profile',
    '/home',
    '/shop',
    '/settings',
    '/subscription',
    '/achievements',
    '/about-us',
    '/payments-settings',
    '/horoscope',
    '/natal-card',
    '/taro-cards',
    '/runes',
    '/kelt-deck',
    '/love-deck',
    '/article',
    '/balance',
    '/balance-history',
    '/affirmation',
    '/payments',
    '/coins-paywall',
    '/onboarding',
    '/anakra-chat',
    '/auth/login',
    '/auth/email',
    '/auth/email/code',
    '/auth/personal-info',
    '/profile/payment',
    '/compatibility/create',
    '/compatibility/initial',
    '/compatibility/requests-left',
    '/compatibility/subscription',
    '/compatibility/history',
    '/compatibility/loaded',
    '/sonnik/create',
    '/sonnik/initial',
    '/sonnik/requests-left',
    '/sonnik/subscription',
    '/sonnik/history',
    '/sonnik/loaded',
    '/anakra/requests-left',
    '/anakra/subscription',
    'home',
    'profile',
    'shop',
    'moon',
  };
  static const _values = <String, Set<String>>{
    'social_action': {
      'feed_interesting',
      'feed_following',
      'search',
      'profile_view',
      'follow',
      'unfollow',
      'block',
      'unblock',
      'post_create',
      'post_edit',
      'post_delete',
      'post_like',
      'post_unlike',
      'comment_create',
      'comment_reply',
      'comment_edit',
      'comment_delete',
      'report',
      'notifications_view',
      'notification_read',
      'notification_read_all',
      'notification_settings',
    },
    'game_action': {
      'start',
      'resume',
      'choice',
      'complete',
      'replay',
      'reading_view',
      'reading_failed',
      'paywall_view',
    },
    'stage': {
      'intro',
      'doors',
      'branch',
      'outcome',
      'cups',
      'well',
      'reveal',
      'reaction',
      'ending',
      'reading',
    },
    'guide': {'aelinn', 'eriol'},
    'ending_id': {'full_hands', 'honest_wish', 'fair_echoes', 'own_evening'},
    'choice_id': {
      'door_potions',
      'door_migo',
      'door_tea',
      'door_stage',
      'potion_bravery',
      'potion_love',
      'potion_carefree',
      'migo_risk',
      'migo_watch',
      'migo_cheat',
      'migo_deal',
      'cup_0',
      'cup_1',
      'cup_2',
      'tea_talk',
      'tea_quiet',
      'tea_walk',
      'stage_sing',
      'stage_hum',
      'stage_flee',
      'well_aloud',
      'well_whisper',
      'well_look',
      'reaction_accept',
      'reaction_deny',
      'reaction_recompose',
    },
    'payment_provider': {
      'apple',
      'app_store',
      'storekit',
      'google',
      'google_play',
      'arc_pay',
      'arcpay',
      'unknown',
    },
    'payment_type': {
      'one_time',
      'subscription',
      'recurring',
      'unknown',
      'real_money',
      'internal_coins',
    },
    'offer_type': {
      'subscription',
      'coins',
      'stars',
      'one_time',
      'trial',
      'pro',
      'unknown',
      'coin_package',
      'request_pack',
      'one_off_unlock',
      'shop_item',
      'pro_unlock',
    },
    'variant': {
      'general',
      'love',
      'career',
      'day',
      'week',
      'month',
      'year',
      'daily',
      'weekly',
      'monthly',
      'yearly',
      'single',
      'three',
      'celtic',
      'one_card',
      'three_cards',
      'basic',
      'full',
      'spread',
    },
    'outcome': {
      'success',
      'failed',
      'cancelled',
      'pending',
      'expired',
      'restored',
    },
    'auth_method': {'email'},
    'generation_status': {'success', 'failed', 'timeout'},
  };

  static Map<String, Object?> sanitize(Map<String, dynamic> params) {
    final result = <String, Object?>{};
    final restoreId = params['restore_id'];
    if (restoreId is String && Uuid.isValidUUID(fromString: restoreId)) {
      result['restore_id'] = restoreId;
      if (params['outcome'] == 'empty') result['outcome'] = 'empty';
      final count = params['restored_count'];
      if (count is int && count >= 0 && count <= 100000) {
        result['restored_count'] = count;
      }
    }
    for (final key in ['product_id', 'plan_id', 'package_id']) {
      if (ProductCatalog.allIds.contains(params[key])) {
        result[key] = params[key];
      }
    }
    // The displayed offer price is context, not client-reported revenue.
    // Preserve it through repeated sanitization for storage and AF projection.
    if (result.containsKey('product_id') ||
        result.containsKey('plan_id') ||
        result.containsKey('package_id')) {
      final price = params['price'];
      if (price is num && price.isFinite && price >= 0) {
        result['price'] = price;
      }
      final currency = params['currency'] ?? params['af_currency'];
      if (currency is String && RegExp(r'^[A-Za-z]{3}$').hasMatch(currency)) {
        result['currency'] = currency.toUpperCase();
      }
    }
    for (final entry in _values.entries) {
      final value = params[entry.key];
      if (value is String && entry.value.contains(value)) {
        result[entry.key] = value;
      }
    }
    final feature =
        params['feature'] ?? params['feature_name'] ?? params['funnel_type'];
    if (features.contains(feature)) result['feature'] = feature;
    for (final key in ['screen', 'origin_surface']) {
      final value =
          params[key] ?? (key == 'screen' ? params['screen_name'] : null);
      if (screens.contains(value)) result[key] = value;
    }
    for (final key in ['step_index', 'generation_seconds', 'message_index']) {
      final value = params[key];
      if (value is int && value >= 0 && value <= 100000) result[key] = value;
    }
    for (final key in ['is_signup', 'is_new_user']) {
      if (params[key] is bool) result[key] = params[key];
    }
    return result;
  }

  static CanonicalAnalyticsEvent? map(
    String source,
    Map<String, dynamic> params,
  ) {
    if (source.startsWith('ast_star_fair_')) {
      final action = source.substring('ast_star_fair_'.length);
      const events = {
        'start': 'feature_action_started',
        'resume': 'feature_action_started',
        'choice': 'feature_action_started',
        'replay': 'feature_action_started',
        'complete': 'feature_result_viewed',
        'reading_view': 'feature_result_viewed',
        'reading_failed': 'feature_action_failed',
        'paywall_view': 'paywall_viewed',
      };
      final event = events[action];
      if (event == null) return null;
      return CanonicalAnalyticsEvent(
        event,
        sanitize({...params, 'feature': 'star_fair', 'game_action': action}),
      );
    }
    if (source == 'restore_started' || source == 'restore_outcome') {
      final id = params['restore_id'];
      if (id is! String || !Uuid.isValidUUID(fromString: id)) return null;
      final payload = <String, Object?>{'restore_id': id};
      if (source == 'restore_outcome') {
        final outcome = params['outcome'];
        if (!const {'success', 'empty', 'failed'}.contains(outcome)) {
          return null;
        }
        payload['outcome'] = outcome;
        final count = params['restored_count'];
        if (count is int && count >= 0 && count <= 100000) {
          payload['restored_count'] = count;
        }
      }
      return CanonicalAnalyticsEvent(source, payload);
    }
    if (source == 'ast_tarot_card_reveal') return null;
    if (source == 'ast_runes_reveal') return null;
    if (source == 'ast_moon_paywall_view' &&
        params['origin_surface'] == 'horoscope') {
      return null;
    }
    final payload = sanitize(params);
    String? name;
    if (source == 'checkout_outcome' ||
        source == 'offer_selected' ||
        source == 'feature_action_started' ||
        source == 'feature_action_failed') {
      if (!payload.containsKey('feature')) return null;
      if (source == 'checkout_outcome' && !payload.containsKey('outcome')) {
        return null;
      }
      name = source;
    } else if (source == 'ast_screen_view') {
      if (!payload.containsKey('screen')) return null;
      name = 'screen_viewed';
    } else if (source == 'ast_error_state_view' &&
        payload['screen'] == '/anakra-chat') {
      name = 'feature_action_failed';
      payload['feature'] = 'anakra';
    } else if (source == 'onboarding_step_view') {
      name = 'onboarding_step_viewed';
    } else if (source == 'ast_auth_code_verify_success' ||
        source == 'ast_auth_code_verify_failed') {
      name = 'auth_result';
      payload['outcome'] = source.endsWith('_success') ? 'success' : 'failed';
      payload['auth_method'] = 'email';
    } else if (source.startsWith('ast_')) {
      final suffix = source.substring(4);
      final split = suffix.indexOf('_');
      if (split < 0) return null;
      final feature = _prefixes[suffix.substring(0, split)];
      if (feature == null) return null;
      final action = suffix.substring(split + 1);
      payload['feature'] = feature;
      // ast_*_start is screen entry; actual requests are mapped separately.
      if (action == 'generation_complete') {
        if (params['generation_status'] != 'success') {
          name = 'feature_action_failed';
        }
      }
      if (const {
        'result_view',
        'response_view',
        'card_reveal',
        'reveal',
        'card_view',
      }.contains(action)) {
        if (params['result_status'] != null &&
            params['result_status'] != 'success') {
          return null;
        }
        name = 'feature_result_viewed';
      }
      if (action == 'paywall_view') name = 'paywall_viewed';
      if (const {'package_select', 'plan_select'}.contains(action)) {
        name = 'offer_selected';
      }
      if (action == 'purchase_start') name = 'checkout_started';
      if (const {
        'purchase_success',
        'purchase_failed',
        'purchase_cancelled',
        'purchase_expired',
      }.contains(action)) {
        name = 'checkout_outcome';
        payload['outcome'] = action.substring('purchase_'.length);
        if (const {
          'canceled',
          'cancelled',
          'user_cancelled',
        }.contains(params['failure_reason'])) {
          payload['outcome'] = 'cancelled';
        } else if (params['failure_reason'] == 'pending') {
          payload['outcome'] = 'pending';
        }
      }
      // Opening a feature and each subsequent request are distinct attempts.
      if (const {'message_sent', 'dream_submit'}.contains(action)) {
        name = 'feature_action_started';
      }
    } else {
      // Only legacy signals without an ast_* equivalent at the same call site.
      const legacy = <String, (String, String)>{
        'tarot_card_view': ('feature_result_viewed', 'tarot'),
        'rune_view': ('feature_result_viewed', 'runes'),
        'love_deck_card_view': ('feature_result_viewed', 'love_deck'),
        'kelt_deck_card_view': ('feature_result_viewed', 'kelt_deck'),
        'horoscope_view': ('feature_result_viewed', 'horoscope'),
        'moon_day_view': ('feature_result_viewed', 'moon'),
        'article_opened': ('feature_action_started', 'articles'),
        'article_read': ('feature_result_viewed', 'articles'),
      };
      final mapped = legacy[source];
      if (mapped != null) {
        if (source == 'horoscope_view' && params['result_status'] == 'locked') {
          return null;
        }
        if (source == 'rune_view' && params['rune_id'] == null) return null;
        name = mapped.$1;
        payload['feature'] = mapped.$2;
        const variants = {
          'card_of_day': 'day',
          'rune_of_day': 'day',
          'deck': 'spread',
        };
        final variant = variants[params['context']];
        if (variant != null) payload['variant'] = variant;
      }
      if (source == 'calculation_started' &&
          const {
            'compatibility',
            'natal_chart',
            'horoscope',
          }.contains(payload['feature'])) {
        name = 'feature_action_started';
      }
      if (source == 'paywall_view' &&
          const {
            'horoscope',
            'love_deck',
            'kelt_deck',
          }.contains(payload['feature'])) {
        name = 'paywall_viewed';
      }
    }
    if (payload['feature'] == 'stars' &&
        [
          payload['product_id'],
          payload['package_id'],
          payload['plan_id'],
        ].any(ProductCatalog.subscriptionIds.contains)) {
      payload['feature'] = 'subscription';
    }
    return name == null ? null : CanonicalAnalyticsEvent(name, payload);
  }
}
