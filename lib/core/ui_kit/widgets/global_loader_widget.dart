import 'package:asteria_app/core/services/global_loader_service.dart';
import 'package:asteria_app/core/ui_kit/ui_kit.dart';
import 'package:asteria_app/core/ui_kit/widgets/generation_loading_view.dart';
import 'package:flutter/material.dart';

class GlobalLoaderWidget extends StatelessWidget {
  const GlobalLoaderWidget({
    super.key,
    required this.child,
    required this.loaderService,
  });
  final Widget child;
  final GlobalLoaderService loaderService;

  @override
  Widget build(BuildContext context) => ListenableBuilder(
    listenable: loaderService,
    builder: (context, _) {
      final type = loaderService.loaderType;
      return Stack(
        fit: StackFit.expand,
        children: [
          ExcludeFocus(
            excluding: loaderService.isLoading,
            child: ExcludeSemantics(
              excluding: loaderService.isLoading,
              child: child,
            ),
          ),
          if (loaderService.isLoading)
            BlockSemantics(
              child: AbsorbPointer(
                child: type == null
                    ? Material(
                        color: Colors.black.withValues(alpha: .5),
                        child: const Center(child: CircularProgressIndicator()),
                      )
                    : GenerationLoadingView(
                        key: ValueKey(type),
                        title: switch (type) {
                          GlobalLoaderType.compatibility =>
                            context.l10n.compatibilityTitle,
                          GlobalLoaderType.natalCard =>
                            context.l10n.natalChartTitle,
                          GlobalLoaderType.sonnik =>
                            context.l10n.dreamDictionaryTitle,
                          GlobalLoaderType.insight =>
                            context.l10n.insightLoadingTitle,
                          GlobalLoaderType.horoscope => context.l10n.loading,
                        },
                        phrases: generationLoadingPhrases(context, type),
                      ),
              ),
            ),
        ],
      );
    },
  );
}

List<String> generationLoadingPhrases(
  BuildContext context,
  GlobalLoaderType type,
) => switch (type) {
  GlobalLoaderType.compatibility => [
    context.l10n.compatibilityLoadingConsulting,
    context.l10n.compatibilityLoadingSecrets,
    context.l10n.compatibilityLoadingDestinies,
    context.l10n.compatibilityLoadingSigns,
  ],
  GlobalLoaderType.natalCard => [
    context.l10n.natalLoadingPattern,
    context.l10n.natalLoadingLanguage,
    context.l10n.natalLoadingCode,
    context.l10n.natalLoadingPortrait,
  ],
  GlobalLoaderType.sonnik => [
    context.l10n.sonnikLoadingLiveya,
    context.l10n.sonnikLoadingImages,
    context.l10n.sonnikLoadingDetails,
    context.l10n.sonnikLoadingMeaning,
  ],
  GlobalLoaderType.insight => [
    context.l10n.insightLoadingSymbols,
    context.l10n.insightLoadingPerspective,
    context.l10n.insightLoadingAngle,
    context.l10n.insightLoadingTogether,
  ],
  GlobalLoaderType.horoscope => [
    context.l10n.astrologyLoadingChart,
    context.l10n.astrologyLoadingStars,
    context.l10n.astrologyLoadingSymbols,
    context.l10n.astrologyLoadingPersonal,
  ],
};
