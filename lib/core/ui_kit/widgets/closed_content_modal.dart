import 'package:asteria_app/core/ui_kit/widgets/modal_glass_surface.dart';
import 'package:asteria_app/core/ui_kit/widgets/card_lens_decoration.dart';
import 'package:asteria_app/core/ui_kit/widgets/asteria_entrance.dart';
import 'package:asteria_app/core/ui_kit/widgets/lotus_feedback.dart';
import 'package:asteria_app/features/monetization/presentation/contextual_purchase_page.dart';
import 'package:asteria_app/features/monetization/presentation/monetization_provider.dart';
import 'package:asteria_app/core/ui_kit/ui_kit.dart';
import 'package:flutter/material.dart';

const Color _closedContentModalSurface = ModalGlassTokens.surface;
const Color _closedContentModalGrabber = ModalGlassTokens.grabber;

class ClosedContentModal extends StatelessWidget {
  final String description;
  final String? title;
  final VoidCallback? onSubscribe;

  const ClosedContentModal({
    super.key,
    required this.description,
    this.title,
    this.onSubscribe,
  });

  static Future<void> show(
    BuildContext context, {
    required String description,
    String? title,
    VoidCallback? onSubscribe,
  }) {
    return showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => ClosedContentModal(
        description: description,
        title: title,
        onSubscribe: onSubscribe,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final maxHeight = MediaQuery.sizeOf(context).height * 0.9;

    return ModalGlassSurface(
      color: _closedContentModalSurface,
      child: SafeArea(
        top: false,
        child: ConstrainedBox(
          constraints: BoxConstraints(maxHeight: maxHeight),
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: AsteriaEntrance.sections([
                  Container(
                    margin: const EdgeInsets.only(top: 16),
                    height: 4,
                    width: 64,
                    decoration: BoxDecoration(
                      color: _closedContentModalGrabber,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    title ?? context.l10n.subscriptionOnlyTitle,
                    style: AppTypography.h2.copyWith(color: AppColors.textInverse),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    description,
                    style: AppTypography.text1.copyWith(color: AppColors.textInverse),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  _SubscriptionButton(
                    onPressed: () async {
                      if (onSubscribe != null) {
                        Navigator.pop(context);
                        onSubscribe!();
                      } else {
                        final purchased = await openContextualPurchase(
                          context,
                          subscription: true,
                          originSurface: 'locked_content',
                        );
                        if (purchased &&
                            context.mounted &&
                            (MonetizationProvider.maybeOf(
                                  context,
                                  listen: false,
                                )?.effectivePro ??
                                false)) {
                          Navigator.pop(context);
                        }
                      }
                    },
                  ),
                  const SizedBox(height: 24),
                ]),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// The subscription CTA shared by locked content and its explanation sheet.
class SubscriptionOfferButton extends StatelessWidget {
  const SubscriptionOfferButton({
    super.key,
    required this.onPressed,
    this.label,
  });

  final VoidCallback? onPressed;
  final String? label;

  @override
  Widget build(BuildContext context) =>
      _SubscriptionButton(onPressed: onPressed, label: label);
}

class _SubscriptionButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final String? label;

  const _SubscriptionButton({required this.onPressed, this.label});

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(minHeight: 48),
      child: SizedBox(
        width: double.infinity,
        child: DecoratedBox(
          decoration: CardLensDecoration.button(
            borderRadius: BorderRadius.circular(16),
            gradient: const LinearGradient(
              colors: [Color(0xFF6E4BFF), Color(0xFF5A3FD1)],
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF6E4BFF).withValues(alpha: 0.05),
                blurRadius: 30,
              ),
            ],
          ),
          child: Material(
            color: Colors.transparent,
            child: Semantics(
              button: true,
              enabled: onPressed != null,
              child: LotusInkTap(
                borderRadius: BorderRadius.circular(16),
                onTap: onPressed,
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  child: Text(
                    label ?? context.l10n.openSubscription,
                    style: AppTypography.text1SemiBold.copyWith(color: AppColors.textInverse),
                    textAlign: TextAlign.center,
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
