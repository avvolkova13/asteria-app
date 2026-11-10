import 'package:asteria_app/core/analytics/durable/analytics_taxonomy.dart';
import 'package:asteria_app/core/analytics/apps_flyer_events.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test(
    'offer price and currency survive repeated sanitization without revenue',
    () {
      final clean = AnalyticsTaxonomy.sanitize({
        'plan_id': 'asteria_pro_year',
        'price': 0,
        'af_currency': 'usd',
        'af_revenue': 29.99,
      });
      expect(clean, {
        'plan_id': 'asteria_pro_year',
        'price': 0,
        'currency': 'USD',
      });
      expect(AnalyticsTaxonomy.sanitize(clean), clean);
      expect(AppsFlyerEvents.sanitize(clean), clean);
    },
  );
  test('invalid offer amounts and currency are omitted', () {
    for (final price in [-1, double.nan, double.infinity, '29.99']) {
      expect(
        AnalyticsTaxonomy.sanitize({
          'plan_id': 'asteria_pro_year',
          'price': price,
        }).containsKey('price'),
        isFalse,
      );
    }
    for (final currency in ['US', 'USDD', '123', ' USD ', 123]) {
      expect(
        AnalyticsTaxonomy.sanitize({
          'plan_id': 'asteria_pro_year',
          'currency': currency,
        }).containsKey('currency'),
        isFalse,
      );
    }
    expect(
      AnalyticsTaxonomy.sanitize({'price': 29.99, 'currency': 'USD'}),
      isEmpty,
    );
  });

  test('restore events retain correlation but never checkout or revenue', () {
    const id = 'aaaaaaaa-aaaa-4aaa-8aaa-aaaaaaaaaaaa';
    for (final outcome in ['success', 'empty', 'failed']) {
      final event = AnalyticsTaxonomy.map('restore_outcome', {
        'restore_id': id,
        'outcome': outcome,
        'restored_count': 1,
        'af_revenue': 4.99,
        'email': 'private@example.test',
        'attempt_id': 'previous-checkout',
        'signed_transaction': 'private-jws',
      });
      expect(event?.name, 'restore_outcome');
      expect(event?.payload, {
        'restore_id': id,
        'outcome': outcome,
        'restored_count': 1,
      });
    }
    expect(AppsFlyerEvents.additional('restore_outcome', {}), isNull);
    expect(
      AnalyticsTaxonomy.map('restore_outcome', {'outcome': 'success'}),
      isNull,
    );
  });
  test('rune daily duplicate and yearly horoscope alias are suppressed', () {
    expect(
      AnalyticsTaxonomy.map('rune_view', {
        'rune_id': 'rune',
        'context': 'rune_of_day',
      })?.name,
      'feature_result_viewed',
    );
    expect(AnalyticsTaxonomy.map('ast_runes_reveal', {}), isNull);
    expect(
      AnalyticsTaxonomy.map('paywall_view', {
        'feature_name': 'horoscope',
      })?.payload['feature'],
      'horoscope',
    );
    expect(
      AnalyticsTaxonomy.map('ast_moon_paywall_view', {
        'origin_surface': 'horoscope',
      }),
      isNull,
    );
  });
  test(
    'ArcPay generic coin outcome for a PRO product stays in subscription funnel',
    () {
      final event = AnalyticsTaxonomy.map('ast_coin_purchase_success', {
        'package_id': 'asteria_pro_month',
      });
      expect(event?.payload['feature'], 'subscription');
    },
  );
  test('canonical actions and results cover all existing feature families', () {
    for (final feature in [
      'compatibility',
      'natal',
      'sonnik',
      'anakra',
      'tarot',
      'runes',
      'moon',
      'affirmations',
    ]) {
      final event = AnalyticsTaxonomy.map('ast_${feature}_start', {});
      expect(event, isNull, reason: '$feature screen entry is not an action');
    }
    for (final name in [
      'ast_compatibility_result_view',
      'ast_natal_result_view',
      'ast_sonnik_result_view',
      'ast_anakra_response_view',
      'tarot_card_view',
      'ast_affirmation_card_view',
      'love_deck_card_view',
      'kelt_deck_card_view',
      'horoscope_view',
      'moon_day_view',
    ]) {
      expect(
        AnalyticsTaxonomy.map(name, {})?.name,
        'feature_result_viewed',
        reason: name,
      );
    }
  });

  test(
    'generated actions use requests rather than screen entry and articles are explicit',
    () {
      for (final feature in ['compatibility', 'natal_chart', 'horoscope']) {
        expect(
          AnalyticsTaxonomy.map('calculation_started', {
            'feature_name': feature,
          })?.name,
          'feature_action_started',
        );
      }
      expect(
        AnalyticsTaxonomy.map('calculation_started', {
          'feature_name': 'sonnik',
        }),
        isNull,
      );
      expect(
        AnalyticsTaxonomy.map('ast_sonnik_dream_submit', {})?.name,
        'feature_action_started',
      );
      expect(
        AnalyticsTaxonomy.map('ast_anakra_message_sent', {})?.name,
        'feature_action_started',
      );
      expect(
        AnalyticsTaxonomy.map('article_opened', {})?.payload['feature'],
        'articles',
      );
      expect(
        AnalyticsTaxonomy.map('article_read', {'text': 'private'})?.payload,
        {'feature': 'articles'},
      );
    },
  );

  test('generation errors are failures, successful generation is not a view', () {
    expect(
      AnalyticsTaxonomy.map('ast_sonnik_generation_complete', {
        'generation_status': 'failed',
      })?.name,
      'feature_action_failed',
    );
    expect(
      AnalyticsTaxonomy.map('ast_sonnik_generation_complete', {
        'generation_status': 'success',
      }),
      isNull,
    );
    expect(
      AnalyticsTaxonomy.map('ast_anakra_response_view', {
        'result_status': 'failed',
      }),
      isNull,
    );
    expect(
      AnalyticsTaxonomy.map('ast_anakra_response_view', {
        'result_status': 'greeting',
      }),
      isNull,
    );
    expect(
      AnalyticsTaxonomy.map('horoscope_view', {'result_status': 'locked'}),
      isNull,
    );
    expect(AnalyticsTaxonomy.map('rune_view', {}), isNull);
    expect(
      AnalyticsTaxonomy.map('rune_view', {
        'rune_id': '1',
        'context': 'rune_of_day',
      })?.name,
      'feature_result_viewed',
    );
    expect(
      AnalyticsTaxonomy.map('tarot_card_view', {
        'context': 'card_of_day',
      })?.name,
      'feature_result_viewed',
    );
    expect(
      AnalyticsTaxonomy.map('ast_tarot_card_reveal', {}),
      isNull,
      reason:
          'The existing UI fires this before checking access or loading insight',
    );
  });

  test(
    'server facts and duplicate legacy aliases never become client events',
    () {
      for (final name in [
        'payment_succeeded',
        'payment_refunded',
        'trial_started',
        'stars_spent',
        'stars_refunded',
        'registration_completed',
        'profile_completed',
        'ast_activation_complete',
        'ast_birth_data_complete',
        'af_purchase',
        'af_coins_purchase',
        'ast_coin_spend_success',
        'app_open',
        'ast_app_open',
        'compatibility_result_view',
        'sonnik_result_view',
        'anakra_answer_received',
      ]) {
        expect(AnalyticsTaxonomy.map(name, {}), isNull, reason: name);
      }
    },
  );

  test(
    'checkout outcome strips revenue, identity, secrets and arbitrary text',
    () {
      final mapped = AnalyticsTaxonomy.map('ast_coin_purchase_success', {
        'af_revenue': 120,
        'af_currency': 'RUB',
        'price': 120,
        'user_id': 'alice',
        'token': 'secret',
        'failure_reason': 'private server message',
        'screen_name': '/auth/email?email=private@example.com',
        'feature_name': 'private free text',
        'dream': 'private dream',
        'payment_provider': 'google_play',
        'payment_type': 'one_time',
      });
      expect(mapped?.name, 'checkout_outcome');
      expect(mapped?.payload, {
        'feature': 'stars',
        'outcome': 'success',
        'payment_provider': 'google_play',
        'payment_type': 'one_time',
      });
      expect(
        AppsFlyerEvents.additional('ast_coin_purchase_success', {}),
        isNull,
      );
      expect(AppsFlyerEvents.additional('af_purchase', {}), isNull);
      expect(
        AppsFlyerEvents.fromCanonical('checkout_started', {}),
        'af_initiated_checkout',
      );
    },
  );

  test('onboarding and verified auth map without duplicating server facts', () {
    expect(
      AnalyticsTaxonomy.map('onboarding_step_view', {'step_index': 2})?.name,
      'onboarding_step_viewed',
    );
    expect(
      AnalyticsTaxonomy.map(
        'ast_auth_code_verify_success',
        {},
      )?.payload['outcome'],
      'success',
    );
    expect(
      AnalyticsTaxonomy.map(
        'ast_auth_code_verify_failed',
        {},
      )?.payload['outcome'],
      'failed',
    );
    expect(
      AnalyticsTaxonomy.map('ast_subscription_plan_select', {})?.name,
      'offer_selected',
    );
  });

  test('only catalog offer IDs survive and cancellation keeps its outcome', () {
    final mapped = AnalyticsTaxonomy.map('ast_subscription_purchase_failed', {
      'plan_id': 'asteria_pro_year',
      'failure_reason': 'canceled',
      'package_id': 'private text',
      'payment_type': 'subscription',
    });
    expect(mapped?.payload['plan_id'], 'asteria_pro_year');
    expect(mapped?.payload['package_id'], isNull);
    expect(mapped?.payload['outcome'], 'cancelled');
  });
}
