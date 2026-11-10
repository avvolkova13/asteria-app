import 'package:asteria_app/core/ui_kit/ui_kit.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/onboarding_bloc.dart';
import '../widgets/onboarding_page_widget.dart';
import '../widgets/onboarding_pagination_widget.dart';
import '../../localization/onboarding_localization_contract.dart';
import '../../data/models/onboarding_page_model.dart';

class OnboardingScreen extends StatefulWidget {
  final List<OnboardingPageModel> pages;
  final OnboardingLocalizationContract localization;
  final VoidCallback? onComplete;

  const OnboardingScreen({
    super.key,
    required this.pages,
    required this.localization,
    this.onComplete,
  });

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  late final PageController _pageController;
  bool _completionRequested = false;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    context.read<OnboardingBloc>().add(OnboardingInitialized(widget.pages));
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onPageChanged(OnboardingState state) {
    if (state.currentPageIndex >= state.pages.length - 1) {
      if (_completionRequested) return;
      _completionRequested = true;
      context.read<OnboardingBloc>().add(OnboardingFinish());
      widget.onComplete?.call();
    } else {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _onChanged(int index) {
    context.read<OnboardingBloc>().add(OnboardingPageChanged(index));
  }

  void _onRetry() {
    context.read<OnboardingBloc>().add(OnboardingInitialized(widget.pages));
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        statusBarBrightness: Brightness.dark,
        systemNavigationBarColor: Colors.transparent,
        systemNavigationBarIconBrightness: Brightness.light,
      ),
      child: Scaffold(
        backgroundColor: const Color(0xFF0D0719),
        body: BlocBuilder<OnboardingBloc, OnboardingState>(
          builder: (context, state) {
            if (state.error != null) {
              return SafeArea(
                child: ErrorScreenWidget(
                  error: switch (state.error!) {
                    OnboardingErrorCode.emptyPages =>
                      context.l10n.onboardingEmptyPagesError,
                    OnboardingErrorCode.invalidPageIndex =>
                      context.l10n.onboardingInvalidPageError,
                  },
                  onRetry: _onRetry,
                ),
              );
            }

            return Stack(
              fit: StackFit.expand,
              children: [
                PageView.builder(
                  controller: _pageController,
                  onPageChanged: _onChanged,
                  itemCount: state.pages.length,
                  itemBuilder: (context, index) {
                    final page = state.pages[index];
                    return OnboardingPageWidget(
                      page: page,
                      localization: widget.localization,
                    );
                  },
                ),
                Positioned(
                  left: 16,
                  right: 16,
                  top: MediaQuery.paddingOf(context).top + 24,
                  child: OnboardingPaginationWidget(
                    totalPages: state.pages.length,
                    currentPage: state.currentPageIndex,
                  ),
                ),
                Positioned(
                  left: 16,
                  right: 16,
                  bottom: MediaQuery.paddingOf(context).bottom + 24,
                  child: _OnboardingCtaButton(
                    text: widget.localization.nextButton(context),
                    onPressed: state.pages.isEmpty
                        ? null
                        : () => _onPageChanged(state),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _OnboardingCtaButton extends StatelessWidget {
  static const _gradient = LinearGradient(
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
    colors: [Color(0xFF6E4BFF), Color(0xFF5A3FD1)],
  );

  final String text;
  final VoidCallback? onPressed;

  const _OnboardingCtaButton({required this.text, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    final isEnabled = onPressed != null;

    return Semantics(
      button: true,
      enabled: isEnabled,
      label: text,
      onTap: onPressed,
      child: ExcludeSemantics(
        child: Opacity(
          opacity: isEnabled ? 1 : 0.58,
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: _gradient,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF6E4BFF).withValues(alpha: 0.05),
                  blurRadius: 30,
                  offset: Offset.zero,
                ),
              ],
            ),
            child: DecoratedBox(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                gradient: const RadialGradient(
                  center: Alignment.topCenter,
                  radius: 2,
                  colors: [Color(0x40F1ECFF), Color(0x00F1ECFF)],
                ),
              ),
              child: Material(
                color: Colors.transparent,
                borderRadius: BorderRadius.circular(16),
                child: InkWell(
                  onTap: onPressed,
                  borderRadius: BorderRadius.circular(16),
                  child: SizedBox(
                    height: 50,
                    child: Center(
                      child: Text(
                        text,
                        style: const TextStyle(
                          fontFamily: 'Onest',
                          fontSize: 17,
                          fontWeight: FontWeight.w400,
                          height: 1.2,
                          letterSpacing: -.41,
                          color: Colors.white,
                        ),
                      ),
                    ),
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
