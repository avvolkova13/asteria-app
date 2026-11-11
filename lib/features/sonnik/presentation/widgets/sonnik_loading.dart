import 'package:asteria_app/core/services/global_loader_service.dart';
import 'package:asteria_app/core/ui_kit/ui_kit.dart';
import 'package:flutter/material.dart';

class SonnikLoading extends StatelessWidget {
  const SonnikLoading({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        LoadingBlock(
          loadingTexts: generationLoadingPhrases(
            context,
            GlobalLoaderType.sonnik,
          ),
        ),
        const SizedBox(height: 100),
      ],
    );
  }
}
