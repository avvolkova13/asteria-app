import 'dart:io';

import 'package:asteria_app/core/analytics/apps_flyer_events.dart';
import 'package:asteria_app/core/analytics/durable/analytics_taxonomy.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('every allowed screen has a distinct allowed AF name', () {
    final routeNames = <String>{};
    for (final screen in AnalyticsTaxonomy.screens) {
      final name = AppsFlyerEvents.fromCanonical('screen_viewed', {
        'screen': screen,
      });
      expect(name, isNot('ast_screen_view'), reason: screen);
      expect(AppsFlyerEvents.names, contains(name), reason: screen);
      if (screen.startsWith('/')) {
        expect(routeNames.add(name!), isTrue, reason: 'Collision for $screen');
      }
    }
  });

  test(
    'every accepted client action has an AF projection, except diagnostics',
    () {
      final backend = File(
        '${Platform.environment['ASTERIA_BACKEND_PATH'] ?? '../asteria-back'}/app/services/analytics/models.py',
      ).readAsStringSync();
      final declaration = backend
          .split('CLIENT_EVENTS = frozenset({')[1]
          .split('})')[0];
      final names = RegExp(
        "'([a-z_]+)'",
      ).allMatches(declaration).map((m) => m[1]!);
      expect(names, isNotEmpty);
      for (final name in names) {
        final mapped = AppsFlyerEvents.fromCanonical(name, {
          'feature': 'sonnik',
          'screen': '/settings',
          'outcome': 'success',
        });
        if (name == 'analytics_queue_dropped') {
          expect(mapped, isNull);
        } else {
          expect(mapped, isNotNull, reason: name);
          expect(
            mapped,
            isNot(name),
            reason: 'AF must not receive the warehouse name',
          );
          expect(AppsFlyerEvents.names, contains(mapped));
        }
      }
    },
  );

  test(
    'all supported feature families and game actions have allowed names',
    () {
      for (final feature in AnalyticsTaxonomy.features) {
        for (final name in [
          'feature_action_started',
          'feature_result_viewed',
          'feature_action_failed',
          'paywall_viewed',
        ]) {
          expect(
            AppsFlyerEvents.names,
            contains(AppsFlyerEvents.fromCanonical(name, {'feature': feature})),
          );
        }
      }
      for (final action in AppsFlyerEvents.starFairActions) {
        expect(
          AppsFlyerEvents.fromCanonical('feature_action_started', {
            'feature': 'star_fair',
            'game_action': action,
          }),
          'ast_star_fair_$action',
        );
      }
      expect(
        AppsFlyerEvents.fromCanonical('paywall_viewed', {
          'feature': 'star_fair',
          'game_action': 'paywall_view',
        }),
        'ast_paywall_view',
      );
    },
  );

  test('additional live generic signals have no duplicate legacy aliases', () {
    const expected = {
      'onboarding_step_completed': 'ast_onboarding_step_complete',
      'onboarding_skipped': 'ast_onboarding_skip',
      'auth_started': 'ast_auth_start',
      'auth_code_requested': 'ast_auth_code_request',
      'horoscope_unlock_click': 'ast_horoscope_paywall_click',
      'tarot_spread_started': 'ast_tarot_spread_start',
    };
    for (final entry in expected.entries) {
      expect(AppsFlyerEvents.additional(entry.key, {}), entry.value);
      expect(AppsFlyerEvents.names, contains(entry.value));
    }
    for (final name in [
      'af_purchase',
      'ast_app_open',
      'ast_profile_view',
      'ast_coin_purchase_success',
      'ast_coin_spend_success',
      'ast_activation_complete',
      'ast_tarot_card_reveal',
      'ast_runes_reveal',
      'auth_code_verified',
      'login_completed',
    ]) {
      expect(AppsFlyerEvents.additional(name, {}), isNull, reason: name);
    }
  });

  test('AF context is bounded and sanitized even for direct SDK callers', () {
    final params = AppsFlyerEvents.sanitize({
      'event_id': 'aaaaaaaa-aaaa-4aaa-8aaa-aaaaaaaaaaaa',
      'menu_item': 'private@example.test',
      'screen_name': '/settings?email=private',
      'entry_point_id': 'home_natal_card',
      'position': 1,
      'af_revenue': 999,
      'af_currency': 'USD',
      'price': 999,
      'raw_payload': {'secret': 'token'},
      'dream': 'private dream',
      'text': 'private',
      'user_id': 'private',
      'content_id': 'private',
      'environment': 'test',
      'attempt_id': 'not-a-uuid',
    });
    expect(params, {
      'event_id': 'aaaaaaaa-aaaa-4aaa-8aaa-aaaaaaaaaaaa',
      'entry_point_id': 'home_natal_card',
      'position': 1,
      'environment': 'test',
    });
    expect(AppsFlyerEvents.names.every((name) => name.length <= 45), isTrue);
    expect(AppsFlyerEvents.names, isNot(contains('ast_coin_purchase_success')));
  });

  test('additional actions retain controlled input and failure context', () {
    expect(
      AppsFlyerEvents.sanitize({
        'input_mode': 'saved_profile',
        'partner_data_completeness': 'partial',
        'birth_time_precision': 'approx_day',
        'failure_reason': 'network_error',
        'failure_stage': 'confirmation',
        'product_type': 'request_pack',
      }),
      {
        'input_mode': 'saved_profile',
        'partner_data_completeness': 'partial',
        'birth_time_precision': 'approx_day',
        'failure_reason': 'network_error',
        'failure_stage': 'confirmation',
        'product_type': 'request_pack',
      },
    );
    expect(
      AppsFlyerEvents.sanitize({
        'failure_reason': 'exception with private data',
      }),
      isEmpty,
    );
  });

  test(
    'implicit tabs and default result sections do not double count views',
    () {
      expect(
        AppsFlyerEvents.additional('ast_moon_tab_view', {
          'content_type': 'day',
        }),
        isNull,
      );
      expect(
        AppsFlyerEvents.additional('ast_moon_tab_view', {
          'content_type': 'year',
        }),
        isNull,
      );
      expect(
        AppsFlyerEvents.additional('ast_natal_section_view', {
          'content_type': 'overview',
        }),
        isNull,
      );
      for (final feature in AppsFlyerEvents.paywallClicks.keys) {
        expect(
          AppsFlyerEvents.additional('paywall_cta_click', {
            'feature_name': feature,
          }),
          AppsFlyerEvents.paywallClicks[feature],
        );
      }
    },
  );

  test('home impressions require their actual visible tab', () {
    expect(
      AppsFlyerEvents.isVisible('ast_home_card_view', {
        'entry_point_id': 'home_natal_card',
      }, '/home'),
      isFalse,
    );
    expect(
      AppsFlyerEvents.isVisible('ast_home_card_view', {
        'entry_point_id': 'home_natal_card',
      }, '/home/personal'),
      isTrue,
    );
    expect(
      AppsFlyerEvents.isVisible('ast_home_card_view', {
        'entry_point_id': 'home_tarot_card',
      }, '/home'),
      isTrue,
    );
    expect(
      AppsFlyerEvents.isVisible('ast_home_card_view', {
        'entry_point_id': 'home_tarot_card',
      }, '/shop'),
      isFalse,
    );
    expect(
      AppsFlyerEvents.isVisible('ast_home_card_click', {}, '/shop'),
      isTrue,
    );
  });
}
