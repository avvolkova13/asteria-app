import 'package:asteria_app/core/ui_kit/widgets/asteria_entrance.dart';
import 'package:asteria_app/core/ui_kit/widgets/lotus_feedback.dart';
import 'package:asteria_app/core/ui_kit/widgets/lotus_raster_icon.dart';
import 'dart:ui' as ui;
import 'package:asteria_app/core/ui_kit/widgets/lotus_icon_surface.dart';
import 'package:asteria_app/app/data/models/user/user_model.dart';
import 'package:asteria_app/app/providers/user_provider.dart';
import 'package:asteria_app/core/di/di.dart';
import 'package:asteria_app/core/ui_kit/ui_kit.dart';
import 'package:asteria_app/core/ui_kit/widgets/clay_icon.dart';
import 'package:asteria_app/core/ui_kit/widgets/static_glass_surface.dart';
import 'package:asteria_app/features/achievements/presentation/achievements_style.dart';
import 'package:asteria_app/features/achievements/presentation/widgets/achievement_card.dart';
import 'package:asteria_app/features/monetization/presentation/monetization_provider.dart';
import 'package:asteria_app/features/profile_flow/profile_flow_ui.dart';
import 'package:flutter/material.dart';

class AchievementsScreen extends StatelessWidget {
  const AchievementsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final userProvider = di.get<UserProvider>();
    return ListenableBuilder(
      listenable: userProvider,
      builder: (context, _) {
        final statistics =
            userProvider.currentUser?.statistics ?? const UserStatisticsModel();
        return Scaffold(
          backgroundColor: AchievementsStyle.background,
          body: StaticGlassBackdrop(
            asset: 'assets/images/home/profile_background.webp',
            paintBackdrop: AchievementsStyle.paintBackground,
            child: SafeArea(
              bottom: false,
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(16, 13, 16, 48),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: AsteriaEntrance.sections([
                    const _AchievementsHeader(),
                    const SizedBox(height: 30),
                    Text(
                      context.l10n.achievementsTitle,
                      style: AchievementsStyle.title.copyWith(
                        fontSize: 32,
                        height: 1,
                      ),
                    ),
                    const SizedBox(height: 16),
                    AchievementCard(
                      key: const ValueKey('achievement-tarot'),
                      id: 'tarot',
                      imageAsset:
                          'assets/images/achievements/balance_reward_tarot.webp',
                      title: context.l10n.achievementTarot,
                      completedCount: statistics.tarotCardsOpened,
                      totalCount: 5,
                    ),
                    const SizedBox(height: 16),
                    AchievementCard(
                      key: const ValueKey('achievement-horoscope'),
                      id: 'horoscope',
                      imageAsset:
                          'assets/images/achievements/achievement-horoscope-figma.webp',
                      title: context.l10n.achievementHoroscope,
                      completedCount: statistics.horoscopeOpened,
                      totalCount: 3,
                    ),
                    const SizedBox(height: 16),
                    AchievementCard(
                      key: const ValueKey('achievement-runes'),
                      id: 'runes',
                      imageAsset:
                          'assets/images/achievements/achievement-rune-figma.webp',
                      // The export includes eight points of shadow on each side.
                      imageSize: const Size(65, 96),
                      title: context.l10n.achievementRunes,
                      completedCount: statistics.runesOpened,
                      totalCount: 3,
                    ),
                  ]),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _AchievementsHeader extends StatelessWidget {
  const _AchievementsHeader();

  @override
  Widget build(BuildContext context) {
    final monetization = MonetizationProvider.maybeOf(context);
    final balance = monetization?.balance ?? 0;
    final hasPro = monetization?.effectivePro ?? false;
    final style = AchievementsStyle.title.copyWith(
      fontSize: 17,
      fontWeight: FontWeight.w600,
      fontVariations: const [ui.FontVariation('wght', 600)],
      height: 1.2,
    );
    final wallet = Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text('$balance', style: style),
        const SizedBox(width: 3),
        LotusRasterIcon('assets/icons/star_coin_icon.png', width: 13, height: 13),
        const SizedBox(width: 10),
        ProfileProPill(isActive: hasPro),
      ],
    );
    return LayoutBuilder(
      builder: (context, constraints) {
        final wrapWallet =
            constraints.maxWidth < 340 ||
            MediaQuery.textScalerOf(context).scale(17) > 22 ||
            balance.toString().length > 6;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Row(
              children: [
                SizedBox(
                  width: 28,
                  height: 44,
                  child: LotusButtons.icon(
                    onPressed: () => Navigator.of(context).pop(),
                    tooltip: MaterialLocalizations.of(
                      context,
                    ).backButtonTooltip,
                    padding: EdgeInsets.zero,
                    icon: const LotusIconSurface(
                      diameter: 28,
                      child: SizedBox.square(
                        dimension: 28,
                        child: Center(
                          child: ClayIcon(
                            Icons.chevron_left,
                            size: 20,
                            color: Color(0xFFB5AAB8),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(context.l10n.achievementsTitle, style: style),
                ),
                if (!wrapWallet) ...[const SizedBox(width: 8), wallet],
              ],
            ),
            if (wrapWallet) ...[const SizedBox(height: 8), wallet],
          ],
        );
      },
    );
  }
}
