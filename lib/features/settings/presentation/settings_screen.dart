import 'package:asteria_app/core/config/app_feature_visibility.dart';
import 'package:asteria_app/core/ui_kit/widgets/asteria_entrance.dart';
import 'package:asteria_app/app/providers/user_provider.dart';
import 'package:asteria_app/core/di/di.dart';
import 'package:asteria_app/core/location/widgets/current_location_controls.dart';
import 'package:asteria_app/core/ui_kit/ui_kit.dart';
import 'package:asteria_app/features/profile_flow/profile_flow_ui.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

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
              crossAxisAlignment: CrossAxisAlignment.start,
              children: AsteriaEntrance.sections([
                ProfileFlowHeader(
                  title: context.l10n.settingsNotifications,
                  canPop: true,
                ),
                const SizedBox(height: 32),
                const _CurrentLocationSettingsCard(),
                const SizedBox(height: 16),
                if (AppFeatureVisibility.horoscopes) ...[
                  _SettingsListTile(title: context.l10n.settingsDailyHoroscope),
                  const SizedBox(height: 16),
                ],
                _SettingsListTile(title: context.l10n.settingsLunarCalendar),
                const SizedBox(height: 16),
                _SettingsListTile(
                  title: context.l10n.settingsDailyAffirmations,
                ),
                const SizedBox(height: 16),
                _SettingsListTile(
                  title: context.l10n.settingsPushNotifications,
                ),
              ]),
            ),
          ),
        ),
      ),
    );
  }
}

class _CurrentLocationSettingsCard extends StatelessWidget {
  const _CurrentLocationSettingsCard();

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<UserProvider>.value(
      value: di.get<UserProvider>(),
      child: Consumer<UserProvider>(
        builder: (context, userProvider, _) {
          final location = userProvider.currentUser?.currentLocation;
          return ProfileGlassCard(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 18),
            borderRadius: 16,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  context.l10n.settingsGeolocation,
                  style: context.textTheme.playfairSemiBold24.copyWith(
                    color: AppColors.textInverse,
                    fontSize:
                        MediaQuery.sizeOf(context).width < 360 &&
                            MediaQuery.textScalerOf(context).scale(24) > 36
                        ? 20
                        : null,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  context.l10n.settingsCurrentLocationDescription,
                  style: context.textTheme.inverseUrbanistRegular14.copyWith(
                    color: AppColorsDark.textSecondary,
                    height: 1.25,
                  ),
                ),
                const SizedBox(height: 14),
                if (location == null) ...[
                  Text(
                    context.l10n.locationNotConfigured,
                    style: context.textTheme.inverseUrbanistRegular17.copyWith(
                      color: const Color(0xFFE6994D),
                    ),
                  ),
                  const SizedBox(height: 14),
                ],
                const CurrentLocationControls(),
              ],
            ),
          );
        },
      ),
    );
  }
}

/// Daily notification delivery has no service contract yet. The separate
/// calendar-plan reminder flow owns its own per-plan settings and permission.
class _SettingsListTile extends StatelessWidget {
  const _SettingsListTile({required this.title});
  final String title;

  @override
  Widget build(BuildContext context) {
    final unavailable = context.l10n.commonUnavailable;
    return Semantics(
      label: '$title. $unavailable',
      enabled: false,
      toggled: false,
      excludeSemantics: true,
      child: ProfileGlassCard(
        padding: const EdgeInsets.fromLTRB(16, 12, 14, 12),
        borderRadius: 16,
        child: LayoutBuilder(
          builder: (context, constraints) {
            final stackControl =
                constraints.maxWidth <
                MediaQuery.textScalerOf(context).scale(17) * 12;
            final label = Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: context.textTheme.inverseUrbanistRegular17),
                const SizedBox(height: 4),
                Text(
                  unavailable,
                  style: context.textTheme.inverseUrbanistRegular14.copyWith(
                    color: AppColorsDark.textSecondary,
                  ),
                ),
              ],
            );
            final control = ConstrainedBox(
              constraints: const BoxConstraints(minHeight: 44),
              child: CupertinoSwitch(
                value: false,
                onChanged: null,
                inactiveTrackColor: AppColorsDark.secondary,
                inactiveThumbColor: AppColors.cardTinted,
                trackOutlineColor: const WidgetStatePropertyAll(
                  AppColorsDark.textTertiary,
                ),
                trackOutlineWidth: const WidgetStatePropertyAll(1),
              ),
            );
            return stackControl
                ? Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      label,
                      const SizedBox(height: 8),
                      Align(alignment: Alignment.centerRight, child: control),
                    ],
                  )
                : Row(
                    children: [
                      Expanded(child: label),
                      const SizedBox(width: 12),
                      control,
                    ],
                  );
          },
        ),
      ),
    );
  }
}
