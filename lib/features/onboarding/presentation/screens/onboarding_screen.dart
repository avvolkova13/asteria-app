import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:asteria_app/core/ui_kit/ui_kit.dart';

import '../bloc/onboarding_bloc.dart';
import '../widgets/intro/onboarding_tour.dart';
import '../../localization/onboarding_localization_contract.dart';
import '../../data/models/onboarding_page_model.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({
    super.key,
    required this.pages,
    required this.localization,
    this.onComplete,
    this.now = DateTime.now,
  });
  final List<OnboardingPageModel> pages;
  final OnboardingLocalizationContract localization;
  final VoidCallback? onComplete;
  final DateTime Function() now;
  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  bool _finishing = false;
  @override
  void initState() {
    super.initState();
    context.read<OnboardingBloc>().add(OnboardingInitialized(widget.pages));
  }

  void _finish() {
    if (_finishing) return;
    _finishing = true;
    context.read<OnboardingBloc>().add(OnboardingFinish());
  }

  @override
  Widget build(BuildContext context) =>
      BlocConsumer<OnboardingBloc, OnboardingState>(
        listenWhen: (previous, current) =>
            !previous.isCompleted && current.isCompleted,
        listener: (_, state) => widget.onComplete?.call(),
        builder: (context, state) {
          if (state.error != null || widget.pages.isEmpty) {
            return Scaffold(
              body: SafeArea(
                child: ErrorScreenWidget(
                  error: context.l10n.onboardingEmptyPagesError,
                  onRetry: () => context.read<OnboardingBloc>().add(
                    OnboardingInitialized(widget.pages),
                  ),
                ),
              ),
            );
          }
          return OnboardingTour(
            pages: widget.pages,
            now: widget.now,
            onComplete: _finish,
            onPageChanged: (index) => context.read<OnboardingBloc>().add(
              OnboardingPageChanged(index),
            ),
          );
        },
      );
}
