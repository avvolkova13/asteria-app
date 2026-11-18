import 'package:asteria_app/core/localization/localization.dart';
import 'package:asteria_app/core/ui_kit/ui_kit.dart';
import 'package:asteria_app/features/onboarding/data/onboarding_data.dart';
import 'package:asteria_app/features/onboarding/presentation/widgets/intro/onboarding_tour.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

/// Simulator-only presentation entry point; uses the production tour widgets.
/// No account, backend initialization or persistent onboarding completion.
void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.light);
  runApp(const OnboardingDemoApp());
}

class OnboardingDemoApp extends StatelessWidget {
  const OnboardingDemoApp({super.key});

  @override
  Widget build(BuildContext context) => MaterialApp(
    title: 'Астерия Онбординг',
    debugShowCheckedModeBanner: false,
    locale: const Locale('ru'),
    localizationsDelegates: const [
      AppLocalizations.delegate,
      ...GlobalMaterialLocalizations.delegates,
    ],
    supportedLocales: AppLocaleService.supportedLocales,
    home: Builder(
      builder: (context) => Theme(
        data: AppThemeDark.instance.getThemeData(context),
        child: const _DemoPresentation(),
      ),
    ),
  );
}

class _DemoPresentation extends StatefulWidget {
  const _DemoPresentation();

  @override
  State<_DemoPresentation> createState() => _DemoPresentationState();
}

class _DemoPresentationState extends State<_DemoPresentation> {
  bool _finished = false;

  @override
  Widget build(BuildContext context) {
    if (!_finished) {
      return OnboardingTour(
        pages: OnboardingData.getPages(context),
        onPageChanged: (_) {},
        onComplete: () => setState(() => _finished = true),
      );
    }
    return Scaffold(
      backgroundColor: AppColorsDark.homeCanvas,
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(28),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Астерия Онбординг',
                  textAlign: TextAlign.center,
                  style: AppTypography.h2.copyWith(
                    color: AppColors.textInverse,
                    height: 1.3,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'Демонстрация завершена',
                  style: AppTypography.text1.copyWith(
                    color: AppColorsDark.textSecondary,
                  ),
                ),
                const SizedBox(height: 28),
                FilledButton(
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColorsDark.linkGold,
                    foregroundColor: AppColorsDark.homeCanvas,
                    minimumSize: const Size(240, 52),
                  ),
                  onPressed: () => setState(() => _finished = false),
                  child: const Text('Открыть онбординг'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
