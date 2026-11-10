import 'package:asteria_app/app/providers/user_provider.dart';
import 'package:asteria_app/core/di/di.dart';
import 'package:asteria_app/core/routing/app_route.dart';
import 'package:asteria_app/core/ui_kit/ui_kit.dart';
import 'package:asteria_app/features/compatibility/presentation/provider/compatibility_provider.dart';
import 'package:asteria_app/features/compatibility/presentation/screens/compatibility_history_screen.dart';
import 'package:asteria_app/features/compatibility/presentation/widgets/compatibility_layout.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class CreateCompatibilityHistoryScreen extends StatelessWidget {
  const CreateCompatibilityHistoryScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CompatibilityLayout(
      child: Consumer<UserProvider>(
        builder: (context, userProvider, child) {
          return CompatibilityHistoryScreen(
            user: userProvider.currentUser,
            onNewPairPressed: () {
              CreateCompatibilityInitialRoute.pushReplacement(context);
            },
            onItemTap: (compatibility) async {
              try {
                await di.get<CompatibilityProvider>().selectCompatibility(
                  compatibility,
                );
                if (!context.mounted) return;
                CreateCompatibilityLoadedRoute.push(context);
              } catch (_) {
                if (!context.mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(context.l10n.genericRefreshError)),
                );
              }
            },
          );
        },
      ),
    );
  }
}
