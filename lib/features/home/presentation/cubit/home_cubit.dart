import 'package:asteria_app/app/data/models/rune_of_day/rune_of_day_model.dart';
import 'package:asteria_app/app/data/models/tarot_card/tarot_card_model.dart';
import 'package:asteria_app/app/data/repositories/user/user_repository.dart';
import 'package:asteria_app/app/providers/content_provider.dart';
import 'package:asteria_app/app/providers/user_provider.dart';
import 'package:asteria_app/core/analytics/product_analytics_service.dart';
import 'package:asteria_app/core/analytics/analytics_route_observer.dart';
import 'package:asteria_app/core/di/di.dart';
import 'package:asteria_app/features/home/presentation/cubit/home_state.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class HomeCubit extends Cubit<HomeState> {
  final UserRepository _userRepository;
  final ContentProvider _contentProvider;

  bool _isInitialTarotCardLoaded = false;
  bool _isInitialRuneLoaded = false;
  bool _isRuneTapInProgress = false;
  bool _isTarotTapInProgress = false;

  HomeCubit({
    required UserRepository userRepository,
    required ContentProvider contentProvider,
    required UserProvider userProvider,
  }) : _userRepository = userRepository,
       _contentProvider = contentProvider,
       super(const HomeInitial());

  Future<void> start() async {
    emit(const HomeLoading());

    try {
      final isTarotCardOpened = _contentProvider.isTodayTarotCardOpened();
      final isRuneOpened = _contentProvider.isTodayRuneOpened();

      emit(
        HomeLoaded(
          isTarotCardOpened: isTarotCardOpened,
          isRuneOpened: isRuneOpened,
        ),
      );
    } catch (e) {
      emit(const HomeError(failure: HomeFailure.load));
    }
  }

  Future<void> logout() async {
    emit(const HomeLoading());

    try {
      await _userRepository.clearCurrentUser();
      emit(const HomeLoggedOut());
    } catch (e) {
      emit(const HomeError(failure: HomeFailure.logout));
    }
  }

  void changeTab(int tabIndex) {
    final currentState = state;
    if (currentState is HomeLoaded) {
      emit(currentState.copyWith(currentTabIndex: tabIndex));
      if (di.isRegistered<AnalyticsRouteObserver>()) {
        di.get<AnalyticsRouteObserver>().homeTab(tabIndex);
      }
    }
  }

  void resetTarotAndRuneOpenState() {
    _isInitialTarotCardLoaded = false;
    _isInitialRuneLoaded = false;
    final currentState = state;
    if (currentState is HomeLoaded) {
      emit(
        currentState.copyWith(isTarotCardOpened: false, isRuneOpened: false),
      );
    }
  }

  Future<void> loadDailySelection() async {
    final currentState = state;
    if (currentState is! HomeLoaded) return;

    final isTarotCardOpened = _contentProvider.isTodayTarotCardOpened();
    final isRuneOpened = _contentProvider.isTodayRuneOpened();

    final needLoadTarotCard =
        isTarotCardOpened &&
        currentState.tarotCard == null &&
        !_isInitialTarotCardLoaded;
    final needLoadRune =
        isRuneOpened && currentState.runeOfDay == null && !_isInitialRuneLoaded;
    final flagsChanged =
        currentState.isTarotCardOpened != isTarotCardOpened ||
        currentState.isRuneOpened != isRuneOpened;

    if (!needLoadTarotCard && !needLoadRune && !flagsChanged) {
      return;
    }

    try {
      TarotCardModel? tarotCard = currentState.tarotCard;
      if (needLoadTarotCard) {
        try {
          tarotCard = _contentProvider.getTodayTarotCard();
          _isInitialTarotCardLoaded = true;
        } catch (e) {
          debugPrint('[ERROR] Не удалось загрузить карту таро: $e');
          await _contentProvider.loadContent();
          try {
            tarotCard = _contentProvider.getTodayTarotCard();
            _isInitialTarotCardLoaded = true;
          } catch (e2) {
            tarotCard = null;
          }
        }
      }

      RuneOfDayModel? runeOfDay = currentState.runeOfDay;
      if (needLoadRune) {
        try {
          runeOfDay = _contentProvider.getTodayRune();
          _isInitialRuneLoaded = true;
        } catch (e) {
          debugPrint('[ERROR] Не удалось загрузить руну: $e');
          await _contentProvider.loadContent();
          try {
            runeOfDay = _contentProvider.getTodayRune();
            _isInitialRuneLoaded = true;
          } catch (e2) {
            runeOfDay = null;
          }
        }
      }

      emit(
        currentState.copyWith(
          runeOfDay: runeOfDay,
          tarotCard: tarotCard,
          isTarotCardOpened: isTarotCardOpened,
          isRuneOpened: isRuneOpened,
        ),
      );
    } catch (e) {
      debugPrint('Ошибка загрузки дневного выбора: $e');
    }
  }

  void refreshTarotCard() {
    final currentState = state;
    if (currentState is! HomeLoaded) return;

    try {
      _contentProvider.refreshTarotCard();
      final tarotCard = _contentProvider.getTodayTarotCard();
      emit(currentState.copyWith(tarotCard: tarotCard));
    } catch (e) {
      debugPrint('Ошибка обновления карты таро: $e');
    }
  }

  void syncTarotCard() {
    final currentState = state;
    if (currentState is! HomeLoaded) return;

    try {
      final isTarotCardOpened = _contentProvider.isTodayTarotCardOpened();
      final tarotCard = _contentProvider.getTodayTarotCard();

      final currentCardId = currentState.tarotCard?.id;
      final newCardId = tarotCard.id;

      if (currentCardId != newCardId ||
          currentState.isTarotCardOpened != isTarotCardOpened) {
        debugPrint(
          '[DEBUG] Синхронизация карты таро: старая ID=$currentCardId, новая ID=$newCardId',
        );
        emit(
          currentState.copyWith(
            tarotCard: tarotCard,
            isTarotCardOpened: isTarotCardOpened,
          ),
        );
      }
    } catch (e) {
      debugPrint('[ERROR] Ошибка синхронизации карты таро: $e');
    }
  }

  void refreshRune() {
    final currentState = state;
    if (currentState is! HomeLoaded) return;

    try {
      _contentProvider.refreshRune();
      final runeOfDay = _contentProvider.getTodayRune();
      emit(currentState.copyWith(runeOfDay: runeOfDay));
    } catch (e) {
      debugPrint('[ERROR] Ошибка обновления руны: $e');
    }
  }

  void syncRune() {
    final currentState = state;
    if (currentState is! HomeLoaded) return;

    try {
      final isRuneOpened = _contentProvider.isTodayRuneOpened();
      final runeOfDay = _contentProvider.getTodayRune();

      final currentRuneId = currentState.runeOfDay?.id;
      final newRuneId = runeOfDay.id;

      if (currentRuneId != newRuneId ||
          currentState.isRuneOpened != isRuneOpened) {
        debugPrint(
          '[DEBUG] Синхронизация руны дня: старая ID=$currentRuneId, новая ID=$newRuneId',
        );
        emit(
          currentState.copyWith(
            runeOfDay: runeOfDay,
            isRuneOpened: isRuneOpened,
          ),
        );
      }
    } catch (e) {
      debugPrint('[ERROR] Ошибка синхронизации руны дня: $e');
    }
  }

  void onTarotCardTapped() {
    final currentState = state;
    if (currentState is! HomeLoaded) return;
    if (currentState.isTarotCardOpened) return;
    if (_isTarotTapInProgress) return;

    _isTarotTapInProgress = true;
    try {
      final tarotCard = _contentProvider.getTodayTarotCard();
      _contentProvider.setTodayTarotCardOpened();
      di.get<ProductAnalyticsService>().trackTarotCardReveal(
        contentId: tarotCard.id,
      );
      emit(
        currentState.copyWith(isTarotCardOpened: true, tarotCard: tarotCard),
      );
    } finally {
      _isTarotTapInProgress = false;
    }
  }

  void onRuneTapped() {
    final currentState = state;
    if (currentState is! HomeLoaded) return;
    if (currentState.isRuneOpened) return;
    if (_isRuneTapInProgress) return;

    _isRuneTapInProgress = true;
    try {
      final rune = _contentProvider.getTodayRune();
      _contentProvider.setTodayRuneOpened();
      di.get<ProductAnalyticsService>().trackRunesReveal(contentId: rune.id);
      emit(currentState.copyWith(isRuneOpened: true, runeOfDay: rune));
    } finally {
      _isRuneTapInProgress = false;
    }
  }
}
