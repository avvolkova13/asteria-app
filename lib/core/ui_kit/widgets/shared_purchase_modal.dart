import 'package:asteria_app/core/ui_kit/widgets/lotus_feedback.dart';
import 'package:asteria_app/core/ui_kit/widgets/lotus_raster_icon.dart';
import 'package:asteria_app/core/analytics/dictionaries/failure_reason.dart';
import 'package:asteria_app/core/analytics/dictionaries/offer_type.dart';
import 'package:asteria_app/core/analytics/product_analytics_service.dart';
import 'package:asteria_app/core/di/di.dart';
import 'package:asteria_app/core/services/global_loader_service.dart';
import 'package:asteria_app/core/ui_kit/ui_kit.dart';
import 'package:asteria_app/core/ui_kit/widgets/clay_icon.dart';
import 'package:asteria_app/features/monetization/data/feature_execution_api.dart';
import 'package:asteria_app/features/monetization/presentation/contextual_purchase_page.dart';
import 'package:asteria_app/features/monetization/presentation/monetization_provider.dart';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

enum PurchaseModalOutcome { purchased, proActivated }

enum PurchaseModalState { initial, notEnoughBalance, success }

const double _purchaseModalSheetHeight = 300;
const double _successPurchaseModalSheetHeight = 320;
const Color _modalBackground = Color(0xFF12052A);
const Color _modalPurple = Color(0xFF6E4BFF);
const Color _modalPurpleDark = Color(0xFF5436D9);
const LinearGradient _modalButtonGradient = LinearGradient(
  colors: [_modalPurple, _modalPurpleDark],
);

class SharedPurchaseModal extends StatefulWidget {
  final String? featureKey;

  /// true forbids the server from falling back from PRO to wallet spending.
  final Future<void> Function(bool requirePro, String idempotencyKey)?
  onAccessPurchase;
  final String purchaseTitle;
  final int price;
  final Future<void> Function()? onPurchase;
  final Future<void> Function(String idempotencyKey)? onIdempotentPurchase;
  final VoidCallback? onSuccess;
  final VoidCallback? onSuccessButtonPressed;
  final GlobalLoaderType? loaderType;
  final bool showSuccessState;

  /// Stable surface id where the spend is originated. Used for analytics
  /// `origin_surface` on `ast_coin_spend_*` events.
  final String originSurface;

  /// What kind of offer is being purchased with coins. Defaults to a generic
  /// request pack — callers should pick a more specific value when relevant
  /// (e.g. `OfferType.oneOffUnlock` for horoscope unlocks).
  final OfferType offerType;

  const SharedPurchaseModal({
    super.key,
    required this.purchaseTitle,
    required this.price,
    this.featureKey,
    this.onAccessPurchase,
    this.onPurchase,
    this.onIdempotentPurchase,
    this.onSuccess,
    this.onSuccessButtonPressed,
    this.loaderType,
    this.showSuccessState = false,
    this.originSurface = 'unknown',
    this.offerType = OfferType.requestPack,
  }) : assert(
         onPurchase != null ||
             onIdempotentPurchase != null ||
             onAccessPurchase != null,
       );

  @override
  State<SharedPurchaseModal> createState() => _SharedPurchaseModalState();
}

class _SharedPurchaseModalState extends State<SharedPurchaseModal> {
  PurchaseModalState _state = PurchaseModalState.initial;
  bool _isSubmitting = false;
  String? _idempotencyKey;
  String? _originUid;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _originUid ??= MonetizationProvider.maybeOf(
      context,
      listen: false,
    )?.state?.uid;
  }

  Future<void> _openCheckout(bool subscription) async {
    if (_isSubmitting) return;
    final provider = MonetizationProvider.maybeOf(context, listen: false);
    if (provider == null ||
        _originUid == null ||
        !provider.isCurrentUser(_originUid!)) {
      return;
    }
    setState(() => _isSubmitting = true);
    try {
      await openContextualPurchase(
        context,
        subscription: subscription,
        originSurface: widget.originSurface,
        minimumStars: provider.neededBalanceFor(widget.price),
      );
      if (!mounted) return;
      if (!provider.isCurrentUser(_originUid!)) {
        Navigator.pop(context);
        return;
      }
      await provider.refreshForAccess();
      if (!mounted || ModalRoute.of(context)?.isCurrent != true) return;
      if (provider.effectivePro && widget.featureKey != null) {
        Navigator.pop(context, PurchaseModalOutcome.proActivated);
        return;
      }
      setState(() {
        _state = provider.canSpend(widget.price)
            ? PurchaseModalState.initial
            : PurchaseModalState.notEnoughBalance;
      });
    } catch (_) {
      if (mounted) showAccessError(context);
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isNotEnoughModal = _state == PurchaseModalState.notEnoughBalance;
    final isSuccessModal = _state == PurchaseModalState.success;

    return Container(
      height: _getModalHeight(isNotEnoughModal, isSuccessModal),
      decoration: BoxDecoration(
        color: isNotEnoughModal ? const Color(0xFF110628) : _modalBackground,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
      child: SafeArea(
        top: false,
        child: Builder(
          builder: (context) {
            final monetizationProvider = MonetizationProvider.maybeOf(context);
            final currentBalance = monetizationProvider?.balance ?? 0;
            final isNotEnoughBalance =
                !(monetizationProvider?.canSpend(widget.price) ?? false);

            if (_state == PurchaseModalState.initial && isNotEnoughBalance) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (!mounted) return;
                setState(() {
                  _state = PurchaseModalState.notEnoughBalance;
                });
              });
            }

            if (_state == PurchaseModalState.notEnoughBalance) {
              return NotEnoughStarsPurchaseContent(
                balance: currentBalance,
                requiredAmount: widget.price,
                description: widget.offerType == OfferType.requestPack
                    ? context.l10n.purchaseNotEnoughRequests
                    : context.l10n.purchaseNotEnoughReading,
                onCancel: () => Navigator.pop(context),
                onBuyStars: () => _openCheckout(false),
                onSubscribe:
                    widget.featureKey != null &&
                        !(monetizationProvider?.effectivePro ?? false)
                    ? () => _openCheckout(true)
                    : null,
                isBusy: _isSubmitting,
              );
            }

            if (_state == PurchaseModalState.success) {
              return _SuccessContent(
                balance: currentBalance,
                buttonText: widget.originSurface == 'anakra'
                    ? context.l10n.purchaseGoToChat
                    : context.l10n.commonClose,
                onPressed: () {
                  Navigator.pop(context, PurchaseModalOutcome.purchased);
                  widget.onSuccessButtonPressed?.call();
                },
              );
            }

            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                children: [
                  const _Grabber(),
                  const SizedBox(height: 16),
                  _buildInitialContent(
                    context,
                    monetizationProvider,
                    currentBalance,
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  double? _getModalHeight(bool isNotEnoughModal, bool isSuccessModal) {
    if (isNotEnoughModal) return null;
    if (isSuccessModal) return _successPurchaseModalSheetHeight;
    return _purchaseModalSheetHeight;
  }

  Widget _buildInitialContent(
    BuildContext context,
    MonetizationProvider? monetizationProvider,
    int currentBalance,
  ) {
    final newBalance =
        monetizationProvider?.balanceAfterSpend(widget.price) ?? 0;
    return Expanded(
      child: Column(
        children: [
          Text(
            context.l10n.purchaseConfirmTitle,
            style: context.textTheme.inversePlayfairSemiBold24.copyWith(
              height: 1,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          _PurchaseDescription(
            purchaseTitle: widget.purchaseTitle,
            price: widget.price,
          ),
          const SizedBox(height: 18),
          _BalanceChangeWidget(balance: currentBalance, newBalance: newBalance),
          const Spacer(),
          Container(
            padding: const EdgeInsets.only(bottom: 32),
            child: Row(
              children: [
                Expanded(
                  child: _ModalActionButton.outline(
                    onPressed: () => Navigator.pop(context),
                    text: context.l10n.commonCancel,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _ModalActionButton.primary(
                    onPressed: _isSubmitting
                        ? null
                        : () => _handlePurchase(context, monetizationProvider),
                    text: context.l10n.commonBuy,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _handlePurchase(
    BuildContext context,
    MonetizationProvider? monetizationProvider,
  ) async {
    if (_isSubmitting || monetizationProvider == null) return;
    if (_originUid == null ||
        !monetizationProvider.isCurrentUser(_originUid!)) {
      Navigator.pop(context);
      return;
    }
    setState(() => _isSubmitting = true);
    try {
      await monetizationProvider.refreshForAccess();
    } catch (_) {
      if (context.mounted) {
        setState(() => _isSubmitting = false);
        showAccessError(context);
      }
      return;
    }
    if (!context.mounted) return;
    if (!monetizationProvider.isCurrentUser(_originUid!) ||
        ModalRoute.of(context)?.isCurrent != true) {
      setState(() => _isSubmitting = false);
      return;
    }
    if (widget.featureKey != null && monetizationProvider.effectivePro) {
      Navigator.pop(context, PurchaseModalOutcome.proActivated);
      return;
    }
    final loader = di.get<GlobalLoaderService>();
    final analytics = di.get<ProductAnalyticsService>();
    final balanceBefore = monetizationProvider.balance;

    setState(() {
      _isSubmitting = true;
      _idempotencyKey ??= const Uuid().v4();
    });

    unawaitedTrack(
      analytics.trackCoinSpendStart(
        originSurface: widget.originSurface,
        offerType: widget.offerType,
        coinAmount: widget.price,
        balanceBefore: balanceBefore,
      ),
    );

    try {
      if (widget.loaderType != null) {
        loader.showWithSpheres(widget.loaderType!);
      } else {
        loader.show();
      }

      final idempotentPurchase = widget.onIdempotentPurchase;
      if (widget.onAccessPurchase != null) {
        await widget.onAccessPurchase!(false, _idempotencyKey!);
      } else if (idempotentPurchase != null) {
        await idempotentPurchase(_idempotencyKey!);
      } else {
        await widget.onPurchase!();
      }
      await monetizationProvider.refresh();

      unawaitedTrack(
        analytics.trackCoinSpendSuccess(
          originSurface: widget.originSurface,
          offerType: widget.offerType,
          coinAmount: widget.price,
          balanceBefore: balanceBefore,
          balanceAfter: monetizationProvider.balance,
        ),
      );

      loader.hide();
      _idempotencyKey = null;
      if (!mounted || !monetizationProvider.isCurrentUser(_originUid!)) return;
      if (widget.showSuccessState && mounted) {
        setState(() {
          _state = PurchaseModalState.success;
          _isSubmitting = false;
        });
      } else if (context.mounted) {
        Navigator.pop(context, PurchaseModalOutcome.purchased);
        widget.onSuccess?.call();
      }
    } on FeatureExecutionInsufficientStarsException {
      unawaitedTrack(
        analytics.trackCoinSpendFailed(
          originSurface: widget.originSurface,
          offerType: widget.offerType,
          coinAmount: widget.price,
          failureReason: FailureReasons.insufficientBalance,
          balanceBefore: balanceBefore,
        ),
      );
      loader.hide();
      await monetizationProvider.refresh();
      if (mounted) {
        setState(() {
          _state = PurchaseModalState.notEnoughBalance;
          _isSubmitting = false;
        });
      }
    } catch (e) {
      unawaitedTrack(
        analytics.trackCoinSpendFailed(
          originSurface: widget.originSurface,
          offerType: widget.offerType,
          coinAmount: widget.price,
          failureReason: FailureReasons.serverError,
          balanceBefore: balanceBefore,
        ),
      );
      loader.hide();
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(context.l10n.purchaseErrorTryAgain)),
        );
      }
    }
  }
}

/// Lightweight fire-and-forget helper used so we don't have to mark callers
/// `async` just to track analytics.
void unawaitedTrack(Future<void> future) {
  // ignore: unawaited_futures
  future;
}

class _BalanceChangeWidget extends StatelessWidget {
  final int balance;
  final int newBalance;

  const _BalanceChangeWidget({required this.balance, required this.newBalance});

  @override
  Widget build(BuildContext context) {
    return Wrap(
      alignment: WrapAlignment.center,
      crossAxisAlignment: WrapCrossAlignment.center,
      spacing: 12,
      runSpacing: 8,
      children: [
        _AmountLabel(label: context.l10n.balanceLabel, amount: balance),
        const _ArrowIcon(),
        _AmountLabel(label: context.l10n.shopAfterPurchase, amount: newBalance),
      ],
    );
  }
}

class _PurchaseDescription extends StatelessWidget {
  final String purchaseTitle;
  final int price;

  const _PurchaseDescription({
    required this.purchaseTitle,
    required this.price,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: context.l10n.purchaseForCoinsLabel(purchaseTitle, price),
      child: ExcludeSemantics(
        child: Wrap(
          alignment: WrapAlignment.center,
          crossAxisAlignment: WrapCrossAlignment.center,
          spacing: 4,
          children: [
            Text(
              context.l10n.purchaseForPrice(purchaseTitle, price),
              style: context.textTheme.inverseUrbanistRegular17.copyWith(
                height: 1.2,
              ),
            ),
            LotusRasterIcon(
              'assets/icons/star_coin_icon.png',
              width: 20,
              height: 20,
              fit: BoxFit.contain,
            ),
          ],
        ),
      ),
    );
  }
}

class _SuccessContent extends StatelessWidget {
  final int balance;
  final String buttonText;
  final VoidCallback onPressed;

  const _SuccessContent({
    required this.balance,
    required this.buttonText,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          const _Grabber(),
          const SizedBox(height: 24),
          ClayAssetIcon(
            'assets/icons/success_square_icon.svg',
            width: 42,
            height: 42,
          ),
          const SizedBox(height: 14),
          Text(
            context.l10n.shopPurchaseComplete,
            style: context.textTheme.inversePlayfairSemiBold24.copyWith(
              height: 1,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 22),
          _SingleBalance(balance: balance),
          const Spacer(),
          Padding(
            padding: const EdgeInsets.only(bottom: 32),
            child: _ModalActionButton.primary(
              text: buttonText,
              onPressed: onPressed,
            ),
          ),
        ],
      ),
    );
  }
}

class _Grabber extends StatelessWidget {
  const _Grabber();

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      height: 4,
      width: 64,
      decoration: BoxDecoration(
        color: AppColors.cardTinted.withValues(alpha: 0.48),
        borderRadius: BorderRadius.circular(2),
      ),
    );
  }
}

class _AmountLabel extends StatelessWidget {
  final String label;
  final int amount;

  const _AmountLabel({required this.label, required this.amount});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Flexible(
          child: Text.rich(
            TextSpan(
              children: [
                TextSpan(
                  text: '$label ',
                  style: context.textTheme.inverseUrbanistRegular16,
                ),
                TextSpan(
                  text: '$amount',
                  style: context.textTheme.inverseUrbanistSemiBold16,
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 4),
        LotusRasterIcon(
          'assets/icons/star_coin_icon.png',
          width: 20,
          height: 20,
          fit: BoxFit.contain,
        ),
      ],
    );
  }
}

class _SingleBalance extends StatelessWidget {
  final int balance;

  const _SingleBalance({required this.balance});

  @override
  Widget build(BuildContext context) {
    return _AmountLabel(label: context.l10n.balanceLabel, amount: balance);
  }
}

class _ArrowIcon extends StatelessWidget {
  const _ArrowIcon();

  @override
  Widget build(BuildContext context) {
    return LotusRasterIcon(
      'assets/icons/right_long_arrow.png',
      width: 24,
      height: 24,
      fit: BoxFit.contain,
      color: AppColors.white.withValues(alpha: 0.76),
    );
  }
}

class _ModalActionButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isPrimary;

  const _ModalActionButton.primary({
    required this.text,
    required this.onPressed,
  }) : isPrimary = true;

  const _ModalActionButton.outline({
    required this.text,
    required this.onPressed,
  }) : isPrimary = false;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: text,
      child: ExcludeSemantics(
        child: SizedBox(
          height: 50,
          width: double.infinity,
          child: Material(
            color: Colors.transparent,
            borderRadius: BorderRadius.circular(16),
            child: Ink(
              decoration: BoxDecoration(
                gradient: isPrimary ? _modalButtonGradient : null,
                borderRadius: BorderRadius.circular(16),
                border: isPrimary ? null : Border.all(color: _modalPurple),
              ),
              child: LotusInkTap(
                onTap: onPressed,
                borderRadius: BorderRadius.circular(16),
                child: Center(
                  child: Text(
                    text,
                    style: context.textTheme.button.copyWith(
                      color: isPrimary ? AppColors.white : _modalPurple,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
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
