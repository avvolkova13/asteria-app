import 'package:asteria_app/core/ui_kit/widgets/generation_loading_view.dart';
import 'package:flutter/material.dart';

class LoadingBlock extends StatelessWidget {
  const LoadingBlock({
    super.key,
    required this.loadingTexts,
    this.textChangeDuration,
  });
  final List<String> loadingTexts;
  final Duration? textChangeDuration;

  @override
  Widget build(BuildContext context) => GenerationLoadingContent(
    phrases: loadingTexts,
    textChangeDuration: textChangeDuration ?? const Duration(seconds: 3),
  );
}
