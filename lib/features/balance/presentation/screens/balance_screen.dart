import 'package:asteria_app/core/ui_kit/widgets/lotus_raster_icon.dart';
import 'package:asteria_app/core/const/pricing_catalog.dart';
import 'package:asteria_app/core/routing/app_route.dart';
import 'package:asteria_app/core/ui_kit/ui_kit.dart';
import 'package:asteria_app/core/ui_kit/widgets/clay_icon.dart';
import 'package:asteria_app/features/balance/presentation/provider/rewards_provider.dart';
import 'package:asteria_app/features/balance/presentation/widgets/earn_rewards_section.dart';
import 'package:asteria_app/features/home/presentation/widgets/card_advertisement_widget.dart';
import 'package:asteria_app/features/profile_flow/profile_flow_ui.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class BalanceScreen extends StatefulWidget {
  const BalanceScreen({super.key});

  @override
  State<BalanceScreen> createState() => _BalanceScreenState();
}

class _BalanceScreenState extends State<BalanceScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) context.read<RewardsProvider>().load();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ProfileFlowColors.background,
      body: ProfileFlowBackground(
        child: SafeArea(
          bottom: false,
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 48),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                ProfileFlowHeader(
                  title: context.l10n.balanceTitle,
                  canPop: true,
                ),
                const SizedBox(height: 28),
                const _IntroText(),
                const SizedBox(height: 24),
                _HistoryButton(onTap: () => BalanceHistoryRoute.push(context)),
                const SizedBox(height: 24),
                const _WhereToSpend(),
                const SizedBox(height: 16),
                ProfilePrimaryButton(
                  onPressed: () => CoinsPaywallRoute.push(context),
                  text: context.l10n.balanceBuy,
                ),
                const SizedBox(height: 24),
                CardAdvertisementWidget(
                  horizontalMargin: 0,
                  variant: CardAdvertisementVariant.balanceSubscriptionBanner,
                  title: context.l10n.balanceSubscriptionPrompt,
                  description: context.l10n.balanceSubscriptionDescription,
                  buttonText: context.l10n.balanceChooseSubscription,
                  onPressed: () => SubscriptionRoute.push(
                    context,
                    params: SubscriptionRouteParams(
                      originSurface: 'balance_subscription_banner',
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                const EarnRewardsSection(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _IntroText extends StatelessWidget {
  const _IntroText();

  @override
  Widget build(BuildContext context) {
    final baseStyle = context.textTheme.inversePlayfairSemiBold24.copyWith(
      fontSize: 20,
      height: 1.08,
    );

    return RichText(
      text: TextSpan(
        style: baseStyle,
        children: [
          TextSpan(
            text: context.l10n.balanceTitle,
            style: baseStyle.copyWith(color: ProfileFlowColors.accent),
          ),
          TextSpan(text: context.l10n.balanceCurrencyDescription),
        ],
      ),
    );
  }
}

class _HistoryButton extends StatelessWidget {
  final VoidCallback onTap;

  const _HistoryButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return ProfileGlassCard(
      onTap: onTap,
      borderRadius: 14,
      padding: const EdgeInsets.symmetric(horizontal: 14),
      color: const Color(0x5C72418A),
      child: SizedBox(
        height: 50,
        child: Row(
          children: [
            Expanded(
              child: Text(
                context.l10n.balanceHistoryTitle,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: context.textTheme.inverseUrbanistRegular17.copyWith(
                  color: ProfileFlowColors.textMuted,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Container(
              width: 22,
              height: 22,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: ProfileFlowColors.accent, width: 2),
              ),
              child: const ClayIcon(
                Icons.chevron_right_rounded,
                color: ProfileFlowColors.accent,
                size: 18,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _WhereToSpend extends StatelessWidget {
  const _WhereToSpend();

  List<_SpendItemData> _items(BuildContext context) => [
    _SpendItemData(
      icon: 'assets/icons/sub/moon_icon.svg',
      text: context.l10n.balanceServiceAnakra,
      price: PricingCatalog.aiAstrologerQuestion,
    ),
    _SpendItemData(
      icon: 'assets/icons/sphere_icon/ic_award.svg',
      text: context.l10n.balanceServiceDream,
      price: PricingCatalog.dreamInterpretation,
    ),
    _SpendItemData(
      icon: 'assets/icons/sub/people_icon.svg',
      text: context.l10n.balanceServiceCompatibility,
      price: PricingCatalog.compatibilityRequest,
    ),
    _SpendItemData(
      icon: 'assets/icons/sub/star_icon.svg',
      text: context.l10n.balanceServiceTarot,
      price: PricingCatalog.paidTarotSpread,
    ),
    _SpendItemData(
      icon: 'assets/icons/sub/lock_icon.svg',
      text: context.l10n.balanceServiceYearForecast,
      price: PricingCatalog.yearlyHoroscope,
    ),
    _SpendItemData(
      icon: 'assets/icons/sphere_icon/ic_award.svg',
      text: context.l10n.balanceServiceNatal,
      price: PricingCatalog.natalChart,
    ),
  ];

  Widget _buildItem(_SpendItemData item, BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(minHeight: 32),
      child: Row(
        children: [
          ClayAssetIcon(
            item.icon,
            width: 24,
            height: 24,
            tint: ProfileFlowColors.accent,
          ),
          const SizedBox(width: 9),
          Expanded(
            child: Text(
              item.text,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: context.textTheme.inverseUrbanistRegular16.copyWith(
                color: ProfileFlowColors.textMuted,
                height: 1.05,
              ),
            ),
          ),
          const SizedBox(width: 8),
          _PricePill(price: item.price),
        ],
      ),
    );
  }

  Widget _buildDivider() {
    return Padding(
      padding: const EdgeInsets.only(left: 33, top: 6, bottom: 6),
      child: Divider(
        height: 1,
        thickness: 1,
        color: const Color(0xFF25183E).withValues(alpha: 0.72),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ProfileGlassCard(
      borderRadius: 8,
      padding: const EdgeInsets.all(16),
      color: const Color(0x6672418A),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            context.l10n.balanceWhereToSpend,
            style: context.textTheme.inversePlayfairSemiBold24.copyWith(
              height: 1.08,
            ),
          ),
          const SizedBox(height: 12),
          for (var index = 0; index < _items(context).length; index++) ...[
            _buildItem(_items(context)[index], context),
            if (index != _items(context).length - 1) _buildDivider(),
          ],
        ],
      ),
    );
  }
}

class _PricePill extends StatelessWidget {
  const _PricePill({required this.price});

  final int price;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minWidth: 48),
      height: 24,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        gradient: const LinearGradient(
          colors: [Color(0xFF8A58FF), Color(0xFF6B39E9)],
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            '$price',
            style: context.textTheme.inverseUrbanistSemiBold16.copyWith(
              height: 1,
            ),
          ),
          const SizedBox(width: 3),
          LotusRasterIcon('assets/icons/star_coin_icon.png', width: 12, height: 12),
        ],
      ),
    );
  }
}

class _SpendItemData {
  final String icon;
  final String text;
  final int price;

  const _SpendItemData({
    required this.icon,
    required this.text,
    required this.price,
  });
}
