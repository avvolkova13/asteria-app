import 'package:asteria_app/core/ui_kit/widgets/asteria_entrance.dart';
import 'package:asteria_app/core/analytics/analytics_events.dart';
import 'package:asteria_app/core/analytics/analytics_facade.dart';
import 'package:asteria_app/core/analytics/dictionaries/entry_surface.dart';
import 'package:asteria_app/core/analytics/dictionaries/length_band.dart';
import 'package:asteria_app/core/analytics/dictionaries/limit_period.dart';
import 'package:asteria_app/core/analytics/dictionaries/limit_type.dart';
import 'package:asteria_app/core/analytics/event_params.dart';
import 'package:asteria_app/core/analytics/product_analytics_service.dart';
import 'package:asteria_app/core/di/di.dart';
import 'package:asteria_app/core/services/auth/auth_session_service.dart';
import 'package:asteria_app/core/routing/app_route.dart';
import 'package:asteria_app/core/ui_kit/ui_kit.dart';
import 'package:asteria_app/features/anakra_chat/presentation/provider/anakra_chat_provider.dart';
import 'package:asteria_app/features/anakra_chat/presentation/widgets/anakra_chat_message.dart';
import 'package:asteria_app/features/anakra_chat/presentation/widgets/anakra_layout.dart';
import 'package:asteria_app/features/anakra_chat/presentation/widgets/anakra_quick_actions.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../widgets/anakra_composer.dart';

class AnakraChatScreen extends StatefulWidget {
  const AnakraChatScreen({super.key});

  @override
  State<AnakraChatScreen> createState() => _AnakraChatScreenState();
}

class _AnakraChatScreenState extends State<AnakraChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  bool _hasScrolledToBottom = false;
  bool _hasInput = false;
  bool _isDispatching = false;
  int _previousMessagesCount = 0;
  // 1-based counter of user-originated messages within the current screen
  // lifecycle. Sent as `message_index` to enable conversation-depth analysis.
  int _userMessageIndex = 0;

  static const _featureParam = {EventParams.featureName: 'anakra_chat'};

  @override
  void initState() {
    super.initState();
    _messageController.addListener(_onMessageInputChanged);
    di.get<AnakraChatProvider>().initialize();
    di.get<AnalyticsFacade>().trackEvent(
      AnalyticsEvents.anakraChatOpen,
      params: _featureParam,
    );
    di.get<ProductAnalyticsService>().trackAnakraStart(
      entrySurface: EntrySurface.home,
    );
  }

  void _onMessageInputChanged() {
    final hasInput = _messageController.text.trim().isNotEmpty;
    if (hasInput == _hasInput) return;

    setState(() {
      _hasInput = hasInput;
    });
  }

  void _jumpToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
    }
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  @override
  void dispose() {
    _messageController.removeListener(_onMessageInputChanged);
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _dispatchMessage(
    AnakraChatProvider provider,
    String text, {
    required String entrySurface,
  }) async {
    if (_isDispatching || provider.isLoadingAnakra) return;
    final isCurrent = _requestGuard(provider);
    if (!isCurrent()) return;
    setState(() => _isDispatching = true);
    try {
      await _performDispatch(
        provider,
        text,
        entrySurface: entrySurface,
        isCurrent: isCurrent,
      );
    } catch (_) {
      if (mounted && isCurrent()) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(context.l10n.anakraServerError)));
      }
    } finally {
      if (mounted) setState(() => _isDispatching = false);
    }
  }

  bool Function() _requestGuard(AnakraChatProvider provider) {
    final revision = provider.identityRevision;
    final uid = provider.currentUserId;
    final auth = di.isRegistered<AuthSessionService>()
        ? di.get<AuthSessionService>()
        : null;
    return () =>
        mounted &&
        uid != null &&
        provider.identityRevision == revision &&
        provider.currentUserId == uid &&
        (auth == null || auth.currentUid == uid) &&
        ModalRoute.of(context)?.isCurrent == true &&
        (WidgetsBinding.instance.lifecycleState == null ||
            WidgetsBinding.instance.lifecycleState ==
                AppLifecycleState.resumed);
  }

  Future<void> _performDispatch(
    AnakraChatProvider provider,
    String text, {
    required String entrySurface,
    required bool Function() isCurrent,
  }) async {
    final facade = di.get<AnalyticsFacade>();
    final productAnalytics = di.get<ProductAnalyticsService>();
    final canMakeRequest = await checkRequestAccess(context, 'anakra');
    if (canMakeRequest == null) return;
    if (!mounted || !isCurrent()) return;
    if (!canMakeRequest) {
      facade.trackEvent(
        AnalyticsEvents.anakraLimitReached,
        params: {..._featureParam, EventParams.entrySurface: entrySurface},
      );
      productAnalytics.trackAnakraLimitReached(
        limitType: LimitType.messages,
        requestsLeft: 0,
        limitPeriod: LimitPeriod.unknown,
      );
      CreateAnakraRequestsLeftRoute.push(context);
      return;
    }

    if (entrySurface == 'text_input' &&
        _messageController.text.trim() == text) {
      _messageController.clear();
    }

    // Bucket length BEFORE the text leaves this method; never log raw text.
    final lengthBand = LengthBand.fromText(text);
    _userMessageIndex += 1;

    facade.trackEvent(
      AnalyticsEvents.anakraQuestionSent,
      params: {..._featureParam, EventParams.entrySurface: entrySurface},
    );
    productAnalytics.trackAnakraMessageSent(
      messageLengthBand: lengthBand,
      messageIndex: _userMessageIndex,
    );

    try {
      final hasResult = await provider.sendMessage(text);
      if (!isCurrent() ||
          hasResult == AnakraSendOutcome.stale ||
          hasResult == AnakraSendOutcome.ignored) {
        return;
      }
      if (hasResult == AnakraSendOutcome.failed) {
        productAnalytics.trackErrorStateView(
          screenName: '/anakra-chat',
          errorType: 'request_failed',
        );
      } else {
        facade.trackEvent(
          AnalyticsEvents.anakraAnswerReceived,
          params: {..._featureParam, EventParams.entrySurface: entrySurface},
        );
        productAnalytics.trackAnakraResponseView();
      }

      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (isCurrent()) _scrollToBottom();
      });
    } catch (e) {
      if (!isCurrent()) return;
      if (e.toString().contains('no_requests')) {
        facade.trackEvent(
          AnalyticsEvents.anakraLimitReached,
          params: {..._featureParam, EventParams.entrySurface: entrySurface},
        );
        productAnalytics.trackAnakraLimitReached(
          limitType: LimitType.messages,
          requestsLeft: 0,
          limitPeriod: LimitPeriod.unknown,
        );
        if (mounted) {
          CreateAnakraRequestsLeftRoute.push(context);
        }
      }
    }
  }

  Future<void> _sendMessage(AnakraChatProvider provider) async {
    final text = _messageController.text.trim();
    if (text.isEmpty || _isDispatching || provider.isLoadingAnakra) return;

    di.get<AnalyticsFacade>().trackEvent(
      AnalyticsEvents.anakraQuestionStarted,
      params: {..._featureParam, EventParams.entrySurface: 'text_input'},
    );

    await _dispatchMessage(provider, text, entrySurface: 'text_input');
  }

  Future<void> _onQuickAction(
    String action,
    AnakraChatProvider provider, {
    required String actionType,
  }) async {
    if (_isDispatching || provider.isLoadingAnakra) return;
    di.get<AnalyticsFacade>().trackEvent(
      AnalyticsEvents.anakraQuestionStarted,
      params: {..._featureParam, EventParams.entrySurface: 'quick_action'},
    );
    // Never log the raw action text — pass a stable semantic id instead.
    di.get<ProductAnalyticsService>().trackAnakraQuickActionClick(
      actionType: actionType,
    );

    await _dispatchMessage(provider, action, entrySurface: 'quick_action');
  }

  @override
  Widget build(BuildContext context) {
    return AnakraPageScaffold(
      resizeToAvoidBottomInset: true,
      child: Consumer<AnakraChatProvider>(
        builder: (context, provider, child) {
          if (provider.messages.any((m) => m.isUser) && !_hasScrolledToBottom) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (mounted && _scrollController.hasClients) {
                _hasScrolledToBottom = true;
                _jumpToBottom();
              }
            });
          }

          if (provider.messages.any((m) => m.isUser) &&
              provider.messages.length > _previousMessagesCount) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (mounted && _scrollController.hasClients) {
                _scrollToBottom();
              }
            });
            _previousMessagesCount = provider.messages.length;
          }

          return Column(
            children: [
              Expanded(
                child: CustomScrollView(
                  physics: const ClampingScrollPhysics(),
                  controller: _scrollController,
                  slivers: [
                    SliverToBoxAdapter(
                      child: AnakraHeroHeader(
                        onRequestsTap: () =>
                            CreateAnakraRequestsLeftRoute.push(context),
                      ),
                    ),
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            ...provider.messages.map(
                              (message) => AsteriaEntrance(
                                replayKey: (message.timestamp.toUtc(), message.isUser),
                                child: AnakraChatMessage(message: message),
                              ),
                            ),
                            if (provider.showQuickActions && !_isDispatching)
                              AnakraQuickActions(
                                onDrawCard: () => _onQuickAction(
                                  context.l10n.anakraQuickDrawCard,
                                  provider,
                                  actionType: 'draw_card',
                                ),
                                onCompatibility: () => _onQuickAction(
                                  context.l10n.anakraQuickCompatibility,
                                  provider,
                                  actionType: 'compatibility',
                                ),
                                onNatalChart: () => _onQuickAction(
                                  context.l10n.anakraQuickNatalChart,
                                  provider,
                                  actionType: 'natal_chart',
                                ),
                                onPowerDay: () => _onQuickAction(
                                  context.l10n.anakraQuickPowerDay,
                                  provider,
                                  actionType: 'power_day',
                                ),
                              ),
                            if (provider.isLoadingAnakra)
                              Padding(
                                padding: const EdgeInsets.fromLTRB(
                                  32,
                                  4,
                                  16,
                                  16,
                                ),
                                child: Row(
                                  children: [
                                    SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        valueColor:
                                            AlwaysStoppedAnimation<Color>(
                                              AnakraPalette.orange,
                                            ),
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Text(
                                      context.l10n.anakraTyping,
                                      style: context
                                          .textTheme
                                          .inverseUrbanistRegular14
                                          .copyWith(
                                            color: AnakraPalette.white
                                                .withValues(alpha: 0.72),
                                          ),
                                    ),
                                  ],
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SafeArea(
                top: false,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
                  child: AnakraComposer(
                    controller: _messageController,
                    busy: provider.isLoadingAnakra || _isDispatching,
                    hasInput: _hasInput,
                    onSend: () => _sendMessage(provider),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
