import 'package:asteria_app/core/ui_kit/widgets/asteria_entrance.dart';
import 'package:asteria_app/core/ui_kit/widgets/card_lens_decoration.dart';
import 'package:asteria_app/core/ui_kit/ui_kit.dart';
import 'package:asteria_app/core/ui_kit/widgets/top_nav_bar.dart';
import 'package:flutter/material.dart';

class PaymentsSettingsScreen extends StatelessWidget {
  const PaymentsSettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      body: CustomScrollView(
        slivers: [
          SliverPersistentHeader(
            pinned: true,
            delegate: TopNavBarDelegate(
              canPop: true,
              userName: context.l10n.paymentTitle,
              type: TopNavBarType.person,
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: CardLensDecoration(
                  color: AppColors.cardBackground,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(
                  context.l10n.paymentSettingsDescription,
                  style: context.textTheme.urbanistRegular16,
                  textAlign: TextAlign.center,
                ),
              ).withEntrance(),
            ),
          ),
        ],
      ),
    );
  }
}
