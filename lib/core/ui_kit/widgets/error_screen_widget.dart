import 'package:flutter/material.dart';

import '../../extensions/build_context_extensions.dart';
import '../app_colors/app_colors.dart';
import '../app_typography.dart';
import '../card_radii.dart';
import 'asteria_entrance.dart';
import 'card_lens_decoration.dart';
import 'clay_icon.dart';
import 'custom_button.dart';

class ErrorScreenWidget extends StatelessWidget {
  final String error;
  final VoidCallback onRetry;
  final String? title;
  final String? retryLabel;

  const ErrorScreenWidget({
    super.key,
    required this.error,
    required this.onRetry,
    this.title,
    this.retryLabel,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 420),
        child: DecoratedBox(
          decoration: const CardLensDecoration(
            color: AppColorsDark.modal,
            borderRadius: BorderRadius.all(
              Radius.circular(AsteriaCardRadii.tile),
            ),
            intensity: .65,
          ),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: AsteriaEntrance.sections([
                Row(
                  children: [
                    const ClayIcon(
                      Icons.error_outline,
                      size: 24,
                      color: AppColorsDark.linkGold,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Semantics(
                        header: true,
                        child: Text(
                          title ?? context.l10n.genericSomethingWrong,
                          style: AppTypography.h3.copyWith(
                            color: AppColors.textInverse,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Text(
                  error,
                  style: AppTypography.text1.copyWith(
                    color: AppColors.textInverse,
                  ),
                ),
                const SizedBox(height: 18),
                CustomButton(
                  onPressed: onRetry,
                  text: retryLabel ?? context.l10n.commonRetry,
                ),
              ]),
            ),
          ),
        ),
      ),
    );
  }
}
