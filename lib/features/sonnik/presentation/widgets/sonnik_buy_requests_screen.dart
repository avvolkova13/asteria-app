import 'package:asteria_app/core/analytics/dictionaries/offer_type.dart';
import 'package:asteria_app/core/ui_kit/ui_kit.dart';
import 'package:asteria_app/features/sonnik/presentation/widgets/sonnik_layout.dart';
import 'package:flutter/material.dart';

class SonnikBuyRequestsScreen extends StatefulWidget {
  final String title;
  final List<PurchasePackage> packages;
  final Future<void> Function(int requestQuantity, String? idempotencyKey)
  onPurchase;
  final String originSurface;

  const SonnikBuyRequestsScreen({
    super.key,
    required this.title,
    required this.packages,
    required this.onPurchase,
    this.originSurface = 'sonnik',
  });

  @override
  State<SonnikBuyRequestsScreen> createState() =>
      _SonnikBuyRequestsScreenState();
}

class _SonnikBuyRequestsScreenState extends State<SonnikBuyRequestsScreen> {
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
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(widget.title, style: context.textTheme.inversePlayfairSemiBold32),
        const SizedBox(height: 24),
        ...widget.packages.asMap().entries.map((entry) {
          final index = entry.key;
          final package = entry.value;

          return Padding(
            padding: EdgeInsets.only(
              bottom: index < widget.packages.length - 1 ? 14 : 0,
            ),
            child: _SonnikPackageItem(
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
        SonnikGradientButton(
          text: context.l10n.commonBuy,
          onPressed: _selectedPackageIndex != null
              ? () => _handlePurchase(context)
              : null,
        ),
      ],
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
        purchaseTitle: context.l10n.purchaseRequestsTitle(
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
      returnToRequestFeature(context, widget.originSurface);
    }
  }
}

class _SonnikPackageItem extends StatelessWidget {
  final int price;
  final int requestQuantity;
  final bool isSelected;
  final VoidCallback onTap;

  const _SonnikPackageItem({
    required this.price,
    required this.requestQuantity,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return SonnikGlassPanel(
      onTap: onTap,
      padding: const EdgeInsets.fromLTRB(16, 14, 14, 14),
      borderRadius: BorderRadius.circular(20),
      child: Row(
        children: [
          Expanded(
            child: Row(
              children: [
                Text(
                  '$price',
                  style: context.textTheme.inverseUrbanistSemiBold24,
                ),
                const SizedBox(width: 5),
                Image.asset('assets/icons/star_coin_icon.png', height: 20),
                const SizedBox(width: 12),
                Icon(
                  Icons.arrow_forward_rounded,
                  color: SonnikPalette.white.withValues(alpha: 0.76),
                  size: 20,
                ),
                const SizedBox(width: 12),
                Flexible(
                  child: Text(
                    context.l10n.requestPackageCount(requestQuantity),
                    overflow: TextOverflow.ellipsis,
                    style: context.textTheme.inverseUrbanistSemiBold24,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          AnimatedContainer(
            duration: const Duration(milliseconds: 160),
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isSelected ? SonnikPalette.white : Colors.transparent,
              border: Border.all(
                color: isSelected
                    ? SonnikPalette.white
                    : SonnikPalette.white.withValues(alpha: 0.45),
                width: 2,
              ),
            ),
            child: isSelected
                ? const Icon(
                    Icons.check_rounded,
                    color: SonnikPalette.purple,
                    size: 20,
                  )
                : null,
          ),
        ],
      ),
    );
  }
}
