import 'dart:async';

import 'package:asteria_app/core/ui_kit/ui_kit.dart';
import 'package:flutter/material.dart';

const Duration _fadeDuration = Duration(milliseconds: 800);

class HoroscropeCreatingScreen extends StatefulWidget {
  const HoroscropeCreatingScreen({Key? key}) : super(key: key);

  @override
  _HoroscropeCreatingScreenState createState() =>
      _HoroscropeCreatingScreenState();
}

class _HoroscropeCreatingScreenState extends State<HoroscropeCreatingScreen>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;
  int _currentTextIndex = 0;
  Timer? _textTimer;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(duration: _fadeDuration, vsync: this);
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeInOut),
    );

    _startTextRotation();
  }

  void _startTextRotation() {
    _textTimer = Timer.periodic(_fadeDuration, (timer) {
      if (mounted) {
        setState(() {
          _currentTextIndex =
              (_currentTextIndex + 1) % 4;
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
    final loadingStepTexts = [
      context.l10n.astrologyLoadingChart,
      context.l10n.astrologyLoadingStars,
      context.l10n.astrologyLoadingSymbols,
      context.l10n.astrologyLoadingPersonal,
    ];
    return Container(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            height: 120,
            child: AnimatedBuilder(
              animation: _fadeAnimation,
              builder: (context, child) {
                return FadeTransition(
                  opacity: _fadeAnimation,
                  child: Center(
                    child: Text(
                      loadingStepTexts[_currentTextIndex],
                      style: context.textTheme.playfairSemiBold32,
                      textAlign: TextAlign.center,
                    ),
                  ),
                );
              },
            ),
          ),
          Image.asset('assets/images/horoscope/horoscope_sphere.webp'),
        ],
      ),
    );
  }
}
