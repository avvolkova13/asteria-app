import 'dart:io';

import 'package:asteria_app/core/analytics/product_analytics_service.dart';
import 'package:asteria_app/core/di/di.dart';
import 'package:asteria_app/core/routing/app_route.dart';
import 'package:asteria_app/core/ui_kit/ui_kit.dart';
import 'package:asteria_app/core/ui_kit/widgets/asteria_entrance.dart';
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
          const MoonScreen(),
          const PracticesScreen(),
          const PersonalScreen(),
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
class HomeTabContents extends StatefulWidget {
  const HomeTabContents({
    super.key,
    required this.index,
    required this.children,
  });

  final int index;
  final List<Widget> children;

  @override
  State<HomeTabContents> createState() => _HomeTabContentsState();
}

class _HomeTabContentsState extends State<HomeTabContents>
    with SingleTickerProviderStateMixin {
  late final _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 320),
    value: 1,
  );
  List<double> _from = [];
  bool _replay = true;

  double _weight(int tab, int selected) {
    final target = tab == selected ? 1.0 : 0.0;
    final prior = tab < _from.length ? _from[tab] : 0.0;
    final t = Curves.easeInOut.transform(_controller.value);
    return prior * (1 - t) + target * t;
  }

  @override
  void didUpdateWidget(HomeTabContents oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.index == widget.index) return;
    _from = List.generate(
      widget.children.length,
      (i) => _weight(i, oldWidget.index),
    );
    _replay = _from[widget.index] < .02;
    if (MediaQuery.disableAnimationsOf(context)) {
      _controller.value = 1;
    } else {
      _controller.forward(from: 0);
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (MediaQuery.disableAnimationsOf(context)) _controller.value = 1;
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final selected = widget.index;
    final pages = [
      for (var i = 0; i < widget.children.length; i++)
        IgnorePointer(
          ignoring: i != selected,
          child: ExcludeSemantics(
            excluding: i != selected,
            child: ExcludeFocus(
              excluding: i != selected,
              child: TickerMode(
                enabled: i == selected,
                child: widget.children[i],
              ),
            ),
          ),
        ),
    ];
    final order = [
      for (var i = 0; i < pages.length; i++)
        if (i != selected) i,
      selected,
    ];
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        // Normalize the alpha of each layer against those underneath. Two
        // independently fading opaque pages would expose the dark canvas.
        var weightBelow = 0.0;
        final layers = <Widget>[];
        for (final i in order) {
          final weight = _weight(i, selected);
          weightBelow += weight;
          final alpha = weightBelow == 0 ? 0.0 : weight / weightBelow;
          layers.add(
            Offstage(
              key: ValueKey(i),
              offstage: weight == 0 && i != selected,
              child: Opacity(
                opacity: alpha,
                child: AsteriaEntranceReplay(
                  enabled: i != selected || _replay || _controller.isCompleted,
                  child: pages[i],
                ),
              ),
            ),
          );
        }
        return Stack(fit: StackFit.expand, children: layers);
      },
    );
  }
}
