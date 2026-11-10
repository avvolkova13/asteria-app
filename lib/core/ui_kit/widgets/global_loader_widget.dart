import 'dart:async';

import 'package:asteria_app/app/providers/user_provider.dart';
import 'package:asteria_app/core/routing/app_route.dart';
import 'package:asteria_app/core/services/global_loader_service.dart';
import 'package:asteria_app/core/ui_kit/ui_kit.dart';
import 'package:asteria_app/features/monetization/presentation/monetization_provider.dart';
import 'package:asteria_app/features/natal_card/widgets/natal_card_loading_overlay.dart';
import 'package:asteria_app/core/ui_kit/widgets/subscription_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';

class GlobalLoaderWidget extends StatelessWidget {
  final Widget child;
  final GlobalLoaderService loaderService;

  const GlobalLoaderWidget({
    super.key,
    required this.child,
    required this.loaderService,
  });

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: loaderService,
      builder: (context, _) {
        final loadingTexts = _loadingTexts(context, loaderService.loaderType);
        return Stack(
          children: [
            child,
            if (loaderService.isLoading)
              AbsorbPointer(
                child: loaderService.loaderType == GlobalLoaderType.natalCard
                    ? const NatalCardLoadingOverlay()
                    : loaderService.loaderType == GlobalLoaderType.compatibility
                    ? _CompatibilityLoadingOverlay(loadingTexts: loadingTexts)
                    : loaderService.loaderType != null &&
                          loadingTexts.isNotEmpty
                    ? _SpheresLoadingOverlay(loadingTexts: loadingTexts)
                    : Material(
                        color: Colors.black.withValues(alpha: 0.5),
                        child: const Center(child: CircularProgressIndicator()),
                      ),
              ),
          ],
        );
      },
    );
  }

  List<String> _loadingTexts(BuildContext context, GlobalLoaderType? type) =>
      switch (type) {
        GlobalLoaderType.compatibility => [
          context.l10n.compatibilityLoadingConsulting,
          context.l10n.compatibilityLoadingSecrets,
          context.l10n.compatibilityLoadingDestinies,
          context.l10n.compatibilityLoadingSigns,
        ],
        GlobalLoaderType.horoscope => [
          context.l10n.astrologyLoadingChart,
          context.l10n.astrologyLoadingStars,
          context.l10n.astrologyLoadingSymbols,
          context.l10n.astrologyLoadingPersonal,
        ],
        GlobalLoaderType.natalCard => [
          context.l10n.natalLoadingPattern,
          context.l10n.natalLoadingLanguage,
          context.l10n.natalLoadingCode,
          context.l10n.natalLoadingPortrait,
        ],
        null => const [],
      };
}

class _CompatibilityLoadingOverlay extends StatefulWidget {
  final List<String> loadingTexts;

  const _CompatibilityLoadingOverlay({required this.loadingTexts});

  @override
  State<_CompatibilityLoadingOverlay> createState() =>
      _CompatibilityLoadingOverlayState();
}

class _CompatibilityLoadingOverlayState
    extends State<_CompatibilityLoadingOverlay>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;
  int _currentIndex = 0;
  Timer? _textTimer;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(duration: _fadeDuration, vsync: this);
    _fadeAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeInOut),
    );
    _fadeController.forward();
    _textTimer = Timer.periodic(_fadeDuration, (timer) {
      if (!mounted || widget.loadingTexts.isEmpty) return;
      setState(() {
        _currentIndex = (_currentIndex + 1) % widget.loadingTexts.length;
      });
      _fadeController
        ..reset()
        ..forward();
    });
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _textTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final text = widget.loadingTexts.isEmpty
        ? ''
        : widget.loadingTexts[_currentIndex];

    return Material(
      color: AppColors.textPrimary,
      child: Stack(
        fit: StackFit.expand,
        children: [
          const _CompatibilityLoaderBackground(),
          SafeArea(
            bottom: false,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 35),
                  const _CompatibilityLoaderTopBar(),
                  const SizedBox(height: 24),
                  const Align(
                    alignment: Alignment.centerLeft,
                    child: _CompatibilityLoaderRequestsBadge(),
                  ),
                  const SizedBox(height: 28),
                  FadeTransition(
                    opacity: _fadeAnimation,
                    child: Text(
                      text,
                      style: context.textTheme.inversePlayfairSemiBold32
                          .copyWith(height: 1.18),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(height: 54),
                  Center(
                    child: SizedBox(
                      width: 325,
                      height: 311,
                      child: Lottie.asset(
                        'assets/lottie/spheres_animation.json',
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CompatibilityLoaderTopBar extends StatelessWidget {
  const _CompatibilityLoaderTopBar();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SvgPicture.asset(
          'assets/icons/back_icon.svg',
          width: 24,
          height: 24,
          colorFilter: ColorFilter.mode(
            AppColors.textSecondary,
            BlendMode.srcIn,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            context.l10n.compatibilityTitle,
            style: context.textTheme.inverseUrbanistSemiBold17,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        GestureDetector(
          onTap: () => BalanceRoute.push(context),
          child: Row(
            children: [
              Consumer<UserProvider>(
                builder: (context, userProvider, child) {
                  return Text(
                    '${MonetizationProvider.maybeOf(context)?.balance ?? 0}',
                    style: context.textTheme.inverseUrbanistSemiBold17,
                  );
                },
              ),
              const SizedBox(width: 2),
              Image.asset('assets/icons/star_coin_icon.png', height: 14),
            ],
          ),
        ),
        const SizedBox(width: 8),
        const SubscriptionWidget(),
      ],
    );
  }
}

class _CompatibilityLoaderRequestsBadge extends StatelessWidget {
  const _CompatibilityLoaderRequestsBadge();

  @override
  Widget build(BuildContext context) {
    return Consumer<MonetizationProvider>(
      builder: (context, monetizationProvider, child) {
        final count = monetizationProvider.requestsLeft('compatibility');

        return IntrinsicWidth(
          child: Container(
            height: 22,
            padding: const EdgeInsets.symmetric(horizontal: 8),
            decoration: BoxDecoration(
              color: const Color(0xFFFFB45E),
              borderRadius: BorderRadius.circular(8),
            ),
            alignment: Alignment.center,
            child: Text(
              context.l10n.requestsLeftCount(count),
              style: context.textTheme.urbanistRegular12.copyWith(
                color: AppColors.textPrimary,
                height: 1,
              ),
            ),
          ),
        );
      },
    );
  }
}

class _CompatibilityLoaderBackground extends StatelessWidget {
  const _CompatibilityLoaderBackground();

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _CompatibilityLoaderStarPainter(),
      child: const DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF0F0A18), Color(0xFF120B1D), Color(0xFF332B58)],
            stops: [0, 0.44, 1],
          ),
        ),
      ),
    );
  }
}

class _CompatibilityLoaderStarPainter extends CustomPainter {
  static const _stars = <Offset>[
    Offset(0.11, 0.22),
    Offset(0.27, 0.17),
    Offset(0.43, 0.28),
    Offset(0.62, 0.14),
    Offset(0.74, 0.25),
    Offset(0.91, 0.18),
    Offset(0.16, 0.43),
    Offset(0.48, 0.39),
    Offset(0.73, 0.48),
    Offset(0.82, 0.67),
    Offset(0.43, 0.74),
  ];

  @override
  void paint(Canvas canvas, Size size) {
    final starPaint = Paint()..color = AppColors.white.withValues(alpha: 0.36);
    final accentPaint = Paint()
      ..color = const Color(0xFFFFF1B8).withValues(alpha: 0.46);

    for (var i = 0; i < _stars.length; i++) {
      final point = Offset(
        _stars[i].dx * size.width,
        _stars[i].dy * size.height,
      );
      canvas.drawCircle(
        point,
        i.isEven ? 1.3 : 2.4,
        i % 3 == 0 ? accentPaint : starPaint,
      );
    }

    final hazePaint = Paint()
      ..shader =
          RadialGradient(
            colors: [
              const Color(0xFFEEEAFD).withValues(alpha: 0.16),
              Colors.transparent,
            ],
          ).createShader(
            Rect.fromCircle(
              center: Offset(size.width * 0.5, size.height * 0.83),
              radius: size.width * 0.62,
            ),
          );
    canvas.drawCircle(
      Offset(size.width * 0.5, size.height * 0.83),
      size.width * 0.62,
      hazePaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

const Duration _spheresTextChangeDuration = Duration(milliseconds: 1800);
const Duration _spheresFadeDuration = Duration(milliseconds: 520);

class _SpheresLoadingOverlay extends StatefulWidget {
  final List<String> loadingTexts;

  const _SpheresLoadingOverlay({required this.loadingTexts});

  @override
  State<_SpheresLoadingOverlay> createState() => _SpheresLoadingOverlayState();
}

class _SpheresLoadingOverlayState extends State<_SpheresLoadingOverlay> {
  int _currentTextIndex = 0;
  Timer? _textTimer;

  @override
  void initState() {
    super.initState();
    _textTimer = Timer.periodic(_spheresTextChangeDuration, (_) {
      if (!mounted || widget.loadingTexts.isEmpty) {
        return;
      }

      setState(() {
        _currentTextIndex =
            (_currentTextIndex + 1) % widget.loadingTexts.length;
      });
    });
  }

  @override
  void dispose() {
    _textTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final screenHeight = mediaQuery.size.height;
    final availableHeight =
        screenHeight - mediaQuery.padding.top - mediaQuery.padding.bottom - 168;
    final contentHeight = availableHeight.clamp(380.0, 640.0);
    final sphereWidth = (mediaQuery.size.width * 0.56).clamp(196.0, 226.0);
    final text = widget.loadingTexts[_currentTextIndex];

    return Material(
      color: AppColors.textPrimary,
      child: Stack(
        fit: StackFit.expand,
        children: [
          const _CompatibilityLoaderBackground(),
          SafeArea(
            bottom: false,
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 358),
                child: SizedBox(
                  height: contentHeight,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      SizedBox(height: contentHeight * 0.17),
                      SizedBox(
                        height: 116,
                        child: Center(
                          child: AnimatedSwitcher(
                            duration: _spheresFadeDuration,
                            switchInCurve: Curves.easeOut,
                            switchOutCurve: Curves.easeIn,
                            transitionBuilder: (child, animation) {
                              return FadeTransition(
                                opacity: animation,
                                child: child,
                              );
                            },
                            child: Text(
                              text,
                              key: ValueKey(text),
                              textAlign: TextAlign.center,
                              style: context.textTheme.inversePlayfairSemiBold32
                                  .copyWith(height: 1.2, letterSpacing: 0),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: contentHeight * 0.085),
                      Image.asset(
                        'assets/images/horoscope/horoscope_sphere.webp',
                        width: sphereWidth,
                        fit: BoxFit.contain,
                      ),
                      const Spacer(),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

const Duration _fadeDuration = Duration(milliseconds: 800);

class _LoadingBlockWidget extends StatefulWidget {
  final List<String> loadingTexts;

  const _LoadingBlockWidget({Key? key, required this.loadingTexts})
    : super(key: key);

  @override
  _LoadingBlockWidgetState createState() => _LoadingBlockWidgetState();
}

class _LoadingBlockWidgetState extends State<_LoadingBlockWidget>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;
  int _currentIndex = 0;
  Timer? _textTimer;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(duration: _fadeDuration, vsync: this);
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeInOut),
    );

    _fadeController.forward();
    _startTextRotation();
  }

  void _startTextRotation() {
    _textTimer = Timer.periodic(_fadeDuration, (timer) {
      if (mounted) {
        setState(() {
          _currentIndex = (_currentIndex + 1) % widget.loadingTexts.length;
        });
        _fadeController.reset();
        _fadeController.forward();
      }
    });
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _textTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            height: 80,
            child: AnimatedBuilder(
              animation: _fadeAnimation,
              builder: (context, child) {
                return FadeTransition(
                  opacity: _fadeAnimation,
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Text(
                        widget.loadingTexts[_currentIndex],
                        style: context.textTheme.playfairSemiBold24,
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          Lottie.asset('assets/lottie/spheres_animation.json'),
        ],
      ),
    );
  }
}
