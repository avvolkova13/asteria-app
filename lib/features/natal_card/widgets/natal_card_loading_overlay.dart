import 'package:asteria_app/core/services/global_loader_service.dart';
import 'package:asteria_app/core/ui_kit/ui_kit.dart';
import 'package:asteria_app/core/ui_kit/widgets/generation_loading_view.dart';
import 'package:flutter/material.dart';

/// Shared by chart generation and loading a translated chart.
class NatalCardLoadingOverlay extends StatelessWidget {
  const NatalCardLoadingOverlay({super.key});

  @override
  Widget build(BuildContext context) => GenerationLoadingView(
    title: context.l10n.natalChartTitle,
    phrases: generationLoadingPhrases(context, GlobalLoaderType.natalCard),
  );
}
