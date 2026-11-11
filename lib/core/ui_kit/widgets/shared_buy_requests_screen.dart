import 'package:asteria_app/core/ui_kit/widgets/asteria_entrance.dart';
import 'package:asteria_app/core/ui_kit/widgets/card_lens_decoration.dart';
import 'package:asteria_app/core/ui_kit/widgets/lotus_feedback.dart';
import 'package:asteria_app/core/ui_kit/widgets/lotus_raster_icon.dart';
import 'package:asteria_app/core/analytics/dictionaries/offer_type.dart';
import 'package:asteria_app/core/ui_kit/ui_kit.dart';
import 'package:asteria_app/core/ui_kit/widgets/clay_icon.dart';
import 'package:flutter/material.dart';

class PurchasePackage {
  final int price;
  final int requestQuantity;

  const PurchasePackage({required this.price, required this.requestQuantity});
}

class SharedBuyRequestsScreen extends StatefulWidget {
  final String title;
  final List<PurchasePackage> packages;
  final Future<void> Function(int requestQuantity, String? idempotencyKey)
  onPurchase;
  final VoidCallback? onSuccess;

  /// Stable surface id for analytics (compatibility / sonnik / anakra / ...).
  final String originSurface;

  const SharedBuyRequestsScreen({
    super.key,
    required this.title,
    required this.packages,
    required this.onPurchase,
    this.onSuccess,
    this.originSurface = 'unknown',
  });

  @override
  State<SharedBuyRequestsScreen> createState() =>
      _SharedBuyRequestsScreenState();
}

class _SharedBuyRequestsScreenState extends State<SharedBuyRequestsScreen> {
  int? _selectedPackageIndex;

  @override
  void initState() {
    super.initState();
    if (widget.packages.isNotEmpty) {
      _selectedPackageIndex = widget.packages.length - 1;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: AsteriaEntrance.sections([
        Text(
          widget.title,
          textAlign: TextAlign.center,
          style: AppTypography.h1.copyWith(color: AppColors.textInverse),
        ),
        const SizedBox(height: 24),
        ...widget.packages.asMap().entries.map((entry) {
          final index = entry.key;
          final package = entry.value;
          return Padding(
            padding: EdgeInsets.only(
              bottom: index < widget.packages.length - 1 ? 16 : 0,
            ),
            child: _PackageItem(
              price: package.price,
              requestQuantity: package.requestQuantity,
              isSelected: _selectedPackageIndex == index,
              onTap: () {
                setState(() {
                  _selectedPackageIndex = index;
                });
              },
            ),
          );
        }),
        const SizedBox(height: 26),
        _GradientBuyButton(
          text: context.l10n.commonBuy,
          onPressed: _selectedPackageIndex != null
              ? () => _handlePurchase(context)
              : null,
        ),
      ]),
    );
  }

  Future<void> _handlePurchase(BuildContext context) async {
    if (_selectedPackageIndex == null) return;

    final selectedPackage = widget.packages[_selectedPackageIndex!];

    final outcome = await showFeaturePurchaseModal(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => SharedPurchaseModal(
        featureKey: widget.originSurface,
        purchaseTitle: context.l10n.requestPackageCount(
          selectedPackage.requestQuantity,
        ),
        price: selectedPackage.price,
        originSurface: widget.originSurface,
        offerType: OfferType.requestPack,

        onIdempotentPurchase: (idempotencyKey) async {
          await widget.onPurchase(
            selectedPackage.requestQuantity,
            idempotencyKey,
          );
        },
      ),
    );
    if (context.mounted && outcome != null) {
      if (widget.onSuccess != null) {
        widget.onSuccess!();
      } else {
        returnToRequestFeature(context, widget.originSurface);
      }
    }
  }
}

class _PackageItem extends StatelessWidget {
  final int price;
  final int requestQuantity;
  final bool isSelected;
  final VoidCallback onTap;

  const _PackageItem({
    required this.price,
    required this.requestQuantity,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      selected: isSelected,
      label: context.l10n.requestPackageForCoins(requestQuantity, price),
      child: ExcludeSemantics(
        child: LotusTap(
          onTap: onTap,
          child: Container(
            height: 61,
            padding: const EdgeInsets.fromLTRB(16, 10, 14, 10),
            decoration: CardLensDecoration(
              color: const Color(0x339A7DB8),
              borderRadius: BorderRadius.circular(16),
              border: isSelected
                  ? Border.all(color: const Color(0xFF6E4BFF), width: 2)
                  : Border.all(color: AppColors.white.withValues(alpha: 0.2)),
            ),
            child: Row(
              children: [
                Text(
                  '$price',
                  style: context.textTheme.inverseUrbanistSemiBold24,
                ),
                const SizedBox(width: 5),
                LotusRasterIcon('assets/icons/star_coin_icon.png', height: 20),
                const SizedBox(width: 12),
                LotusRasterIcon(
                  'assets/icons/right_long_arrow.png',
                  height: 18,
                  color: AppColors.white.withValues(alpha: 0.74),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    context.l10n.requestPackageCount(requestQuantity),
                    style: context.textTheme.inverseUrbanistSemiBold24,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 12),
                ClayAssetIcon(
                  isSelected
                      ? 'assets/icons/radio_button_selected.svg'
                      : 'assets/icons/radio_button_unselected.svg',
                  width: 29,
                  height: 29,
                  tint: isSelected
                      ? null
                      : AppColors.white.withValues(alpha: 0.45),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _GradientBuyButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;

  const _GradientBuyButton({required this.text, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    final enabled = onPressed != null;

    return Semantics(
      button: true,
      enabled: enabled,
      label: text,
      child: LotusTap(
        onTap: enabled ? onPressed : null,
        child: AnimatedOpacity(
          duration: const Duration(milliseconds: 150),
          opacity: enabled ? 1 : 0.64,
          child: Container(
            height: 50,
            alignment: Alignment.center,
            decoration: CardLensDecoration.button(
              enabled: enabled,
              borderRadius: BorderRadius.circular(16),
              gradient: enabled
                  ? const LinearGradient(
                      colors: [Color(0xFF6E4BFF), Color(0xFF5436D9)],
                    )
                  : null,
              color: enabled ? null : const Color(0xFF5436D9),
            ),
            child: Text(
              text,
              style: AppTypography.text1SemiBold.copyWith(
                color: AppColors.textInverse,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ),
      ),
    );
  }
}
