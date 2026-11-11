import 'package:asteria_app/core/ui_kit/widgets/asteria_entrance.dart';
import 'package:asteria_app/app/data/models/sonnik/sonnik_model.dart';
import 'package:asteria_app/app/providers/user_provider.dart';
import 'package:asteria_app/core/di/di.dart';
import 'package:asteria_app/core/extensions/datetime_extensions.dart';
import 'package:asteria_app/core/routing/app_route.dart';
import 'package:asteria_app/core/ui_kit/ui_kit.dart';
import 'package:asteria_app/core/ui_kit/widgets/clay_icon.dart';
import 'package:asteria_app/features/sonnik/presentation/provider/sonnik_provider.dart';
import 'package:asteria_app/features/sonnik/presentation/widgets/sonnik_layout.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class CreateSonnikHistoryScreen extends StatelessWidget {
  const CreateSonnikHistoryScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SonnikPageScaffold(
      title: context.l10n.dreamDictionaryTitle,
      child: Consumer<UserProvider>(
        builder: (context, userProvider, child) {
          final history = userProvider.currentUser?.sonnikHistory ?? [];

          return ListView(
            physics: const ClampingScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(16, 24, 16, 40),
            children: AsteriaEntrance.sections([
              Text(
                context.l10n.dreamHistoryTitle,
                style: context.textTheme.inversePlayfairSemiBold32,
              ),
              const SizedBox(height: 24),
              if (history.isEmpty)
                SonnikGlassPanel(
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 18),
                      child: Text(
                        context.l10n.dreamHistoryEmpty,
                        style: context.textTheme.inverseUrbanistRegular16,
                      ).withEntrance(),
                    ),
                  ),
                )
              else
                ...history.map((item) {
                  return Padding(
                    key: ValueKey(item.id),
                    padding: const EdgeInsets.only(bottom: 14),
                    child: _SonnikHistoryItem(
                      sonnik: item,
                      onTap: () {
                        di.get<SonnikProvider>().selectSonnik(item);
                        CreateSonnikLoadedRoute.push(context);
                      },
                    ),
                  );
                }),
            ]),
          );
        },
      ),
    );
  }
}

class _SonnikHistoryItem extends StatelessWidget {
  final SonnikModel sonnik;
  final VoidCallback onTap;

  const _SonnikHistoryItem({required this.sonnik, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return SonnikGlassPanel(
      onTap: onTap,
      padding: const EdgeInsets.fromLTRB(16, 14, 14, 14),
      borderRadius: BorderRadius.circular(20),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  sonnik.dateGenerated.toLocalizedShortDate(
                    Localizations.localeOf(context),
                  ),
                  style: context.textTheme.urbanistSemiBold16.copyWith(
                    color: SonnikPalette.gold,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  sonnik.title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: AppTypography.h4.copyWith(color: SonnikPalette.white),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          const ClayIcon(
            Icons.arrow_forward_ios_rounded,
            color: SonnikPalette.white,
            size: 18,
          ),
        ],
      ),
    );
  }
}
