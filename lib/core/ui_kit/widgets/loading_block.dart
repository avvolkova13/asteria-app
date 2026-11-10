import 'dart:async';

import 'package:asteria_app/core/ui_kit/ui_kit.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

const Duration _fadeDuration = Duration(milliseconds: 800);

class LoadingBlock extends StatefulWidget {
  final List<String> loadingTexts;
  final Duration? textChangeDuration;

  const LoadingBlock({Key? key, required this.loadingTexts, this.textChangeDuration}) : super(key: key);

  @override
  _LoadingBlockState createState() => _LoadingBlockState();
}

class _LoadingBlockState extends State<LoadingBlock> with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;
  int _currentIndex = 0;
  Timer? _textTimer;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(duration: _fadeDuration, vsync: this);
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _fadeController, curve: Curves.easeInOut));

    _startTextRotation();
  }

  void _startTextRotation() {
    final duration = widget.textChangeDuration ?? _fadeDuration;
    _textTimer = Timer.periodic(duration, (timer) {
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
                      widget.loadingTexts[_currentIndex],
                      style: context.textTheme.playfairSemiBold32,
                      textAlign: TextAlign.center,
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
