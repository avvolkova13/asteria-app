import 'package:asteria_app/core/ui_kit/ui_kit.dart';
import 'package:asteria_app/core/ui_kit/widgets/asteria_entrance.dart';
import 'package:asteria_app/core/ui_kit/widgets/top_nav_bar.dart';
import 'package:asteria_app/features/profile_flow/profile_flow_ui.dart';
import 'package:flutter/material.dart';

class PaymentsSettingsScreen extends StatelessWidget {
  const PaymentsSettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ProfileFlowColors.background,
      body: ProfileFlowBackground(
        child: SafeArea(
          child: Column(
            children: [
              TopNavBar(
                canPop: true,
                userName: context.l10n.paymentTitle,
                type: TopNavBarType.payment,
              ),
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(16, 24, 16, 16),
                  children: [
                    ProfileGlassCard(
                      child: Text(
                        context.l10n.paymentSettingsDescription,
                        style: context.textTheme.inverseUrbanistRegular16,
                      ),
                    ).withEntrance(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
