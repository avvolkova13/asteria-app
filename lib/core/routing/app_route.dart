import 'package:asteria_app/core/config/app_feature_visibility.dart';
import 'package:asteria_app/features/monetization/presentation/contextual_purchase_page.dart';
import 'package:asteria_app/features/about_us/about_us_screen.dart';
import 'package:asteria_app/features/achievements/presentation/achievements_screen.dart';
import 'package:asteria_app/features/auth/localization/auth_localization_contract.dart';
import 'package:asteria_app/features/auth/presentation/screens/personal_info_input_screen.dart';
import 'package:asteria_app/features/auth/presentation/screens/email_login_screen.dart';
import 'package:asteria_app/features/auth/presentation/screens/email_code_screen.dart';
import 'package:asteria_app/features/auth/presentation/cubit/email_auth_cubit.dart';
import 'package:asteria_app/features/auth/domain/models/auth_identity.dart';
import 'package:asteria_app/core/services/auth/auth_session_service.dart';
import 'package:asteria_app/core/localization/legal_asset_resolver.dart';
import 'package:asteria_app/features/compatibility/presentation/screens/create_compatibility_screen.dart';
import 'package:asteria_app/features/compatibility/presentation/screens/create_compatibility_initial_screen.dart';
import 'package:asteria_app/features/compatibility/presentation/screens/create_compatibility_requests_left_screen.dart';
import 'package:asteria_app/features/compatibility/presentation/screens/create_compatibility_subscription_screen.dart';
import 'package:asteria_app/features/compatibility/presentation/screens/create_compatibility_history_screen.dart';
import 'package:asteria_app/features/compatibility/presentation/screens/create_compatibility_loaded_screen.dart';
import 'package:asteria_app/features/sonnik/presentation/screens/create_sonnik_screen.dart';
import 'package:asteria_app/features/sonnik/presentation/screens/create_sonnik_initial_screen.dart';
import 'package:asteria_app/features/sonnik/presentation/screens/create_sonnik_requests_left_screen.dart';
import 'package:asteria_app/features/sonnik/presentation/screens/create_sonnik_subscription_screen.dart';
import 'package:asteria_app/features/sonnik/presentation/screens/create_sonnik_history_screen.dart';
import 'package:asteria_app/features/sonnik/presentation/screens/create_sonnik_loaded_screen.dart';
import 'package:asteria_app/features/home/home.dart';
import 'package:asteria_app/features/horoscope/presentation/horoscope_screen.dart';
import 'package:asteria_app/features/natal_card/natal_card_screen.dart';
import 'package:asteria_app/features/payments_settings/presentation/payments_settings_screen.dart';
import 'package:asteria_app/features/settings/presentation/settings_screen.dart';
import 'package:asteria_app/features/onboarding/onboarding.dart';
import 'package:asteria_app/features/shop/presentation/shop_screen.dart';
import 'package:asteria_app/features/subscription/presentation/subscription_screen.dart';
import 'package:asteria_app/features/taro_cards/taro_cards_screen.dart';
import 'package:asteria_app/features/runes/runes_screen.dart';
import 'package:asteria_app/features/kelt_deck/kelt_deck_screen.dart';
import 'package:asteria_app/features/love_deck/love_deck_screen.dart';
import 'package:asteria_app/features/article/presentation/article_screen.dart';
import 'package:asteria_app/features/balance/presentation/screens/balance_screen.dart';
import 'package:asteria_app/features/balance/presentation/screens/balance_history_screen.dart';
import 'package:asteria_app/features/affirmation/affirmation_screen.dart';
import 'package:asteria_app/features/affirmation/player/affirmation_player_screen.dart';
import 'package:asteria_app/features/payments/presentation/screens/payments_screen.dart';
import 'package:asteria_app/features/payments/presentation/cubit/arc_pay_checkout_cubit.dart';
import 'package:asteria_app/features/coins_paywall/presentation/screens/coins_paywall_screen.dart';
import 'package:asteria_app/features/anakra_chat/presentation/screens/anakra_chat_screen.dart';
import 'package:asteria_app/features/anakra_chat/presentation/screens/create_anakra_requests_left_screen.dart';
import 'package:asteria_app/features/anakra_chat/presentation/screens/create_anakra_subscription_screen.dart';
import 'package:asteria_app/core/di/di.dart';
import 'package:asteria_app/features/home/presentation/screens/profile_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

part 'routes/onboarding_route.dart';
part 'routes/home_route.dart';
part 'routes/auth_routes.dart';
part 'routes/profile_routes.dart';
part 'routes/settings_route.dart';
part 'routes/subscription_route.dart';
part 'routes/achievements_route.dart';
part 'routes/about_us_route.dart';
part 'routes/payments_settings_route.dart';
part 'routes/shop_route.dart';
part 'routes/horoscope_route.dart';
part 'routes/compatibility_routes.dart';
part 'routes/sonnik_routes.dart';
part 'routes/natal_card_route.dart';
part 'routes/taro_cards_route.dart';
part 'routes/runes_route.dart';
part 'routes/kelt_deck_route.dart';
part 'routes/love_deck_route.dart';
part 'routes/article_route.dart';
part 'routes/balance_routes.dart';
part 'routes/affirmation_route.dart';
part 'routes/payments_route.dart';
part 'routes/coins_paywall_route.dart';
part 'routes/anakra_chat_routes.dart';

Widget $unimplementedRoute(String name) {
  return Scaffold(body: Center(child: Text('Route $name not implemented')));
}

/// Native iOS navigation still owns the edge swipe and route result.
class AsteriaPage<T> extends CupertinoPage<T> {
  const AsteriaPage({required super.child, super.key, super.name});
}

class AppRoute extends GoRoute {
  AppRoute({
    required String super.name,
    Widget? child,
    Page<dynamic> Function(BuildContext, GoRouterState)? pageBuilder,
    String? path,
    super.parentNavigatorKey,
    super.redirect,
    super.onExit,
    super.routes,
  }) : super(
         path: path ?? name,
         pageBuilder: child == null
             ? (pageBuilder ??
                   (context, state) => AsteriaPage<void>(
                     name: name,
                     key: state.pageKey,
                     child: $unimplementedRoute(name),
                   ))
             : (context, state) => AsteriaPage<void>(
                 name: name,
                 key: state.pageKey,
                 child: child,
               ),
       );
}
