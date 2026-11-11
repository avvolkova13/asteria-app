import 'package:asteria_app/core/services/global_loader_service.dart';
import 'package:asteria_app/core/ui_kit/widgets/generation_loading_view.dart';
import 'package:asteria_app/core/ui_kit/widgets/global_loader_widget.dart';
import 'package:flutter/material.dart';

class HoroscropeCreatingScreen extends StatelessWidget {
  const HoroscropeCreatingScreen({super.key});

  @override
  Widget build(BuildContext context) => Center(
    child: SingleChildScrollView(
      child: GenerationLoadingContent(
        phrases: generationLoadingPhrases(context, GlobalLoaderType.horoscope),
      ),
    ),
  );
}
