import 'package:asteria_app/core/ui_kit/widgets/card_lens_decoration.dart';
import 'package:asteria_app/core/ui_kit/widgets/asteria_entrance.dart';
import 'package:asteria_app/core/ui_kit/widgets/lotus_feedback.dart';
import 'package:asteria_app/core/ui_kit/widgets/lotus_raster_icon.dart';
import 'package:asteria_app/core/ui_kit/widgets/lotus_icon_surface.dart';
import 'package:asteria_app/app/data/models/user/user_model.dart';
import 'package:asteria_app/app/providers/user_provider.dart';
import 'package:asteria_app/core/extensions/datetime_extensions.dart';
import 'package:asteria_app/core/routing/app_route.dart';
import 'package:asteria_app/core/ui_kit/ui_kit.dart';
import 'package:asteria_app/core/ui_kit/widgets/clay_icon.dart';
import 'package:asteria_app/core/ui_kit/widgets/subscription_widget.dart';
import 'package:asteria_app/features/home/presentation/widgets/profile_avatar.dart';
import 'package:asteria_app/features/monetization/presentation/monetization_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

enum TopNavBarType {
  home,
  moon,
  payment,
  profile,
  natalCard,
  horoscope,
  person,
  transparent,
  onlyCollapsed;

  String getImagePath({DateTime? birthDate, Gender? gender}) {
    final moonImage = gender == Gender.male
        ? 'assets/images/home/moon_top_bar_man.webp'
        : 'assets/images/home/moon_top_bar.webp';
    return switch (this) {
      TopNavBarType.horoscope =>
        birthDate != null
            ? 'assets/images/zodiacs/round_zodiacs/${birthDate.getZodiacSignAsset()}.webp'
            : 'assets/images/zodiacs/round_zodiacs/oven.webp',
      TopNavBarType.person => moonImage,
      TopNavBarType.home => moonImage,
      TopNavBarType.profile => moonImage,
      TopNavBarType.moon => moonImage,
      TopNavBarType.payment => moonImage,
      TopNavBarType.natalCard => 'assets/images/home/natal_card_top_bar.webp',
      TopNavBarType.transparent => moonImage,
      TopNavBarType.onlyCollapsed => moonImage,
    };
  }
}

class TopNavBar extends StatelessWidget {
  final String userName;
  final TopNavBarType type;
  final bool canPop;
  final DateTime? birthDate;

  const TopNavBar({
    Key? key,
    required this.userName,
    required this.type,
    this.canPop = false,
    this.birthDate,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    switch (type) {
      case TopNavBarType.payment:
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(children: [
            Expanded(child: _TopNavBarTitle(userName: userName, canPop: canPop)),
            const SizedBox(width: 12),
            const _MoonTopNavBarActions(),
          ]),
        );
      case TopNavBarType.moon:
        return _MoonTopNavBarWidget(userName: userName, canPop: canPop);
      case TopNavBarType.profile:
        return _ProfileTopNavBarWidget(
          userName: userName,
          type: type,
          birthDate: birthDate,
        );
      default:
        return _HomeTopNavBarWidget(
          userName: userName,
          type: type,
          canPop: canPop,
          birthDate: birthDate,
        );
    }
  }
}

class TopNavBarDelegate extends SliverPersistentHeaderDelegate {
  final String userName;
  final TopNavBarType type;
  final bool canPop;
  final DateTime? birthDate;
  final double moonTopPadding;

  const TopNavBarDelegate({
    required this.userName,
    required this.type,
    this.canPop = false,
    this.birthDate,
    this.moonTopPadding = 59,
  });

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    final isCollapsed = shrinkOffset > (maxExtent - minExtent) / 2;

    final currentHeight = (maxExtent - shrinkOffset).clamp(
      minExtent,
      maxExtent,
    );
    final collapsedHeight = _collapsedHeight;

    if (type == TopNavBarType.moon) {
      return SizedBox(
        height: 42 + moonTopPadding,
        child: _MoonTopNavBarWidget(
          userName: userName,
          canPop: canPop,
          topPadding: moonTopPadding,
        ),
      );
    }

    if (type == TopNavBarType.onlyCollapsed) {
      return Align(
        alignment: Alignment.topCenter,
        child: SizedBox(
          height: collapsedHeight,
          child: _buildCollapsedHeader(context, showImage: true),
        ),
      );
    }

    if (type == TopNavBarType.transparent) {
      if (isCollapsed) {
        return Align(
          alignment: Alignment.topCenter,
          child: SizedBox(
            height: collapsedHeight,
            child: _buildCollapsedHeader(context, showImage: true),
          ),
        );
      }
      return SizedBox(
        height: currentHeight,
        child: _TransparentTopNavBar(
          userName: userName,
          type: type,
          canPop: canPop,
          birthDate: birthDate,
        ),
      );
    }

    if (isCollapsed || maxExtent == minExtent) {
      return Align(
        alignment: Alignment.topCenter,
        child: SizedBox(
          height: collapsedHeight,
          child: _buildCollapsedHeader(context, showImage: true),
        ),
      );
    } else {
      if (type == TopNavBarType.transparent) {
        return SizedBox(
          height: currentHeight,
          child: ClipRect(
            child: Align(
              alignment: Alignment.topCenter,
              child: Transform.translate(
                offset: Offset(0, -shrinkOffset),
                child: _TransparentTopNavBar(
                  userName: userName,
                  type: type,
                  canPop: canPop,
                  birthDate: birthDate,
                ),
              ),
            ),
          ),
        );
      }
      return SizedBox(
        height: currentHeight,
        child: ClipRect(
          child: Align(
            alignment: Alignment.topCenter,
            child: Transform.translate(
              offset: Offset(0, -shrinkOffset),
              child: TopNavBar(
                userName: userName,
                type: type,
                canPop: canPop,
                birthDate: birthDate,
              ),
            ),
          ),
        ),
      );
    }
  }

  Widget _buildCollapsedHeader(BuildContext context, {bool showImage = true}) {
    return Container(
      decoration: BoxDecoration(
        image: showImage
            ? DecorationImage(
                image: AssetImage('assets/background/app_bar_short.webp'),
                fit: BoxFit.cover,
              )
            : null,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(16),
          bottomRight: Radius.circular(16),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.only(left: 16, right: 16, top: 32),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: Transform.translate(
                offset: const Offset(0, -2),
                child: Row(
                  children: [
                    if (canPop) ...[
                      _TopNavBackButton(
                        onTap: () => Navigator.of(context).pop(),
                        child: const SizedBox.square(
                          dimension: LotusArrowBubble.hitExtent,
                          child: Center(child: LotusArrowBubble(back: true)),
                        ),
                      ),
                    ],
                    Flexible(
                      child: Text(
                        userName,
                        style: AppTypography.navTitle.copyWith(color: AppColors.textInverse),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ).withEntrance(),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 8),
            Row(
              children: [
                LotusTap(
                  onTap: () => BalanceRoute.push(context),
                  child: Row(
                    children: [
                      Consumer<UserProvider>(
                        builder: (context, userProvider, child) {
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 4),
                            child: Text(
                              '${MonetizationProvider.maybeOf(context)?.balance ?? 0} ',
                              style:
                                  context.textTheme.inverseUrbanistSemiBold17,
                            ).withEntrance(),
                          );
                        },
                      ),
                      Padding(
                        padding: const EdgeInsets.only(bottom: 4),
                        child: LotusRasterIcon(
                          'assets/icons/star_coin_icon.png',
                          height: 16,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                SubscriptionWidget(),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  double get maxExtent {
    switch (type) {
      case TopNavBarType.profile:
        return _profileHeight;
      case TopNavBarType.moon:
        return 42 + moonTopPadding;
      case TopNavBarType.transparent:
      case TopNavBarType.onlyCollapsed:
        return _collapsedHeight;
      default:
        return _defaultHeight;
    }
  }

  @override
  double get minExtent {
    if (type == TopNavBarType.moon) {
      return 42 + moonTopPadding;
    }
    return _collapsedHeight;
  }

  @override
  bool shouldRebuild(covariant SliverPersistentHeaderDelegate oldDelegate) {
    return oldDelegate is TopNavBarDelegate &&
        (oldDelegate.userName != userName ||
            oldDelegate.type != type ||
            oldDelegate.canPop != canPop ||
            oldDelegate.birthDate != birthDate ||
            oldDelegate.moonTopPadding != moonTopPadding);
  }
}

class _MoonTopNavBarWidget extends StatelessWidget {
  final String userName;
  final bool canPop;
  final double topPadding;

  const _MoonTopNavBarWidget({
    required this.userName,
    required this.canPop,
    this.topPadding = 59,
  });

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: AppColors.textPrimary,
      child: SizedBox(
        height: 42 + topPadding,
        width: double.infinity,
        child: Padding(
          padding: EdgeInsets.only(top: topPadding),
          child: SizedBox(
            height: 42,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    child: _TopNavBarTitle(userName: userName, canPop: canPop),
                  ),
                  const SizedBox(width: 12),
                  const _MoonTopNavBarActions(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _TopNavBarTitle extends StatelessWidget {
  final String userName;
  final bool canPop;

  const _TopNavBarTitle({required this.userName, required this.canPop});

  @override
  Widget build(BuildContext context) {
    return Transform.translate(
      offset: const Offset(0, -2),
      child: Row(
        children: [
          if (canPop)
            _TopNavBackButton(
              onTap: () => Navigator.of(context).pop(),
              child: const SizedBox.square(
                dimension: LotusArrowBubble.hitExtent,
                child: Center(child: LotusArrowBubble(back: true)),
              ),
            ),
          Flexible(
            child: Text(
              userName,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppTypography.navTitle.copyWith(color: AppColors.textInverse),
            ).withEntrance(),
          ),
        ],
      ),
    );
  }
}

class HomeAccountBar extends StatelessWidget {
  const HomeAccountBar({
    super.key,
    this.backgroundColor = AppColorsDark.homeCanvas,
    this.accountLabelStyle,
    this.showAccountActions = true,
  });

  final Color backgroundColor;
  final TextStyle? accountLabelStyle;
  final bool showAccountActions;

  @override
  Widget build(BuildContext context) {
    final gender = context.select<UserProvider, Gender?>(
      (provider) => provider.currentUser?.personalInfo?.gender,
    );
    return ColoredBox(
      color: backgroundColor,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Row(
          children: [
            Expanded(
              child: Align(
                alignment: Alignment.centerLeft,
                child: Tooltip(
                  message: context.l10n.navProfile,
                  excludeFromSemantics: true,
                  child: LotusButtons.text(
                    style: TextButton.styleFrom(
                      minimumSize: const Size(44, 44),
                      visualDensity: VisualDensity.standard,
                      padding: const EdgeInsets.only(right: 8),
                      foregroundColor: AppColors.textInverse,
                    ),
                    onPressed: () => HomeProfileRoute.push(context),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        ProfileAvatar(size: 36, gender: gender),
                        const SizedBox(width: 8),
                        Flexible(
                          child: Text(
                            context.l10n.navProfile,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: AppTypography.text1SemiBold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            if (showAccountActions) ...[
              Transform.translate(
                offset: const Offset(0, 2),
                child: _MoonTopNavBarActions(labelStyle: accountLabelStyle),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _MoonTopNavBarActions extends StatelessWidget {
  const _MoonTopNavBarActions({this.labelStyle});
  final TextStyle? labelStyle;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        LotusTap(
          onTap: () => BalanceRoute.push(context),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Consumer<UserProvider>(
                builder: (context, userProvider, child) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: Text(
                      '${MonetizationProvider.maybeOf(context)?.balance ?? 0} ',
                      style:
                          labelStyle ??
                          context.textTheme.inverseUrbanistSemiBold17,
                    ),
                  );
                },
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: LotusRasterIcon(
                  'assets/icons/star_coin_icon.png',
                  height: 14,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 8),
        SizedBox(
          width: 76,
          height: 28,
          child: SubscriptionWidget(labelStyle: labelStyle),
        ),
      ],
    );
  }
}

class _HomeTopNavBarWidget extends StatelessWidget {
  final String userName;
  final TopNavBarType type;
  final bool canPop;
  final DateTime? birthDate;

  const _HomeTopNavBarWidget({
    required this.userName,
    required this.type,
    required this.canPop,
    this.birthDate,
  });

  @override
  Widget build(BuildContext context) {
    final isMoonScreen = type == TopNavBarType.moon;
    final isProfileScreen = type == TopNavBarType.profile;
    final isTransparent = type == TopNavBarType.transparent;

    return SizedBox(
      height: 201,
      width: double.infinity,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // Background image
          if (!isProfileScreen && !isTransparent)
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              height: 144,
              child: ClipRRect(
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(16),
                  bottomRight: Radius.circular(16),
                ),
                child: Image.asset(
                  'assets/background/app_bar_main.webp',
                  fit: BoxFit.cover,
                ),
              ),
            ),

          // Status Bar
          Positioned(
            top: 60,
            left: 0,
            right: 0,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Left title with optional back button
                  Expanded(child: _TopNavBarTitle(userName: userName, canPop: canPop)),
                  // Right content (coins and PRO)
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // Coins
                      LotusTap(
                        onTap: () => BalanceRoute.push(context),
                        child: Row(
                          children: [
                            Consumer<UserProvider>(
                              builder: (context, userProvider, child) {
                                return Padding(
                                  padding: const EdgeInsets.only(bottom: 4),
                                  child: Text(
                                    '${MonetizationProvider.maybeOf(context)?.balance ?? 0} ',
                                    style: context
                                        .textTheme
                                        .inverseUrbanistSemiBold17,
                                  ).withEntrance(),
                                );
                              },
                            ),
                            Padding(
                              padding: const EdgeInsets.only(bottom: 4),
                              child: LotusRasterIcon(
                                'assets/icons/star_coin_icon.png',
                                height: 16,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      // PRO badge
                      SubscriptionWidget(),
                    ],
                  ),
                ],
              ),
            ),
          ),
          // Avatar - позиционируем по центру и частично выходящую за пределы фона
          if (!isProfileScreen && !isTransparent)
            Positioned(
              top: 87,
              left: 0,
              right: 0,
              child: Center(
                child: Consumer<UserProvider>(
                  builder: (context, userProvider, _) {
                    return Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: context.colors.surface,
                          width: 8,
                        ),
                      ),
                      child: isMoonScreen
                          ? const AsteriaEntrance(child: ClipOval(
                              child: SizedBox(height: 100, width: 100),
                            ))
                          : ClipOval(
                              child: Image.asset(
                                type.getImagePath(
                                  birthDate: birthDate,
                                  gender: userProvider
                                      .currentUser
                                      ?.personalInfo
                                      ?.gender,
                                ),
                                height: 100,
                                width: 100,
                              ),
                            ).withEntrance(),
                    );
                  },
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _ProfileTopNavBarWidget extends StatelessWidget {
  final String userName;
  final TopNavBarType type;
  final DateTime? birthDate;

  const _ProfileTopNavBarWidget({
    required this.userName,
    required this.type,
    this.birthDate,
  });

  static const double _buttonBottomPadding = 32.0;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: _profileHeight,
      width: double.infinity,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // Составной фон из трех частей
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: _profileHeight,
            child: ClipRRect(
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(16),
                bottomRight: Radius.circular(16),
              ),
              child: Stack(
                children: [
                  // Верхняя часть
                  Positioned(
                    top: 0,
                    left: 0,
                    right: 0,
                    child: ClipRRect(
                      borderRadius: const BorderRadius.only(
                        bottomLeft: Radius.circular(16),
                        bottomRight: Radius.circular(16),
                      ),
                      child: SizedBox(
                        height: 144,
                        child: Image.asset(
                          'assets/background/app_bar_profile_top.webp',
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  ),
                  // Левая часть
                  Positioned(
                    top: 147,
                    left: 0,
                    bottom: 0,
                    child: LotusTap(
                      onTap: () {
                        SettingsRoute.push(context);
                      },
                      child: Stack(
                        children: [
                          ClipRRect(
                            borderRadius: const BorderRadius.only(
                              topLeft: Radius.circular(16),
                              bottomRight: Radius.circular(16),
                            ),
                            child: SizedBox(
                              width: MediaQuery.of(context).size.width / 2 - 2,
                              height: double.infinity,
                              child: Image.asset(
                                'assets/background/app_bar_profile_left_right.webp',
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                          // Кнопка уведомлений в левом нижнем углу
                          Positioned(
                            bottom: _buttonBottomPadding,
                            left: 24,
                            child: _AppBarButton(
                              icon: 'notifications_icon',
                              label: context.l10n.settingsNotifications,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  // Правая часть
                  Positioned(
                    top: 147,
                    right: 0,
                    bottom: 0,
                    child: LotusTap(
                      onTap: () {
                        PaymentsSettingsRoute.push(context);
                      },
                      child: Stack(
                        children: [
                          ClipRRect(
                            borderRadius: const BorderRadius.only(
                              topRight: Radius.circular(16),
                              bottomLeft: Radius.circular(16),
                            ),
                            child: SizedBox(
                              width: MediaQuery.of(context).size.width / 2 - 2,
                              height: double.infinity,
                              child: Image.asset(
                                'assets/background/app_bar_profile_left_right.webp',
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                          // Кнопка оплаты в правом нижнем углу
                          Positioned(
                            bottom: _buttonBottomPadding,
                            left: 24,
                            child: _AppBarButton(
                              icon: 'wallet_icon',
                              label: context.l10n.paymentTitle,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Status Bar
          Positioned(
            top: 60,
            left: 0,
            right: 0,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Left title
                  Transform.translate(
                    offset: const Offset(0, -2),
                    child: Text(
                      userName,
                      style: AppTypography.navTitle.copyWith(color: AppColors.textInverse),
                    ).withEntrance(),
                  ),
                  // Right content (coins and PRO)
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // Coins
                      LotusTap(
                        onTap: () => BalanceRoute.push(context),
                        child: Row(
                          children: [
                            Consumer<UserProvider>(
                              builder: (context, userProvider, child) {
                                return Text(
                                  '${MonetizationProvider.maybeOf(context)?.balance ?? 0} ',
                                  style: context
                                      .textTheme
                                      .inverseUrbanistSemiBold17,
                                ).withEntrance();
                              },
                            ),
                            Padding(
                              padding: const EdgeInsets.only(bottom: 2),
                              child: LotusRasterIcon(
                                'assets/icons/star_coin_icon.png',
                                height: 16,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      // PRO badge
                      SubscriptionWidget(),
                    ],
                  ),
                ],
              ),
            ),
          ),
          // Avatar - позиционируем по центру
          Positioned(
            top: 94,
            left: 0,
            right: 0,
            child: Center(
              child: Consumer<UserProvider>(
                builder: (context, userProvider, _) {
                  return Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: context.colors.surface,
                        width: 2,
                      ),
                    ),
                    child: ClipOval(
                      child: Image.asset(
                        type.getImagePath(
                          birthDate: birthDate,
                          gender:
                              userProvider.currentUser?.personalInfo?.gender,
                        ),
                        height: 100,
                        width: 100,
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TransparentTopNavBar extends StatelessWidget {
  final String userName;
  final TopNavBarType type;
  final bool canPop;
  final DateTime? birthDate;

  const _TransparentTopNavBar({
    required this.userName,
    required this.type,
    required this.canPop,
    this.birthDate,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: _collapsedHeight,
      width: double.infinity,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // Status Bar - без фона
          Positioned(
            top: 60,
            left: 0,
            right: 0,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Left title with optional back button
                  Expanded(child: _TopNavBarTitle(userName: userName, canPop: canPop)),
                  // Right content (coins and PRO)
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // Coins
                      LotusTap(
                        onTap: () => BalanceRoute.push(context),
                        child: Row(
                          children: [
                            Consumer<UserProvider>(
                              builder: (context, userProvider, child) {
                                return Padding(
                                  padding: const EdgeInsets.only(bottom: 4),
                                  child: Text(
                                    '${MonetizationProvider.maybeOf(context)?.balance ?? 0} ',
                                    style: context
                                        .textTheme
                                        .inverseUrbanistSemiBold17,
                                  ).withEntrance(),
                                );
                              },
                            ),
                            Padding(
                              padding: const EdgeInsets.only(bottom: 4),
                              child: LotusRasterIcon(
                                'assets/icons/star_coin_icon.png',
                                height: 16,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      // PRO badge
                      SubscriptionWidget(),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TopNavBackButton extends StatelessWidget {
  const _TopNavBackButton({required this.onTap, required this.child});

  final VoidCallback onTap;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: MaterialLocalizations.of(context).backButtonTooltip,
      child: LotusTap(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: child,
      ),
    );
  }
}

class _AppBarButton extends StatelessWidget {
  final String icon;
  final String label;

  const _AppBarButton({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(6),
          decoration: CardLensDecoration.button(
            color: AppColors.primary,
            borderRadius: BorderRadius.circular(8),
          ),
          child: ClayAssetIcon('assets/icons/$icon.svg', width: 24, height: 24),
        ),
        const SizedBox(height: 4),
        Text(label, style: AppTypography.text1SemiBold.copyWith(color: AppColors.textInverse)),
      ],
    );
  }
}

// Константы высот
const double _defaultHeight = 201.0;
const double _profileHeight = 302.0;
const double _collapsedHeight = 105.0;
