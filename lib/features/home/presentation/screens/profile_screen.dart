import 'package:asteria_app/core/ui_kit/widgets/modal_glass_surface.dart';
import 'package:asteria_app/core/ui_kit/widgets/asteria_entrance.dart';
import 'package:asteria_app/core/ui_kit/widgets/lotus_feedback.dart';
import 'package:asteria_app/app/data/models/user/user_model.dart';
import 'package:asteria_app/app/data/repositories/user/user_repository.dart';
import 'package:asteria_app/app/providers/user_provider.dart';
import 'package:asteria_app/core/analytics/product_analytics_service.dart';
import 'package:asteria_app/core/di/di.dart';
import 'package:asteria_app/core/extensions/datetime_extensions.dart';
import 'package:asteria_app/core/routing/app_route.dart';
import 'package:asteria_app/core/services/global_loader_service.dart';
import 'package:asteria_app/core/services/auth/auth_session_service.dart';
import 'package:asteria_app/core/ui_kit/ui_kit.dart';
import 'package:asteria_app/features/monetization/presentation/monetization_provider.dart';
import 'package:asteria_app/features/home/presentation/widgets/subscription_status_widget.dart';
import 'package:asteria_app/features/home/presentation/widgets/profile_avatar.dart';
import 'package:asteria_app/features/profile_flow/profile_flow_ui.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key, this.canPop = false});

  final bool canPop;

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  void initState() {
    super.initState();
    di.get<ProductAnalyticsService>().trackProfileView();
  }

  void _trackMenuClick(String menuItem) {
    di.get<ProductAnalyticsService>().trackProfileMenuClick(menuItem: menuItem);
  }

  void _onSubscriptionTap(BuildContext context) {
    _trackMenuClick('subscription');
    SubscriptionRoute.push(context);
  }

  void _onSettingsTap(BuildContext context) {
    _trackMenuClick('settings');
    SettingsRoute.push(context);
  }

  void _onAchievementsTap(BuildContext context) {
    _trackMenuClick('achievements');
    AchievementsRoute.push(context);
  }

  void _onAboutUsTap(BuildContext context) {
    _trackMenuClick('about_us');
    AboutUsRoute.push(context);
  }

  void _onShopTap(BuildContext context) {
    _trackMenuClick('shop');
    ShopRoute.push(context);
  }

  Future<void> _onSiteTap(BuildContext context) async {
    _trackMenuClick('site');
    final uri = Uri.parse('https://asteria-calendar.com');
    final launched = await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (!launched && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.l10n.profileOpenWebsiteError)),
      );
    }
  }

  Future<void> _onDeleteAccountTap(BuildContext context) async {
    _trackMenuClick('delete_account');
    final userProvider = di.get<UserProvider>();
    final user = userProvider.currentUser;
    final userId = user?.id;
    if (userId == null) {
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(context.l10n.userNotFoundError)));
      }
      return;
    }

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext dialogContext) {
        return ModalGlassAlert(
          color: AppColorsDark.modal,
          title: Text(context.l10n.profileDeleteAccount),
          content: Text(context.l10n.profileDeleteAccountQuestion),
          actions: [
            LotusButtons.text(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: Text(
                context.l10n.commonNo,
                style: context.textTheme.inverseUrbanistBold16,
              ),
            ),
            LotusButtons.text(
              onPressed: () => Navigator.of(dialogContext).pop(true),
              child: Text(
                context.l10n.commonYes,
                style: context.textTheme.inverseUrbanistBold16.copyWith(
                  color: Color.lerp(AppColors.error, AppColors.white, .45),
                ),
              ),
            ),
          ],
        );
      },
    );

    if (confirmed != true || !context.mounted) return;

    final authSession = di.get<AuthSessionService>();
    final email = user?.email ?? authSession.currentEmail;
    if (email == null || email.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(context.l10n.profileDeleteError)));
      return;
    }
    if (!authSession.hasRecentSignIn) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.l10n.profileConfirmEmailDelete)),
      );
      AuthEmailRoute.push(
        context,
        deleteAfterVerification: true,
        expectedUid: userId,
        expectedEmail: email,
      );
      return;
    }

    final loaderService = di.get<GlobalLoaderService>();
    loaderService.show();
    try {
      await di.get<UserRepository>().deleteUser(userId);
      await authSession.deleteCurrentIdentity();
      di.get<ProductAnalyticsService>().trackAccountDelete();
      if (!context.mounted) return;
      await userProvider.clearUser();
      if (!context.mounted) return;
      AuthLoginRoute.go(context);
    } on RecentLoginRequiredException {
      if (context.mounted) {
        AuthEmailRoute.push(
          context,
          deleteAfterVerification: true,
          expectedUid: userId,
          expectedEmail: email,
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(context.l10n.profileDeleteError)),
        );
      }
    } finally {
      loaderService.hide();
    }
  }

  void _onLogoutTap(BuildContext context) {
    _trackMenuClick('logout');
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return ModalGlassAlert(
          color: AppColorsDark.modal,
          title: Text(context.l10n.profileLogoutTitle),
          content: Text(context.l10n.profileLogoutQuestion),
          actions: [
            LotusButtons.text(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                context.l10n.commonCancel,
                style: context.textTheme.inverseUrbanistBold16,
              ),
            ),
            LotusButtons.text(
              onPressed: () async {
                await di.get<ProductAnalyticsService>().trackAccountLogout();
                await di.get<UserProvider>().clearUser();
                if (!context.mounted) return;
                Navigator.of(context).pop();
                AuthLoginRoute.go(context);
              },
              child: Text(
                context.l10n.logoutButton,
                style: context.textTheme.inverseUrbanistBold16.copyWith(
                  color: ProfileFlowColors.accent,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ProfileFlowColors.background,
      body: ProfileFlowBackground(
        imageAsset: 'assets/images/home/profile_background.webp',
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
            child: Consumer<UserProvider>(
              builder: (context, userProvider, child) {
                final user = userProvider.currentUser;
                final monetization = MonetizationProvider.maybeOf(context);
                final effectiveGrants = monetization?.state?.effectiveGrants;
                final activeGrant =
                    effectiveGrants == null || effectiveGrants.isEmpty
                    ? null
                    : effectiveGrants.first;
                final isArcPayOneTime = activeGrant?.provider == 'arc_pay';
                final hasProSubscription =
                    user != null && (monetization?.effectivePro ?? false);
                final name = (user?.name?.trim().isNotEmpty ?? false)
                    ? user!.name!.trim()
                    : context.l10n.defaultUserName;
                final accessDate =
                    activeGrant?.endsAt ??
                    activeGrant?.graceUntil ??
                    user?.nextPaymentDate;
                final nextPaymentDateText = accessDate?.toLocalizedShortDate(
                  Localizations.localeOf(context),
                );

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: AsteriaEntrance.sections([
                    ProfileFlowHeader(
                      title: context.l10n.profileTitle,
                      canPop: widget.canPop,
                    ),
                    const SizedBox(height: 32),
                    _ProfileHeroCard(
                      name: name,
                      userId: user?.id,
                      gender: user?.personalInfo?.gender,
                      onAvatarTap: user == null
                          ? null
                          : () => ProfileAvatarRoute.push(context),
                    ),
                    const SizedBox(height: 8),
                    LayoutBuilder(
                      builder: (context, constraints) {
                        final labelSize = MediaQuery.textScalerOf(
                          context,
                        ).scale(17);
                        final columns = constraints.maxWidth >= labelSize * 14
                            ? 2
                            : 1;
                        final gap = 8.0;
                        final tileWidth =
                            (constraints.maxWidth - gap * (columns - 1)) /
                            columns;
                        return Wrap(
                          spacing: gap,
                          runSpacing: gap,
                          children: [
                            for (final (label, icon, action) in [
                              (
                                context.l10n.settingsNotifications,
                                'profile_notifications_icon',
                                _onSettingsTap,
                              ),
                              (
                                context.l10n.profileAbout,
                                'profile_about_icon',
                                _onAboutUsTap,
                              ),
                              (
                                context.l10n.profileAchievements,
                                'profile_achievements_icon',
                                _onAchievementsTap,
                              ),
                              (
                                context.l10n.profileShop,
                                'profile_shop_icon',
                                _onShopTap,
                              ),
                              (
                                context.l10n.asteriaWebsite,
                                'profile_site_icon',
                                _onSiteTap,
                              ),
                            ])
                              SizedBox(
                                width: icon == 'profile_site_icon'
                                    ? constraints.maxWidth
                                    : tileWidth,
                                child: _ProfileMenuCard(
                                  title: label,
                                  iconAsset: 'assets/icons/$icon.svg',
                                  horizontal: columns == 1,
                                  onTap: () => action(context),
                                ),
                              ),
                          ],
                        );
                      },
                    ),
                    const SizedBox(height: 24),
                    if (hasProSubscription)
                      SubscriptionActiveStatusWidget(
                        onTap: () => _onSubscriptionTap(context),
                        nextPaymentDateText: nextPaymentDateText,
                        oneTimeAccess: isArcPayOneTime,
                      )
                    else
                      SubscriptionInactiveStatusWidget(
                        onTap: () => _onSubscriptionTap(context),
                      ),
                    const SizedBox(height: 26),
                    _LogoutButton(onTap: () => _onLogoutTap(context)),
                    const SizedBox(height: 15),
                    _DeleteAccountButton(
                      onTap: () => _onDeleteAccountTap(context),
                    ),
                  ]),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}

class _ProfileHeroCard extends StatelessWidget {
  const _ProfileHeroCard({
    required this.name,
    required this.gender,
    this.userId,
    this.onAvatarTap,
  });

  static const _cardColor = Color(0x3D72418A);

  final String name;
  final Gender? gender;
  final String? userId;
  final VoidCallback? onAvatarTap;

  @override
  Widget build(BuildContext context) {
    final avatarHeight = MediaQuery.sizeOf(context).height * 0.096;

    return ProfileGlassCard(
      color: _cardColor,
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      child: Column(
        children: [
          Semantics(
            button: true,
            label: context.l10n.avatarChange,
            child: LotusTap(
              onTap: onAvatarTap,
              child: SizedBox.square(
                dimension: avatarHeight + 12,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    ProfileAvatar(
                      size: avatarHeight,
                      gender: gender,
                      userId: userId,
                    ),
                    const Positioned(
                      right: 0,
                      bottom: 0,
                      child: ProfileIconBox(
                        icon: Icons.edit_rounded,
                        size: 28,
                        iconSize: 15,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 7),
          Text(
            name,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Color(0xFFFFFFFF),
              fontFamily: 'Lora',
              fontSize: 20,
              fontWeight: FontWeight.w500,
              height: 1.1,
              letterSpacing: 0,
            ),
          ),
        ],
      ),
    );
  }
}

class _ProfileMenuCard extends StatelessWidget {
  const _ProfileMenuCard({
    required this.title,
    required this.iconAsset,
    required this.horizontal,
    required this.onTap,
  });

  final String title;
  final String iconAsset;
  final bool horizontal;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final icon = ProfileIconBox(
      iconAsset: iconAsset,
      iconSize: 34,
      preserveAssetColors: true,
    );
    final label = Text(
      title,
      textAlign: horizontal ? TextAlign.start : TextAlign.center,
      style: context.textTheme.inverseUrbanistRegular17.copyWith(height: 1.1),
    );
    return ProfileGlassCard(
      onTap: onTap,
      color: const Color(0x3D72418A),
      padding: EdgeInsets.symmetric(
        horizontal: horizontal ? 16 : 8,
        vertical: 14,
      ),
      child: horizontal
          ? Row(
              children: [
                icon,
                const SizedBox(width: 12),
                Expanded(child: label),
              ],
            )
          : Column(children: [icon, const SizedBox(height: 6), label]),
    );
  }
}

class _LogoutButton extends StatelessWidget {
  const _LogoutButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: LotusFeedback(
        onActivate: onTap,
        keyboard: true,
        builder: (activate) => Semantics(
          button: true,
          label: context.l10n.logoutButton,
          onTap: activate,
          child: ExcludeSemantics(
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: activate,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const ProfileIconBox(
                    iconAsset: 'assets/icons/exit_icon.svg',
                    size: 34,
                    iconSize: 22,
                  ),
                  const SizedBox(width: 10),
                  Text(
                    context.l10n.logoutButton,
                    style: context.textTheme.inverseUrbanistRegular17,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _DeleteAccountButton extends StatelessWidget {
  const _DeleteAccountButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: LotusFeedback(
        onActivate: onTap,
        keyboard: true,
        builder: (activate) => Semantics(
          button: true,
          label: context.l10n.profileDeleteAccount,
          onTap: activate,
          child: ExcludeSemantics(
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: activate,
              child: ConstrainedBox(
                constraints: const BoxConstraints(minHeight: 44),
                child: Align(
                  widthFactor: 1,
                  heightFactor: 1,
                  child: Text(
                    context.l10n.profileDeleteAccount,
                    style: context.textTheme.inverseUrbanistRegular14.copyWith(
                      color: AppColorsDark.textSecondary,
                      decoration: TextDecoration.underline,
                      decorationColor: AppColorsDark.textSecondary,
                      decorationThickness: 0.8,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
