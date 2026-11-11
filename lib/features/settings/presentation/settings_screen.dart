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
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 48),
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
                _SettingsListTile(
                  title: context.l10n.settingsDailyHoroscope,
                  value: true,
                ),
                const SizedBox(height: 16),
                _SettingsListTile(
                  title: context.l10n.settingsLunarCalendar,
                  value: false,
                ),
                const SizedBox(height: 16),
                _SettingsListTile(
                  title: context.l10n.settingsDailyAffirmations,
                  value: true,
                ),
                const SizedBox(height: 16),
                _SettingsListTile(
                  title: context.l10n.settingsPushNotifications,
                  value: true,
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
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  context.l10n.settingsCurrentLocationDescription,
                  style: context.textTheme.inverseUrbanistRegular14.copyWith(
                    color: AppColors.textInverse.withValues(alpha: 0.72),
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

class _SettingsListTile extends StatefulWidget {
  const _SettingsListTile({required this.title, required this.value});

  final String title;
  final bool value;

  @override
  State<_SettingsListTile> createState() => _SettingsListTileState();
}

class _SettingsListTileState extends State<_SettingsListTile> {
  late bool _isEnabled;

  @override
  void initState() {
    super.initState();
    _isEnabled = widget.value;
  }

  @override
  Widget build(BuildContext context) {
    return ProfileGlassCard(
      padding: const EdgeInsets.fromLTRB(16, 9, 14, 9),
      borderRadius: 16,
      child: Row(
        children: [
          Expanded(
            child: Text(
              widget.title,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: context.textTheme.inverseUrbanistRegular17,
            ),
          ),
          Transform.scale(
            scale: 0.92,
            child: CupertinoSwitch(
              value: _isEnabled,
              onChanged: (bool value) {
                setState(() {
                  _isEnabled = value;
                });
              },
              activeTrackColor: ProfileFlowColors.accent,
              inactiveTrackColor: const Color(0xFF21194B),
              thumbColor: _isEnabled
                  ? const Color(0xFF160D25)
                  : const Color(0xFF443B9B),
            ),
          ),
        ],
      ),
    );
  }
}
