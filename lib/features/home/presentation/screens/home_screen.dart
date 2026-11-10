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
          return switch (state) {
            HomeInitial() => const Scaffold(
              backgroundColor: Color(0xFFEEEAFD),
              body: Center(child: LoadingWidget()),
            ),
            HomeLoading() => const Scaffold(
              backgroundColor: Color(0xFFEEEAFD),
              body: Center(child: LoadingWidget()),
            ),
            HomeLoaded() => _buildHomeScreen(context, state),
            HomeLoggedOut() => const Scaffold(
              backgroundColor: Color(0xFFEEEAFD),
              body: SizedBox.shrink(),
            ),
            HomeError() => _buildErrorScaffold(
              context,
              context.l10n.homeLoadError,
              context.l10n.commonRetry,
              () => context.read<HomeCubit>().start(),
            ),
          };
        },
      ),
    );
  }

  Widget _buildHomeScreen(BuildContext context, HomeLoaded state) {
    final isAndroid = Platform.isAndroid;
    final aiAstrologerAsset = YearAnimalAsset.forYear(DateTime.now().year);

    return Scaffold(
      backgroundColor: const Color(0xFFEEEAFD),
      body: IndexedStack(
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
      backgroundColor: const Color(0xFFEEEAFD),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                message,
                style: Theme.of(context).textTheme.titleLarge,
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
