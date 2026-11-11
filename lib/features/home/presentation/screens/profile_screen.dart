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
        return AlertDialog(
          title: Text(context.l10n.profileDeleteAccount),
          content: Text(context.l10n.profileDeleteAccountQuestion),
          actions: [
            LotusButtons.text(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: Text(
                context.l10n.commonNo,
                style: context.textTheme.urbanistBold16,
              ),
            ),
            LotusButtons.text(
              onPressed: () => Navigator.of(dialogContext).pop(true),
              child: Text(
                context.l10n.commonYes,
                style: context.textTheme.urbanistBold16,
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
        return AlertDialog(
          title: Text(context.l10n.profileLogoutTitle),
          content: Text(context.l10n.profileLogoutQuestion),
          actions: [
            LotusButtons.text(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                context.l10n.commonCancel,
                style: context.textTheme.urbanistBold16,
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
                style: context.textTheme.urbanistBold16,
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
          bottom: false,
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 112),
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
                      gender: user?.personalInfo?.gender,
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: _ProfileMenuCard(
                            title: context.l10n.settingsNotifications,
                            iconAsset:
                                'assets/icons/profile_notifications_icon.svg',
                            preserveIconAssetColors: true,
                            iconSize: 34,
                            onTap: () => _onSettingsTap(context),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: _ProfileMenuCard(
                            title: context.l10n.profileAbout,
                            iconAsset: 'assets/icons/profile_about_icon.svg',
                            preserveIconAssetColors: true,
                            iconSize: 34,
                            onTap: () => _onAboutUsTap(context),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: _ProfileMenuCard(
                            title: context.l10n.profileAchievements,
                            iconAsset:
                                'assets/icons/profile_achievements_icon.svg',
                            preserveIconAssetColors: true,
                            iconSize: 34,
                            onTap: () => _onAchievementsTap(context),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: _ProfileMenuCard(
                            title: context.l10n.profileShop,
                            iconAsset: 'assets/icons/profile_shop_icon.svg',
                            preserveIconAssetColors: true,
                            iconSize: 34,
                            onTap: () => _onShopTap(context),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    _AsteriaSiteCard(onTap: () => _onSiteTap(context)),
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
  const _ProfileHeroCard({required this.name, required this.gender});

  static const _cardColor = Color(0x3D72418A);

  final String name;
  final Gender? gender;

  @override
  Widget build(BuildContext context) {
    final avatarHeight = MediaQuery.sizeOf(context).height * 0.096;

    return ProfileGlassCard(
      color: _cardColor,
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      child: Column(
        children: [
          ProfileAvatar(size: avatarHeight, gender: gender),
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
    required this.onTap,
    this.iconAsset,
    this.preserveIconAssetColors = false,
    this.iconSize = 22,
  });

  static const _cardColor = Color(0x3D72418A);

  final String title;
  final String? iconAsset;
  final bool preserveIconAssetColors;
  final double iconSize;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final textScale = MediaQuery.textScalerOf(context).scale(1).clamp(1.0, 1.3);

    return ProfileGlassCard(
      onTap: onTap,
      color: _cardColor,
      padding: const EdgeInsets.fromLTRB(10, 16, 10, 15),
      child: SizedBox(
        height: 58 + ((textScale - 1) * 74),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            ProfileIconBox(
              iconAsset: iconAsset,
              iconSize: iconSize,
              preserveAssetColors: preserveIconAssetColors,
            ),
            Text(
              title,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: context.textTheme.inverseUrbanistRegular17.copyWith(
                fontSize: 17,
                fontWeight: FontWeight.w400,
                height: 1.1,
                letterSpacing: 0,
                color: AppColors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AsteriaSiteCard extends StatelessWidget {
  const _AsteriaSiteCard({required this.onTap});

  static const _cardColor = Color(0x3D72418A);

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ProfileGlassCard(
      onTap: onTap,
      color: _cardColor,
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 14),
      child: SizedBox(
        height: 58,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const ProfileIconBox(
              iconAsset: 'assets/icons/profile_site_icon.svg',
              preserveAssetColors: true,
              iconSize: 34,
            ),
            Text(
              context.l10n.asteriaWebsite,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: context.textTheme.inverseUrbanistRegular17.copyWith(
                fontSize: 17,
                fontWeight: FontWeight.w400,
                height: 1.1,
                letterSpacing: 0,
                color: AppColors.white,
              ),
            ),
          ],
        ),
      ),
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
              child: Text(
                context.l10n.profileDeleteAccount,
                style: context.textTheme.inverseUrbanistRegular14.copyWith(
                  color: AppColors.white.withValues(alpha: 0.42),
                  decoration: TextDecoration.underline,
                  decorationColor: AppColors.white.withValues(alpha: 0.32),
                  decorationThickness: 0.8,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
