import 'package:asteria_app/core/ui_kit/ui_kit.dart';
import 'package:asteria_app/core/ui_kit/widgets/clay_icon.dart';
import 'package:asteria_app/features/balance/domain/reward_models.dart';
import 'package:asteria_app/features/balance/presentation/provider/rewards_provider.dart';
import 'package:asteria_app/features/profile_flow/profile_flow_ui.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class EarnRewardsSection extends StatelessWidget {
  const EarnRewardsSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<RewardsProvider>(
      builder: (context, provider, child) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    context.l10n.rewardsHowEarn,
                    style: context.textTheme.inversePlayfairSemiBold32,
                  ),
                ),
                if (provider.isLoading)
                  const SizedBox.square(
                    dimension: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: ProfileFlowColors.accent,
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 16),
            if (provider.error != null) ...[
              ProfileGlassCard(
                padding: const EdgeInsets.all(12),
                color: AppColors.error.withValues(alpha: 0.16),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        _localizedError(context, provider.error!),
                        style: context.textTheme.inverseUrbanistRegular14,
                      ),
                    ),
                    TextButton(
                      onPressed: provider.load,
                      child: Text(context.l10n.balanceRewardRetry),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
            ],
            for (var index = 0; index < provider.items.length; index++) ...[
              _RewardCard(item: provider.items[index]),
              if (index != provider.items.length - 1)
                const SizedBox(height: 16),
            ],
          ],
        );
      },
    );
  }

  String _localizedError(BuildContext context, RewardErrorCode error) =>
      switch (error) {
        RewardErrorCode.startFailed => context.l10n.rewardStartError,
        RewardErrorCode.loadFailed => context.l10n.rewardLoadError,
        RewardErrorCode.shareFailed => context.l10n.rewardShareError,
      };
}

class _RewardCard extends StatelessWidget {
  final RewardStatusModel item;

  const _RewardCard({required this.item});

  bool get _isComplete =>
      item.status == RewardStatusValue.completed ||
      item.status == RewardStatusValue.cooldown;

  bool get _showsProgress =>
      item.target > 1 ||
      item.status == RewardStatusValue.completed ||
      item.status == RewardStatusValue.cooldown;

  String _progressText(BuildContext context) {
    if (item.status == RewardStatusValue.cooldown) {
      return context.l10n.rewardAvailableNextMonth;
    }
    if (item.target > 1 && !_isComplete) {
      return '${item.current} ${context.l10n.commonOf} ${item.target}';
    }
    return _isComplete
        ? context.l10n.rewardCompleted
        : _localizedFrequency(context);
  }

  String _localizedFrequency(BuildContext context) =>
      item.id == 'share' || item.frequency == 'monthly'
      ? context.l10n.rewardMonthly
      : context.l10n.rewardOneTime;

  String _localizedTitle(BuildContext context) => switch (item.id) {
    'onboarding' => context.l10n.rewardCompleteOnboarding,
    'tarot' => context.l10n.rewardTarotReading,
    'articles' => context.l10n.rewardReadArticles,
    'share' => context.l10n.rewardShare,
    'login_streak' => context.l10n.rewardLoginStreak,
    _ => item.title,
  };

  double get _progressValue {
    if (_isComplete) return 1;
    if (item.target <= 0) return 0;
    return (item.current / item.target).clamp(0.0, 1.0);
  }

  IconData get _icon => switch (item.id) {
    'onboarding' => Icons.auto_awesome,
    'tarot' => Icons.style_outlined,
    'articles' => Icons.menu_book_outlined,
    'share' => Icons.ios_share,
    'login_streak' => Icons.calendar_month_outlined,
    _ => Icons.star_outline,
  };

  String? get _assetPath => switch (item.id) {
    'onboarding' => 'assets/images/achievements/balance_reward_onboarding.webp',
    'tarot' => 'assets/images/achievements/balance_reward_tarot.webp',
    'articles' => 'assets/images/achievements/balance_reward_articles.webp',
    'share' => 'assets/images/achievements/balance_reward_share.webp',
    'login_streak' =>
      'assets/images/achievements/balance_reward_login_streak.webp',
    _ => null,
  };

  Future<void> _share(BuildContext context) async {
    final renderBox = context.findRenderObject() as RenderBox?;
    final origin = renderBox == null
        ? null
        : renderBox.localToGlobal(Offset.zero) & renderBox.size;
    final amount = await context.read<RewardsProvider>().shareInvite(
      text: context.l10n.rewardShareText('{link}'),
      subject: context.l10n.rewardShareSubject,
      origin: origin,
    );
    if (!context.mounted || amount <= 0) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(
      SnackBar(content: Text('${context.l10n.rewardGranted}: $amount')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<RewardsProvider>();
    final canShare =
        item.id == 'share' &&
        item.status == RewardStatusValue.available &&
        !provider.isSharing;
    final isSharing = provider.isSharing && item.id == 'share';
    final bodyText = _showsProgress
        ? _localizedFrequency(context)
        : _progressText(context);

    return ProfileGlassCard(
      key: ValueKey('reward_card_${item.id}'),
      onTap: canShare ? () => _share(context) : null,
      padding: const EdgeInsets.all(8),
      color: const Color(0x6633214A),
      child: SizedBox(
        height: 112,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _RewardArtwork(
              assetPath: _assetPath,
              icon: _icon,
              itemId: item.id,
              isComplete: _isComplete,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(top: 2, right: 2, bottom: 3),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Text(
                            _localizedTitle(context),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: context.textTheme.inversePlayfairSemiBold24
                                .copyWith(fontSize: 20, height: 1.02),
                          ),
                        ),
                        const SizedBox(width: 6),
                        _RewardAmount(item: item, isSharing: isSharing),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      bodyText,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: context.textTheme.inverseUrbanistRegular16
                          .copyWith(
                            color: ProfileFlowColors.textMuted,
                            height: 1.05,
                          ),
                    ),
                    if (_showsProgress) ...[
                      const Spacer(),
                      _RewardProgressBar(value: _progressValue),
                      const SizedBox(height: 7),
                      _RewardStatusLabel(text: _progressText(context)),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RewardArtwork extends StatelessWidget {
  const _RewardArtwork({
    required this.assetPath,
    required this.icon,
    required this.itemId,
    required this.isComplete,
  });

  final String? assetPath;
  final IconData icon;
  final String itemId;
  final bool isComplete;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 112,
      height: 112,
      decoration: BoxDecoration(
        color: const Color(0xFF342848).withValues(alpha: 0.78),
        borderRadius: BorderRadius.circular(32),
      ),
      clipBehavior: Clip.hardEdge,
      child: assetPath == null
          ? ClayIcon(
              icon,
              color: isComplete ? AppColors.success : ProfileFlowColors.purple,
              size: 44,
            )
          : _RewardImage(assetPath: assetPath!, itemId: itemId),
    );
  }
}

class _RewardImage extends StatelessWidget {
  const _RewardImage({required this.assetPath, required this.itemId});

  final String assetPath;
  final String itemId;

  @override
  Widget build(BuildContext context) {
    final isTarot = itemId == 'tarot';

    return Center(
      child: Image.asset(
        assetPath,
        width: isTarot ? 78 : 112,
        height: isTarot ? 104 : 112,
        cacheWidth: isTarot ? 180 : 224,
        fit: isTarot ? BoxFit.contain : BoxFit.cover,
      ),
    );
  }
}

class _RewardAmount extends StatelessWidget {
  const _RewardAmount({required this.item, required this.isSharing});

  final RewardStatusModel item;
  final bool isSharing;

  @override
  Widget build(BuildContext context) {
    if (isSharing) {
      return const SizedBox.square(
        dimension: 20,
        child: CircularProgressIndicator(
          strokeWidth: 2,
          color: ProfileFlowColors.accent,
        ),
      );
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          '+${item.amount}',
          style: context.textTheme.inversePlayfairSemiBold24.copyWith(
            fontSize: 20,
            height: 1,
          ),
        ),
        const SizedBox(width: 3),
        Image.asset('assets/icons/star_coin_icon.png', width: 16, height: 16),
      ],
    );
  }
}

class _RewardStatusLabel extends StatelessWidget {
  const _RewardStatusLabel({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    final style = context.textTheme.inverseUrbanistSemiBold14.copyWith(
      color: ProfileFlowColors.accent,
      fontSize: 13,
      height: 1,
      letterSpacing: -0.08,
    );

    return SizedBox(
      width: double.infinity,
      height: 13,
      child: FittedBox(
        fit: BoxFit.scaleDown,
        alignment: Alignment.centerLeft,
        child: Text(text, maxLines: 1, softWrap: false, style: style),
      ),
    );
  }
}

class _RewardProgressBar extends StatelessWidget {
  const _RewardProgressBar({required this.value});

  final double value;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(2),
      child: SizedBox(
        height: 4,
        child: Stack(
          fit: StackFit.expand,
          children: [
            ColoredBox(color: const Color(0xFF24183B).withValues(alpha: 0.82)),
            FractionallySizedBox(
              alignment: Alignment.centerLeft,
              widthFactor: value,
              child: const ColoredBox(color: ProfileFlowColors.accent),
            ),
          ],
        ),
      ),
    );
  }
}
