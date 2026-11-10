import 'package:asteria_app/core/analytics/analytics_events.dart';
import 'package:asteria_app/core/analytics/analytics_facade.dart';
import 'package:asteria_app/core/analytics/dictionaries/offer_type.dart';
import 'package:asteria_app/core/analytics/event_params.dart';
import 'package:asteria_app/core/analytics/feature_names.dart';
import 'package:asteria_app/core/analytics/product_analytics_service.dart';
import 'package:asteria_app/core/di/di.dart';
import 'package:asteria_app/core/ui_kit/ui_kit.dart';
import 'package:asteria_app/features/compatibility/presentation/widgets/compatibility_layout.dart';
import 'package:asteria_app/features/monetization/presentation/monetization_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class CreateCompatibilitySubscriptionScreen extends StatefulWidget {
  const CreateCompatibilitySubscriptionScreen({Key? key}) : super(key: key);

  @override
  State<CreateCompatibilitySubscriptionScreen> createState() =>
      _CreateCompatibilitySubscriptionScreenState();
}

class _CreateCompatibilitySubscriptionScreenState
    extends State<CreateCompatibilitySubscriptionScreen> {
  @override
  void initState() {
    super.initState();
    di.get<AnalyticsFacade>().trackEvent(
      AnalyticsEvents.compatibilityPaywallView,
      params: {
        EventParams.featureName: FeatureName.compatibility.eventValue,
        EventParams.paywallVariant: 'requests_pack',
      },
    );
    di.get<ProductAnalyticsService>().trackCompatibilityPaywallView(
      originSurface: 'compatibility_requests_left',
      offerType: OfferType.requestPack,
      paywallVariant: 'requests_pack',
    );
  }

  @override
  Widget build(BuildContext context) {
    return CompatibilityLayout(
      showRequestsBadge: false,
      padding: const EdgeInsets.fromLTRB(14, 64, 14, 0),
      child: _CompatibilityPackagesContent(
        packages: const [
          PurchasePackage(price: 100, requestQuantity: 10),
          PurchasePackage(price: 200, requestQuantity: 20),
          PurchasePackage(price: 300, requestQuantity: 30),
        ],
        onPurchase: (requestQuantity, idempotencyKey) async {
          final facade = di.get<AnalyticsFacade>();
          final monetizationProvider = di.get<MonetizationProvider>();

          facade.trackEvent(
            AnalyticsEvents.purchaseStart,
            params: {
              EventParams.featureName: FeatureName.compatibility.eventValue,
              EventParams.packageId: 'compatibility_$requestQuantity',
            },
          );
          try {
            await monetizationProvider.purchaseRequestPack(
              feature: 'compatibility',
              quantity: requestQuantity,
              idempotencyKey: idempotencyKey,
            );
            facade.trackEvent(
              AnalyticsEvents.compatibilityPurchaseSuccess,
              params: {
                EventParams.featureName: FeatureName.compatibility.eventValue,
                EventParams.packageId: 'compatibility_$requestQuantity',
                EventParams.purchaseType: 'requests_pack',
                EventParams.currency: 'coins',
              },
            );
          } catch (e) {
            facade.trackPurchaseFailed(
              feature: FeatureName.compatibility,
              productId: 'compatibility_$requestQuantity',
              failureStage: 'purchase_request_pack',
              failureReason: e.toString(),
            );
            rethrow;
          }
        },
      ),
    );
  }
}

class _CompatibilityPackagesContent extends StatefulWidget {
  final List<PurchasePackage> packages;
  final Future<void> Function(int requestQuantity, String? idempotencyKey)
  onPurchase;

  const _CompatibilityPackagesContent({
    required this.packages,
    required this.onPurchase,
  });

  @override
  State<_CompatibilityPackagesContent> createState() =>
      _CompatibilityPackagesContentState();
}

class _CompatibilityPackagesContentState
    extends State<_CompatibilityPackagesContent> {
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
      children: [
        Text(
          context.l10n.choosePackageTitle,
          style: context.textTheme.inversePlayfairSemiBold32,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 24),
        ...widget.packages.asMap().entries.map((entry) {
          final index = entry.key;
          final package = entry.value;
          return Padding(
            padding: EdgeInsets.only(
              bottom: index < widget.packages.length - 1 ? 16 : 0,
            ),
            child: _PackageCard(
              package: package,
              isSelected: _selectedPackageIndex == index,
              onTap: () {
                setState(() {
                  _selectedPackageIndex = index;
                });
              },
            ),
          );
        }),
        const SizedBox(height: 24),
        CompatibilityGradientButton(
          text: context.l10n.commonBuy,
          onPressed: _selectedPackageIndex == null
              ? null
              : () => _handlePurchase(context),
        ),
      ],
    );
  }

  Future<void> _handlePurchase(BuildContext context) async {
    final selectedIndex = _selectedPackageIndex;
    if (selectedIndex == null) return;

    final selectedPackage = widget.packages[selectedIndex];
    final outcome = await showFeaturePurchaseModal(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => SharedPurchaseModal(
        featureKey: 'compatibility',
        purchaseTitle: context.l10n.purchaseRequestsTitle(
          selectedPackage.requestQuantity,
        ),
        price: selectedPackage.price,
        originSurface: 'compatibility',
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
      returnToRequestFeature(context, 'compatibility');
    }
  }
}

class _PackageCard extends StatelessWidget {
  final PurchasePackage package;
  final bool isSelected;
  final VoidCallback onTap;

  const _PackageCard({
    required this.package,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: CompatibilityGlassCard(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
        border: Border.all(
          color: isSelected
              ? const Color(0xFF7C4DFF)
              : AppColors.white.withValues(alpha: 0.26),
          width: isSelected ? 1.5 : 1,
        ),
        child: Row(
          children: [
            Text(
              '${package.price}',
              style: context.textTheme.inverseUrbanistSemiBold24,
            ),
            const SizedBox(width: 4),
            Image.asset('assets/icons/star_coin_icon.png', height: 18),
            const SizedBox(width: 10),
            Text(
              '→',
              style: context.textTheme.urbanistRegular20.copyWith(
                color: const Color(0xFF7C4DFF),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                context.l10n.requestPackageCount(package.requestQuantity),
                style: context.textTheme.inverseUrbanistSemiBold24,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            _SelectionMark(isSelected: isSelected),
          ],
        ),
      ),
    );
  }
}

class _SelectionMark extends StatelessWidget {
  final bool isSelected;

  const _SelectionMark({required this.isSelected});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 42,
      height: 42,
      decoration: BoxDecoration(
        color: isSelected
            ? const Color(0xFFFFB45E)
            : const Color(0xFF49366E).withValues(alpha: 0.54),
        shape: BoxShape.circle,
      ),
      child: isSelected
          ? Center(
              child: SvgPicture.asset(
                'assets/icons/checbox_round_selected.svg',
                width: 24,
                height: 24,
                colorFilter: const ColorFilter.mode(
                  AppColors.textPrimary,
                  BlendMode.srcIn,
                ),
              ),
            )
          : null,
    );
  }
}
