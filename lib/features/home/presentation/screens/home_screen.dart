import 'dart:io';

import 'package:asteria_app/core/analytics/product_analytics_service.dart';
import 'package:asteria_app/core/di/di.dart';
import 'package:asteria_app/core/routing/app_route.dart';
import 'package:asteria_app/core/ui_kit/ui_kit.dart';
import 'package:asteria_app/features/anakra_chat/presentation/provider/anakra_chat_provider.dart';
import 'package:asteria_app/features/home/localization/home_localization_contract.dart';
import 'package:asteria_app/features/home/presentation/cubit/home_cubit.dart';
import 'package:asteria_app/features/home/presentation/cubit/home_state.dart';
import 'package:asteria_app/features/home/presentation/models/year_animal_asset.dart';
import 'package:asteria_app/features/home/presentation/screens/main_screen.dart';
import 'package:asteria_app/features/home/presentation/screens/personal_screen.dart';
import 'package:asteria_app/features/home/presentation/screens/moon_screen.dart';
import 'package:asteria_app/features/home/presentation/screens/practices_screen.dart';
import 'package:asteria_app/features/home/presentation/widgets/widgets_index.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class HomeScreen extends StatefulWidget {
  final HomeLocalizationContract homeLocalization;
  const HomeScreen({super.key, required this.homeLocalization});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    context.read<HomeCubit>().start();
    _initializeAnakraChat();
    // ast_home_view — fired once when the home screen mounts. Card-level
    // view/click events are emitted by `MainScreen` for the funnel cards.
    di.get<ProductAnalyticsService>().trackHomeView();
  }

  Future<void> _initializeAnakraChat() async {
    final anakraChatProvider = di.get<AnakraChatProvider>();
    await anakraChatProvider.initialize();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<HomeCubit, HomeState>(
      listener: (context, state) {
        if (state is HomeLoggedOut) {
          AuthLoginRoute.go(context);
        } else if (state is HomeError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                state.failure == HomeFailure.logout
                    ? context.l10n.logoutError
                    : context.l10n.homeLoadError,
              ),
            ),
          );
        }
      },
      child: BlocBuilder<HomeCubit, HomeState>(
        builder: (context, state) {
          final content = switch (state) {
            HomeInitial() => const Scaffold(
              backgroundColor: AppColorsDark.homeCanvas,
              body: Center(child: LoadingWidget()),
            ),
            HomeLoading() => const Scaffold(
              backgroundColor: AppColorsDark.homeCanvas,
              body: Center(child: LoadingWidget()),
            ),
            HomeLoaded() => _buildHomeScreen(context, state),
            HomeLoggedOut() => const Scaffold(
              backgroundColor: AppColorsDark.homeCanvas,
              body: SizedBox.shrink(),
            ),
            HomeError() => _buildErrorScaffold(
              context,
              context.l10n.homeLoadError,
              context.l10n.commonRetry,
              () => context.read<HomeCubit>().start(),
            ),
          };
          return ColoredBox(
            color: AppColorsDark.homeCanvas,
            child: AnimatedSwitcher(
              duration: MediaQuery.disableAnimationsOf(context)
                  ? Duration.zero
                  : const Duration(milliseconds: 320),
              switchInCurve: Curves.easeInOut,
              switchOutCurve: Curves.easeInOut,
              child: KeyedSubtree(
                key: ValueKey(
                  state is HomeInitial || state is HomeLoading
                      ? HomeLoading
                      : state.runtimeType,
                ),
                child: content,
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildHomeScreen(BuildContext context, HomeLoaded state) {
    final isAndroid = Platform.isAndroid;
    final aiAstrologerAsset = YearAnimalAsset.forYear(DateTime.now().year);

    return Scaffold(
      backgroundColor: AppColorsDark.homeCanvas,
      body: HomeTabContents(
        index: state.currentTabIndex,
        children: [
          const MainScreen(),
          const PersonalScreen(),
          const MoonScreen(),
          const PracticesScreen(),
        ],
      ),
      bottomNavigationBar: Padding(
        padding: EdgeInsets.only(bottom: isAndroid ? 8 : 0),
        child: BottomTabBarWidget(
          currentIndex: state.currentTabIndex,
          onTabChanged: (index) {
            context.read<HomeCubit>().changeTab(index);
          },
          onAiAstrologerPressed: () {
            AnakraChatRoute.push(context);
          },
          aiAstrologerAsset: aiAstrologerAsset,
        ),
      ),
    );
  }

  Widget _buildErrorScaffold(
    BuildContext context,
    String message,
    String buttonText,
    VoidCallback onPressed,
  ) {
    return Scaffold(
      backgroundColor: AppColorsDark.homeCanvas,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                message,
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(color: AppColors.textInverse),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              CustomButton(text: buttonText, onPressed: onPressed),
            ],
          ),
        ),
      ),
    );
  }
}

/// Each tab keeps its scroll and form state. During a handoff only the new
/// tab can receive input or run its own tickers.
class HomeTabContents extends StatelessWidget {
  const HomeTabContents({
    super.key,
    required this.index,
    required this.children,
  });

  final int index;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final duration = MediaQuery.disableAnimationsOf(context)
        ? Duration.zero
        : const Duration(milliseconds: 300);
    return Stack(
      fit: StackFit.expand,
      children: [
        for (var i = 0; i < children.length; i++)
          TweenAnimationBuilder<double>(
            tween: Tween<double>(
              begin: i == index ? 1 : 0,
              end: i == index ? 1 : 0,
            ),
            duration: duration,
            curve: Curves.easeInOut,
            builder: (context, opacity, child) => Offstage(
              offstage: opacity == 0,
              child: Opacity(opacity: opacity, child: child),
            ),
            child: IgnorePointer(
              ignoring: i != index,
              child: ExcludeSemantics(
                excluding: i != index,
                child: ExcludeFocus(
                  excluding: i != index,
                  child: TickerMode(enabled: i == index, child: children[i]),
                ),
              ),
            ),
          ),
      ],
    );
  }
}
