import 'package:asteria_app/core/ui_kit/widgets/asteria_entrance.dart';
import 'dart:async';

import 'package:asteria_app/core/ui_kit/ui_kit.dart';
import 'package:flutter/material.dart';

const Duration _textChangeDuration = Duration(milliseconds: 1800);
const Duration _fadeDuration = Duration(milliseconds: 520);

class HoroscropeCreatingScreen extends StatefulWidget {
  const HoroscropeCreatingScreen({super.key});

  @override
  State<HoroscropeCreatingScreen> createState() =>
      _HoroscropeCreatingScreenState();
}

class _HoroscropeCreatingScreenState extends State<HoroscropeCreatingScreen> {
  int _currentTextIndex = 0;
  Timer? _textTimer;

  @override
  void initState() {
    super.initState();
    _textTimer = Timer.periodic(_textChangeDuration, (_) {
      if (!mounted) {
        return;
      }

      setState(() {
        _currentTextIndex = (_currentTextIndex + 1) % 4;
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
    final loadingStepTexts = [
      context.l10n.astrologyLoadingChart,
      context.l10n.astrologyLoadingStars,
      context.l10n.astrologyLoadingSymbols,
      context.l10n.astrologyLoadingPersonal,
    ];
    final mediaQuery = MediaQuery.of(context);
    final screenHeight = mediaQuery.size.height;
    final availableHeight =
        screenHeight - mediaQuery.padding.top - mediaQuery.padding.bottom - 168;
    final contentHeight = availableHeight.clamp(380.0, 640.0);
    final sphereWidth = (mediaQuery.size.width * 0.56).clamp(196.0, 226.0);

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 358),
        child: SizedBox(
          height: contentHeight,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: AsteriaEntrance.sections([
              SizedBox(height: contentHeight * 0.17),
              SizedBox(
                height: 116,
                child: Center(
                  child: AnimatedSwitcher(
                    duration: _fadeDuration,
                    switchInCurve: Curves.easeOut,
                    switchOutCurve: Curves.easeIn,
                    transitionBuilder: (child, animation) {
                      return FadeTransition(opacity: animation, child: child);
                    },
                    child: Text(
                      loadingStepTexts[_currentTextIndex],
                      key: ValueKey(_currentTextIndex),
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
            ]),
          ),
        ),
      ),
    );
  }
}
